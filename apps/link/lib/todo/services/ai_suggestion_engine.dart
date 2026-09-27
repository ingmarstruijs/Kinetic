import 'package:drift/drift.dart';
import 'package:flutter/widgets.dart';
import 'package:kinetic_webdav/kinetic_webdav.dart';

import '../../db/app_database.dart';
import '../../debug/heuristic_log.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../family/proposals/link_member_proposal_repository.dart';
import '../../todo/models/enums.dart';
import '../../todo/models/personal_task.dart';
import '../../todo/services/todo_repository.dart';
import '../models/ai_suggestion.dart';
import '../reminder_time.dart';
import 'ai_suggestion_repository.dart';
import 'reminder_proposal_engine.dart';
import 'suggestion_actions.dart';
import 'suggestion_heuristics.dart';

void _heuristicLog(String message) => HeuristicLog.instance.add(message);

class _RankedCandidate {
  final AiSuggestion suggestion;
  final int score;
  final String label;

  const _RankedCandidate({
    required this.suggestion,
    required this.score,
    required this.label,
  });
}

/// Heuristic-based suggestion engine.
///
/// Call [runIfDue] on app resume and on first init. A run that creates at
/// least one suggestion is throttled for 24 hours; an empty run is not, so
/// new tasks can surface hints on the next open. Categorize always runs
/// (even during throttle) because it tracks the current open list.
///
/// Detectors collect scored candidates; the engine ranks them, applies
/// accept/dismiss feedback, and commits the top results under the pending cap.
class AiSuggestionEngine {
  final AppDatabase _db;
  final AiSuggestionRepository _suggestionRepo;
  final TodoRepository _todoRepo;
  final LinkMemberProposalRepository? _proposalRepo;
  final Future<List<LoadMetrics>> Function()? _pullLoadMetrics;
  final String? myLinkId;
  final DateTime Function() _now;

  static const _maxPendingSelf = 3;
  static const _maxPendingFamilyMember = 3;
  static const _staleAfterDays = 7;
  static const _singleHabitSilenceDays = 14;
  static const _privacyBudget = Duration(days: 14);
  static const _uncategorizedThreshold = 3;

  final _reminderEngine = ReminderProposalEngine();

  AiSuggestionEngine({
    required AppDatabase db,
    required AiSuggestionRepository suggestionRepo,
    required TodoRepository todoRepo,
    LinkMemberProposalRepository? proposalRepo,
    Future<List<LoadMetrics>> Function()? pullLoadMetrics,
    this.myLinkId,
    DateTime Function()? now,
  }) : _db = db,
       _suggestionRepo = suggestionRepo,
       _todoRepo = todoRepo,
       _proposalRepo = proposalRepo,
       _pullLoadMetrics = pullLoadMetrics,
       _now = now ?? DateTime.now;

  DateTime get _nowUtc => _now().toUtc();

  /// Runs detectors when due. Pass [force] to ignore the 24h throttle (debug).
  /// Forced runs do not update last-run timestamps.
  Future<void> runIfDue({bool force = false}) async {
    final settings = await _loadSettings();
    final now = _nowUtc;

    final selfDue = force || _isDue(settings?.lastSuggestionRunAt, now);
    final partnerDue =
        force || _isDue(settings?.lastFamilyMemberSuggestionRunAt, now);

    final l10n = lookupAppLocalizations(
      Locale(settings?.localeCode == 'nl' ? 'nl' : 'en'),
    );

    final completedTasks = await _todoRepo.watchCompletedTasks().first;
    final openTasks = await _todoRepo.watchOpenTasks().first;
    final openHabitGroups = openTasks.map((t) => habitGroupKey(t.title)).toSet();

    _heuristicLog(
      'run start force=$force selfDue=$selfDue partnerDue=$partnerDue '
      'open=${openTasks.length} completed=${completedTasks.length}',
    );

    // Categorize always tracks the current open list (not the 24h throttle).
    if (!selfDue) {
      _heuristicLog('self throttled → categorize only');
      final categorize = await _collectCategorize(openTasks);
      await _commitRanked(
        categorize,
        maxPending: _maxPendingSelf,
        countPending: _suggestionRepo.countPendingSelf,
      );
    }

    if (!selfDue && !partnerDue) {
      _heuristicLog('skip full run (both paths throttled)');
      return;
    }

    if (selfDue) {
      final before = await _suggestionRepo.countPendingSelf();
      _heuristicLog('self path start pending=$before');
      final ranked = <_RankedCandidate>[
        ...await _collectHabit(completedTasks, openHabitGroups, l10n),
        ...await _collectSeasonal(completedTasks, openHabitGroups, l10n),
        ...await _collectCalendar(openTasks),
        ...await _collectOverdue(openTasks, completedTasks, l10n),
        ...await _collectStale(openTasks, completedTasks, l10n),
        ...await _collectCategorize(openTasks),
      ];
      await _commitRanked(
        ranked,
        maxPending: _maxPendingSelf,
        countPending: _suggestionRepo.countPendingSelf,
      );
      final after = await _suggestionRepo.countPendingSelf();
      _heuristicLog(
        'self path end pending=$after created=${after - before} '
        'candidates=${ranked.length}',
      );
      if (!force && after > before) await _updateLastRun(selfPath: true);
    }

    if (partnerDue && _proposalRepo != null) {
      final before = await _suggestionRepo.countPendingFamilyMember();
      _heuristicLog('family path start pending=$before');
      final ranked = <_RankedCandidate>[
        ...await _collectFamilyComplement(openTasks),
        ...await _collectLoadBalance(openTasks),
      ];
      await _commitRanked(
        ranked,
        maxPending: _maxPendingFamilyMember,
        countPending: _suggestionRepo.countPendingFamilyMember,
      );
      final after = await _suggestionRepo.countPendingFamilyMember();
      _heuristicLog(
        'family path end pending=$after created=${after - before} '
        'candidates=${ranked.length}',
      );
      if (!force && after > before) await _updateLastRun(selfPath: false);
    } else if (partnerDue) {
      _heuristicLog('family path skipped (no proposal repo)');
    }
  }

  Future<void> _commitRanked(
    List<_RankedCandidate> ranked, {
    required int maxPending,
    required Future<int> Function() countPending,
  }) async {
    final scored = <_RankedCandidate>[];
    for (final c in ranked) {
      final feedback = await _suggestionRepo.feedbackDelta(
        dedupeKey: c.suggestion.dedupeKey,
        reason: c.suggestion.reason,
      );
      scored.add(
        _RankedCandidate(
          suggestion: c.suggestion,
          score: c.score + feedback,
          label: feedback == 0
              ? c.label
              : '${c.label} feedback=$feedback',
        ),
      );
    }
    scored.sort((a, b) => b.score.compareTo(a.score));

    var created = 0;
    for (final c in scored) {
      if (await countPending() >= maxPending) {
        _heuristicLog('commit: stop at pending cap');
        break;
      }
      if (c.score < suggestionMinScore) {
        _heuristicLog(
          'skip low score ${c.score} < $suggestionMinScore (${c.label})',
        );
        continue;
      }
      final before = await countPending();
      await _suggestionRepo.upsertSuggestion(c.suggestion);
      final after = await countPending();
      if (after > before) {
        created++;
        _heuristicLog('commit score=${c.score} ${c.label}');
      } else {
        _heuristicLog('skip duplicate/suppressed (${c.label})');
      }
    }
    _heuristicLog('commit done created=$created from ${scored.length} ranked');
  }

  Future<_RankedCandidate> _candidate({
    required AiSuggestion suggestion,
    required int score,
    required String label,
  }) async {
    return _RankedCandidate(
      suggestion: suggestion,
      score: score,
      label: label,
    );
  }

  // ---------------------------------------------------------------------------
  // Detector 1 — Habit (→ self)
  // ---------------------------------------------------------------------------

  Future<List<_RankedCandidate>> _collectHabit(
    List<PersonalTask> completed,
    Set<String> openHabitGroups,
    AppLocalizations l10n,
  ) async {
    final groups = <String, List<PersonalTask>>{};
    for (final task in completed) {
      if (task.recurrenceRule != null) continue;
      if (task.completedAt == null) continue;
      final key = habitGroupKey(task.title);
      groups.putIfAbsent(key, () => []).add(task);
    }

    final out = <_RankedCandidate>[];
    for (final entry in groups.entries) {
      if (openCoversHabitGroup(openHabitGroups, entry.key)) continue;

      final times = entry.value.map((t) => t.completedAt!).toList()..sort();
      final lastDone = times.last;
      final daysSince = _nowUtc.difference(lastDone).inDays;
      final original = entry.value.last;

      final median = times.length >= 2 ? _medianInterval(times) : null;
      final repeatDue =
          times.length >= 2 && daysSince >= median! * 0.8;
      final singleKeywordDue =
          times.length == 1 &&
          isStrongHabitTitle(original.title) &&
          daysSince >= _singleHabitSilenceDays;

      if (!repeatDue && !singleKeywordDue) continue;

      final interval = median ?? daysSince;
      final score = suggestionBaseScore(SuggestionReason.habit) +
          (repeatDue ? 10 + times.length.clamp(0, 10) : 0) +
          (daysSince ~/ 7).clamp(0, 8);
      final why = repeatDue
          ? 'repeatDue completions=${times.length} median=$median '
              'daysSince=$daysSince group=${entry.key}'
          : 'singleKeywordDue daysSince=$daysSince group=${entry.key}';
      out.add(
        await _candidate(
          score: score,
          label: 'habit "${original.title}" ($why)',
          suggestion: AiSuggestion.create(
            title: original.title,
            notes: original.notes,
            priority: original.priority.index,
            category: original.category.name,
            suggestedDueDate: lastDone
                .add(Duration(days: interval.round()))
                .toLocal(),
            reason: SuggestionReason.habit,
            dedupeKey: 'habit:${entry.key}',
            explanation: times.length >= 2
                ? l10n.suggestHabitRepeatExplanation(
                    original.title,
                    interval,
                    daysSince,
                  )
                : l10n.suggestHabitOnceExplanation(original.title, daysSince),
          ),
        ),
      );
    }
    return out;
  }

  // ---------------------------------------------------------------------------
  // Detector 2 — Family complement (→ family member)
  // ---------------------------------------------------------------------------

  Future<List<_RankedCandidate>> _collectFamilyComplement(
    List<PersonalTask> openTasks,
  ) async {
    final out = <_RankedCandidate>[];
    final seenFamilies = <String>{};
    for (final task in openTasks) {
      final hint = matchFamilyMemberHint(title: task.title, notes: task.notes);
      if (hint == null) continue;
      if (!seenFamilies.add(hint.familyId)) continue;
      if (await _suggestionRepo.hasRecentWithTitle(
        hint.familyMemberTitle,
        within: _privacyBudget,
      )) {
        _heuristicLog(
          'familyComplement: quiet familyId=${hint.familyId} (privacy budget)',
        );
        continue;
      }

      out.add(
        await _candidate(
          score: suggestionBaseScore(SuggestionReason.familyMemberComplement),
          label: 'familyComplement familyId=${hint.familyId}',
          suggestion: AiSuggestion.create(
            title: hint.familyMemberTitle,
            category: hint.categories.isEmpty
                ? task.category.name
                : hint.categories.first.name,
            reason: SuggestionReason.familyMemberComplement,
            dedupeKey: 'familyMemberComplement:${hint.familyId}',
            explanation: hint.explanation,
          ),
        ),
      );
    }
    return out;
  }

  // ---------------------------------------------------------------------------
  // Detector 3 — Seasonal history (→ self)
  // ---------------------------------------------------------------------------

  Future<List<_RankedCandidate>> _collectSeasonal(
    List<PersonalTask> completed,
    Set<String> openHabitGroups,
    AppLocalizations l10n,
  ) async {
    final currentMonth = _now().month;
    final currentYear = _now().year;

    final history = <String, List<DateTime>>{};
    for (final task in completed) {
      if (task.completedAt == null) continue;
      final key = habitGroupKey(task.title);
      history.putIfAbsent(key, () => []).add(task.completedAt!);
    }

    final out = <_RankedCandidate>[];
    for (final entry in history.entries) {
      if (openCoversHabitGroup(openHabitGroups, entry.key)) continue;

      final priorYearMatch = entry.value.any(
        (dt) => dt.month == currentMonth && dt.year < currentYear,
      );
      if (!priorYearMatch) continue;

      final original = completed.firstWhere(
        (t) => habitGroupKey(t.title) == entry.key,
      );
      final monthName = localizedMonthName(l10n, currentMonth);
      final lastDone = original.completedAt!;
      final thisYear = DateTime(
        currentYear,
        lastDone.month,
        lastDone.day,
        lastDone.hour,
        lastDone.minute,
      );
      final suggestedDue = thisYear.isAfter(_now())
          ? thisYear
          : _proposeReminder(
              title: original.title,
              category: original.category,
              completed: completed,
            );
      out.add(
        await _candidate(
          score: suggestionBaseScore(SuggestionReason.seasonal),
          label: 'seasonal "${original.title}" month=$monthName',
          suggestion: AiSuggestion.create(
            title: original.title,
            notes: original.notes,
            priority: original.priority.index,
            category: original.category.name,
            suggestedDueDate: suggestedDue,
            reason: SuggestionReason.seasonal,
            dedupeKey: 'seasonal:${entry.key}',
            explanation:
                l10n.suggestSeasonalExplanation(original.title, monthName),
          ),
        ),
      );
    }
    return out;
  }

  // ---------------------------------------------------------------------------
  // Detector 3b — Calendar keywords (→ self)
  // ---------------------------------------------------------------------------

  Future<List<_RankedCandidate>> _collectCalendar(
    List<PersonalTask> openTasks,
  ) async {
    final corpus = openTasks.map((t) => normalizeSuggestionText(t.title)).join(' ');
    final out = <_RankedCandidate>[];
    for (final prompt in calendarPromptsForMonth(_now().month)) {
      if (containsAnyKeyword(corpus, prompt.skipIfTitleContains)) {
        _heuristicLog('calendar: skip "${prompt.title}" (open corpus match)');
        continue;
      }
      out.add(
        await _candidate(
          score: suggestionBaseScore(SuggestionReason.calendar),
          label: 'calendar "${prompt.title}"',
          suggestion: AiSuggestion.create(
            title: prompt.title,
            suggestedDueDate: _proposeReminder(
              title: prompt.title,
              completed: const [],
            ),
            reason: SuggestionReason.calendar,
            dedupeKey: prompt.dedupeKey,
            explanation: prompt.explanation,
          ),
        ),
      );
    }
    return out;
  }

  // ---------------------------------------------------------------------------
  // Detector 3c — Overdue open tasks (→ self)
  // ---------------------------------------------------------------------------

  Future<List<_RankedCandidate>> _collectOverdue(
    List<PersonalTask> openTasks,
    List<PersonalTask> completed,
    AppLocalizations l10n,
  ) async {
    final declined = await _suggestionRepo.dismissedRelatedTaskIds(
      SuggestionReason.overdue,
    );
    final out = <_RankedCandidate>[];
    final now = _now();

    for (final task in openTasks) {
      if (task.dueDate == null) continue;
      if (declined.contains(task.id)) continue;
      if (!_isTaskOverdue(task.dueDate!, now, isAllDay: task.isAllDay)) {
        continue;
      }

      final localDue = task.dueDate!.toLocal();
      final effective = task.isAllDay
          ? DateTime(localDue.year, localDue.month, localDue.day, 23, 59, 59)
          : localDue;
      final daysOverdue = now.difference(effective).inDays.clamp(0, 60);

      final proposal = _reminderEngine.best(
        title: task.title,
        category: task.category,
        completedTasks: completed,
        now: now,
      );
      final at = proposal?.at ?? suggestedReminderAt(now);

      out.add(
        await _candidate(
          score: suggestionBaseScore(SuggestionReason.overdue) +
              daysOverdue.clamp(0, 14),
          label: 'overdue "${task.title}" days=$daysOverdue',
          suggestion: AiSuggestion.create(
            title: task.title,
            notes: task.notes,
            priority: task.priority.index,
            category: task.category.name,
            suggestedDueDate: at,
            reason: SuggestionReason.overdue,
            dedupeKey: 'overdue:${task.id}',
            relatedTaskIds: [task.id],
            explanation: l10n.suggestOverdueExplanation(task.title, daysOverdue),
          ),
        ),
      );
    }
    return out;
  }

  bool _isTaskOverdue(DateTime due, DateTime now, {required bool isAllDay}) {
    final local = due.toLocal();
    final effective = isAllDay
        ? DateTime(local.year, local.month, local.day, 23, 59, 59)
        : local;
    return effective.isBefore(now);
  }

  // ---------------------------------------------------------------------------
  // Detector 3d — Stale open tasks (→ self)
  // ---------------------------------------------------------------------------

  Future<List<_RankedCandidate>> _collectStale(
    List<PersonalTask> openTasks,
    List<PersonalTask> completed,
    AppLocalizations l10n,
  ) async {
    final declined = await _suggestionRepo.dismissedRelatedTaskIds(
      SuggestionReason.stale,
    );
    final out = <_RankedCandidate>[];
    for (final task in openTasks) {
      if (task.dueDate != null || task.remindAt != null) continue;
      if (declined.contains(task.id)) continue;
      final ageDays = _nowUtc.difference(task.createdAt).inDays;
      if (ageDays < _staleAfterDays) continue;

      final proposal = _reminderEngine.best(
        title: task.title,
        category: task.category,
        completedTasks: completed,
        now: _now(),
      );
      final at = proposal?.at ?? suggestedReminderAt(_now());

      out.add(
        await _candidate(
          score: suggestionBaseScore(SuggestionReason.stale) +
              (ageDays ~/ 7).clamp(0, 12),
          label: 'stale "${task.title}" ageDays=$ageDays',
          suggestion: AiSuggestion.create(
            title: task.title,
            notes: task.notes,
            priority: task.priority.index,
            category: task.category.name,
            suggestedDueDate: at,
            reason: SuggestionReason.stale,
            dedupeKey: 'stale:${task.id}',
            relatedTaskIds: [task.id],
            explanation: l10n.suggestStaleExplanation(task.title, ageDays),
          ),
        ),
      );
    }
    return out;
  }

  // ---------------------------------------------------------------------------
  // Detector 3e — Uncategorized open tasks (→ self)
  // ---------------------------------------------------------------------------

  Future<List<_RankedCandidate>> _collectCategorize(
    List<PersonalTask> openTasks,
  ) async {
    final declined = await _suggestionRepo.dismissedRelatedTaskIds(
      SuggestionReason.categorize,
    );
    final existing = openTasks
        .map((t) => t.customCategory)
        .whereType<String>()
        .toSet()
        .toList();

    final byCategory = <TaskCategory, List<PersonalTask>>{};
    for (final task in openTasks) {
      if (task.customCategory != null) continue;
      if (declined.contains(task.id)) continue;
      if (task.category == TaskCategory.other) continue;
      byCategory.putIfAbsent(task.category, () => []).add(task);
    }

    final out = <_RankedCandidate>[];
    for (final entry in byCategory.entries) {
      if (entry.value.length < _uncategorizedThreshold) continue;

      final pending = await _suggestionRepo.watchPendingSelf().first;
      if (pending.any(
        (s) =>
            s.reason == SuggestionReason.categorize &&
            s.category == entry.key.name,
      )) {
        continue;
      }

      final ids = entry.value.map((t) => t.id).toList();
      final reused = resolveCategoryLabel(entry.key.name, existing);
      final hasCustom = existing.any(
        (e) => e.trim().toLowerCase() == reused.trim().toLowerCase(),
      );

      out.add(
        await _candidate(
          score: suggestionBaseScore(SuggestionReason.categorize) +
              entry.value.length.clamp(0, 10),
          label: 'categorize ${entry.key.name} count=${ids.length}',
          suggestion: AiSuggestion.create(
            title: 'Categorize ${ids.length} as ${entry.key.name}',
            notes: hasCustom ? reused : null,
            category: entry.key.name,
            reason: SuggestionReason.categorize,
            dedupeKey:
                'categorize:${entry.key.name}:${(ids.toList()..sort()).join(',')}',
            relatedTaskIds: ids,
            explanation: 'Open tasks with no category yet.',
          ),
        ),
      );
    }
    return out;
  }

  // ---------------------------------------------------------------------------
  // Detector 4 — Load balance (→ family member)
  // ---------------------------------------------------------------------------

  Future<List<_RankedCandidate>> _collectLoadBalance(
    List<PersonalTask> openTasks,
  ) async {
    final peerMetrics = await _fetchPeerLoadMetrics();
    final byCategory = <String, List<PersonalTask>>{};
    for (final task in openTasks) {
      byCategory.putIfAbsent(task.category.name, () => []).add(task);
    }

    final out = <_RankedCandidate>[];
    for (final entry in byCategory.entries) {
      // "Other" has no actionable theme for the recipient — skip it.
      if (entry.key == 'other') continue;
      // Only shareable (non-private) tasks can become a concrete ask.
      final shareable =
          entry.value.where((t) => !t.isPrivate).toList(growable: false);
      if (shareable.length < 3) continue;

      final peerHigh = peerMetrics.isEmpty
          ? 0
          : peerMetrics
              .map((m) => m.openInCategory(entry.key))
              .fold<int>(0, (a, b) => a > b ? a : b);
      if (!_localLoadHeavierThanPeers(
        category: entry.key,
        localCount: shareable.length,
        peerMetrics: peerMetrics,
      )) {
        _heuristicLog(
          'loadBalance: skip category=${entry.key} '
          'shareable=${shareable.length} peerHigh=$peerHigh',
        );
        continue;
      }

      final title = loadBalanceTitle(entry.key);
      if (await _suggestionRepo.hasRecentWithTitle(
        title,
        within: _privacyBudget,
      )) {
        _heuristicLog(
          'loadBalance: quiet category=${entry.key} (privacy budget)',
        );
        continue;
      }

      final gap = shareable.length - peerHigh;
      out.add(
        await _candidate(
          score: suggestionBaseScore(SuggestionReason.loadBalance) +
              gap.clamp(0, 15),
          label:
              'loadBalance category=${entry.key} shareable=${shareable.length} '
              'peerHigh=$peerHigh',
          suggestion: AiSuggestion.create(
            title: title,
            category: entry.key,
            reason: SuggestionReason.loadBalance,
            dedupeKey: 'loadBalance:${entry.key}',
            relatedTaskIds: shareable.map((t) => t.id).toList(),
            explanation:
                'You have ${shareable.length} open shareable tasks in '
                '${categoryLabel(entry.key)}. Pick one to ask for help.',
          ),
        ),
      );
    }
    return out;
  }

  Future<List<LoadMetrics>> _fetchPeerLoadMetrics() async {
    final pull = _pullLoadMetrics;
    if (pull == null) return const [];
    try {
      return await pull();
    } catch (_) {
      return const [];
    }
  }

  /// When peer metrics exist, only nudge if this device is heavier in the category.
  @visibleForTesting
  bool localLoadHeavierThanPeers({
    required String category,
    required int localCount,
    required List<LoadMetrics> peerMetrics,
  }) {
    if (peerMetrics.isEmpty) return true;
    var peerHigh = 0;
    for (final metrics in peerMetrics) {
      final count = metrics.openInCategory(category);
      if (count > peerHigh) peerHigh = count;
    }
    return localCount > peerHigh;
  }

  bool _localLoadHeavierThanPeers({
    required String category,
    required int localCount,
    required List<LoadMetrics> peerMetrics,
  }) =>
      localLoadHeavierThanPeers(
        category: category,
        localCount: localCount,
        peerMetrics: peerMetrics,
      );

  DateTime? _proposeReminder({
    required String title,
    TaskCategory? category,
    List<PersonalTask> completed = const [],
  }) {
    return _reminderEngine
        .best(
          title: title,
          category: category,
          completedTasks: completed,
          now: _now(),
        )
        ?.at;
  }

  bool _isDue(DateTime? lastRun, DateTime now) {
    if (lastRun == null) return true;
    return now.difference(lastRun).inHours >= 24;
  }

  Future<AppSettingsRow?> _loadSettings() async {
    final rows = await _db.select(_db.appSettings).get();
    return rows.isEmpty ? null : rows.first;
  }

  Future<void> _updateLastRun({required bool selfPath}) async {
    final now = _nowUtc;
    await _db
        .into(_db.appSettings)
        .insertOnConflictUpdate(
          selfPath
              ? AppSettingsCompanion(
                  key: const Value('default'),
                  lastSuggestionRunAt: Value(now),
                  updatedAt: Value(now),
                )
              : AppSettingsCompanion(
                  key: const Value('default'),
                  lastFamilyMemberSuggestionRunAt: Value(now),
                  updatedAt: Value(now),
                ),
        );
  }

  int _medianInterval(List<DateTime> sorted) {
    final gaps = <int>[];
    for (var i = 1; i < sorted.length; i++) {
      gaps.add(sorted[i].difference(sorted[i - 1]).inDays);
    }
    gaps.sort();
    if (gaps.isEmpty) return 0;
    final mid = gaps.length ~/ 2;
    return gaps.length.isOdd ? gaps[mid] : ((gaps[mid - 1] + gaps[mid]) ~/ 2);
  }
}
