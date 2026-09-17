import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kinetic_webdav/kinetic_webdav.dart';

import '../../db/app_database.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../sync/sync_orchestrator.dart';
import '../../theme/app_header.dart';
import '../models/kids_task.dart';
import '../services/kids_task_repository.dart';
import 'kids_task_detail_screen.dart';

class KidsHomeScreen extends StatefulWidget {
  final AppDatabase appDb;
  final KidsTaskRepository? repository;
  final KidsSyncOrchestrator? orchestrator;
  final VoidCallback? onLeaveFamily;
  final DateTime? xpResetAt;
  final KidGoal? goal;
  final VoidCallback? onLoadDemo;
  final VoidCallback? onOpenSettings;

  const KidsHomeScreen({
    super.key,
    required this.appDb,
    this.repository,
    this.orchestrator,
    this.onLeaveFamily,
    this.xpResetAt,
    this.goal,
    this.onLoadDemo,
    this.onOpenSettings,
  });

  @override
  State<KidsHomeScreen> createState() => _KidsHomeScreenState();
}

class _KidsHomeScreenState extends State<KidsHomeScreen> {
  late KidsTaskRepository _taskRepository;
  bool _syncing = false;

  @override
  void initState() {
    super.initState();
    _taskRepository = widget.repository ?? KidsTaskRepository(db: widget.appDb);
  }

  Future<void> _sync() async {
    if (_syncing || widget.orchestrator == null) return;
    setState(() => _syncing = true);
    try {
      await widget.orchestrator!.sync();
    } finally {
      if (mounted) setState(() => _syncing = false);
    }
  }

  Future<void> _requestComplete(KidsTask task) async {
    if (task.awaitingVerification || task.isCompleted) return;
    final l10n = AppLocalizations.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.confirmCompleteTitle),
        content: Text(l10n.confirmCompleteBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.confirmCompleteAction),
          ),
        ],
      ),
    );
    if (ok == true) {
      await _taskRepository.requestComplete(task.id);
      await widget.orchestrator?.sync();
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const AppHeaderKids(),
        actions: [
          if (widget.orchestrator != null) ...[
            if (_syncing)
              const Padding(
                padding: EdgeInsets.only(right: 8),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              )
            else
              IconButton(
                icon: const Icon(Icons.sync),
                onPressed: _sync,
                tooltip: l10n.sync,
              ),
          ],
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'settings') widget.onOpenSettings?.call();
              if (value == 'leave') widget.onLeaveFamily?.call();
              if (value == 'demo') widget.onLoadDemo?.call();
            },
            itemBuilder: (_) => [
              if (widget.onOpenSettings != null)
                PopupMenuItem(
                  value: 'settings',
                  child: Row(
                    children: [
                      const Icon(Icons.settings_outlined, size: 18),
                      const SizedBox(width: 8),
                      Text(l10n.settings),
                    ],
                  ),
                ),
              if (widget.onLoadDemo != null)
                PopupMenuItem(
                  value: 'demo',
                  child: Row(
                    children: [
                      const Icon(Icons.movie_filter_outlined, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        Localizations.localeOf(context).languageCode == 'nl'
                            ? 'Laad demo-klusjes'
                            : 'Load demo chores',
                      ),
                    ],
                  ),
                ),
              if (widget.onLeaveFamily != null)
                PopupMenuItem(
                  value: 'leave',
                  child: Row(
                    children: [
                      const Icon(Icons.logout, size: 18),
                      const SizedBox(width: 8),
                      Text(l10n.leaveFamily),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
      body: StreamBuilder<List<KidsTask>>(
        stream: _taskRepository.watchAll(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text(l10n.errorWithDetails(snapshot.error!)));
          }

          final tasks = snapshot.data ?? [];
          final openTasks = tasks.where((t) => t.isOpen).toList();
          final pendingTasks =
              tasks.where((t) => t.awaitingVerification).toList();
          final completedTasks = tasks.where((t) => t.isCompleted).toList();

          final xpHeader = StreamBuilder<int>(
            stream: _taskRepository.watchTotalXp(resetAt: widget.xpResetAt),
            builder: (context, xpSnap) {
              final totalXp = xpSnap.data ?? 0;
              final goal = widget.goal;
              final capped = goal != null && goal.targetXp > 0
                  ? (totalXp > goal.targetXp ? goal.targetXp : totalXp)
                  : totalXp;
              final progress = goal != null && goal.targetXp > 0
                  ? (capped / goal.targetXp).clamp(0.0, 1.0)
                  : null;

              return Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: scheme.primary.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.star_rounded, color: scheme.primary),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            goal != null
                                ? goal.title
                                : l10n.totalXp(capped),
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            goal != null
                                ? l10n.goalProgress(capped, goal.targetXp)
                                : l10n.keepGoing,
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: scheme.onSurfaceVariant),
                          ),
                          if (progress != null) ...[
                            const SizedBox(height: 10),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: LinearProgressIndicator(
                                value: progress,
                                minHeight: 8,
                                backgroundColor:
                                    scheme.outline.withValues(alpha: 0.2),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    Icon(
                      Icons.military_tech_rounded,
                      size: 40,
                      color: scheme.primary.withValues(alpha: 0.7),
                    ),
                  ],
                ),
              );
            },
          );

          if (tasks.isEmpty) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  xpHeader,
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.celebration,
                            size: 64,
                            color: scheme.primary,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            l10n.allDone,
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            l10n.noTasksRightNow,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(color: scheme.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              xpHeader,
              if (openTasks.isNotEmpty) ...[
                Row(
                  children: [
                    Text(
                      l10n.stillToDo,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: scheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text('${openTasks.length}'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ...openTasks.map((task) => _buildTaskCard(context, task)),
                const SizedBox(height: 20),
              ],
              if (pendingTasks.isNotEmpty) ...[
                Text(
                  l10n.waitingForParent,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                ...pendingTasks.map((task) => _buildTaskCard(context, task)),
                const SizedBox(height: 20),
              ],
              if (completedTasks.isNotEmpty) ...[
                Text(
                  l10n.completed,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                ...completedTasks.map((task) => _buildTaskCard(context, task)),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _buildTaskCard(BuildContext context, KidsTask task) {
    final scheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);
    final priorityColor = _getPriorityColor(scheme, task.priority);
    final pending = task.awaitingVerification;
    final done = task.isCompleted;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        leading: pending
            ? Icon(Icons.hourglass_top_rounded, color: scheme.tertiary)
            : Checkbox(
                value: done,
                onChanged: done ? null : (_) => _requestComplete(task),
              ),
        title: Text(
          task.title,
          style: done
              ? TextStyle(
                  decoration: TextDecoration.lineThrough,
                  color: scheme.onSurfaceVariant,
                )
              : null,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (pending)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  l10n.awaitingParentConfirm,
                  style: TextStyle(
                    color: scheme.tertiary,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: priorityColor.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _priorityLabel(l10n, task.priority),
                      style: TextStyle(
                        fontSize: 11,
                        color: priorityColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  if (task.dueDate != null) ...[
                    const SizedBox(width: 8),
                    Text(
                      _formatDueDate(l10n, task.dueDate!),
                      style: TextStyle(
                        fontSize: 11,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              decoration: BoxDecoration(
                color: scheme.primary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.star_rounded, size: 14, color: scheme.primary),
                  const SizedBox(width: 4),
                  Text(
                    '${task.xpReward} XP',
                    style: TextStyle(
                      color: scheme.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: scheme.outline),
          ],
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => KidsTaskDetailScreen(
                repository: _taskRepository,
                taskId: task.id,
                onRequestComplete: () => _requestComplete(task),
              ),
            ),
          );
        },
      ),
    );
  }

  Color _getPriorityColor(ColorScheme scheme, TaskPriority priority) {
    return switch (priority) {
      TaskPriority.urgent => Colors.red,
      TaskPriority.high => Colors.deepOrange,
      TaskPriority.normal => scheme.primary,
      TaskPriority.low => Colors.green,
    };
  }

  String _priorityLabel(AppLocalizations l10n, TaskPriority priority) {
    return switch (priority) {
      TaskPriority.urgent => l10n.priorityUrgent,
      TaskPriority.high => l10n.priorityHigh,
      TaskPriority.normal => l10n.priorityNormal,
      TaskPriority.low => l10n.priorityLow,
    };
  }

  String _formatDueDate(AppLocalizations l10n, DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final dueDay = DateTime(date.year, date.month, date.day);

    if (dueDay == today) {
      return l10n.today;
    } else if (dueDay == tomorrow) {
      return l10n.tomorrow;
    } else if (dueDay.isBefore(today)) {
      return l10n.overdue;
    } else {
      return DateFormat.Md().format(dueDay);
    }
  }
}
