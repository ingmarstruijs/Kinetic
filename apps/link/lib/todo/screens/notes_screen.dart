import 'package:flutter/material.dart';
import '../../theme/app_themes.dart';
import '../../l10n/generated/app_localizations.dart';

import '../../settings/settings_repository.dart';
import '../../sync/sync_status.dart';
import '../../theme/app_header.dart';
import '../../vault/vault_biometrics.dart';
import '../models/personal_note.dart';
import '../services/note_repository.dart';
import '../services/todo_repository.dart';
import '../widgets/category_sheet.dart';
import '../widgets/note_quick_add_bar.dart';
import 'note_editor_screen.dart';

/// Screen that displays all notes in a scrollable list with create/edit/delete.
class NotesScreen extends StatefulWidget {
  final NoteRepository repo;
  final TodoRepository? todoRepo;
  final SettingsRepository? settingsRepo;
  final ValueNotifier<SyncStatusInfo>? syncStatus;
  final bool hasOtherLinkMembers;
  final VoidCallback? onSyncRetry;
  final String? myLinkId;
  final List<({String id, String name})> otherLinkMembers;

  const NotesScreen({
    super.key,
    required this.repo,
    this.todoRepo,
    this.settingsRepo,
    this.syncStatus,
    this.hasOtherLinkMembers = false,
    this.onSyncRetry,
    this.myLinkId,
    this.otherLinkMembers = const [],
  });

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  Future<void> _openEditor({
    PersonalNote? note,
    bool initialIsShared = false,
    String? initialTitle,
    String? initialBody,
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
          todoRepo: widget.todoRepo,
          note: note,
          hasFamilyKey: widget.hasOtherLinkMembers,
          initialIsShared: note?.isShared ?? initialIsShared,
          initialTitle: initialTitle,
          initialBody: initialBody,
          otherLinkMembers: widget.otherLinkMembers,
        ),
      ),
    );
    if (context.mounted && result != null) {
      messenger.showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).notesSaved)),
      );
    }
  }

  void _showNewNoteMenu() {
    final l10n = AppLocalizations.of(context);
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.note_add_outlined),
              title: Text(l10n.notesNewTooltip),
              onTap: () {
                Navigator.pop(ctx);
                _openEditor();
              },
            ),
            ListTile(
              leading: const Icon(Icons.description_outlined),
              title: Text(l10n.notesFromTemplate),
              onTap: () {
                Navigator.pop(ctx);
                _showTemplatePicker();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showTemplatePicker() {
    final l10n = AppLocalizations.of(context);
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(title: Text(l10n.notesFromTemplate)),
            ListTile(
              title: Text(l10n.notesTemplateMeeting),
              onTap: () {
                Navigator.pop(ctx);
                _openEditor(
                  initialTitle: l10n.notesTemplateMeeting,
                  initialBody: l10n.notesTemplateMeetingBody,
                );
              },
            ),
            ListTile(
              title: Text(l10n.notesTemplateShopping),
              onTap: () {
                Navigator.pop(ctx);
                _openEditor(
                  initialTitle: l10n.notesTemplateShopping,
                  initialBody: l10n.notesTemplateShoppingBody,
                );
              },
            ),
            ListTile(
              title: Text(l10n.notesTemplateJournal),
              onTap: () {
                Navigator.pop(ctx);
                _openEditor(
                  initialTitle: l10n.notesTemplateJournal,
                  initialBody: l10n.notesTemplateJournalBody,
                );
              },
            ),
          ],
        ),
      ),
    );
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
    final scheme = Theme.of(context).colorScheme;
    return Theme(
      data: Theme.of(context).copyWith(
        bottomSheetTheme: BottomSheetThemeData(
          backgroundColor: scheme.surface,
          elevation: 0,
          modalBackgroundColor: scheme.surface,
          modalElevation: 1,
        ),
      ),
      child: Scaffold(
        appBar: AppBar(
          title: AppHeader(
            title: AppLocalizations.of(context).notesTitle,
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
              tooltip: AppLocalizations.of(context).notesTrashTooltip,
              onPressed: () => _showTrashSheet(context),
            ),
            IconButton(
              icon: const Icon(Icons.add),
              tooltip: AppLocalizations.of(context).notesNewTooltip,
              onPressed: _showNewNoteMenu,
            ),
          ],
        ),
        body: _NotesListBody(
          repo: widget.repo,
          settingsRepo: widget.settingsRepo,
          hasOtherLinkMembers: widget.hasOtherLinkMembers,
          myLinkId: widget.myLinkId,
          otherLinkMembers: widget.otherLinkMembers,
          onEditNote: (note) => _openEditor(note: note),
        ),
        bottomSheet: NoteQuickAddBar(
          repo: widget.repo,
          todoRepo: widget.todoRepo,
          hasFamilyKey: widget.hasOtherLinkMembers,
          otherLinkMembers: widget.otherLinkMembers,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Notes list body: private + shared sections, or empty state
// ---------------------------------------------------------------------------

class _NotesListBody extends StatelessWidget {
  final NoteRepository repo;
  final SettingsRepository? settingsRepo;
  final bool hasOtherLinkMembers;
  final String? myLinkId;
  final List<({String id, String name})> otherLinkMembers;
  final void Function(PersonalNote note) onEditNote;

  const _NotesListBody({
    required this.repo,
    this.settingsRepo,
    required this.hasOtherLinkMembers,
    required this.myLinkId,
    required this.otherLinkMembers,
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

        final notes = snapshot.data ?? [];
        if (notes.isEmpty) {
          final scheme = Theme.of(context).colorScheme;
          final l10n = AppLocalizations.of(context);
          return Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 88),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.sticky_note_2_outlined,
                    size: 56,
                    color: scheme.onSurfaceVariant,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.notesEmpty,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: scheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.notesEmptyHint,
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
          hasOtherLinkMembers: hasOtherLinkMembers,
          myLinkId: myLinkId,
          otherLinkMembers: otherLinkMembers,
          onEditNote: onEditNote,
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Grouped + draggable notes list (Private / Shared → categories)
// ---------------------------------------------------------------------------

sealed class _NoteListItem {}

class _NoteShareHeaderItem extends _NoteListItem {
  final bool isShared;
  _NoteShareHeaderItem({required this.isShared});
}

class _NoteCategoryHeaderItem extends _NoteListItem {
  final String? category;
  final int count;
  final bool isShared;
  _NoteCategoryHeaderItem({
    required this.category,
    required this.count,
    required this.isShared,
  });
}

class _NoteDataItem extends _NoteListItem {
  final PersonalNote note;
  _NoteDataItem({required this.note});
}

class _NoteGroupedList extends StatefulWidget {
  final List<PersonalNote> notes;
  final NoteRepository repo;
  final SettingsRepository? settingsRepo;
  final bool hasOtherLinkMembers;
  final String? myLinkId;
  final List<({String id, String name})> otherLinkMembers;
  final void Function(PersonalNote note) onEditNote;

  const _NoteGroupedList({
    required this.notes,
    required this.repo,
    this.settingsRepo,
    required this.hasOtherLinkMembers,
    required this.myLinkId,
    required this.otherLinkMembers,
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
    await widget.repo.renameNoteCategory(from: category, to: next);
    final updated = [for (final c in _categoryOrder) c == category ? next : c];
    setState(() => _categoryOrder = updated);
    _saveCategoryOrder(updated);
  }

  void _appendCategorySection({
    required List<_NoteListItem> flatItems,
    required List<PersonalNote> sectionNotes,
    required bool isShared,
  }) {
    if (sectionNotes.isEmpty) return;

    final groups = <String?, List<PersonalNote>>{};
    for (final n in sectionNotes) {
      groups.putIfAbsent(n.category, () => []).add(n);
    }
    for (final list in groups.values) {
      list.sort((a, b) {
        final byOrder = a.sortOrder.compareTo(b.sortOrder);
        if (byOrder != 0) return byOrder;
        return b.createdAt.compareTo(a.createdAt);
      });
    }

    final merged = _mergeOrder(groups.keys);
    final groupKeys = merged.where(groups.containsKey).toList();
    final showCatHeaders =
        groupKeys.length > 1 ||
        (groupKeys.isNotEmpty && groupKeys.first != null);

    for (final cat in groupKeys) {
      if (showCatHeaders) {
        flatItems.add(
          _NoteCategoryHeaderItem(
            category: cat,
            count: groups[cat]!.length,
            isShared: isShared,
          ),
        );
      }
      for (final n in groups[cat]!) {
        flatItems.add(_NoteDataItem(note: n));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final privateNotes = widget.notes.where((n) => !n.isShared).toList();
    final sharedNotes = widget.notes.where((n) => n.isShared).toList();
    final showShareHeaders =
        widget.hasOtherLinkMembers || sharedNotes.isNotEmpty;

    final allCats = widget.notes.map((n) => n.category).toSet();
    final merged = _mergeOrder(allCats);
    if (merged.length != _categoryOrder.length ||
        !merged.every(_categoryOrder.contains)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => _categoryOrder = merged);
      });
    }

    final flatItems = <_NoteListItem>[];
    if (showShareHeaders) {
      if (privateNotes.isNotEmpty) {
        flatItems.add(_NoteShareHeaderItem(isShared: false));
        _appendCategorySection(
          flatItems: flatItems,
          sectionNotes: privateNotes,
          isShared: false,
        );
      }
      if (sharedNotes.isNotEmpty) {
        flatItems.add(_NoteShareHeaderItem(isShared: true));
        _appendCategorySection(
          flatItems: flatItems,
          sectionNotes: sharedNotes,
          isShared: true,
        );
      }
    } else {
      _appendCategorySection(
        flatItems: flatItems,
        sectionNotes: privateNotes,
        isShared: false,
      );
    }

    return ReorderableListView.builder(
      buildDefaultDragHandles: false,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 88),
      itemCount: flatItems.length,
      itemBuilder: (context, index) {
        final item = flatItems[index];

        if (item is _NoteShareHeaderItem) {
          return _NoteShareSectionHeader(
            key: ValueKey(item.isShared ? 'share_shared' : 'share_private'),
            label: item.isShared ? l10n.notesTabShared : l10n.notesTabPrivate,
          );
        }

        if (item is _NoteCategoryHeaderItem) {
          return _NoteCategoryHeader(
            key: ValueKey(
              'cat_${item.isShared ? 's' : 'p'}_${item.category ?? '_'}',
            ),
            label: item.category ?? l10n.commonNoCategory,
            count: item.count,
            index: index,
            canRename: item.category != null,
            onRename: () => _renameCategory(item.category),
          );
        }

        final noteItem = item as _NoteDataItem;
        return Padding(
          key: ValueKey(noteItem.note.id),
          padding: const EdgeInsets.only(bottom: 10),
          child: _NoteCard(
            note: noteItem.note,
            repo: widget.repo,
            myLinkId: widget.myLinkId,
            otherLinkMembers: widget.otherLinkMembers,
            dragIndex: index,
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
    if (items[oldIndex] is _NoteShareHeaderItem) return;
    if (oldIndex < newIndex) newIndex -= 1;

    if (items[oldIndex] is _NoteCategoryHeaderItem) {
      final reordered = [...items]
        ..removeAt(oldIndex)
        ..insert(newIndex, items[oldIndex]);
      final newOrder = <String?>[];
      for (final item in reordered) {
        if (item is _NoteCategoryHeaderItem &&
            !newOrder.contains(item.category)) {
          newOrder.add(item.category);
        }
      }
      setState(() => _categoryOrder = newOrder);
      _saveCategoryOrder(newOrder);
      return;
    }

    final moving = items[oldIndex] as _NoteDataItem;
    final reordered = [...items]
      ..removeAt(oldIndex)
      ..insert(newIndex, moving);

    final updates = <({String id, String? category, int sortOrder})>[];
    bool? currentShared;
    String? cat;
    var posInCat = 0;
    var hasCatHeaders = false;

    for (final item in reordered) {
      if (item is _NoteShareHeaderItem) {
        currentShared = item.isShared;
        cat = null;
        posInCat = 0;
        hasCatHeaders = false;
      } else if (item is _NoteCategoryHeaderItem) {
        currentShared = item.isShared;
        cat = item.category;
        posInCat = 0;
        hasCatHeaders = true;
      } else {
        final noteItem = item as _NoteDataItem;
        if (currentShared != null &&
            noteItem.note.isShared != currentShared) {
          return; // cannot change private ↔ shared by drag
        }
        updates.add((
          id: noteItem.note.id,
          category: hasCatHeaders ? cat : noteItem.note.category,
          sortOrder: posInCat,
        ));
        posInCat++;
      }
    }

    widget.repo.batchUpdateCategoryAndOrder(updates);
  }
}

class _NoteShareSectionHeader extends StatelessWidget {
  final String label;

  const _NoteShareSectionHeader({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 16, 0, 8),
      child: Text(
        label,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _NoteCategoryHeader extends StatelessWidget {
  final String label;
  final int count;
  final int index;
  final bool canRename;
  final VoidCallback onRename;

  const _NoteCategoryHeader({
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
    const trailingSlot = 40.0;
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 8, 0, 2),
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

class _NoteCard extends StatelessWidget {
  final PersonalNote note;
  final NoteRepository repo;
  final String? myLinkId;
  final List<({String id, String name})> otherLinkMembers;
  final int dragIndex;
  final VoidCallback onTap;

  const _NoteCard({
    required this.note,
    required this.repo,
    required this.myLinkId,
    required this.otherLinkMembers,
    required this.dragIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);
    final updatedLabel = formatNoteUpdatedAt(note.updatedAt, l10n);
    final editorLabel = note.isShared
        ? _lastEditorLabel(note, myLinkId, otherLinkMembers, l10n)
        : null;
    final metaLine = editorLabel == null
        ? '${l10n.notesLastModified} · $updatedLabel'
        : '${l10n.notesLastModified} · $updatedLabel · $editorLabel';
    final reminderPassed = note.remindAt != null && isOverdue(note.remindAt!);
    final showMeta =
        note.remindAt != null || note.isContentHidden || note.isLocalOnly;

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
              const SizedBox(height: 6),
              Text(
                metaLine,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: tt.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                  height: 1.4,
                ),
              ),
              if (showMeta) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    if (note.isLocalOnly)
                      _NoteMetaChip(
                        icon: Icons.phonelink_lock_outlined,
                        label: l10n.notesLocalOnlyBadge,
                        color: scheme.onSurfaceVariant,
                      ),
                    if (note.isContentHidden)
                      _NoteMetaChip(
                        icon: Icons.lock_outline,
                        label: l10n.notesLockedBadge,
                        color: scheme.onSurfaceVariant,
                      ),
                    if (note.remindAt != null)
                      _NoteMetaChip(
                        icon: Icons.schedule,
                        label: formatDueDate(
                          note.remindAt!,
                          l10n,
                          allDay: false,
                        ),
                        color: reminderPassed
                            ? scheme.error
                            : scheme.onSurfaceVariant,
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

String? _lastEditorLabel(
  PersonalNote note,
  String? myLinkId,
  List<({String id, String name})> members,
  AppLocalizations l10n,
) {
  final id = note.updatedByLinkId?.trim();
  if (id == null || id.isEmpty) return null;
  if (myLinkId != null && myLinkId.isNotEmpty && id == myLinkId) {
    return l10n.taskAssignToMe;
  }
  final match = members.where((m) => m.id == id).firstOrNull;
  final name = match?.name.trim();
  if (name != null && name.isNotEmpty) return name;
  return null;
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
                        subtitle: Text(
                          '${l10n.notesLastModified} · '
                          '${formatNoteUpdatedAt(note.updatedAt, l10n)}',
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
