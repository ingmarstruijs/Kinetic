import 'package:flutter/material.dart';
import '../../theme/app_themes.dart';
import '../../l10n/generated/app_localizations.dart';

import '../../main.dart';
import '../../settings/settings_repository.dart';
import '../../theme/app_header.dart';
import '../../vault/vault_biometrics.dart';
import '../models/personal_note.dart';
import '../services/note_repository.dart';
import '../widgets/category_sheet.dart';
import 'note_editor_screen.dart';

/// Screen that displays all notes in a scrollable list with create/edit/delete.
class NotesScreen extends StatefulWidget {
  final NoteRepository repo;
  final SettingsRepository? settingsRepo;
  final ValueNotifier<SyncStatus>? syncStatus;
  final bool partnerPaired;
  final VoidCallback? onSyncRetry;

  const NotesScreen({
    super.key,
    required this.repo,
    this.settingsRepo,
    this.syncStatus,
    this.partnerPaired = false,
    this.onSyncRetry,
  });

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen>
    with TickerProviderStateMixin {
  TabController? _tabController;

  bool get _onSharedTab => widget.partnerPaired && (_tabController?.index == 1);

  @override
  void initState() {
    super.initState();
    _syncTabController();
  }

  @override
  void didUpdateWidget(NotesScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.partnerPaired != widget.partnerPaired) {
      _syncTabController();
    }
  }

  void _syncTabController() {
    if (widget.partnerPaired) {
      _tabController ??= TabController(length: 2, vsync: this);
    } else if (_tabController != null) {
      _tabController!.dispose();
      _tabController = null;
    }
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  Future<void> _openEditor({
    PersonalNote? note,
    bool initialIsShared = false,
  }) async {
    final messenger = ScaffoldMessenger.of(context);
    final l10n = AppLocalizations.of(context);

    if (note != null && note.isContentHidden) {
      final unlocked = await VaultBiometrics.authenticate(
        reason: l10n.notesUnlockReason,
      );
      if (!mounted) return;
      if (unlocked != true) {
        if (unlocked == null) {
          messenger.showSnackBar(
            SnackBar(content: Text(l10n.notesHideNeedsDeviceLock)),
          );
        } else {
          messenger.showSnackBar(
            SnackBar(content: Text(l10n.notesUnlockFailed)),
          );
        }
        return;
      }
    }

    final result = await Navigator.of(context).push<PersonalNote?>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => NoteEditorScreen(
          repo: widget.repo,
          note: note,
          hasFamilyKey: widget.partnerPaired,
          initialIsShared: note?.isShared ?? initialIsShared,
        ),
      ),
    );
    if (context.mounted && result != null) {
      messenger.showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).notesSaved)),
      );
    }
  }

  void _showTrashSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => _NotesTrashSheet(repo: widget.repo),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: AppHeader(
          title: AppLocalizations.of(context).notesTitle,
          centerTitle: false,
        ),
        centerTitle: false,
        actions: [
          if (widget.syncStatus != null)
            ValueListenableBuilder<SyncStatus>(
              valueListenable: widget.syncStatus!,
              builder: (context, status, _) => switch (status) {
                SyncStatus.syncing => const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
                SyncStatus.error => IconButton(
                  onPressed: widget.onSyncRetry,
                  tooltip: AppLocalizations.of(context).tasksSyncFailed,
                  icon: Icon(
                    Icons.sync_problem_outlined,
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
                SyncStatus.idle => IconButton(
                  onPressed: widget.onSyncRetry,
                  tooltip: AppLocalizations.of(context).tasksSyncing,
                  icon: const Icon(Icons.cloud_done_outlined),
                ),
              },
            ),
          IconButton(
            icon: const Icon(Icons.delete_outlined),
            tooltip: AppLocalizations.of(context).notesTrashTooltip,
            onPressed: () => _showTrashSheet(context),
          ),
        ],
        bottom: widget.partnerPaired && _tabController != null
            ? TabBar(
                controller: _tabController,
                tabs: [
                  Tab(text: AppLocalizations.of(context).notesTabPrivate),
                  Tab(text: AppLocalizations.of(context).notesTabShared),
                ],
              )
            : null,
      ),
      body: widget.partnerPaired && _tabController != null
          ? TabBarView(
              controller: _tabController,
              children: [
                _NotesTabBody(
                  repo: widget.repo,
                  settingsRepo: widget.settingsRepo,
                  isShared: false,
                  onEditNote: (note) => _openEditor(note: note),
                ),
                _NotesTabBody(
                  repo: widget.repo,
                  settingsRepo: widget.settingsRepo,
                  isShared: true,
                  onEditNote: (note) => _openEditor(note: note),
                ),
              ],
            )
          : _NotesTabBody(
              repo: widget.repo,
              settingsRepo: widget.settingsRepo,
              isShared: false,
              onEditNote: (note) => _openEditor(note: note),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openEditor(initialIsShared: _onSharedTab),
        tooltip: AppLocalizations.of(context).notesNewTooltip,
        child: const Icon(Icons.add),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Single-tab body: filtered note list or empty state
// ---------------------------------------------------------------------------

class _NotesTabBody extends StatelessWidget {
  final NoteRepository repo;
  final SettingsRepository? settingsRepo;
  final bool isShared;
  final void Function(PersonalNote note) onEditNote;

  const _NotesTabBody({
    required this.repo,
    this.settingsRepo,
    required this.isShared,
    required this.onEditNote,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<PersonalNote>>(
      stream: repo.watchAll(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 48,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    AppLocalizations.of(context).notesLoadError,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    snapshot.error.toString(),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          );
        }

        final notes = (snapshot.data ?? [])
            .where((n) => n.isShared == isShared)
            .toList();

        if (notes.isEmpty) {
          final scheme = Theme.of(context).colorScheme;
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    isShared
                        ? AppLocalizations.of(context).notesEmptyShared
                        : AppLocalizations.of(context).notesEmptyPrivate,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: scheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isShared
                        ? AppLocalizations.of(context).notesEmptySharedHint
                        : AppLocalizations.of(context).notesEmptyPrivateHint,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return _NoteGroupedList(
          notes: notes,
          repo: repo,
          settingsRepo: settingsRepo,
          showSharedBadge: false,
          onEditNote: onEditNote,
        );
      },
    );
  }
}
// ---------------------------------------------------------------------------
// Grouped + draggable notes list
// ---------------------------------------------------------------------------

sealed class _NoteListItem {}

class _NoteHeaderItem extends _NoteListItem {
  final String? category;
  _NoteHeaderItem({required this.category});
}

class _NoteDataItem extends _NoteListItem {
  final PersonalNote note;
  _NoteDataItem({required this.note});
}

class _NoteGroupedList extends StatefulWidget {
  final List<PersonalNote> notes;
  final NoteRepository repo;
  final SettingsRepository? settingsRepo;
  final bool showSharedBadge;
  final void Function(PersonalNote note) onEditNote;

  const _NoteGroupedList({
    required this.notes,
    required this.repo,
    this.settingsRepo,
    required this.showSharedBadge,
    required this.onEditNote,
  });

  @override
  State<_NoteGroupedList> createState() => _NoteGroupedListState();
}

class _NoteGroupedListState extends State<_NoteGroupedList> {
  List<String?> _categoryOrder = [];

  @override
  void initState() {
    super.initState();
    _loadSavedOrder();
  }

  Future<void> _loadSavedOrder() async {
    if (widget.settingsRepo == null) return;
    final saved = await widget.settingsRepo!.loadNoteCategoryOrder();
    if (mounted) setState(() => _categoryOrder = saved);
  }

  void _saveCategoryOrder(List<String?> order) {
    widget.settingsRepo?.saveNoteCategoryOrder(order);
  }

  List<String?> _mergeOrder(Iterable<String?> streamKeys) {
    final known = Set<String?>.from(streamKeys);
    final merged = _categoryOrder.where(known.contains).toList();
    for (final k in streamKeys) {
      if (!merged.contains(k)) merged.add(k);
    }
    return merged;
  }

  @override
  Widget build(BuildContext context) {
    // Group notes by category
    final groups = <String?, List<PersonalNote>>{};
    for (final n in widget.notes) {
      groups.putIfAbsent(n.category, () => []).add(n);
    }

    // Use saved order merged with current categories
    final merged = _mergeOrder(groups.keys);
    if (merged.length != _categoryOrder.length ||
        !merged.every(_categoryOrder.contains)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => _categoryOrder = _mergeOrder(groups.keys));
      });
    }

    final groupKeys = merged.where(groups.containsKey).toList();

    final showHeaders = groupKeys.length > 1 || groupKeys.first != null;

    final flatItems = <_NoteListItem>[];
    for (final cat in groupKeys) {
      if (showHeaders) {
        flatItems.add(_NoteHeaderItem(category: cat));
      }
      for (final n in groups[cat]!) {
        flatItems.add(_NoteDataItem(note: n));
      }
    }

    return ReorderableListView.builder(
      buildDefaultDragHandles: false,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 88),
      itemCount: flatItems.length,
      itemBuilder: (context, index) {
        final item = flatItems[index];

        if (item is _NoteHeaderItem) {
          return _NoteCategoryHeader(
            key: ValueKey('header_${item.category}'),
            label:
                item.category ?? AppLocalizations.of(context).commonNoCategory,
            index: index,
          );
        }

        final noteItem = item as _NoteDataItem;
        return Padding(
          key: ValueKey(noteItem.note.id),
          padding: const EdgeInsets.only(bottom: 10),
          child: _NoteCard(
            note: noteItem.note,
            repo: widget.repo,
            dragIndex: index,
            showSharedBadge: widget.showSharedBadge,
            onTap: () => widget.onEditNote(noteItem.note),
          ),
        );
      },
      onReorder: (oldIndex, newIndex) {
        _onReorder(flatItems, oldIndex, newIndex);
      },
    );
  }

  void _onReorder(List<_NoteListItem> items, int oldIndex, int newIndex) {
    if (oldIndex < newIndex) newIndex -= 1;

    if (items[oldIndex] is _NoteHeaderItem) {
      // Header drag → reorder category blocks
      final reordered = [...items]
        ..removeAt(oldIndex)
        ..insert(newIndex, items[oldIndex]);
      final newOrder = <String?>[];
      for (final item in reordered) {
        if (item is _NoteHeaderItem) newOrder.add(item.category);
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
      if (item is _NoteHeaderItem) {
        currentCat = item.category;
        posInCat = 0;
      } else {
        final noteItem = item as _NoteDataItem;
        updates.add((
          id: noteItem.note.id,
          category: currentCat,
          sortOrder: posInCat,
        ));
        posInCat++;
      }
    }

    widget.repo.batchUpdateCategoryAndOrder(updates);
  }
}

class _NoteCategoryHeader extends StatelessWidget {
  final String label;
  final int index;

  const _NoteCategoryHeader({
    super.key,
    required this.label,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 16, 0, 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ReorderableDragStartListener(
            index: index,
            child: Icon(
              Icons.drag_indicator,
              size: 18,
              color: Theme.of(context).colorScheme.outlineVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _NoteCard extends StatelessWidget {
  final PersonalNote note;
  final NoteRepository repo;
  final int dragIndex;
  final bool showSharedBadge;
  final VoidCallback onTap;

  const _NoteCard({
    required this.note,
    required this.repo,
    required this.dragIndex,
    required this.onTap,
    this.showSharedBadge = false,
  });

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final preview = note.bodyPreview;
    final reminderPassed = note.remindAt != null && isOverdue(note.remindAt!);
    final showShared = note.isShared && showSharedBadge;
    final showMeta =
        note.remindAt != null || showShared || note.isContentHidden;

    return Material(
      color: scheme.surfaceContainerLow,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        onLongPress: () => _pickCategory(context),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 8, 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      note.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: tt.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        height: 1.25,
                      ),
                    ),
                  ),
                  ReorderableDragStartListener(
                    index: dragIndex,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 4, top: 2),
                      child: Icon(
                        Icons.drag_indicator,
                        size: 18,
                        color: scheme.outlineVariant,
                      ),
                    ),
                  ),
                ],
              ),
              if (preview.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  preview,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: tt.bodyMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                    height: 1.4,
                  ),
                ),
              ],
              if (showMeta) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    if (note.isContentHidden)
                      _NoteMetaChip(
                        icon: Icons.lock_outline,
                        label: AppLocalizations.of(context).notesLockedBadge,
                        color: scheme.onSurfaceVariant,
                      ),
                    if (note.remindAt != null)
                      _NoteMetaChip(
                        icon: Icons.schedule,
                        label: formatDueDate(
                          note.remindAt!,
                          AppLocalizations.of(context),
                          allDay: false,
                        ),
                        color: reminderPassed
                            ? scheme.error
                            : scheme.onSurfaceVariant,
                      ),
                    if (showShared)
                      _NoteMetaChip(
                        icon: Icons.people_outline,
                        label: AppLocalizations.of(context).notesSharedBadge,
                        color: kColorTeal,
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickCategory(BuildContext context) async {
    final categories = await repo.watchNoteCategories().first;
    if (!context.mounted) return;
    final result = await showCategoryPicker(
      context: context,
      existingCategories: categories,
      currentCategory: note.category,
    );
    if (result != null) {
      await repo.updateNoteCategory(note.id, result.isEmpty ? null : result);
    }
  }
}

class _NoteMetaChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _NoteMetaChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(color: color),
        ),
      ],
    );
  }
}

class _NotesTrashSheet extends StatelessWidget {
  final NoteRepository repo;

  const _NotesTrashSheet({required this.repo});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.6,
      maxChildSize: 0.95,
      minChildSize: 0.3,
      builder: (context, scrollController) => StreamBuilder<List<PersonalNote>>(
        stream: repo.watchDeleted(),
        builder: (ctx, snap) {
          final deleted = snap.data ?? [];
          final l10n = AppLocalizations.of(context);
          final scheme = Theme.of(context).colorScheme;

          return Column(
            children: [
              Center(
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: scheme.outlineVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 8, 8),
                child: Row(
                  children: [
                    Expanded(child: AppHeader(title: l10n.notesTrashTitle)),
                    if (deleted.isNotEmpty)
                      TextButton.icon(
                        onPressed: () => _confirmEmpty(ctx),
                        icon: const Icon(Icons.delete_sweep_outlined, size: 16),
                        label: Text(l10n.tasksDeleteAll),
                        style: TextButton.styleFrom(
                          foregroundColor: scheme.onSurfaceVariant,
                          textStyle: const TextStyle(fontSize: 12),
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                        ),
                      ),
                  ],
                ),
              ),
              const Divider(height: 1),
              if (deleted.isEmpty)
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.inbox_outlined,
                          size: 56,
                          color: scheme.onSurfaceVariant,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          l10n.notesNoTrash,
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(color: scheme.onSurface),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          l10n.notesNoTrashHint,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: scheme.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                )
              else
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    itemCount: deleted.length,
                    itemBuilder: (_, i) {
                      final note = deleted[i];
                      return ListTile(
                        title: Text(
                          note.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: note.bodyPreview.isEmpty
                            ? null
                            : Text(
                                note.bodyPreview,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                        trailing: TextButton(
                          onPressed: () => repo.restore(note.id),
                          child: Text(l10n.notesRestore),
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

  void _confirmEmpty(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.notesEmptyTrashTitle),
        content: Text(l10n.notesEmptyTrashBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.commonCancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red.shade700),
            onPressed: () {
              Navigator.pop(ctx);
              repo.emptyTrash();
            },
            child: Text(l10n.commonDelete),
          ),
        ],
      ),
    );
  }
}
