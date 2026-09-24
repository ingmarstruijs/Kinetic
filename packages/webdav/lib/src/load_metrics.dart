/// Coarse open-task counts per category for a Kinetic Link device.
///
/// Stored on WebDAV as `/kinetic/shared/load/{linkId}.json`,
/// encrypted with the family key. No task titles or other private detail.
class LoadMetrics {
  /// This device's [SyncConfig.linkId].
  final String linkId;

  /// Open personal tasks keyed by category name (e.g. `household`).
  final Map<String, int> openByCategory;

  /// UTC timestamp when these counts were published.
  final DateTime updatedAt;

  const LoadMetrics({
    required this.linkId,
    required this.openByCategory,
    required this.updatedAt,
  });

  int get totalOpen =>
      openByCategory.values.fold<int>(0, (sum, n) => sum + n);

  int openInCategory(String category) => openByCategory[category] ?? 0;

  Map<String, dynamic> toJson() => {
        'linkId': linkId,
        'openByCategory': openByCategory,
        'updatedAt': updatedAt.toUtc().toIso8601String(),
      };

  factory LoadMetrics.fromJson(Map<String, dynamic> json) {
    final raw = json['openByCategory'];
    final counts = <String, int>{};
    if (raw is Map) {
      for (final entry in raw.entries) {
        counts[entry.key.toString()] = (entry.value as num).toInt();
      }
    }
    return LoadMetrics(
      linkId: json['linkId'] as String,
      openByCategory: counts,
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  static LoadMetrics? tryFromJson(Map<String, dynamic> json) {
    try {
      return LoadMetrics.fromJson(json);
    } catch (_) {
      return null;
    }
  }
}
