import 'package:flutter_test/flutter_test.dart';
import 'package:kinetic_webdav/kinetic_webdav.dart';

void main() {
  group('LoadMetrics', () {
    test('round-trips through JSON', () {
      final updated = DateTime.utc(2025, 8, 1, 10, 0, 0);
      final metrics = LoadMetrics(
        linkId: 'link-abc',
        openByCategory: const {'household': 3, 'admin': 1},
        updatedAt: updated,
      );

      final decoded = LoadMetrics.fromJson(metrics.toJson());

      expect(decoded.linkId, equals('link-abc'));
      expect(decoded.openByCategory, equals({'household': 3, 'admin': 1}));
      expect(decoded.totalOpen, equals(4));
      expect(decoded.updatedAt.toUtc(), equals(updated));
    });

    test('tryFromJson returns null for malformed JSON', () {
      expect(LoadMetrics.tryFromJson({'bad': 'data'}), isNull);
    });
  });
}
