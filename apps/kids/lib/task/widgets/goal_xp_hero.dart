import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kinetic_webdav/kinetic_webdav.dart';

import '../../l10n/generated/app_localizations.dart';
import '../goal_xp.dart';

/// XP hero with goal progress, overflow spaarpot, and one-shot celebration.
///
/// Celebration typically fires after Link confirms a chore and the kid's next
/// sync raises XP over the target. Uses a root [showGeneralDialog] so it is
/// visible above the home screen (including after demo scenarios).
class GoalXpHero extends StatefulWidget {
  final Stream<int> xpStream;
  final KidGoal? goal;
  final SecureKeyValueStore? celebrationStore;

  const GoalXpHero({
    super.key,
    required this.xpStream,
    this.goal,
    this.celebrationStore,
  });

  @override
  State<GoalXpHero> createState() => _GoalXpHeroState();
}

class _GoalXpHeroState extends State<GoalXpHero>
    with SingleTickerProviderStateMixin {
  late final AnimationController _potPulseCtrl;

  SecureKeyValueStore get _store =>
      widget.celebrationStore ?? FlutterSecureKeyValueStore();

  String? _celebratedKey;
  bool _celebrationLoaded = false;
  bool _celebrating = false;
  bool _celebrationQueued = false;
  int? _lastOverflow;
  int? _lastTotalXp;

  @override
  void initState() {
    super.initState();
    _potPulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );
    _loadCelebratedKey();
  }

  @override
  void didUpdateWidget(covariant GoalXpHero oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.goal?.updatedAt != widget.goal?.updatedAt) {
      _celebrating = false;
      _celebrationQueued = false;
      // New goal (or demo re-apply): allow celebration again for this identity.
      _lastTotalXp = null;
    }
  }

  Future<void> _loadCelebratedKey() async {
    try {
      final key = await _store.read(key: kGoalCelebratedStoreKey);
      if (!mounted) return;
      setState(() {
        _celebratedKey = key;
        _celebrationLoaded = true;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _celebratedKey = null;
        _celebrationLoaded = true;
      });
    }
  }

  Future<void> _runCelebration(KidGoal goal) async {
    if (!mounted || _celebrating) return;
    final key = goalCelebrationKey(goal);
    if (_celebratedKey == key) return;

    setState(() {
      _celebrating = true;
      _celebrationQueued = false;
    });

    // Brief beat so the progress bar can finish filling first.
    await Future<void>.delayed(const Duration(milliseconds: 550));
    if (!mounted) return;

    HapticFeedback.heavyImpact();

    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;

    try {
      await showGeneralDialog<void>(
        context: context,
        useRootNavigator: true,
        barrierDismissible: false,
        barrierLabel: l10n.goalReached,
        barrierColor: Colors.black.withValues(alpha: 0.55),
        transitionDuration: const Duration(milliseconds: 280),
        pageBuilder: (ctx, animation, secondaryAnimation) {
          return _GoalCelebrationDialog(
            label: l10n.goalReached,
            goalTitle: goal.title,
            scheme: scheme,
            onFinished: () {
              if (Navigator.of(ctx, rootNavigator: true).canPop()) {
                Navigator.of(ctx, rootNavigator: true).pop();
              }
            },
          );
        },
        transitionBuilder: (ctx, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      );
    } catch (_) {
      // Still mark celebrated so we don't loop on a broken dialog path.
    }

    try {
      await _store.write(key: kGoalCelebratedStoreKey, value: key);
    } catch (_) {}

    if (!mounted) return;
    setState(() {
      _celebratedKey = key;
      _celebrating = false;
    });
  }

  void _onXpTick(int totalXp, GoalXpBreakdown breakdown) {
    if (_lastOverflow != null &&
        breakdown.overflow > _lastOverflow! &&
        breakdown.overflow > 0) {
      _potPulseCtrl.forward(from: 0);
    }
    _lastOverflow = breakdown.overflow;

    final currentGoal = widget.goal;
    final previousXp = _lastTotalXp;

    final crossed = previousXp != null &&
        currentGoal != null &&
        currentGoal.targetXp > 0 &&
        previousXp < currentGoal.targetXp &&
        totalXp >= currentGoal.targetXp;
    final firstSeenReached = previousXp == null && breakdown.reached;
    _lastTotalXp = totalXp;

    if (!breakdown.reached ||
        currentGoal == null ||
        !_celebrationLoaded ||
        _celebrating ||
        _celebrationQueued) {
      return;
    }

    final key = goalCelebrationKey(currentGoal);
    if (_celebratedKey == key) return;

    if (crossed || firstSeenReached || _celebratedKey != key) {
      _celebrationQueued = true;
      // ignore: discarded_futures
      _runCelebration(currentGoal);
    }
  }

  @override
  void dispose() {
    _potPulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);

    return StreamBuilder<int>(
      stream: widget.xpStream,
      builder: (context, xpSnap) {
        // Avoid treating "no emission yet" as 0 XP (that breaks the bar/celebration).
        if (!xpSnap.hasData) {
          return _buildGoalCard(
            context,
            scheme,
            l10n,
            GoalXpBreakdown.from(totalXp: 0, goal: widget.goal),
            barValue: widget.goal != null ? 0 : null,
          );
        }

        final totalXp = xpSnap.data!;
        final breakdown = GoalXpBreakdown.from(
          totalXp: totalXp,
          goal: widget.goal,
        );
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          _onXpTick(totalXp, breakdown);
        });

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildGoalCard(
              context,
              scheme,
              l10n,
              breakdown,
              barValue: breakdown.progress,
            ),
            if (breakdown.overflow > 0) ...[
              const SizedBox(height: 10),
              _buildPot(context, scheme, l10n, breakdown.overflow),
            ],
          ],
        );
      },
    );
  }

  Widget _buildGoalCard(
    BuildContext context,
    ColorScheme scheme,
    AppLocalizations l10n,
    GoalXpBreakdown breakdown, {
    required double? barValue,
  }) {
    final goal = widget.goal;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: breakdown.reached
            ? scheme.primaryContainer.withValues(alpha: 0.35)
            : scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
        border: breakdown.reached
            ? Border.all(
                color: scheme.primary.withValues(alpha: 0.55),
                width: 2,
              )
            : null,
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: scheme.primary.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              breakdown.reached
                  ? Icons.emoji_events_rounded
                  : Icons.star_rounded,
              color: scheme.primary,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  goal != null
                      ? goal.title
                      : l10n.totalXp(breakdown.towardGoal),
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  goal != null
                      ? (breakdown.reached
                          ? l10n.goalReached
                          : l10n.goalProgress(
                              breakdown.towardGoal,
                              goal.targetXp,
                            ))
                      : l10n.keepGoing,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: breakdown.reached
                            ? scheme.primary
                            : scheme.onSurfaceVariant,
                        fontWeight: breakdown.reached
                            ? FontWeight.w700
                            : FontWeight.normal,
                      ),
                ),
                if (barValue != null) ...[
                  const SizedBox(height: 10),
                  TweenAnimationBuilder<double>(
                    // Remount when the target changes so we animate from the
                    // previous visual value instead of jumping or sticking.
                    key: ValueKey<double>(barValue),
                    tween: Tween<double>(
                      begin: (barValue - 0.25).clamp(0.0, 1.0),
                      end: barValue.clamp(0.0, 1.0),
                    ),
                    duration: const Duration(milliseconds: 700),
                    curve: Curves.easeOutCubic,
                    builder: (context, value, _) {
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: value,
                          minHeight: 10,
                          backgroundColor:
                              scheme.outline.withValues(alpha: 0.2),
                        ),
                      );
                    },
                  ),
                  if (goal != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      l10n.goalProgress(
                        breakdown.towardGoal,
                        goal.targetXp,
                      ),
                      style: Theme.of(context)
                          .textTheme
                          .labelSmall
                          ?.copyWith(color: scheme.onSurfaceVariant),
                    ),
                  ],
                ],
              ],
            ),
          ),
          Icon(
            Icons.military_tech_rounded,
            size: 44,
            color: scheme.primary.withValues(
              alpha: breakdown.reached ? 1.0 : 0.7,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPot(
    BuildContext context,
    ColorScheme scheme,
    AppLocalizations l10n,
    int overflow,
  ) {
    final scale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.1), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.1, end: 1.0), weight: 50),
    ]).animate(
      CurvedAnimation(parent: _potPulseCtrl, curve: Curves.easeOut),
    );

    return ScaleTransition(
      scale: scale,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: scheme.tertiaryContainer.withValues(alpha: 0.55),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: scheme.tertiary.withValues(alpha: 0.35),
          ),
        ),
        child: Row(
          children: [
            Icon(Icons.savings_rounded, color: scheme.tertiary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                l10n.bonusXpPot,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
            Text(
              l10n.bonusXpAmount(overflow),
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: scheme.tertiary,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GoalCelebrationDialog extends StatefulWidget {
  final String label;
  final String? goalTitle;
  final ColorScheme scheme;
  final VoidCallback onFinished;

  const _GoalCelebrationDialog({
    required this.label,
    required this.goalTitle,
    required this.scheme,
    required this.onFinished,
  });

  @override
  State<_GoalCelebrationDialog> createState() => _GoalCelebrationDialogState();
}

class _GoalCelebrationDialogState extends State<_GoalCelebrationDialog>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          widget.onFinished();
        }
      });
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  double _opacity(double t) {
    if (t < 0.08) return t / 0.08;
    if (t > 0.82) return (1.0 - t) / 0.18;
    return 1.0;
  }

  double _scale(double t) {
    if (t < 0.2) {
      return 0.55 + Curves.elasticOut.transform(t / 0.2) * 0.55;
    }
    return 1.05;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = widget.scheme;
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, _) {
        final t = _ctrl.value;
        final opacity = _opacity(t);
        return Material(
          type: MaterialType.transparency,
          child: Stack(
            fit: StackFit.expand,
            children: [
              CustomPaint(
                painter: _ConfettiPainter(
                  progress: t,
                  primary: scheme.primary,
                  secondary: scheme.tertiary,
                ),
              ),
              Center(
                child: Opacity(
                  opacity: opacity,
                  child: Transform.scale(
                    scale: _scale(t),
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 32),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 28,
                        vertical: 24,
                      ),
                      decoration: BoxDecoration(
                        color: scheme.primaryContainer,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: scheme.primary.withValues(alpha: 0.45),
                            blurRadius: 28,
                            spreadRadius: 4,
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.emoji_events_rounded,
                            size: 64,
                            color: scheme.primary,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            widget.label,
                            textAlign: TextAlign.center,
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: scheme.onPrimaryContainer,
                                ),
                          ),
                          if (widget.goalTitle != null &&
                              widget.goalTitle!.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Text(
                              widget.goalTitle!,
                              textAlign: TextAlign.center,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    color: scheme.onPrimaryContainer
                                        .withValues(alpha: 0.85),
                                  ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ConfettiPainter extends CustomPainter {
  final double progress;
  final Color primary;
  final Color secondary;

  _ConfettiPainter({
    required this.progress,
    required this.primary,
    required this.secondary,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;
    final rng = math.Random(42);
    final origin = Offset(size.width / 2, size.height * 0.42);
    final fade = progress < 0.75 ? 1.0 : ((1.0 - progress) / 0.25).clamp(0.0, 1.0);

    for (var i = 0; i < 72; i++) {
      final angle = (i / 72) * math.pi * 2 + rng.nextDouble() * 0.5;
      final speed = 80 + rng.nextDouble() * (size.shortestSide * 0.55);
      final travel = Curves.easeOut.transform(progress.clamp(0.0, 1.0));
      final dx = math.cos(angle) * speed * travel;
      final dy =
          math.sin(angle) * speed * travel + size.height * 0.25 * travel * travel;
      final pos = origin + Offset(dx, dy);
      final paint = Paint()
        ..color = (i.isEven ? primary : secondary).withValues(alpha: fade)
        ..style = PaintingStyle.fill;
      final w = 5.0 + rng.nextDouble() * 7;
      final h = 4.0 + rng.nextDouble() * 5;
      canvas.save();
      canvas.translate(pos.dx, pos.dy);
      canvas.rotate(angle + progress * 8);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset.zero, width: w, height: h),
          const Radius.circular(1.5),
        ),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.primary != primary ||
      oldDelegate.secondary != secondary;
}
