import 'package:flutter/material.dart';

import '../../l10n/generated/app_localizations.dart';
import '../../partner/services/partner_proposal_repository.dart';
import '../models/ai_suggestion.dart';
import '../models/enums.dart';
import '../widgets/task_detail_sheet.dart';
import 'ai_suggestion_repository.dart';
import 'suggestion_heuristics.dart';
import 'todo_repository.dart';

String suggestionDisplayTitle(AiSuggestion suggestion, AppLocalizations l10n) {
  if (suggestion.reason != SuggestionReason.categorize) {
    return suggestion.title;
  }
  final label = suggestion.notes?.trim().isNotEmpty == true
      ? suggestion.notes!
      : localizedCategoryName(l10n, suggestion.category);
  final count = suggestion.relatedTaskIds.isEmpty
      ? 0
      : suggestion.relatedTaskIds.length;
  return l10n.suggestCategorizeTitle(count, label);
}

String suggestionDisplayExplanation(
  AiSuggestion suggestion,
  AppLocalizations l10n,
) {
  if (suggestion.reason == SuggestionReason.categorize) {
    final count = suggestion.relatedTaskIds.length;
    return l10n.suggestCategorizeExplanation(count);
  }
  return suggestion.explanation ?? '';
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

Future<void> acceptSelfSuggestion({
  required AiSuggestion suggestion,
  required TodoRepository todoRepo,
  required AiSuggestionRepository suggestionRepo,
  String? listId,
}) async {
  if (suggestion.reason == SuggestionReason.categorize) {
    final label = suggestion.notes?.trim().isNotEmpty == true
        ? suggestion.notes!
        : categoryLabel(suggestion.category);
    await todoRepo.applyCustomCategoryToTasks(
      taskIds: suggestion.relatedTaskIds,
      category: label,
    );
    await suggestionRepo.accept(suggestion.id);
    return;
  }

  if (suggestion.reason == SuggestionReason.stale &&
      suggestion.suggestedDueDate != null) {
    final applied = await todoRepo.applyReminderToOpenTask(
      title: suggestion.title,
      taskId: suggestion.relatedTaskIds.firstOrNull,
      dueDate: suggestion.suggestedDueDate!,
    );
    if (!applied) {
      await todoRepo.createTask(
        title: suggestion.title,
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
      title: suggestion.title,
      notes: suggestion.notes,
      priority: TaskPriority.values[suggestion.priority],
      dueDate: suggestion.suggestedDueDate,
      listId: listId,
    );
  }
  await suggestionRepo.accept(suggestion.id);
}

/// Opens the task sheet pre-filled from [suggestion], including a reminder
/// when [suggestedDueDate] is set. Accepts the suggestion only after save.
Future<void> openSuggestionAsTaskWithReminder({
  required BuildContext context,
  required AiSuggestion suggestion,
  required TodoRepository todoRepo,
  required AiSuggestionRepository suggestionRepo,
  String? listId,
}) async {
  final priorityIndex = suggestion.priority.clamp(
    0,
    TaskPriority.values.length - 1,
  );
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => TaskDetailSheet(
      repo: todoRepo,
      initialListId: listId,
      initialTitle: suggestion.title,
      initialNotes: suggestion.notes,
      initialPriority: TaskPriority.values[priorityIndex],
      initialDueDate: suggestion.suggestedDueDate,
      initialIsAllDay: suggestion.suggestedDueDate == null,
      prefillReminder: suggestion.suggestedDueDate == null,
      onSaved: () => suggestionRepo.accept(suggestion.id),
    ),
  );
}

/// Shows what the partner will see, then sends. Returns false if cancelled
/// or if pairing data is missing.
Future<bool> confirmAndSendSuggestionToPartner({
  required BuildContext context,
  required AiSuggestion suggestion,
  required PartnerProposalRepository proposalRepo,
  required AiSuggestionRepository suggestionRepo,
  required String? myParentId,
}) async {
  final l10n = AppLocalizations.of(context);
  if (myParentId == null || myParentId.isEmpty) {
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.suggestWebDavRequired)));
    }
    return false;
  }

  final confirmed = await showDialog<bool>(
    context: context,
    builder: (ctx) {
      final dialogL10n = AppLocalizations.of(ctx);
      final tt = Theme.of(ctx).textTheme;
      return AlertDialog(
        title: Text(dialogL10n.suggestPartnerSeesTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(suggestion.title, style: tt.titleMedium),
            const SizedBox(height: 8),
            Text(
              suggestion.isPartnerTargeted
                  ? dialogL10n.suggestPartnerSeesGeneric
                  : dialogL10n.suggestPartnerSeesFull,
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
    myParentId: myParentId,
    taskTitle: suggestion.title,
    taskNotes: suggestion.isPartnerTargeted ? null : suggestion.notes,
    taskPriority: TaskPriority.values[suggestion.priority],
    taskDueDate: suggestion.suggestedDueDate,
    autoGenerated: suggestion.isPartnerTargeted,
  );
  await suggestionRepo.accept(suggestion.id);
  if (context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context).suggestSent)),
    );
  }
  return true;
}
