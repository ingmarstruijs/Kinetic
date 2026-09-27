import 'dart:io';

import 'package:drift/drift.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import '../../db/app_database.dart';

/// Local note image assets referenced as `kinetic-asset://{id}` in markdown.
class NoteAssetStore {
  NoteAssetStore(this._db);

  final AppDatabase _db;
  static const scheme = 'kinetic-asset';

  static String uriFor(String assetId) => '$scheme://$assetId';

  static String? parseId(String source) {
    final uri = Uri.tryParse(source);
    if (uri == null) return null;
    if (uri.scheme != scheme) return null;
    final id = uri.host.isNotEmpty ? uri.host : uri.path.replaceFirst('/', '');
    return id.isEmpty ? null : id;
  }

  Future<Directory> _dir() async {
    final root = await getApplicationDocumentsDirectory();
    final dir = Directory(p.join(root.path, 'note_assets'));
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir;
  }

  Future<File> fileFor(String assetId, {String? fileName}) async {
    final dir = await _dir();
    final name = fileName ?? '$assetId.bin';
    return File(p.join(dir.path, name));
  }

  Future<NoteAssetRow> saveBytes({
    required String noteId,
    required Uint8List bytes,
    String mimeType = 'image/jpeg',
  }) async {
    final id = const Uuid().v4();
    final ext = mimeType.contains('png')
        ? 'png'
        : mimeType.contains('webp')
            ? 'webp'
            : 'jpg';
    final fileName = '$id.$ext';
    final file = await fileFor(id, fileName: fileName);
    await file.writeAsBytes(bytes, flush: true);
    final now = DateTime.now().toUtc();
    final row = NoteAssetsCompanion.insert(
      id: id,
      noteId: noteId,
      mimeType: Value(mimeType),
      fileName: fileName,
      syncState: const Value('dirty'),
      createdAt: now,
      updatedAt: now,
    );
    await _db.into(_db.noteAssets).insert(row);
    return (await (_db.select(_db.noteAssets)..where((t) => t.id.equals(id)))
            .getSingle());
  }

  Future<Uint8List?> readBytes(String assetId) async {
    final row = await (_db.select(_db.noteAssets)
          ..where((t) => t.id.equals(assetId)))
        .getSingleOrNull();
    if (row == null) return null;
    final file = await fileFor(assetId, fileName: row.fileName);
    if (!await file.exists()) return null;
    return file.readAsBytes();
  }

  Future<List<NoteAssetRow>> forNote(String noteId) {
    return (_db.select(_db.noteAssets)..where((t) => t.noteId.equals(noteId)))
        .get();
  }

  Future<List<NoteAssetRow>> dirtyAssets() {
    return (_db.select(_db.noteAssets)
          ..where((t) => t.syncState.equals('dirty')))
        .get();
  }

  Future<void> markClean(String assetId) async {
    await (_db.update(_db.noteAssets)..where((t) => t.id.equals(assetId)))
        .write(
      NoteAssetsCompanion(
        syncState: const Value('clean'),
        updatedAt: Value(DateTime.now().toUtc()),
      ),
    );
  }

  Future<void> upsertFromRemote({
    required String id,
    required String noteId,
    required Uint8List bytes,
    String mimeType = 'image/jpeg',
  }) async {
    final ext = mimeType.contains('png')
        ? 'png'
        : mimeType.contains('webp')
            ? 'webp'
            : 'jpg';
    final fileName = '$id.$ext';
    final file = await fileFor(id, fileName: fileName);
    await file.writeAsBytes(bytes, flush: true);
    final now = DateTime.now().toUtc();
    await _db.into(_db.noteAssets).insertOnConflictUpdate(
          NoteAssetsCompanion(
            id: Value(id),
            noteId: Value(noteId),
            mimeType: Value(mimeType),
            fileName: Value(fileName),
            syncState: const Value('clean'),
            createdAt: Value(now),
            updatedAt: Value(now),
          ),
        );
  }

  Future<void> deleteForNote(String noteId) async {
    final rows = await forNote(noteId);
    for (final row in rows) {
      final file = await fileFor(row.id, fileName: row.fileName);
      if (await file.exists()) await file.delete();
    }
    await (_db.delete(_db.noteAssets)..where((t) => t.noteId.equals(noteId)))
        .go();
  }

  Future<void> deleteAsset(String assetId) async {
    final row = await (_db.select(_db.noteAssets)
          ..where((t) => t.id.equals(assetId)))
        .getSingleOrNull();
    if (row != null) {
      final file = await fileFor(row.id, fileName: row.fileName);
      if (await file.exists()) await file.delete();
    }
    await (_db.delete(_db.noteAssets)..where((t) => t.id.equals(assetId))).go();
  }

  /// Removes local assets for [noteId] that are no longer referenced in [markdown].
  Future<void> pruneUnreferenced(String noteId, String markdown) async {
    final keep = <String>{};
    final re = RegExp(r'kinetic-asset://([a-zA-Z0-9\-]+)');
    for (final match in re.allMatches(markdown)) {
      keep.add(match.group(1)!);
    }
    final rows = await forNote(noteId);
    for (final row in rows) {
      if (!keep.contains(row.id)) await deleteAsset(row.id);
    }
  }
}
