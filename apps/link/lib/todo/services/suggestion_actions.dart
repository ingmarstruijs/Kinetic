import 'package:flutter/material.dart';

import '../../l10n/generated/app_localizations.dart';
import '../../family/proposals/link_member_proposal_repository.dart';
import '../../theme/app_themes.dart';
import '../models/ai_suggestion.dart';
import '../models/enums.dart';
import '../models/personal_task.dart';
import 'ai_suggestion_repository.dart';
import 'suggestion_heuristics.dart';
import 'todo_repository.dart';

String suggestionDisplayTitle(AiSuggestion suggestion, AppLocalizations l10n) {
  switch (suggestion.reason) {
    case SuggestionReason.categorize:
      final label = suggestion.notes?.trim().isNotEmpty == true
          ? suggestion.notes!
          : localizedCategoryName(l10n, suggestion.category);
      final count = suggestion.relatedTaskIds.isEmpty
          ? 0
          : suggestion.relatedTaskIds.length;
      return l10n.suggestCategorizeTitle(count, label);
    case SuggestionReason.loadBalance:
      return _loadBalanceTitle(l10n, suggestion.category);
    case SuggestionReason.familyMemberComplement:
      return _familyMemberTitle(
            l10n,
            _idAfterPrefix(suggestion.dedupeKey, 'familyMemberComplement:'),
          ) ??
          suggestion.title;
    case SuggestionReason.calendar:
      return _calendarTitle(l10n, _calendarId(suggestion)) ?? suggestion.title;
    case SuggestionReason.habit:
    case SuggestionReason.seasonal:
    case SuggestionReason.stale:
    case SuggestionReason.overdue:
      return suggestion.title;
  }
}

String suggestionDisplayExplanation(
  AiSuggestion suggestion,
  AppLocalizations l10n,
) {
  switch (suggestion.reason) {
    case SuggestionReason.categorize:
      return l10n.suggestCategorizeExplanation(
        suggestion.relatedTaskIds.length,
      );
    case SuggestionReason.loadBalance:
      final category = localizedCategoryName(l10n, suggestion.category);
      final count = suggestion.relatedTaskIds.length;
      if (count == 0) {
        return l10n.suggestLoadBalanceExplanationGeneric(category);
      }
      return l10n.suggestLoadBalanceExplanation(count, category);
    case SuggestionReason.familyMemberComplement:
      return _familyMemberExplanation(
            l10n,
            _idAfterPrefix(suggestion.dedupeKey, 'familyMemberComplement:'),
          ) ??
          (suggestion.explanation ?? '');
    case SuggestionReason.calendar:
      return _calendarExplanation(l10n, _calendarId(suggestion)) ??
          (suggestion.explanation ?? '');
    case SuggestionReason.habit:
    case SuggestionReason.seasonal:
    case SuggestionReason.stale:
    case SuggestionReason.overdue:
      return suggestion.explanation ?? '';
  }
}

String localizedCategoryName(AppLocalizations l10n, String categoryName) {
  return switch (categoryName) {
    'household' => l10n.categoryHousehold,
    'health' => l10n.categoryHealth,
    'admin' => l10n.categoryAdmin,
    'school' => l10n.categorySchool,
    'finance' => l10n.categoryFinance,
    _ => l10n.categoryOther,
  };
}

String localizedMonthName(AppLocalizations l10n, int month) => switch (month) {
  1 => l10n.monthJanuary,
  2 => l10n.monthFebruary,
  3 => l10n.monthMarch,
  4 => l10n.monthApril,
  5 => l10n.monthMay,
  6 => l10n.monthJune,
  7 => l10n.monthJuly,
  8 => l10n.monthAugust,
  9 => l10n.monthSeptember,
  10 => l10n.monthOctober,
  11 => l10n.monthNovember,
  _ => l10n.monthDecember,
};

String _loadBalanceTitle(AppLocalizations l10n, String category) =>
    switch (category) {
      'household' => l10n.suggestLoadBalanceTitleHousehold,
      'health' => l10n.suggestLoadBalanceTitleHealth,
      'admin' => l10n.suggestLoadBalanceTitleAdmin,
      'school' => l10n.suggestLoadBalanceTitleSchool,
      'finance' => l10n.suggestLoadBalanceTitleFinance,
      _ => l10n.suggestLoadBalanceTitleOther,
    };

String? _familyMemberTitle(AppLocalizations l10n, String? familyId) =>
    switch (familyId) {
      'school' => l10n.suggestFamilyMemberTitleSchool,
      'household' => l10n.suggestFamilyMemberTitleHousehold,
      'health' => l10n.suggestFamilyMemberTitleHealth,
      'sport' => l10n.suggestFamilyMemberTitleSport,
      'admin' => l10n.suggestFamilyMemberTitleAdmin,
      _ => null,
    };

String? _familyMemberExplanation(AppLocalizations l10n, String? familyId) =>
    switch (familyId) {
      'school' => l10n.suggestFamilyMemberExplanationSchool,
      'household' => l10n.suggestFamilyMemberExplanationHousehold,
      'health' => l10n.suggestFamilyMemberExplanationHealth,
      'sport' => l10n.suggestFamilyMemberExplanationSport,
      'admin' => l10n.suggestFamilyMemberExplanationAdmin,
      _ => null,
    };

String? _calendarTitle(AppLocalizations l10n, String? id) => switch (id) {
  'tax-return' => l10n.suggestCalendarTaxTitle,
  'school-supplies' => l10n.suggestCalendarSchoolTitle,
  'christmas' => l10n.suggestCalendarChristmasTitle,
  _ => null,
};

String? _calendarExplanation(AppLocalizations l10n, String? id) => switch (id) {
  'tax-return' => l10n.suggestCalendarTaxExplanation,
  'school-supplies' => l10n.suggestCalendarSchoolExplanation,
  'christmas' => l10n.suggestCalendarChristmasExplanation,
  _ => null,
};

String? _idAfterPrefix(String key, String prefix) {
  if (!key.startsWith(prefix)) return null;
  final id = key.substring(prefix.length);
  return id.isEmpty ? null : id;
}

String? _calendarId(AiSuggestion suggestion) {
  final fromKey = _idAfterPrefix(suggestion.dedupeKey, 'calendar:');
  if (fromKey != null) return fromKey;
  for (final prompt in calendarPrompts) {
    if (suggestion.title == prompt.title) return prompt.id;
  }
  return null;
}

Future<void> acceptSelfSuggestion({
  required AiSuggestion suggestion,
  required TodoRepository todoRepo,
  required AiSuggestionRepository suggestionRepo,
  required AppLocalizations l10n,
  String? listId,
}) async {
  if (suggestion.reason == SuggestionReason.categorize) {
    final label = suggestion.notes?.trim().isNotEmpty == true
        ? suggestion.notes!
        : localizedCategoryName(l10n, suggestion.category);
    await todoRepo.applyCustomCategoryToTasks(
      taskIds: suggestion.relatedTaskIds,
      category: label,
    );
    await suggestionRepo.accept(suggestion.id);
    return;
  }

  final title = suggestionDisplayTitle(suggestion, l10n);
  if ((suggestion.reason == SuggestionReason.stale ||
          suggestion.reason == SuggestionReason.overdue) &&
      suggestion.suggestedDueDate != null) {
    final applied = await todoRepo.applyReminderToOpenTask(
      title: suggestion.title,
      taskId: suggestion.relatedTaskIds.firstOrNull,
      dueDate: suggestion.suggestedDueDate!,
    );
    if (!applied) {
      await todoRepo.createTask(
        title: title,
        notes: suggestion.notes,
        priority: TaskPriority.values[suggestion.priority],
        dueDate: suggestion.suggestedDueDate,
        isAllDay: false,
        remindAt: suggestion.suggestedDueDate,
        listId: listId,
      );
    }
  } else {
    await todoRepo.createTask(
      title: title,
      notes: suggestion.notes,
      priority: TaskPriority.values[suggestion.priority],
      dueDate: suggestion.suggestedDueDate,
      listId: listId,
    );
  }
  await suggestionRepo.accept(suggestion.id);
}

/// Shows what the family member will see, then sends. Returns false if cancelled
/// or if pairing data is missing.
///
/// For [SuggestionReason.loadBalance], the sender must pick a concrete
/// shareable task so the recipient gets an actionable title.
Future<bool> confirmAndSendSuggestionToFamilyMember({
  required BuildContext context,
  required AiSuggestion suggestion,
  required LinkMemberProposalRepository proposalRepo,
  required AiSuggestionRepository suggestionRepo,
  required String? myLinkId,
  TodoRepository? todoRepo,
  List<({String id, String name})> otherLinkMembers = const [],
}) async {
  final l10n = AppLocalizations.of(context);
  if (myLinkId == null || myLinkId.isEmpty) {
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.suggestWebDavRequired)));
    }
    return false;
  }

  String? toMemberId;
  var recipientName = l10n.familyMemberGenericName;
  if (otherLinkMembers.length > 1) {
    final picked = await showDialog<({String id, String name})>(
      context: context,
      builder: (ctx) {
        final dialogL10n = AppLocalizations.of(ctx);
        return SimpleDialog(
          title: Text(dialogL10n.familyMemberPickerTitle),
          children: [
            for (final member in otherLinkMembers)
              SimpleDialogOption(
                onPressed: () => Navigator.pop(ctx, member),
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.person_outline),
                  title: Text(member.name),
                ),
              ),
          ],
        );
      },
    );
    if (picked == null) return false;
    if (!context.mounted) return false;
    toMemberId = picked.id;
    final name = picked.name.trim();
    if (name.isNotEmpty) recipientName = name;
  } else if (otherLinkMembers.length == 1) {
    toMemberId = otherLinkMembers.first.id;
    final name = otherLinkMembers.first.name.trim();
    if (name.isNotEmpty) recipientName = name;
  }

  PersonalTask? pickedTask;
  if (suggestion.reason == SuggestionReason.loadBalance) {
    if (todoRepo == null) return false;
    final candidates = await _shareableLoadBalanceTasks(
      todoRepo: todoRepo,
      suggestion: suggestion,
    );
    if (candidates.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.suggestPickTaskEmpty)),
        );
      }
      return false;
    }
    if (!context.mounted) return false;
    if (candidates.length == 1) {
      pickedTask = candidates.first;
    } else {
      pickedTask = await showDialog<PersonalTask>(
        context: context,
        builder: (ctx) {
          final dialogL10n = AppLocalizations.of(ctx);
          return SimpleDialog(
            title: Text(dialogL10n.suggestPickTaskTitle),
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
                child: Text(
                  dialogL10n.suggestPickTaskSubtitle,
                  style: Theme.of(ctx).textTheme.bodySmall,
                ),
              ),
              for (final task in candidates)
                SimpleDialogOption(
                  onPressed: () => Navigator.pop(ctx, task),
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.task_alt_outlined),
                    title: Text(task.title),
                    subtitle: task.dueDate != null
                        ? Text(
                            formatDueDate(
                              task.dueDate!,
                              dialogL10n,
                              allDay: task.isAllDay,
                            ),
                          )
                        : null,
                  ),
                ),
            ],
          );
        },
      );
      if (pickedTask == null) return false;
    }
  }

  if (!context.mounted) return false;
  final title = pickedTask?.title ?? suggestionDisplayTitle(suggestion, l10n);
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (ctx) {
      final dialogL10n = AppLocalizations.of(ctx);
      final tt = Theme.of(ctx).textTheme;
      return AlertDialog(
        title: Text(dialogL10n.suggestFamilyMemberSeesTitle(recipientName)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: tt.titleMedium),
            const SizedBox(height: 8),
            Text(
              pickedTask != null
                  ? dialogL10n.suggestPickTaskSubtitle
                  : suggestion.isFamilyMemberTargeted
                      ? dialogL10n.suggestFamilyMemberSeesGeneric
                      : dialogL10n.suggestFamilyMemberSeesFull,
              style: tt.bodySmall,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(dialogL10n.commonCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(dialogL10n.suggestSend),
          ),
        ],
      );
    },
  );
  if (confirmed != true) return false;

  await proposalRepo.createManualProposal(
    myLinkId: myLinkId,
    toMemberId: toMemberId,
    taskTitle: title,
    taskNotes: pickedTask != null
        ? pickedTask.notes
        : (suggestion.isFamilyMemberTargeted ? null : suggestion.notes),
    taskCategory: pickedTask?.category.name ?? suggestion.category,
    taskPriority:
        pickedTask?.priority ?? TaskPriority.values[suggestion.priority],
    taskDueDate: pickedTask?.dueDate ?? suggestion.suggestedDueDate,
    sourceTaskId: pickedTask?.id,
    autoGenerated: suggestion.isFamilyMemberTargeted,
  );
  if (pickedTask != null) {
    await todoRepo?.suppressReminderForSentTask(pickedTask.id);
  }
  await suggestionRepo.accept(suggestion.id);
  if (context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          AppLocalizations.of(context).suggestSent(recipientName),
        ),
      ),
    );
  }
  return true;
}

/// Shareable open tasks for a load-balance send: prefer [relatedTaskIds],
/// otherwise open non-private tasks matching the suggestion category
/// (auto category **or** custom label aliases like "Household" / "Huishouden").
Future<List<PersonalTask>> _shareableLoadBalanceTasks({
  required TodoRepository todoRepo,
  required AiSuggestion suggestion,
}) async {
  final fromIds = <PersonalTask>[];
  for (final id in suggestion.relatedTaskIds) {
    final task = await todoRepo.getTask(id);
    if (task == null || task.isCompleted || task.isPrivate) continue;
    fromIds.add(task);
  }
  if (fromIds.isNotEmpty) return fromIds;

  final open = await todoRepo.watchOpenTasks().first;
  final category = suggestion.category.trim().toLowerCase();
  final matched = [
    for (final task in open)
      if (!task.isPrivate &&
          !task.isCompleted &&
          _taskMatchesLoadCategory(task, category))
        task,
  ];
  if (matched.isNotEmpty) return matched;

  // Last resort: any shareable open task so Send never dead-ends on a stale hint.
  return [
    for (final task in open)
      if (!task.isPrivate && !task.isCompleted) task,
  ];
}

bool _taskMatchesLoadCategory(PersonalTask task, String category) {
  if (category.isEmpty || category == 'other') return true;
  if (task.category.name == category) return true;
  final custom = task.customCategory?.trim().toLowerCase();
  if (custom == null || custom.isEmpty) return false;
  final aliases = categoryNameAliases(category).map((a) => a.toLowerCase());
  for (final alias in aliases) {
    if (custom == alias || custom.contains(alias)) return true;
  }
  return false;
}
