import 'dart:convert';

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:flutter_test/flutter_test.dart';
import 'package:link/db/app_database.dart';

import '../helpers/fake_http_client.dart';
import '../helpers/sync_test_harness.dart';
import '../helpers/test_database.dart';

Future<void> _insertDirtySharedNote(
  AppDatabase db, {
  required String id,
  required String title,
  List<String>? sharedMemberIds,
}) async {
  final now = DateTime.now().toUtc();
  await db.into(db.personalNotes).insert(
        PersonalNotesCompanion.insert(
          id: id,
          title: title,
          body: const Value('hello'),
          isShared: const Value(true),
          sharedMemberIds: Value(
            sharedMemberIds == null || sharedMemberIds.isEmpty
                ? null
                : jsonEncode(sharedMemberIds),
          ),
          syncState: const Value('dirty'),
          createdAt: now,
          updatedAt: now,
        ),
      );
}

void main() {
  setUpAll(() {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  });

  group('shared notes round-trip', () {
    late SharedStorage storage;

    setUp(() => storage = SharedStorage());

    test('dirty shared note on Alice appears on Bob after sync', () async {
      final dbA = createTestDatabase();
      final dbB = createTestDatabase();
      final alice = await makeLinkOrchestrator(
        dbA,
        storage,
        username: 'alice',
        linkId: 'link-alice',
        personalKey: syncTestPersonalKeyA,
      );
      final bob = await makeLinkOrchestrator(
        dbB,
        storage,
        username: 'bob',
        linkId: 'link-bob',
        personalKey: syncTestPersonalKeyB,
      );

      await _insertDirtySharedNote(dbA, id: 'note-1', title: 'Family dinner');
      await alice.orchestrator.syncWithService(alice.service);
      await bob.orchestrator.syncWithService(bob.service);

      final bobNote = await (dbB.select(dbB.personalNotes)
            ..where((t) => t.id.equals('note-1')))
          .getSingleOrNull();
      expect(bobNote, isNotNull);
      expect(bobNote!.title, 'Family dinner');
      expect(bobNote.isShared, isTrue);
    });

    test('sharedMemberIds audience excludes Bob', () async {
      final dbA = createTestDatabase();
      final dbB = createTestDatabase();
      final alice = await makeLinkOrchestrator(
        dbA,
        storage,
        username: 'alice',
        linkId: 'link-alice',
        personalKey: syncTestPersonalKeyA,
      );
      final bob = await makeLinkOrchestrator(
        dbB,
        storage,
        username: 'bob',
        linkId: 'link-bob',
        personalKey: syncTestPersonalKeyB,
      );

      await _insertDirtySharedNote(
        dbA,
        id: 'note-private-share',
        title: 'Only for Sam',
        sharedMemberIds: const ['link-sam'],
      );
      await alice.orchestrator.syncWithService(alice.service);
      await bob.orchestrator.syncWithService(bob.service);

      final bobNote = await (dbB.select(dbB.personalNotes)
            ..where((t) => t.id.equals('note-private-share')))
          .getSingleOrNull();
      expect(bobNote, isNull);
    });

    test('remote delete of clean shared note hard-deletes locally', () async {
      final dbA = createTestDatabase();
      final dbB = createTestDatabase();
      final alice = await makeLinkOrchestrator(
        dbA,
        storage,
        username: 'alice',
        linkId: 'link-alice',
        personalKey: syncTestPersonalKeyA,
      );
      final bob = await makeLinkOrchestrator(
        dbB,
        storage,
        username: 'bob',
        linkId: 'link-bob',
        personalKey: syncTestPersonalKeyB,
      );

      await _insertDirtySharedNote(dbA, id: 'note-del', title: 'Gone soon');
      await alice.orchestrator.syncWithService(alice.service);
      await bob.orchestrator.syncWithService(bob.service);
      expect(
        await (dbB.select(dbB.personalNotes)
              ..where((t) => t.id.equals('note-del')))
            .getSingleOrNull(),
        isNotNull,
      );

      // Alice soft-deletes and syncs → shared file removed.
      await (dbA.update(dbA.personalNotes)
            ..where((t) => t.id.equals('note-del')))
          .write(const PersonalNotesCompanion(syncState: Value('deleted')));
      await alice.orchestrator.syncWithService(alice.service);
      await bob.orchestrator.syncWithService(bob.service);

      expect(
        await (dbB.select(dbB.personalNotes)
              ..where((t) => t.id.equals('note-del')))
            .getSingleOrNull(),
        isNull,
      );
    });
  });
}
