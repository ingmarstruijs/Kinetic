import 'package:drift/drift.dart';

import '../../db/app_database.dart';
import '../models/kids_task.dart';

/// KidsTaskRepository — CRUD for assigned tasks with streaming.
class KidsTaskRepository {
  final AppDatabase _db;

  KidsTaskRepository({required AppDatabase db}) : _db = db;

  Stream<List<KidsTask>> watchAll() {
    return (_db.select(_db.kidsTasks)
          ..orderBy([(t) => OrderingTerm.asc(t.dueDate)]))
        .watch()
        .map((rows) => rows.map(_taskFromRow).toList());
  }

  Stream<List<KidsTask>> watchPending() {
    return (_db.select(_db.kidsTasks)
          ..where(
            (t) =>
                t.isCompleted.equals(false) &
                t.awaitingVerification.equals(false),
          )
          ..orderBy([(t) => OrderingTerm.asc(t.dueDate)]))
        .watch()
        .map((rows) => rows.map(_taskFromRow).toList());
  }

  Stream<KidsTask?> watchOne(String id) {
    return (_db.select(_db.kidsTasks)..where((t) => t.id.equals(id)))
        .watchSingleOrNull()
        .map((row) => row != null ? _taskFromRow(row) : null);
  }

  /// Kid requests completion — status becomes pending verification (no XP yet).
  Future<void> requestComplete(String taskId) async {
    await (_db.update(_db.kidsTasks)..where((t) => t.id.equals(taskId))).write(
      KidsTasksCompanion(
        isCompleted: const Value(false),
        awaitingVerification: const Value(true),
        completedAt: const Value(null),
        clearedFromHome: const Value(false),
        syncState: const Value('dirty'),
        updatedAt: Value(DateTime.now().toUtc()),
      ),
    );
  }

  /// Apply link-app accept from sync (local is already COMPLETED on wire).
  Future<void> applyAccepted(String taskId, DateTime completedAt) async {
    await (_db.update(_db.kidsTasks)..where((t) => t.id.equals(taskId))).write(
      KidsTasksCompanion(
        isCompleted: const Value(true),
        awaitingVerification: const Value(false),
        completedAt: Value(completedAt),
        clearedFromHome: const Value(false),
        syncState: const Value('clean'),
        updatedAt: Value(completedAt),
      ),
    );
  }

  /// Apply link-app reject / reopen from sync.
  Future<void> applyOpen(String taskId, {required bool dirty}) async {
    await (_db.update(_db.kidsTasks)..where((t) => t.id.equals(taskId))).write(
      KidsTasksCompanion(
        isCompleted: const Value(false),
        awaitingVerification: const Value(false),
        completedAt: const Value(null),
        clearedFromHome: const Value(false),
        syncState: Value(dirty ? 'dirty' : 'clean'),
        updatedAt: Value(DateTime.now().toUtc()),
      ),
    );
  }

  Future<void> delete(String taskId) async {
    await (_db.update(_db.kidsTasks)..where((t) => t.id.equals(taskId))).write(
      KidsTasksCompanion(
        syncState: const Value('deleted'),
        updatedAt: Value(DateTime.now().toUtc()),
      ),
    );
  }

  Future<List<KidsTaskRow>> getAllRows() => _db.select(_db.kidsTasks).get();

  Future<List<KidsTaskRow>> getDirtyRows() {
    return (_db.select(
      _db.kidsTasks,
    )..where((t) => t.syncState.equals('dirty'))).get();
  }

  Future<List<KidsTaskRow>> getDeletedRows() {
    return (_db.select(
      _db.kidsTasks,
    )..where((t) => t.syncState.equals('deleted'))).get();
  }

  Future<void> upsertTask(KidsTask task) async {
    await _db.into(_db.kidsTasks).insert(
          _taskToCompanion(task),
          onConflict: DoUpdate((_) => _taskToCompanion(task)),
        );
  }

  Future<void> markSynced(String taskId, String? etag) async {
    await (_db.update(_db.kidsTasks)..where((t) => t.id.equals(taskId))).write(
      KidsTasksCompanion(
        syncState: const Value('clean'),
        webdavEtag: Value(etag),
      ),
    );
  }

  Future<void> hardDelete(String taskId) async {
    await (_db.delete(_db.kidsTasks)..where((t) => t.id.equals(taskId))).go();
  }

  /// Delete all completed (accepted) tasks locally — used after XP/goal reset.
  Future<void> hardDeleteCompleted() async {
    await (_db.delete(_db.kidsTasks)
          ..where((t) => t.isCompleted.equals(true)))
        .go();
  }

  /// Hide completed tasks from the home list; XP still counts.
  Future<void> clearCompletedFromHome() async {
    await (_db.update(_db.kidsTasks)
          ..where((t) => t.isCompleted.equals(true)))
        .write(const KidsTasksCompanion(clearedFromHome: Value(true)));
  }

  /// Total XP from accepted completions only.
  Stream<int> watchTotalXp({DateTime? resetAt}) {
    return (_db.select(_db.kidsTasks)
          ..where((t) => t.isCompleted.equals(true)))
        .watch()
        .map((rows) {
          final filtered = resetAt == null
              ? rows
              : rows
                  .where(
                    (r) =>
                        r.completedAt != null &&
                        r.completedAt!.isAfter(resetAt),
                  )
                  .toList();
          return filtered.fold(0, (sum, r) => sum + r.xpReward);
        });
  }

  KidsTask _taskFromRow(KidsTaskRow row) {
    return KidsTask(
      id: row.id,
      linkTaskId: row.linkTaskId,
      title: row.title,
      notes: row.notes,
      category: TaskCategory.values.firstWhere(
        (e) => e.name == row.category,
        orElse: () => TaskCategory.other,
      ),
      priority: TaskPriority.values[row.priority],
      dueDate: row.dueDate,
      isCompleted: row.isCompleted,
      awaitingVerification: row.awaitingVerification,
      completedAt: row.completedAt,
      xpReward: row.xpReward,
      clearedFromHome: row.clearedFromHome,
      syncState: row.syncState,
      webdavEtag: row.webdavEtag,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }

  KidsTasksCompanion _taskToCompanion(KidsTask task) {
    return KidsTasksCompanion(
      id: Value(task.id),
      linkTaskId: Value(task.linkTaskId),
      title: Value(task.title),
      notes: Value(task.notes),
      category: Value(task.category.name),
      priority: Value(task.priority.index),
      dueDate: Value(task.dueDate),
      isCompleted: Value(task.isCompleted),
      awaitingVerification: Value(task.awaitingVerification),
      completedAt: Value(task.completedAt),
      xpReward: Value(task.xpReward),
      // Keep cleanup flag for completed rows; reset when the task is open again.
      clearedFromHome:
          task.isCompleted ? const Value.absent() : const Value(false),
      syncState: Value(task.syncState),
      webdavEtag: Value(task.webdavEtag),
      createdAt: Value(task.createdAt),
      updatedAt: Value(task.updatedAt),
    );
  }
}
