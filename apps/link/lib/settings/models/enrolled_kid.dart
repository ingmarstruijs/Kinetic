import 'package:kinetic_webdav/kinetic_webdav.dart';

/// A child registered in the family (local cache of the shared roster).
class EnrolledKid {
  final String id;
  final String name;
  final DateTime enrolledAt;

  /// When true, XP rewards and goals are shown for this kid.
  final bool xpEnabled;

  /// Last local/roster update — used for LWW merge with [FamilyKidMember].
  final DateTime updatedAt;

  const EnrolledKid({
    required this.id,
    required this.name,
    required this.enrolledAt,
    this.xpEnabled = true,
    DateTime? updatedAt,
  }) : updatedAt = updatedAt ?? enrolledAt;

  EnrolledKid copyWith({
    String? id,
    String? name,
    DateTime? enrolledAt,
    bool? xpEnabled,
    DateTime? updatedAt,
  }) =>
      EnrolledKid(
        id: id ?? this.id,
        name: name ?? this.name,
        enrolledAt: enrolledAt ?? this.enrolledAt,
        xpEnabled: xpEnabled ?? this.xpEnabled,
        updatedAt: updatedAt ?? this.updatedAt,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'enrolledAt': enrolledAt.toIso8601String(),
        'xpEnabled': xpEnabled,
        'updatedAt': updatedAt.toIso8601String(),
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
    );
  }

  FamilyKidMember toFamilyKidMember() => FamilyKidMember(
        id: id,
        name: name,
        enrolledAt: enrolledAt,
        xpEnabled: xpEnabled,
        updatedAt: updatedAt,
      );

  factory EnrolledKid.fromFamilyKidMember(FamilyKidMember m) => EnrolledKid(
        id: m.id,
        name: m.name,
        enrolledAt: m.enrolledAt,
        xpEnabled: m.xpEnabled,
        updatedAt: m.updatedAt,
      );
}
