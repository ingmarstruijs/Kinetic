/// Plaintext task DTO exchanged over the bridge (never encrypted blobs).
class BridgeTaskDto {
  final String id;
  final String title;
  final bool isCompleted;
  final String? notes;
  final DateTime? dueAt;
  final DateTime updatedAt;

  const BridgeTaskDto({
    required this.id,
    required this.title,
    required this.isCompleted,
    this.notes,
    this.dueAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'isCompleted': isCompleted,
        if (notes != null) 'notes': notes,
        if (dueAt != null) 'dueAt': dueAt!.toUtc().toIso8601String(),
        'updatedAt': updatedAt.toUtc().toIso8601String(),
      };

  static BridgeTaskDto fromJson(Map<String, dynamic> json) {
    DateTime? parse(String? s) =>
        s == null ? null : DateTime.tryParse(s)?.toUtc();
    return BridgeTaskDto(
      id: json['id'] as String,
      title: json['title'] as String? ?? '',
      isCompleted: json['isCompleted'] as bool? ?? false,
      notes: json['notes'] as String?,
      dueAt: parse(json['dueAt'] as String?),
      updatedAt: parse(json['updatedAt'] as String?) ??
          DateTime.now().toUtc(),
    );
  }
}
