import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:kinetic_webdav/kinetic_webdav.dart';

import '../db/app_database.dart';
import '../partner/models/partner_proposal.dart';
import '../settings/models/enrolled_kid.dart';
import '../todo/models/enums.dart';
import '../todo/models/personal_note.dart';
import 'webdav_config_repository.dart';

/// True when this device's [myId] appears in disconnect tombstone device ids.
bool disconnectIncludesSelf(String myId, List<String> disconnectedIds) =>
    myId.isNotEmpty && disconnectedIds.contains(myId);

/// Drives a full sync cycle against the WebDAV server.
///
/// Call [sync] in the background (e.g. on app resume or a timer).
class SyncOrchestrator {
  final AppDatabase _db;
  final SyncConfig _config;
  final WebDavConfigRepository? _configRepo;

  /// Optional callback invoked after disconnect tombstones are processed.
  ///
  /// Receives the list of device IDs that sent an explicit disconnect so the
  /// caller (main.dart) can update UI notifiers (partner pairing, kids count).
  final void Function(List<String> disconnectedIds)? onDisconnectsDetected;

  /// Called after the shared roster is merged so UI can refresh link members/kids.
  final void Function(FamilyRoster roster)? onRosterUpdated;

  SyncOrchestrator({
    required AppDatabase db,
    required SyncConfig config,
    WebDavConfigRepository? configRepository,
    this.onDisconnectsDetected,
    this.onRosterUpdated,
  }) : _db = db,
       _config = config,
       _configRepo = configRepository;

  /// The WebDAV username (used as the local link ID).
  String get username => _config.username;

  /// The stable link device UUID (used to identify this device in proposals).
  String get linkId => _config.linkId;

  /// The full sync config (used by screens that need WebDAV access).
  SyncConfig get config => _config;

  Future<void> sync() async {
    final client = WebDavClient(
      baseUrl: _config.baseUrl,
      username: _config.username,
      password: _config.password,
    );
    final service = WebDavSyncService(client: client, config: _config);
    try {
      // Disconnects before roster so a kicked device does not re-add itself.
      await _processDisconnects(service);
      await _syncTasks(service);
      await _syncNotes(service);
      await _syncProposals(service);
      await _syncRoster(service);
      await _pushPresence(service);
    } finally {
      client.dispose();
    }
  }

  /// Runs the full sync pipeline against a pre-built [service].
  ///
  /// Exposed for integration testing — production code always uses [sync].
  @visibleForTesting
  Future<void> syncWithService(WebDavSyncService service) async {
    await _processDisconnects(service);
    await _syncTasks(service);
    await _syncNotes(service);
    await _syncProposals(service);
    await _syncRoster(service);
    await _pushPresence(service);
  }

  // ---------------------------------------------------------------------------
  // Presence heartbeat
  // ---------------------------------------------------------------------------

  Future<void> _pushPresence(WebDavSyncService service) async {
    if (_config.familyKeyBytes == null) return;
    try {
      await service.pushPresence(
        PresenceInfo(
          deviceId: _config.linkId.isNotEmpty
              ? _config.linkId
              : _config.username,
          deviceType: 'link',
          displayName: _config.username,
          lastSeen: DateTime.now().toUtc(),
        ),
      );
    } catch (_) {
      // Non-critical — silently skip if server is unreachable.
    }
  }

  /// Pulls all family-member presence entries (excluding self).
  ///
  /// Called from settings UI to display last-seen timestamps.
  Future<List<PresenceInfo>> pullPresence() async {
    if (_config.familyKeyBytes == null) return [];
    final client = WebDavClient(
      baseUrl: _config.baseUrl,
      username: _config.username,
      password: _config.password,
    );
    final service = WebDavSyncService(client: client, config: _config);
    try {
      final myId = _config.linkId.isNotEmpty
          ? _config.linkId
          : _config.username;
      final all = await service.pullPresence();
      return all.where((p) => p.deviceId != myId).toList();
    } finally {
      client.dispose();
    }
  }

  // ---------------------------------------------------------------------------
  // Family roster
  // ---------------------------------------------------------------------------

  Future<void> _syncRoster(WebDavSyncService service) async {
    final configRepo = _configRepo;
    if (_config.familyKeyBytes == null || configRepo == null) return;
    // Skip if this device was just kicked (family key cleared mid-sync).
    final liveKey = await configRepo.loadFamilyKey();
    if (liveKey == null) return;
    final myId =
        _config.linkId.isNotEmpty ? _config.linkId : _config.username;
    if (myId.isEmpty) return;

    try {
      final remote = await service.pullRoster() ?? FamilyRoster.empty();
      final localCached =
          await configRepo.loadCachedRoster() ?? FamilyRoster.empty();
      final kids = await configRepo.loadEnrolledKids();
      final kidsParticipation = await configRepo.loadKidsParticipation();
      final now = DateTime.now().toUtc();

      final previousSelf = [
        ...localCached.linkMembers,
        ...remote.linkMembers,
      ].where((a) => a.id == myId).firstOrNull;

      final self = FamilyLinkMember(
        id: myId,
        displayName: _config.username,
        kidsParticipation: kidsParticipation,
        joinedAt: previousSelf?.joinedAt ?? now,
        updatedAt: now,
      );

      var merged = FamilyRoster.merge(localCached, remote).withLocalLinkMember(
        self: self,
        localKids: kids.map((k) => k.toFamilyKidMember()).toList(),
      );

      await service.pushRoster(merged);
      await configRepo.saveCachedRoster(merged);
      await configRepo.restoreEnrolledKids(
        merged.kids.map(EnrolledKid.fromFamilyKidMember).toList(),
      );
      onRosterUpdated?.call(merged);
    } catch (_) {
      // Non-critical — retry next cycle.
    }
  }

  // ---------------------------------------------------------------------------
  // Disconnect tombstones
  // ---------------------------------------------------------------------------

  /// Checks the shared disconnect folder.  If a tombstone for a known
  /// partner or enrolled kid is found the callback is invoked and the
  /// tombstone is cleaned up so it is not processed again.
  Future<void> _processDisconnects(WebDavSyncService service) async {
    if (_config.familyKeyBytes == null) return;
    try {
      final tombstones = await service.pullDisconnects();
      if (tombstones.isEmpty) return;
      final disconnectedIds = tombstones.map((t) => t.deviceId).toList();

      final configRepo = _configRepo;
      if (configRepo != null) {
        var roster =
            await configRepo.loadCachedRoster() ?? FamilyRoster.empty();
        for (final id in disconnectedIds) {
          roster = roster.withoutMember(id);
        }
        try {
          await service.pushRoster(roster);
        } catch (_) {}
        await configRepo.saveCachedRoster(roster);
        await configRepo.restoreEnrolledKids(
          roster.kids.map(EnrolledKid.fromFamilyKidMember).toList(),
        );
        onRosterUpdated?.call(roster);
      }

      onDisconnectsDetected?.call(disconnectedIds);
      // Clean up processed tombstones so they are not re-read next cycle.
      for (final tombstone in tombstones) {
        try {
          await service.deleteDisconnect(tombstone.deviceId);
        } catch (_) {}
      }
    } catch (_) {
      // Non-critical.
    }
  }

  /// Writes an explicit disconnect tombstone for this link device and
  /// removes its own presence entry.  Call this before clearing the family key.
  Future<void> pushDisconnect() async {
    if (_config.familyKeyBytes == null) return;
    final client = WebDavClient(
      baseUrl: _config.baseUrl,
      username: _config.username,
      password: _config.password,
    );
    final service = WebDavSyncService(client: client, config: _config);
    try {
      final myId = _config.linkId.isNotEmpty
          ? _config.linkId
          : _config.username;
      await service.pushDisconnect(
        DisconnectTombstone(
          deviceId: myId,
          deviceType: 'link',
          disconnectedAt: DateTime.now().toUtc(),
        ),
      );
      try {
        await service.deletePresence(myId);
      } catch (_) {}
    } finally {
      client.dispose();
    }
  }

  /// Writes a disconnect tombstone for [memberId] and removes them from the
  /// shared roster. Call when a Link user removes another family member.
  Future<void> removeLinkMember(String memberId) async {
    if (_config.familyKeyBytes == null || memberId.isEmpty) return;
    final myId =
        _config.linkId.isNotEmpty ? _config.linkId : _config.username;
    if (memberId == myId) return;

    final client = WebDavClient(
      baseUrl: _config.baseUrl,
      username: _config.username,
      password: _config.password,
    );
    final service = WebDavSyncService(client: client, config: _config);
    try {
      await service.pushDisconnect(
        DisconnectTombstone(
          deviceId: memberId,
          deviceType: 'link',
          disconnectedAt: DateTime.now().toUtc(),
        ),
      );
      try {
        await service.deletePresence(memberId);
      } catch (_) {}

      final configRepo = _configRepo;
      if (configRepo != null) {
        var roster =
            await configRepo.loadCachedRoster() ?? FamilyRoster.empty();
        roster = roster.withoutMember(memberId);
        try {
          await service.pushRoster(roster);
        } catch (_) {}
        await configRepo.saveCachedRoster(roster);
        onRosterUpdated?.call(roster);
      }
    } finally {
      client.dispose();
    }
  }

  /// Writes a disconnect tombstone for a removed kid and removes their
  /// presence entry.  Call this when the link user removes an enrolled kid.
  Future<void> pushKidDisconnect(EnrolledKid kid) async {
    if (_config.familyKeyBytes == null) return;
    final client = WebDavClient(
      baseUrl: _config.baseUrl,
      username: _config.username,
      password: _config.password,
    );
    final service = WebDavSyncService(client: client, config: _config);
    try {
      await service.pushDisconnect(
        DisconnectTombstone(
          deviceId: kid.id,
          deviceType: 'kid',
          disconnectedAt: DateTime.now().toUtc(),
        ),
      );
      try {
        await service.deletePresence(kid.id);
      } catch (_) {}
    } finally {
      client.dispose();
    }
  }

  // ---------------------------------------------------------------------------
  // Tasks
  // ---------------------------------------------------------------------------

  Future<void> _syncTasks(WebDavSyncService service) async {
    // 1a. Push dirty tasks delegated to kids FIRST (shared tasks folder).
    //     Must happen before step 1b marks them clean.
    if (_config.familyKeyBytes != null) {
      await _syncKidsTasks(service);
    }

    // 1b. Push dirty local tasks (personal tasks folder).
    //     Exclude tasks that have a kidsTaskId — those belong in the shared
    //     tasks folder (handled by step 1a) and must not be pushed here.
    final dirtyRows = await (_db.select(
      _db.personalTasks,
    )..where((t) => t.syncState.equals('dirty') & t.kidsTaskId.isNull())).get();

    for (final row in dirtyRows) {
      final icalTask = _rowToICalTask(row);
      try {
        await service.pushTask(icalTask);
        await (_db.update(
          _db.personalTasks,
        )..where((t) => t.id.equals(row.id))).write(
          PersonalTasksCompanion(
            syncState: const Value('clean'),
            updatedAt: Value(DateTime.now()),
          ),
        );
      } catch (_) {
        // Leave dirty for next cycle.
      }
    }

    // 2. Push locally-deleted tasks (tombstones stored with syncState='deleted').
    //    Also delete from shared folder if the task was sent to kids.
    final deletedRows = await (_db.select(
      _db.personalTasks,
    )..where((t) => t.syncState.equals('deleted'))).get();

    for (final row in deletedRows) {
      try {
        await service.deleteTask(row.id);
        // If this task was sent to kids, remove it from the shared folder too.
        if (row.kidsTaskId != null) {
          try {
            await service.deleteSharedTask(row.kidsTaskId!);
          } catch (_) {
            // Ignore if file doesn't exist on server.
          }
        }
        await (_db.delete(
          _db.personalTasks,
        )..where((t) => t.id.equals(row.id))).go();
      } catch (_) {}
    }

    // 3. Pull from server.
    final remoteList = await service.pullTasks();
    if (remoteList.isEmpty) return;

    final localList = await _db.select(_db.personalTasks).get();
    final merge = WebDavSyncService.mergeTasks(
      localList.map(_rowToICalTask).toList(),
      remoteList,
    );

    // 4. Apply merged result.
    for (final task in merge.merged) {
      final existing = localList.where((r) => r.id == task.uid).firstOrNull;
      if (existing == null) {
        // New from server — insert.
        await _db
            .into(_db.personalTasks)
            .insertOnConflictUpdate(_icalTaskToCompanion(task, etag: null));
      } else if (!existing.updatedAt.isAtSameMomentAs(task.updatedAt)) {
        // Remote is different — update.
        await (_db.update(_db.personalTasks)
              ..where((t) => t.id.equals(task.uid)))
            .write(_icalTaskToCompanion(task, etag: existing.webdavEtag));
      }
    }

    // 5. Push tasks that were newer locally.
    for (final task in merge.toPush) {
      try {
        await service.pushTask(task);
      } catch (_) {}
    }
  }

  /// Pushes tasks with a kidsTaskId to the shared tasks folder and preserves
  /// kid-side IN-PROCESS (awaiting link-app verification) on the wire.
  Future<void> _syncKidsTasks(WebDavSyncService service) async {
    Map<String, ICalTask> sharedByUid = {};
    try {
      final sharedTasks = await service.pullSharedTasks();
      sharedByUid = {for (final t in sharedTasks) t.uid: t};
    } catch (_) {
      // Unreachable WebDAV — still try to push dirty kids tasks below.
    }

    // Push any dirty tasks that have a kidsTaskId.
    final rows =
        await (_db.select(_db.personalTasks)..where(
              (t) => t.kidsTaskId.isNotNull() & t.syncState.equals('dirty'),
            ))
            .get();
    for (final row in rows) {
      final baseNotes = row.notes ?? '';
      final targetKidPart = row.targetKidId != null
          ? ';xKineticTargetKidId:${row.targetKidId}'
          : '';
      final verifierPart = row.verifierLinkId != null
          ? ';xKineticVerifierLinkId:${row.verifierLinkId}'
          : '';
      final description =
          '$baseNotes;xKineticLinkTaskId:${row.id};xKineticCategory:${row.category};xKineticXpReward:${row.xpReward}$targetKidPart$verifierPart';
      final remote = sharedByUid[row.kidsTaskId!];
      final status = row.isCompleted
          ? ICalTaskStatus.completed
          : (remote?.status == ICalTaskStatus.inProcess
              ? ICalTaskStatus.inProcess
              : ICalTaskStatus.needsAction);
      final kidsTask = ICalTask(
        uid: row.kidsTaskId!,
        summary: row.title,
        description: description,
        status: status,
        priority: _driftPriorityToICal(row.priority),
        createdAt: row.createdAt,
        updatedAt: row.updatedAt,
        dueAt: row.dueDate,
      );
      try {
        await service.pushSharedTask(kidsTask);
        await (_db.update(_db.personalTasks)..where((t) => t.id.equals(row.id)))
            .write(const PersonalTasksCompanion(syncState: Value('clean')));
      } catch (_) {
        // Leave dirty for retry next cycle.
      }
    }
  }

  /// Link app accepts a kid's completion request — awards XP on the wire.
  Future<void> acceptKidsTaskCompletion(ICalTask sharedTask) async {
    final client = WebDavClient(
      baseUrl: _config.baseUrl,
      username: _config.username,
      password: _config.password,
    );
    final service = WebDavSyncService(client: client, config: _config);
    try {
      final now = DateTime.now().toUtc();
      await service.pushSharedTask(
        sharedTask.copyWith(
          status: ICalTaskStatus.completed,
          updatedAt: now,
        ),
      );
      final linked =
          await (_db.select(_db.personalTasks)..where(
                (t) => t.kidsTaskId.equals(sharedTask.uid),
              ))
              .getSingleOrNull();
      if (linked != null) {
        await (_db.update(
          _db.personalTasks,
        )..where((t) => t.id.equals(linked.id))).write(
          PersonalTasksCompanion(
            isCompleted: const Value(true),
            completedAt: Value(now),
            updatedAt: Value(now),
            syncState: const Value('dirty'),
          ),
        );
      }
    } finally {
      client.dispose();
    }
  }

  /// Link app rejects a completion request — task returns to open for the kid.
  Future<void> rejectKidsTaskCompletion(ICalTask sharedTask) async {
    final client = WebDavClient(
      baseUrl: _config.baseUrl,
      username: _config.username,
      password: _config.password,
    );
    final service = WebDavSyncService(client: client, config: _config);
    try {
      await service.pushSharedTask(
        sharedTask.copyWith(
          status: ICalTaskStatus.needsAction,
          updatedAt: DateTime.now().toUtc(),
        ),
      );
    } finally {
      client.dispose();
    }
  }

  // ---------------------------------------------------------------------------
  // Notes
  // ---------------------------------------------------------------------------

  Future<void> _syncNotes(WebDavSyncService service) async {
    // 1. Push dirty local notes.
    final dirtyRows = await (_db.select(
      _db.personalNotes,
    )..where((t) => t.syncState.equals('dirty'))).get();

    for (final row in dirtyRows) {
      final icalNote = _rowToICalNote(row);
      try {
        // Push to the correct folder based on current isShared value
        await service.pushNote(icalNote);

        // If this note was previously synced, ensure there's no orphaned file
        // in the "other" folder (could happen if isShared was toggled).
        // Try to delete from the opposite location (silently ignore 404s).
        try {
          final oppositeIsShared = !icalNote.isShared;
          await service.deleteNote(row.id, isShared: oppositeIsShared);
        } catch (_) {
          // File may not exist — that's fine.
        }

        await (_db.update(
          _db.personalNotes,
        )..where((t) => t.id.equals(row.id))).write(
          // Only clear the dirty flag — do NOT change updatedAt so that the
          // iCal timestamp and the local timestamp remain in sync.
          const PersonalNotesCompanion(syncState: Value('clean')),
        );
      } catch (e) {
        if (kDebugMode) debugPrint('Error pushing note ${row.id}: $e');
        // Leave dirty for next cycle.
      }
    }

    // 2. Push locally-deleted notes (tombstones stored with syncState='deleted').
    final deletedRows = await (_db.select(
      _db.personalNotes,
    )..where((t) => t.syncState.equals('deleted'))).get();

    for (final row in deletedRows) {
      try {
        await service.deleteNote(row.id, isShared: row.isShared);
        await (_db.delete(
          _db.personalNotes,
        )..where((t) => t.id.equals(row.id))).go();
      } catch (_) {}
    }

    // 3. Pull from server.
    final remoteList = await service.pullNotes();
    if (kDebugMode) {
      debugPrint(
        'Pulled ${remoteList.length} notes from server (personal + shared)',
      );
    }

    final localList = await _db.select(_db.personalNotes).get();
    final remoteIds = remoteList.map((n) => n.uid).toSet();

    // 3a. Detect and remove shared notes that were deleted on the partner's device.
    // If a shared note exists locally but not on the server, and it's clean (not dirty),
    // then it was deleted remotely and should be removed locally too.
    for (final local in localList) {
      if (local.isShared &&
          local.syncState == 'clean' &&
          !remoteIds.contains(local.id)) {
        if (kDebugMode) {
          debugPrint(
            'Shared note deleted on partner device, removing locally: ${local.id}',
          );
        }
        await (_db.delete(
          _db.personalNotes,
        )..where((t) => t.id.equals(local.id))).go();
      }
    }

    if (remoteList.isEmpty) return;

    // 4. Apply Last-Write-Wins merge: remote wins only when it is strictly
    //    newer than the local copy AND the local copy is clean (unmodified).
    //    If the local copy is dirty the user has unsaved changes — we keep
    //    them and they will be pushed on the next sync cycle.
    for (final note in remoteList) {
      // Audience filter: selected-member shares are only for listed link members.
      if (note.isShared) {
        final audience = note.sharedMemberIds;
        if (audience != null && audience.isNotEmpty) {
          final myId = _config.linkId.isNotEmpty
              ? _config.linkId
              : _config.username;
          if (!audience.contains(myId)) continue;
        }
      }
      final existing = localList.where((r) => r.id == note.uid).firstOrNull;
      if (existing == null) {
        // New from server — insert.
        if (kDebugMode) {
          debugPrint(
            'Inserting new note from server: ${note.uid} (isShared=${note.isShared})',
          );
        }
        await _db
            .into(_db.personalNotes)
            .insertOnConflictUpdate(_icalNoteToCompanion(note, etag: null));
      } else if (existing.syncState != 'dirty' &&
          note.updatedAt.isAfter(existing.updatedAt)) {
        // Remote is newer and local has no pending changes — adopt remote.
        if (kDebugMode) {
          debugPrint(
            'Updating existing note from server: ${note.uid} (isShared=${note.isShared})',
          );
        }
        await (_db.update(_db.personalNotes)
              ..where((t) => t.id.equals(note.uid)))
            .write(_icalNoteToCompanion(note, etag: existing.webdavEtag));
      }
    }
  }

  // ---------------------------------------------------------------------------
  // Conversion helpers
  // ---------------------------------------------------------------------------

  static ICalNote _rowToICalNote(PersonalNoteRow row) {
    return ICalNote(
      uid: row.id,
      summary: row.title,
      description: row.body,
      isShared: row.isShared,
      sharedMemberIds: PersonalNote.decodeSharedMemberIds(row.sharedMemberIds),
      updatedByLinkId: row.updatedByLinkId,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
      remindAt: row.remindAt,
    );
  }

  static PersonalNotesCompanion _icalNoteToCompanion(
    ICalNote note, {
    required String? etag,
  }) {
    final members = note.sharedMemberIds;
    return PersonalNotesCompanion(
      id: Value(note.uid),
      title: Value(note.summary),
      body: Value(note.description ?? ''),
      isShared: Value(note.isShared),
      sharedMemberIds: Value(
        members == null || members.isEmpty ? null : jsonEncode(members),
      ),
      updatedByLinkId: Value(note.updatedByLinkId),
      createdAt: Value(note.createdAt),
      updatedAt: Value(note.updatedAt),
      remindAt: Value(note.remindAt),
      syncState: const Value('clean'),
      webdavEtag: Value(etag),
    );
  }

  static ICalTask _rowToICalTask(PersonalTaskRow row) {
    return ICalTask(
      uid: row.id,
      summary: row.title,
      description: row.notes,
      status: row.isCompleted
          ? ICalTaskStatus.completed
          : ICalTaskStatus.needsAction,
      priority: _driftPriorityToICal(row.priority),
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
      dueAt: row.dueDate,
      remindAt: row.remindAt,
      rrule: row.recurrenceRule,
    );
  }

  static PersonalTasksCompanion _icalTaskToCompanion(
    ICalTask task, {
    required String? etag,
  }) {
    return PersonalTasksCompanion(
      id: Value(task.uid),
      title: Value(task.summary),
      notes: Value(task.description),
      isCompleted: Value(task.status == ICalTaskStatus.completed),
      completedAt: task.status == ICalTaskStatus.completed
          ? Value(task.updatedAt)
          : const Value(null),
      priority: Value(_icalPriorityToDrift(task.priority)),
      dueDate: Value(task.dueAt),
      remindAt: Value(task.remindAt),
      recurrenceRule: Value(task.rrule),
      createdAt: Value(task.createdAt),
      updatedAt: Value(task.updatedAt),
      syncState: const Value('clean'),
      webdavEtag: Value(etag),
      // Keep existing list / category / flags — don't overwrite from server.
      isAllDay: const Value(true),
      isFlagged: const Value(false),
      isPrivate: const Value(false),
      category: const Value('other'),
      sortOrder: const Value(0),
    );
  }

  static int _driftPriorityToICal(int drift) => switch (drift) {
    3 => 1, // high → iCal 1
    2 => 5, // medium → iCal 5
    1 => 9, // low → iCal 9
    _ => 0,
  };

  static int _icalPriorityToDrift(int ical) => switch (ical) {
    1 => 3,
    5 => 2,
    9 => 1,
    _ => 0,
  };

  // ---------------------------------------------------------------------------
  // Proposals
  // ---------------------------------------------------------------------------

  Future<void> _syncProposals(WebDavSyncService service) async {
    // 1. Push dirty local proposals (accepted/rejected/snoozed feedback +
    //    new auto-generated outbound proposals).
    final dirtyRows = await (_db.select(
      _db.partnerProposals,
    )..where((p) => p.syncState.equals('dirty'))).get();
    for (final row in dirtyRows) {
      try {
        final proposal = _proposalRowToProposal(row);
        final json = _proposalToJson(proposal);
        await service.pushProposal(json);
        await (_db.update(_db.partnerProposals)
              ..where((p) => p.id.equals(row.id)))
            .write(const PartnerProposalsCompanion(syncState: Value('clean')));
      } catch (_) {
        // Leave dirty for next cycle.
      }
    }

    // 2. Pull remote proposals.
    final remotes = await service.pullProposals();
    final remoteProposals = _jsonListToProposals(remotes);

    // 3. Get local proposals and merge (LWW).
    final localRows = await _db.select(_db.partnerProposals).get();
    final locals = localRows.map(_proposalRowToProposal).toList();
    final merged = _mergeProposals(locals, remoteProposals);

    // 4. Write merged proposals to local DB.
    for (final proposal in merged) {
      await _db
          .into(_db.partnerProposals)
          .insertOnConflictUpdate(_proposalToCompanion(proposal));
    }

    // 4a. Clean up tasks for accepted outgoing proposals.
    // If we sent a proposal and it is (now) accepted, remove the matching
    // open task from this device. Do not require syncState=clean — most
    // recently sent tasks are still dirty.
    final myLinkId = _config.linkId;
    for (final proposal in merged) {
      if (proposal.fromLinkId != myLinkId) continue;
      if (proposal.status != ProposalStatus.accepted) continue;

      final localProposal = locals
          .where((p) => p.id == proposal.id)
          .firstOrNull;
      final newlyAccepted =
          localProposal == null ||
          localProposal.status != ProposalStatus.accepted;
      final needle = _normalizeProposalTitle(proposal.taskTitle);

      final openTasks =
          await (_db.select(_db.personalTasks)..where(
                (t) =>
                    t.isCompleted.equals(false) &
                    t.syncState.equals('deleted').not(),
              ))
              .get();

      for (final task in openTasks) {
        if (_normalizeProposalTitle(task.title) != needle) continue;
        // On later syncs, only retry-delete tasks that predate acceptance so a
        // brand-new same-title task is kept.
        if (!newlyAccepted && task.createdAt.isAfter(proposal.updatedAt)) {
          continue;
        }
        await (_db.update(_db.personalTasks)
              ..where((t) => t.id.equals(task.id)))
            .write(
              PersonalTasksCompanion(
                syncState: const Value('deleted'),
                updatedAt: Value(DateTime.now().toUtc()),
              ),
            );
      }
    }
  }

  static String _normalizeProposalTitle(String title) =>
      title.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');

  PartnerProposal _proposalRowToProposal(PartnerProposalRow row) {
    return PartnerProposal(
      id: row.id,
      fromLinkId: row.fromLinkId,
      toMemberId: row.toMemberId,
      taskTitle: row.taskTitle,
      taskNotes: row.taskNotes,
      taskCategory: row.taskCategory,
      taskPriority: TaskPriority.values[row.taskPriority],
      taskDueDate: row.taskDueDate,
      status: ProposalStatus.values.firstWhere((e) => e.name == row.status),
      receivedAt: row.receivedAt,
      updatedAt: row.updatedAt,
      autoGenerated: row.autoGenerated,
    );
  }

  Map<String, dynamic> _proposalToJson(PartnerProposal p) => {
    'id': p.id,
    'fromLinkId': p.fromLinkId,
    'toMemberId': p.toMemberId,
    'taskTitle': p.taskTitle,
    'taskNotes': p.taskNotes,
    'taskCategory': p.taskCategory,
    'taskPriority': p.taskPriority.index,
    'taskDueDate': p.taskDueDate?.toIso8601String(),
    'status': p.status.name,
    'receivedAt': p.receivedAt.toIso8601String(),
    'updatedAt': p.updatedAt.toIso8601String(),
    'autoGenerated': p.autoGenerated,
  };

  PartnerProposal _jsonToProposal(Map<String, dynamic> json) {
    return PartnerProposal(
      id: json['id'] as String,
      fromLinkId: json['fromLinkId'] as String,
      toMemberId: json['toMemberId'] as String?,
      taskTitle: json['taskTitle'] as String,
      taskNotes: json['taskNotes'] as String?,
      taskCategory: json['taskCategory'] as String? ?? 'other',
      taskPriority: TaskPriority.values[json['taskPriority'] as int],
      taskDueDate: json['taskDueDate'] != null
          ? DateTime.parse(json['taskDueDate'] as String)
          : null,
      status: ProposalStatus.values.firstWhere((e) => e.name == json['status']),
      receivedAt: DateTime.parse(json['receivedAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      autoGenerated: json['autoGenerated'] as bool? ?? false,
    );
  }

  List<PartnerProposal> _jsonListToProposals(List<Map<String, dynamic>> jsons) {
    return jsons.map(_jsonToProposal).toList();
  }

  PartnerProposalsCompanion _proposalToCompanion(PartnerProposal p) {
    return PartnerProposalsCompanion(
      id: Value(p.id),
      fromLinkId: Value(p.fromLinkId),
      toMemberId: Value(p.toMemberId),
      taskTitle: Value(p.taskTitle),
      taskNotes: Value(p.taskNotes),
      taskCategory: Value(p.taskCategory),
      taskPriority: Value(p.taskPriority.index),
      taskDueDate: Value(p.taskDueDate),
      status: Value(p.status.name),
      receivedAt: Value(p.receivedAt),
      updatedAt: Value(p.updatedAt),
      autoGenerated: Value(p.autoGenerated),
      syncState: const Value('clean'),
    );
  }

  /// LWW merge: remote wins if newer, local wins if older.
  List<PartnerProposal> _mergeProposals(
    List<PartnerProposal> local,
    List<PartnerProposal> remote,
  ) {
    final remoteById = {for (final p in remote) p.id: p};
    final localById = {for (final p in local) p.id: p};

    final merged = <PartnerProposal>[];

    for (final id in {...remoteById.keys, ...localById.keys}) {
      final r = remoteById[id];
      final l = localById[id];

      if (r == null) {
        merged.add(l!);
      } else if (l == null) {
        merged.add(r);
      } else if (!r.updatedAt.isBefore(l.updatedAt)) {
        merged.add(r);
      } else {
        merged.add(l);
      }
    }
    return merged;
  }
}
