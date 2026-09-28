import 'package:kinetic_webdav/kinetic_webdav.dart';

/// Split of accepted XP into goal progress vs overflow spaarpot.
class GoalXpBreakdown {
  final int towardGoal;
  final int overflow;
  final double? progress;
  final bool reached;

  const GoalXpBreakdown({
    required this.towardGoal,
    required this.overflow,
    required this.progress,
    required this.reached,
  });

  factory GoalXpBreakdown.from({
    required int totalXp,
    KidGoal? goal,
  }) {
    final target = goal?.targetXp ?? 0;
    if (goal == null || target <= 0) {
      return GoalXpBreakdown(
        towardGoal: totalXp,
        overflow: 0,
        progress: null,
        reached: false,
      );
    }
    final toward = totalXp > target ? target : totalXp;
    final overflow = totalXp > target ? totalXp - target : 0;
    return GoalXpBreakdown(
      towardGoal: toward,
      overflow: overflow,
      progress: (toward / target).clamp(0.0, 1.0),
      reached: totalXp >= target,
    );
  }
}

/// Stable key used to remember that celebration already played for this goal.
String goalCelebrationKey(KidGoal goal) =>
    goal.updatedAt.toUtc().toIso8601String();

const kGoalCelebratedStoreKey = 'kinetic_goal_celebrated';
