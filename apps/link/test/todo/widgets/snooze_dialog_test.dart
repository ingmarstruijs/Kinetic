import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:link/todo/widgets/snooze_dialog.dart';

void main() {
  group('resolveSnoozeUntil', () {
    final now = DateTime(2026, 9, 15, 14, 30);

    test('ten minutes', () {
      expect(
        resolveSnoozeUntil(SnoozeChoice.tenMinutes, now: now),
        DateTime(2026, 9, 15, 14, 40),
      );
    });

    test('one hour', () {
      expect(
        resolveSnoozeUntil(SnoozeChoice.oneHour, now: now),
        DateTime(2026, 9, 15, 15, 30),
      );
    });

    test('three hours', () {
      expect(
        resolveSnoozeUntil(SnoozeChoice.threeHours, now: now),
        DateTime(2026, 9, 15, 17, 30),
      );
    });

    test('tomorrow morning is 09:00 next day', () {
      expect(
        resolveSnoozeUntil(SnoozeChoice.tomorrowMorning, now: now),
        DateTime(2026, 9, 16, 9),
      );
    });

    test('custom time later today', () {
      expect(
        resolveSnoozeUntil(
          SnoozeChoice.custom,
          now: now,
          custom: const TimeOfDay(hour: 18, minute: 0),
        ),
        DateTime(2026, 9, 15, 18),
      );
    });

    test('custom time in the past rolls to tomorrow', () {
      expect(
        resolveSnoozeUntil(
          SnoozeChoice.custom,
          now: now,
          custom: const TimeOfDay(hour: 9, minute: 0),
        ),
        DateTime(2026, 9, 16, 9),
      );
    });
  });
}
