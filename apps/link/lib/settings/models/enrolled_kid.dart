import 'package:kinetic_webdav/kinetic_webdav.dart';

/// A child registered in the family (local cache of the shared roster).
///
/// Draft kids (`isActive == false`) exist after QR generation until the kids
/// device sends presence (or a parent marks them active). Stale drafts are
/// soft-purged after [draftExpiry].
class EnrolledKid {
  /// Drafts with no presence older than this are removed automatically.
  static const draftExpiry = Duration(days: 7);

  final String id;
  final String name;
  final DateTime enrolledAt;

  /// When true, XP rewards and goals are shown for this kid.
  final bool xpEnabled;

  /// Last local/roster update — used for LWW merge with [FamilyKidMember].
  final DateTime updatedAt;

  /// False until first kids-device presence (or explicit parent confirm).
  final bool isActive;

  const EnrolledKid({
    required this.id,
    required this.name,
    required this.enrolledAt,
    this.xpEnabled = true,
    DateTime? updatedAt,
    this.isActive = true,
  }) : updatedAt = updatedAt ?? enrolledAt;

  /// True when this draft has aged past [draftExpiry] without activation.
  bool isStaleDraft([DateTime? now]) {
    if (isActive) return false;
    final clock = now ?? DateTime.now().toUtc();
    return clock.difference(enrolledAt.toUtc()) >= draftExpiry;
  }

  EnrolledKid copyWith({
    String? id,
    String? name,
    DateTime? enrolledAt,
    bool? xpEnabled,
    DateTime? updatedAt,
    bool? isActive,
  }) =>
      EnrolledKid(
        id: id ?? this.id,
        name: name ?? this.name,
        enrolledAt: enrolledAt ?? this.enrolledAt,
        xpEnabled: xpEnabled ?? this.xpEnabled,
        updatedAt: updatedAt ?? this.updatedAt,
        isActive: isActive ?? this.isActive,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'enrolledAt': enrolledAt.toIso8601String(),
        'xpEnabled': xpEnabled,
        'updatedAt': updatedAt.toIso8601String(),
        'isActive': isActive,
      };

  factory EnrolledKid.fromJson(Map<String, dynamic> json) {
    final enrolled = DateTime.parse(json['enrolledAt'] as String);
    return EnrolledKid(
      id: json['id'] as String,
      name: json['name'] as String,
      enrolledAt: enrolled,
      xpEnabled: json['xpEnabled'] as bool? ?? true,
      updatedAt: DateTime.tryParse(json['updatedAt'] as String? ?? '') ??
          enrolled,
      // Legacy rows without the field were already linked — treat as active.
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  FamilyKidMember toFamilyKidMember() => FamilyKidMember(
        id: id,
        name: name,
        enrolledAt: enrolledAt,
        xpEnabled: xpEnabled,
        updatedAt: updatedAt,
        isActive: isActive,
      );

  factory EnrolledKid.fromFamilyKidMember(FamilyKidMember m) => EnrolledKid(
        id: m.id,
        name: m.name,
        enrolledAt: m.enrolledAt,
        xpEnabled: m.xpEnabled,
        updatedAt: m.updatedAt,
        isActive: m.isActive,
      );
}
