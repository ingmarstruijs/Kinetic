import 'package:flutter/material.dart';
import 'package:kinetic_webdav/kinetic_webdav.dart';

import '../../family/family_connection_service.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../settings/models/enrolled_kid.dart';
import '../../sync/webdav_config_repository.dart';

/// Subtle presence + coarse load chips for the Tasks header (no messaging).
class FamilyAmbientStrip extends StatefulWidget {
  final bool visible;
  final List<({String id, String name})> otherLinkMembers;
  final List<EnrolledKid> enrolledKids;
  final int enrolledKidsCount;
  final WebDavConfigRepository? configRepo;
  final Future<List<PresenceInfo>> Function()? pullPresence;
  final Future<List<LoadMetrics>> Function()? pullLoadMetrics;
  final ValueNotifier<int>? syncDoneCount;

  const FamilyAmbientStrip({
    super.key,
    required this.visible,
    this.otherLinkMembers = const [],
    this.enrolledKids = const [],
    this.enrolledKidsCount = 0,
    this.configRepo,
    this.pullPresence,
    this.pullLoadMetrics,
    this.syncDoneCount,
  });

  @override
  State<FamilyAmbientStrip> createState() => _FamilyAmbientStripState();
}

class _FamilyAmbientStripState extends State<FamilyAmbientStrip> {
  List<PresenceInfo> _presence = const [];
  List<LoadMetrics> _loadMetrics = const [];

  @override
  void initState() {
    super.initState();
    widget.syncDoneCount?.addListener(_reload);
    if (widget.visible) _reload();
  }

  @override
  void didUpdateWidget(FamilyAmbientStrip oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.syncDoneCount != widget.syncDoneCount) {
      oldWidget.syncDoneCount?.removeListener(_reload);
      widget.syncDoneCount?.addListener(_reload);
    }
    if (widget.visible &&
        (oldWidget.visible != widget.visible ||
            oldWidget.otherLinkMembers != widget.otherLinkMembers ||
            oldWidget.enrolledKids != widget.enrolledKids)) {
      _reload();
    }
  }

  @override
  void dispose() {
    widget.syncDoneCount?.removeListener(_reload);
    super.dispose();
  }

  Future<void> _reload() async {
    if (!widget.visible) return;
    final pullPresence = widget.pullPresence;
    final pullLoad = widget.pullLoadMetrics;
    if (pullPresence == null && pullLoad == null) return;

    List<PresenceInfo> presence = const [];
    List<LoadMetrics> load = const [];
    List<EnrolledKid> kids = widget.enrolledKids;
    if (kids.isEmpty &&
        widget.enrolledKidsCount > 0 &&
        widget.configRepo != null) {
      try {
        kids = await widget.configRepo!.loadEnrolledKids();
      } catch (_) {}
    }
    try {
      if (pullPresence != null) presence = await pullPresence();
    } catch (_) {}
    try {
      if (pullLoad != null) load = await pullLoad();
    } catch (_) {}

    if (!mounted) return;
    setState(() {
      _presence = presence;
      _loadMetrics = load;
      _enrolledKids = kids;
    });
  }

  List<EnrolledKid> _enrolledKids = const [];

  @override
  Widget build(BuildContext context) {
    if (!widget.visible) return const SizedBox.shrink();

    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final now = DateTime.now();
    final loadById = {for (final m in _loadMetrics) m.linkId: m};

    final linkMembers = FamilyConnectionService.linkStatuses(
      otherLinkMembers: [
        for (final m in widget.otherLinkMembers)
          FamilyLinkMember(
            id: m.id,
            displayName: m.name,
            joinedAt: DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
            updatedAt: DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
          ),
      ],
      presenceList: _presence,
      now: now,
    );
    final kids = FamilyConnectionService.kidStatuses(
      enrolledKids: _enrolledKids.isNotEmpty ? _enrolledKids : widget.enrolledKids,
      presenceList: _presence,
      now: now,
    );
    final members = [...linkMembers, ...kids];
    if (members.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: EdgeInsets.zero,
      child: Wrap(
        spacing: 6,
        runSpacing: 4,
        children: [
          for (final member in members)
            _AmbientChip(
              label: member.name,
              loadLabel: _loadLabel(l10n, member, loadById, now),
              tooltip: member.statusLabel(l10n),
              dotColor: _dotColor(scheme, member),
              loadMuted: _loadMetricsStale(loadById[member.id], now),
            ),
        ],
      ),
    );
  }

  String _loadLabel(
    AppLocalizations l10n,
    FamilyMemberStatus member,
    Map<String, LoadMetrics> loadById,
    DateTime now,
  ) {
    if (member.type != FamilyMemberType.linkMember) {
      return '';
    }
    final metrics = loadById[member.id];
    if (metrics == null) return l10n.tasksAmbientLoadUnknown;
    if (_loadMetricsStale(metrics, now)) return l10n.tasksAmbientLoadUnknown;
    return l10n.tasksAmbientLoadOpen(metrics.totalOpen);
  }

  bool _loadMetricsStale(LoadMetrics? metrics, DateTime now) {
    if (metrics == null) return true;
    final (connected, _) = FamilyConnectionService.evaluateConnection(
      metrics.updatedAt,
      now,
    );
    return !connected;
  }

  Color _dotColor(ColorScheme scheme, FamilyMemberStatus member) {
    if (!member.isConnected) {
      return scheme.outlineVariant.withValues(alpha: 0.7);
    }
    if (member.isStale) {
      return scheme.tertiary.withValues(alpha: 0.85);
    }
    return scheme.primary.withValues(alpha: 0.75);
  }
}

class _AmbientChip extends StatelessWidget {
  final String label;
  final String loadLabel;
  final String tooltip;
  final Color dotColor;
  final bool loadMuted;

  const _AmbientChip({
    required this.label,
    required this.loadLabel,
    required this.tooltip,
    required this.dotColor,
    required this.loadMuted,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textStyle = Theme.of(context).textTheme.labelSmall?.copyWith(
          fontSize: 11,
          color: scheme.onSurfaceVariant.withValues(alpha: 0.85),
        );

    return Tooltip(
      message: tooltip,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerHighest.withValues(alpha: 0.35),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
            ),
            const SizedBox(width: 6),
            Text(label, style: textStyle, overflow: TextOverflow.ellipsis),
            if (loadLabel.isNotEmpty) ...[
              const SizedBox(width: 4),
              Text(
                loadLabel,
                style: textStyle?.copyWith(
                  color: loadMuted
                      ? scheme.outline
                      : scheme.onSurfaceVariant.withValues(alpha: 0.7),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
