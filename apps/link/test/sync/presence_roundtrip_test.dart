import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:flutter_test/flutter_test.dart';
import 'package:kinetic_webdav/kinetic_webdav.dart';

import '../helpers/fake_http_client.dart';
import '../helpers/sync_test_harness.dart';
import '../helpers/test_database.dart';

void main() {
  setUpAll(() {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  });

  group('presence round-trip', () {
    late SharedStorage storage;

    setUp(() {
      storage = SharedStorage();
    });

    test('syncWithService writes presence for this link device', () async {
      final db = createTestDatabase();
      final built = await makeLinkOrchestrator(
        db,
        storage,
        username: 'alice',
        linkId: 'link-alice',
        personalKey: syncTestPersonalKeyA,
      );

      await built.orchestrator.syncWithService(built.service);

      expect(
        storage.contains('/kinetic/shared/presence/link-alice.json'),
        isTrue,
      );
      final presence = await built.service.pullPresence();
      expect(presence.single.deviceId, 'link-alice');
      expect(presence.single.deviceType, 'link');
    });

    test('pullPresence sees other link and kid devices, not self', () async {
      final dbA = createTestDatabase();
      final alice = await makeLinkOrchestrator(
        dbA,
        storage,
        username: 'alice',
        linkId: 'link-alice',
        personalKey: syncTestPersonalKeyA,
      );
      final bob = await makeLinkOrchestrator(
        createTestDatabase(),
        storage,
        username: 'bob',
        linkId: 'link-bob',
        personalKey: syncTestPersonalKeyB,
      );

      await alice.orchestrator.syncWithService(alice.service);
      await bob.orchestrator.syncWithService(bob.service);
      await alice.service.pushPresence(
        PresenceInfo(
          deviceId: 'kid-mees',
          deviceType: 'kid',
          displayName: 'Mees',
          lastSeen: DateTime.now().toUtc(),
        ),
      );

      final others = await alice.service.pullPresence();
      final ids = others.map((p) => p.deviceId).toSet();
      expect(ids, containsAll(['link-alice', 'link-bob', 'kid-mees']));

      final withoutSelf = others.where((p) => p.deviceId != 'link-alice');
      expect(withoutSelf.map((p) => p.deviceId).toSet(), {
        'link-bob',
        'kid-mees',
      });
    });

    test('deletePresence removes the presence blob', () async {
      final built = await makeLinkOrchestrator(
        createTestDatabase(),
        storage,
        username: 'alice',
        linkId: 'link-alice',
        personalKey: syncTestPersonalKeyA,
      );
      await built.orchestrator.syncWithService(built.service);
      await built.service.deletePresence('link-alice');
      expect(
        storage.contains('/kinetic/shared/presence/link-alice.json'),
        isFalse,
      );
    });
  });
}
