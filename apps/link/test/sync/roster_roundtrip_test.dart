import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:flutter_test/flutter_test.dart';
import 'package:kinetic_webdav/kinetic_webdav.dart';
import 'package:link/sync/sync_orchestrator.dart';
import 'package:link/sync/webdav_config_repository.dart';

import '../helpers/fake_http_client.dart';
import '../helpers/sync_test_harness.dart';
import '../helpers/test_database.dart';

void main() {
  setUpAll(() {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  });

  group('roster round-trip', () {
    late SharedStorage storage;
    late WebDavConfigRepository aliceRepo;
    late WebDavConfigRepository bobRepo;

    setUp(() {
      storage = SharedStorage();
      aliceRepo = WebDavConfigRepository(InMemoryKeyValueStore());
      bobRepo = WebDavConfigRepository(InMemoryKeyValueStore());
    });

    test('Alice enrolls kid → Bob sees kid after both sync', () async {
      final kid = await aliceRepo.addEnrolledKid('Mees');

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
      );

      await alice.orchestrator.syncWithService(alice.service);
      await bob.orchestrator.syncWithService(bob.service);

      final bobRoster = await bobRepo.loadCachedRoster();
      expect(bobRoster, isNotNull);
      expect(bobRoster!.kids.map((k) => k.id), contains(kid.id));
      expect(bobRoster.kids.singleWhere((k) => k.id == kid.id).name, 'Mees');
      expect(
        bobRoster.linkMembers.map((m) => m.id).toSet(),
        containsAll(['link-alice', 'link-bob']),
      );
      // Draft until presence — Bob still sees the waiting kid.
      expect(
        bobRoster.kids.singleWhere((k) => k.id == kid.id).isActive,
        isFalse,
      );
    });

    test('kid presence promotes draft to active for Alice and Bob', () async {
      final kid = await aliceRepo.addEnrolledKid('Mees');
      expect(kid.isActive, isFalse);

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
      );

      await alice.orchestrator.syncWithService(alice.service);

      // Simulate kids-device heartbeat without depending on the kids app.
      final kidConfig = SyncConfig(
        serverUrl: 'https://fake-dav',
        username: 'alice',
        password: 'pass',
        linkId: kid.id,
        personalKeyBytes: syncTestPersonalKeyA,
        familyKeyBytes: syncTestFamilyKey,
      );
      final kidClient = WebDavClient(
        baseUrl: kidConfig.baseUrl,
        username: kidConfig.username,
        password: kidConfig.password,
        httpClient: FakeHttpClient(storage),
      );
      final kidService = WebDavSyncService(client: kidClient, config: kidConfig);
      await kidService.pushPresence(
        PresenceInfo(
          deviceId: kid.id,
          deviceType: 'kid',
          displayName: 'Mees',
          lastSeen: DateTime.now().toUtc(),
        ),
      );
      kidClient.dispose();

      await alice.orchestrator.syncWithService(alice.service);
      await bob.orchestrator.syncWithService(bob.service);

      final aliceKids = await aliceRepo.loadEnrolledKids();
      final active = aliceKids.singleWhere((k) => k.id == kid.id);
      expect(active.isActive, isTrue);

      final bobRoster = await bobRepo.loadCachedRoster();
      expect(
        bobRoster!.kids.singleWhere((k) => k.id == kid.id).isActive,
        isTrue,
      );
    });

    test('Bob kidsParticipation=false wins LWW on Alice sync', () async {
      await aliceRepo.addEnrolledKid('Mees');
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
      );

      await alice.orchestrator.syncWithService(alice.service);
      await bob.orchestrator.syncWithService(bob.service);

      await bobRepo.saveKidsParticipation(false);
      // Ensure Bob's self row is newer than Alice's last merge of Bob.
      await Future<void>.delayed(const Duration(milliseconds: 5));
      await bob.orchestrator.syncWithService(bob.service);
      await alice.orchestrator.syncWithService(alice.service);

      final aliceRoster = await aliceRepo.loadCachedRoster();
      final bobMember = aliceRoster!.linkMembers.singleWhere(
        (m) => m.id == 'link-bob',
      );
      expect(bobMember.kidsParticipation, isFalse);
    });

    test('kick via disconnect + roster withoutMember drops member for peer',
        () async {
      FamilyRoster? bobRosterAfter;
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
        onRosterUpdated: (r) => bobRosterAfter = r,
        // Mirror main.dart: kicked device clears family key so _syncRoster
        // does not re-add self after processing the tombstone.
        onDisconnectsDetected: (ids) {
          if (disconnectIncludesSelf('link-bob', ids)) {
            bobRepo.clearFamilyKey();
          }
        },
      );

      await alice.orchestrator.syncWithService(alice.service);
      await bob.orchestrator.syncWithService(bob.service);

      // Alice removes Bob: tombstone + roster without Bob (mirrors removeLinkMember).
      await alice.service.pushDisconnect(
        DisconnectTombstone(
          deviceId: 'link-bob',
          deviceType: 'link',
          disconnectedAt: DateTime.now().toUtc(),
        ),
      );
      var roster = await aliceRepo.loadCachedRoster() ?? FamilyRoster.empty();
      roster = roster.withoutMember('link-bob');
      await alice.service.pushRoster(roster);
      await aliceRepo.saveCachedRoster(roster);

      await bob.orchestrator.syncWithService(bob.service);

      expect(
        bobRosterAfter!.linkMembers.map((m) => m.id),
        isNot(contains('link-bob')),
      );
      // Tombstone cleaned after process.
      expect(
        storage.contains('/kinetic/shared/disconnect/link-bob.json'),
        isFalse,
      );
    });
  });
}
