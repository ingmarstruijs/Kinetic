import 'package:drift/drift.dart';

/// KidsTasks — assigned tasks from adult app
///
/// Kids can see, mark complete, and track progress on tasks assigned by parents.
/// All tasks are synced via WebDAV with the family key.
@DataClassName('KidsTaskRow')
class KidsTasks extends Table {
  /// Unique task ID (UUID) — matches parent's task ID
  TextColumn get id => text()();

  /// Parent who assigned this task
  TextColumn get parentId => text()();

  /// Task content
  TextColumn get title => text()();
  TextColumn get notes => text().nullable()();

  /// Task classification
  TextColumn get category => text().withDefault(const Constant('other'))();
  IntColumn get priority => integer().withDefault(const Constant(0))();

  /// Scheduling
  DateTimeColumn get dueDate => dateTime().nullable()();

  /// Completion tracking — [isCompleted] is true only after parent acceptance.
  BoolColumn get isCompleted => boolean().withDefault(const Constant(false))();
  DateTimeColumn get completedAt => dateTime().nullable()();

  /// True while waiting for the parent to accept/reject a completion request.
  BoolColumn get awaitingVerification =>
      boolean().withDefault(const Constant(false))();

  /// XP reward for completion (counts only after parent acceptance)
  IntColumn get xpReward => integer().withDefault(const Constant(10))();

  /// Local-only: kid hid this completed task from the home list (XP still counts).
  BoolColumn get clearedFromHome =>
      boolean().withDefault(const Constant(false))();

  /// Sync state: 'clean' (synced), 'dirty' (modified locally), 'deleted' (soft-delete)
  TextColumn get syncState => text().withDefault(const Constant('clean'))();

  /// WebDAV ETag for conflict detection
  TextColumn get webdavEtag => text().nullable()();

  /// Timestamps
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
