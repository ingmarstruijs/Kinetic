import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:flutter_test/flutter_test.dart';
import 'package:link/db/app_database.dart';

import '../helpers/fake_http_client.dart';
import '../helpers/sync_test_harness.dart';
import '../helpers/test_database.dart';

Future<void> _insertDirtyLocalOnlyNote(AppDatabase db, {required String id}) async {
  final now = DateTime.now().toUtc();
  await db.into(db.personalNotes).insert(
        PersonalNotesCompanion.insert(
          id: id,
          title: 'Secret',
          body: const Value('never leaves'),
          isLocalOnly: const Value(true),
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

  test('local-only dirty note is marked clean without WebDAV push', () async {
    final storage = SharedStorage();
    final db = createTestDatabase();
    final link = await makeLinkOrchestrator(
      db,
      storage,
      username: 'alice',
      linkId: 'link-alice',
      personalKey: syncTestPersonalKeyA,
    );

    await _insertDirtyLocalOnlyNote(db, id: 'local-note-1');
    await link.orchestrator.syncWithService(link.service);

    final row = await (db.select(db.personalNotes)
          ..where((t) => t.id.equals('local-note-1')))
        .getSingle();
    expect(row.syncState, 'clean');
    expect(row.body, 'never leaves');

    expect(storage.contains('/kinetic/alice/notes/local-note-1.ics'), isFalse);
  });
}
