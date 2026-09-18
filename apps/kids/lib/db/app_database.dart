import 'package:drift/drift.dart';

import 'encrypted_open.dart';
import 'tables.dart';

part 'app_database.drift.dart';

/// AppDatabase — Drift database for kids app
///
/// Stores assigned tasks synced from the Kinetic Link app via WebDAV.
/// Uses same encryption and sync strategy as the link app.
@DriftDatabase(tables: [KidsTasks])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  /// Internal constructor for testing with custom executor
  AppDatabase.withExecutor(super.executor);

  @override
  int get schemaVersion => 4;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) => m.createAll(),
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            await m.addColumn(kidsTasks, kidsTasks.awaitingVerification);
          }
          if (from < 3) {
            await m.addColumn(kidsTasks, kidsTasks.clearedFromHome);
          }
          if (from < 4) {
            // Parent wording dropped in favour of the originating link task.
            await m.renameColumn(
              kidsTasks,
              'parent_id',
              kidsTasks.linkTaskId,
            );
          }
        },
      );

  static QueryExecutor _openConnection() {
    return openEncryptedDatabase(name: 'kids_app');
  }

  /// Get all tasks
  Future<List<KidsTaskRow>> getAllTasks() {
    return select(kidsTasks).get();
  }

  /// Get a single task by ID
  Future<KidsTaskRow?> getTask(String id) {
    return (select(kidsTasks)..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  /// Insert or replace a task
  Future<void> upsertTask(Insertable<KidsTaskRow> task) {
    return into(kidsTasks).insert(task, onConflict: DoUpdate((old) => task));
  }

  /// Soft-delete a task
  Future<void> deleteTask(String id) {
    return (update(kidsTasks)..where((t) => t.id.equals(id))).write(
      KidsTasksCompanion(
        syncState: const Value('deleted'),
        updatedAt: Value(DateTime.now().toUtc()),
      ),
    );
  }
}
