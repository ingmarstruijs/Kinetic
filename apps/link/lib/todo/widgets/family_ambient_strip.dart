import 'package:flutter/material.dart';
import 'package:kinetic_webdav/kinetic_webdav.dart';

import '../../family/family_connection_service.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../settings/models/enrolled_kid.dart';
import '../../sync/sync_status.dart';
import '../../sync/webdav_config_repository.dart';

/// Subtle presence + coarse load chips for the Tasks header (no messaging).
///
/// When [onOpenKids] is set, the strip is styled as a tappable control that
/// opens the family popover.
class FamilyAmbientStrip extends StatefulWidget {
  final bool visible;
  final List<({String id, String name})> otherLinkMembers;
  final List<EnrolledKid> enrolledKids;
  final int enrolledKidsCount;
  final WebDavConfigRepository? configRepo;
  final Future<List<PresenceInfo>> Function()? pullPresence;
  final Future<List<LoadMetrics>> Function()? pullLoadMetrics;
  final ValueNotifier<int>? syncDoneCount;

  /// When sync is in error (e.g. offline), chips show as disconnected even if
  /// the last successful presence pull still looks fresh.
  final ValueNotifier<SyncStatusInfo>? syncStatus;

  /// When set, tapping the strip opens the kids popover.
  final VoidCallback? onOpenKids;

  /// Whether the kids popover is currently open (chevron direction).
  final bool kidsPopoverOpen;

  /// Optional pending-verification count shown next to the kids affordance.
  final int kidsPendingCount;

  /// Open-task counts per kid id (from the kids panel / shared tasks).
  final Map<String, int> kidsOpenCounts;

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
    this.syncStatus,
    this.onOpenKids,
    this.kidsPopoverOpen = false,
    this.kidsPendingCount = 0,
    this.kidsOpenCounts = const {},
  });

  @override
  State<FamilyAmbientStrip> createState() => _FamilyAmbientStripState();
}

class _FamilyAmbientStripState extends State<FamilyAmbientStrip> {
  List<PresenceInfo> _presence = const [];
  List<LoadMetrics> _loadMetrics = const [];
  List<EnrolledKid> _enrolledKids = const [];

  @override
  void initState() {
    super.initState();
    widget.syncDoneCount?.addListener(_reload);
    widget.syncStatus?.addListener(_onSyncStatusChanged);
    if (widget.visible) _reload();
  }

  @override
  void didUpdateWidget(FamilyAmbientStrip oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.syncDoneCount != widget.syncDoneCount) {
      oldWidget.syncDoneCount?.removeListener(_reload);
      widget.syncDoneCount?.addListener(_reload);
    }
    if (oldWidget.syncStatus != widget.syncStatus) {
      oldWidget.syncStatus?.removeListener(_onSyncStatusChanged);
      widget.syncStatus?.addListener(_onSyncStatusChanged);
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
    widget.syncStatus?.removeListener(_onSyncStatusChanged);
    super.dispose();
  }

  void _onSyncStatusChanged() {
    if (mounted) setState(() {});
  }

  bool get _syncUnreachable =>
      widget.syncStatus?.value.status == SyncStatus.error;

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

  FamilyMemberStatus _displayStatus(FamilyMemberStatus member) {
    if (!_syncUnreachable || !member.isConnected) return member;
    return FamilyMemberStatus(
      id: member.id,
      name: member.name,
      type: member.type,
      isConnected: false,
      isStale: false,
      lastSeen: member.lastSeen,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.visible) return const SizedBox.shrink();

    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final now = DateTime.now();
    final loadById = {for (final m in _loadMetrics) m.linkId: m};
    final syncUnreachable = _syncUnreachable;

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
      enrolledKids:
          _enrolledKids.isNotEmpty ? _enrolledKids : widget.enrolledKids,
      presenceList: _presence,
      now: now,
    );
    final members = [
      for (final m in [...linkMembers, ...kids]) _displayStatus(m),
    ];
    final canOpen = widget.onOpenKids != null;
    if (members.isEmpty && !canOpen) return const SizedBox.shrink();

    final content = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: members.isEmpty
                  ? Text(
                      l10n.kidsSectionTitle,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    )
                  : Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        for (final member in members)
                          _AmbientChip(
                            label: member.name,
                            count: _openCount(l10n, member, loadById, now),
                            countMuted: syncUnreachable ||
                                (member.type == FamilyMemberType.linkMember
                                    ? _loadMetricsStale(
                                        loadById[member.id],
                                        now,
                                      )
                                    : false),
                            tooltip: member.statusLabel(l10n),
                            dotColor: _dotColor(scheme, member),
                          ),
                      ],
                    ),
            ),
            if (canOpen) ...[
              const SizedBox(width: 8),
              _OpenChevron(
                open: widget.kidsPopoverOpen,
                pendingCount: widget.kidsPendingCount,
              ),
            ],
          ],
        ),
      ],
    );

    if (!canOpen) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
        child: Align(
          alignment: Alignment.centerLeft,
          child: content,
        ),
      );
    }

    final radius = BorderRadius.circular(22);
    final open = widget.kidsPopoverOpen;
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: open ? scheme.surfaceContainer : scheme.surfaceContainerLow,
          borderRadius: radius,
          boxShadow: [
            BoxShadow(
              color: scheme.shadow.withValues(alpha: open ? 0.12 : 0.07),
              blurRadius: open ? 14 : 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: radius,
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: widget.onOpenKids,
            borderRadius: radius,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 52),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 10, 10),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: content,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Open count to show beside [member.name], or `—` when adult load is unknown.
  String? _openCount(
    AppLocalizations l10n,
    FamilyMemberStatus member,
    Map<String, LoadMetrics> loadById,
    DateTime now,
  ) {
    if (member.type == FamilyMemberType.kid) {
      final count = widget.kidsOpenCounts[member.id];
      if (count == null) return null;
      return '$count';
    }
    final metrics = loadById[member.id];
    if (metrics == null || _loadMetricsStale(metrics, now)) {
      return l10n.tasksAmbientLoadUnknown;
    }
    return '${metrics.totalOpen}';
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

class _OpenChevron extends StatelessWidget {
  final bool open;
  final int pendingCount;

  const _OpenChevron({
    required this.open,
    required this.pendingCount,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: scheme.primaryContainer.withValues(alpha: 0.85),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            open ? Icons.expand_less_rounded : Icons.expand_more_rounded,
            size: 22,
            color: scheme.onPrimaryContainer,
          ),
        ),
        if (pendingCount > 0)
          Positioned(
            top: -3,
            right: -3,
            child: Container(
              constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
              padding: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: scheme.error,
                borderRadius: BorderRadius.circular(999),
              ),
              alignment: Alignment.center,
              child: Text(
                pendingCount > 9 ? '9+' : '$pendingCount',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: scheme.onError,
                      fontWeight: FontWeight.w700,
                      fontSize: 9,
                      height: 1,
                    ),
              ),
            ),
          ),
      ],
    );
  }
}

class _AmbientChip extends StatelessWidget {
  final String label;
  final String? count;
  final bool countMuted;
  final String tooltip;
  final Color dotColor;

  const _AmbientChip({
    required this.label,
    required this.count,
    required this.countMuted,
    required this.tooltip,
    required this.dotColor,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final nameStyle = Theme.of(context).textTheme.labelSmall?.copyWith(
          fontSize: 11,
          color: scheme.onSurfaceVariant.withValues(alpha: 0.9),
        );
    final countStyle = nameStyle?.copyWith(
      fontWeight: FontWeight.w700,
      fontSize: 12,
      color: countMuted
          ? scheme.outline
          : scheme.onSurface.withValues(alpha: 0.92),
    );

    return Tooltip(
      message: tooltip,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: scheme.surface.withValues(alpha: 0.72),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: scheme.outlineVariant.withValues(alpha: 0.4),
          ),
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
            Text(label, style: nameStyle, overflow: TextOverflow.ellipsis),
            if (count != null && count!.isNotEmpty) ...[
              const SizedBox(width: 5),
              Text(count!, style: countStyle),
            ],
          ],
        ),
      ),
    );
  }
}
