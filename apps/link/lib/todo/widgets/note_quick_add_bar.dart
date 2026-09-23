import 'package:flutter/material.dart';

import '../../l10n/generated/app_localizations.dart';
import '../models/personal_note.dart';
import '../screens/note_editor_screen.dart';
import '../services/note_repository.dart';

/// Persistent text field at the bottom of the notes list.
///
/// Enter (or the ✓ circle) creates a private note with the typed title.
/// The expand icon opens the full note editor for more options.
class NoteQuickAddBar extends StatefulWidget {
  final NoteRepository repo;
  final bool hasFamilyKey;
  final List<({String id, String name})> otherLinkMembers;

  const NoteQuickAddBar({
    super.key,
    required this.repo,
    this.hasFamilyKey = false,
    this.otherLinkMembers = const [],
  });

  @override
  State<NoteQuickAddBar> createState() => _NoteQuickAddBarState();
}

class _NoteQuickAddBarState extends State<NoteQuickAddBar> {
  final _ctrl = TextEditingController();
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _ctrl.addListener(() {
      final has = _ctrl.text.trim().isNotEmpty;
      if (has != _hasText) setState(() => _hasText = has);
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final title = _ctrl.text.trim();
    if (title.isEmpty) return;
    await widget.repo.insert(title: title);
    _ctrl.clear();
  }

  void _openFull() {
    final title = _ctrl.text.trim();
    _ctrl.clear();
    Navigator.of(context).push<PersonalNote?>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => NoteEditorScreen(
          repo: widget.repo,
          initialTitle: title.isEmpty ? null : title,
          hasFamilyKey: widget.hasFamilyKey,
          otherLinkMembers: widget.otherLinkMembers,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
        child: Material(
          color: scheme.surface,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
            side: BorderSide(color: scheme.outline.withAlpha(50)),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 4, 4, 4),
            child: Row(
              children: [
                GestureDetector(
                  key: const Key('note-quick-add-submit'),
                  onTap: _submit,
                  behavior: HitTestBehavior.opaque,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _hasText
                            ? Theme.of(context).colorScheme.primary
                            : scheme.outlineVariant,
                        width: 2,
                      ),
                      color: _hasText
                          ? Theme.of(context).colorScheme.primary
                          : Colors.transparent,
                    ),
                    child: _hasText
                        ? const Icon(Icons.add, size: 18, color: Colors.white)
                        : Icon(
                            Icons.add,
                            size: 18,
                            color: scheme.outlineVariant,
                          ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _ctrl,
                    style: Theme.of(context).textTheme.bodyLarge,
                    decoration: InputDecoration(
                      hintText: l10n.notesQuickAddHint,
                      hintStyle: Theme.of(context).textTheme.bodyLarge
                          ?.copyWith(color: scheme.onSurfaceVariant),
                      border: InputBorder.none,
                      isDense: true,
                    ),
                    textCapitalization: TextCapitalization.sentences,
                    onSubmitted: (_) => _submit(),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.expand_less, color: scheme.onSurfaceVariant),
                  tooltip: l10n.quickAddMoreOptions,
                  onPressed: _openFull,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
