import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:kinetic_webdav/kinetic_webdav.dart';

import 'fake_http_client.dart';

void main() {
  late SharedStorage storage;
  late Uint8List familyKey;
  late WebDavSyncService service;

  setUp(() {
    storage = SharedStorage();
    familyKey = KineticEncryption.generateFamilyKey();
    final config = SyncConfig(
      serverUrl: 'https://fake-dav',
      username: 'alice',
      password: 'pass',
      linkId: 'link-alice',
      personalKeyBytes: KineticEncryption.generatePersonalKey(),
      familyKeyBytes: familyKey,
    );
    final client = WebDavClient(
      baseUrl: config.baseUrl,
      username: config.username,
      password: config.password,
      httpClient: FakeHttpClient(storage),
    );
    service = WebDavSyncService(client: client, config: config);
  });

  group('roster wire', () {
    test('pushRoster / pullRoster encrypt round-trip', () async {
      final now = DateTime.utc(2026, 3, 1);
      final roster = FamilyRoster(
        linkMembers: [
          FamilyLinkMember(
            id: 'link-alice',
            displayName: 'Alice',
            kidsParticipation: true,
            joinedAt: now,
            updatedAt: now,
          ),
        ],
        kids: [
          FamilyKidMember(
            id: 'kid-1',
            name: 'Mees',
            enrolledAt: now,
            updatedAt: now,
          ),
        ],
        updatedAt: now,
      );

      await service.pushRoster(roster);
      expect(storage.contains('/kinetic/shared/roster.json'), isTrue);

      final pulled = await service.pullRoster();
      expect(pulled, isNotNull);
      expect(pulled!.linkMembers.single.id, 'link-alice');
      expect(pulled.kids.single.name, 'Mees');
    });
  });

  group('presence wire', () {
    test('pushPresence / pullPresence / deletePresence', () async {
      final now = DateTime.utc(2026, 3, 2, 10);
      await service.pushPresence(
        PresenceInfo(
          deviceId: 'link-alice',
          deviceType: 'link',
          displayName: 'Alice',
          lastSeen: now,
        ),
      );
      expect(
        storage.contains('/kinetic/shared/presence/link-alice.json'),
        isTrue,
      );

      final all = await service.pullPresence();
      expect(all.single.deviceId, 'link-alice');
      expect(all.single.deviceType, 'link');

      await service.deletePresence('link-alice');
      expect(
        storage.contains('/kinetic/shared/presence/link-alice.json'),
        isFalse,
      );
      expect(await service.pullPresence(), isEmpty);
    });
  });

  group('disconnect wire', () {
    test('pushDisconnect / pullDisconnects / deleteDisconnect', () async {
      final at = DateTime.utc(2026, 3, 3);
      await service.pushDisconnect(
        DisconnectTombstone(
          deviceId: 'link-bob',
          deviceType: 'link',
          disconnectedAt: at,
        ),
      );
      expect(
        storage.contains('/kinetic/shared/disconnect/link-bob.json'),
        isTrue,
      );

      final tombs = await service.pullDisconnects();
      expect(tombs.single.deviceId, 'link-bob');
      expect(tombs.single.deviceType, 'link');

      await service.deleteDisconnect('link-bob');
      expect(
        storage.contains('/kinetic/shared/disconnect/link-bob.json'),
        isFalse,
      );
      expect(await service.pullDisconnects(), isEmpty);
    });
  });
}
