import 'package:drift/drift.dart';

import '../../db/app_database.dart';
import '../models/ai_suggestion.dart';

class AiSuggestionRepository {
  final AppDatabase _db;

  AiSuggestionRepository(this._db);

  // ---------------------------------------------------------------------------
  // Mapping helpers
  // ---------------------------------------------------------------------------

  AiSuggestion _rowToModel(AiSuggestionRow row) {
    return AiSuggestion(
      id: row.id,
      title: row.title,
      notes: row.notes,
      priority: row.priority,
      category: row.category,
      suggestedDueDate: row.suggestedDueDate,
      reason: SuggestionReason.values.firstWhere(
        (e) => e.name == row.reason,
        orElse: () => SuggestionReason.habit,
      ),
      status: SuggestionStatus.values.firstWhere(
        (e) => e.name == row.status,
        orElse: () => SuggestionStatus.pending,
      ),
      snoozeUntil: row.snoozeUntil,
      explanation: row.explanation,
      dedupeKey: row.dedupeKey,
      relatedTaskIds: parseRelatedTaskIds(row.relatedTaskIds),
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }

  AiSuggestionsCompanion _modelToCompanion(AiSuggestion s) {
    return AiSuggestionsCompanion.insert(
      id: s.id,
      title: s.title,
      notes: Value(s.notes),
      priority: Value(s.priority),
      category: Value(s.category),
      suggestedDueDate: Value(s.suggestedDueDate),
      reason: s.reason.name,
      status: Value(s.status.name),
      snoozeUntil: Value(s.snoozeUntil),
      explanation: Value(s.explanation),
      dedupeKey: Value(s.dedupeKey),
      relatedTaskIds: Value(
        s.relatedTaskIds.isEmpty ? null : joinRelatedTaskIds(s.relatedTaskIds),
      ),
      createdAt: s.createdAt,
      updatedAt: s.updatedAt,
    );
  }

  // ---------------------------------------------------------------------------
  // Queries
  // ---------------------------------------------------------------------------

  /// Watch suggestions that are pending and not snoozed (or snooze expired).
  Stream<List<AiSuggestion>> watchPending() {
    final now = DateTime.now().toUtc();
    return (_db.select(_db.aiSuggestions)
          ..where(
            (t) =>
                t.status.equals('pending') &
                (t.snoozeUntil.isNull() |
                    t.snoozeUntil.isSmallerThanValue(now)),
          )
          ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
        .watch()
        .map((rows) => rows.map(_rowToModel).toList());
  }

  /// Pending suggestions targeted at the user (habit / seasonal).
  Stream<List<AiSuggestion>> watchPendingSelf() {
    return watchPending().map(
      (all) => all.where((s) => s.reason.isSelfTargeted).toList(),
    );
  }

  /// Pending suggestions the user may forward to their partner.
  Stream<List<AiSuggestion>> watchPendingPartner() {
    return watchPending().map(
      (all) => all.where((s) => s.reason.isPartnerTargeted).toList(),
    );
  }

  /// Returns how many pending non-snoozed suggestions exist right now.
  Future<int> countPending() async {
    final now = DateTime.now().toUtc();
    final rows =
        await (_db.select(_db.aiSuggestions)..where(
              (t) =>
                  t.status.equals('pending') &
                  (t.snoozeUntil.isNull() |
                      t.snoozeUntil.isSmallerThanValue(now)),
            ))
            .get();
    return rows.length;
  }

  /// Watch pending suggestion count (drives the Voorstellen tab badge).
  Stream<int> watchPendingCount() => watchPending().map((list) => list.length);

  Future<int> countPendingSelf() async {
    final all = await watchPendingSelf().first;
    return all.length;
  }

  Future<int> countPendingPartner() async {
    final all = await watchPendingPartner().first;
    return all.length;
  }

  /// True if a pending/snoozed suggestion with [title] already exists.
  Future<bool> hasPendingWithTitle(String title) async {
    final normalized = title.trim().toLowerCase();
    final rows =
        await (_db.select(_db.aiSuggestions)..where(
              (t) => t.status.equals('pending') | t.status.equals('snoozed'),
            ))
            .get();
    return rows.any((r) => r.title.trim().toLowerCase() == normalized);
  }

  /// True if a pending/snoozed suggestion with [dedupeKey] already exists.
  Future<bool> hasPendingWithDedupeKey(String dedupeKey) async {
    if (dedupeKey.isEmpty) return false;
    final rows =
        await (_db.select(_db.aiSuggestions)..where(
              (t) =>
                  t.dedupeKey.equals(dedupeKey) &
                  (t.status.equals('pending') | t.status.equals('snoozed')),
            ))
            .get();
    return rows.isNotEmpty;
  }

  /// Dismissed suggestions are never re-proposed (same key, or legacy
  /// title+reason when the key was empty).
  Future<bool> isSuppressed(AiSuggestion suggestion) async {
    final rows = await (_db.select(
      _db.aiSuggestions,
    )..where((t) => t.status.equals('dismissed'))).get();
    final titleNorm = suggestion.title.trim().toLowerCase();
    for (final row in rows) {
      if (suggestion.dedupeKey.isNotEmpty &&
          row.dedupeKey == suggestion.dedupeKey) {
        return true;
      }
      if (suggestion.reason == SuggestionReason.categorize) continue;
      if (row.reason == suggestion.reason.name &&
          row.title.trim().toLowerCase() == titleNorm) {
        return true;
      }
    }
    return false;
  }

  /// Task ids the user already declined for [reason] (categorize / stale).
  Future<Set<String>> dismissedRelatedTaskIds(SuggestionReason reason) async {
    final rows =
        await (_db.select(_db.aiSuggestions)..where(
              (t) =>
                  t.status.equals('dismissed') & t.reason.equals(reason.name),
            ))
            .get();
    return {for (final row in rows) ...parseRelatedTaskIds(row.relatedTaskIds)};
  }

  /// True if any suggestion with [title] was created within [within].
  Future<bool> hasRecentWithTitle(
    String title, {
    Duration within = const Duration(days: 14),
  }) async {
    final normalized = title.trim().toLowerCase();
    final cutoff = DateTime.now().toUtc().subtract(within);
    final rows = await (_db.select(
      _db.aiSuggestions,
    )..where((t) => t.createdAt.isBiggerOrEqualValue(cutoff))).get();
    return rows.any((r) => r.title.trim().toLowerCase() == normalized);
  }

  // ---------------------------------------------------------------------------
  // Mutations
  // ---------------------------------------------------------------------------

  /// Insert or ignore. Never recreates a dismissed suggestion.
  Future<void> upsertSuggestion(AiSuggestion suggestion) async {
    if (await isSuppressed(suggestion)) return;
    if (suggestion.dedupeKey.isNotEmpty &&
        await hasPendingWithDedupeKey(suggestion.dedupeKey)) {
      return;
    }
    if (await hasPendingWithTitle(suggestion.title)) return;
    await _db
        .into(_db.aiSuggestions)
        .insert(_modelToCompanion(suggestion), mode: InsertMode.insertOrIgnore);
  }

  Future<void> accept(String id) =>
      (_db.update(_db.aiSuggestions)..where((t) => t.id.equals(id))).write(
        AiSuggestionsCompanion(
          status: const Value('accepted'),
          updatedAt: Value(DateTime.now().toUtc()),
        ),
      );

  Future<void> dismiss(String id) =>
      (_db.update(_db.aiSuggestions)..where((t) => t.id.equals(id))).write(
        AiSuggestionsCompanion(
          status: const Value('dismissed'),
          updatedAt: Value(DateTime.now().toUtc()),
        ),
      );

  Future<void> snooze(String id) =>
      (_db.update(_db.aiSuggestions)..where((t) => t.id.equals(id))).write(
        AiSuggestionsCompanion(
          status: const Value('snoozed'),
          snoozeUntil: Value(
            DateTime.now().toUtc().add(const Duration(days: 7)),
          ),
          updatedAt: Value(DateTime.now().toUtc()),
        ),
      );
}
