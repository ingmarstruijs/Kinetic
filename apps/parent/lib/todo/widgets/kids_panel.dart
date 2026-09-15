import 'package:flutter/material.dart';
import 'package:kinetic_webdav/kinetic_webdav.dart';

import '../../l10n/generated/app_localizations.dart';
import '../../settings/models/enrolled_kid.dart';
import '../../sync/webdav_config_repository.dart';

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

  const KidTaskGroup({
    required this.key,
    required this.name,
    required this.tasks,
    required this.xp,
  });

  int get openCount =>
      tasks.where((t) => t.status != ICalTaskStatus.completed).length;
}

List<KidTaskGroup> groupKidsTasks({
  required List<ICalTask> tasks,
  required List<EnrolledKid> enrolledKids,
  required String everyoneLabel,
}) {
  final xpPerKid = <String, int>{};
  final grouped = <String, List<ICalTask>>{};

  for (final task in tasks) {
    final targetId = icalProp(task.description, 'xKineticTargetKidId');
    final key = (targetId == null || targetId.isEmpty)
        ? '__everyone__'
        : targetId;
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
  final SyncConfig syncConfig;

  const KidsPanel({
    super.key,
    required this.configRepo,
    required this.syncConfig,
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
    if (oldWidget.syncConfig != widget.syncConfig) {
      _future = _load();
    }
  }

  void reload() => setState(() => _future = _load());

  Future<_KidsPanelData> _load() async {
    final enrolledKids = await widget.configRepo.loadEnrolledKids();
    final client = WebDavClient(
      baseUrl: widget.syncConfig.baseUrl,
      username: widget.syncConfig.username,
      password: widget.syncConfig.password,
    );
    final service = WebDavSyncService(
      client: client,
      config: widget.syncConfig,
    );
    try {
      final tasks = await service.pullSharedTasks();
      return _KidsPanelData(tasks: tasks, enrolledKids: enrolledKids);
    } finally {
      client.dispose();
    }
  }

  Future<void> _resetXp(String kidLabel, List<EnrolledKid> enrolledKids) async {
    final kid = enrolledKids.cast<EnrolledKid?>().firstWhere(
      (k) => k?.name == kidLabel,
      orElse: () => null,
    );
    if (kid == null || !mounted) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppLocalizations.of(context).tasksXpResetTitle(kid.name)),
        content: Text(AppLocalizations.of(context).tasksXpResetBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(AppLocalizations.of(context).commonCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(AppLocalizations.of(context).tasksXpResetAction),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    final client = WebDavClient(
      baseUrl: widget.syncConfig.baseUrl,
      username: widget.syncConfig.username,
      password: widget.syncConfig.password,
    );
    final service = WebDavSyncService(
      client: client,
      config: widget.syncConfig,
    );
    try {
      await service.pushXpReset(kid.id, DateTime.now().toUtc());
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context).tasksXpResetDone(kid.name),
            ),
          ),
        );
        reload();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).tasksXpResetError('$e')),
          ),
        );
      }
    } finally {
      client.dispose();
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
        );
        final visible = _filterKey == null
            ? groups
            : groups.where((g) => g.key == _filterKey).toList();

        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
          child: Column(
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
                      onResetXp: group.key == '__everyone__'
                          ? null
                          : () => _resetXp(group.name, data.enrolledKids),
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
  const _KidsPanelData({required this.tasks, required this.enrolledKids});
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
  final VoidCallback? onResetXp;

  const _KidGroupCard({
    required this.group,
    required this.expanded,
    required this.onToggle,
    this.onResetXp,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final open = group.tasks.where((t) => t.status != ICalTaskStatus.completed);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        child: Column(
          children: [
            InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: onToggle,
              onLongPress: onResetXp,
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
                        ],
                      ),
                    ),
                    if (onResetXp != null)
                      PopupMenuButton<String>(
                        icon: Icon(
                          Icons.more_horiz,
                          color: scheme.outline,
                          size: 20,
                        ),
                        onSelected: (value) {
                          if (value == 'xp') onResetXp?.call();
                        },
                        itemBuilder: (ctx) => [
                          PopupMenuItem(
                            value: 'xp',
                            child: Text(l10n.tasksResetXp),
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
                      for (final task in open) _KidsTaskTile(task: task),
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
  const _KidsTaskTile({required this.task});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final due = task.dueAt;

    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      leading: Icon(Icons.hourglass_empty_rounded, color: scheme.outline),
      title: Text(task.summary),
      subtitle: due == null
          ? null
          : Text(
              '${due.toLocal().day}/${due.toLocal().month}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
    );
  }
}
