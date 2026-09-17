/// Per-kid XP goal stored at `/kinetic/shared/goals/{kidId}.json`.
class KidGoal {
  final String kidId;
  final String title;
  final int targetXp;
  final DateTime updatedAt;

  const KidGoal({
    required this.kidId,
    required this.title,
    required this.targetXp,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() => {
        'kidId': kidId,
        'title': title,
        'targetXp': targetXp,
        'updatedAt': updatedAt.toUtc().toIso8601String(),
      };

  factory KidGoal.fromJson(Map<String, dynamic> json) {
    return KidGoal(
      kidId: json['kidId'] as String? ?? '',
      title: json['title'] as String? ?? '',
      targetXp: (json['targetXp'] as num?)?.toInt() ?? 0,
      updatedAt: DateTime.tryParse(json['updatedAt'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
    );
  }

  KidGoal copyWith({
    String? kidId,
    String? title,
    int? targetXp,
    DateTime? updatedAt,
  }) {
    return KidGoal(
      kidId: kidId ?? this.kidId,
      title: title ?? this.title,
      targetXp: targetXp ?? this.targetXp,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
