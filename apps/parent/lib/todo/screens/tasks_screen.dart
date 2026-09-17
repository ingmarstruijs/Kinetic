import 'package:flutter/material.dart';
import '../../l10n/generated/app_localizations.dart';
import 'package:kinetic_webdav/kinetic_webdav.dart';

import '../../main.dart';
import '../../partner/services/partner_proposal_repository.dart';
import '../../settings/models/enrolled_kid.dart';
import '../../settings/settings_repository.dart';
import '../../sync/webdav_config_repository.dart';
import '../../theme/app_header.dart';
import '../../todo/models/personal_task.dart';
import '../../todo/services/ai_suggestion_repository.dart';
import '../../todo/services/todo_repository.dart';
import '../../todo/widgets/kids_panel.dart';
import '../../todo/widgets/quick_add_bar.dart';
import '../../todo/widgets/suggestions_panel.dart';
import '../../todo/widgets/task_detail_sheet.dart';
import '../../todo/widgets/task_tile.dart';

class TasksScreen extends StatefulWidget {
  final TodoRepository repo;
  final SettingsRepository? settingsRepo;
  final PartnerProposalRepository? proposalRepo;
  final AiSuggestionRepository? suggestionRepo;
  final String? myParentId;
  final ValueNotifier<SyncStatus>? syncStatus;
  final bool hasFamilyKey;
  final bool partnerPaired;
  final VoidCallback? onSyncRetry;
  final WebDavConfigRepository? configRepo;
  final int enrolledKidsCount;
  final ValueNotifier<int>? syncDoneCount;
  final SyncConfig? syncConfig;
  final Future<List<PresenceInfo>> Function()? pullPresence;
  final Future<List<ICalTask>> Function()? pullSharedTasks;
  final List<EnrolledKid>? enrolledKidsOverride;
  final Future<void> Function(ICalTask task)? onDeleteKidTask;
  final Future<void> Function(ICalTask task)? onAcceptKidTask;
  final Future<void> Function(ICalTask task)? onRejectKidTask;

  const TasksScreen({
    super.key,
    required this.repo,
    this.settingsRepo,
    this.proposalRepo,
    this.suggestionRepo,
    this.myParentId,
    this.syncStatus,
    this.hasFamilyKey = false,
    this.partnerPaired = false,
    this.onSyncRetry,
    this.configRepo,
    this.enrolledKidsCount = 0,
    this.syncDoneCount,
    this.syncConfig,
    this.pullPresence,
    this.pullSharedTasks,
    this.enrolledKidsOverride,
    this.onDeleteKidTask,
    this.onAcceptKidTask,
    this.onRejectKidTask,
  });

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  final _kidsKey = GlobalKey<KidsPanelState>();

  @override
  void initState() {
    super.initState();
    widget.syncDoneCount?.addListener(_onSyncDone);
  }

  @override
  void didUpdateWidget(TasksScreen old) {
    super.didUpdateWidget(old);
    if (old.syncDoneCount != widget.syncDoneCount) {
      old.syncDoneCount?.removeListener(_onSyncDone);
      widget.syncDoneCount?.addListener(_onSyncDone);
    }
  }

  void _onSyncDone() => _kidsKey.currentState?.reload();

  @override
  void dispose() {
    widget.syncDoneCount?.removeListener(_onSyncDone);
    super.dispose();
  }

  void _showCompletedSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => _CompletedBottomSheet(
        repo: widget.repo,
        hasFamilyKey: widget.hasFamilyKey,
      ),
    );
  }

  bool get _showKids {
    final count =
        widget.enrolledKidsOverride?.length ?? widget.enrolledKidsCount;
    if (count <= 0 || widget.configRepo == null) return false;
    return widget.pullSharedTasks != null || widget.syncConfig != null;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Theme(
      data: Theme.of(context).copyWith(
        bottomSheetTheme: BottomSheetThemeData(
          backgroundColor: Colors.transparent,
          elevation: 0,
          modalBackgroundColor: scheme.surface,
          modalElevation: 1,
        ),
      ),
      child: Scaffold(
        appBar: AppBar(
          title: AppHeader(
            title: AppLocalizations.of(context).tasksTitle,
            centerTitle: false,
          ),
          centerTitle: false,
          actions: [
            if (widget.syncStatus != null)
              ValueListenableBuilder<SyncStatus>(
                valueListenable: widget.syncStatus!,
                builder: (context, status, _) => _SyncIcon(
                  status: status,
                  onSyncPressed: widget.onSyncRetry,
                ),
              ),
            IconButton(
              icon: const Icon(Icons.delete_outlined),
              tooltip: AppLocalizations.of(context).tasksCompletedTooltip,
              onPressed: () => _showCompletedSheet(context),
            ),
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                useSafeArea: true,
                builder: (_) => TaskDetailSheet(
                  repo: widget.repo,
                  hasFamilyKey: widget.hasFamilyKey,
                  partnerPaired: widget.partnerPaired,
                  configRepo: widget.configRepo,
                  pullPresence: widget.pullPresence,
                ),
              ),
            ),
          ],
        ),
        body: _TasksBody(
          repo: widget.repo,
          hasFamilyKey: widget.hasFamilyKey,
          partnerPaired: widget.partnerPaired,
          settingsRepo: widget.settingsRepo,
          proposalRepo: widget.proposalRepo,
          myParentId: widget.myParentId,
          configRepo: widget.configRepo,
          pullPresence: widget.pullPresence,
          header: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.suggestionRepo != null)
                SuggestionsPanel(
                  suggestionRepo: widget.suggestionRepo!,
                  todoRepo: widget.repo,
                  proposalRepo: widget.proposalRepo,
                  myParentId: widget.myParentId,
                  partnerPaired: widget.partnerPaired,
                  onSyncRequested: widget.onSyncRetry,
                ),
              if (_showKids)
                KidsPanel(
                  key: _kidsKey,
                  configRepo: widget.configRepo!,
                  syncConfig: widget.syncConfig,
                  pullSharedTasks: widget.pullSharedTasks,
                  enrolledKidsOverride: widget.enrolledKidsOverride,
                  todoRepo: widget.repo,
                  onDeleteKidTask: widget.onDeleteKidTask,
                  onAcceptKidTask: widget.onAcceptKidTask,
                  onRejectKidTask: widget.onRejectKidTask,
                ),
            ],
          ),
        ),
        bottomSheet: QuickAddBar(repo: widget.repo),
      ),
    );
  }
}

class _SyncIcon extends StatelessWidget {
  final SyncStatus status;
  final VoidCallback? onSyncPressed;

  const _SyncIcon({required this.status, this.onSyncPressed});

  @override
  Widget build(BuildContext context) {
    return switch (status) {
      SyncStatus.syncing => const Padding(
        padding: EdgeInsets.symmetric(horizontal: 12),
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
      SyncStatus.error => IconButton(
        onPressed: onSyncPressed,
        tooltip: AppLocalizations.of(context).tasksSyncFailed,
        icon: Icon(
          Icons.sync_problem_outlined,
          color: Theme.of(context).colorScheme.error,
        ),
      ),
      SyncStatus.idle => IconButton(
        onPressed: onSyncPressed,
        tooltip: AppLocalizations.of(context).tasksSyncing,
        icon: const Icon(Icons.cloud_done_outlined),
      ),
    };
  }
}

sealed class _ListItem {}

class _HeaderItem extends _ListItem {
  final String? category;
  final int count;
  _HeaderItem({required this.category, required this.count});
}

class _TaskItem extends _ListItem {
  final PersonalTask task;
  _TaskItem({required this.task});
}

class _TasksBody extends StatefulWidget {
  final TodoRepository repo;
  final bool hasFamilyKey;
  final bool partnerPaired;
  final SettingsRepository? settingsRepo;
  final PartnerProposalRepository? proposalRepo;
  final String? myParentId;
  final WebDavConfigRepository? configRepo;
  final Future<List<PresenceInfo>> Function()? pullPresence;
  final Widget header;

  const _TasksBody({
    required this.repo,
    this.hasFamilyKey = false,
    this.partnerPaired = false,
    this.settingsRepo,
    this.proposalRepo,
    this.myParentId,
    this.configRepo,
    this.pullPresence,
    required this.header,
  });

  @override
  State<_TasksBody> createState() => _TasksBodyState();
}

class _TasksBodyState extends State<_TasksBody> {
  List<String?> _categoryOrder = [];
  late final Stream<List<PersonalTask>> _openTasks = widget.repo
      .watchOpenTasks();

  List<String?> _mergeOrder(Iterable<String?> streamKeys) {
    final known = Set<String?>.from(streamKeys);
    final merged = _categoryOrder.where(known.contains).toList();
    for (final k in streamKeys) {
      if (!merged.contains(k)) merged.add(k);
    }
    return merged;
  }

  @override
  void initState() {
    super.initState();
    _loadSavedOrder();
  }

  Future<void> _loadSavedOrder() async {
    if (widget.settingsRepo == null) return;
    final saved = await widget.settingsRepo!.loadTaskCategoryOrder();
    if (mounted) setState(() => _categoryOrder = saved);
  }

  void _saveCategoryOrder(List<String?> order) {
    widget.settingsRepo?.saveTaskCategoryOrder(order);
  }

  Future<void> _renameCategory(String? category) async {
    if (category == null || category.isEmpty) return;
    final l10n = AppLocalizations.of(context);
    final controller = TextEditingController(text: category);
    final next = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.categoryRename),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(hintText: l10n.categoryRenameHint),
          textCapitalization: TextCapitalization.sentences,
          onSubmitted: (value) => Navigator.pop(ctx, value.trim()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.commonCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: Text(l10n.commonSave),
          ),
        ],
      ),
    );
    controller.dispose();
    if (next == null || next.isEmpty || next == category) return;
    await widget.repo.renameCustomCategory(from: category, to: next);
    final updated = [for (final c in _categoryOrder) c == category ? next : c];
    setState(() => _categoryOrder = updated);
    _saveCategoryOrder(updated);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<PersonalTask>>(
      stream: _openTasks,
      builder: (ctx, snap) {
        final tasks = snap.data ?? [];

        final groups = <String?, List<PersonalTask>>{};
        for (final t in tasks) {
          groups.putIfAbsent(t.customCategory, () => []).add(t);
        }

        final merged = _mergeOrder(groups.keys);
        if (merged.length != _categoryOrder.length ||
            !merged.every(_categoryOrder.contains)) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              setState(() => _categoryOrder = _mergeOrder(groups.keys));
            }
          });
        }

        final groupKeys = merged.where(groups.containsKey).toList();
        final flatItems = <_ListItem>[];
        final showHeaders =
            groupKeys.length > 1 ||
            (groupKeys.isNotEmpty && groupKeys.first != null);

        for (final cat in groupKeys) {
          if (showHeaders) {
            flatItems.add(
              _HeaderItem(category: cat, count: groups[cat]!.length),
            );
          }
          for (final t in groups[cat]!) {
            flatItems.add(_TaskItem(task: t));
          }
        }

        return CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: widget.header),
            if (flatItems.isEmpty)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.only(bottom: 88),
                  child: SizedBox(height: 240, child: _EmptyOpen()),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.only(top: 4, bottom: 88),
                sliver: SliverReorderableList(
                  itemCount: flatItems.length,
                  onReorder: (oldIndex, newIndex) {
                    _onReorder(flatItems, oldIndex, newIndex);
                  },
                  itemBuilder: (context, index) {
                    final item = flatItems[index];
                    if (item is _HeaderItem) {
                      return _CategoryHeader(
                        key: ValueKey('header_${item.category}'),
                        label:
                            item.category ??
                            AppLocalizations.of(context).commonNoCategory,
                        count: item.count,
                        index: index,
                        canRename: item.category != null,
                        onRename: () => _renameCategory(item.category),
                      );
                    }
                    final taskItem = item as _TaskItem;
                    return _DraggableTaskRow(
                      key: ValueKey(taskItem.task.id),
                      index: index,
                      task: taskItem.task,
                      repo: widget.repo,
                      hasFamilyKey: widget.hasFamilyKey,
                      partnerPaired: widget.partnerPaired,
                      proposalRepo: widget.proposalRepo,
                      myParentId: widget.myParentId,
                      configRepo: widget.configRepo,
                      pullPresence: widget.pullPresence,
                    );
                  },
                ),
              ),
          ],
        );
      },
    );
  }

  void _onReorder(List<_ListItem> items, int oldIndex, int newIndex) {
    if (oldIndex < newIndex) newIndex -= 1;

    if (items[oldIndex] is _HeaderItem) {
      final reordered = [...items]
        ..removeAt(oldIndex)
        ..insert(newIndex, items[oldIndex]);
      final newOrder = <String?>[];
      for (final item in reordered) {
        if (item is _HeaderItem) newOrder.add(item.category);
      }
      setState(() => _categoryOrder = newOrder);
      _saveCategoryOrder(newOrder);
      return;
    }

    final reordered = [...items]
      ..removeAt(oldIndex)
      ..insert(newIndex, items[oldIndex]);

    final updates = <({String id, String? category, int sortOrder})>[];
    String? currentCat;
    int posInCat = 0;

    for (final item in reordered) {
      if (item is _HeaderItem) {
        currentCat = item.category;
        posInCat = 0;
      } else {
        final taskItem = item as _TaskItem;
        updates.add((
          id: taskItem.task.id,
          category: currentCat,
          sortOrder: posInCat,
        ));
        posInCat++;
      }
    }

    widget.repo.batchUpdateCategoryAndOrder(updates);
  }
}

class _CategoryHeader extends StatelessWidget {
  final String label;
  final int count;
  final int index;
  final bool canRename;
  final VoidCallback onRename;

  const _CategoryHeader({
    super.key,
    required this.label,
    required this.count,
    required this.index,
    required this.canRename,
    required this.onRename,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);
    // Keep trailing chrome the same width for named + "No category" headers
    // so section margins / task alignment stay consistent.
    const trailingSlot = 40.0;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 4, 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Row(
              children: [
                Flexible(
                  child: Text(
                    label.toUpperCase(),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                      letterSpacing: 1.2,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: scheme.primaryContainer.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '$count',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: scheme.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: trailingSlot,
            height: trailingSlot,
            child: canRename
                ? PopupMenuButton<String>(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: trailingSlot,
                      minHeight: trailingSlot,
                    ),
                    icon: Icon(
                      Icons.more_horiz,
                      size: 18,
                      color: scheme.outline,
                    ),
                    onSelected: (value) {
                      if (value == 'rename') onRename();
                    },
                    itemBuilder: (ctx) => [
                      PopupMenuItem(
                        value: 'rename',
                        child: Text(l10n.categoryRename),
                      ),
                    ],
                  )
                : null,
          ),
          ReorderableDragStartListener(
            index: index,
            child: SizedBox(
              width: trailingSlot,
              height: trailingSlot,
              child: Icon(
                Icons.drag_indicator,
                size: 18,
                color: scheme.outlineVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DraggableTaskRow extends StatelessWidget {
  final int index;
  final PersonalTask task;
  final TodoRepository repo;
  final bool hasFamilyKey;
  final bool partnerPaired;
  final PartnerProposalRepository? proposalRepo;
  final String? myParentId;
  final WebDavConfigRepository? configRepo;
  final Future<List<PresenceInfo>> Function()? pullPresence;

  const _DraggableTaskRow({
    super.key,
    required this.index,
    required this.task,
    required this.repo,
    required this.hasFamilyKey,
    required this.partnerPaired,
    this.proposalRepo,
    this.myParentId,
    this.configRepo,
    this.pullPresence,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: TaskTile(
            task: task,
            repo: repo,
            hasFamilyKey: hasFamilyKey,
            partnerPaired: partnerPaired,
            proposalRepo: proposalRepo,
            myParentId: myParentId,
            configRepo: configRepo,
            pullPresence: pullPresence,
          ),
        ),
        ReorderableDragStartListener(
          index: index,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            child: Icon(
              Icons.drag_handle,
              size: 20,
              color: Theme.of(context).colorScheme.outlineVariant,
            ),
          ),
        ),
      ],
    );
  }
}

class _CompletedBottomSheet extends StatelessWidget {
  final TodoRepository repo;
  final bool hasFamilyKey;

  const _CompletedBottomSheet({required this.repo, this.hasFamilyKey = false});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.6,
      maxChildSize: 0.95,
      minChildSize: 0.3,
      builder: (context, scrollController) => StreamBuilder<List<PersonalTask>>(
        stream: repo.watchCompletedTasks(),
        builder: (ctx, snap) {
          final completed = snap.data ?? [];

          return Column(
            children: [
              Center(
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.outlineVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 8, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: AppHeader(
                        title: AppLocalizations.of(context).tasksCompletedTitle,
                      ),
                    ),
                    if (completed.isNotEmpty)
                      TextButton.icon(
                        onPressed: () => _confirmDeleteAll(ctx, repo),
                        icon: const Icon(Icons.delete_sweep_outlined, size: 16),
                        label: Text(
                          AppLocalizations.of(context).tasksDeleteAll,
                        ),
                        style: TextButton.styleFrom(
                          foregroundColor: Theme.of(
                            context,
                          ).colorScheme.onSurfaceVariant,
                          textStyle: const TextStyle(fontSize: 12),
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                        ),
                      ),
                  ],
                ),
              ),
              const Divider(height: 1),
              if (completed.isEmpty)
                const Expanded(child: _EmptyCompleted())
              else
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    itemCount: completed.length,
                    itemBuilder: (_, i) => TaskTile(
                      task: completed[i],
                      repo: repo,
                      hasFamilyKey: hasFamilyKey,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  void _confirmDeleteAll(BuildContext context, TodoRepository repo) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppLocalizations.of(context).tasksDeleteCompletedTitle),
        content: Text(AppLocalizations.of(context).tasksDeleteCompletedBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(AppLocalizations.of(context).commonCancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red.shade700),
            onPressed: () {
              Navigator.pop(ctx);
              repo.deleteCompletedTasks();
            },
            child: Text(AppLocalizations.of(context).commonDelete),
          ),
        ],
      ),
    );
  }
}

class _EmptyOpen extends StatelessWidget {
  const _EmptyOpen();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 56,
            color: scheme.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.of(context).tasksAllDone,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(color: scheme.onSurface),
          ),
          const SizedBox(height: 8),
          Text(
            AppLocalizations.of(context).tasksNoOpenTasks,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class _EmptyCompleted extends StatelessWidget {
  const _EmptyCompleted();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.inbox_outlined, size: 56, color: scheme.onSurfaceVariant),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.of(context).tasksNoCompleted,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(color: scheme.onSurface),
          ),
          const SizedBox(height: 8),
          Text(
            AppLocalizations.of(context).tasksNoCompletedHint,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
