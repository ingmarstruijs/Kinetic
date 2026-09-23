import 'package:flutter_test/flutter_test.dart';
import 'package:kinetic_webdav/kinetic_webdav.dart';

void main() {
  group('PresenceInfo', () {
    test('round-trips through JSON', () {
      final now = DateTime.utc(2025, 6, 1, 12, 0, 0);
      final info = PresenceInfo(
        deviceId: 'device-123',
        deviceType: 'link',
        displayName: 'Alice',
        lastSeen: now,
      );

      final decoded = PresenceInfo.fromJson(info.toJson());

      expect(decoded.deviceId, equals('device-123'));
      expect(decoded.deviceType, equals('link'));
      expect(decoded.displayName, equals('Alice'));
      expect(decoded.lastSeen.toUtc(), equals(now));
    });

    test('tryFromJson returns null for malformed JSON', () {
      final result = PresenceInfo.tryFromJson({'bad': 'data'});
      expect(result, isNull);
    });

    test('deviceType distinguishes link from kid', () {
      final link = PresenceInfo(
        deviceId: 'p1',
        deviceType: 'link',
        displayName: 'Link',
        lastSeen: DateTime.now().toUtc(),
      );
      final kid = PresenceInfo(
        deviceId: 'k1',
        deviceType: 'kid',
        displayName: 'Kid',
        lastSeen: DateTime.now().toUtc(),
      );

      expect(link.deviceType, equals('link'));
      expect(kid.deviceType, equals('kid'));
    });
  });

  group('DisconnectTombstone', () {
    test('round-trips through JSON', () {
      final now = DateTime.utc(2025, 6, 2, 9, 30, 0);
      final tombstone = DisconnectTombstone(
        deviceId: 'device-abc',
        deviceType: 'kid',
        disconnectedAt: now,
      );

      final decoded = DisconnectTombstone.fromJson(tombstone.toJson());

      expect(decoded.deviceId, equals('device-abc'));
      expect(decoded.deviceType, equals('kid'));
      expect(decoded.disconnectedAt.toUtc(), equals(now));
    });
  });
}
