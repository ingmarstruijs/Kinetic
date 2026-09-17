import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import '../../l10n/generated/app_localizations.dart';
import '../../theme/app_theme.dart';
import '../../vault/vault_biometrics.dart';
import '../models/personal_note.dart';
import '../reminder_time.dart';
import '../services/note_repository.dart';
import '../widgets/category_sheet.dart';
import '../widgets/detail_meta_row.dart';
import '../widgets/hour_first_time_picker.dart';

/// Fullscreen editor for creating or editing a note.
class NoteEditorScreen extends StatefulWidget {
  final NoteRepository repo;
  final PersonalNote? note;
  final bool hasFamilyKey;
  final bool initialIsShared;

  const NoteEditorScreen({
    super.key,
    required this.repo,
    this.note,
    this.hasFamilyKey = false,
    this.initialIsShared = false,
  });

  @override
  State<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends State<NoteEditorScreen> {
  late final TextEditingController _titleCtrl;
  late final TextEditingController _bodyCtrl;
  late bool _isShared;
  late bool _isContentHidden;
  late DateTime? _remindAt;
  String? _category;
  bool _saving = false;
  bool _previewMarkdown = false;
  bool _allowPop = false;

  @override
  void initState() {
    super.initState();
    final note = widget.note;
    _titleCtrl = TextEditingController(text: note?.title ?? '');
    _bodyCtrl = TextEditingController(text: note?.body ?? '');
    _isShared = note?.isShared ?? widget.initialIsShared;
    _isContentHidden = note?.isContentHidden ?? false;
    _remindAt = note?.remindAt;
    _category = note?.category;
    _titleCtrl.addListener(_onFieldsChanged);
    _bodyCtrl.addListener(_onFieldsChanged);
  }

  @override
  void dispose() {
    _titleCtrl.removeListener(_onFieldsChanged);
    _bodyCtrl.removeListener(_onFieldsChanged);
    _titleCtrl.dispose();
    _bodyCtrl.dispose();
    super.dispose();
  }

  void _onFieldsChanged() {
    if (mounted) setState(() {});
  }

  bool get _isDirty {
    final note = widget.note;
    if (note == null) {
      return _titleCtrl.text.trim().isNotEmpty ||
          _bodyCtrl.text.isNotEmpty ||
          _isShared != widget.initialIsShared ||
          _isContentHidden ||
          _remindAt != null ||
          _category != null;
    }
    return _titleCtrl.text.trim() != note.title ||
        _bodyCtrl.text != note.body ||
        _isShared != note.isShared ||
        _isContentHidden != note.isContentHidden ||
        _remindAt != note.remindAt ||
        _category != note.category;
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
            onPressed: () => Navigator.of(ctx).pop(_UnsavedAction.discard),
            child: Text(l10n.notesDiscard),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(_UnsavedAction.cancel),
            child: Text(l10n.commonCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(_UnsavedAction.save),
            child: Text(l10n.commonSave),
          ),
        ],
      ),
    );
  }

  Future<void> _onPopInvoked(bool didPop, Object? result) async {
    if (didPop) return;
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

      if (note != null) {
        final updatedNote = note.copyWith(
          title: _titleCtrl.text.trim(),
          body: _bodyCtrl.text,
          isShared: _isShared,
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
          body: _bodyCtrl.text,
          isShared: _isShared,
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

  void _showMarkdownHelp() {
    final l10n = AppLocalizations.of(context);
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (ctx) {
        final scheme = Theme.of(ctx).colorScheme;
        final tt = Theme.of(ctx).textTheme;
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  l10n.notesMarkdownHelpTitle,
                  style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: scheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: SelectableText(
                    l10n.notesMarkdownHelpBody,
                    style: tt.bodyMedium?.copyWith(
                      fontFamily: 'monospace',
                      height: 1.45,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _wrapSelection(String before, String after, {String placeholder = ''}) {
    final text = _bodyCtrl.text;
    final sel = _bodyCtrl.selection;
    final start = sel.isValid ? sel.start : text.length;
    final end = sel.isValid ? sel.end : text.length;
    final selected = text.substring(start, end);
    final inner = selected.isEmpty ? placeholder : selected;
    final inserted = '$before$inner$after';
    final newText = text.replaceRange(start, end, inserted);
    final cursorStart = start + before.length;
    final cursorEnd = cursorStart + inner.length;
    _bodyCtrl.value = TextEditingValue(
      text: newText,
      selection: selected.isEmpty && placeholder.isNotEmpty
          ? TextSelection(baseOffset: cursorStart, extentOffset: cursorEnd)
          : TextSelection.collapsed(offset: cursorEnd + after.length),
    );
  }

  void _insertLink() {
    final l10n = AppLocalizations.of(context);
    final text = _bodyCtrl.text;
    final sel = _bodyCtrl.selection;
    final start = sel.isValid ? sel.start : text.length;
    final end = sel.isValid ? sel.end : text.length;
    final selected = text.substring(start, end);
    final label = selected.isEmpty ? l10n.notesMdLink : selected;
    const url = 'url';
    final inserted = '[$label]($url)';
    final newText = text.replaceRange(start, end, inserted);
    final urlStart = start + 1 + label.length + 2; // after "]("
    _bodyCtrl.value = TextEditingValue(
      text: newText,
      selection: TextSelection(
        baseOffset: urlStart,
        extentOffset: urlStart + url.length,
      ),
    );
  }

  void _prefixCurrentLine(String prefix) {
    final text = _bodyCtrl.text;
    final sel = _bodyCtrl.selection;
    final offset = sel.isValid
        ? sel.baseOffset.clamp(0, text.length).toInt()
        : text.length;
    final lineStart = offset == 0 ? 0 : text.lastIndexOf('\n', offset - 1) + 1;
    final lineEndIndex = text.indexOf('\n', offset);
    final lineEnd = lineEndIndex == -1 ? text.length : lineEndIndex;
    final line = text.substring(lineStart, lineEnd);

    final String nextLine;
    final int delta;
    if (line.startsWith(prefix)) {
      nextLine = line.substring(prefix.length);
      delta = -prefix.length;
    } else {
      nextLine = '$prefix$line';
      delta = prefix.length;
    }

    final newText = text.replaceRange(lineStart, lineEnd, nextLine);
    final cursor = (offset + delta).clamp(0, newText.length).toInt();
    _bodyCtrl.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: cursor),
    );
  }

  static final _listLinePattern = RegExp(
    r'^(\s*)(- \[ \]\s|- \[[xX]\]\s|[*+-]\s|\d+\.\s)(.*)$',
  );

  bool _applyingListContinue = false;

  /// Continues bullet/checkbox/numbered lists on Enter; empty item exits the list.
  void _onBodyChanged(String value) {
    if (_applyingListContinue) return;
    final sel = _bodyCtrl.selection;
    if (!sel.isValid || !sel.isCollapsed) return;
    final offset = sel.baseOffset;
    if (offset < 1 || value[offset - 1] != '\n') return;

    final lineBreak = offset - 1;
    final lineStart =
        lineBreak == 0 ? 0 : value.lastIndexOf('\n', lineBreak - 1) + 1;
    final prevLine = value.substring(lineStart, lineBreak);
    final match = _listLinePattern.firstMatch(prevLine);
    if (match == null) return;

    final indent = match.group(1)!;
    final marker = match.group(2)!;
    final content = match.group(3)!;

    _applyingListContinue = true;
    try {
      if (content.trim().isEmpty) {
        // Exit list: drop the empty marker line.
        final newText = value.substring(0, lineStart) + value.substring(offset);
        _bodyCtrl.value = TextEditingValue(
          text: newText,
          selection: TextSelection.collapsed(offset: lineStart),
        );
        return;
      }

      final nextPrefix = '$indent${_nextListMarker(marker)}';
      final newText =
          value.substring(0, offset) + nextPrefix + value.substring(offset);
      _bodyCtrl.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(offset: offset + nextPrefix.length),
      );
    } finally {
      _applyingListContinue = false;
    }
  }

  String _nextListMarker(String marker) {
    if (marker.startsWith('- [') || marker.startsWith('* [')) {
      return '- [ ] ';
    }
    final numbered = RegExp(r'^(\d+)\.\s$').firstMatch(marker);
    if (numbered != null) {
      final n = int.parse(numbered.group(1)!) + 1;
      return '$n. ';
    }
    return marker;
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
    const months = [
      'jan',
      'feb',
      'mrt',
      'apr',
      'mei',
      'jun',
      'jul',
      'aug',
      'sep',
      'okt',
      'nov',
      'dec',
    ];
    return '${dt.day} ${months[dt.month - 1]}';
  }

  String _formatTimeOnly(DateTime dt) {
    return '${dt.hour.toString().padLeft(2, '0')}:'
        '${dt.minute.toString().padLeft(2, '0')}';
  }

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
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 4, 0),
              child: Row(
                children: [
                  Expanded(
                    child: SegmentedButton<bool>(
                      segments: [
                        ButtonSegment(
                          value: false,
                          label: Text(l10n.notesEditMarkdown),
                          icon: const Icon(Icons.edit_outlined, size: 18),
                        ),
                        ButtonSegment(
                          value: true,
                          label: Text(l10n.notesPreviewMarkdown),
                          icon: const Icon(Icons.visibility_outlined, size: 18),
                        ),
                      ],
                      selected: {_previewMarkdown},
                      onSelectionChanged: (s) =>
                          setState(() => _previewMarkdown = s.first),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.help_outline),
                    tooltip: l10n.notesMarkdownHelpTooltip,
                    onPressed: _showMarkdownHelp,
                  ),
                ],
              ),
            ),
            if (!_previewMarkdown)
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.fromLTRB(8, 4, 8, 0),
                child: Row(
                  children: [
                    _MarkdownQuickButton(
                      icon: Icons.format_bold,
                      tooltip: l10n.notesMdBold,
                      onPressed: () =>
                          _wrapSelection('**', '**', placeholder: l10n.notesMdBold),
                    ),
                    _MarkdownQuickButton(
                      icon: Icons.format_italic,
                      tooltip: l10n.notesMdItalic,
                      onPressed: () =>
                          _wrapSelection('*', '*', placeholder: l10n.notesMdItalic),
                    ),
                    _MarkdownQuickButton(
                      icon: Icons.title,
                      tooltip: l10n.notesMdHeading,
                      onPressed: () => _prefixCurrentLine('## '),
                    ),
                    _MarkdownQuickButton(
                      icon: Icons.format_list_bulleted,
                      tooltip: l10n.notesMdBullet,
                      onPressed: () => _prefixCurrentLine('- '),
                    ),
                    _MarkdownQuickButton(
                      icon: Icons.check_box_outlined,
                      tooltip: l10n.notesMdCheckbox,
                      onPressed: () => _prefixCurrentLine('- [ ] '),
                    ),
                    _MarkdownQuickButton(
                      icon: Icons.link,
                      tooltip: l10n.notesMdLink,
                      onPressed: _insertLink,
                    ),
                  ],
                ),
              ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                child: _previewMarkdown
                    ? (_bodyCtrl.text.trim().isEmpty
                          ? Text(
                              l10n.notesMarkdownHint,
                              style: tt.bodyLarge?.copyWith(
                                color: scheme.onSurfaceVariant,
                              ),
                            )
                          : Markdown(
                              data: _bodyCtrl.text,
                              padding: EdgeInsets.zero,
                              selectable: true,
                            ))
                    : TextField(
                        controller: _bodyCtrl,
                        style: tt.bodyLarge?.copyWith(height: 1.45),
                        decoration: InputDecoration(
                          hintText: l10n.notesMarkdownHint,
                          hintStyle: tt.bodyLarge?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                          border: InputBorder.none,
                        ),
                        textCapitalization: TextCapitalization.sentences,
                        keyboardType: TextInputType.multiline,
                        maxLines: null,
                        expands: true,
                        textAlignVertical: TextAlignVertical.top,
                        onChanged: _onBodyChanged,
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
                      style: tt.bodyMedium?.copyWith(color: kColorTeal),
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
                label: l10n.notesSharedWithPartner,
                active: _isShared,
                onTap: () => setState(() => _isShared = !_isShared),
                trailing: Switch(
                  value: _isShared,
                  onChanged: (v) => setState(() => _isShared = v),
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
                      color: _isContentHidden ? kColorTeal : null,
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
}

enum _UnsavedAction { save, discard, cancel }

class _MarkdownQuickButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  const _MarkdownQuickButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon, size: 22),
      tooltip: tooltip,
      visualDensity: VisualDensity.compact,
      onPressed: onPressed,
    );
  }
}
