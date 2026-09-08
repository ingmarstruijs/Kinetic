import 'package:flutter/material.dart';

import '../../l10n/generated/app_localizations.dart';
import '../../partner/services/partner_proposal_repository.dart';
import '../../todo/models/ai_suggestion.dart';
import '../../todo/services/ai_suggestion_repository.dart';
import '../../todo/services/suggestion_actions.dart';
import '../../todo/services/todo_repository.dart';

// ---------------------------------------------------------------------------
// SuggestionBanner — shows one pending AI suggestion at a time.
//
// Shows a dismissable card at the top of the Tasks screen. The banner is
// hidden when there are no pending suggestions.
// ---------------------------------------------------------------------------

class SuggestionBanner extends StatelessWidget {
  final AiSuggestionRepository suggestionRepo;
  final TodoRepository todoRepo;
  final PartnerProposalRepository? proposalRepo;
  final String? myParentId;
  final bool partnerPaired;
  final String? activeListId;
  final bool selfOnly;

  const SuggestionBanner({
    super.key,
    required this.suggestionRepo,
    required this.todoRepo,
    this.proposalRepo,
    this.myParentId,
    this.partnerPaired = false,
    this.activeListId,
    this.selfOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<AiSuggestion>>(
      stream: selfOnly
          ? suggestionRepo.watchPendingSelf()
          : suggestionRepo.watchPending(),
      builder: (context, snapshot) {
        final suggestions = snapshot.data ?? [];
        if (suggestions.isEmpty) return const SizedBox.shrink();

        final suggestion = suggestions.first;
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: SuggestionCard(
            key: ValueKey(suggestion.id),
            suggestion: suggestion,
            suggestionRepo: suggestionRepo,
            todoRepo: todoRepo,
            proposalRepo: proposalRepo,
            myParentId: myParentId,
            partnerPaired: partnerPaired,
            activeListId: activeListId,
          ),
        );
      },
    );
  }
}

class SuggestionCard extends StatelessWidget {
  final AiSuggestion suggestion;
  final AiSuggestionRepository suggestionRepo;
  final TodoRepository todoRepo;
  final PartnerProposalRepository? proposalRepo;
  final String? myParentId;
  final bool partnerPaired;
  final String? activeListId;
  final bool partnerOnly;
  final EdgeInsetsGeometry margin;

  const SuggestionCard({
    super.key,
    required this.suggestion,
    required this.suggestionRepo,
    required this.todoRepo,
    this.proposalRepo,
    this.myParentId,
    required this.partnerPaired,
    this.activeListId,
    this.partnerOnly = false,
    this.margin = const EdgeInsets.fromLTRB(12, 8, 12, 0),
  });

  Future<void> _accept(BuildContext context) async {
    await acceptSelfSuggestion(
      suggestion: suggestion,
      todoRepo: todoRepo,
      suggestionRepo: suggestionRepo,
      listId: activeListId,
    );
  }

  Future<void> _openWithReminder(BuildContext context) async {
    await openSuggestionAsTaskWithReminder(
      context: context,
      suggestion: suggestion,
      todoRepo: todoRepo,
      suggestionRepo: suggestionRepo,
      listId: activeListId,
    );
  }

  Future<void> _sendToPartner(BuildContext context) async {
    if (proposalRepo == null) return;
    await confirmAndSendSuggestionToPartner(
      context: context,
      suggestion: suggestion,
      proposalRepo: proposalRepo!,
      suggestionRepo: suggestionRepo,
      myParentId: myParentId,
    );
  }

  Future<void> _dismiss() async {
    await suggestionRepo.dismiss(suggestion.id);
  }

  Future<void> _snooze() async {
    await suggestionRepo.snooze(suggestion.id);
  }

  bool get _isNewTaskSuggestion =>
      suggestion.reason == SuggestionReason.habit ||
      suggestion.reason == SuggestionReason.seasonal ||
      suggestion.reason == SuggestionReason.calendar;

  String _primaryLabel(AppLocalizations l10n) {
    if (suggestion.reason == SuggestionReason.categorize) {
      return l10n.suggestAddCategory;
    }
    if (suggestion.reason == SuggestionReason.stale) {
      return l10n.tasksAddReminder;
    }
    return l10n.suggestAdd;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final explanation = suggestionDisplayExplanation(suggestion, l10n);

    return GestureDetector(
      onLongPress: () async {
        final ok = await showDialog<bool>(
          context: context,
          builder: (ctx) {
            final dialogL10n = AppLocalizations.of(ctx);
            return AlertDialog(
              title: Text(dialogL10n.suggestSnoozeTitle),
              content: Text(dialogL10n.suggestSnoozeBody),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: Text(dialogL10n.commonCancel),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  child: Text(dialogL10n.suggestSnoozeAction),
                ),
              ],
            );
          },
        );
        if (ok == true) await _snooze();
      },
      child: Card(
        margin: margin,
        color: colorScheme.secondaryContainer,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.lightbulb_outline,
                size: 20,
                color: colorScheme.secondary,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            suggestionDisplayTitle(suggestion, l10n),
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: colorScheme.onSecondaryContainer,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Chip(
                          label: Text(
                            suggestion.reason.label(l10n),
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: colorScheme.onSecondaryContainer,
                            ),
                          ),
                          padding: EdgeInsets.zero,
                          visualDensity: VisualDensity.compact,
                          backgroundColor: colorScheme.secondaryContainer,
                          side: BorderSide(color: colorScheme.outline),
                        ),
                      ],
                    ),
                    if (explanation.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        explanation,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSecondaryContainer.withValues(
                            alpha: 0.8,
                          ),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        if (!partnerOnly)
                          _ActionButton(
                            label: _primaryLabel(l10n),
                            icon: suggestion.reason == SuggestionReason.stale
                                ? Icons.alarm_add_outlined
                                : suggestion.reason ==
                                      SuggestionReason.categorize
                                ? Icons.label_outline
                                : Icons.add,
                            onPressed: () => _accept(context),
                            colorScheme: colorScheme,
                            filled: true,
                          ),
                        if (!partnerOnly && _isNewTaskSuggestion)
                          _ActionButton(
                            label: l10n.suggestAddWithReminder,
                            icon: Icons.alarm_add_outlined,
                            onPressed: () => _openWithReminder(context),
                            colorScheme: colorScheme,
                          ),
                        if (partnerPaired &&
                            proposalRepo != null &&
                            suggestion.reason != SuggestionReason.stale &&
                            suggestion.reason != SuggestionReason.categorize)
                          _ActionButton(
                            label: '→ ${l10n.commonPartner}',
                            icon: Icons.person_outline,
                            onPressed: () => _sendToPartner(context),
                            colorScheme: colorScheme,
                          ),
                        _ActionButton(
                          label: l10n.commonCloseAction,
                          icon: Icons.close,
                          onPressed: _dismiss,
                          colorScheme: colorScheme,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  final ColorScheme colorScheme;
  final bool filled;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.onPressed,
    required this.colorScheme,
    this.filled = false,
  });

  @override
  Widget build(BuildContext context) {
    if (filled) {
      return FilledButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 16),
        label: Text(label),
        style: FilledButton.styleFrom(
          visualDensity: VisualDensity.compact,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          textStyle: const TextStyle(fontSize: 12),
        ),
      );
    }
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 16),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        visualDensity: VisualDensity.compact,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        textStyle: const TextStyle(fontSize: 12),
      ),
    );
  }
}
