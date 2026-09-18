/// Canonical family roster shared among all Kinetic Link devices.
///
/// Stored on WebDAV as `/kinetic/shared/roster.json`, encrypted with the
/// family key. Devices merge by union of member ids (per-member LWW).
class FamilyRoster {
  final List<FamilyLinkMember> linkMembers;
  final List<FamilyKidMember> kids;
  final DateTime updatedAt;

  const FamilyRoster({
    required this.linkMembers,
    required this.kids,
    required this.updatedAt,
  });

  factory FamilyRoster.empty() => FamilyRoster(
        linkMembers: const [],
        kids: const [],
        updatedAt: DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
      );

  Map<String, dynamic> toJson() => {
        'linkMembers': linkMembers.map((a) => a.toJson()).toList(),
        'kids': kids.map((k) => k.toJson()).toList(),
        'updatedAt': updatedAt.toUtc().toIso8601String(),
      };

  factory FamilyRoster.fromJson(Map<String, dynamic> json) {
    final linkMembersJson = json['linkMembers'] as List<dynamic>? ?? const [];
    final kidsJson = json['kids'] as List<dynamic>? ?? const [];
    return FamilyRoster(
      linkMembers: linkMembersJson
          .whereType<Map>()
          .map((e) => FamilyLinkMember.fromJson(Map<String, dynamic>.from(e)))
          .where((a) => a.id.isNotEmpty)
          .toList(),
      kids: kidsJson
          .whereType<Map>()
          .map((e) => FamilyKidMember.fromJson(Map<String, dynamic>.from(e)))
          .where((k) => k.id.isNotEmpty)
          .toList(),
      updatedAt: DateTime.tryParse(json['updatedAt'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
    );
  }

  FamilyRoster copyWith({
    List<FamilyLinkMember>? linkMembers,
    List<FamilyKidMember>? kids,
    DateTime? updatedAt,
  }) =>
      FamilyRoster(
        linkMembers: linkMembers ?? this.linkMembers,
        kids: kids ?? this.kids,
        updatedAt: updatedAt ?? this.updatedAt,
      );

  /// Upsert this device's link-member row and optionally merge local kids.
  FamilyRoster withLocalLinkMember({
    required FamilyLinkMember self,
    List<FamilyKidMember> localKids = const [],
  }) {
    final memberById = {for (final a in linkMembers) a.id: a};
    memberById[self.id] = self;
    final kidById = {for (final k in kids) k.id: k};
    for (final k in localKids) {
      final existing = kidById[k.id];
      if (existing == null || !k.updatedAt.isBefore(existing.updatedAt)) {
        kidById[k.id] = k;
      }
    }
    return FamilyRoster(
      linkMembers: memberById.values.toList()
        ..sort((a, b) => a.displayName.compareTo(b.displayName)),
      kids: kidById.values.toList()
        ..sort((a, b) => a.name.compareTo(b.name)),
      updatedAt: DateTime.now().toUtc(),
    );
  }

  /// Remove a member (link or kid) after an explicit disconnect.
  FamilyRoster withoutMember(String memberId) {
    return FamilyRoster(
      linkMembers: linkMembers.where((a) => a.id != memberId).toList(),
      kids: kids.where((k) => k.id != memberId).toList(),
      updatedAt: DateTime.now().toUtc(),
    );
  }

  /// Union-merge two rosters; per-member [updatedAt] wins ties.
  static FamilyRoster merge(FamilyRoster a, FamilyRoster b) {
    final linkMembers = <String, FamilyLinkMember>{};
    for (final member in [...a.linkMembers, ...b.linkMembers]) {
      final existing = linkMembers[member.id];
      if (existing == null || !member.updatedAt.isBefore(existing.updatedAt)) {
        linkMembers[member.id] = member;
      }
    }
    final kids = <String, FamilyKidMember>{};
    for (final kid in [...a.kids, ...b.kids]) {
      final existing = kids[kid.id];
      if (existing == null || !kid.updatedAt.isBefore(existing.updatedAt)) {
        kids[kid.id] = kid;
      }
    }
    final updatedAt =
        a.updatedAt.isAfter(b.updatedAt) ? a.updatedAt : b.updatedAt;
    return FamilyRoster(
      linkMembers: linkMembers.values.toList()
        ..sort((x, y) => x.displayName.compareTo(y.displayName)),
      kids: kids.values.toList()..sort((x, y) => x.name.compareTo(y.name)),
      updatedAt: updatedAt,
    );
  }

  List<FamilyLinkMember> otherLinkMembers(String myId) =>
      linkMembers.where((a) => a.id != myId).toList();

  List<FamilyLinkMember> participatingLinkMembers() =>
      linkMembers.where((a) => a.kidsParticipation).toList();
}

/// A Kinetic Link member of the family roster.
class FamilyLinkMember {
  final String id;
  final String displayName;

  /// When true, this member shows kids UI and may act as kids-task verifier.
  final bool kidsParticipation;
  final DateTime joinedAt;
  final DateTime updatedAt;

  const FamilyLinkMember({
    required this.id,
    required this.displayName,
    this.kidsParticipation = true,
    required this.joinedAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'displayName': displayName,
        'kidsParticipation': kidsParticipation,
        'joinedAt': joinedAt.toUtc().toIso8601String(),
        'updatedAt': updatedAt.toUtc().toIso8601String(),
      };

  factory FamilyLinkMember.fromJson(Map<String, dynamic> json) {
    final joined = DateTime.tryParse(json['joinedAt'] as String? ?? '') ??
        DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
    final updated = DateTime.tryParse(json['updatedAt'] as String? ?? '') ??
        joined;
    return FamilyLinkMember(
      id: json['id'] as String? ?? '',
      displayName: json['displayName'] as String? ?? '',
      kidsParticipation: json['kidsParticipation'] as bool? ?? true,
      joinedAt: joined,
      updatedAt: updated,
    );
  }

  FamilyLinkMember copyWith({
    String? id,
    String? displayName,
    bool? kidsParticipation,
    DateTime? joinedAt,
    DateTime? updatedAt,
  }) =>
      FamilyLinkMember(
        id: id ?? this.id,
        displayName: displayName ?? this.displayName,
        kidsParticipation: kidsParticipation ?? this.kidsParticipation,
        joinedAt: joinedAt ?? this.joinedAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
}

/// A kid member of the shared family roster.
class FamilyKidMember {
  final String id;
  final String name;
  final DateTime enrolledAt;
  final bool xpEnabled;
  final DateTime updatedAt;

  const FamilyKidMember({
    required this.id,
    required this.name,
    required this.enrolledAt,
    this.xpEnabled = true,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'enrolledAt': enrolledAt.toUtc().toIso8601String(),
        'xpEnabled': xpEnabled,
        'updatedAt': updatedAt.toUtc().toIso8601String(),
      };

  factory FamilyKidMember.fromJson(Map<String, dynamic> json) {
    final enrolled = DateTime.tryParse(json['enrolledAt'] as String? ?? '') ??
        DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
    final updated = DateTime.tryParse(json['updatedAt'] as String? ?? '') ??
        enrolled;
    return FamilyKidMember(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      enrolledAt: enrolled,
      xpEnabled: json['xpEnabled'] as bool? ?? true,
      updatedAt: updated,
    );
  }

  FamilyKidMember copyWith({
    String? id,
    String? name,
    DateTime? enrolledAt,
    bool? xpEnabled,
    DateTime? updatedAt,
  }) =>
      FamilyKidMember(
        id: id ?? this.id,
        name: name ?? this.name,
        enrolledAt: enrolledAt ?? this.enrolledAt,
        xpEnabled: xpEnabled ?? this.xpEnabled,
        updatedAt: updatedAt ?? this.updatedAt,
      );
}
