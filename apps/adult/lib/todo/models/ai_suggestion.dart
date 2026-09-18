import 'package:uuid/uuid.dart';

import '../../l10n/generated/app_localizations.dart';

/// Reason a suggestion was generated.
enum SuggestionReason {
  habit,
  partnerComplement,
  seasonal,
  loadBalance,
  stale,
  calendar,
  categorize,
}

List<String> parseRelatedTaskIds(String? raw) {
  if (raw == null || raw.isEmpty) return const [];
  return raw
      .split(',')
      .map((s) => s.trim())
      .where((s) => s.isNotEmpty)
      .toList();
}

String joinRelatedTaskIds(Iterable<String> ids) =>
    ids.where((id) => id.isNotEmpty).join(',');

extension SuggestionReasonLabel on SuggestionReason {
  String label(AppLocalizations l10n) => switch (this) {
    SuggestionReason.habit => l10n.suggestReasonHabit,
    SuggestionReason.partnerComplement => l10n.suggestReasonPartner,
    SuggestionReason.seasonal => l10n.suggestReasonSeasonal,
    SuggestionReason.loadBalance => l10n.suggestReasonLoadBalance,
    SuggestionReason.stale => l10n.suggestReasonStale,
    SuggestionReason.calendar => l10n.suggestReasonCalendar,
    SuggestionReason.categorize => l10n.suggestReasonCategorize,
  };

  bool get isSelfTargeted =>
      this == SuggestionReason.habit ||
      this == SuggestionReason.seasonal ||
      this == SuggestionReason.stale ||
      this == SuggestionReason.calendar ||
      this == SuggestionReason.categorize;

  bool get isPartnerTargeted =>
      this == SuggestionReason.partnerComplement ||
      this == SuggestionReason.loadBalance;
}

/// Lifecycle state of a suggestion.
enum SuggestionStatus { pending, accepted, dismissed, snoozed }

class AiSuggestion {
  final String id;
  final String title;
  final String? notes;
  final int priority;
  final String category;
  final DateTime? suggestedDueDate;
  final SuggestionReason reason;
  final SuggestionStatus status;
  final DateTime? snoozeUntil;
  final String? explanation;
  final String dedupeKey;
  final List<String> relatedTaskIds;
  final DateTime createdAt;
  final DateTime updatedAt;

  const AiSuggestion({
    required this.id,
    required this.title,
    this.notes,
    required this.priority,
    required this.category,
    this.suggestedDueDate,
    required this.reason,
    required this.status,
    this.snoozeUntil,
    this.explanation,
    this.dedupeKey = '',
    this.relatedTaskIds = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isPartnerTargeted => reason.isPartnerTargeted;

  static AiSuggestion create({
    required String title,
    String? notes,
    int priority = 0,
    String category = 'other',
    DateTime? suggestedDueDate,
    required SuggestionReason reason,
    String? explanation,
    String dedupeKey = '',
    List<String> relatedTaskIds = const [],
  }) {
    final now = DateTime.now().toUtc();
    return AiSuggestion(
      id: const Uuid().v4(),
      title: title,
      notes: notes,
      priority: priority,
      category: category,
      suggestedDueDate: suggestedDueDate,
      reason: reason,
      status: SuggestionStatus.pending,
      explanation: explanation,
      dedupeKey: dedupeKey,
      relatedTaskIds: relatedTaskIds,
      createdAt: now,
      updatedAt: now,
    );
  }

  AiSuggestion copyWith({
    SuggestionStatus? status,
    DateTime? snoozeUntil,
    DateTime? updatedAt,
  }) {
    return AiSuggestion(
      id: id,
      title: title,
      notes: notes,
      priority: priority,
      category: category,
      suggestedDueDate: suggestedDueDate,
      reason: reason,
      status: status ?? this.status,
      snoozeUntil: snoozeUntil ?? this.snoozeUntil,
      explanation: explanation,
      dedupeKey: dedupeKey,
      relatedTaskIds: relatedTaskIds,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
