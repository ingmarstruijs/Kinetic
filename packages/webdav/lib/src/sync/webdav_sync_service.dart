import 'dart:convert';

import 'package:cryptography/cryptography.dart';
import 'package:flutter/foundation.dart';

import '../encryption/kinetic_encryption.dart';
import '../family_roster.dart';
import '../ical/ical_note.dart';
import '../ical/ical_serializer.dart';
import '../ical/ical_task.dart';
import '../presence_info.dart';
import '../kid_goal.dart';
import '../load_metrics.dart';
import '../sync_config.dart';
import '../webdav_client.dart';

/// Synchronises [ICalTask]s and [ICalNote]s with a WebDAV server.
///
/// Each resource is stored as a single encrypted `.ics` file:
///   - Personal tasks:  `/kinetic/{username}/tasks/{uid}.ics` (personal key)
///   - Personal notes:  `/kinetic/{username}/notes/{uid}.ics` (personal key)
///   - Shared notes:    `/kinetic/shared/notes/{uid}.ics`     (family key)
///
/// All `.ics` files are AES-256-GCM encrypted; the raw bytes stored on the
/// server are `[nonce][ciphertext+mac]` (see [KineticEncryption]).
///
/// Conflict resolution: Last-Write-Wins on [ICalTask.updatedAt].
class WebDavSyncService {
  final WebDavClient client;
  final SyncConfig config;

  WebDavSyncService({required this.client, required this.config});

  // ---------------------------------------------------------------------------
  // Tasks
  // ---------------------------------------------------------------------------

  String get _tasksPath => '/kinetic/${config.username}/tasks';

  /// Pulls all tasks from the server, decrypts each one, and returns the list.
  Future<List<ICalTask>> pullTasks() async {
    final entries = await _listIcsFiles(_tasksPath);
    final tasks = <ICalTask>[];
    var ok = 0;
    var errors = 0;
    for (final entry in entries) {
      try {
        final href = _relativizeHref(entry.href);
        final blob = await client.get(href);
        final plain =
            await KineticEncryption.decrypt(blob, config.personalKeyBytes);
        final ical = utf8.decode(plain);
        tasks.add(ICalSerializer.vtodoToTask(ical));
        ok++;
      } catch (e) {
        errors++;
        if (kDebugMode) {
          debugPrint('[tasks] GET/decrypt failed ${entry.href}: $e');
        }
        // Skip corrupted or unreadable files — do not abort the sync.
        continue;
      }
    }
    if (kDebugMode) {
      var open = 0;
      var done = 0;
      var other = 0;
      for (final t in tasks) {
        switch (t.status) {
          case ICalTaskStatus.completed:
            done++;
          case ICalTaskStatus.needsAction:
          case ICalTaskStatus.inProcess:
            open++;
          case ICalTaskStatus.cancelled:
            other++;
        }
      }
      debugPrint(
        '[tasks] pull listed:${entries.length} ok:$ok'
        '${errors > 0 ? ' errors:$errors' : ''} '
        '→ total:${tasks.length} open:$open done:$done'
        '${other > 0 ? ' other:$other' : ''}',
      );
      if (tasks.isNotEmpty) {
        final ids = tasks.map((t) {
          final id = t.uid.length <= 8 ? t.uid : t.uid.substring(0, 8);
          final mark = switch (t.status) {
            ICalTaskStatus.completed => 'D',
            ICalTaskStatus.cancelled => 'X',
            ICalTaskStatus.inProcess => 'P',
            ICalTaskStatus.needsAction => 'O',
          };
          return '$id$mark';
        }).join(', ');
        debugPrint('[tasks] pull ids: $ids');
      }
    }
    return tasks;
  }

  /// Encrypts [task] and PUTs it to `/kinetic/{username}/tasks/{uid}.ics`.
  Future<void> pushTask(ICalTask task) async {
    final ical = ICalSerializer.taskToVtodo(task);
    final plain = Uint8List.fromList(utf8.encode(ical));
    final blob =
        await KineticEncryption.encrypt(plain, config.personalKeyBytes);
    await _putWithCollectionFallback('$_tasksPath/${task.uid}.ics', blob);
  }

  /// Deletes the task file for [uid] from the server.
  Future<void> deleteTask(String uid) => client.delete('$_tasksPath/$uid.ics');

  // ---------------------------------------------------------------------------
  // Notes
  // ---------------------------------------------------------------------------

  String get _personalNotesPath => '/kinetic/${config.username}/notes';
  String get _sharedNotesPath => '/kinetic/shared/notes';

  /// Extracts the path-relative-to-baseUrl from a PROPFIND href.
  /// PROPFIND responses include full paths like `/webdav/kinetic/shared/notes/file.ics`,
  /// but client.get() needs just the kinetic-relative path like `/kinetic/shared/notes/file.ics`.
  String _relativizeHref(String href) {
    // Extract the path component from baseUrl.
    final Uri baseUri = Uri.parse(client.baseUrl);
    final basePath = baseUri.path;
    // If href starts with basePath, remove it.
    if (basePath.isNotEmpty && href.startsWith(basePath)) {
      return href.substring(basePath.length);
    }
    return href;
  }

  /// Pulls all personal notes (personal key) and shared notes (family key).
  Future<List<ICalNote>> pullNotes() async {
    final notes = <ICalNote>[];
    var personalListed = 0;
    var personalOk = 0;
    var personalMissing = 0;
    var personalErrors = 0;
    var sharedListed = 0;
    var sharedOk = 0;
    var sharedMissing = 0;
    var sharedMacFail = 0;
    var sharedErrors = 0;
    var sharedSkippedNoKey = false;

    // Personal notes
    final personalEntries = await _listIcsFiles(_personalNotesPath);
    personalListed = personalEntries.length;
    for (final entry in personalEntries) {
      try {
        final href = _relativizeHref(entry.href);
        final blob = await client.get(href);
        final plain =
            await KineticEncryption.decrypt(blob, config.personalKeyBytes);
        notes.add(ICalSerializer.vjournalToNote(utf8.decode(plain)));
        personalOk++;
      } on WebDavException catch (e) {
        // Skip 404s — file may have been deleted or PROPFIND returned stale entry
        if (e.message.contains('404')) {
          personalMissing++;
          continue;
        }
        personalErrors++;
        if (kDebugMode) {
          debugPrint('[notes] personal GET/decrypt failed ${entry.href}: $e');
        }
      } catch (e) {
        personalErrors++;
        if (kDebugMode) {
          debugPrint('[notes] personal decrypt failed ${entry.href}: $e');
        }
      }
    }

    // Shared notes — only if family key is available.
    final familyKey = config.familyKeyBytes;
    if (familyKey != null) {
      final sharedEntries = await _listIcsFiles(_sharedNotesPath);
      sharedListed = sharedEntries.length;
      final staleSharedHrefs = <String>[];
      for (final entry in sharedEntries) {
        try {
          final href = _relativizeHref(entry.href);
          final blob = await client.get(href);
          final plain = await KineticEncryption.decrypt(blob, familyKey);
          notes.add(ICalSerializer.vjournalToNote(utf8.decode(plain)));
          sharedOk++;
        } on SecretBoxAuthenticationError {
          final href = _relativizeHref(entry.href);
          sharedMacFail++;
          staleSharedHrefs.add(href);
        } on WebDavException catch (e) {
          if (e.message.contains('404')) {
            sharedMissing++;
            continue;
          }
          sharedErrors++;
          if (kDebugMode) {
            debugPrint('[notes] shared GET failed ${entry.href}: $e');
          }
        } catch (e) {
          sharedErrors++;
          if (kDebugMode) {
            debugPrint('[notes] shared decrypt failed ${entry.href}: $e');
          }
        }
      }
      // Current family key opened at least one file, so MAC failures are
      // leftovers from an old key — delete them. If *nothing* decrypted,
      // the key itself may be wrong; leave the files alone.
      if (sharedOk > 0 && staleSharedHrefs.isNotEmpty) {
        await _deleteStaleSharedNotes(staleSharedHrefs);
      }
    } else {
      sharedSkippedNoKey = true;
    }

    if (kDebugMode) {
      final sharedPart = sharedSkippedNoKey
          ? 'shared=skipped(no family key)'
          : 'shared=listed:$sharedListed ok:$sharedOk'
              '${sharedMacFail > 0 ? ' macFail:$sharedMacFail' : ''}'
              '${sharedMissing > 0 ? ' missing404:$sharedMissing' : ''}'
              '${sharedErrors > 0 ? ' errors:$sharedErrors' : ''}';
      debugPrint(
        '[notes] pull '
        'personal=listed:$personalListed ok:$personalOk'
        '${personalMissing > 0 ? ' missing404:$personalMissing' : ''}'
        '${personalErrors > 0 ? ' errors:$personalErrors' : ''} '
        '$sharedPart → total:${notes.length}',
      );
      if (notes.isNotEmpty) {
        final ids = notes.map((n) {
          final id = n.uid.length <= 8 ? n.uid : n.uid.substring(0, 8);
          return '$id${n.isShared ? 'S' : 'P'}';
        }).join(', ');
        debugPrint('[notes] pull ids: $ids');
      }
    }
    return notes;
  }

  /// Encrypts [note] and pushes it to the correct folder.
  Future<void> pushNote(ICalNote note) async {
    final ical = ICalSerializer.noteToVjournal(note);
    final plain = Uint8List.fromList(utf8.encode(ical));

    if (note.isShared) {
      final familyKey = config.familyKeyBytes;
      if (familyKey == null) {
        throw StateError('Family key required to push shared note');
      }
      final blob = await KineticEncryption.encrypt(plain, familyKey);
      await _putWithCollectionFallback(
        '$_sharedNotesPath/${note.uid}.ics',
        blob,
      );
    } else {
      final blob =
          await KineticEncryption.encrypt(plain, config.personalKeyBytes);
      await _putWithCollectionFallback(
        '$_personalNotesPath/${note.uid}.ics',
        blob,
      );
    }
  }

  /// Deletes a note from the server.  [isShared] determines the folder.
  Future<void> deleteNote(String uid, {required bool isShared}) {
    final path = isShared
        ? '$_sharedNotesPath/$uid.ics'
        : '$_personalNotesPath/$uid.ics';
    return client.delete(path);
  }

  String _noteAssetsDir(String noteUid, {required bool isShared}) =>
      isShared
          ? '$_sharedNotesPath/$noteUid.assets'
          : '$_personalNotesPath/$noteUid.assets';

  /// Encrypts and uploads a note image asset beside the note `.ics`.
  Future<void> pushNoteAsset({
    required String noteUid,
    required String assetId,
    required Uint8List plainBytes,
    required bool isShared,
  }) async {
    final key = isShared ? config.familyKeyBytes : config.personalKeyBytes;
    if (isShared && key == null) {
      throw StateError('Family key required to push shared note asset');
    }
    final blob = await KineticEncryption.encrypt(plainBytes, key!);
    final dir = _noteAssetsDir(noteUid, isShared: isShared);
    await _putWithCollectionFallback('$dir/$assetId.bin', blob);
  }

  /// Lists and decrypts note image assets for [noteUid].
  Future<List<({String assetId, Uint8List bytes})>> pullNoteAssets(
    String noteUid, {
    required bool isShared,
  }) async {
    final key = isShared ? config.familyKeyBytes : config.personalKeyBytes;
    if (isShared && key == null) return const [];
    final dir = _noteAssetsDir(noteUid, isShared: isShared);
    List<WebDavEntry> entries;
    try {
      entries = await client.propfind(dir);
    } catch (_) {
      return const [];
    }
    final out = <({String assetId, Uint8List bytes})>[];
    for (final entry in entries) {
      if (entry.isCollection) continue;
      final href = _relativizeHref(entry.href);
      final name = href.split('/').where((s) => s.isNotEmpty).last;
      if (!name.endsWith('.bin')) continue;
      final assetId = name.substring(0, name.length - 4);
      try {
        final blob = await client.get(href);
        final plain = await KineticEncryption.decrypt(blob, key!);
        out.add((assetId: assetId, bytes: plain));
      } catch (_) {
        // Skip undecryptable / missing assets.
      }
    }
    return out;
  }

  /// Best-effort delete of the asset collection for a note.
  Future<void> deleteNoteAssets(String noteUid, {required bool isShared}) async {
    try {
      await client.delete(_noteAssetsDir(noteUid, isShared: isShared));
    } catch (_) {
      // Collection may not exist.
    }
  }

  // ---------------------------------------------------------------------------
  // LWW merge helper
  // ---------------------------------------------------------------------------

  /// Merges [remote] tasks into [local] using Last-Write-Wins on [ICalTask.updatedAt].
  ///
  /// Returns:
  ///   - [merged]: the canonical list after merge (to write to the local DB)
  ///   - [toPush]: tasks from [local] that are newer than their remote counterpart
  ///     (caller should push these after calling this method)
  static ({List<ICalTask> merged, List<ICalTask> toPush}) mergeTasks(
    List<ICalTask> local,
    List<ICalTask> remote,
  ) {
    final remoteByUid = {for (final t in remote) t.uid: t};
    final localByUid = {for (final t in local) t.uid: t};

    final merged = <ICalTask>[];
    final toPush = <ICalTask>[];

    // Remote wins if updated > local, otherwise local wins (and needs push).
    for (final uid in {...remoteByUid.keys, ...localByUid.keys}) {
      final r = remoteByUid[uid];
      final l = localByUid[uid];
      if (r == null) {
        // Local-only: push to server.
        merged.add(l!);
        toPush.add(l);
      } else if (l == null) {
        // Remote-only: adopt.
        merged.add(r);
      } else if (!r.updatedAt.isBefore(l.updatedAt)) {
        // Remote is same age or newer: adopt remote.
        merged.add(r);
      } else {
        // Local is newer: keep local, push it.
        merged.add(l);
        toPush.add(l);
      }
    }
    return (merged: merged, toPush: toPush);
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  Future<void> _deleteStaleSharedNotes(List<String> hrefs) async {
    for (final href in hrefs) {
      try {
        if (kDebugMode) {
          debugPrint('[notes] deleting undecryptable leftover: $href');
        }
        await client.delete(href);
      } catch (e) {
        if (kDebugMode) {
          debugPrint('[notes] failed deleting leftover $href: $e');
        }
      }
    }
  }

  /// Returns PROPFIND entries whose href ends with `.ics`.
  Future<List<WebDavEntry>> _listIcsFiles(String path) async {
    try {
      final entries = await client.propfind(path);
      return entries.where((e) => e.href.endsWith('.ics')).toList();
    } on WebDavException catch (e) {
      // If the directory does not exist yet return empty list.
      if (e.message.contains('404')) return [];
      rethrow;
    }
  }

  // ---------------------------------------------------------------------------
  // Shared Tasks (link→kids assignments)
  // ---------------------------------------------------------------------------

  String get _sharedTasksPath => '/kinetic/shared/tasks';

  /// Pulls all shared tasks from `/kinetic/shared/tasks/` (family key encrypted).
  /// Used by the kids app to receive link-assigned tasks.
  Future<List<ICalTask>> pullSharedTasks() async {
    final familyKey = config.familyKeyBytes;
    if (familyKey == null) return [];
    final entries = await _listIcsFiles(_sharedTasksPath);
    final tasks = <ICalTask>[];
    for (final entry in entries) {
      try {
        final href = _relativizeHref(entry.href);
        final blob = await client.get(href);
        final plain = await KineticEncryption.decrypt(blob, familyKey);
        tasks.add(ICalSerializer.vtodoToTask(utf8.decode(plain)));
      } catch (e) {
        continue;
      }
    }
    return tasks;
  }

  /// Encrypts [task] with the family key and PUTs it to `/kinetic/shared/tasks/{uid}.ics`.
  Future<void> pushSharedTask(ICalTask task) async {
    final familyKey = config.familyKeyBytes;
    if (familyKey == null) {
      throw StateError('Family key required to push shared tasks');
    }
    final ical = ICalSerializer.taskToVtodo(task);
    final plain = Uint8List.fromList(utf8.encode(ical));
    final blob = await KineticEncryption.encrypt(plain, familyKey);
    // Same MKCOL fallback as goals/presence — Link enrollment may never have
    // run setupDirectories on this server, so /kinetic/shared/tasks can be absent.
    await _putWithCollectionFallback(
      '$_sharedTasksPath/${task.uid}.ics',
      blob,
    );
  }

  /// Deletes a shared task from `/kinetic/shared/tasks/{uid}.ics`.
  Future<void> deleteSharedTask(String uid) =>
      client.delete('$_sharedTasksPath/$uid.ics');

  // ---------------------------------------------------------------------------
  // Proposals (JSON-based)
  // ---------------------------------------------------------------------------

  String get _proposalsPath => '/kinetic/shared/proposals';

  /// Pulls all proposals from the shared folder (encrypted with family key).
  /// Returns a list of JSON-decoded proposal maps.
  Future<List<Map<String, dynamic>>> pullProposals() async {
    final familyKey = config.familyKeyBytes;
    if (familyKey == null) return []; // No family key, no proposals to pull

    final entries = await _listJsonFiles(_proposalsPath);
    final proposals = <Map<String, dynamic>>[];

    for (final entry in entries) {
      try {
        final href = _relativizeHref(entry.href);
        final blob = await client.get(href);
        final plain = await KineticEncryption.decrypt(blob, familyKey);
        final json = jsonDecode(utf8.decode(plain)) as Map<String, dynamic>;
        proposals.add(json);
      } catch (e) {
        continue; // Skip corrupted files
      }
    }
    return proposals;
  }

  /// Encrypts [proposalJson] and PUTs it to `/kinetic/shared/proposals/{id}.json`.
  /// Creates the directory on-demand if it doesn't exist (for backward compatibility
  /// with accounts set up before this feature was added).
  Future<void> pushProposal(Map<String, dynamic> proposalJson) async {
    final familyKey = config.familyKeyBytes;
    if (familyKey == null) {
      throw StateError('Family key required to push proposals');
    }

    final id = proposalJson['id'] as String;
    final plain = Uint8List.fromList(utf8.encode(jsonEncode(proposalJson)));
    final blob = await KineticEncryption.encrypt(plain, familyKey);

    await _putWithCollectionFallback('$_proposalsPath/$id.json', blob);
  }

  /// Deletes a proposal file from the server.
  Future<void> deleteProposal(String id) =>
      client.delete('$_proposalsPath/$id.json');

  // ---------------------------------------------------------------------------
  // Load Metrics (JSON-based)
  // ---------------------------------------------------------------------------

  String get _loadPath => '/kinetic/shared/load';

  /// Pulls all family members' load metrics (encrypted with family key).
  Future<List<LoadMetrics>> pullLoadMetrics() async {
    final familyKey = config.familyKeyBytes;
    if (familyKey == null) return []; // No family key, no metrics to pull

    final entries = await _listJsonFiles(_loadPath);
    final metrics = <LoadMetrics>[];

    for (final entry in entries) {
      try {
        final href = _relativizeHref(entry.href);
        final blob = await client.get(href);
        final plain = await KineticEncryption.decrypt(blob, familyKey);
        final json = jsonDecode(utf8.decode(plain)) as Map<String, dynamic>;
        final parsed = LoadMetrics.tryFromJson(json);
        if (parsed != null) metrics.add(parsed);
      } catch (e) {
        continue;
      }
    }
    return metrics;
  }

  /// Encrypts and PUTs load metrics to `/kinetic/shared/load/{linkId}.json`.
  /// Creates the directory on-demand if it doesn't exist (for backward compatibility
  /// with accounts set up before this feature was added).
  Future<void> pushLoadMetrics(LoadMetrics metrics) async {
    final familyKey = config.familyKeyBytes;
    if (familyKey == null) {
      throw StateError('Family key required to push load metrics');
    }

    final plain = Uint8List.fromList(utf8.encode(jsonEncode(metrics.toJson())));
    final blob = await KineticEncryption.encrypt(plain, familyKey);

    await _putWithCollectionFallback(
      '$_loadPath/${metrics.linkId}.json',
      blob,
    );
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  /// HTTP status codes returned when PUT targets a file in a missing collection.
  static const _missingCollectionStatuses = ['403', '404', '409'];

  bool _isMissingCollectionError(WebDavException e) =>
      _missingCollectionStatuses.any(e.message.contains);

  /// PUTs [bytes] to [path], creating missing parent collections on demand.
  ///
  /// Walks ancestors from the deepest parent up to `/kinetic` so a wiped
  /// shared tree (e.g. only `/kinetic/shared/presence` missing mid-path) is
  /// rebuilt instead of failing the write after a single MKCOL attempt.
  Future<void> _putWithCollectionFallback(String path, Uint8List bytes) async {
    try {
      await client.put(path, bytes);
    } on WebDavException catch (e) {
      if (!_isMissingCollectionError(e)) rethrow;
      final parents = <String>[];
      var cursor = path;
      while (true) {
        final lastSlash = cursor.lastIndexOf('/');
        if (lastSlash <= 0) break;
        cursor = cursor.substring(0, lastSlash);
        if (cursor.isEmpty || cursor == '/') break;
        parents.add(cursor);
        // Stop at the kinetic root — do not MKCOL the WebDAV base itself.
        if (cursor == '/kinetic') break;
      }
      for (final collectionPath in parents.reversed) {
        try {
          await client.mkcol(collectionPath);
        } catch (_) {
          // Directory may already exist, or a deeper parent is still missing;
          // continue so later MKCOLs / the final PUT can succeed.
        }
      }
      await client.put(path, bytes);
    }
  }

  /// Returns PROPFIND entries whose href ends with `.json`.
  Future<List<WebDavEntry>> _listJsonFiles(String path) async {
    try {
      final entries = await client.propfind(path);
      return entries.where((e) => e.href.endsWith('.json')).toList();
    } on WebDavException catch (e) {
      if (e.message.contains('404')) return [];
      rethrow;
    }
  }

  // ---------------------------------------------------------------------------
  // Presence heartbeat
  // ---------------------------------------------------------------------------

  String get _presencePath => '/kinetic/shared/presence';
  String get _disconnectPath => '/kinetic/shared/disconnect';

  /// Writes a presence heartbeat for [info] to the shared presence folder,
  /// encrypted with the family key.  No-op when no family key is available.
  Future<void> pushPresence(PresenceInfo info) async {
    final familyKey = config.familyKeyBytes;
    if (familyKey == null) return;

    final plain = Uint8List.fromList(utf8.encode(jsonEncode(info.toJson())));
    final blob = await KineticEncryption.encrypt(plain, familyKey);

    await _putWithCollectionFallback(
      '$_presencePath/${info.deviceId}.json',
      blob,
    );
  }

  /// Pulls all presence entries from the shared presence folder.
  /// Returns an empty list when no family key is available or no entries exist.
  Future<List<PresenceInfo>> pullPresence() async {
    final familyKey = config.familyKeyBytes;
    if (familyKey == null) return [];

    final entries = await _listJsonFiles(_presencePath);
    final result = <PresenceInfo>[];
    for (final entry in entries) {
      try {
        final href = _relativizeHref(entry.href);
        final blob = await client.get(href);
        final plain = await KineticEncryption.decrypt(blob, familyKey);
        final json = jsonDecode(utf8.decode(plain)) as Map<String, dynamic>;
        final presence = PresenceInfo.tryFromJson(json);
        if (presence != null) result.add(presence);
      } catch (_) {
        continue;
      }
    }
    return result;
  }

  // ---------------------------------------------------------------------------
  // Disconnect tombstones
  // ---------------------------------------------------------------------------

  /// Writes a disconnect tombstone for [deviceId], signalling to other
  /// family members that this device has intentionally left.
  Future<void> pushDisconnect(DisconnectTombstone tombstone) async {
    final familyKey = config.familyKeyBytes;
    if (familyKey == null) return;

    final plain =
        Uint8List.fromList(utf8.encode(jsonEncode(tombstone.toJson())));
    final blob = await KineticEncryption.encrypt(plain, familyKey);

    await _putWithCollectionFallback(
      '$_disconnectPath/${tombstone.deviceId}.json',
      blob,
    );
  }

  /// Pulls all disconnect tombstones from the shared disconnect folder.
  Future<List<DisconnectTombstone>> pullDisconnects() async {
    final familyKey = config.familyKeyBytes;
    if (familyKey == null) return [];

    final entries = await _listJsonFiles(_disconnectPath);
    final result = <DisconnectTombstone>[];
    for (final entry in entries) {
      try {
        final href = _relativizeHref(entry.href);
        final blob = await client.get(href);
        final plain = await KineticEncryption.decrypt(blob, familyKey);
        final json = jsonDecode(utf8.decode(plain)) as Map<String, dynamic>;
        result.add(DisconnectTombstone.fromJson(json));
      } catch (_) {
        continue;
      }
    }
    return result;
  }

  /// Removes the disconnect tombstone for [deviceId] from the server.
  Future<void> deleteDisconnect(String deviceId) =>
      client.delete('$_disconnectPath/$deviceId.json');

  /// Removes the presence entry for [deviceId] from the server.
  Future<void> deletePresence(String deviceId) =>
      client.delete('$_presencePath/$deviceId.json');

  // ---------------------------------------------------------------------------
  // Family roster
  // ---------------------------------------------------------------------------

  String get _rosterPath => '/kinetic/shared/roster.json';

  /// Writes the canonical [roster] document (family-key encrypted).
  Future<void> pushRoster(FamilyRoster roster) async {
    final familyKey = config.familyKeyBytes;
    if (familyKey == null) return;

    final plain =
        Uint8List.fromList(utf8.encode(jsonEncode(roster.toJson())));
    final blob = await KineticEncryption.encrypt(plain, familyKey);
    await _putWithCollectionFallback(_rosterPath, blob);
  }

  /// Pulls the shared roster, or null when missing / no family key.
  Future<FamilyRoster?> pullRoster() async {
    final familyKey = config.familyKeyBytes;
    if (familyKey == null) return null;
    try {
      final blob = await client.get(_rosterPath);
      final plain = await KineticEncryption.decrypt(blob, familyKey);
      final json = jsonDecode(utf8.decode(plain)) as Map<String, dynamic>;
      return FamilyRoster.fromJson(json);
    } catch (_) {
      return null;
    }
  }

  // ---------------------------------------------------------------------------
  // XP Reset
  // ---------------------------------------------------------------------------

  String get _xpResetPath => '/kinetic/shared/xp-reset';

  /// Writes an XP-reset timestamp for [kidId] to the shared folder.
  /// The kids app reads this during sync and only counts XP earned after this time.
  Future<void> pushXpReset(String kidId, DateTime resetAt) async {
    final familyKey = config.familyKeyBytes;
    if (familyKey == null) throw StateError('Family key required to push XP reset');
    final json = jsonEncode({
      'kidId': kidId,
      'resetAt': resetAt.toUtc().toIso8601String(),
    });
    final plain = Uint8List.fromList(utf8.encode(json));
    final blob = await KineticEncryption.encrypt(plain, familyKey);
    await _putWithCollectionFallback('$_xpResetPath/$kidId.json', blob);
  }

  /// Reads the XP-reset timestamp for [kidId], or null if none has been set.
  Future<DateTime?> pullXpReset(String kidId) async {
    final familyKey = config.familyKeyBytes;
    if (familyKey == null) return null;
    try {
      final blob = await client.get('$_xpResetPath/$kidId.json');
      final plain = await KineticEncryption.decrypt(blob, familyKey);
      final data = jsonDecode(utf8.decode(plain)) as Map<String, dynamic>;
      final resetAtStr = data['resetAt'] as String?;
      if (resetAtStr == null) return null;
      return DateTime.parse(resetAtStr);
    } catch (_) {
      return null;
    }
  }

  // ---------------------------------------------------------------------------
  // Kid goals
  // ---------------------------------------------------------------------------

  String get _goalsPath => '/kinetic/shared/goals';

  /// Writes or replaces the XP goal for [goal.kidId].
  Future<void> pushGoal(KidGoal goal) async {
    final familyKey = config.familyKeyBytes;
    if (familyKey == null) throw StateError('Family key required to push goal');
    final plain = Uint8List.fromList(utf8.encode(jsonEncode(goal.toJson())));
    final blob = await KineticEncryption.encrypt(plain, familyKey);
    await _putWithCollectionFallback('$_goalsPath/${goal.kidId}.json', blob);
  }

  /// Reads the goal for [kidId], or null if missing / undecryptable.
  Future<KidGoal?> pullGoal(String kidId) async {
    final familyKey = config.familyKeyBytes;
    if (familyKey == null) return null;
    try {
      final blob = await client.get('$_goalsPath/$kidId.json');
      final plain = await KineticEncryption.decrypt(blob, familyKey);
      final data = jsonDecode(utf8.decode(plain)) as Map<String, dynamic>;
      return KidGoal.fromJson(data);
    } catch (_) {
      return null;
    }
  }

  /// Pulls goals for every enrolled kid id that has a file.
  Future<Map<String, KidGoal>> pullGoals(Iterable<String> kidIds) async {
    final result = <String, KidGoal>{};
    for (final id in kidIds) {
      final goal = await pullGoal(id);
      if (goal != null) result[id] = goal;
    }
    return result;
  }

  /// Deletes the goal file for [kidId].
  Future<void> deleteGoal(String kidId) =>
      client.delete('$_goalsPath/$kidId.json');

  // ---------------------------------------------------------------------------
  // Family key rotation — re-wrap `/kinetic/shared/**` blobs
  // ---------------------------------------------------------------------------

  /// Re-encrypts every family-key blob under `/kinetic/shared/`.
  ///
  /// Files that cannot be opened with [oldFamilyKey] are left unchanged and
  /// counted in [FamilySharedReencryptReport.skipped].
  Future<FamilySharedReencryptReport> reencryptSharedTree({
    required Uint8List oldFamilyKey,
    required Uint8List newFamilyKey,
    void Function(FamilySharedReencryptProgress progress)? onProgress,
  }) async {
    final paths = <String>[];
    for (final entry in await _listIcsFiles(_sharedNotesPath)) {
      paths.add(_relativizeHref(entry.href));
    }
    for (final entry in await _listIcsFiles(_sharedTasksPath)) {
      paths.add(_relativizeHref(entry.href));
    }
    for (final path in [
      _proposalsPath,
      _loadPath,
      _presencePath,
      _disconnectPath,
      _xpResetPath,
      _goalsPath,
    ]) {
      for (final entry in await _listJsonFiles(path)) {
        paths.add(_relativizeHref(entry.href));
      }
    }
    paths.add(_rosterPath);

    var reencrypted = 0;
    var skipped = 0;
    var failed = 0;
    final total = paths.length;

    for (var i = 0; i < paths.length; i++) {
      final path = paths[i];
      onProgress?.call(
        FamilySharedReencryptProgress(path: path, index: i, total: total),
      );
      try {
        final Uint8List blob;
        try {
          blob = await client.get(path);
        } on WebDavException catch (e) {
          if (e.message.contains('404')) {
            skipped++;
            continue;
          }
          rethrow;
        }
        Uint8List plain;
        try {
          plain = await KineticEncryption.decrypt(blob, oldFamilyKey);
        } catch (_) {
          skipped++;
          continue;
        }
        final wrapped =
            await KineticEncryption.encrypt(plain, newFamilyKey);
        await _putWithCollectionFallback(path, wrapped);
        reencrypted++;
      } catch (e) {
        if (kDebugMode) {
          debugPrint('Family re-encrypt failed for $path: $e');
        }
        failed++;
      }
    }

    return FamilySharedReencryptReport(
      reencrypted: reencrypted,
      skipped: skipped,
      failed: failed,
    );
  }
}

/// Progress callback payload for [WebDavSyncService.reencryptSharedTree].
class FamilySharedReencryptProgress {
  const FamilySharedReencryptProgress({
    required this.path,
    required this.index,
    required this.total,
  });

  final String path;
  final int index;
  final int total;
}

/// Counts from [WebDavSyncService.reencryptSharedTree].
class FamilySharedReencryptReport {
  const FamilySharedReencryptReport({
    required this.reencrypted,
    required this.skipped,
    required this.failed,
  });

  final int reencrypted;
  final int skipped;
  final int failed;

  bool get ok => failed == 0;
}
