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
  final String? myLinkId;
  final List<({String id, String name})> otherLinkMembers;

  const NotesScreen({
    super.key,
    required this.repo,
    this.settingsRepo,
    this.syncStatus,
    this.partnerPaired = false,
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
                  tooltip: AppLocalizations.of(context).tasksSyncOffline,
                  icon: Icon(
                    Icons.cloud_off_outlined,
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
      ),
      body: _NotesListBody(
        repo: widget.repo,
        partnerPaired: widget.partnerPaired,
        myLinkId: widget.myLinkId,
        otherLinkMembers: widget.otherLinkMembers,
        onEditNote: (note) => _openEditor(note: note),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openEditor(),
        tooltip: AppLocalizations.of(context).notesNewTooltip,
        child: const Icon(Icons.add),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Notes list body: private + shared sections, or empty state
// ---------------------------------------------------------------------------

class _NotesListBody extends StatelessWidget {
  final NoteRepository repo;
  final bool partnerPaired;
  final String? myLinkId;
  final List<({String id, String name})> otherLinkMembers;
  final void Function(PersonalNote note) onEditNote;

  const _NotesListBody({
    required this.repo,
    required this.partnerPaired,
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
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
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
          partnerPaired: partnerPaired,
          myLinkId: myLinkId,
          otherLinkMembers: otherLinkMembers,
          onEditNote: onEditNote,
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Grouped + draggable notes list (Private / Shared sections)
// ---------------------------------------------------------------------------

sealed class _NoteListItem {}

class _NoteHeaderItem extends _NoteListItem {
  final bool isShared;
  _NoteHeaderItem({required this.isShared});
}

class _NoteDataItem extends _NoteListItem {
  final PersonalNote note;
  _NoteDataItem({required this.note});
}

class _NoteGroupedList extends StatelessWidget {
  final List<PersonalNote> notes;
  final NoteRepository repo;
  final bool partnerPaired;
  final String? myLinkId;
  final List<({String id, String name})> otherLinkMembers;
  final void Function(PersonalNote note) onEditNote;

  const _NoteGroupedList({
    required this.notes,
    required this.repo,
    required this.partnerPaired,
    required this.myLinkId,
    required this.otherLinkMembers,
    required this.onEditNote,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final privateNotes = notes.where((n) => !n.isShared).toList();
    final sharedNotes = notes.where((n) => n.isShared).toList();
    final showSharedSection = partnerPaired || sharedNotes.isNotEmpty;
    final showHeaders = showSharedSection;

    final flatItems = <_NoteListItem>[];
    if (showHeaders) {
      if (privateNotes.isNotEmpty) {
        flatItems.add(_NoteHeaderItem(isShared: false));
        for (final n in privateNotes) {
          flatItems.add(_NoteDataItem(note: n));
        }
      }
      if (sharedNotes.isNotEmpty) {
        flatItems.add(_NoteHeaderItem(isShared: true));
        for (final n in sharedNotes) {
          flatItems.add(_NoteDataItem(note: n));
        }
      }
    } else {
      for (final n in privateNotes) {
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
          return _NoteSectionHeader(
            key: ValueKey(item.isShared ? 'header_shared' : 'header_private'),
            label: item.isShared ? l10n.notesTabShared : l10n.notesTabPrivate,
          );
        }

        final noteItem = item as _NoteDataItem;
        return Padding(
          key: ValueKey(noteItem.note.id),
          padding: const EdgeInsets.only(bottom: 10),
          child: _NoteCard(
            note: noteItem.note,
            repo: repo,
            myLinkId: myLinkId,
            otherLinkMembers: otherLinkMembers,
            dragIndex: index,
            onTap: () => onEditNote(noteItem.note),
          ),
        );
      },
      onReorder: (oldIndex, newIndex) {
        _onReorder(flatItems, oldIndex, newIndex);
      },
    );
  }

  void _onReorder(List<_NoteListItem> items, int oldIndex, int newIndex) {
    if (items[oldIndex] is _NoteHeaderItem) return;
    if (oldIndex < newIndex) newIndex -= 1;

    final moving = items[oldIndex] as _NoteDataItem;
    final reordered = [...items]
      ..removeAt(oldIndex)
      ..insert(newIndex, moving);

    // Keep notes inside their Private / Shared section.
    bool? sectionShared;
    for (final item in reordered) {
      if (item is _NoteHeaderItem) {
        sectionShared = item.isShared;
      } else if (item is _NoteDataItem) {
        if (sectionShared != null && item.note.isShared != sectionShared) {
          return;
        }
      }
    }

    final updates = <({String id, String? category, int sortOrder})>[];
    bool? currentShared;
    var posInSection = 0;

    for (final item in reordered) {
      if (item is _NoteHeaderItem) {
        currentShared = item.isShared;
        posInSection = 0;
      } else {
        final noteItem = item as _NoteDataItem;
        if (currentShared != null && noteItem.note.isShared != currentShared) {
          return;
        }
        updates.add((
          id: noteItem.note.id,
          category: noteItem.note.category,
          sortOrder: posInSection,
        ));
        posInSection++;
      }
    }

    repo.batchUpdateCategoryAndOrder(updates);
  }
}

class _NoteSectionHeader extends StatelessWidget {
  final String label;

  const _NoteSectionHeader({super.key, required this.label});

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
    final showMeta = note.remindAt != null || note.isContentHidden;

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
