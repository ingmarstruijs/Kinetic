import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:flutter_test/flutter_test.dart';
import 'package:kinetic_webdav/kinetic_webdav.dart';
import 'package:link/db/app_database.dart';

import '../helpers/fake_http_client.dart';
import '../helpers/sync_test_harness.dart';
import '../helpers/test_database.dart';

Future<void> _insertDirtyKidsTask(
  AppDatabase db, {
  required String id,
  required String kidsTaskId,
  required String title,
  String? targetKidId,
  String? recurrenceRule,
  DateTime? dueDate,
}) async {
  final now = DateTime.now().toUtc();
  await db.into(db.personalTasks).insert(
        PersonalTasksCompanion.insert(
          id: id,
          title: title,
          kidsTaskId: Value(kidsTaskId),
          targetKidId: Value(targetKidId),
          syncState: const Value('dirty'),
          recurrenceRule: Value(recurrenceRule),
          dueDate: Value(dueDate),
          createdAt: now,
          updatedAt: now,
        ),
      );
}

void main() {
  setUpAll(() {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  });

  group('kids shared tasks round-trip (link side)', () {
    late SharedStorage storage;

    setUp(() => storage = SharedStorage());

    test('dirty kids-assigned task lands under shared/tasks', () async {
      final db = createTestDatabase();
      final alice = await makeLinkOrchestrator(
        db,
        storage,
        username: 'alice',
        linkId: 'link-alice',
        personalKey: syncTestPersonalKeyA,
      );

      await _insertDirtyKidsTask(
        db,
        id: 'personal-1',
        kidsTaskId: 'kids-uid-1',
        title: 'Tidy room',
        targetKidId: 'kid-mees',
      );
      await alice.orchestrator.syncWithService(alice.service);

      expect(storage.contains('/kinetic/shared/tasks/kids-uid-1.ics'), isTrue);
      final shared = await alice.service.pullSharedTasks();
      expect(shared.single.uid, 'kids-uid-1');
      expect(shared.single.summary, 'Tidy room');
      expect(shared.single.description, contains('xKineticTargetKidId:kid-mees'));
      expect(shared.single.status, ICalTaskStatus.needsAction);
    });

    test('pushes recurrence rule on shared kids task', () async {
      final db = createTestDatabase();
      final alice = await makeLinkOrchestrator(
        db,
        storage,
        username: 'alice',
        linkId: 'link-alice',
        personalKey: syncTestPersonalKeyA,
      );
      final due = DateTime.utc(2026, 9, 22, 17);

      await _insertDirtyKidsTask(
        db,
        id: 'personal-rec',
        kidsTaskId: 'kids-uid-rec',
        title: 'Brush teeth',
        targetKidId: 'kid-mees',
        recurrenceRule: 'FREQ=DAILY',
        dueDate: due,
      );
      await alice.orchestrator.syncWithService(alice.service);

      final shared = (await alice.service.pullSharedTasks()).single;
      expect(shared.rrule, 'FREQ=DAILY');
      expect(shared.dueAt, due);
    });

    test('accepting recurring kids mission rolls due and keeps RRULE', () async {
      final db = createTestDatabase();
      final alice = await makeLinkOrchestrator(
        db,
        storage,
        username: 'alice',
        linkId: 'link-alice',
        personalKey: syncTestPersonalKeyA,
      );
      final due = DateTime.utc(2026, 9, 22, 17);

      await _insertDirtyKidsTask(
        db,
        id: 'personal-rec-accept',
        kidsTaskId: 'kids-uid-rec-accept',
        title: 'Brush teeth',
        targetKidId: 'kid-mees',
        recurrenceRule: 'FREQ=DAILY',
        dueDate: due,
      );
      await alice.orchestrator.syncWithService(alice.service);

      // Kid marks awaiting verification on the wire.
      final remote = (await alice.service.pullSharedTasks()).single;
      await alice.service.pushSharedTask(
        remote.copyWith(
          status: ICalTaskStatus.inProcess,
          updatedAt: DateTime.now().toUtc(),
        ),
      );

      await alice.orchestrator.acceptKidsTaskCompletionWithService(
        alice.service,
        (await alice.service.pullSharedTasks()).single,
      );

      final after = (await alice.service.pullSharedTasks()).single;
      expect(after.status, ICalTaskStatus.needsAction);
      expect(after.rrule, 'FREQ=DAILY');
      expect(after.dueAt!.toUtc(), DateTime.utc(2026, 9, 23, 17));

      final local = await (db.select(db.personalTasks)
            ..where((t) => t.id.equals('personal-rec-accept')))
          .getSingle();
      expect(local.isCompleted, isFalse);
      expect(local.dueDate!.toUtc(), DateTime.utc(2026, 9, 23, 17));
      expect(local.recurrenceRule, 'FREQ=DAILY');
    });

    test('preserves remote inProcess when pushing dirty kids task', () async {
      final db = createTestDatabase();
      final alice = await makeLinkOrchestrator(
        db,
        storage,
        username: 'alice',
        linkId: 'link-alice',
        personalKey: syncTestPersonalKeyA,
      );

      await _insertDirtyKidsTask(
        db,
        id: 'personal-2',
        kidsTaskId: 'kids-uid-2',
        title: 'Walk dog',
        targetKidId: 'kid-mees',
      );
      await alice.orchestrator.syncWithService(alice.service);

      // Kid marks awaiting verification on the wire.
      final remote = (await alice.service.pullSharedTasks()).single;
      await alice.service.pushSharedTask(
        remote.copyWith(
          status: ICalTaskStatus.inProcess,
          updatedAt: DateTime.now().toUtc(),
        ),
      );

      // Link edits title → dirty push must keep inProcess.
      await (db.update(db.personalTasks)
            ..where((t) => t.id.equals('personal-2')))
          .write(
            PersonalTasksCompanion(
              title: const Value('Walk dog urgently'),
              syncState: const Value('dirty'),
              updatedAt: Value(DateTime.now().toUtc()),
            ),
          );
      await alice.orchestrator.syncWithService(alice.service);

      final after = (await alice.service.pullSharedTasks()).single;
      expect(after.status, ICalTaskStatus.inProcess);
      expect(after.summary, 'Walk dog urgently');
    });

    test('deleting kids-assigned task removes shared file', () async {
      final db = createTestDatabase();
      final alice = await makeLinkOrchestrator(
        db,
        storage,
        username: 'alice',
        linkId: 'link-alice',
        personalKey: syncTestPersonalKeyA,
      );

      await _insertDirtyKidsTask(
        db,
        id: 'personal-3',
        kidsTaskId: 'kids-uid-3',
        title: 'Feed cat',
      );
      await alice.orchestrator.syncWithService(alice.service);
      expect(storage.contains('/kinetic/shared/tasks/kids-uid-3.ics'), isTrue);

      await (db.update(db.personalTasks)
            ..where((t) => t.id.equals('personal-3')))
          .write(const PersonalTasksCompanion(syncState: Value('deleted')));
      await alice.orchestrator.syncWithService(alice.service);

      expect(storage.contains('/kinetic/shared/tasks/kids-uid-3.ics'), isFalse);
    });
  });
}
