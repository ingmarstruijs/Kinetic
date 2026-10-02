import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:flutter_test/flutter_test.dart';
import 'package:kinetic_webdav/kinetic_webdav.dart';
import 'package:link/sync/sync_orchestrator.dart';

import '../helpers/fake_http_client.dart';
import '../helpers/sync_test_harness.dart';
import '../helpers/test_database.dart';

void main() {
  setUpAll(() {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  });

  group('nudge round-trip', () {
    late SharedStorage storage;

    setUp(() {
      storage = SharedStorage();
    });

    test('pushNudge / pullNudges preserves fields', () async {
      final alice = await makeLinkOrchestrator(
        createTestDatabase(),
        storage,
        username: 'alice',
        linkId: 'link-alice',
        personalKey: syncTestPersonalKeyA,
      );

      final now = DateTime.utc(2026, 4, 1, 12);
      final nudge = FamilyNudge(
        id: 'nudge-abc',
        fromLinkId: 'link-alice',
        toLinkId: 'link-bob',
        fromDisplayName: 'Alice',
        createdAt: now,
        expiresAt: now.add(const Duration(hours: 24)),
      );

      await alice.service.pushNudge(nudge);
      expect(
        storage.contains('/kinetic/shared/nudges/nudge-abc.json'),
        isTrue,
      );

      final pulled = await alice.service.pullNudges();
      expect(pulled, hasLength(1));
      expect(pulled.single.id, 'nudge-abc');
      expect(pulled.single.fromLinkId, 'link-alice');
      expect(pulled.single.toLinkId, 'link-bob');
      expect(pulled.single.fromDisplayName, 'Alice');
    });

    test('deleteNudge removes the shared file', () async {
      final alice = await makeLinkOrchestrator(
        createTestDatabase(),
        storage,
        username: 'alice',
        linkId: 'link-alice',
        personalKey: syncTestPersonalKeyA,
      );
      final now = DateTime.utc(2026, 4, 1, 12);
      await alice.service.pushNudge(
        FamilyNudge(
          id: 'nudge-del',
          fromLinkId: 'link-alice',
          toLinkId: 'link-bob',
          fromDisplayName: 'Alice',
          createdAt: now,
          expiresAt: now.add(const Duration(hours: 24)),
        ),
      );
      expect(storage.contains('/kinetic/shared/nudges/nudge-del.json'), isTrue);

      await alice.service.deleteNudge('nudge-del');
      expect(storage.contains('/kinetic/shared/nudges/nudge-del.json'), isFalse);
      expect(await alice.service.pullNudges(), isEmpty);
    });

    test('sendNudge writes an inbound nudge the recipient syncs', () async {
      final received = <FamilyNudge>[];
      final alice = await makeLinkOrchestrator(
        createTestDatabase(),
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
        onNudgesReceived: received.addAll,
      );

      await alice.orchestrator.sendNudge(
        toLinkId: 'link-bob',
        fromDisplayName: 'Alice',
      );

      final onWire = await alice.service.pullNudges();
      expect(onWire, hasLength(1));
      expect(onWire.single.toLinkId, 'link-bob');
      expect(onWire.single.fromLinkId, 'link-alice');

      await bob.orchestrator.syncWithService(bob.service);
      expect(received, hasLength(1));
      expect(received.single.fromDisplayName, 'Alice');
    });

    test('sync notifies recipient of inbound nudges once', () async {
      final received = <FamilyNudge>[];
      final alice = await makeLinkOrchestrator(
        createTestDatabase(),
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
        onNudgesReceived: received.addAll,
      );

      final now = DateTime.now().toUtc();
      await alice.service.pushNudge(
        FamilyNudge(
          id: 'nudge-to-bob',
          fromLinkId: 'link-alice',
          toLinkId: 'link-bob',
          fromDisplayName: 'Alice',
          createdAt: now,
          expiresAt: now.add(SyncOrchestrator.nudgeTtl),
        ),
      );

      await bob.orchestrator.syncWithService(bob.service);

      expect(received, hasLength(1));
      expect(received.single.toLinkId, 'link-bob');
      expect(received.single.fromLinkId, 'link-alice');
      expect(received.single.fromDisplayName, 'Alice');

      received.clear();
      await bob.orchestrator.syncWithService(bob.service);
      expect(received, isEmpty);
    });

    test('sync ignores nudges addressed to someone else', () async {
      final received = <FamilyNudge>[];
      final alice = await makeLinkOrchestrator(
        createTestDatabase(),
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
        onNudgesReceived: received.addAll,
      );

      final now = DateTime.now().toUtc();
      await alice.service.pushNudge(
        FamilyNudge(
          id: 'nudge-for-carol',
          fromLinkId: 'link-alice',
          toLinkId: 'link-carol',
          fromDisplayName: 'Alice',
          createdAt: now,
          expiresAt: now.add(SyncOrchestrator.nudgeTtl),
        ),
      );

      await bob.orchestrator.syncWithService(bob.service);
      expect(received, isEmpty);
    });

    test('sync deletes expired nudges and does not notify', () async {
      final received = <FamilyNudge>[];
      final alice = await makeLinkOrchestrator(
        createTestDatabase(),
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
        onNudgesReceived: received.addAll,
      );

      final now = DateTime.now().toUtc();
      await alice.service.pushNudge(
        FamilyNudge(
          id: 'nudge-expired',
          fromLinkId: 'link-alice',
          toLinkId: 'link-bob',
          fromDisplayName: 'Alice',
          createdAt: now.subtract(const Duration(hours: 30)),
          expiresAt: now.subtract(const Duration(hours: 6)),
        ),
      );
      expect(
        storage.contains('/kinetic/shared/nudges/nudge-expired.json'),
        isTrue,
      );

      await bob.orchestrator.syncWithService(bob.service);
      expect(received, isEmpty);
      expect(
        storage.contains('/kinetic/shared/nudges/nudge-expired.json'),
        isFalse,
      );
    });

    test('dismissNudge removes the remote file', () async {
      final alice = await makeLinkOrchestrator(
        createTestDatabase(),
        storage,
        username: 'alice',
        linkId: 'link-alice',
        personalKey: syncTestPersonalKeyA,
      );
      final now = DateTime.now().toUtc();
      await alice.service.pushNudge(
        FamilyNudge(
          id: 'nudge-dismiss',
          fromLinkId: 'link-alice',
          toLinkId: 'link-bob',
          fromDisplayName: 'Alice',
          createdAt: now,
          expiresAt: now.add(SyncOrchestrator.nudgeTtl),
        ),
      );

      await alice.orchestrator.dismissNudge('nudge-dismiss');
      expect(
        storage.contains('/kinetic/shared/nudges/nudge-dismiss.json'),
        isFalse,
      );
    });

    test('sendNudge rejects empty or self recipient', () async {
      final alice = await makeLinkOrchestrator(
        createTestDatabase(),
        storage,
        username: 'alice',
        linkId: 'link-alice',
        personalKey: syncTestPersonalKeyA,
      );

      await expectLater(
        alice.orchestrator.sendNudge(toLinkId: ''),
        throwsA(isA<ArgumentError>()),
      );
      await expectLater(
        alice.orchestrator.sendNudge(toLinkId: 'link-alice'),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('sendNudge enforces cooldown per recipient', () async {
      final alice = await makeLinkOrchestrator(
        createTestDatabase(),
        storage,
        username: 'alice',
        linkId: 'link-alice',
        personalKey: syncTestPersonalKeyA,
      );

      await alice.orchestrator.sendNudge(
        toLinkId: 'link-bob',
        fromDisplayName: 'Alice',
      );

      await expectLater(
        alice.orchestrator.sendNudge(
          toLinkId: 'link-bob',
          fromDisplayName: 'Alice',
        ),
        throwsA(
          isA<StateError>().having(
            (e) => e.message,
            'message',
            'nudge_cooldown',
          ),
        ),
      );

      // Different recipient is still allowed.
      await alice.orchestrator.sendNudge(
        toLinkId: 'link-carol',
        fromDisplayName: 'Alice',
      );
      final ids = (await alice.service.pullNudges()).map((n) => n.toLinkId);
      expect(ids, containsAll(['link-bob', 'link-carol']));
    });

    test('sendNudge cooldown can be primed via debug helper', () async {
      final alice = await makeLinkOrchestrator(
        createTestDatabase(),
        storage,
        username: 'alice',
        linkId: 'link-alice',
        personalKey: syncTestPersonalKeyA,
      );

      alice.orchestrator.debugMarkNudgeSent('link-bob');

      await expectLater(
        alice.orchestrator.sendNudge(
          toLinkId: 'link-bob',
          fromDisplayName: 'Alice',
        ),
        throwsA(
          isA<StateError>().having(
            (e) => e.message,
            'message',
            'nudge_cooldown',
          ),
        ),
      );
    });
  });
}
