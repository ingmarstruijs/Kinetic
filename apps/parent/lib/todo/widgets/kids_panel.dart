import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kinetic_webdav/kinetic_webdav.dart';

import '../../l10n/generated/app_localizations.dart';
import '../../settings/models/enrolled_kid.dart';
import '../../sync/webdav_config_repository.dart';
import '../services/todo_repository.dart';

const _kidPalette = [
  Color(0xFF5B8DEF),
  Color(0xFFE07A9A),
  Color(0xFF5BAF8A),
  Color(0xFFE0A84A),
  Color(0xFF7B6FE0),
];

Color kidAvatarColor(String name) =>
    _kidPalette[name.hashCode.abs() % _kidPalette.length];

String kidInitials(String name) {
  final parts = name.trim().split(RegExp(r'\s+'));
  if (parts.isEmpty || parts.first.isEmpty) return '?';
  if (parts.length == 1) return parts.first[0].toUpperCase();
  final a = parts.first[0];
  final b = parts.last[0];
  return '${a.toUpperCase()}${b.toUpperCase()}';
}

String? icalProp(String? desc, String key) {
  if (desc == null || desc.isEmpty) return null;
  return RegExp('$key:([^;]+)').firstMatch(desc)?.group(1);
}

class KidTaskGroup {
  final String key;
  final String name;
  final List<ICalTask> tasks;
  final int xp;
  final KidGoal? goal;

  const KidTaskGroup({
    required this.key,
    required this.name,
    required this.tasks,
    required this.xp,
    this.goal,
  });

  int get openCount =>
      tasks.where((t) => t.status == ICalTaskStatus.needsAction).length;

  int get pendingCount =>
      tasks.where((t) => t.status == ICalTaskStatus.inProcess).length;

  int get displayXp {
    if (goal == null || goal!.targetXp <= 0) return xp;
    return xp > goal!.targetXp ? goal!.targetXp : xp;
  }
}

List<KidTaskGroup> groupKidsTasks({
  required List<ICalTask> tasks,
  required List<EnrolledKid> enrolledKids,
  required String everyoneLabel,
  Map<String, KidGoal> goals = const {},
}) {
  final xpPerKid = <String, int>{};
  final grouped = <String, List<ICalTask>>{};
  final enrolledIds = enrolledKids.map((k) => k.id).toSet();
  final soleKidId = enrolledKids.length == 1 ? enrolledKids.first.id : null;

  for (final task in tasks) {
    final targetId = icalProp(task.description, 'xKineticTargetKidId');
    String key;
    if (targetId != null &&
        targetId.isNotEmpty &&
        enrolledIds.contains(targetId)) {
      key = targetId;
    } else if (soleKidId != null) {
      // One enrolled kid: show shared/"everyone" tasks on that kid's card.
      key = soleKidId;
    } else {
      key = '__everyone__';
    }
    grouped.putIfAbsent(key, () => []).add(task);
    if (task.status == ICalTaskStatus.completed) {
      final xp =
          int.tryParse(icalProp(task.description, 'xKineticXpReward') ?? '') ??
          0;
      xpPerKid[key] = (xpPerKid[key] ?? 0) + xp;
    }
  }

  final groups = <KidTaskGroup>[];
  for (final kid in enrolledKids) {
    groups.add(
      KidTaskGroup(
        key: kid.id,
        name: kid.name,
        tasks: grouped[kid.id] ?? const [],
        xp: xpPerKid[kid.id] ?? 0,
        goal: goals[kid.id],
      ),
    );
  }
  if (grouped.containsKey('__everyone__')) {
    groups.add(
      KidTaskGroup(
        key: '__everyone__',
        name: everyoneLabel,
        tasks: grouped['__everyone__']!,
        xp: xpPerKid['__everyone__'] ?? 0,
      ),
    );
  }
  return groups;
}

class KidsPanel extends StatefulWidget {
  final WebDavConfigRepository configRepo;
  final SyncConfig? syncConfig;
  final Future<List<ICalTask>> Function()? pullSharedTasks;
  final List<EnrolledKid>? enrolledKidsOverride;
  final TodoRepository? todoRepo;
  final Future<void> Function(ICalTask task)? onDeleteKidTask;
  final Future<void> Function(ICalTask task)? onAcceptKidTask;
  final Future<void> Function(ICalTask task)? onRejectKidTask;

  const KidsPanel({
    super.key,
    required this.configRepo,
    this.syncConfig,
    this.pullSharedTasks,
    this.enrolledKidsOverride,
    this.todoRepo,
    this.onDeleteKidTask,
    this.onAcceptKidTask,
    this.onRejectKidTask,
  });

  @override
  State<KidsPanel> createState() => KidsPanelState();
}

class KidsPanelState extends State<KidsPanel> {
  late Future<_KidsPanelData> _future;
  bool _expanded = true;
  String? _filterKey;
  String? _openKidKey;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  @override
  void didUpdateWidget(KidsPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.syncConfig != widget.syncConfig ||
        oldWidget.enrolledKidsOverride != widget.enrolledKidsOverride ||
        oldWidget.pullSharedTasks != widget.pullSharedTasks) {
      _future = _load();
    }
  }

  void reload() {
    final next = _load();
    setState(() {
      _future = next;
    });
  }

  Future<_KidsPanelData> _load() async {
    final enrolledKids =
        widget.enrolledKidsOverride ??
        await widget.configRepo.loadEnrolledKids();
    if (widget.pullSharedTasks != null) {
      final tasks = await widget.pullSharedTasks!();
      return _KidsPanelData(
        tasks: tasks,
        enrolledKids: enrolledKids,
        goals: const {},
      );
    }
    final config = widget.syncConfig;
    if (config == null) {
      return _KidsPanelData(
        tasks: const [],
        enrolledKids: enrolledKids,
        goals: const {},
      );
    }
    final client = WebDavClient(
      baseUrl: config.baseUrl,
      username: config.username,
      password: config.password,
    );
    final service = WebDavSyncService(client: client, config: config);
    try {
      final tasks = await service.pullSharedTasks();
      final goals = await service.pullGoals(enrolledKids.map((k) => k.id));
      return _KidsPanelData(
        tasks: tasks,
        enrolledKids: enrolledKids,
        goals: goals,
      );
    } finally {
      client.dispose();
    }
  }

  Future<T?> _withService<T>(
    Future<T> Function(WebDavSyncService service) action,
  ) async {
    final config = widget.syncConfig;
    if (config == null) return null;
    final client = WebDavClient(
      baseUrl: config.baseUrl,
      username: config.username,
      password: config.password,
    );
    final service = WebDavSyncService(client: client, config: config);
    try {
      return await action(service);
    } finally {
      client.dispose();
    }
  }

  Future<void> _resetXpAndGoal(KidTaskGroup group) async {
    if (group.key == '__everyone__' || !mounted) return;
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.kidsGoalResetTitle(group.name)),
        content: Text(l10n.kidsGoalResetBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.commonCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.tasksXpResetAction),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    try {
      await _withService((service) async {
        await service.pushXpReset(group.key, DateTime.now().toUtc());
        for (final task in group.tasks) {
          if (task.status == ICalTaskStatus.completed) {
            await service.deleteSharedTask(task.uid);
            await widget.todoRepo?.removeKidsAssignment(
              kidsTaskId: task.uid,
              parentTaskId: icalProp(task.description, 'xKineticParentId'),
            );
          }
        }
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.kidsGoalResetDone(group.name))),
        );
        reload();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.tasksXpResetError('$e'))),
        );
      }
    }
  }

  Future<void> _editGoal(KidTaskGroup group, {bool renameOnly = false}) async {
    if (group.key == '__everyone__' || !mounted) return;
    final l10n = AppLocalizations.of(context);
    final titleCtrl = TextEditingController(text: group.goal?.title ?? '');
    final xpCtrl = TextEditingController(
      text: group.goal != null ? '${group.goal!.targetXp}' : '100',
    );
    final saved = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          group.goal == null
              ? l10n.kidsGoalSet
              : (renameOnly ? l10n.kidsGoalRename : l10n.kidsGoalEdit),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleCtrl,
              decoration: InputDecoration(
                labelText: l10n.kidsGoalTitleLabel,
                hintText: l10n.kidsGoalTitleHint,
              ),
              textCapitalization: TextCapitalization.sentences,
            ),
            if (!renameOnly) ...[
              const SizedBox(height: 12),
              TextField(
                controller: xpCtrl,
                decoration: InputDecoration(
                  labelText: l10n.kidsGoalTargetLabel,
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.commonCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.kidsGoalSave),
          ),
        ],
      ),
    );
    if (saved != true || !mounted) return;
    final title = titleCtrl.text.trim();
    final target = renameOnly
        ? (group.goal?.targetXp ?? 100)
        : (int.tryParse(xpCtrl.text.trim()) ?? 0);
    if (title.isEmpty || target <= 0) return;

    try {
      await _withService(
        (service) => service.pushGoal(
          KidGoal(
            kidId: group.key,
            title: title,
            targetXp: target,
            updatedAt: DateTime.now().toUtc(),
          ),
        ),
      );
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.kidsGoalSaved)));
        reload();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('$e')));
      }
    }
  }

  Future<void> _removeGoal(KidTaskGroup group) async {
    if (group.key == '__everyone__' || group.goal == null) return;
    final l10n = AppLocalizations.of(context);
    try {
      await _withService((service) => service.deleteGoal(group.key));
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.kidsGoalRemoved)));
        reload();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('$e')));
      }
    }
  }

  bool get _canDeleteKidTask =>
      widget.onDeleteKidTask != null || widget.syncConfig != null;

  Future<void> _deleteKidTask(ICalTask task) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.kidsDeleteTaskTitle),
        content: Text(l10n.kidsDeleteTaskBody(task.summary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.commonCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.commonDelete),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    try {
      if (widget.onDeleteKidTask != null) {
        await widget.onDeleteKidTask!(task);
      } else {
        await _withService((service) => service.deleteSharedTask(task.uid));
      }
      await widget.todoRepo?.removeKidsAssignment(
        kidsTaskId: task.uid,
        parentTaskId: icalProp(task.description, 'xKineticParentId'),
      );
      if (mounted) reload();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.commonDeleteError('$e'))));
      }
    }
  }

  Future<void> _accept(ICalTask task) async {
    try {
      if (widget.onAcceptKidTask != null) {
        await widget.onAcceptKidTask!(task);
      } else {
        await _withService((service) async {
          await service.pushSharedTask(
            task.copyWith(
              status: ICalTaskStatus.completed,
              updatedAt: DateTime.now().toUtc(),
            ),
          );
        });
        await widget.todoRepo?.completeByKidsTaskId(task.uid);
      }
      if (mounted) reload();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('$e')));
      }
    }
  }

  Future<void> _reject(ICalTask task) async {
    try {
      if (widget.onRejectKidTask != null) {
        await widget.onRejectKidTask!(task);
      } else {
        await _withService((service) async {
          await service.pushSharedTask(
            task.copyWith(
              status: ICalTaskStatus.needsAction,
              updatedAt: DateTime.now().toUtc(),
            ),
          );
        });
      }
      if (mounted) reload();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('$e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return FutureBuilder<_KidsPanelData>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting &&
            !snapshot.hasData) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(l10n.tasksLoadKidsError),
                TextButton.icon(
                  icon: const Icon(Icons.refresh),
                  label: Text(l10n.commonRetry),
                  onPressed: reload,
                ),
              ],
            ),
          );
        }

        final data = snapshot.data;
        if (data == null) return const SizedBox.shrink();

        final groups = groupKidsTasks(
          tasks: data.tasks,
          enrolledKids: data.enrolledKids,
          everyoneLabel: l10n.commonEveryone,
          goals: data.goals,
        );
        final visible = _filterKey == null
            ? groups
            : groups.where((g) => g.key == _filterKey).toList();

        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              InkWell(
                onTap: () => setState(() => _expanded = !_expanded),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Icon(
                        Icons.people_outline,
                        size: 18,
                        color: scheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        l10n.kidsSectionTitle.toUpperCase(),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: scheme.primary,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.1,
                        ),
                      ),
                      const Spacer(),
                      Icon(
                        _expanded ? Icons.expand_less : Icons.expand_more,
                        color: scheme.outline,
                      ),
                    ],
                  ),
                ),
              ),
              if (_expanded) ...[
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _KidChip(
                        selected: _filterKey == null,
                        label: l10n.kidsAllFilter,
                        onTap: () => setState(() {
                          _filterKey = null;
                          _openKidKey = null;
                        }),
                      ),
                      for (final kid in data.enrolledKids) ...[
                        const SizedBox(width: 8),
                        _KidChip(
                          selected: _filterKey == kid.id,
                          label: kid.name,
                          color: kidAvatarColor(kid.name),
                          initials: kidInitials(kid.name),
                          onTap: () => setState(() {
                            _filterKey = kid.id;
                            _openKidKey = kid.id;
                          }),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                if (visible.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      l10n.tasksNoKidsAssignments,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  )
                else
                  for (final group in visible)
                    _KidGroupCard(
                      group: group,
                      expanded: _openKidKey == group.key,
                      onToggle: () => setState(() {
                        _openKidKey = _openKidKey == group.key
                            ? null
                            : group.key;
                      }),
                      onSetGoal: group.key == '__everyone__'
                          ? null
                          : () => _editGoal(group),
                      onRenameGoal: group.goal == null
                          ? null
                          : () => _editGoal(group, renameOnly: true),
                      onRemoveGoal:
                          group.goal == null ? null : () => _removeGoal(group),
                      onResetGoal: group.key == '__everyone__'
                          ? null
                          : () => _resetXpAndGoal(group),
                      onDeleteTask: _canDeleteKidTask ? _deleteKidTask : null,
                      onAccept: _accept,
                      onReject: _reject,
                    ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _KidsPanelData {
  final List<ICalTask> tasks;
  final List<EnrolledKid> enrolledKids;
  final Map<String, KidGoal> goals;
  const _KidsPanelData({
    required this.tasks,
    required this.enrolledKids,
    required this.goals,
  });
}

class _KidChip extends StatelessWidget {
  final bool selected;
  final String label;
  final Color? color;
  final String? initials;
  final VoidCallback onTap;

  const _KidChip({
    required this.selected,
    required this.label,
    required this.onTap,
    this.color,
    this.initials,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return FilterChip(
      selected: selected,
      showCheckmark: initials == null,
      avatar: initials == null
          ? null
          : CircleAvatar(
              backgroundColor: color ?? scheme.primary,
              foregroundColor: Colors.white,
              child: Text(
                initials!,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
      label: Text(label),
      onSelected: (_) => onTap(),
      selectedColor: scheme.primaryContainer,
      backgroundColor: scheme.surfaceContainerHighest,
      shape: const StadiumBorder(),
    );
  }
}

class _KidGroupCard extends StatelessWidget {
  final KidTaskGroup group;
  final bool expanded;
  final VoidCallback onToggle;
  final VoidCallback? onSetGoal;
  final VoidCallback? onRenameGoal;
  final VoidCallback? onRemoveGoal;
  final VoidCallback? onResetGoal;
  final Future<void> Function(ICalTask task)? onDeleteTask;
  final Future<void> Function(ICalTask task)? onAccept;
  final Future<void> Function(ICalTask task)? onReject;

  const _KidGroupCard({
    required this.group,
    required this.expanded,
    required this.onToggle,
    this.onSetGoal,
    this.onRenameGoal,
    this.onRemoveGoal,
    this.onResetGoal,
    this.onDeleteTask,
    this.onAccept,
    this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final open = group.tasks.where((t) => t.status != ICalTaskStatus.completed);
    final goal = group.goal;
    final progress = goal != null && goal.targetXp > 0
        ? (group.displayXp / goal.targetXp).clamp(0.0, 1.0)
        : null;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: onToggle,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: kidAvatarColor(group.name),
                      foregroundColor: Colors.white,
                      child: Text(
                        kidInitials(group.name),
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            group.name,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            l10n.kidsOpenTasks(group.openCount),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                          if (goal != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              goal.title,
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: scheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: progress,
                                minHeight: 6,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              l10n.kidsXpProgress(
                                group.displayXp,
                                goal.targetXp,
                              ),
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: scheme.onSurfaceVariant,
                              ),
                            ),
                          ] else
                            Text(
                              l10n.kidsXpTotal(group.displayXp),
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: scheme.onSurfaceVariant,
                              ),
                            ),
                          if (group.pendingCount > 0)
                            Text(
                              expanded
                                  ? l10n.kidsPendingVerification
                                  : l10n.kidsPendingExpandHint(
                                      group.pendingCount,
                                    ),
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: scheme.tertiary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                        ],
                      ),
                    ),
                    if (onSetGoal != null || onResetGoal != null)
                      PopupMenuButton<String>(
                        icon: Icon(
                          Icons.more_horiz,
                          color: scheme.outline,
                          size: 20,
                        ),
                        onSelected: (value) {
                          switch (value) {
                            case 'set':
                              onSetGoal?.call();
                            case 'rename':
                              onRenameGoal?.call();
                            case 'remove':
                              onRemoveGoal?.call();
                            case 'reset':
                              onResetGoal?.call();
                          }
                        },
                        itemBuilder: (ctx) => [
                          if (onSetGoal != null)
                            PopupMenuItem(
                              value: 'set',
                              child: Text(
                                goal == null
                                    ? l10n.kidsGoalSet
                                    : l10n.kidsGoalEdit,
                              ),
                            ),
                          if (onRenameGoal != null)
                            PopupMenuItem(
                              value: 'rename',
                              child: Text(l10n.kidsGoalRename),
                            ),
                          if (onRemoveGoal != null)
                            PopupMenuItem(
                              value: 'remove',
                              child: Text(l10n.kidsGoalRemove),
                            ),
                          if (onResetGoal != null)
                            PopupMenuItem(
                              value: 'reset',
                              child: Text(l10n.kidsGoalReset),
                            ),
                        ],
                      ),
                    Icon(
                      expanded ? Icons.expand_less : Icons.chevron_right,
                      color: scheme.outline,
                    ),
                  ],
                ),
              ),
            ),
            if (expanded)
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (open.isEmpty)
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          l10n.tasksNoKidsAssignments,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      )
                    else
                      for (final task in open)
                        _KidsTaskTile(
                          task: task,
                          onDelete: onDeleteTask,
                          onAccept: onAccept,
                          onReject: onReject,
                        ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _KidsTaskTile extends StatelessWidget {
  final ICalTask task;
  final Future<void> Function(ICalTask task)? onDelete;
  final Future<void> Function(ICalTask task)? onAccept;
  final Future<void> Function(ICalTask task)? onReject;

  const _KidsTaskTile({
    required this.task,
    this.onDelete,
    this.onAccept,
    this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final due = task.dueAt;
    final pending = task.status == ICalTaskStatus.inProcess;
    final subtitleParts = [
      if (pending) l10n.kidsPendingVerification,
      if (due != null) '${due.toLocal().day}/${due.toLocal().month}',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ListTile(
          dense: true,
          contentPadding: EdgeInsets.zero,
          leading: Icon(
            pending
                ? Icons.hourglass_top_rounded
                : Icons.hourglass_empty_rounded,
            color: pending ? scheme.tertiary : scheme.outline,
          ),
          title: Text(task.summary),
          subtitle: subtitleParts.isEmpty
              ? null
              : Text(
                  subtitleParts.join(' · '),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
          trailing: onDelete == null
              ? null
              : IconButton(
                  tooltip: l10n.commonDelete,
                  icon: Icon(Icons.delete_outline, color: scheme.outline),
                  onPressed: () => onDelete!(task),
                ),
        ),
        if (pending)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                TextButton(
                  onPressed: onReject == null ? null : () => onReject!(task),
                  child: Text(l10n.kidsRejectCompletion),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: onAccept == null ? null : () => onAccept!(task),
                  child: Text(l10n.kidsAcceptCompletion),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
