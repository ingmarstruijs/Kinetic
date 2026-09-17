import 'package:drift/drift.dart';

import '../../db/app_database.dart';
import '../../notifications/notification_service.dart';
import '../../notifications/reminder_action.dart';
import '../models/personal_note.dart';

/// NoteRepository — CRUD for personal notes with reminder scheduling.
class NoteRepository {
  final AppDatabase _db;
  final NotificationService? _notifications;
  final void Function()? onWrite;

  NoteRepository({
    required AppDatabase db,
    NotificationService? notifications,
    this.onWrite,
  }) : _db = db,
       _notifications = notifications;

  /// All notes, private first then shared, by sortOrder then newest.
  /// Excludes trashed notes and sync tombstones.
  Stream<List<PersonalNote>> watchAll() {
    return (_db.select(_db.personalNotes)
          ..where(
            (t) => t.deletedAt.isNull() & t.syncState.equals('deleted').not(),
          )
          ..orderBy([
            (t) => OrderingTerm.asc(t.isShared),
            (t) => OrderingTerm.asc(t.sortOrder),
            (t) => OrderingTerm.desc(t.createdAt),
          ]))
        .watch()
        .map((rows) => rows.map(_noteFromRow).toList());
  }

  /// Notes in the trash, newest first.
  Stream<List<PersonalNote>> watchDeleted() {
    return (_db.select(_db.personalNotes)
          ..where(
            (t) =>
                t.deletedAt.isNotNull() & t.syncState.equals('deleted').not(),
          )
          ..orderBy([(t) => OrderingTerm.desc(t.deletedAt)]))
        .watch()
        .map((rows) => rows.map(_noteFromRow).toList());
  }

  /// Stream a single note by id.
  Stream<PersonalNote?> watchOne(String id) {
    return (_db.select(_db.personalNotes)..where((t) => t.id.equals(id)))
        .watchSingleOrNull()
        .map((row) => row != null ? _noteFromRow(row) : null);
  }

  /// Create a new note.
  Future<PersonalNote> insert({
    required String title,
    String body = '',
    bool isShared = false,
    bool isContentHidden = false,
    DateTime? remindAt,
    String? category,
    int sortOrder = 0,
  }) async {
    try {
      final note = PersonalNote.create(
        title: title,
        body: body,
        isShared: isShared,
        isContentHidden: isContentHidden,
        remindAt: remindAt,
        category: category,
        sortOrder: sortOrder,
      );
      await _db.into(_db.personalNotes).insert(_noteToCompanion(note));
      await _scheduleReminderFor(note);
      onWrite?.call();
      return note;
    } catch (e) {
      rethrow;
    }
  }

  /// Update an existing note.
  Future<void> update(PersonalNote note) async {
    try {
      await (_db.update(
        _db.personalNotes,
      )..where((t) => t.id.equals(note.id))).write(_noteToCompanion(note));
      // Cancel old reminder, schedule new one.
      await _notifications?.cancelReminder(_notifId(note.id));
      await _scheduleReminderFor(note);
      onWrite?.call();
    } catch (e) {
      rethrow;
    }
  }

  /// Move a note to the trash. Restore with [restore]; empty with
  /// [emptyTrash].
  Future<void> delete(String id) async {
    try {
      await _notifications?.cancelReminder(_notifId(id));
      await (_db.update(
        _db.personalNotes,
      )..where((t) => t.id.equals(id))).write(
        PersonalNotesCompanion(
          deletedAt: Value(DateTime.now().toUtc()),
          updatedAt: Value(DateTime.now().toUtc()),
        ),
      );
      onWrite?.call();
    } catch (e) {
      rethrow;
    }
  }

  /// Restore a trashed note to the active list.
  Future<void> restore(String id) async {
    await (_db.update(_db.personalNotes)..where((t) => t.id.equals(id))).write(
      PersonalNotesCompanion(
        deletedAt: const Value(null),
        updatedAt: Value(DateTime.now().toUtc()),
      ),
    );
    final note = await getNote(id);
    if (note != null) await _scheduleReminderFor(note);
    onWrite?.call();
  }

  /// Permanently remove all trashed notes (WebDAV tombstones).
  Future<void> emptyTrash() async {
    await (_db.update(
      _db.personalNotes,
    )..where((t) => t.deletedAt.isNotNull())).write(
      PersonalNotesCompanion(
        syncState: const Value('deleted'),
        updatedAt: Value(DateTime.now().toUtc()),
      ),
    );
    onWrite?.call();
  }

  Future<PersonalNote?> getNote(String id) async {
    final row = await (_db.select(
      _db.personalNotes,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
    return row == null ? null : _noteFromRow(row);
  }

  Future<void> snoozeReminder(String noteId, DateTime until) async {
    final note = await getNote(noteId);
    if (note == null) return;
    await update(note.copyWith(remindAt: until.toUtc()));
  }

  Future<void> clearReminder(String noteId) async {
    final note = await getNote(noteId);
    if (note == null) return;
    await update(note.copyWith(clearRemindAt: true));
  }

  // ── Helpers ────────────────────────────────────────────────────────────────
  Future<void> updateNoteCategory(String noteId, String? category) async {
    await (_db.update(
      _db.personalNotes,
    )..where((t) => t.id.equals(noteId))).write(
      PersonalNotesCompanion(
        category: Value(category),
        updatedAt: Value(DateTime.now().toUtc()),
      ),
    );
    onWrite?.call();
  }

  /// Batch-update category and sortOrder for notes after drag-and-drop reordering.
  Future<void> batchUpdateCategoryAndOrder(
    List<({String id, String? category, int sortOrder})> updates,
  ) async {
    await _db.transaction(() async {
      for (final u in updates) {
        await (_db.update(
          _db.personalNotes,
        )..where((t) => t.id.equals(u.id))).write(
          PersonalNotesCompanion(
            category: Value(u.category),
            sortOrder: Value(u.sortOrder),
            updatedAt: Value(DateTime.now().toUtc()),
          ),
        );
      }
    });
    onWrite?.call();
  }

  /// Stream of distinct, sorted category names from all notes.
  Stream<List<String>> watchNoteCategories() {
    return watchAll().map(
      (notes) =>
          notes.map((n) => n.category).whereType<String>().toSet().toList()
            ..sort(),
    );
  }

  PersonalNote _noteFromRow(PersonalNoteRow row) {
    return PersonalNote.fromRow(row);
  }

  PersonalNotesCompanion _noteToCompanion(PersonalNote note) {
    return PersonalNotesCompanion(
      id: Value(note.id),
      title: Value(note.title),
      body: Value(note.body),
      isShared: Value(note.isShared),
      isContentHidden: Value(note.isContentHidden),
      remindAt: Value(note.remindAt),
      category: Value(note.category),
      sortOrder: Value(note.sortOrder),
      createdAt: Value(note.createdAt),
      updatedAt: Value(note.updatedAt),
      deletedAt: Value(note.deletedAt),
      syncState: const Value('dirty'),
      webdavEtag: const Value(null),
    );
  }

  Future<void> _scheduleReminderFor(PersonalNote note) async {
    if (note.remindAt == null) return;
    if (note.remindAt!.isBefore(DateTime.now())) return;
    try {
      final body = note.isContentHidden
          ? ''
          : (note.body.length > 100
                ? '${note.body.substring(0, 100)}…'
                : note.body);
      await _notifications?.scheduleReminder(
        id: _notifId(note.id),
        title: note.title,
        body: body,
        at: note.remindAt!,
        payload: ReminderPayload.note(note.id).encode(),
      );
    } catch (_) {
      // Best-effort: notification scheduling errors should not fail note operations.
    }
  }

  /// Re-schedule notifications for all notes that have a future reminder.
  /// Call after restoring a backup on a new install.
  Future<void> rescheduleAllReminders() async {
    final rows = await _db.select(_db.personalNotes).get();
    for (final row in rows) {
      if (row.deletedAt != null || row.syncState == 'deleted') continue;
      final note = _noteFromRow(row);
      await _scheduleReminderFor(note);
    }
  }

  int _notifId(String noteId) => noteId.hashCode.abs();
}
