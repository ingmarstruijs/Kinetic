import 'package:flutter_test/flutter_test.dart';
import 'package:link/todo/services/note_repository.dart';

import '../../helpers/test_database.dart';

void main() {
  test('delete moves a note to trash and restore brings it back', () async {
    final db = createTestDatabase();
    addTearDown(db.close);
    final repo = NoteRepository(db: db);

    final note = await repo.insert(title: 'Shopping', body: 'Milk');
    expect((await repo.watchAll().first).map((n) => n.id), [note.id]);
    expect(await repo.watchDeleted().first, isEmpty);

    await repo.delete(note.id);
    expect(await repo.watchAll().first, isEmpty);
    expect((await repo.watchDeleted().first).map((n) => n.id), [note.id]);

    await repo.restore(note.id);
    expect((await repo.watchAll().first).map((n) => n.id), [note.id]);
    expect(await repo.watchDeleted().first, isEmpty);
  });

  test('emptyTrash tombstones trashed notes', () async {
    final db = createTestDatabase();
    addTearDown(db.close);
    final repo = NoteRepository(db: db);

    final note = await repo.insert(title: 'Gone');
    await repo.delete(note.id);
    await repo.emptyTrash();

    expect(await repo.watchAll().first, isEmpty);
    expect(await repo.watchDeleted().first, isEmpty);
    final row = await (db.select(
      db.personalNotes,
    )..where((t) => t.id.equals(note.id))).getSingle();
    expect(row.syncState, 'deleted');
    expect(row.deletedAt, isNotNull);
  });

  test('insert and update persist isContentHidden', () async {
    final db = createTestDatabase();
    addTearDown(db.close);
    final repo = NoteRepository(db: db);

    final note = await repo.insert(
      title: 'Vault',
      body: 'secret',
      isContentHidden: true,
    );
    expect(note.isContentHidden, isTrue);
    expect((await repo.getNote(note.id))!.isContentHidden, isTrue);
    expect(note.bodyPreview, isEmpty);

    await repo.update(note.copyWith(isContentHidden: false));
    final open = await repo.getNote(note.id);
    expect(open!.isContentHidden, isFalse);
    expect(open.bodyPreview, 'secret');
  });
}
