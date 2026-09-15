import 'package:flutter/material.dart';

import '../../l10n/generated/app_localizations.dart';
import '../../partner/models/partner_proposal.dart';
import '../../partner/services/partner_proposal_repository.dart';
import '../../theme/app_themes.dart';
import '../models/ai_suggestion.dart';
import '../services/ai_suggestion_repository.dart';
import '../services/suggestion_actions.dart';
import '../services/todo_repository.dart';

/// Collapsible suggestions card shown above the parent's task list.
class SuggestionsPanel extends StatefulWidget {
  final AiSuggestionRepository suggestionRepo;
  final TodoRepository todoRepo;
  final PartnerProposalRepository? proposalRepo;
  final String? myParentId;
  final bool partnerPaired;
  final VoidCallback? onSyncRequested;

  const SuggestionsPanel({
    super.key,
    required this.suggestionRepo,
    required this.todoRepo,
    this.proposalRepo,
    this.myParentId,
    this.partnerPaired = false,
    this.onSyncRequested,
  });

  @override
  State<SuggestionsPanel> createState() => _SuggestionsPanelState();
}

class _SuggestionsPanelState extends State<SuggestionsPanel> {
  bool _expanded = true;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<AiSuggestion>>(
      stream: widget.suggestionRepo.watchPendingSelf(),
      builder: (context, selfSnap) {
        return StreamBuilder<List<AiSuggestion>>(
          stream: widget.partnerPaired
              ? widget.suggestionRepo.watchPendingPartner()
              : Stream<List<AiSuggestion>>.value(const []),
          builder: (context, partnerSnap) {
            return StreamBuilder<List<PartnerProposal>>(
              stream: widget.proposalRepo != null && widget.partnerPaired
                  ? widget.proposalRepo!.watchPending(
                      myParentId: widget.myParentId,
                    )
                  : Stream<List<PartnerProposal>>.value(const []),
              builder: (context, proposalSnap) {
                final self = selfSnap.data ?? const <AiSuggestion>[];
                final forPartner = partnerSnap.data ?? const <AiSuggestion>[];
                final fromPartner =
                    proposalSnap.data ?? const <PartnerProposal>[];
                final total =
                    self.length + forPartner.length + fromPartner.length;
                if (total == 0) return const SizedBox.shrink();

                return _SuggestionsCard(
                  expanded: _expanded,
                  onToggle: () => setState(() => _expanded = !_expanded),
                  count: total,
                  self: self,
                  forPartner: forPartner,
                  fromPartner: fromPartner,
                  suggestionRepo: widget.suggestionRepo,
                  todoRepo: widget.todoRepo,
                  proposalRepo: widget.proposalRepo,
                  myParentId: widget.myParentId,
                  partnerPaired: widget.partnerPaired,
                  onSyncRequested: widget.onSyncRequested,
                );
              },
            );
          },
        );
      },
    );
  }
}

class _SuggestionsCard extends StatelessWidget {
  final bool expanded;
  final VoidCallback onToggle;
  final int count;
  final List<AiSuggestion> self;
  final List<AiSuggestion> forPartner;
  final List<PartnerProposal> fromPartner;
  final AiSuggestionRepository suggestionRepo;
  final TodoRepository todoRepo;
  final PartnerProposalRepository? proposalRepo;
  final String? myParentId;
  final bool partnerPaired;
  final VoidCallback? onSyncRequested;

  const _SuggestionsCard({
    required this.expanded,
    required this.onToggle,
    required this.count,
    required this.self,
    required this.forPartner,
    required this.fromPartner,
    required this.suggestionRepo,
    required this.todoRepo,
    required this.proposalRepo,
    required this.myParentId,
    required this.partnerPaired,
    this.onSyncRequested,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Material(
        color: scheme.primaryContainer.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            InkWell(
              onTap: onToggle,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 8, 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.auto_awesome, size: 20, color: scheme.primary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                l10n.suggestionsTitle.toUpperCase(),
                                style: theme.textTheme.labelLarge?.copyWith(
                                  color: scheme.primary,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.8,
                                ),
                              ),
                              const SizedBox(width: 8),
                              _CountBadge(count: count),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            l10n.suggestionsSubtitle,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: scheme.onPrimaryContainer.withValues(
                                alpha: 0.75,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      expanded ? Icons.expand_less : Icons.expand_more,
                      color: scheme.primary,
                    ),
                  ],
                ),
              ),
            ),
            if (expanded) ...[
              if (self.isNotEmpty) _SectionLabel(label: l10n.tasksForYou),
              for (final suggestion in self)
                _SelfSuggestionRow(
                  suggestion: suggestion,
                  suggestionRepo: suggestionRepo,
                  todoRepo: todoRepo,
                ),
              if (forPartner.isNotEmpty)
                _SectionLabel(label: l10n.tasksForPartner),
              for (final suggestion in forPartner)
                _PartnerTargetRow(
                  suggestion: suggestion,
                  suggestionRepo: suggestionRepo,
                  proposalRepo: proposalRepo,
                  myParentId: myParentId,
                  partnerPaired: partnerPaired,
                ),
              if (fromPartner.isNotEmpty)
                _SectionLabel(label: l10n.tasksFromPartner),
              for (final proposal in fromPartner)
                _IncomingProposalRow(
                  proposal: proposal,
                  proposalRepo: proposalRepo!,
                  onSyncRequested: onSyncRequested,
                ),
              const SizedBox(height: 10),
            ],
          ],
        ),
      ),
    );
  }
}

class _CountBadge extends StatelessWidget {
  final int count;
  const _CountBadge({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 18,
      height: 18,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        color: Color(0xFFE53935),
        shape: BoxShape.circle,
      ),
      child: Text(
        count > 9 ? '9+' : '$count',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 6),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _SelfSuggestionRow extends StatelessWidget {
  final AiSuggestion suggestion;
  final AiSuggestionRepository suggestionRepo;
  final TodoRepository todoRepo;

  const _SelfSuggestionRow({
    required this.suggestion,
    required this.suggestionRepo,
    required this.todoRepo,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final date = suggestion.suggestedDueDate;

    return Dismissible(
      key: ValueKey('sug_${suggestion.id}'),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => suggestionRepo.dismiss(suggestion.id),
      background: const SizedBox.shrink(),
      secondaryBackground: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        child: Icon(Icons.close, color: scheme.error),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
        child: Material(
          color: scheme.surface.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => acceptSelfSuggestion(
              suggestion: suggestion,
              todoRepo: todoRepo,
              suggestionRepo: suggestionRepo,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                children: [
                  _LeadingIcon(icon: Icons.lightbulb_outline),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          suggestionDisplayTitle(suggestion, l10n),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        if (date != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            formatDueDate(date, l10n, allDay: false),
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: scheme.onSurfaceVariant),
                          ),
                        ],
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right, color: scheme.outline),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PartnerTargetRow extends StatelessWidget {
  final AiSuggestion suggestion;
  final AiSuggestionRepository suggestionRepo;
  final PartnerProposalRepository? proposalRepo;
  final String? myParentId;
  final bool partnerPaired;

  const _PartnerTargetRow({
    required this.suggestion,
    required this.suggestionRepo,
    required this.proposalRepo,
    required this.myParentId,
    required this.partnerPaired,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
      child: Material(
        color: scheme.surface.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const _LeadingIcon(icon: Icons.person_outline),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      suggestionDisplayTitle(suggestion, l10n),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => suggestionRepo.dismiss(suggestion.id),
                    child: Text(l10n.tasksDecline),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: proposalRepo == null || !partnerPaired
                        ? null
                        : () => confirmAndSendSuggestionToPartner(
                            context: context,
                            suggestion: suggestion,
                            proposalRepo: proposalRepo!,
                            suggestionRepo: suggestionRepo,
                            myParentId: myParentId,
                          ),
                    child: Text(l10n.suggestSend),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _IncomingProposalRow extends StatelessWidget {
  final PartnerProposal proposal;
  final PartnerProposalRepository proposalRepo;
  final VoidCallback? onSyncRequested;

  const _IncomingProposalRow({
    required this.proposal,
    required this.proposalRepo,
    this.onSyncRequested,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
      child: Material(
        color: scheme.surface.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const _LeadingIcon(icon: Icons.person_outline),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          proposal.taskTitle,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          l10n.suggestionsProposedByPartner,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: scheme.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: () async {
                      await proposalRepo.dismiss(proposal.id);
                      onSyncRequested?.call();
                    },
                    child: Text(l10n.tasksDecline),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: () async {
                      await proposalRepo.accept(proposal.id);
                      onSyncRequested?.call();
                    },
                    child: Text(l10n.tasksAccept),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LeadingIcon extends StatelessWidget {
  final IconData icon;
  const _LeadingIcon({required this.icon});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: scheme.primaryContainer,
        shape: BoxShape.circle,
      ),
      child: Icon(icon, size: 18, color: scheme.primary),
    );
  }
}
