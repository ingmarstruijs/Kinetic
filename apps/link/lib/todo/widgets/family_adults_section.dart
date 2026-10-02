import 'package:flutter/material.dart';
import 'package:kinetic_webdav/kinetic_webdav.dart';

import '../../family/family_connection_service.dart';
import '../../l10n/generated/app_localizations.dart';

/// Adults block for the ambient family popover — nudge per other link member.
class FamilyAdultsSection extends StatelessWidget {
  final List<({String id, String name})> otherLinkMembers;
  final List<PresenceInfo> presence;
  final Future<void> Function(FamilyMemberStatus member)? onNudge;

  const FamilyAdultsSection({
    super.key,
    required this.otherLinkMembers,
    this.presence = const [],
    this.onNudge,
  });

  @override
  Widget build(BuildContext context) {
    if (otherLinkMembers.isEmpty) return const SizedBox.shrink();

    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final adults = FamilyConnectionService.linkStatuses(
      otherLinkMembers: [
        for (final m in otherLinkMembers)
          FamilyLinkMember(
            id: m.id,
            displayName: m.name,
            joinedAt: DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
            updatedAt: DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
          ),
      ],
      presenceList: presence,
      now: DateTime.now(),
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(Icons.people_alt_outlined, size: 18, color: scheme.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l10n.adultsSectionTitle.toUpperCase(),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: scheme.primary,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.1,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          for (final adult in adults)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Material(
                color: scheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: scheme.primaryContainer,
                        foregroundColor: scheme.onPrimaryContainer,
                        child: Text(
                          _initials(adult.name),
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              adult.name,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              adult.statusLabel(l10n),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: scheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (onNudge != null)
                        FilledButton.tonalIcon(
                          onPressed: adult.isConnected
                              ? () => onNudge!(adult)
                              : null,
                          icon: const Icon(Icons.waving_hand_outlined, size: 18),
                          label: Text(l10n.nudgeSend),
                        ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  static String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }
}
