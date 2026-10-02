import 'package:flutter_test/flutter_test.dart';
import 'package:kinetic_webdav/kinetic_webdav.dart';

void main() {
  group('FamilyNudge', () {
    test('round-trips through JSON', () {
      final created = DateTime.utc(2026, 4, 1, 10, 0, 0);
      final expires = DateTime.utc(2026, 4, 2, 10, 0, 0);
      final nudge = FamilyNudge(
        id: 'nudge-1',
        fromLinkId: 'link-alice',
        toLinkId: 'link-bob',
        fromDisplayName: 'Alice',
        createdAt: created,
        expiresAt: expires,
      );

      final decoded = FamilyNudge.fromJson(nudge.toJson());

      expect(decoded.id, 'nudge-1');
      expect(decoded.fromLinkId, 'link-alice');
      expect(decoded.toLinkId, 'link-bob');
      expect(decoded.fromDisplayName, 'Alice');
      expect(decoded.createdAt.toUtc(), created);
      expect(decoded.expiresAt.toUtc(), expires);
    });

    test('tryFromJson returns null for malformed JSON', () {
      expect(FamilyNudge.tryFromJson({'bad': 'data'}), isNull);
    });

    test('isExpired respects expiresAt', () {
      final nudge = FamilyNudge(
        id: 'nudge-2',
        fromLinkId: 'a',
        toLinkId: 'b',
        fromDisplayName: 'A',
        createdAt: DateTime.utc(2026, 4, 1),
        expiresAt: DateTime.utc(2026, 4, 2),
      );
      expect(nudge.isExpired(DateTime.utc(2026, 4, 1, 12)), isFalse);
      expect(nudge.isExpired(DateTime.utc(2026, 4, 2)), isTrue);
      expect(nudge.isExpired(DateTime.utc(2026, 4, 3)), isTrue);
    });

    test('default fromDisplayName is empty string when omitted in JSON', () {
      final decoded = FamilyNudge.fromJson({
        'id': 'nudge-3',
        'fromLinkId': 'a',
        'toLinkId': 'b',
        'createdAt': '2026-04-01T00:00:00.000Z',
        'expiresAt': '2026-04-02T00:00:00.000Z',
      });
      expect(decoded.fromDisplayName, '');
    });
  });
}
