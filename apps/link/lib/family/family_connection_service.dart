import 'package:kinetic_webdav/kinetic_webdav.dart';

import '../l10n/generated/app_localizations.dart';
import '../settings/models/enrolled_kid.dart';

enum FamilyMemberType { linkMember, kid }

/// Connection state for a family member eligible for task delegation.
class FamilyMemberStatus {
  final String id;
  final String name;
  final FamilyMemberType type;
  final bool isConnected;
  final bool isStale;
  final DateTime? lastSeen;

  const FamilyMemberStatus({
    required this.id,
    required this.name,
    required this.type,
    required this.isConnected,
    required this.isStale,
    this.lastSeen,
  });

  String statusLabel(AppLocalizations l10n) =>
      FamilyConnectionService.formatStatus(
        isConnected: isConnected,
        isStale: isStale,
        lastSeen: lastSeen,
        l10n: l10n,
      );
}

/// Evaluates link-member / kid connectivity from enrollment and presence data.
class FamilyConnectionService {
  static const connectedThreshold = Duration(days: 7);
  static const staleThreshold = Duration(days: 14);

  /// Status for every link member in the family besides this device.
  ///
  /// [otherLinkMembers] comes from the shared roster
  /// (`FamilyRoster.otherLinkMembers(myId)`). When it is empty the list is derived
  /// from presence entries with `deviceType == 'link'` so devices that have
  /// not merged a roster yet still see their family member.
  static List<FamilyMemberStatus> linkStatuses({
    List<FamilyLinkMember> otherLinkMembers = const [],
    required List<PresenceInfo> presenceList,
    DateTime? now,
    bool allowWithoutPresence = false,
  }) {
    final clock = now ?? DateTime.now();
    final presenceById = {for (final p in presenceList) p.deviceId: p};

    FamilyMemberStatus build({
      required String id,
      required String name,
      DateTime? lastSeen,
    }) {
      final (connected, stale) = _evaluate(
        lastSeen,
        clock,
        allowWithoutPresence: allowWithoutPresence,
      );
      return FamilyMemberStatus(
        id: id,
        name: name,
        type: FamilyMemberType.linkMember,
        isConnected: connected,
        isStale: stale,
        lastSeen: lastSeen,
      );
    }

    if (otherLinkMembers.isNotEmpty) {
      return [
        for (final member in otherLinkMembers)
          build(
            id: member.id,
            name: member.displayName.isNotEmpty
                ? member.displayName
                : 'Family member',
            lastSeen: presenceById[member.id]?.lastSeen,
          ),
      ];
    }

    final linkDevices = presenceList
        .where((p) => p.deviceType == 'link')
        .toList();
    if (linkDevices.isEmpty) {
      return [build(id: 'unknown-link-member', name: 'Family member')];
    }
    return [
      for (final p in linkDevices)
        build(
          id: p.deviceId,
          name: p.displayName.isNotEmpty ? p.displayName : 'Family member',
          lastSeen: p.lastSeen,
        ),
    ];
  }

  /// Convenience over [linkStatuses]; returns the first other link member.
  static FamilyMemberStatus? otherLinkMemberStatus({
    required bool hasOtherLinkMembers,
    required List<PresenceInfo> presenceList,
    List<FamilyLinkMember> otherLinkMembers = const [],
    DateTime? now,
    bool allowWithoutPresence = false,
  }) {
    if (!hasOtherLinkMembers) return null;
    final members = linkStatuses(
      otherLinkMembers: otherLinkMembers,
      presenceList: presenceList,
      now: now,
      allowWithoutPresence: allowWithoutPresence,
    );
    return members.isEmpty ? null : members.first;
  }

  static List<FamilyMemberStatus> kidStatuses({
    required List<EnrolledKid> enrolledKids,
    required List<PresenceInfo> presenceList,
    DateTime? now,
    bool allowWithoutPresence = false,
  }) {
    final clock = now ?? DateTime.now();
    final byId = {for (final p in presenceList) p.deviceId: p};
    return [
      for (final kid in enrolledKids.where((k) => k.isActive))
        () {
          final presence = byId[kid.id];
          final lastSeen = presence?.lastSeen;
          final (connected, stale) = _evaluate(
            lastSeen,
            clock,
            allowWithoutPresence: allowWithoutPresence,
          );
          return FamilyMemberStatus(
            id: kid.id,
            name: kid.name,
            type: FamilyMemberType.kid,
            isConnected: connected,
            isStale: stale,
            lastSeen: lastSeen,
          );
        }(),
    ];
  }

  static bool canSend({
    FamilyMemberStatus? linkMember,
    List<FamilyMemberStatus> linkMembers = const [],
    required List<FamilyMemberStatus> kids,
  }) {
    if (linkMember?.isConnected == true) return true;
    if (linkMembers.any((m) => m.isConnected)) return true;
    return kids.any((k) => k.isConnected);
  }

  static String formatStatus({
    required bool isConnected,
    required bool isStale,
    DateTime? lastSeen,
    required AppLocalizations l10n,
  }) {
    if (!isConnected) {
      if (lastSeen == null) return l10n.connNotConnected;
      return l10n.connNotConnectedSince(
        _formatLastSeen(DateTime.now(), lastSeen, l10n),
      );
    }
    if (isStale && lastSeen == null) return l10n.connUnknownNoSync;
    if (isStale) {
      return l10n.connStale(_formatLastSeen(DateTime.now(), lastSeen!, l10n));
    }
    if (lastSeen == null) return l10n.connConnected;
    return l10n.connConnectedSince(
      _formatLastSeen(DateTime.now(), lastSeen, l10n),
    );
  }

  static (bool connected, bool stale) _evaluate(
    DateTime? lastSeen,
    DateTime now, {
    bool allowWithoutPresence = false,
  }) {
    if (lastSeen == null) {
      if (allowWithoutPresence) return (true, true);
      return (false, false);
    }
    final diff = now.difference(lastSeen.toLocal());
    if (diff > staleThreshold) return (false, true);
    if (diff > connectedThreshold) return (true, true);
    return (true, false);
  }

  /// Same 7 / 14-day windows as presence, for load-metric [updatedAt] timestamps.
  static (bool connected, bool stale) evaluateConnection(
    DateTime? timestamp,
    DateTime now,
  ) =>
      _evaluate(timestamp, now);

  static String _formatLastSeen(
    DateTime now,
    DateTime lastSeen,
    AppLocalizations l10n,
  ) {
    final diff = now.difference(lastSeen.toLocal());
    if (diff.inMinutes < 1) return l10n.relativeJustNow;
    if (diff.inMinutes < 60) return l10n.relativeMinutesAgo(diff.inMinutes);
    if (diff.inHours < 24) return l10n.relativeHoursAgo(diff.inHours);
    if (diff.inDays < 7) return l10n.relativeDaysAgo(diff.inDays);
    return l10n.relativeWeeksAgo(diff.inDays ~/ 7);
  }
}
