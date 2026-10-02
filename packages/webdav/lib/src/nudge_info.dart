/// A lightweight attention ping between Kinetic Link adults.
///
/// Stored on WebDAV as `/kinetic/shared/nudges/{id}.json`, encrypted with the
/// family key. Ephemeral: deleted after the recipient dismisses or after TTL.
class FamilyNudge {
  final String id;
  final String fromLinkId;
  final String toLinkId;

  /// Display name of the sender at send time (best-effort).
  final String fromDisplayName;

  final DateTime createdAt;
  final DateTime expiresAt;

  const FamilyNudge({
    required this.id,
    required this.fromLinkId,
    required this.toLinkId,
    required this.fromDisplayName,
    required this.createdAt,
    required this.expiresAt,
  });

  bool isExpired([DateTime? now]) {
    final clock = now ?? DateTime.now().toUtc();
    return !expiresAt.toUtc().isAfter(clock);
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'fromLinkId': fromLinkId,
        'toLinkId': toLinkId,
        'fromDisplayName': fromDisplayName,
        'createdAt': createdAt.toUtc().toIso8601String(),
        'expiresAt': expiresAt.toUtc().toIso8601String(),
      };

  factory FamilyNudge.fromJson(Map<String, dynamic> json) => FamilyNudge(
        id: json['id'] as String,
        fromLinkId: json['fromLinkId'] as String,
        toLinkId: json['toLinkId'] as String,
        fromDisplayName: json['fromDisplayName'] as String? ?? '',
        createdAt: DateTime.parse(json['createdAt'] as String),
        expiresAt: DateTime.parse(json['expiresAt'] as String),
      );

  static FamilyNudge? tryFromJson(Map<String, dynamic> json) {
    try {
      return FamilyNudge.fromJson(json);
    } catch (_) {
      return null;
    }
  }
}
