import '../../l10n/generated/app_localizations.dart';
import '../../theme/app_themes.dart';
import '../models/enums.dart';
import '../models/personal_task.dart';

/// How the chip label should be phrased, independent of locale.
enum ReminderLabelMode { relativeHours, relativeDays, clock }

enum ReminderExplainKind {
  habitTime,
  habitInterval,
  keyword,
  categorySchool,
  categoryHousehold,
  categoryHealth,
  categoryAdmin,
  categoryDefault,
  evening,
  morning,
  tomorrowEvening,
  quick,
}

/// A single smart reminder chip proposal.
class ReminderChipProposal {
  final DateTime at;
  final int score;
  final ReminderLabelMode labelMode;
  final int relativeCount;
  final ReminderExplainKind explainKind;
  final int? explainCount;
  final int? explainWeekday;
  final int? explainMedianDays;
  final int? explainDaysSince;
  final String? explainKeyword;

  const ReminderChipProposal({
    required this.at,
    required this.score,
    required this.labelMode,
    this.relativeCount = 0,
    required this.explainKind,
    this.explainCount,
    this.explainWeekday,
    this.explainMedianDays,
    this.explainDaysSince,
    this.explainKeyword,
  });
}

String formatReminderChipLabel(
  ReminderChipProposal chip,
  AppLocalizations l10n, {
  DateTime? now,
}) {
  final clock = (now ?? DateTime.now()).toLocal();
  final at = chip.at.toLocal();
  final time = formatClockTime(at, l10n);

  switch (chip.labelMode) {
    case ReminderLabelMode.relativeHours:
      return l10n.dateInHours(chip.relativeCount);
    case ReminderLabelMode.relativeDays:
      return l10n.dateInDays(chip.relativeCount);
    case ReminderLabelMode.clock:
      final dayDiff = DateTime(
        at.year,
        at.month,
        at.day,
      ).difference(DateTime(clock.year, clock.month, clock.day)).inDays;
      if (dayDiff == 0) {
        return at.hour >= 17
            ? l10n.dateTonightTime(time)
            : l10n.dateTodayTime(time);
      }
      if (dayDiff == 1) return l10n.dateTomorrowTime(time);
      return '${_shortWeekday(at.weekday, l10n)} $time';
  }
}

String formatReminderChipExplanation(
  ReminderChipProposal chip,
  AppLocalizations l10n,
) {
  return switch (chip.explainKind) {
    ReminderExplainKind.habitTime => l10n.reminderWhyHabitTime(
      chip.explainCount ?? 0,
      _shortWeekday(chip.explainWeekday ?? 1, l10n),
    ),
    ReminderExplainKind.habitInterval => l10n.reminderWhyHabitInterval(
      chip.explainMedianDays ?? 0,
      chip.explainDaysSince ?? 0,
    ),
    ReminderExplainKind.keyword => l10n.reminderWhyKeyword(
      chip.explainKeyword ?? '',
    ),
    ReminderExplainKind.categorySchool => l10n.reminderWhyCategorySchool,
    ReminderExplainKind.categoryHousehold => l10n.reminderWhyCategoryHousehold,
    ReminderExplainKind.categoryHealth => l10n.reminderWhyCategoryHealth,
    ReminderExplainKind.categoryAdmin => l10n.reminderWhyCategoryAdmin,
    ReminderExplainKind.categoryDefault => l10n.reminderWhyDefaultMorning,
    ReminderExplainKind.evening => l10n.reminderWhyEvening,
    ReminderExplainKind.morning => l10n.reminderWhyDefaultMorning,
    ReminderExplainKind.tomorrowEvening => l10n.reminderWhyTomorrowEvening,
    ReminderExplainKind.quick => l10n.reminderWhyQuick,
  };
}

String _shortWeekday(int weekday, AppLocalizations l10n) => switch (weekday) {
  1 => l10n.dateWeekdayShortMonday,
  2 => l10n.dateWeekdayShortTuesday,
  3 => l10n.dateWeekdayShortWednesday,
  4 => l10n.dateWeekdayShortThursday,
  5 => l10n.dateWeekdayShortFriday,
  6 => l10n.dateWeekdayShortSaturday,
  7 => l10n.dateWeekdayShortSunday,
  _ => '',
};

enum _ReminderProposalSource {
  habitTime,
  habitInterval,
  keyword,
  category,
  contextual,
  fallback,
}

class _ScoredCandidate {
  final DateTime at;
  final int score;
  final _ReminderProposalSource source;
  final ReminderLabelMode labelMode;
  final int relativeCount;
  final ReminderExplainKind explainKind;
  final int? explainCount;
  final int? explainWeekday;
  final int? explainMedianDays;
  final int? explainDaysSince;
  final String? explainKeyword;

  const _ScoredCandidate({
    required this.at,
    required this.score,
    required this.source,
    required this.labelMode,
    this.relativeCount = 0,
    required this.explainKind,
    this.explainCount,
    this.explainWeekday,
    this.explainMedianDays,
    this.explainDaysSince,
    this.explainKeyword,
  });

  ReminderChipProposal toProposal() => ReminderChipProposal(
    at: at,
    score: score,
    labelMode: labelMode,
    relativeCount: relativeCount,
    explainKind: explainKind,
    explainCount: explainCount,
    explainWeekday: explainWeekday,
    explainMedianDays: explainMedianDays,
    explainDaysSince: explainDaysSince,
    explainKeyword: explainKeyword,
  );
}

/// On-device heuristic engine that proposes contextual reminder chips.
class ReminderProposalEngine {
  static const _scoreHabitTime = 100;
  static const _scoreHabitInterval = 90;
  static const _scoreKeyword = 70;
  static const _scoreCategory = 50;
  static const _scoreContextual = 30;
  static const _scoreFallback = 10;

  static const _keywordRules = <String, ({int hour, int minute})>{
    'school': (hour: 7, minute: 0),
    'huiswerk': (hour: 7, minute: 0),
    'sport': (hour: 18, minute: 0),
    'training': (hour: 18, minute: 0),
    'zwemmen': (hour: 18, minute: 0),
    'boodschappen': (hour: 10, minute: 0),
    'supermarkt': (hour: 10, minute: 0),
    'belasting': (hour: 9, minute: 0),
    'deadline': (hour: 9, minute: 0),
    'verjaardag': (hour: 10, minute: 0),
    'cadeau': (hour: 10, minute: 0),
    'kapper': (hour: 9, minute: 0),
    'tandarts': (hour: 9, minute: 0),
    'afspraak': (hour: 9, minute: 0),
  };

  List<ReminderChipProposal> propose({
    required String title,
    TaskCategory? category,
    required List<PersonalTask> completedTasks,
    DateTime? now,
    int maxChips = 4,
  }) {
    final clock = (now ?? DateTime.now()).toLocal();
    final normalizedTitle = _normalize(title);

    if (normalizedTitle.isEmpty) {
      return _fallbackChips(clock, maxChips);
    }

    final candidates = <_ScoredCandidate>[
      ..._habitTimeCandidates(normalizedTitle, completedTasks, clock),
      ..._habitIntervalCandidates(normalizedTitle, completedTasks, clock),
      ..._keywordCandidates(normalizedTitle, clock),
      ..._categoryCandidates(category, clock),
      ..._contextualCandidates(clock),
      ..._fallbackCandidates(clock),
    ];

    candidates.sort((a, b) => b.score.compareTo(a.score));

    final picked = <ReminderChipProposal>[];
    for (final c in candidates) {
      if (c.at.isBefore(clock)) continue;
      if (picked.any((p) => p.at.difference(c.at).inMinutes.abs() < 30)) {
        continue;
      }
      picked.add(c.toProposal());
      if (picked.length >= maxChips) break;
    }

    if (picked.length < maxChips) {
      for (final fb in _fallbackChips(clock, maxChips)) {
        if (picked.any((p) => p.at.difference(fb.at).inMinutes.abs() < 30)) {
          continue;
        }
        picked.add(fb);
        if (picked.length >= maxChips) break;
      }
    }

    return picked;
  }

  /// Highest-scoring chip, or null when nothing could be proposed.
  ReminderChipProposal? best({
    required String title,
    TaskCategory? category,
    required List<PersonalTask> completedTasks,
    DateTime? now,
  }) {
    final chips = propose(
      title: title,
      category: category,
      completedTasks: completedTasks,
      now: now,
      maxChips: 1,
    );
    return chips.isEmpty ? null : chips.first;
  }

  List<ReminderChipProposal> _fallbackChips(DateTime clock, int maxChips) {
    return _fallbackCandidates(clock)
        .where((c) => c.at.isAfter(clock))
        .take(maxChips)
        .map((c) => c.toProposal())
        .toList();
  }

  List<_ScoredCandidate> _habitTimeCandidates(
    String normalizedTitle,
    List<PersonalTask> completed,
    DateTime clock,
  ) {
    final slots = <String, int>{};
    for (final task in completed) {
      if (task.completedAt == null) continue;
      if (_normalize(task.title) != normalizedTitle) continue;
      final local = task.completedAt!.toLocal();
      final key = '${local.weekday}-${local.hour}';
      slots[key] = (slots[key] ?? 0) + 1;
    }
    final total = slots.values.fold<int>(0, (a, b) => a + b);
    if (total < 2) return [];

    final best = slots.entries.reduce((a, b) => a.value >= b.value ? a : b);
    final parts = best.key.split('-');
    final weekday = int.parse(parts[0]);
    final hour = int.parse(parts[1]);
    final at = _nextWeekdayAt(clock, weekday, hour, 0);
    final count = best.value;
    return [
      _ScoredCandidate(
        at: at,
        score: _scoreHabitTime,
        source: _ReminderProposalSource.habitTime,
        labelMode: ReminderLabelMode.clock,
        explainKind: ReminderExplainKind.habitTime,
        explainCount: count,
        explainWeekday: weekday,
      ),
    ];
  }

  List<_ScoredCandidate> _habitIntervalCandidates(
    String normalizedTitle,
    List<PersonalTask> completed,
    DateTime clock,
  ) {
    final times = <DateTime>[];
    for (final task in completed) {
      if (task.recurrenceRule != null) continue;
      if (task.completedAt == null) continue;
      if (_normalize(task.title) != normalizedTitle) continue;
      times.add(task.completedAt!);
    }
    if (times.length < 2) return [];

    times.sort();
    final median = _medianInterval(times);
    final lastDone = times.last;
    final daysSince = clock.toUtc().difference(lastDone).inDays;
    if (daysSince < median * 0.8) return [];

    final medianHour = _medianHour(times);
    final at = DateTime(
      clock.year,
      clock.month,
      clock.day,
      medianHour,
      0,
    ).add(Duration(days: median - daysSince));
    if (!at.isAfter(clock)) {
      return [];
    }

    final daysUntil = at.difference(clock).inDays;
    final relative = daysUntil <= 1;

    return [
      _ScoredCandidate(
        at: at,
        score: _scoreHabitInterval,
        source: _ReminderProposalSource.habitInterval,
        labelMode: relative
            ? ReminderLabelMode.clock
            : ReminderLabelMode.relativeDays,
        relativeCount: relative ? 0 : daysUntil,
        explainKind: ReminderExplainKind.habitInterval,
        explainMedianDays: median,
        explainDaysSince: daysSince,
      ),
    ];
  }

  List<_ScoredCandidate> _keywordCandidates(
    String normalizedTitle,
    DateTime clock,
  ) {
    final results = <_ScoredCandidate>[];
    for (final entry in _keywordRules.entries) {
      if (!normalizedTitle.contains(entry.key)) continue;
      final rule = entry.value;
      DateTime at;
      var labelMode = ReminderLabelMode.clock;
      var relativeCount = 0;
      if (entry.key == 'boodschappen' || entry.key == 'supermarkt') {
        at = _nextWeekdayAt(clock, DateTime.saturday, rule.hour, rule.minute);
      } else if (entry.key == 'belasting' ||
          entry.key == 'deadline' ||
          entry.key == 'verjaardag' ||
          entry.key == 'cadeau') {
        at = DateTime(
          clock.year,
          clock.month,
          clock.day,
          rule.hour,
          rule.minute,
        ).add(const Duration(days: 3));
        labelMode = ReminderLabelMode.relativeDays;
        relativeCount = 3;
      } else if (entry.key == 'sport' ||
          entry.key == 'training' ||
          entry.key == 'zwemmen') {
        at = _eveningTodayOrTomorrow(clock, rule.hour, rule.minute);
      } else {
        at = _tomorrowAt(clock, rule.hour, rule.minute);
      }
      results.add(
        _ScoredCandidate(
          at: at,
          score: _scoreKeyword,
          source: _ReminderProposalSource.keyword,
          labelMode: labelMode,
          relativeCount: relativeCount,
          explainKind: ReminderExplainKind.keyword,
          explainKeyword: entry.key,
        ),
      );
    }
    return results;
  }

  List<_ScoredCandidate> _categoryCandidates(
    TaskCategory? category,
    DateTime clock,
  ) {
    final cat = category ?? TaskCategory.other;
    final DateTime at;
    final ReminderExplainKind explainKind;

    switch (cat) {
      case TaskCategory.school:
        at = _tomorrowAt(clock, 7, 0);
        explainKind = ReminderExplainKind.categorySchool;
      case TaskCategory.household:
        at = _nextWeekdayAt(clock, DateTime.saturday, 9, 0);
        explainKind = ReminderExplainKind.categoryHousehold;
      case TaskCategory.health:
        at = _tomorrowAt(clock, 8, 0);
        explainKind = ReminderExplainKind.categoryHealth;
      case TaskCategory.finance:
      case TaskCategory.admin:
        at = _tomorrowAt(clock, 9, 0);
        explainKind = ReminderExplainKind.categoryAdmin;
      case TaskCategory.other:
        at = _tomorrowAt(clock, 9, 0);
        explainKind = ReminderExplainKind.categoryDefault;
    }

    return [
      _ScoredCandidate(
        at: at,
        score: _scoreCategory,
        source: _ReminderProposalSource.category,
        labelMode: ReminderLabelMode.clock,
        explainKind: explainKind,
      ),
    ];
  }

  List<_ScoredCandidate> _contextualCandidates(DateTime clock) {
    final results = <_ScoredCandidate>[];
    if (clock.hour < 20) {
      results.add(
        _ScoredCandidate(
          at: DateTime(clock.year, clock.month, clock.day, 20, 0),
          score: _scoreContextual,
          source: _ReminderProposalSource.contextual,
          labelMode: ReminderLabelMode.clock,
          explainKind: ReminderExplainKind.evening,
        ),
      );
    }
    results.add(
      _ScoredCandidate(
        at: _tomorrowAt(clock, 9, 0),
        score: _scoreContextual,
        source: _ReminderProposalSource.contextual,
        labelMode: ReminderLabelMode.clock,
        explainKind: ReminderExplainKind.morning,
      ),
    );
    if (clock.hour < 20) {
      results.add(
        _ScoredCandidate(
          at: _tomorrowAt(clock, 20, 0),
          score: _scoreContextual - 1,
          source: _ReminderProposalSource.contextual,
          labelMode: ReminderLabelMode.clock,
          explainKind: ReminderExplainKind.tomorrowEvening,
        ),
      );
    }
    return results;
  }

  List<_ScoredCandidate> _fallbackCandidates(DateTime clock) {
    return [
      _ScoredCandidate(
        at: clock.add(const Duration(hours: 1)),
        score: _scoreFallback,
        source: _ReminderProposalSource.fallback,
        labelMode: ReminderLabelMode.relativeHours,
        relativeCount: 1,
        explainKind: ReminderExplainKind.quick,
      ),
      ..._contextualCandidates(clock),
    ];
  }

  DateTime _tomorrowAt(DateTime clock, int hour, int minute) {
    final tomorrow = clock.add(const Duration(days: 1));
    return DateTime(tomorrow.year, tomorrow.month, tomorrow.day, hour, minute);
  }

  DateTime _eveningTodayOrTomorrow(DateTime clock, int hour, int minute) {
    final tonight = DateTime(clock.year, clock.month, clock.day, hour, minute);
    if (tonight.isAfter(clock)) return tonight;
    return _tomorrowAt(clock, hour, minute);
  }

  DateTime _nextWeekdayAt(DateTime clock, int weekday, int hour, int minute) {
    var candidate = DateTime(clock.year, clock.month, clock.day, hour, minute);
    while (candidate.weekday != weekday || !candidate.isAfter(clock)) {
      candidate = candidate.add(const Duration(days: 1));
    }
    return candidate;
  }

  int _medianInterval(List<DateTime> sorted) {
    final gaps = <int>[];
    for (var i = 1; i < sorted.length; i++) {
      gaps.add(sorted[i].difference(sorted[i - 1]).inDays);
    }
    gaps.sort();
    final mid = gaps.length ~/ 2;
    return gaps.length.isOdd ? gaps[mid] : ((gaps[mid - 1] + gaps[mid]) ~/ 2);
  }

  int _medianHour(List<DateTime> times) {
    final hours = times.map((t) => t.toLocal().hour).toList()..sort();
    return hours[hours.length ~/ 2];
  }

  String _normalize(String s) => s
      .trim()
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9\u00c0-\u024f]'), ' ')
      .trim();
}
