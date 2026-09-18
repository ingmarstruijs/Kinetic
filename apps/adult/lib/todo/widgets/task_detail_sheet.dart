import 'dart:async';

import 'package:flutter/material.dart';
import '../../l10n/generated/app_localizations.dart';
import 'package:kinetic_webdav/kinetic_webdav.dart';

import '../../family/family_connection_service.dart';
import '../../partner/services/partner_proposal_repository.dart';
import '../../sync/webdav_config_repository.dart';
import '../../theme/app_theme.dart';
import '../../todo/models/enums.dart';
import '../../todo/models/personal_task.dart';
import '../../todo/reminder_time.dart';
import '../../todo/services/reminder_proposal_engine.dart';
import '../../todo/services/todo_repository.dart';
import 'category_sheet.dart';
import 'detail_meta_row.dart';
import 'hour_first_time_picker.dart';

// ---------------------------------------------------------------------------
// TaskDetailSheet
//
// Full-screen modal bottom sheet for creating or editing a PersonalTask.
// Pass task=null to create a new one.
// ---------------------------------------------------------------------------

class TaskDetailSheet extends StatefulWidget {
  final PersonalTask? task;
  final TodoRepository repo;
  final PartnerProposalRepository? proposalRepo;
  final String? myParentId;
  final String? initialListId;
  final String? initialTitle;
  final String? initialNotes;
  final TaskPriority? initialPriority;
  final DateTime? initialDueDate;
  final bool? initialIsAllDay;
  final bool prefillReminder;
  final VoidCallback? onSaved;
  final bool hasFamilyKey;
  final bool partnerPaired;
  final WebDavConfigRepository? configRepo;
  final Future<List<PresenceInfo>> Function()? pullPresence;

  /// When set (or [assignToEveryone] is true), saving a new task also
  /// assigns it to kids via [TodoRepository.sendToKids].
  final String? assignToKidId;
  final bool assignToEveryone;

  /// Show the XP reward field (kids create with gamification on).
  final bool showXpReward;

  /// Optional hint under the XP field (e.g. everyone + mixed XP settings).
  final String? xpRewardHint;

  /// Display name for kids assignment banner (kid name or everyone label).
  final String? assignToDisplayName;

  const TaskDetailSheet({
    super.key,
    required this.repo,
    this.task,
    this.proposalRepo,
    this.myParentId,
    this.initialListId,
    this.initialTitle,
    this.initialNotes,
    this.initialPriority,
    this.initialDueDate,
    this.initialIsAllDay,
    this.prefillReminder = false,
    this.onSaved,
    this.hasFamilyKey = false,
    this.partnerPaired = false,
    this.configRepo,
    this.pullPresence,
    this.assignToKidId,
    this.assignToEveryone = false,
    this.showXpReward = false,
    this.xpRewardHint,
    this.assignToDisplayName,
  });

  bool get _isKidsAssignment =>
      assignToEveryone || assignToKidId != null;

  @override
  State<TaskDetailSheet> createState() => _TaskDetailSheetState();
}

class _TaskDetailSheetState extends State<TaskDetailSheet> {
  late final TextEditingController _titleCtrl;
  late final TextEditingController _notesCtrl;
  late final TextEditingController _xpCtrl;

  late TaskPriority _priority;
  DateTime? _dueDate;
  bool _isAllDay = true;
  String? _recurrenceRule;
  String? _listId;
  String? _customCategory;

  bool _saving = false;
  List<ReminderChipProposal> _reminderChips = [];
  List<PersonalTask> _completedTasks = [];
  FamilyMemberStatus? _partnerStatus;
  Timer? _chipDebounce;
  final _reminderEngine = ReminderProposalEngine();
  bool _didPrefillReminder = false;

  @override
  void initState() {
    super.initState();
    final t = widget.task;
    _titleCtrl = TextEditingController(
      text: t?.title ?? widget.initialTitle ?? '',
    );
    _notesCtrl = TextEditingController(
      text: t?.notes ?? widget.initialNotes ?? '',
    );
    _xpCtrl = TextEditingController(text: '${t?.xpReward ?? 10}');
    _priority = t?.priority ?? widget.initialPriority ?? TaskPriority.none;
    _dueDate = t?.dueDate ?? widget.initialDueDate;
    _isAllDay = t?.isAllDay ?? widget.initialIsAllDay ?? true;
    _recurrenceRule = t?.recurrenceRule;
    _listId = t?.listId ?? widget.initialListId;
    _customCategory = t?.customCategory;
    _titleCtrl.addListener(_onTitleChanged);
    _loadCompletedTasks();
    _loadFamilyConnections();
    _refreshReminderChips();
  }

  void _onTitleChanged() {
    _chipDebounce?.cancel();
    _chipDebounce = Timer(const Duration(milliseconds: 300), () {
      if (mounted) _refreshReminderChips();
    });
  }

  Future<void> _loadCompletedTasks() async {
    try {
      final tasks = await widget.repo.watchCompletedTasks().first;
      if (mounted) {
        setState(() => _completedTasks = tasks);
        _refreshReminderChips();
      }
    } catch (_) {}
  }

  Future<void> _loadFamilyConnections() async {
    if (widget.configRepo == null || !widget.partnerPaired) return;
    try {
      final presence = widget.pullPresence != null
          ? await widget.pullPresence!()
          : <PresenceInfo>[];
      final partnerPaired = await widget.configRepo!.isPartnerPaired();
      if (!mounted) return;
      final allowWithoutPresence = widget.pullPresence == null;
      setState(() {
        _partnerStatus = FamilyConnectionService.partnerStatus(
          partnerPaired: partnerPaired,
          presenceList: presence,
          allowWithoutPresence: allowWithoutPresence,
        );
      });
    } catch (_) {}
  }

  void _refreshReminderChips() {
    final chips = _reminderEngine.propose(
      title: _titleCtrl.text,
      category: widget.task?.category,
      completedTasks: _completedTasks,
    );
    var dueDate = _dueDate;
    var isAllDay = _isAllDay;
    if (widget.prefillReminder &&
        !_didPrefillReminder &&
        dueDate == null &&
        chips.isNotEmpty) {
      _didPrefillReminder = true;
      dueDate = chips.first.at.toUtc();
      isAllDay = false;
    }
    setState(() {
      _reminderChips = chips;
      _dueDate = dueDate;
      _isAllDay = isAllDay;
    });
  }

  @override
  void dispose() {
    _chipDebounce?.cancel();
    _titleCtrl.removeListener(_onTitleChanged);
    _titleCtrl.dispose();
    _notesCtrl.dispose();
    _xpCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final title = _titleCtrl.text.trim();
    if (title.isEmpty) return;
    setState(() => _saving = true);

    try {
      final newNotes = _notesCtrl.text.trim();
      if (widget.task == null) {
        final created = await widget.repo.createTask(
          title: title,
          listId: _listId,
          notes: newNotes.isEmpty ? null : newNotes,
          priority: _priority,
          dueDate: _dueDate,
          isAllDay: _isAllDay,
          recurrenceRule: _recurrenceRule,
          isPrivate: false,
          customCategory: _customCategory,
          remindAt: _isAllDay ? null : _dueDate,
        );
        if (widget._isKidsAssignment) {
          await widget.repo.sendToKids(
            created.id,
            targetKidId: widget.assignToEveryone ? null : widget.assignToKidId,
            xpReward: widget.showXpReward
                ? (int.tryParse(_xpCtrl.text.trim()) ?? 10)
                : 0,
          );
        }
      } else {
        await widget.repo.updateTask(
          widget.task!.copyWith(
            title: title,
            notes: newNotes.isEmpty ? null : newNotes,
            clearNotes: newNotes.isEmpty,
            priority: _priority,
            dueDate: _dueDate,
            isAllDay: _isAllDay,
            recurrenceRule: _recurrenceRule,
            isPrivate: false,
            listId: _listId,
            customCategory: _customCategory,
            clearCustomCategory: _customCategory == null,
            clearDueDate: _dueDate == null,
            remindAt: _isAllDay ? null : _dueDate,
            clearRemindAt: _isAllDay || _dueDate == null,
          ),
        );
      }
      widget.onSaved?.call();
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).commonSaveError('$e')),
          ),
        );
      }
    }
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppLocalizations.of(context).taskDeleteTitle),
        content: Text(
          AppLocalizations.of(context).taskDeleteBody(
            _titleCtrl.text.trim().isNotEmpty
                ? _titleCtrl.text.trim()
                : widget.task!.title,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(AppLocalizations.of(context).commonCancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(AppLocalizations.of(context).commonDelete),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    await widget.repo.deleteTask(widget.task!.id);
    if (mounted) Navigator.pop(context);
  }

  bool get _canSendToPartner =>
      widget.partnerPaired &&
      _partnerStatus != null &&
      _partnerStatus!.isConnected;

  void _showSendDialog(BuildContext context) {
    final task = widget.task;
    if (task == null) return;

    if (!_canSendToPartner) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).taskNoConnectedFamily),
        ),
      );
      return;
    }

    if (task.kidsTaskId != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).taskAssignmentCreated),
        ),
      );
      return;
    }

    _sendToPartner(context);
  }

  Future<void> _sendToPartner(BuildContext context) async {
    final task = widget.task;
    if (task == null || widget.proposalRepo == null) return;
    if (_partnerStatus?.isConnected != true) return;

    if (_partnerStatus!.isStale && mounted) {
      final proceed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(AppLocalizations.of(context).taskStaleConnectionTitle),
          content: Text(
            AppLocalizations.of(context).taskStalePartnerBody(
              _partnerStatus!
                  .statusLabel(AppLocalizations.of(context))
                  .toLowerCase(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(AppLocalizations.of(context).commonCancel),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(AppLocalizations.of(context).taskSendAnyway),
            ),
          ],
        ),
      );
      if (proceed != true || !mounted) return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppLocalizations.of(context).taskSendToPartnerTitle),
        content: Text(
          AppLocalizations.of(context).taskSendToPartnerBody(task.title),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(AppLocalizations.of(context).commonCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(AppLocalizations.of(context).commonSend),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    await widget.proposalRepo!.createManualProposal(
      myParentId: widget.myParentId ?? '',
      taskTitle: task.title,
      taskNotes: task.notes,
      taskPriority: task.priority,
      taskDueDate: task.dueDate,
    );
    // Task stays in the sender's list until partner accepts the proposal.
    // When partner accepts, the sync orchestrator will detect the status change
    // and clean up the task automatically.
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Material(
      color: Theme.of(context).colorScheme.surface,
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Drag handle ──────────────────────────────────────────────────
            const SizedBox(height: 8),
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.outlineVariant.withAlpha(80),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            if (widget._isKidsAssignment) ...[
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Icon(
                      widget.assignToEveryone
                          ? Icons.groups_outlined
                          : Icons.child_care_outlined,
                      size: 18,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        widget.assignToEveryone
                            ? AppLocalizations.of(
                                context,
                              ).kidsCreateForEveryoneHint
                            : AppLocalizations.of(context).kidsCreateForName(
                                widget.assignToDisplayName ??
                                    AppLocalizations.of(context).commonKids,
                              ),
                        style: tt.titleSmall?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 12),

            // ── Title ────────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                controller: _titleCtrl,
                autofocus: widget.task == null,
                style: tt.titleLarge,
                decoration: InputDecoration(
                  hintText: AppLocalizations.of(context).taskNameHint,
                  hintStyle: tt.titleLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  border: InputBorder.none,
                ),
                textCapitalization: TextCapitalization.sentences,
                onSubmitted: (_) => _save(),
              ),
            ),

            // ── Notes ────────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                controller: _notesCtrl,
                style: tt.bodyMedium,
                decoration: InputDecoration(
                  hintText: AppLocalizations.of(context).commonNotes,
                  hintStyle: tt.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  border: InputBorder.none,
                ),
                textCapitalization: TextCapitalization.sentences,
                maxLines: null,
              ),
            ),

            const Divider(height: 16),

            // ── Metadata rows ────────────────────────────────────────────────
            // Herinnering row — combined date + time
            DetailMetaRow(
              icon: Icons.alarm_outlined,
              label: AppLocalizations.of(context).commonReminder,
              active: _dueDate != null,
              onTap: _dueDate != null ? null : () => _pickReminder(),
              titleWidget: _dueDate != null
                  ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        InkWell(
                          onTap: _pickDateOnly,
                          borderRadius: BorderRadius.circular(4),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4,
                              vertical: 2,
                            ),
                            child: Text(
                              _formatDateOnly(_dueDate!.toLocal()),
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    color: Theme.of(context).colorScheme.primary,
                                    decoration: TextDecoration.underline,
                                  ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          child: Text(
                            '·',
                            style: TextStyle(
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: _pickTimeOnly,
                          borderRadius: BorderRadius.circular(4),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4,
                              vertical: 2,
                            ),
                            child: Text(
                              _isAllDay
                                  ? AppLocalizations.of(context).taskAddTime
                                  : _formatTimeOnly(_dueDate!.toLocal()),
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    color: Theme.of(context).colorScheme.primary,
                                    decoration: TextDecoration.underline,
                                  ),
                            ),
                          ),
                        ),
                      ],
                    )
                  : null,
              trailing: _dueDate != null
                  ? IconButton(
                      icon: const Icon(Icons.close, size: 16),
                      onPressed: () => setState(() {
                        _dueDate = null;
                        _isAllDay = true;
                        _recurrenceRule = null;
                      }),
                    )
                  : null,
              leadingCheckbox: true,
              checked: _dueDate != null,
              onCheckChanged: (v) {
                if (v) {
                  _setDefaultReminder();
                } else {
                  setState(() {
                    _dueDate = null;
                    _isAllDay = true;
                    _recurrenceRule = null;
                  });
                }
              },
            ),
            // Smart reminder chips — only when no reminder is set
            if (_dueDate == null)
              ListTile(
                dense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                leading: const SizedBox(width: 40),
                title: Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    for (var i = 0; i < _reminderChips.length; i++)
                      Tooltip(
                        message: formatReminderChipExplanation(
                          _reminderChips[i],
                          AppLocalizations.of(context),
                        ),
                        child: ActionChip(
                          avatar: i == 0
                              ? Icon(
                                  Icons.auto_awesome,
                                  size: 14,
                                  color: i == 0 ? Theme.of(context).colorScheme.primary : null,
                                )
                              : null,
                          label: Text(
                            formatReminderChipLabel(
                              _reminderChips[i],
                              AppLocalizations.of(context),
                            ),
                          ),
                          visualDensity: VisualDensity.compact,
                          onPressed: () =>
                              _applyReminderAt(_reminderChips[i].at),
                        ),
                      ),
                  ],
                ),
              ),
            DetailMetaRow(
              icon: Icons.flag_outlined,
              label: _priority == TaskPriority.none
                  ? AppLocalizations.of(context).commonPriority
                  : '${AppLocalizations.of(context).commonPriority}: ${switch (_priority) {
                      TaskPriority.low => AppLocalizations.of(context).commonLow,
                      TaskPriority.medium => AppLocalizations.of(context).commonMedium,
                      TaskPriority.high => AppLocalizations.of(context).commonHigh,
                      TaskPriority.none => AppLocalizations.of(context).commonNone,
                    }}',
              active: _priority != TaskPriority.none,
              color: _priority != TaskPriority.none
                  ? priorityColor(_priority)
                  : null,
              onTap: () => _pickPriority(context),
            ),
            DetailMetaRow(
              icon: Icons.label_outline,
              label:
                  _customCategory ??
                  AppLocalizations.of(context).taskAddCategory,
              active: _customCategory != null,
              onTap: () => _pickCategory(context),
              trailing: _customCategory != null
                  ? IconButton(
                      icon: const Icon(Icons.close, size: 16),
                      onPressed: () => setState(() => _customCategory = null),
                    )
                  : null,
            ),
            if (_dueDate != null)
              DetailMetaRow(
                icon: Icons.repeat,
                label:
                    _recurrenceRule ?? AppLocalizations.of(context).taskRepeat,
                active: _recurrenceRule != null,
                onTap: () => _pickRecurrence(context),
              ),
            if (widget.showXpReward && widget.task == null)
              ListTile(
                dense: true,
                leading: const Icon(Icons.star_outline, size: 20),
                title: Text(AppLocalizations.of(context).taskXpReward),
                subtitle: widget.xpRewardHint == null
                    ? null
                    : Text(
                        widget.xpRewardHint!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurfaceVariant,
                        ),
                      ),
                trailing: SizedBox(
                  width: 72,
                  child: TextField(
                    controller: _xpCtrl,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    decoration: const InputDecoration(
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 6,
                      ),
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ),

            const SizedBox(height: 8),

            // ── Action bar ───────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: Row(
                children: [
                  if (widget.task != null)
                    IconButton(
                      icon: const Icon(Icons.delete_outline),
                      color: Theme.of(context).colorScheme.error,
                      tooltip: AppLocalizations.of(context).commonDelete,
                      onPressed: _saving ? null : () => _confirmDelete(context),
                    ),
                  if (widget.partnerPaired &&
                      widget.proposalRepo != null &&
                      widget.task != null &&
                      widget.task!.kidsTaskId == null)
                    IconButton(
                      icon: const Icon(Icons.send_outlined),
                      tooltip: _canSendToPartner
                          ? AppLocalizations.of(context).taskForward
                          : AppLocalizations.of(context).taskNoConnectedFamily,
                      onPressed: _saving || !_canSendToPartner
                          ? null
                          : () => _showSendDialog(context),
                    ),
                  const Spacer(),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(AppLocalizations.of(context).commonCancel),
                  ),
                  const SizedBox(width: 12),
                  FilledButton(
                    onPressed: _saving ? null : _save,
                    child: Text(
                      widget.task == null
                          ? AppLocalizations.of(context).commonAdd
                          : AppLocalizations.of(context).commonSave,
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

  void _setDefaultReminder() {
    setState(() {
      _dueDate = suggestedReminderAt(DateTime.now()).toUtc();
      _isAllDay = false;
    });
  }

  void _applyReminderAt(DateTime when) {
    setState(() {
      _dueDate = when.toUtc();
      _isAllDay = false;
    });
  }

  Future<void> _pickDateOnly() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate?.toLocal() ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2099),
    );
    if (picked == null || !mounted) return;
    final existing = _dueDate?.toLocal() ?? DateTime.now();
    setState(() {
      _dueDate = DateTime(
        picked.year,
        picked.month,
        picked.day,
        _isAllDay ? 0 : existing.hour,
        _isAllDay ? 0 : existing.minute,
      ).toUtc();
    });
  }

  TimeOfDay _initialPickerTime() {
    if (_dueDate != null && !_isAllDay) {
      final current = _dueDate!.toLocal();
      return TimeOfDay(hour: current.hour, minute: current.minute);
    }
    return TimeOfDay.fromDateTime(suggestedReminderAt(DateTime.now()));
  }

  Future<void> _pickTimeOnly() async {
    final picked = await showHourFirstTimePicker(
      context: context,
      initialTime: _initialPickerTime(),
    );
    if (picked == null || !mounted) return;
    final d = _dueDate?.toLocal() ?? DateTime.now();
    setState(() {
      _dueDate = DateTime(
        d.year,
        d.month,
        d.day,
        picked.hour,
        picked.minute,
      ).toUtc();
      _isAllDay = false;
    });
  }

  Future<void> _pickReminder() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _dueDate?.toLocal() ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2099),
    );
    if (pickedDate == null || !mounted) return;
    final pickedTime = await showHourFirstTimePicker(
      context: context,
      initialTime: _initialPickerTime(),
    );
    if (pickedTime == null || !mounted) return;
    setState(() {
      _dueDate = DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
        pickedTime.hour,
        pickedTime.minute,
      ).toUtc();
      _isAllDay = false;
    });
  }

  String _formatDateOnly(DateTime d) {
    final now = DateTime.now();
    if (d.year == now.year && d.month == now.month && d.day == now.day) {
      return AppLocalizations.of(context).dateToday;
    }
    final tomorrow = now.add(const Duration(days: 1));
    if (d.year == tomorrow.year &&
        d.month == tomorrow.month &&
        d.day == tomorrow.day) {
      return AppLocalizations.of(context).dateTomorrow;
    }
    return '${d.day.toString().padLeft(2, '0')}-${d.month.toString().padLeft(2, '0')}-${d.year}';
  }

  String _formatTimeOnly(DateTime d) {
    return '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _pickCategory(BuildContext context) async {
    final categories = await widget.repo.watchTaskCategories().first;
    if (!mounted) return;
    final result = await showCategoryPicker(
      // ignore: use_build_context_synchronously
      context: context,
      existingCategories: categories,
      currentCategory: _customCategory,
    );
    if (result != null && mounted) {
      setState(() => _customCategory = result.isEmpty ? null : result);
    }
  }

  void _pickPriority(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final p in TaskPriority.values)
              ListTile(
                leading: Icon(
                  Icons.flag,
                  color: p == TaskPriority.none
                      ? Theme.of(context).colorScheme.outlineVariant
                      : priorityColor(p),
                ),
                title: Text(switch (p) {
                  TaskPriority.none => AppLocalizations.of(context).commonNone,
                  TaskPriority.low => AppLocalizations.of(context).commonLow,
                  TaskPriority.medium => AppLocalizations.of(
                    context,
                  ).commonMedium,
                  TaskPriority.high => AppLocalizations.of(context).commonHigh,
                }),
                trailing: _priority == p
                    ? Icon(Icons.check, color: Theme.of(context).colorScheme.primary)
                    : null,
                onTap: () {
                  Navigator.pop(ctx);
                  setState(() => _priority = p);
                },
              ),
          ],
        ),
      ),
    );
  }

  void _pickRecurrence(BuildContext context) {
    // Simple recurrence picker — RRULE strings
    final options = <(String, String)>[
      (AppLocalizations.of(context).taskRecurrenceDaily, 'FREQ=DAILY'),
      (
        AppLocalizations.of(context).taskRecurrenceWeekdays,
        'FREQ=DAILY;BYDAY=MO,TU,WE,TH,FR',
      ),
      (AppLocalizations.of(context).taskRecurrenceWeekly, 'FREQ=WEEKLY'),
      (
        AppLocalizations.of(context).taskRecurrenceBiweekly,
        'FREQ=WEEKLY;INTERVAL=2',
      ),
      (AppLocalizations.of(context).taskRecurrenceMonthly, 'FREQ=MONTHLY'),
    ];
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.block_outlined),
              title: Text(AppLocalizations.of(context).taskRecurrenceNone),
              onTap: () {
                Navigator.pop(ctx);
                setState(() => _recurrenceRule = null);
              },
            ),
            for (final (label, rule) in options)
              ListTile(
                leading: const Icon(Icons.repeat),
                title: Text(label),
                trailing: _recurrenceRule == rule
                    ? Icon(Icons.check, color: Theme.of(context).colorScheme.primary)
                    : null,
                onTap: () {
                  Navigator.pop(ctx);
                  setState(() => _recurrenceRule = rule);
                },
              ),
          ],
        ),
      ),
    );
  }
}
