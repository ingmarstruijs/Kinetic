import 'package:flutter/material.dart';

import '../../l10n/generated/app_localizations.dart';
import '../../partner/services/partner_proposal_repository.dart';
import '../models/ai_suggestion.dart';
import '../models/enums.dart';
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
    case SuggestionReason.partnerComplement:
      return _partnerTitle(
            l10n,
            _idAfterPrefix(suggestion.dedupeKey, 'partnerComplement:'),
          ) ??
          suggestion.title;
    case SuggestionReason.calendar:
      return _calendarTitle(l10n, _calendarId(suggestion)) ?? suggestion.title;
    case SuggestionReason.habit:
    case SuggestionReason.seasonal:
    case SuggestionReason.stale:
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
    case SuggestionReason.partnerComplement:
      return _partnerExplanation(
            l10n,
            _idAfterPrefix(suggestion.dedupeKey, 'partnerComplement:'),
          ) ??
          (suggestion.explanation ?? '');
    case SuggestionReason.calendar:
      return _calendarExplanation(l10n, _calendarId(suggestion)) ??
          (suggestion.explanation ?? '');
    case SuggestionReason.habit:
    case SuggestionReason.seasonal:
    case SuggestionReason.stale:
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

String? _partnerTitle(AppLocalizations l10n, String? familyId) =>
    switch (familyId) {
      'school' => l10n.suggestPartnerTitleSchool,
      'household' => l10n.suggestPartnerTitleHousehold,
      'health' => l10n.suggestPartnerTitleHealth,
      'sport' => l10n.suggestPartnerTitleSport,
      'admin' => l10n.suggestPartnerTitleAdmin,
      _ => null,
    };

String? _partnerExplanation(AppLocalizations l10n, String? familyId) =>
    switch (familyId) {
      'school' => l10n.suggestPartnerExplanationSchool,
      'household' => l10n.suggestPartnerExplanationHousehold,
      'health' => l10n.suggestPartnerExplanationHealth,
      'sport' => l10n.suggestPartnerExplanationSport,
      'admin' => l10n.suggestPartnerExplanationAdmin,
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
  if (suggestion.reason == SuggestionReason.stale &&
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

  final title = suggestionDisplayTitle(suggestion, l10n);
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
            Text(title, style: tt.titleMedium),
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
    taskTitle: title,
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
