import 'package:flutter/material.dart';
import 'package:kinetic_webdav/kinetic_webdav.dart';

import '../../l10n/generated/app_localizations.dart';
import '../../partner/services/partner_proposal_repository.dart';
import '../../sync/webdav_config_repository.dart';
import '../../todo/services/todo_repository.dart';
import '../../todo/widgets/task_detail_sheet.dart';

// ---------------------------------------------------------------------------
// QuickAddBar — persistent text field at the bottom of the task list.
//
// Typing and pressing Enter (or tapping ✓) creates a task in the current
// list with auto-category detection.  Tapping the expand icon opens the
// full TaskDetailSheet for more options.
// ---------------------------------------------------------------------------

class QuickAddBar extends StatefulWidget {
  final TodoRepository repo;
  final String? activeListId;
  final bool hasFamilyKey;
  final bool partnerPaired;
  final PartnerProposalRepository? proposalRepo;
  final String? myLinkId;
  final List<({String id, String name})> otherLinkMembers;
  final WebDavConfigRepository? configRepo;
  final Future<List<PresenceInfo>> Function()? pullPresence;
  final bool kidsParticipation;

  const QuickAddBar({
    super.key,
    required this.repo,
    this.activeListId,
    this.hasFamilyKey = false,
    this.partnerPaired = false,
    this.proposalRepo,
    this.myLinkId,
    this.otherLinkMembers = const [],
    this.configRepo,
    this.pullPresence,
    this.kidsParticipation = true,
  });

  @override
  State<QuickAddBar> createState() => _QuickAddBarState();
}

class _QuickAddBarState extends State<QuickAddBar> {
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
    await widget.repo.createTask(title: title, listId: widget.activeListId);
    _ctrl.clear();
  }

  void _openFull() {
    final title = _ctrl.text.trim();
    _ctrl.clear();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => TaskDetailSheet(
        repo: widget.repo,
        initialListId: widget.activeListId,
        initialTitle: title.isEmpty ? null : title,
        hasFamilyKey: widget.hasFamilyKey,
        partnerPaired: widget.partnerPaired,
        proposalRepo: widget.proposalRepo,
        myLinkId: widget.myLinkId,
        otherLinkMembers: widget.otherLinkMembers,
        configRepo: widget.configRepo,
        pullPresence: widget.pullPresence,
        kidsParticipation: widget.kidsParticipation,
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
                  onTap: _submit,
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
                      hintText: l10n.quickAddHint,
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
