import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:flutter_test/flutter_test.dart';
import 'package:kinetic_webdav/kinetic_webdav.dart';
import 'package:link/sync/webdav_config_repository.dart';

import '../helpers/fake_http_client.dart';
import '../helpers/sync_test_harness.dart';
import '../helpers/test_database.dart';

void main() {
  setUpAll(() {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  });

  group('disconnect round-trip', () {
    late SharedStorage storage;

    setUp(() => storage = SharedStorage());

    test('Alice tombstone is seen by Bob and cleaned up', () async {
      List<String>? bobSaw;
      final aliceRepo = WebDavConfigRepository(InMemoryKeyValueStore());
      final bobRepo = WebDavConfigRepository(InMemoryKeyValueStore());

      final alice = await makeLinkOrchestrator(
        createTestDatabase(),
        storage,
        username: 'alice',
        linkId: 'link-alice',
        personalKey: syncTestPersonalKeyA,
        configRepo: aliceRepo,
      );
      final bob = await makeLinkOrchestrator(
        createTestDatabase(),
        storage,
        username: 'bob',
        linkId: 'link-bob',
        personalKey: syncTestPersonalKeyB,
        configRepo: bobRepo,
        onDisconnectsDetected: (ids) => bobSaw = ids,
      );

      await alice.service.pushDisconnect(
        DisconnectTombstone(
          deviceId: 'link-alice',
          deviceType: 'link',
          disconnectedAt: DateTime.now().toUtc(),
        ),
      );
      expect(
        storage.contains('/kinetic/shared/disconnect/link-alice.json'),
        isTrue,
      );

      await bob.orchestrator.syncWithService(bob.service);

      expect(bobSaw, contains('link-alice'));
      expect(
        storage.contains('/kinetic/shared/disconnect/link-alice.json'),
        isFalse,
      );
    });

    test('kid tombstone triggers kids onDisconnected via syncWithService',
        () async {
      // Exercise wire + kids orchestrator path without importing kids package:
      // push tombstone here; kids-side assert lives in kids_sync_roundtrip_test.
      await makeLinkOrchestrator(
        createTestDatabase(),
        storage,
        username: 'alice',
        linkId: 'link-alice',
        personalKey: syncTestPersonalKeyA,
      ).then((alice) async {
        await alice.service.pushDisconnect(
          DisconnectTombstone(
            deviceId: 'kid-mees',
            deviceType: 'kid',
            disconnectedAt: DateTime.now().toUtc(),
          ),
        );
        expect(
          storage.contains('/kinetic/shared/disconnect/kid-mees.json'),
          isTrue,
        );
        final tombs = await alice.service.pullDisconnects();
        expect(tombs.single.deviceId, 'kid-mees');
        expect(tombs.single.deviceType, 'kid');
      });
    });
  });
}
