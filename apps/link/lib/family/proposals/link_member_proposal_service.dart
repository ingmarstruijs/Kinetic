import 'package:drift/drift.dart';

import '../../db/app_database.dart';
import '../../todo/models/enums.dart';
import '../../todo/services/todo_repository.dart';
import 'link_member_proposal.dart';
import 'package:kinetic_webdav/kinetic_webdav.dart';

/// LinkMemberProposalService — manages proposal sync via WebDAV.
///
/// Proposals represent tasks proposed by another link member (link→link communication).
/// Each proposal is stored as encrypted JSON in `/kinetic/shared/proposals/`.
class LinkMemberProposalService {
  final WebDavSyncService service;
  final AppDatabase db;
  final TodoRepository todoRepository;

  LinkMemberProposalService({
    required this.service,
    required this.db,
    required this.todoRepository,
  });

  /// Pulls remote proposals, merges with local using LWW on updatedAt.
  Future<void> syncProposals(String fromLinkId) async {
    // Pull remote proposals
    final remote = await service.pullProposals();
    final remoteProposals = _jsonListToProposals(remote);

    // Get local proposals
    final local = await db.select(db.linkMemberProposals).get();

    // LWW merge
    final merged = _mergeProposals(
      local.map(_rowToProposal).toList(),
      remoteProposals,
    );

    // Write to local DB
    for (final proposal in merged) {
      await db
          .into(db.linkMemberProposals)
          .insertOnConflictUpdate(_proposalToCompanion(proposal));
    }
  }

  /// Push a newly created/updated proposal to the server.
  /// The proposal must have syncState='dirty' — this will set it to 'clean'.
  Future<void> pushProposal(LinkMemberProposal proposal) async {
    final json = _proposalToJson(proposal);
    await service.pushProposal(json);

    // Mark as clean in local DB
    await (db.update(
      db.linkMemberProposals,
    )..where((p) => p.id.equals(proposal.id))).write(
      LinkMemberProposalsCompanion(
        syncState: const Value('clean'),
        updatedAt: Value(DateTime.now().toUtc()),
      ),
    );
  }

  /// Delete a proposal (hard delete from server, soft delete locally).
  Future<void> deleteProposal(String proposalId) async {
    // Soft delete locally
    await (db.update(
      db.linkMemberProposals,
    )..where((p) => p.id.equals(proposalId))).write(
      LinkMemberProposalsCompanion(
        syncState: const Value('deleted'),
        updatedAt: Value(DateTime.now().toUtc()),
      ),
    );

    // Try to delete from server (may not exist if newly created)
    try {
      await service.deleteProposal(proposalId);
    } catch (e) {
      // Ignore "file not found" errors
      if (!e.toString().contains('404')) rethrow;
    }
  }

  /// Stream pending proposals (status='pending') ordered by receivedAt.
  Stream<List<LinkMemberProposal>> watchPendingProposals() {
    return (db.select(db.linkMemberProposals)
          ..where((p) => p.status.equals('pending'))
          ..orderBy([(p) => OrderingTerm.desc(p.receivedAt)]))
        .watch()
        .map((rows) => rows.map(_rowToProposal).toList());
  }

  /// Update proposal status (pending → accepted/dismissed).
  Future<void> updateProposalStatus(String id, String newStatus) async {
    await (db.update(db.linkMemberProposals)..where((p) => p.id.equals(id))).write(
      LinkMemberProposalsCompanion(
        status: Value(newStatus),
        updatedAt: Value(DateTime.now().toUtc()),
        syncState: const Value('dirty'),
      ),
    );
  }

  /// Accept a proposal: update status to 'accepted' and create a task.
  Future<void> acceptProposal(LinkMemberProposal proposal) async {
    final due = proposal.taskDueDate;
    final timed =
        due != null && (due.toLocal().hour != 0 || due.toLocal().minute != 0);
    final categoryRaw = proposal.taskCategory.trim();
    final enumCategory = TaskCategory.values
        .where((c) => c.name == categoryRaw)
        .firstOrNull;
    final customCategory =
        enumCategory == null &&
            categoryRaw.isNotEmpty &&
            categoryRaw != 'other'
        ? categoryRaw
        : null;

    final created = await todoRepository.createTask(
      title: proposal.taskTitle,
      notes: proposal.taskNotes,
      category: enumCategory ?? TaskCategory.other,
      customCategory: customCategory,
      priority: proposal.taskPriority,
      dueDate: due,
      isAllDay: due == null || !timed,
      remindAt: timed ? due : null,
      isPrivate: false,
    );

    await (db.update(db.linkMemberProposals)..where((p) => p.id.equals(proposal.id)))
        .write(
          LinkMemberProposalsCompanion(
            status: const Value('accepted'),
            resultTaskId: Value(created.id),
            updatedAt: Value(DateTime.now().toUtc()),
            syncState: const Value('dirty'),
          ),
        );
  }

  /// Dismiss a proposal: update status to 'dismissed'.
  Future<void> dismissProposal(String proposalId) async {
    await updateProposalStatus(proposalId, 'dismissed');
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  LinkMemberProposal _rowToProposal(LinkMemberProposalRow row) {
    return LinkMemberProposal(
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
      sourceTaskId: row.sourceTaskId,
      resultTaskId: row.resultTaskId,
    );
  }

  LinkMemberProposalsCompanion _proposalToCompanion(LinkMemberProposal p) {
    return LinkMemberProposalsCompanion(
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
      sourceTaskId: Value(p.sourceTaskId),
      resultTaskId: Value(p.resultTaskId),
    );
  }

  Map<String, dynamic> _proposalToJson(LinkMemberProposal p) {
    return {
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
      'sourceTaskId': p.sourceTaskId,
      'resultTaskId': p.resultTaskId,
    };
  }

  LinkMemberProposal _jsonToProposal(Map<String, dynamic> json) {
    return LinkMemberProposal(
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
      sourceTaskId: json['sourceTaskId'] as String?,
      resultTaskId: json['resultTaskId'] as String?,
    );
  }

  List<LinkMemberProposal> _jsonListToProposals(List<Map<String, dynamic>> jsons) {
    return jsons.map(_jsonToProposal).toList();
  }

  /// LWW merge: remote wins if newer, local wins if older (and needs push).
  List<LinkMemberProposal> _mergeProposals(
    List<LinkMemberProposal> local,
    List<LinkMemberProposal> remote,
  ) {
    final remoteById = {for (final p in remote) p.id: p};
    final localById = {for (final p in local) p.id: p};

    final merged = <LinkMemberProposal>[];

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
