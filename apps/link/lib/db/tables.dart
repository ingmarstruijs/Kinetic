// Drift table definitions for the link app local database.
// Run `dart run build_runner build` to regenerate `app_database.g.dart`.

import 'package:drift/drift.dart';

// ---------------------------------------------------------------------------
// PersonalLists — user-created groups (like Reminders lists)
// ---------------------------------------------------------------------------

@DataClassName('PersonalListRow')
class PersonalLists extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  IntColumn get colorValue =>
      integer().withDefault(const Constant(0xFF44BBA4))();
  IntColumn get iconCodePoint =>
      integer().withDefault(const Constant(0xe156))(); // Icons.list
  BoolColumn get isPrivateDefault =>
      boolean().withDefault(const Constant(false))();
  IntColumn get position => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

// ---------------------------------------------------------------------------
// PersonalTasks — Link member's own todo items
// ---------------------------------------------------------------------------

@DataClassName('PersonalTaskRow')
class PersonalTasks extends Table {
  TextColumn get id => text()();

  // null = inbox (not in any list)
  TextColumn get listId => text().nullable().references(PersonalLists, #id)();

  TextColumn get title => text()();
  TextColumn get notes => text().nullable()();

  // 0 = none, 1 = low (!), 2 = medium (!!), 3 = high (!!!)
  IntColumn get priority => integer().withDefault(const Constant(0))();

  // Stored as UTC milliseconds since epoch; null = no due date
  DateTimeColumn get dueDate => dateTime().nullable()();
  BoolColumn get isAllDay => boolean().withDefault(const Constant(true))();

  // iCalendar RRULE string e.g. "FREQ=DAILY" — null = no recurrence
  TextColumn get recurrenceRule => text().nullable()();

  BoolColumn get isCompleted => boolean().withDefault(const Constant(false))();
  DateTimeColumn get completedAt => dateTime().nullable()();

  BoolColumn get isFlagged => boolean().withDefault(const Constant(false))();

  // true = never propose this task to a family member
  BoolColumn get isPrivate => boolean().withDefault(const Constant(false))();

  // Set when this task was delegated to a child (kids task id)
  TextColumn get kidsTaskId => text().nullable()();

  // ID of the specific enrolled kid this task was targeted at; null = all kids
  TextColumn get targetKidId => text().nullable()();

  /// Link member who must verify kids completion; null = any participating link member.
  TextColumn get verifierLinkId => text().nullable()();

  // XP reward when this task is sent to kids; default 10
  IntColumn get xpReward => integer().withDefault(const Constant(10))();

  // Auto-detected: household / health / admin / school / finance / other
  TextColumn get category => text().withDefault(const Constant('other'))();

  // User-defined category label; null = uncategorized
  TextColumn get customCategory => text().nullable()();

  /// When to fire a local reminder notification; null = no reminder.
  DateTimeColumn get remindAt => dateTime().nullable()();

  IntColumn get sortOrder => integer().withDefault(const Constant(0))();

  // WebDAV sync metadata
  /// ETag returned by the server after the last successful PUT/GET.
  /// Null = never synced.
  TextColumn get webdavEtag => text().nullable()();

  /// 'clean' | 'dirty' | 'deleted'. 'dirty' = local change not yet pushed.
  TextColumn get syncState => text().withDefault(const Constant('dirty'))();

  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

// ---------------------------------------------------------------------------
// PersonalNotes — this Link device's notes (plaintext / markdown)
// ---------------------------------------------------------------------------

@DataClassName('PersonalNoteRow')
class PersonalNotes extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get body => text().withDefault(const Constant(''))();

  /// true = encrypted with family key and stored in shared WebDAV folder.
  BoolColumn get isShared => boolean().withDefault(const Constant(false))();

  /// JSON list of link member ids; null/empty with [isShared] = all link members.
  TextColumn get sharedMemberIds => text().nullable()();

  DateTimeColumn get remindAt => dateTime().nullable()();

  // User-defined category label; null = uncategorized
  TextColumn get category => text().nullable()();

  // Manual sort order within category; 0 = unsorted (falls back to createdAt)
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();

  /// When true, body is hidden in the notes list and opening requires
  /// device biometrics / PIN (local privacy flag, not synced).
  BoolColumn get isContentHidden =>
      boolean().withDefault(const Constant(false))();

  // WebDAV sync metadata
  TextColumn get webdavEtag => text().nullable()();
  TextColumn get syncState => text().withDefault(const Constant('dirty'))();

  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  /// Link member id of the last editor (synced for shared notes).
  TextColumn get updatedByLinkId => text().nullable()();

  /// Set when the note is moved to trash; null = active.
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

// ---------------------------------------------------------------------------
// PersonalSubtasks — checklist items inside a PersonalTask
// ---------------------------------------------------------------------------

@DataClassName('PersonalSubtaskRow')
class PersonalSubtasks extends Table {
  TextColumn get id => text()();
  TextColumn get taskId => text().references(PersonalTasks, #id)();
  TextColumn get title => text()();
  BoolColumn get isCompleted => boolean().withDefault(const Constant(false))();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}

// ---------------------------------------------------------------------------
// LinkMemberProposals — tasks proposed by the other link member (C3 inbox)
// ---------------------------------------------------------------------------

@DataClassName('LinkMemberProposalRow')
class LinkMemberProposals extends Table {
  TextColumn get id => text()();

  // Originating link member ID
  TextColumn get fromLinkId => text()();

  /// Target link member id; null = any / all other link members (legacy).
  TextColumn get toMemberId => text().nullable()();

  // The synced task content
  TextColumn get taskTitle => text()();
  TextColumn get taskNotes => text().nullable()();
  TextColumn get taskCategory => text().withDefault(const Constant('other'))();
  IntColumn get taskPriority => integer().withDefault(const Constant(0))();
  DateTimeColumn get taskDueDate => dateTime().nullable()();

  // pending / accepted / snoozed / dismissed / rejected
  TextColumn get status => text().withDefault(const Constant('pending'))();

  // true = created by the local auto-proposal engine (not manually sent)
  BoolColumn get autoGenerated =>
      boolean().withDefault(const Constant(false))();

  // Sync state: clean (synced), dirty (modified locally), deleted (soft-delete)
  TextColumn get syncState => text().withDefault(const Constant('clean'))();

  /// Sender's personal task id when this proposal was created (link→link send).
  TextColumn get sourceTaskId => text().nullable()();

  /// Receiver's personal task id created when this proposal was accepted.
  TextColumn get resultTaskId => text().nullable()();

  DateTimeColumn get receivedAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

// ---------------------------------------------------------------------------
// ExclusionRules — learned patterns from rejected auto-proposals
// ---------------------------------------------------------------------------

@DataClassName('ExclusionRuleRow')
class ExclusionRules extends Table {
  TextColumn get id => text()();

  // Normalized (lowercase, alphanumeric) keyword extracted from a rejected title
  TextColumn get pattern => text()();

  // Score penalty applied when this pattern matches a candidate task title
  IntColumn get penaltyScore => integer().withDefault(const Constant(40))();

  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

// ---------------------------------------------------------------------------
// AiSuggestions — locally generated task suggestions (never synced)
// ---------------------------------------------------------------------------

@DataClassName('AiSuggestionRow')
class AiSuggestions extends Table {
  TextColumn get id => text()();

  TextColumn get title => text()();
  TextColumn get notes => text().nullable()();

  // 0=none 1=low 2=medium 3=high
  IntColumn get priority => integer().withDefault(const Constant(0))();

  TextColumn get category => text().withDefault(const Constant('other'))();

  DateTimeColumn get suggestedDueDate => dateTime().nullable()();

  // habit | familyMemberComplement | seasonal | loadBalance
  TextColumn get reason => text()();

  // pending | accepted | dismissed | snoozed
  TextColumn get status => text().withDefault(const Constant('pending'))();

  DateTimeColumn get snoozeUntil => dateTime().nullable()();

  /// Human-readable explanation of why this suggestion was generated.
  TextColumn get explanation => text().nullable()();

  /// Stable identity used to suppress a dismissed suggestion forever.
  /// Example: `calendar:school-supplies`, `stale:<taskId>`.
  TextColumn get dedupeKey => text().withDefault(const Constant(''))();

  /// Comma-separated personal-task ids this suggestion applies to
  /// (stale reminder, categorize).
  TextColumn get relatedTaskIds => text().nullable()();

  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('AppSettingsRow')
class AppSettings extends Table {
  // Always use 'default' as the single key
  TextColumn get key =>
      text().withDefault(const Constant('default')).unique()();

  // Theme preference: 'light' | 'calm' | 'night'
  // Legacy ids 'sand', 'dusk', and 'dark' are mapped in appThemeFromName.
  TextColumn get theme => text().withDefault(const Constant('dark'))();

  // UI language: 'en' | 'nl'
  TextColumn get localeCode => text().withDefault(const Constant('en'))();

  // JSON-encoded ordered list of task category labels (nullable = no saved order)
  TextColumn get taskCategoryOrder => text().nullable()();

  // JSON-encoded ordered list of note category labels (nullable = no saved order)
  TextColumn get noteCategoryOrder => text().nullable()();

  // Throttle timestamps for the AI suggestion engine
  DateTimeColumn get lastSuggestionRunAt => dateTime().nullable()();
  DateTimeColumn get lastFamilyMemberSuggestionRunAt => dateTime().nullable()();

  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {key};
}
