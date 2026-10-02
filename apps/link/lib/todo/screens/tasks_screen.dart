import 'package:flutter/material.dart';
import '../../l10n/generated/app_localizations.dart';
import 'package:kinetic_webdav/kinetic_webdav.dart';

import '../../debug/demo_session.dart';
import '../../family/family_connection_service.dart';
import '../../family/proposals/link_member_proposal_repository.dart';
import '../../settings/models/enrolled_kid.dart';
import '../../settings/settings_repository.dart';
import '../../sync/sync_status.dart';
import '../../sync/webdav_config_repository.dart';
import '../../theme/app_header.dart';
import '../../todo/models/personal_task.dart';
import '../../todo/services/ai_suggestion_repository.dart';
import '../../todo/services/note_repository.dart';
import '../../todo/services/todo_repository.dart';
import '../../todo/widgets/family_adults_section.dart';
import '../../todo/widgets/kids_panel.dart';
import '../../todo/widgets/quick_add_bar.dart';
import '../../todo/widgets/suggestions_panel.dart';
import '../../todo/widgets/category_sheet.dart';
import '../../todo/widgets/family_ambient_strip.dart';
import '../../todo/widgets/task_detail_sheet.dart';
import '../../todo/widgets/task_tile.dart';
import '../../todo/widgets/tasks_section_header.dart';
import '../../todo/category_icons.dart';
import '../../todo/smart_sort.dart';

class TasksScreen extends StatefulWidget {
  final TodoRepository repo;
  final NoteRepository? noteRepo;
  final SettingsRepository? settingsRepo;
  final LinkMemberProposalRepository? proposalRepo;
  final AiSuggestionRepository? suggestionRepo;
  final String? myLinkId;
  final ValueNotifier<SyncStatusInfo>? syncStatus;
  final bool hasFamilyKey;
  final bool hasOtherLinkMembers;
  final List<({String id, String name})> otherLinkMembers;
  final VoidCallback? onSyncRetry;
  final WebDavConfigRepository? configRepo;
  final int enrolledKidsCount;
  final ValueNotifier<int>? syncDoneCount;
  final SyncConfig? syncConfig;
  final Future<List<PresenceInfo>> Function()? pullPresence;
  final Future<List<LoadMetrics>> Function()? pullLoadMetrics;
  final Future<List<ICalTask>> Function()? pullSharedTasks;
  final List<EnrolledKid>? enrolledKidsOverride;
  final Future<void> Function(ICalTask task)? onDeleteKidTask;
  final Future<void> Function(ICalTask task)? onAcceptKidTask;
  final Future<void> Function(ICalTask task)? onRejectKidTask;
  final Future<void> Function(String toLinkId, String toName)? onSendNudge;

  /// False when this link member turned off kids panels in settings.
  final bool kidsParticipation;

  const TasksScreen({
    super.key,
    required this.repo,
    this.noteRepo,
    this.settingsRepo,
    this.proposalRepo,
    this.suggestionRepo,
    this.myLinkId,
    this.syncStatus,
    this.hasFamilyKey = false,
    this.hasOtherLinkMembers = false,
    this.otherLinkMembers = const [],
    this.onSyncRetry,
    this.configRepo,
    this.enrolledKidsCount = 0,
    this.syncDoneCount,
    this.syncConfig,
    this.pullPresence,
    this.pullLoadMetrics,
    this.pullSharedTasks,
    this.enrolledKidsOverride,
    this.onDeleteKidTask,
    this.onAcceptKidTask,
    this.onRejectKidTask,
    this.onSendNudge,
    this.kidsParticipation = true,
  });

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  final _kidsKey = GlobalKey<KidsPanelState>();
  final _ambientKey = GlobalKey();
  bool _suggestionsVisible = false;
  bool _familyPopoverOpen = false;
  int _kidsPendingCount = 0;
  Map<String, int> _kidsOpenCounts = const {};
  List<PresenceInfo> _presence = const [];

  @override
  void initState() {
    super.initState();
    widget.syncDoneCount?.addListener(_onSyncDone);
    _reloadPresence();
  }

  @override
  void didUpdateWidget(TasksScreen old) {
    super.didUpdateWidget(old);
    if (old.syncDoneCount != widget.syncDoneCount) {
      old.syncDoneCount?.removeListener(_onSyncDone);
      widget.syncDoneCount?.addListener(_onSyncDone);
    }
    if (old.pullPresence != widget.pullPresence ||
        old.otherLinkMembers != widget.otherLinkMembers) {
      _reloadPresence();
    }
  }

  void _onSyncDone() {
    _kidsKey.currentState?.reload();
    _reloadPresence();
  }

  Future<void> _reloadPresence() async {
    final pull = widget.pullPresence;
    if (pull == null) return;
    try {
      final list = await pull();
      if (!mounted) return;
      setState(() => _presence = list);
    } catch (_) {}
  }

  Future<void> _showKidsCreateSheet(
    BuildContext context, {
    String? kidId,
    required bool everyone,
  }) async {
    final demo = DemoSession.instance;
    final kids = demo.active && demo.kids.isNotEmpty
        ? demo.kids
        : widget.enrolledKidsOverride ??
              await widget.configRepo?.loadEnrolledKids() ??
              const <EnrolledKid>[];
    final target = everyone
        ? null
        : kids.where((k) => k.id == kidId).firstOrNull;
    final xpKids = kids.where((k) => k.xpEnabled).toList();
    // Per kid: that kid's flag. Everyone: if any kid has XP on.
    final showXp = everyone
        ? xpKids.isNotEmpty
        : (target?.xpEnabled ?? false);
    final displayName = everyone ? null : (target?.name ?? kidId);
    if (!context.mounted) return;
    String? xpHint;
    if (everyone && showXp && xpKids.length < kids.length) {
      final l10n = AppLocalizations.of(context);
      xpHint = xpKids.length <= 3
          ? l10n.kidsXpAppliesToNamed(xpKids.map((k) => k.name).join(', '))
          : l10n.kidsXpAppliesToEnabled;
    }
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => TaskDetailSheet(
        repo: widget.repo,
        noteRepo: widget.noteRepo,
        hasFamilyKey: widget.hasFamilyKey,
        hasOtherLinkMembers: widget.hasOtherLinkMembers,
        proposalRepo: widget.proposalRepo,
        myLinkId: widget.myLinkId,
        configRepo: widget.configRepo,
        pullPresence: widget.pullPresence,
        assignToKidId: everyone ? null : kidId,
        assignToEveryone: everyone,
        showXpReward: showXp,
        xpRewardHint: xpHint,
        assignToDisplayName: displayName,
        onSaved: () => _kidsKey.currentState?.reload(),
      ),
    );
  }

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
    if (!widget.kidsParticipation) return false;
    final count =
        widget.enrolledKidsOverride?.length ?? widget.enrolledKidsCount;
    if (count <= 0 || widget.configRepo == null) return false;
    return widget.pullSharedTasks != null || widget.syncConfig != null;
  }

  bool get _showFamilyPopover =>
      _showKids || (widget.hasFamilyKey && widget.hasOtherLinkMembers);

  bool get _showAdultsSection => widget.otherLinkMembers.isNotEmpty;

  bool get _showAmbientStrip =>
      widget.hasFamilyKey &&
      (widget.hasOtherLinkMembers || widget.enrolledKidsCount > 0);

  void _toggleFamilyPopover() {
    if (!_showFamilyPopover) return;
    setState(() => _familyPopoverOpen = !_familyPopoverOpen);
    if (_familyPopoverOpen) {
      _kidsKey.currentState?.reload();
      _reloadPresence();
    }
  }

  bool _mapEquals(Map<String, int> a, Map<String, int> b) {
    if (identical(a, b)) return true;
    if (a.length != b.length) return false;
    for (final e in a.entries) {
      if (b[e.key] != e.value) return false;
    }
    return true;
  }

  Future<void> _handleNudge(FamilyMemberStatus member) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    try {
      final send = widget.onSendNudge;
      if (send != null) {
        await send(member.id, member.name);
      } else if (!DemoSession.instance.active) {
        throw StateError('nudge unavailable');
      }
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.nudgeSent(member.name))),
      );
    } on StateError catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            e.message == 'nudge_cooldown'
                ? l10n.nudgeCooldown
                : l10n.nudgeSendFailed,
          ),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.nudgeSendFailed)),
      );
    }
  }

  Widget _buildKidsPanel() {
    return KidsPanel(
      key: _kidsKey,
      configRepo: widget.configRepo!,
      syncConfig: widget.syncConfig,
      pullSharedTasks: widget.pullSharedTasks,
      enrolledKidsOverride: widget.enrolledKidsOverride,
      todoRepo: widget.repo,
      syncStatus: widget.syncStatus,
      onDeleteKidTask: widget.onDeleteKidTask,
      onAcceptKidTask: widget.onAcceptKidTask,
      onRejectKidTask: widget.onRejectKidTask,
      myLinkId: widget.myLinkId,
      kidsParticipation: widget.kidsParticipation,
      popoverMode: true,
      onPendingCountChanged: (count) {
        if (!mounted || _kidsPendingCount == count) return;
        setState(() => _kidsPendingCount = count);
      },
      onOpenCountsChanged: (counts) {
        if (!mounted) return;
        if (_mapEquals(_kidsOpenCounts, counts)) return;
        setState(() => _kidsOpenCounts = counts);
      },
      onCreateTask: ({String? kidId, required bool everyone}) {
        _showKidsCreateSheet(
          context,
          kidId: kidId,
          everyone: everyone,
        );
      },
    );
  }

  Widget _buildFamilyPopoverBody() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_showAdultsSection)
            FamilyAdultsSection(
              otherLinkMembers: widget.otherLinkMembers,
              presence: _presence,
              onNudge: widget.onSendNudge != null || DemoSession.instance.active
                  ? _handleNudge
                  : null,
            ),
          if (_showKids) _buildKidsPanel(),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final barColor =
        Theme.of(context).appBarTheme.backgroundColor ??
        Theme.of(context).scaffoldBackgroundColor;
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
              ValueListenableBuilder<SyncStatusInfo>(
                valueListenable: widget.syncStatus!,
                builder: (context, info, _) => SyncStatusIcon(
                  info: info,
                  onRetry: widget.onSyncRetry ?? () {},
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
                  noteRepo: widget.noteRepo,
                  hasFamilyKey: widget.hasFamilyKey,
                  hasOtherLinkMembers: widget.hasOtherLinkMembers,
                  proposalRepo: widget.proposalRepo,
                  myLinkId: widget.myLinkId,
                  otherLinkMembers: widget.otherLinkMembers,
                  configRepo: widget.configRepo,
                  pullPresence: widget.pullPresence,
                  kidsParticipation: widget.kidsParticipation,
                ),
              ),
            ),
          ],
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_showAmbientStrip)
              Material(
                key: _ambientKey,
                color: Colors.transparent,
                elevation: 0,
                child: FamilyAmbientStrip(
                  visible: true,
                  otherLinkMembers: widget.otherLinkMembers,
                  enrolledKids: widget.enrolledKidsOverride ??
                      const <EnrolledKid>[],
                  pullPresence: widget.pullPresence,
                  pullLoadMetrics: widget.pullLoadMetrics,
                  syncDoneCount: widget.syncDoneCount,
                  configRepo: widget.configRepo,
                  enrolledKidsCount: widget.enrolledKidsCount,
                  onOpenKids: _showFamilyPopover ? _toggleFamilyPopover : null,
                  kidsPopoverOpen: _familyPopoverOpen,
                  kidsPendingCount: _kidsPendingCount,
                  kidsOpenCounts: _kidsOpenCounts,
                ),
              ),
            Expanded(
              child: Stack(
                clipBehavior: Clip.hardEdge,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: _TasksBody(
                          repo: widget.repo,
                          noteRepo: widget.noteRepo,
                          hasFamilyKey: widget.hasFamilyKey,
                          hasOtherLinkMembers: widget.hasOtherLinkMembers,
                          // Compact personal empty only when Suggestions chrome is up —
                          // kids live in the ambient popover now.
                          familyContext: _suggestionsVisible,
                          settingsRepo: widget.settingsRepo,
                          proposalRepo: widget.proposalRepo,
                          myLinkId: widget.myLinkId,
                          otherLinkMembers: widget.otherLinkMembers,
                          configRepo: widget.configRepo,
                          pullPresence: widget.pullPresence,
                          header: widget.suggestionRepo == null
                              ? const SizedBox.shrink()
                              : SuggestionsPanel(
                                  suggestionRepo: widget.suggestionRepo!,
                                  todoRepo: widget.repo,
                                  proposalRepo: widget.proposalRepo,
                                  myLinkId: widget.myLinkId,
                                  hasOtherLinkMembers:
                                      widget.hasOtherLinkMembers,
                                  otherLinkMembers: widget.otherLinkMembers,
                                  onSyncRequested: widget.onSyncRetry,
                                  onVisibilityChanged: (visible) {
                                    if (!mounted ||
                                        _suggestionsVisible == visible) {
                                      return;
                                    }
                                    setState(
                                      () => _suggestionsVisible = visible,
                                    );
                                  },
                                ),
                        ),
                      ),
                      QuickAddBar(
                        repo: widget.repo,
                        hasFamilyKey: widget.hasFamilyKey,
                        hasOtherLinkMembers: widget.hasOtherLinkMembers,
                        proposalRepo: widget.proposalRepo,
                        myLinkId: widget.myLinkId,
                        otherLinkMembers: widget.otherLinkMembers,
                        configRepo: widget.configRepo,
                        pullPresence: widget.pullPresence,
                        kidsParticipation: widget.kidsParticipation,
                      ),
                    ],
                  ),
                  // Full-height panel over tasks + QuickAdd; ambient strip stays above.
                  // Kept mounted when closed so kids open/pending counts stay fresh.
                  if (_showFamilyPopover)
                    Positioned.fill(
                      child: Offstage(
                        offstage: !_familyPopoverOpen,
                        child: IgnorePointer(
                          ignoring: !_familyPopoverOpen,
                          child: Material(
                            elevation: _familyPopoverOpen ? 6 : 0,
                            color: barColor,
                            shadowColor:
                                scheme.shadow.withValues(alpha: 0.25),
                            child: SafeArea(
                              top: false,
                              child: _buildFamilyPopoverBody(),
                            ),
                          ),
                        ),
                      ),
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

sealed class _ListItem {}

/// Small breathing room under the last task row (QuickAdd sits in layout below).
const _kQuickAddClearance = 16.0;

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
  final NoteRepository? noteRepo;
  final bool hasFamilyKey;
  final bool hasOtherLinkMembers;
  /// When true, the personal-task list empty state stays compact (no "all done"
  /// hero) because Suggestions and/or Kids panels already occupy the header.
  final bool familyContext;
  final SettingsRepository? settingsRepo;
  final LinkMemberProposalRepository? proposalRepo;
  final String? myLinkId;
  final List<({String id, String name})> otherLinkMembers;
  final WebDavConfigRepository? configRepo;
  final Future<List<PresenceInfo>> Function()? pullPresence;
  final Widget header;

  const _TasksBody({
    required this.repo,
    this.noteRepo,
    this.hasFamilyKey = false,
    this.hasOtherLinkMembers = false,
    this.familyContext = false,
    this.settingsRepo,
    this.proposalRepo,
    this.myLinkId,
    this.otherLinkMembers = const [],
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
  bool _tasksExpanded = true;

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
    // Wait until the PopupMenu route has finished closing.
    await Future<void>.delayed(Duration.zero);
    if (!mounted) return;
    final next = await showRenameCategoryDialog(
      context: context,
      currentName: category,
    );
    if (next == null || next.isEmpty || next == category || !mounted) return;
    await widget.repo.renameCustomCategory(from: category, to: next);
    await widget.settingsRepo?.renameCategoryIcon(category, next);
    final updated = [for (final c in _categoryOrder) c == category ? next : c];
    setState(() => _categoryOrder = updated);
    _saveCategoryOrder(updated);
  }

  Future<void> _setCategoryIcon(String? category) async {
    if (category == null || category.isEmpty) return;
    await Future<void>.delayed(Duration.zero);
    if (!mounted || widget.settingsRepo == null) return;
    final icons = await widget.settingsRepo!.loadCategoryIcons();
    if (!mounted) return;
    final picked = await showCategoryIconPicker(
      context: context,
      currentIconKey: icons[category],
    );
    if (picked == null || !mounted) return;
    await widget.settingsRepo!.setCategoryIcon(category, picked);
  }

  Future<void> _removeCategory(String? category) async {
    if (category == null || category.isEmpty) return;
    await Future<void>.delayed(Duration.zero);
    if (!mounted) return;
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.categoryRemoveTitle),
        content: Text(l10n.categoryRemoveBody(category)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.commonCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.categoryRemove),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    await widget.repo.renameCustomCategory(from: category, to: '');
    await widget.settingsRepo?.setCategoryIcon(category, null);
    final updated = [for (final c in _categoryOrder) if (c != category) c];
    setState(() => _categoryOrder = updated);
    _saveCategoryOrder(updated);
  }

  @override
  Widget build(BuildContext context) {
    final smartStream =
        widget.settingsRepo?.watchSmartSortEnabled() ?? Stream.value(false);
    final iconsStream =
        widget.settingsRepo?.watchCategoryIcons() ??
        Stream.value(<String, String>{});

    return StreamBuilder<bool>(
      stream: smartStream,
      builder: (context, smartSnap) {
        final smartSort = smartSnap.data ?? false;
        return StreamBuilder<Map<String, String>>(
          stream: iconsStream,
          builder: (context, iconsSnap) {
            final categoryIcons = iconsSnap.data ?? const <String, String>{};
            return StreamBuilder<List<PersonalTask>>(
              stream: _openTasks,
              builder: (ctx, snap) {
                final tasks = snap.data ?? [];

                final groups = <String?, List<PersonalTask>>{};
                for (final t in tasks) {
                  groups.putIfAbsent(t.customCategory, () => []).add(t);
                }

                for (final entry in groups.entries) {
                  final list = entry.value;
                  if (smartSort) {
                    list.sort(compareTasksSmart);
                  }
                }

                final List<String?> groupKeys;
                if (smartSort) {
                  groupKeys = groups.keys.toList()
                    ..sort(
                      (a, b) => compareTaskCategoriesSmart(a, b, groups),
                    );
                } else {
                  final merged = _mergeOrder(groups.keys);
                  if (merged.length != _categoryOrder.length ||
                      !merged.every(_categoryOrder.contains)) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (mounted) {
                        setState(
                          () => _categoryOrder = _mergeOrder(groups.keys),
                        );
                      }
                    });
                  }
                  groupKeys = merged.where(groups.containsKey).toList();
                }

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
                    if (widget.familyContext)
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const SizedBox(height: 8),
                              Divider(
                                height: 1,
                                color: Theme.of(context)
                                    .colorScheme
                                    .outlineVariant
                                    .withValues(alpha: 0.5),
                              ),
                              const SizedBox(height: 20),
                              TasksSectionHeader(
                                icon: Icons.checklist_outlined,
                                title: AppLocalizations.of(
                                  context,
                                ).tasksSectionTitle,
                                count: tasks.isEmpty ? null : tasks.length,
                                expanded: _tasksExpanded,
                                onToggle: () => setState(
                                  () => _tasksExpanded = !_tasksExpanded,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    if (!widget.familyContext || _tasksExpanded) ...[
                      if (flatItems.isEmpty)
                        if (widget.familyContext)
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
                              child: _EmptyOpen(familyContext: true),
                            ),
                          )
                        else
                          SliverFillRemaining(
                            hasScrollBody: false,
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
                              child: Center(child: _EmptyOpen()),
                            ),
                          )
                      else
                        SliverPadding(
                          padding: const EdgeInsets.only(top: 4),
                          sliver: smartSort
                              ? SliverList(
                                  delegate: SliverChildBuilderDelegate(
                                    (context, index) => _buildListItem(
                                      context,
                                      flatItems,
                                      index,
                                      categoryIcons: categoryIcons,
                                      reorderable: false,
                                    ),
                                    childCount: flatItems.length,
                                  ),
                                )
                              : SliverReorderableList(
                                  itemCount: flatItems.length,
                                  onReorder: (oldIndex, newIndex) {
                                    _onReorder(flatItems, oldIndex, newIndex);
                                  },
                                  itemBuilder: (context, index) =>
                                      _buildListItem(
                                    context,
                                    flatItems,
                                    index,
                                    categoryIcons: categoryIcons,
                                    reorderable: true,
                                  ),
                                ),
                        ),
                    ],
                    const SliverToBoxAdapter(
                      child: SizedBox(height: _kQuickAddClearance),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildListItem(
    BuildContext context,
    List<_ListItem> flatItems,
    int index, {
    required Map<String, String> categoryIcons,
    required bool reorderable,
  }) {
    final item = flatItems[index];
    if (item is _HeaderItem) {
      return _CategoryHeader(
        key: ValueKey('header_${item.category}'),
        label:
            item.category ?? AppLocalizations.of(context).commonNoCategory,
        icon: CategoryIconCatalog.resolve(
          item.category == null ? null : categoryIcons[item.category],
          isNone: item.category == null,
        ),
        count: item.count,
        index: index,
        canRename: item.category != null,
        reorderable: reorderable,
        onRename: () => _renameCategory(item.category),
        onSetIcon: () => _setCategoryIcon(item.category),
        onRemove: () => _removeCategory(item.category),
      );
    }
    final taskItem = item as _TaskItem;
    return _DraggableTaskRow(
      key: ValueKey(taskItem.task.id),
      index: index,
      task: taskItem.task,
      repo: widget.repo,
      noteRepo: widget.noteRepo,
      hasFamilyKey: widget.hasFamilyKey,
      hasOtherLinkMembers: widget.hasOtherLinkMembers,
      proposalRepo: widget.proposalRepo,
      myLinkId: widget.myLinkId,
      otherLinkMembers: widget.otherLinkMembers,
      configRepo: widget.configRepo,
      pullPresence: widget.pullPresence,
      categoryIcons: categoryIcons,
      reorderable: reorderable,
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
  final IconData icon;
  final int count;
  final int index;
  final bool canRename;
  final bool reorderable;
  final VoidCallback onRename;
  final VoidCallback onSetIcon;
  final VoidCallback onRemove;

  const _CategoryHeader({
    super.key,
    required this.label,
    required this.icon,
    required this.count,
    required this.index,
    required this.canRename,
    required this.reorderable,
    required this.onRename,
    required this.onSetIcon,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);
    // Keep leading icon + trailing chrome the same width for named and
    // "No category" headers so section margins / task alignment stay consistent.
    const trailingSlot = 40.0;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 4, 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, size: 16, color: scheme.onSurfaceVariant),
          const SizedBox(width: 8),
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
                      if (value == 'icon') onSetIcon();
                      if (value == 'remove') onRemove();
                    },
                    itemBuilder: (ctx) => [
                      PopupMenuItem(
                        value: 'rename',
                        child: Text(l10n.categoryRename),
                      ),
                      PopupMenuItem(
                        value: 'icon',
                        child: Text(l10n.categorySetIcon),
                      ),
                      PopupMenuItem(
                        value: 'remove',
                        child: Text(l10n.categoryRemove),
                      ),
                    ],
                  )
                : null,
          ),
          if (reorderable)
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
  final NoteRepository? noteRepo;
  final bool hasFamilyKey;
  final bool hasOtherLinkMembers;
  final LinkMemberProposalRepository? proposalRepo;
  final String? myLinkId;
  final List<({String id, String name})> otherLinkMembers;
  final WebDavConfigRepository? configRepo;
  final Future<List<PresenceInfo>> Function()? pullPresence;
  final Map<String, String> categoryIcons;
  final bool reorderable;

  const _DraggableTaskRow({
    super.key,
    required this.index,
    required this.task,
    required this.repo,
    this.noteRepo,
    required this.hasFamilyKey,
    required this.hasOtherLinkMembers,
    this.proposalRepo,
    this.myLinkId,
    this.otherLinkMembers = const [],
    this.configRepo,
    this.pullPresence,
    this.categoryIcons = const {},
    this.reorderable = true,
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
            noteRepo: noteRepo,
            hasFamilyKey: hasFamilyKey,
            hasOtherLinkMembers: hasOtherLinkMembers,
            proposalRepo: proposalRepo,
            myLinkId: myLinkId,
            otherLinkMembers: otherLinkMembers,
            configRepo: configRepo,
            pullPresence: pullPresence,
            categoryIcons: categoryIcons,
          ),
        ),
        if (reorderable)
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
                    itemBuilder: (_, i) {
                      final task = completed[i];
                      final l10n = AppLocalizations.of(ctx);
                      final done = task.completedAt;
                      final subtitle = done == null
                          ? null
                          : l10n.tasksDoneOn(done.toLocal().day, done.toLocal().month);
                      return ListTile(
                        title: Text(
                          task.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: subtitle == null ? null : Text(subtitle),
                        trailing: TextButton(
                          onPressed: () => repo.uncompleteTask(task.id),
                          child: Text(l10n.tasksRestore),
                        ),
                      );
                    },
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
  final bool familyContext;

  const _EmptyOpen({this.familyContext = false});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    if (familyContext) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Text(
          l10n.tasksNoPersonalOpen,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: scheme.onSurfaceVariant,
          ),
        ),
      );
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.check_circle_outline,
          size: 56,
          color: scheme.onSurfaceVariant,
        ),
        const SizedBox(height: 16),
        Text(
          l10n.tasksAllDone,
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(color: scheme.onSurface),
        ),
        const SizedBox(height: 8),
        Text(
          l10n.tasksNoOpenTasks,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
        ),
      ],
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
