import 'dart:convert';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:kinetic_webdav/kinetic_webdav.dart';

import 'fake_http_client.dart';

/// Minimal HTTP client that returns a fixed sequence of status codes.
class _SequenceHttpClient extends http.BaseClient {
  _SequenceHttpClient(this._statusCodes);

  final List<int> _statusCodes;
  int _call = 0;
  final methods = <String>[];
  final paths = <String>[];

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    methods.add(request.method);
    paths.add(request.url.path);
    final status = _statusCodes[_call++];
    return http.StreamedResponse(
      Stream.value(Uint8List(0)),
      status,
    );
  }
}

void main() {
  group('WebDavSyncService.pushXpReset', () {
    late WebDavSyncService service;
    late _SequenceHttpClient httpClient;

    setUp(() {
      httpClient = _SequenceHttpClient([409, 201, 201]);
      final davClient = WebDavClient(
        baseUrl: 'https://dav.example.com',
        username: 'alice',
        password: 'secret',
        httpClient: httpClient,
      );
      service = WebDavSyncService(
        client: davClient,
        config: SyncConfig(
          serverUrl: 'https://dav.example.com',
          username: 'alice',
          password: 'secret',
          linkId: 'link-1',
          personalKeyBytes: KineticEncryption.generatePersonalKey(),
          familyKeyBytes: KineticEncryption.generateFamilyKey(),
        ),
      );
    });

    test('creates collection and retries when first PUT returns 409', () async {
      await service.pushXpReset('kid-123', DateTime.utc(2026, 6, 11, 12));

      expect(httpClient.methods, ['PUT', 'MKCOL', 'PUT']);
      expect(httpClient.paths.first, '/kinetic/shared/xp-reset/kid-123.json');
      expect(httpClient.paths.last, '/kinetic/shared/xp-reset/kid-123.json');
      expect(
        httpClient.paths[1],
        '/kinetic/shared/xp-reset/',
      );
    });

    test('throws when family key is missing', () async {
      final davClient = WebDavClient(
        baseUrl: 'https://dav.example.com',
        username: 'alice',
        password: 'secret',
        httpClient: _SequenceHttpClient([201]),
      );
      final noKeyService = WebDavSyncService(
        client: davClient,
        config: SyncConfig(
          serverUrl: 'https://dav.example.com',
          username: 'alice',
          password: 'secret',
          linkId: 'link-1',
          personalKeyBytes: KineticEncryption.generatePersonalKey(),
        ),
      );

      expect(
        () => noKeyService.pushXpReset('kid-123', DateTime.utc(2026, 6, 11)),
        throwsA(isA<StateError>()),
      );
    });

    test('pushGoal creates collection on 409', () async {
      httpClient = _SequenceHttpClient([409, 201, 201]);
      final davClient = WebDavClient(
        baseUrl: 'https://dav.example.com',
        username: 'alice',
        password: 'secret',
        httpClient: httpClient,
      );
      service = WebDavSyncService(
        client: davClient,
        config: SyncConfig(
          serverUrl: 'https://dav.example.com',
          username: 'alice',
          password: 'secret',
          linkId: 'link-1',
          personalKeyBytes: KineticEncryption.generatePersonalKey(),
          familyKeyBytes: KineticEncryption.generateFamilyKey(),
        ),
      );

      await service.pushGoal(
        KidGoal(
          kidId: 'kid-1',
          title: 'Bike',
          targetXp: 100,
          updatedAt: DateTime.utc(2026, 6, 11),
        ),
      );

      expect(httpClient.methods, ['PUT', 'MKCOL', 'PUT']);
      expect(httpClient.paths.first, '/kinetic/shared/goals/kid-1.json');
    });
  });

  group('WebDavSyncService goals round-trip', () {
    late SharedStorage storage;
    late Uint8List familyKey;
    late WebDavSyncService service;

    setUp(() {
      storage = SharedStorage();
      familyKey = KineticEncryption.generateFamilyKey();
      service = WebDavSyncService(
        client: WebDavClient(
          baseUrl: 'https://dav.example.com',
          username: 'alice',
          password: 'secret',
          httpClient: FakeHttpClient(storage),
        ),
        config: SyncConfig(
          serverUrl: 'https://dav.example.com',
          username: 'alice',
          password: 'secret',
          linkId: 'link-1',
          personalKeyBytes: KineticEncryption.generatePersonalKey(),
          familyKeyBytes: familyKey,
        ),
      );
    });

    test('pushGoal / pullGoal / deleteGoal', () async {
      final goal = KidGoal(
        kidId: 'kid-1',
        title: 'Bike',
        targetXp: 100,
        updatedAt: DateTime.utc(2026, 6, 11),
      );

      await service.pushGoal(goal);
      final pulled = await service.pullGoal('kid-1');
      expect(pulled, isNotNull);
      expect(pulled!.title, 'Bike');
      expect(pulled.targetXp, 100);
      expect(pulled.kidId, 'kid-1');

      await service.deleteGoal('kid-1');
      expect(await service.pullGoal('kid-1'), isNull);
    });
  });

  group('WebDavSyncService.pullNotes stale shared blobs', () {
    late SharedStorage storage;
    late Uint8List familyKey;
    late Uint8List otherFamilyKey;
    late WebDavSyncService service;

    ICalNote sharedNote(String uid) => ICalNote(
          uid: uid,
          summary: 'Note $uid',
          isShared: true,
          createdAt: DateTime.utc(2026, 1, 1),
          updatedAt: DateTime.utc(2026, 1, 1),
        );

    Future<void> putShared(String uid, Uint8List key) async {
      final ical = ICalSerializer.noteToVjournal(sharedNote(uid));
      final blob = await KineticEncryption.encrypt(
        Uint8List.fromList(utf8.encode(ical)),
        key,
      );
      storage.put('/kinetic/shared/notes/$uid.ics', blob);
    }

    setUp(() {
      storage = SharedStorage();
      familyKey = KineticEncryption.generateFamilyKey();
      otherFamilyKey = KineticEncryption.generateFamilyKey();
      service = WebDavSyncService(
        client: WebDavClient(
          baseUrl: 'https://dav.example.com',
          username: 'alice',
          password: 'secret',
          httpClient: FakeHttpClient(storage),
        ),
        config: SyncConfig(
          serverUrl: 'https://dav.example.com',
          username: 'alice',
          password: 'secret',
          linkId: 'link-1',
          personalKeyBytes: KineticEncryption.generatePersonalKey(),
          familyKeyBytes: familyKey,
        ),
      );
    });

    test('deletes leftover shared notes when current family key opens others',
        () async {
      await putShared('38ac6f82-d227-490f-af6b-b041951597d4', familyKey);
      await putShared('07674cb3-8910-415e-bad4-6babaae126f0', otherFamilyKey);
      await putShared('c6f8dd97-a47c-4bb1-88db-dcedab5f1e3e', otherFamilyKey);

      final notes = await service.pullNotes();

      expect(notes.map((n) => n.uid), ['38ac6f82-d227-490f-af6b-b041951597d4']);
      expect(
        storage.contains(
          '/kinetic/shared/notes/38ac6f82-d227-490f-af6b-b041951597d4.ics',
        ),
        isTrue,
      );
      expect(
        storage.contains(
          '/kinetic/shared/notes/07674cb3-8910-415e-bad4-6babaae126f0.ics',
        ),
        isFalse,
      );
      expect(
        storage.contains(
          '/kinetic/shared/notes/c6f8dd97-a47c-4bb1-88db-dcedab5f1e3e.ics',
        ),
        isFalse,
      );
    });

    test('does not delete shared notes when nothing decrypts', () async {
      await putShared('07674cb3-8910-415e-bad4-6babaae126f0', otherFamilyKey);
      await putShared('c6f8dd97-a47c-4bb1-88db-dcedab5f1e3e', otherFamilyKey);

      final notes = await service.pullNotes();

      expect(notes, isEmpty);
      expect(
        storage.contains(
          '/kinetic/shared/notes/07674cb3-8910-415e-bad4-6babaae126f0.ics',
        ),
        isTrue,
      );
      expect(
        storage.contains(
          '/kinetic/shared/notes/c6f8dd97-a47c-4bb1-88db-dcedab5f1e3e.ics',
        ),
        isTrue,
      );
    });
  });

  group('WebDavSyncService.reencryptSharedTree', () {
    late SharedStorage storage;
    late Uint8List oldKey;
    late Uint8List newKey;
    late WebDavSyncService service;

    setUp(() {
      storage = SharedStorage();
      oldKey = KineticEncryption.generateFamilyKey();
      newKey = KineticEncryption.generateFamilyKey();
      service = WebDavSyncService(
        client: WebDavClient(
          baseUrl: 'https://dav.example.com',
          username: 'alice',
          password: 'secret',
          httpClient: FakeHttpClient(storage),
        ),
        config: SyncConfig(
          serverUrl: 'https://dav.example.com',
          username: 'alice',
          password: 'secret',
          linkId: 'link-1',
          personalKeyBytes: KineticEncryption.generatePersonalKey(),
          familyKeyBytes: oldKey,
        ),
      );
    });

    test('re-wraps decryptable shared notes with new family key', () async {
      const uid = 'note-rotate-1';
      final ical = ICalSerializer.noteToVjournal(
        ICalNote(
          uid: uid,
          summary: 'Shared',
          isShared: true,
          createdAt: DateTime.utc(2026, 1, 1),
          updatedAt: DateTime.utc(2026, 1, 1),
        ),
      );
      final blob = await KineticEncryption.encrypt(
        Uint8List.fromList(utf8.encode(ical)),
        oldKey,
      );
      storage.put('/kinetic/shared/notes/$uid.ics', blob);

      final report = await service.reencryptSharedTree(
        oldFamilyKey: oldKey,
        newFamilyKey: newKey,
      );

      expect(report.reencrypted, greaterThan(0));
      expect(report.failed, 0);

      final stored = storage.get('/kinetic/shared/notes/$uid.ics')!;
      final plain = await KineticEncryption.decrypt(stored, newKey);
      final note = ICalSerializer.vjournalToNote(utf8.decode(plain));
      expect(note.uid, uid);

      expect(
        () => KineticEncryption.decrypt(stored, oldKey),
        throwsA(isA<SecretBoxAuthenticationError>()),
      );
    });

    test('peer with old family key cannot pull re-encrypted shared tasks',
        () async {
      final now = DateTime.utc(2026, 3, 1);
      await service.pushSharedTask(
        ICalTask(
          uid: 'task-rotate-1',
          summary: 'Shared chore',
          status: ICalTaskStatus.needsAction,
          createdAt: now,
          updatedAt: now,
        ),
      );

      final report = await service.reencryptSharedTree(
        oldFamilyKey: oldKey,
        newFamilyKey: newKey,
      );
      expect(report.reencrypted, greaterThan(0));
      expect(report.failed, 0);

      final stalePeer = WebDavSyncService(
        client: WebDavClient(
          baseUrl: 'https://dav.example.com',
          username: 'bob',
          password: 'secret',
          httpClient: FakeHttpClient(storage),
        ),
        config: SyncConfig(
          serverUrl: 'https://dav.example.com',
          username: 'bob',
          password: 'secret',
          linkId: 'link-bob',
          personalKeyBytes: KineticEncryption.generatePersonalKey(),
          familyKeyBytes: oldKey,
        ),
      );
      expect(await stalePeer.pullSharedTasks(), isEmpty);

      final rotatedPeer = WebDavSyncService(
        client: WebDavClient(
          baseUrl: 'https://dav.example.com',
          username: 'bob',
          password: 'secret',
          httpClient: FakeHttpClient(storage),
        ),
        config: SyncConfig(
          serverUrl: 'https://dav.example.com',
          username: 'bob',
          password: 'secret',
          linkId: 'link-bob',
          personalKeyBytes: KineticEncryption.generatePersonalKey(),
          familyKeyBytes: newKey,
        ),
      );
      final tasks = await rotatedPeer.pullSharedTasks();
      expect(tasks.single.uid, 'task-rotate-1');
      expect(tasks.single.summary, 'Shared chore');
    });
  });
}
