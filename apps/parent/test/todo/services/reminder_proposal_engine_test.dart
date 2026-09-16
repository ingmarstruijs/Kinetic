import 'package:flutter_test/flutter_test.dart';
import 'package:parent/l10n/generated/app_localizations_en.dart';
import 'package:parent/l10n/generated/app_localizations_nl.dart';
import 'package:parent/todo/models/enums.dart';
import 'package:parent/todo/models/personal_task.dart';
import 'package:parent/todo/services/reminder_proposal_engine.dart';

void main() {
  final engine = ReminderProposalEngine();
  final en = AppLocalizationsEn();
  final nl = AppLocalizationsNl();

  PersonalTask completed({
    required String title,
    required DateTime completedAt,
  }) {
    return PersonalTask.create(
      title: title,
      dueDate: completedAt,
      isAllDay: false,
    ).copyWith(isCompleted: true, completedAt: completedAt);
  }

  List<String> labels(
    List<ReminderChipProposal> chips,
    DateTime now, {
    required bool dutch,
  }) {
    final l10n = dutch ? nl : en;
    return chips
        .map((c) => formatReminderChipLabel(c, l10n, now: now))
        .toList();
  }

  group('ReminderProposalEngine', () {
    test('empty title returns fallback chips', () {
      final now = DateTime(2026, 6, 17, 10);
      final chips = engine.propose(
        title: '',
        completedTasks: const [],
        now: now,
      );
      expect(chips, isNotEmpty);
      expect(labels(chips, now, dutch: false), contains('In 1 hour'));
      expect(labels(chips, now, dutch: false), contains('Tomorrow 09:00'));
      expect(labels(chips, now, dutch: true), contains('Over 1 uur'));
      expect(labels(chips, now, dutch: true), contains('Morgen 09:00'));
      expect(labels(chips, now, dutch: true), contains('Vanavond 20:00'));
      expect(labels(chips, now, dutch: true), contains('Morgen 20:00'));
    });

    test('school keyword suggests tomorrow morning', () {
      final now = DateTime(2026, 6, 17, 10);
      final chips = engine.propose(
        title: 'Schooltas controleren',
        completedTasks: const [],
        now: now,
      );
      expect(
        formatReminderChipLabel(chips.first, en, now: now),
        'Tomorrow 07:00',
      );
      expect(
        formatReminderChipLabel(chips.first, nl, now: now),
        'Morgen 07:00',
      );
    });

    test('habit time wins over category default', () {
      final saturday = DateTime(2026, 6, 13, 10);
      final now = DateTime(2026, 6, 17, 10);
      final chips = engine.propose(
        title: 'Boodschappen',
        category: TaskCategory.household,
        completedTasks: [
          completed(title: 'Boodschappen', completedAt: saturday),
          completed(
            title: 'Boodschappen',
            completedAt: saturday.subtract(const Duration(days: 7)),
          ),
        ],
        now: now,
      );
      expect(
        formatReminderChipLabel(chips.first, en, now: now),
        startsWith('Sat'),
      );
      expect(
        formatReminderChipLabel(chips.first, nl, now: now),
        startsWith('Za'),
      );
      expect(formatReminderChipExplanation(chips.first, en), isNotEmpty);
    });

    test('hides vanavond chip after 20:00', () {
      final now = DateTime(2026, 6, 17, 21);
      final chips = engine.propose(
        title: 'Iets doen',
        completedTasks: const [],
        now: now,
      );
      expect(
        labels(chips, now, dutch: false),
        isNot(contains('Tonight 20:00')),
      );
      expect(
        labels(chips, now, dutch: true),
        isNot(contains('Vanavond 20:00')),
      );
    });

    test('deduplicates near-identical times', () {
      final chips = engine.propose(
        title: 'Taak',
        completedTasks: const [],
        now: DateTime(2026, 6, 17, 10),
        maxChips: 6,
      );
      for (var i = 0; i < chips.length; i++) {
        for (var j = i + 1; j < chips.length; j++) {
          final diff = chips[i].at.difference(chips[j].at).inMinutes.abs();
          expect(diff, greaterThanOrEqualTo(30));
        }
      }
    });
  });
}
