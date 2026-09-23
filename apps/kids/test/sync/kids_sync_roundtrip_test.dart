import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:flutter_test/flutter_test.dart';
import 'package:kids/db/app_database.dart';
import 'package:kids/task/services/kids_task_repository.dart';
import 'package:kinetic_webdav/kinetic_webdav.dart';

import '../helpers/fake_http_client.dart';
import '../helpers/sync_test_harness.dart';
import '../helpers/test_database.dart';

/// Link-side helper on the same SharedStorage / family key as kids harness.
WebDavSyncService _makeLinkService(SharedStorage storage) {
  final config = SyncConfig(
    serverUrl: 'https://fake-dav',
    username: 'alice',
    password: 'pass',
    linkId: 'link-alice',
    personalKeyBytes: kidsSyncTestPersonalKey,
    familyKeyBytes: kidsSyncTestFamilyKey,
  );
  final client = WebDavClient(
    baseUrl: config.baseUrl,
    username: config.username,
    password: config.password,
    httpClient: FakeHttpClient(storage),
  );
  return WebDavSyncService(client: client, config: config);
}

void main() {
  setUpAll(() {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  });

  group('kids sync round-trip', () {
    late SharedStorage storage;
    const kidId = 'kid-mees';

    setUp(() => storage = SharedStorage());

    test('pull shared task inserts locally and fires onNewTaskReceived',
        () async {
      String? notified;
      final link = _makeLinkService(storage);
      final now = DateTime.now().toUtc();
      await link.pushSharedTask(
        ICalTask(
          uid: 'kids-task-1',
          summary: 'Tidy room',
          description:
              'xKineticLinkTaskId:p1;xKineticCategory:household;xKineticXpReward:10;xKineticTargetKidId:$kidId',
          status: ICalTaskStatus.needsAction,
          createdAt: now,
          updatedAt: now,
        ),
      );

      final db = createTestDatabase();
      final kids = makeKidsOrchestrator(
        db,
        storage,
        myKidId: kidId,
        onNewTaskReceived: (t) => notified = t,
      );
      await kids.orchestrator.syncWithService(kids.service);

      final rows = await db.select(db.kidsTasks).get();
      expect(rows.single.id, 'kids-task-1');
      expect(rows.single.title, 'Tidy room');
      expect(notified, 'Tidy room');
    });

    test('completion push sets shared status to inProcess', () async {
      final link = _makeLinkService(storage);
      final now = DateTime.now().toUtc();
      await link.pushSharedTask(
        ICalTask(
          uid: 'kids-task-2',
          summary: 'Walk dog',
          description:
              'xKineticLinkTaskId:p2;xKineticCategory:other;xKineticXpReward:10;xKineticTargetKidId:$kidId',
          status: ICalTaskStatus.needsAction,
          createdAt: now,
          updatedAt: now,
        ),
      );

      final db = createTestDatabase();
      final repo = KidsTaskRepository(db: db);
      final kids = makeKidsOrchestrator(db, storage, myKidId: kidId);
      await kids.orchestrator.syncWithService(kids.service);

      await repo.requestComplete('kids-task-2');
      await kids.orchestrator.syncWithService(kids.service);

      final shared = await link.pullSharedTasks();
      expect(shared.single.uid, 'kids-task-2');
      expect(shared.single.status, ICalTaskStatus.inProcess);
    });

    test('tombstone for kid id fires onDisconnected', () async {
      var disconnected = false;
      final link = _makeLinkService(storage);
      await link.pushDisconnect(
        DisconnectTombstone(
          deviceId: kidId,
          deviceType: 'kid',
          disconnectedAt: DateTime.now().toUtc(),
        ),
      );

      final kids = makeKidsOrchestrator(
        createTestDatabase(),
        storage,
        myKidId: kidId,
        onDisconnected: () => disconnected = true,
      );
      await kids.orchestrator.syncWithService(kids.service);
      expect(disconnected, isTrue);
    });

    test('goal pull invokes onGoalReceived', () async {
      KidGoal? received;
      final link = _makeLinkService(storage);
      await link.pushGoal(
        KidGoal(
          kidId: kidId,
          title: 'New bike',
          targetXp: 100,
          updatedAt: DateTime.now().toUtc(),
        ),
      );

      final kids = makeKidsOrchestrator(
        createTestDatabase(),
        storage,
        myKidId: kidId,
        onGoalReceived: (g) => received = g,
      );
      await kids.orchestrator.syncWithService(kids.service);

      expect(received, isNotNull);
      expect(received!.title, 'New bike');
      expect(received!.targetXp, 100);
    });

    test('link delete of shared task hard-deletes clean local row', () async {
      final link = _makeLinkService(storage);
      final now = DateTime.now().toUtc();
      await link.pushSharedTask(
        ICalTask(
          uid: 'kids-task-3',
          summary: 'Feed cat',
          description:
              'xKineticLinkTaskId:p3;xKineticCategory:other;xKineticXpReward:10;xKineticTargetKidId:$kidId',
          status: ICalTaskStatus.needsAction,
          createdAt: now,
          updatedAt: now,
        ),
      );

      final db = createTestDatabase();
      final kids = makeKidsOrchestrator(db, storage, myKidId: kidId);
      await kids.orchestrator.syncWithService(kids.service);
      expect(await db.select(db.kidsTasks).get(), hasLength(1));

      await link.deleteSharedTask('kids-task-3');
      await kids.orchestrator.syncWithService(kids.service);
      expect(await db.select(db.kidsTasks).get(), isEmpty);
    });
  });
}
