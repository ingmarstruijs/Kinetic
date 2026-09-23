import 'package:flutter/material.dart';

import '../../l10n/generated/app_localizations.dart';
import '../../family/proposals/link_member_proposal.dart';
import '../../family/proposals/link_member_proposal_repository.dart';
import '../../theme/app_themes.dart';
import '../models/ai_suggestion.dart';
import '../models/enums.dart';
import '../services/ai_suggestion_repository.dart';
import '../services/suggestion_actions.dart';
import '../services/todo_repository.dart';
import 'tasks_section_header.dart';

/// Collapsible suggestions section shown above the Kinetic Link task list.
class SuggestionsPanel extends StatefulWidget {
  final AiSuggestionRepository suggestionRepo;
  final TodoRepository todoRepo;
  final LinkMemberProposalRepository? proposalRepo;
  final String? myLinkId;
  final bool hasOtherLinkMembers;
  final List<({String id, String name})> otherLinkMembers;
  final VoidCallback? onSyncRequested;
  final ValueChanged<bool>? onVisibilityChanged;

  const SuggestionsPanel({
    super.key,
    required this.suggestionRepo,
    required this.todoRepo,
    this.proposalRepo,
    this.myLinkId,
    this.hasOtherLinkMembers = false,
    this.otherLinkMembers = const [],
    this.onSyncRequested,
    this.onVisibilityChanged,
  });

  @override
  State<SuggestionsPanel> createState() => _SuggestionsPanelState();
}

class _SuggestionsPanelState extends State<SuggestionsPanel> {
  bool _expanded = true;
  late Stream<List<AiSuggestion>> _pending;
  Stream<List<LinkMemberProposal>>? _proposals;
  bool? _lastVisible;

  void _reportVisibility(bool visible) {
    if (_lastVisible == visible) return;
    _lastVisible = visible;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      widget.onVisibilityChanged?.call(visible);
    });
  }

  @override
  void initState() {
    super.initState();
    _bindStreams();
  }

  @override
  void didUpdateWidget(SuggestionsPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.suggestionRepo != widget.suggestionRepo ||
        oldWidget.proposalRepo != widget.proposalRepo ||
        oldWidget.hasOtherLinkMembers != widget.hasOtherLinkMembers ||
        oldWidget.myLinkId != widget.myLinkId ||
        oldWidget.otherLinkMembers != widget.otherLinkMembers) {
      setState(_bindStreams);
    }
  }

  void _bindStreams() {
    _pending = widget.suggestionRepo.watchPending();
    _proposals = widget.proposalRepo != null && widget.hasOtherLinkMembers
        ? widget.proposalRepo!.watchPending(myLinkId: widget.myLinkId)
        : null;
  }

  void _refresh() {
    if (mounted) setState(_bindStreams);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<AiSuggestion>>(
      stream: _pending,
      builder: (context, pendingSnap) {
        return StreamBuilder<List<LinkMemberProposal>>(
          stream: _proposals,
          builder: (context, proposalSnap) {
            final pending = pendingSnap.data ?? const <AiSuggestion>[];
            final self = [
              for (final s in pending)
                if (s.reason.isSelfTargeted) s,
            ];
            final forFamilyMember = [
              for (final s in pending)
                if (s.reason.isFamilyMemberTargeted) s,
            ];
            final fromFamilyMember = proposalSnap.data ?? const <LinkMemberProposal>[];
            final total = self.length + forFamilyMember.length + fromFamilyMember.length;
            _reportVisibility(total > 0);
            if (total == 0) return const SizedBox.shrink();

            return _SuggestionsCard(
              expanded: _expanded,
              onToggle: () => setState(() => _expanded = !_expanded),
              count: total,
              self: self,
              forFamilyMember: forFamilyMember,
              fromFamilyMember: fromFamilyMember,
              suggestionRepo: widget.suggestionRepo,
              todoRepo: widget.todoRepo,
              proposalRepo: widget.proposalRepo,
              myLinkId: widget.myLinkId,
              hasOtherLinkMembers: widget.hasOtherLinkMembers,
              otherLinkMembers: widget.otherLinkMembers,
              onSyncRequested: widget.onSyncRequested,
              onChanged: _refresh,
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
  final List<AiSuggestion> forFamilyMember;
  final List<LinkMemberProposal> fromFamilyMember;
  final AiSuggestionRepository suggestionRepo;
  final TodoRepository todoRepo;
  final LinkMemberProposalRepository? proposalRepo;
  final String? myLinkId;
  final bool hasOtherLinkMembers;
  final List<({String id, String name})> otherLinkMembers;
  final VoidCallback? onSyncRequested;
  final VoidCallback onChanged;

  const _SuggestionsCard({
    required this.expanded,
    required this.onToggle,
    required this.count,
    required this.self,
    required this.forFamilyMember,
    required this.fromFamilyMember,
    required this.suggestionRepo,
    required this.todoRepo,
    required this.proposalRepo,
    required this.myLinkId,
    required this.hasOtherLinkMembers,
    required this.otherLinkMembers,
    this.onSyncRequested,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final forLabel = _forSectionLabel(l10n, otherLinkMembers);
    final fromLabel = _fromSectionLabel(l10n, otherLinkMembers);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TasksSectionHeader(
            icon: Icons.auto_awesome,
            title: l10n.suggestionsTitle,
            count: count,
            expanded: expanded,
            onToggle: onToggle,
            subtitle: l10n.suggestionsSubtitle,
          ),
          if (expanded) ...[
            const SizedBox(height: 8),
            if (self.isNotEmpty) _SectionLabel(label: l10n.tasksForYou),
            for (final suggestion in self)
              _SelfSuggestionRow(
                suggestion: suggestion,
                suggestionRepo: suggestionRepo,
                todoRepo: todoRepo,
                onChanged: onChanged,
              ),
            if (forFamilyMember.isNotEmpty) _SectionLabel(label: forLabel),
            for (final suggestion in forFamilyMember)
              _FamilyMemberTargetRow(
                suggestion: suggestion,
                suggestionRepo: suggestionRepo,
                proposalRepo: proposalRepo,
                myLinkId: myLinkId,
                hasOtherLinkMembers: hasOtherLinkMembers,
                otherLinkMembers: otherLinkMembers,
                onChanged: onChanged,
              ),
            if (fromFamilyMember.isNotEmpty) _SectionLabel(label: fromLabel),
            for (final proposal in fromFamilyMember)
              _IncomingProposalRow(
                proposal: proposal,
                proposalRepo: proposalRepo!,
                fromName: _memberName(
                  otherLinkMembers,
                  proposal.fromLinkId,
                  l10n.familyMemberGenericName,
                ),
                onSyncRequested: onSyncRequested,
                onChanged: onChanged,
              ),
            const SizedBox(height: 4),
          ],
        ],
      ),
    );
  }
}

String _forSectionLabel(
  AppLocalizations l10n,
  List<({String id, String name})> members,
) {
  if (members.length == 1) {
    return l10n.tasksForFamilyMember(members.first.name);
  }
  if (members.isEmpty) {
    return l10n.tasksForFamilyMember(l10n.familyMemberGenericName);
  }
  return l10n.tasksForFamily;
}

String _fromSectionLabel(
  AppLocalizations l10n,
  List<({String id, String name})> members,
) {
  if (members.length == 1) {
    return l10n.tasksFromFamilyMember(members.first.name);
  }
  if (members.isEmpty) {
    return l10n.tasksFromFamilyMember(l10n.familyMemberGenericName);
  }
  return l10n.tasksFromFamily;
}

String _memberName(
  List<({String id, String name})> members,
  String id,
  String fallback,
) {
  for (final m in members) {
    if (m.id == id && m.name.trim().isNotEmpty) return m.name.trim();
  }
  return fallback;
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 4, 0, 6),
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
  final VoidCallback onChanged;

  const _SelfSuggestionRow({
    required this.suggestion,
    required this.suggestionRepo,
    required this.todoRepo,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final date = suggestion.suggestedDueDate;

    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 8),
      child: Material(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const _LeadingIcon(icon: Icons.lightbulb_outline),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          suggestionDisplayTitle(suggestion, l10n),
                          maxLines: 2,
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
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () async {
                      await suggestionRepo.dismiss(suggestion.id);
                      onChanged();
                    },
                    child: Text(l10n.tasksDecline),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: () async {
                      await acceptSelfSuggestion(
                        suggestion: suggestion,
                        todoRepo: todoRepo,
                        suggestionRepo: suggestionRepo,
                        l10n: l10n,
                      );
                      onChanged();
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

class _FamilyMemberTargetRow extends StatelessWidget {
  final AiSuggestion suggestion;
  final AiSuggestionRepository suggestionRepo;
  final LinkMemberProposalRepository? proposalRepo;
  final String? myLinkId;
  final bool hasOtherLinkMembers;
  final List<({String id, String name})> otherLinkMembers;
  final VoidCallback onChanged;

  const _FamilyMemberTargetRow({
    required this.suggestion,
    required this.suggestionRepo,
    required this.proposalRepo,
    required this.myLinkId,
    required this.hasOtherLinkMembers,
    required this.otherLinkMembers,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final explanation = suggestionDisplayExplanation(suggestion, l10n);

    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 8),
      child: Material(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const _LeadingIcon(icon: Icons.person_outline),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          suggestionDisplayTitle(suggestion, l10n),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        if (explanation.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Text(
                              explanation,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: scheme.onSurfaceVariant),
                            ),
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
                  TextButton(
                    onPressed: () async {
                      await suggestionRepo.dismiss(suggestion.id);
                      onChanged();
                    },
                    child: Text(l10n.tasksDecline),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: proposalRepo == null || !hasOtherLinkMembers
                        ? null
                        : () async {
                            await confirmAndSendSuggestionToFamilyMember(
                              context: context,
                              suggestion: suggestion,
                              proposalRepo: proposalRepo!,
                              suggestionRepo: suggestionRepo,
                              myLinkId: myLinkId,
                              otherLinkMembers: otherLinkMembers,
                            );
                            onChanged();
                          },
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
  final LinkMemberProposal proposal;
  final LinkMemberProposalRepository proposalRepo;
  final String fromName;
  final VoidCallback? onSyncRequested;
  final VoidCallback onChanged;

  const _IncomingProposalRow({
    required this.proposal,
    required this.proposalRepo,
    required this.fromName,
    this.onSyncRequested,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final notes = proposal.taskNotes?.trim();
    final due = proposal.taskDueDate;
    final timed =
        due != null && (due.toLocal().hour != 0 || due.toLocal().minute != 0);
    final metaParts = <String>[
      if (due != null) formatDueDate(due, l10n, allDay: !timed),
      if (proposal.taskPriority != TaskPriority.none)
        _priorityName(proposal.taskPriority, l10n),
      ?_proposalCategoryLabel(proposal.taskCategory),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 8),
      child: Material(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _LeadingIcon(icon: Icons.person_outline),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          proposal.taskTitle,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        if (notes != null && notes.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            notes,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: scheme.onSurfaceVariant),
                          ),
                        ],
                        if (metaParts.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            metaParts.join(' · '),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: scheme.onSurfaceVariant),
                          ),
                        ],
                        const SizedBox(height: 2),
                        Text(
                          l10n.suggestionsProposedByFamilyMember(fromName),
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
                      onChanged();
                    },
                    child: Text(l10n.tasksDecline),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: () async {
                      await proposalRepo.accept(proposal.id);
                      onSyncRequested?.call();
                      onChanged();
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

String _priorityName(TaskPriority priority, AppLocalizations l10n) =>
    switch (priority) {
      TaskPriority.low => l10n.commonLow,
      TaskPriority.medium => l10n.commonMedium,
      TaskPriority.high => l10n.commonHigh,
      TaskPriority.none => l10n.commonNone,
    };

String? _proposalCategoryLabel(String raw) {
  final value = raw.trim();
  if (value.isEmpty || value == 'other') return null;
  if (TaskCategory.values.any((c) => c.name == value)) return null;
  return value;
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
