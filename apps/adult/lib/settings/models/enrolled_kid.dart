/// A child registered in the family by scanning the parent's enrollment QR.
class EnrolledKid {
  final String id;
  final String name;
  final DateTime enrolledAt;

  /// When true, XP rewards and goals are shown for this kid.
  final bool xpEnabled;

  const EnrolledKid({
    required this.id,
    required this.name,
    required this.enrolledAt,
    this.xpEnabled = true,
  });

  EnrolledKid copyWith({
    String? id,
    String? name,
    DateTime? enrolledAt,
    bool? xpEnabled,
  }) => EnrolledKid(
    id: id ?? this.id,
    name: name ?? this.name,
    enrolledAt: enrolledAt ?? this.enrolledAt,
    xpEnabled: xpEnabled ?? this.xpEnabled,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'enrolledAt': enrolledAt.toIso8601String(),
    'xpEnabled': xpEnabled,
  };

  factory EnrolledKid.fromJson(Map<String, dynamic> json) => EnrolledKid(
    id: json['id'] as String,
    name: json['name'] as String,
    enrolledAt: DateTime.parse(json['enrolledAt'] as String),
    xpEnabled: json['xpEnabled'] as bool? ?? true,
  );
}
