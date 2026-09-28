import 'package:flutter_test/flutter_test.dart';
import 'package:kids/task/goal_xp.dart';
import 'package:kinetic_webdav/kinetic_webdav.dart';

void main() {
  KidGoal goal({int targetXp = 50}) => KidGoal(
        kidId: 'kid',
        title: 'Reward',
        targetXp: targetXp,
        updatedAt: DateTime.utc(2026, 1, 1),
      );

  group('GoalXpBreakdown', () {
    test('no goal returns uncapped total without overflow', () {
      final b = GoalXpBreakdown.from(totalXp: 42, goal: null);
      expect(b.towardGoal, 42);
      expect(b.overflow, 0);
      expect(b.progress, isNull);
      expect(b.reached, isFalse);
    });

    test('zero target treated as no goal progress', () {
      final b = GoalXpBreakdown.from(
        totalXp: 20,
        goal: goal(targetXp: 0),
      );
      expect(b.towardGoal, 20);
      expect(b.overflow, 0);
      expect(b.progress, isNull);
      expect(b.reached, isFalse);
    });

    test('under target', () {
      final b = GoalXpBreakdown.from(totalXp: 25, goal: goal());
      expect(b.towardGoal, 25);
      expect(b.overflow, 0);
      expect(b.progress, 0.5);
      expect(b.reached, isFalse);
    });

    test('exact target', () {
      final b = GoalXpBreakdown.from(totalXp: 50, goal: goal());
      expect(b.towardGoal, 50);
      expect(b.overflow, 0);
      expect(b.progress, 1.0);
      expect(b.reached, isTrue);
    });

    test('over target fills bar and banks overflow', () {
      final b = GoalXpBreakdown.from(totalXp: 65, goal: goal());
      expect(b.towardGoal, 50);
      expect(b.overflow, 15);
      expect(b.progress, 1.0);
      expect(b.reached, isTrue);
    });
  });

  test('goalCelebrationKey uses updatedAt UTC ISO', () {
    final g = goal();
    expect(goalCelebrationKey(g), '2026-01-01T00:00:00.000Z');
  });
}
