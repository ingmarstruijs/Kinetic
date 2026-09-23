import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';

import '../../l10n/generated/app_localizations.dart';
import '../../theme/app_themes.dart';
import '../../vault/vault_biometrics.dart';
import '../models/personal_note.dart';
import '../reminder_time.dart';
import '../services/note_repository.dart';
import '../widgets/category_sheet.dart';
import '../widgets/detail_meta_row.dart';
import '../widgets/hour_first_time_picker.dart';
import '../widgets/note_markdown_codec.dart';

/// Fullscreen editor for creating or editing a note.
class NoteEditorScreen extends StatefulWidget {
  final NoteRepository repo;
  final PersonalNote? note;
  final bool hasFamilyKey;
  final bool initialIsShared;

  /// Prefill for a new note (ignored when [note] is set).
  final String? initialTitle;

  /// Other link members in the family roster (for selective share).
  final List<({String id, String name})> otherLinkMembers;

  const NoteEditorScreen({
    super.key,
    required this.repo,
    this.note,
    this.hasFamilyKey = false,
    this.initialIsShared = false,
    this.initialTitle,
    this.otherLinkMembers = const [],
  });

  @override
  State<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends State<NoteEditorScreen> {
  late final TextEditingController _titleCtrl;
  late final QuillController _quillCtrl;
  late final FocusNode _editorFocus;
  late final ScrollController _editorScroll;
  late final String _baselineBody;
  late bool _isShared;
  late bool _isContentHidden;
  late DateTime? _remindAt;
  String? _category;

  /// null = all link members when shared; non-null = selected subset.
  List<String>? _sharedMemberIds;
  bool _saving = false;
  bool _allowPop = false;

  @override
  void initState() {
    super.initState();
    final note = widget.note;
    _titleCtrl = TextEditingController(
      text: note?.title ?? widget.initialTitle ?? '',
    );
    _quillCtrl = QuillController(
      document: NoteMarkdownCodec.documentFromMarkdown(note?.body ?? ''),
      selection: const TextSelection.collapsed(offset: 0),
    );
    _baselineBody = NoteMarkdownCodec.markdownFromDocument(_quillCtrl.document);
    _editorFocus = FocusNode();
    _editorScroll = ScrollController();
    _isShared = note?.isShared ?? widget.initialIsShared;
    _sharedMemberIds = note?.sharedMemberIds;
    _isContentHidden = note?.isContentHidden ?? false;
    _remindAt = note?.remindAt;
    _category = note?.category;
    _titleCtrl.addListener(_onFieldsChanged);
    _quillCtrl.addListener(_onFieldsChanged);
  }

  @override
  void dispose() {
    _titleCtrl.removeListener(_onFieldsChanged);
    _quillCtrl.removeListener(_onFieldsChanged);
    _titleCtrl.dispose();
    _quillCtrl.dispose();
    _editorFocus.dispose();
    _editorScroll.dispose();
    super.dispose();
  }

  void _onFieldsChanged() {
    if (mounted) setState(() {});
  }

  String get _bodyMarkdown =>
      NoteMarkdownCodec.markdownFromDocument(_quillCtrl.document);

  bool get _isDirty {
    final note = widget.note;
    if (note == null) {
      return _titleCtrl.text.trim().isNotEmpty ||
          _bodyMarkdown.isNotEmpty ||
          _isShared != widget.initialIsShared ||
          _isContentHidden ||
          _remindAt != null ||
          _category != null;
    }
    return _titleCtrl.text.trim() != note.title ||
        _bodyMarkdown != _baselineBody ||
        _isShared != note.isShared ||
        !_sameIdList(_sharedMemberIds, note.sharedMemberIds) ||
        _isContentHidden != note.isContentHidden ||
        _remindAt != note.remindAt ||
        _category != note.category;
  }

  static bool _sameIdList(List<String>? a, List<String>? b) {
    if (a == null && b == null) return true;
    if (a == null || b == null) return false;
    if (a.length != b.length) return false;
    final sa = {...a};
    return b.every(sa.contains);
  }

  Future<void> _popAllowed([PersonalNote? result]) async {
    _allowPop = true;
    if (!mounted) return;
    Navigator.of(context).pop(result);
  }

  Future<_UnsavedAction?> _askUnsavedAction() {
    final l10n = AppLocalizations.of(context);
    return showDialog<_UnsavedAction>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.notesUnsavedTitle),
        content: Text(l10n.notesUnsavedBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, _UnsavedAction.cancel),
            child: Text(l10n.commonCancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, _UnsavedAction.discard),
            child: Text(l10n.notesDiscard),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, _UnsavedAction.save),
            child: Text(l10n.commonSave),
          ),
        ],
      ),
    );
  }

  Future<void> _onPopInvoked(bool didPop, Object? result) async {
    if (didPop || _allowPop) return;
    if (!_isDirty) {
      await _popAllowed();
      return;
    }
    final action = await _askUnsavedAction();
    if (!mounted) return;
    if (action == _UnsavedAction.save) {
      await _save();
    } else if (action == _UnsavedAction.discard) {
      await _popAllowed();
    }
  }

  Future<void> _setContentHidden(bool value) async {
    if (!value) {
      setState(() => _isContentHidden = false);
      return;
    }
    final l10n = AppLocalizations.of(context);
    final result = await VaultBiometrics.authenticate(
      reason: l10n.notesUnlockReason,
    );
    if (!mounted) return;
    if (result == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.notesHideNeedsDeviceLock)),
      );
      return;
    }
    if (result != true) return;
    setState(() => _isContentHidden = true);
  }

  Future<void> _save() async {
    if (_titleCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).notesTitleRequired)),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      final note = widget.note;
      late final PersonalNote savedNote;
      final body = _bodyMarkdown;

      if (note != null) {
        final updatedNote = note.copyWith(
          title: _titleCtrl.text.trim(),
          body: body,
          isShared: _isShared,
          sharedMemberIds: _isShared ? _sharedMemberIds : null,
          clearSharedMemberIds:
              !_isShared ||
              _sharedMemberIds == null ||
              _sharedMemberIds!.isEmpty,
          isContentHidden: _isContentHidden,
          remindAt: _remindAt,
          clearRemindAt: _remindAt == null,
          category: _category,
          clearCategory: _category == null,
        );
        await widget.repo.update(updatedNote);
        savedNote = updatedNote;
      } else {
        savedNote = await widget.repo.insert(
          title: _titleCtrl.text.trim(),
          body: body,
          isShared: _isShared,
          sharedMemberIds: _isShared ? _sharedMemberIds : null,
          isContentHidden: _isContentHidden,
          remindAt: _remindAt,
          category: _category,
        );
      }

      if (mounted) await _popAllowed(savedNote);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).commonSaveError('$e')),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _pickCategory() async {
    final categories = await widget.repo.watchNoteCategories().first;
    if (!mounted) return;
    final result = await showCategoryPicker(
      context: context,
      existingCategories: categories,
      currentCategory: _category,
    );
    if (result != null && mounted) {
      setState(() => _category = result.isEmpty ? null : result);
    }
  }

  Future<void> _pickReminder() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: _remindAt ?? now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (date == null || !mounted) return;

    final time = await showHourFirstTimePicker(
      context: context,
      initialTime: _remindAt != null
          ? TimeOfDay.fromDateTime(_remindAt!)
          : TimeOfDay.fromDateTime(suggestedReminderAt(DateTime.now())),
    );
    if (time == null || !mounted) return;

    setState(() {
      _remindAt = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppLocalizations.of(context).notesDeleteTitle),
        content: Text(AppLocalizations.of(context).notesDeleteBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(AppLocalizations.of(context).commonCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(AppLocalizations.of(context).commonDelete),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    try {
      await widget.repo.delete(widget.note!.id);
      if (mounted) await _popAllowed();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).commonDeleteError('$e')),
          ),
        );
      }
    }
  }

  String _formatDateOnly(DateTime dt) {
    return formatMediumDate(dt, AppLocalizations.of(context));
  }

  String _formatTimeOnly(DateTime dt) {
    return formatClockTime(dt, AppLocalizations.of(context));
  }

  static const _toolbarConfig = QuillSimpleToolbarConfig(
    multiRowsDisplay: false,
    showFontFamily: false,
    showFontSize: false,
    showSmallButton: false,
    showUnderLineButton: false,
    showLineHeightButton: false,
    showStrikeThrough: false,
    showInlineCode: false,
    showColorButton: false,
    showBackgroundColorButton: false,
    showClearFormat: false,
    showAlignmentButtons: false,
    showHeaderStyle: true,
    showListNumbers: false,
    showListBullets: true,
    showListCheck: true,
    showCodeBlock: false,
    showQuote: false,
    showIndent: false,
    showLink: true,
    showUndo: true,
    showRedo: true,
    showSearchButton: false,
    showSubscript: false,
    showSuperscript: false,
    showDividers: false,
    headerStyleType: HeaderStyleType.buttons,
  );

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;

    return PopScope(
      canPop: _allowPop || !_isDirty,
      onPopInvokedWithResult: _onPopInvoked,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            widget.note == null ? l10n.notesNewTooltip : l10n.notesTitle,
          ),
          actions: [
            if (widget.note != null)
              IconButton(
                icon: const Icon(Icons.delete_outline),
                color: scheme.error,
                tooltip: l10n.commonDelete,
                onPressed: _saving ? null : _confirmDelete,
              ),
            const SizedBox(width: 8),
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: FilledButton(
                onPressed: _saving ? null : _save,
                child: Text(
                  widget.note == null ? l10n.commonAdd : l10n.commonSave,
                ),
              ),
            ),
          ],
        ),
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                child: TextField(
                  controller: _titleCtrl,
                  autofocus: widget.note == null,
                  style: tt.headlineSmall?.copyWith(fontWeight: FontWeight.w600),
                  decoration: InputDecoration(
                    hintText: l10n.commonTitle,
                    hintStyle: tt.headlineSmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                    border: InputBorder.none,
                  ),
                  textCapitalization: TextCapitalization.sentences,
                ),
              ),
              QuillSimpleToolbar(
                controller: _quillCtrl,
                config: _toolbarConfig,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
                  child: QuillEditor.basic(
                    controller: _quillCtrl,
                    focusNode: _editorFocus,
                    scrollController: _editorScroll,
                    config: QuillEditorConfig(
                      placeholder: l10n.notesBodyHint,
                      padding: EdgeInsets.zero,
                      autoFocus: false,
                      expands: true,
                      customStyles: DefaultStyles(
                        paragraph: DefaultTextBlockStyle(
                          tt.bodyLarge?.copyWith(height: 1.45) ??
                              const TextStyle(fontSize: 16, height: 1.45),
                          HorizontalSpacing.zero,
                          VerticalSpacing.zero,
                          VerticalSpacing.zero,
                          null,
                        ),
                        placeHolder: DefaultTextBlockStyle(
                          tt.bodyLarge?.copyWith(
                                height: 1.45,
                                color: scheme.onSurfaceVariant,
                              ) ??
                              TextStyle(
                                fontSize: 16,
                                height: 1.45,
                                color: scheme.onSurfaceVariant,
                              ),
                          HorizontalSpacing.zero,
                          VerticalSpacing.zero,
                          VerticalSpacing.zero,
                          null,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const Divider(height: 1),
              DetailMetaRow(
                icon: Icons.alarm_outlined,
                label: l10n.commonReminder,
                active: _remindAt != null,
                onTap: _pickReminder,
                titleWidget: _remindAt != null
                    ? Text(
                        '${_formatDateOnly(_remindAt!.toLocal())} · '
                        '${_formatTimeOnly(_remindAt!.toLocal())}',
                        style: tt.bodyMedium?.copyWith(color: scheme.primary),
                      )
                    : null,
                trailing: _remindAt != null
                    ? IconButton(
                        icon: const Icon(Icons.close, size: 16),
                        onPressed: () => setState(() => _remindAt = null),
                      )
                    : null,
              ),
              DetailMetaRow(
                icon: Icons.label_outline,
                label: _category ?? l10n.taskAddCategory,
                active: _category != null,
                onTap: _pickCategory,
                trailing: _category != null
                    ? IconButton(
                        icon: const Icon(Icons.close, size: 16),
                        onPressed: () => setState(() => _category = null),
                      )
                    : null,
              ),
              if (widget.hasFamilyKey)
                DetailMetaRow(
                  icon: Icons.people_outline,
                  label: _shareLabel(l10n),
                  active: _isShared,
                  onTap: () => _toggleShare(l10n),
                  trailing: Switch(
                    value: _isShared,
                    onChanged: (v) async {
                      if (v) {
                        await _enableShare(l10n);
                      } else {
                        setState(() {
                          _isShared = false;
                          _sharedMemberIds = null;
                        });
                      }
                    },
                  ),
                ),
              DetailMetaRow(
                icon: Icons.lock_outline,
                label: l10n.notesHideContent,
                active: _isContentHidden,
                onTap: () => _setContentHidden(!_isContentHidden),
                titleWidget: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.notesHideContent,
                      style: tt.bodyMedium?.copyWith(
                        color: _isContentHidden ? scheme.primary : null,
                      ),
                    ),
                    Text(
                      l10n.notesHideContentHint,
                      style: tt.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                trailing: Switch(
                  value: _isContentHidden,
                  onChanged: _setContentHidden,
                ),
              ),
              SizedBox(height: MediaQuery.of(context).padding.bottom + 8),
            ],
          ),
        ),
      ),
    );
  }

  String _shareLabel(AppLocalizations l10n) {
    if (!_isShared) return l10n.notesSharedWithPartner;
    final ids = _sharedMemberIds;
    if (ids == null || ids.isEmpty) return l10n.notesShareAllAdults;
    if (ids.length == 1 && widget.otherLinkMembers.length == 1) {
      return l10n.notesSharedWithPartner;
    }
    return l10n.notesShareAudienceHint;
  }

  Future<void> _toggleShare(AppLocalizations l10n) async {
    if (_isShared) {
      setState(() {
        _isShared = false;
        _sharedMemberIds = null;
      });
      return;
    }
    await _enableShare(l10n);
  }

  Future<void> _enableShare(AppLocalizations l10n) async {
    final members = widget.otherLinkMembers;
    if (members.length <= 1) {
      setState(() {
        _isShared = true;
        _sharedMemberIds = null;
      });
      return;
    }

    final selected = <String>{...?_sharedMemberIds};
    final result = await showModalBottomSheet<List<String>?>(
      context: context,
      showDragHandle: true,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModal) {
            return SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    title: Text(l10n.notesSharePickAdults),
                  ),
                  CheckboxListTile(
                    title: Text(l10n.notesShareAllAdults),
                    value: selected.isEmpty,
                    onChanged: (_) {
                      setModal(() => selected.clear());
                    },
                  ),
                  for (final a in members)
                    CheckboxListTile(
                      title: Text(a.name),
                      value: selected.contains(a.id),
                      onChanged: (v) {
                        setModal(() {
                          if (v == true) {
                            selected.add(a.id);
                          } else {
                            selected.remove(a.id);
                          }
                        });
                      },
                    ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: FilledButton(
                      onPressed: () => Navigator.pop(
                        ctx,
                        selected.isEmpty ? <String>[] : selected.toList(),
                      ),
                      child: Text(l10n.commonSave),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
    if (!mounted || result == null) return;
    setState(() {
      _isShared = true;
      _sharedMemberIds = result.isEmpty ? null : result;
    });
  }
}

enum _UnsavedAction { save, discard, cancel }
