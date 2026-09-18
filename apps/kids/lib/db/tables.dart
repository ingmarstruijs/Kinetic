import 'package:drift/drift.dart';

/// KidsTasks — assigned tasks from link app
///
/// Kids can see, mark complete, and track progress on tasks assigned from the link app.
/// All tasks are synced via WebDAV with the family key.
@DataClassName('KidsTaskRow')
class KidsTasks extends Table {
  /// Unique task ID (UUID) — matches the Kinetic Link task id
  TextColumn get id => text()();

  /// Link task this mission was created from
  TextColumn get linkTaskId => text()();

  /// Task content
  TextColumn get title => text()();
  TextColumn get notes => text().nullable()();

  /// Task classification
  TextColumn get category => text().withDefault(const Constant('other'))();
  IntColumn get priority => integer().withDefault(const Constant(0))();

  /// Scheduling
  DateTimeColumn get dueDate => dateTime().nullable()();

  /// Completion tracking — [isCompleted] is true only after link-app acceptance.
  BoolColumn get isCompleted => boolean().withDefault(const Constant(false))();
  DateTimeColumn get completedAt => dateTime().nullable()();

  /// True while waiting for the link app to accept/reject a completion request.
  BoolColumn get awaitingVerification =>
      boolean().withDefault(const Constant(false))();

  /// XP reward for completion (counts only after link-app acceptance)
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
