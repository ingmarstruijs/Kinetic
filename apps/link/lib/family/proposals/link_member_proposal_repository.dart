import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../db/app_database.dart';
import '../../todo/models/enums.dart';
import '../../todo/services/todo_repository.dart';
import 'link_member_proposal.dart';

/// LinkMemberProposalRepository — CRUD for inter-link task proposals.
///
/// Manages proposals from the other link member, supporting accept/snooze/dismiss workflow.
class LinkMemberProposalRepository {
  final AppDatabase _db;
  final TodoRepository _todoRepository;
  final _uuid = const Uuid();

  LinkMemberProposalRepository({
    required AppDatabase db,
    required TodoRepository todoRepository,
  }) : _db = db,
       _todoRepository = todoRepository;

  /// All pending proposals from a family member, ordered by received date (newest first).
  ///
  /// [myLinkId] is used to exclude proposals sent by the local user so they
  /// do not appear in their own inbox.
  /// Also filters out proposals whose task title closely matches a task already
  /// present in the local personal task list (receiver already has the task).
  Stream<List<LinkMemberProposal>> watchPending({String? myLinkId}) {
    final proposalsStream =
        (_db.select(_db.linkMemberProposals)
              ..where((t) => t.status.equals('pending'))
              ..orderBy([(t) => OrderingTerm.desc(t.receivedAt)]))
            .watch()
            .map(
              (rows) => rows
                  .map(_proposalFromRow)
                  .where(
                    (p) =>
                        myLinkId == null || p.isAddressedTo(myLinkId),
                  )
                  .toList(),
            );

    final tasksStream =
        (_db.select(_db.personalTasks)..where(
              (t) =>
                  t.isCompleted.equals(false) &
                  t.syncState.equals('deleted').not(),
            ))
            .watch();

    return proposalsStream.asyncExpand(
      (proposals) => tasksStream.map((taskRows) {
        final ownTitles = taskRows.map((r) => _normalizeTitle(r.title)).toSet();
        return proposals
            .where((p) => !ownTitles.contains(_normalizeTitle(p.taskTitle)))
            .toList();
      }),
    );
  }

  static String _normalizeTitle(String title) =>
      title.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');

  /// All proposals (any status), ordered by received date (newest first).
  Stream<List<LinkMemberProposal>> watchAll() {
    return (_db.select(_db.linkMemberProposals)
          ..orderBy([(t) => OrderingTerm.desc(t.receivedAt)]))
        .watch()
        .map((rows) => rows.map(_proposalFromRow).toList());
  }

  /// Stream a single proposal by id.
  Stream<LinkMemberProposal?> watchOne(String id) {
    return (_db.select(_db.linkMemberProposals)..where((t) => t.id.equals(id)))
        .watchSingleOrNull()
        .map((row) => row != null ? _proposalFromRow(row) : null);
  }

  /// Accept a proposal: create a task from the proposal and update status.
  Future<void> accept(String proposalId) async {
    // Fetch the proposal to get task details
    final proposalRow = await (_db.select(
      _db.linkMemberProposals,
    )..where((t) => t.id.equals(proposalId))).getSingleOrNull();

    if (proposalRow == null) {
      throw StateError('Proposal $proposalId not found');
    }

    final due = proposalRow.taskDueDate;
    final timed = due != null && (due.toLocal().hour != 0 || due.toLocal().minute != 0);
    final categoryRaw = proposalRow.taskCategory.trim();
    final enumCategory = TaskCategory.values
        .where((c) => c.name == categoryRaw)
        .firstOrNull;
    final customCategory =
        enumCategory == null &&
            categoryRaw.isNotEmpty &&
            categoryRaw != 'other'
        ? categoryRaw
        : null;

    final created = await _todoRepository.createTask(
      title: proposalRow.taskTitle,
      notes: proposalRow.taskNotes,
      category: enumCategory ?? TaskCategory.other,
      customCategory: customCategory,
      priority: TaskPriority.values[proposalRow.taskPriority],
      dueDate: due,
      isAllDay: due == null || !timed,
      remindAt: timed ? due : null,
      isPrivate: false,
    );

    // Update proposal status to 'accepted' and bind the created task id.
    await (_db.update(
      _db.linkMemberProposals,
    )..where((t) => t.id.equals(proposalId))).write(
      LinkMemberProposalsCompanion(
        status: const Value('accepted'),
        resultTaskId: Value(created.id),
        syncState: const Value('dirty'),
        updatedAt: Value(DateTime.now().toUtc()),
      ),
    );
  }

  /// Dismiss a proposal (change status to dismissed, no action).
  Future<void> dismiss(String proposalId) async {
    await (_db.update(
      _db.linkMemberProposals,
    )..where((t) => t.id.equals(proposalId))).write(
      LinkMemberProposalsCompanion(
        status: const Value('dismissed'),
        syncState: const Value('dirty'),
        updatedAt: Value(DateTime.now().toUtc()),
      ),
    );
  }

  /// Soft-delete a proposal by marking syncState='deleted'.
  Future<void> delete(String proposalId) async {
    await (_db.update(
      _db.linkMemberProposals,
    )..where((t) => t.id.equals(proposalId))).write(
      LinkMemberProposalsCompanion(
        syncState: const Value('deleted'),
        updatedAt: Value(DateTime.now().toUtc()),
      ),
    );
  }

  /// Reject a proposal and learn from it.
  ///
  /// Sets status to [ProposalStatus.rejected] (syncs back to sender) and
  /// stores exclusion rules derived from the task title so similar tasks are
  /// not proposed again.
  Future<void> reject(String proposalId, String taskTitle) async {
    await (_db.update(
      _db.linkMemberProposals,
    )..where((t) => t.id.equals(proposalId))).write(
      LinkMemberProposalsCompanion(
        status: const Value('rejected'),
        syncState: const Value('dirty'),
        updatedAt: Value(DateTime.now().toUtc()),
      ),
    );
    await _storeExclusionFromTitle(taskTitle);
  }

  /// Watch the count of pending proposals from a family member.
  ///
  /// [myLinkId] excludes own outgoing proposals from the count.
  Stream<int> watchPendingCount({String? myLinkId}) {
    return (_db.select(
      _db.linkMemberProposals,
    )..where((t) => t.status.equals('pending'))).watch().map(
      (rows) => rows
          .map(_proposalFromRow)
          .where((p) => myLinkId == null || p.isAddressedTo(myLinkId))
          .length,
    );
  }

  /// Watch the status of an outgoing proposal for the given [taskId] sent
  /// by [fromLinkId].  Returns null when no matching proposal exists.
  Stream<ProposalStatus?> watchOutgoingProposalStatus({
    required String taskId,
    required String fromLinkId,
  }) {
    return (_db.select(_db.linkMemberProposals)
          ..where(
            (p) =>
                p.fromLinkId.equals(fromLinkId) &
                p.sourceTaskId.equals(taskId) &
                p.syncState.equals('deleted').not(),
          )
          ..orderBy([(p) => OrderingTerm.desc(p.updatedAt)]))
        .watch()
        .map((rows) {
          if (rows.isEmpty) return null;
          return ProposalStatus.values.firstWhere(
            (s) => s.name == rows.first.status,
            orElse: () => ProposalStatus.pending,
          );
        });
  }

  /// Returns accepted proposals (for the AI engine to analyse).
  Stream<List<LinkMemberProposalRow>> watchAccepted() {
    return (_db.select(
      _db.linkMemberProposals,
    )..where((p) => p.status.equals('accepted'))).watch();
  }

  /// Returns true if an outgoing proposal with [title] from [linkId] was
  /// created in the last 30 days (dedup for auto proposals).
  Future<bool> hasRecentOutgoing(String title, String linkId) async {
    final cutoff = DateTime.now().toUtc().subtract(const Duration(days: 30));
    final normalized = _normalizeTitle(title);
    final rows =
        await (_db.select(_db.linkMemberProposals)..where(
              (p) =>
                  p.fromLinkId.equals(linkId) &
                  p.syncState.equals('deleted').not() &
                  p.receivedAt.isBiggerOrEqualValue(cutoff),
            ))
            .get();
    return rows.any((r) => _normalizeTitle(r.taskTitle) == normalized);
  }

  /// Watch the accepted proposal (if any) that created [taskId].
  /// Used for "from {name}" chrome on tiles and the edit sheet.
  Stream<LinkMemberProposal?> watchAcceptedProposalForTask({
    required String taskId,
  }) {
    return (_db.select(_db.linkMemberProposals)..where(
          (p) =>
              p.status.equals('accepted') &
              p.resultTaskId.equals(taskId) &
              p.syncState.equals('deleted').not(),
        ))
        .watch()
        .map((rows) => rows.isEmpty ? null : _proposalFromRow(rows.first));
  }

  /// Soft-delete proposals linked to [taskId] (as source or result).
  Future<void> archiveProposalsForTask(String taskId) async {
    final now = DateTime.now().toUtc();
    await (_db.update(_db.linkMemberProposals)..where(
          (p) =>
              (p.sourceTaskId.equals(taskId) | p.resultTaskId.equals(taskId)) &
              p.syncState.equals('deleted').not(),
        ))
        .write(
          LinkMemberProposalsCompanion(
            syncState: const Value('deleted'),
            updatedAt: Value(now),
          ),
        );
  }

  /// Manually send a task to a family member.
  ///
  /// Creates a proposal (autoGenerated=false) with the task's data so the
  /// family member sees it in their inbox.  The task itself is NOT deleted
  /// here — the caller is responsible for soft-deleting it after calling this.
  Future<void> createManualProposal({
    required String myLinkId,
    required String taskTitle,
    String? sourceTaskId,
    String? taskNotes,
    String taskCategory = 'other',
    required TaskPriority taskPriority,
    DateTime? taskDueDate,
    bool autoGenerated = false,
    String? toMemberId,
  }) async {
    final now = DateTime.now().toUtc();
    final category = taskCategory.trim().isEmpty ? 'other' : taskCategory.trim();
    await _db
        .into(_db.linkMemberProposals)
        .insert(
          LinkMemberProposalsCompanion.insert(
            id: _uuid.v4(),
            fromLinkId: myLinkId,
            toMemberId: Value(toMemberId),
            taskTitle: taskTitle,
            taskNotes: Value(taskNotes),
            taskCategory: Value(category),
            taskPriority: Value(taskPriority.index),
            taskDueDate: Value(taskDueDate),
            status: const Value('pending'),
            autoGenerated: Value(autoGenerated),
            syncState: const Value('dirty'),
            sourceTaskId: Value(sourceTaskId),
            receivedAt: now,
            updatedAt: now,
          ),
        );
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  Future<void> _storeExclusionFromTitle(String taskTitle) async {
    final normalized = taskTitle
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9\s]'), '')
        .trim();
    final words = normalized.split(RegExp(r'\s+'));
    const stopWords = {
      'voor',
      'naar',
      'met',
      'een',
      'het',
      'van',
      'zijn',
      'hebben',
      'worden',
      'maar',
      'ook',
      'niet',
      'door',
      'dan',
      'als',
      'nog',
      'mijn',
      'jouw',
      'ons',
      'hun',
    };
    final meaningful = words
        .where((w) => w.length >= 4 && !stopWords.contains(w))
        .take(2)
        .toList();
    final patterns = meaningful.isNotEmpty ? meaningful : [normalized];
    for (final pattern in patterns) {
      await _db
          .into(_db.exclusionRules)
          .insert(
            ExclusionRulesCompanion.insert(
              id: _uuid.v4(),
              pattern: pattern,
              createdAt: DateTime.now().toUtc(),
            ),
          );
    }
  }

  LinkMemberProposal _proposalFromRow(LinkMemberProposalRow row) {
    return LinkMemberProposal(
      id: row.id,
      fromLinkId: row.fromLinkId,
      toMemberId: row.toMemberId,
      taskTitle: row.taskTitle,
      taskNotes: row.taskNotes,
      taskCategory: row.taskCategory,
      taskPriority: TaskPriority.values[row.taskPriority],
      taskDueDate: row.taskDueDate,
      status: ProposalStatus.values.firstWhere(
        (e) => e.name == row.status,
        orElse: () => ProposalStatus.pending,
      ),
      receivedAt: row.receivedAt,
      updatedAt: row.updatedAt,
      autoGenerated: row.autoGenerated,
      sourceTaskId: row.sourceTaskId,
      resultTaskId: row.resultTaskId,
    );
  }
}
