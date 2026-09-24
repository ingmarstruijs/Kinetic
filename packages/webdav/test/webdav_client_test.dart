import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:kinetic_webdav/kinetic_webdav.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'webdav_client_test.mocks.dart';

@GenerateMocks([http.Client])
void main() {
  late MockClient mockHttp;
  late WebDavClient client;

  setUp(() {
    mockHttp = MockClient();
    client = WebDavClient(
      baseUrl: 'https://dav.example.com',
      username: 'alice',
      // ggignore: mocked HTTP, not a real login
      password: 'test-password',
      httpClient: mockHttp,
    );
  });

  // ---------------------------------------------------------------------------
  // Auth header
  // ---------------------------------------------------------------------------

  test('GET sends correct Basic auth header', () async {
    when(mockHttp.get(any, headers: anyNamed('headers')))
        .thenAnswer((_) async => http.Response('hello', 200));

    await client.get('/kinetic/alice/tasks/task-1.ics');

    final captured = verify(
      mockHttp.get(any, headers: captureAnyNamed('headers')),
    ).captured.single as Map<String, String>;

    final expected = base64Encode(utf8.encode('alice:test-password'));
    expect(captured['Authorization'], equals('Basic $expected'));
  });

  // ---------------------------------------------------------------------------
  // GET
  // ---------------------------------------------------------------------------

  test('GET returns body bytes on 200', () async {
    final bytes = Uint8List.fromList([1, 2, 3, 4]);
    when(mockHttp.get(any, headers: anyNamed('headers')))
        .thenAnswer((_) async => http.Response.bytes(bytes, 200));

    final result = await client.get('/some/path');
    expect(result, equals(bytes));
  });

  test('GET throws WebDavException with statusCode 404', () async {
    when(mockHttp.get(any, headers: anyNamed('headers')))
        .thenAnswer((_) async => http.Response('Not Found', 404));

    try {
      await client.get('/missing');
      fail('expected WebDavException');
    } on WebDavException catch (e) {
      expect(e.statusCode, 404);
      expect(e.isNotFound, isTrue);
    }
  });

  // ---------------------------------------------------------------------------
  // Connection probe
  // ---------------------------------------------------------------------------

  test('probeConnection returns authFailed on 401', () async {
    when(mockHttp.send(any)).thenAnswer((invocation) async {
      final request = invocation.positionalArguments[0] as http.BaseRequest;
      expect(request.method, 'PROPFIND');
      return http.StreamedResponse(Stream.value([]), 401);
    });

    expect(
      await client.probeConnection(),
      WebDavConnectionStatus.authFailed,
    );
  });

  test('probeConnection returns ok on 207', () async {
    when(mockHttp.send(any)).thenAnswer((invocation) async {
      final request = invocation.positionalArguments[0] as http.BaseRequest;
      expect(request.method, 'PROPFIND');
      return http.StreamedResponse(Stream.value([]), 207);
    });

    expect(await client.probeConnection(), WebDavConnectionStatus.ok);
  });

  // ---------------------------------------------------------------------------
  // PUT
  // ---------------------------------------------------------------------------

  test('PUT sends bytes and succeeds on 201', () async {
    when(mockHttp.put(any,
            headers: anyNamed('headers'), body: anyNamed('body')))
        .thenAnswer((_) async => http.Response('', 201));

    final data = Uint8List.fromList([9, 8, 7]);
    await expectLater(client.put('/file.ics', data), completes);
  });

  test('PUT throws WebDavException on 412 Precondition Failed', () async {
    when(mockHttp.put(any,
            headers: anyNamed('headers'), body: anyNamed('body')))
        .thenAnswer((_) async => http.Response('', 412));

    expect(
      () => client.put('/file.ics', Uint8List(0)),
      throwsA(isA<WebDavException>()),
    );
  });

  // ---------------------------------------------------------------------------
  // DELETE
  // ---------------------------------------------------------------------------

  test('DELETE succeeds on 204', () async {
    when(mockHttp.delete(any, headers: anyNamed('headers')))
        .thenAnswer((_) async => http.Response('', 204));

    await expectLater(client.delete('/file.ics'), completes);
  });

  test('DELETE treats 404 as success', () async {
    when(mockHttp.delete(any, headers: anyNamed('headers')))
        .thenAnswer((_) async => http.Response('', 404));

    await expectLater(client.delete('/nonexistent.ics'), completes);
  });

  test('DELETE throws on 500', () async {
    when(mockHttp.delete(any, headers: anyNamed('headers')))
        .thenAnswer((_) async => http.Response('Server Error', 500));

    expect(() => client.delete('/file.ics'), throwsA(isA<WebDavException>()));
  });

  // ---------------------------------------------------------------------------
  // MKCOL
  // ---------------------------------------------------------------------------

  test('MKCOL treats 409 as success when collection already exists', () async {
    when(mockHttp.send(any)).thenAnswer((invocation) async {
      final request = invocation.positionalArguments[0] as http.BaseRequest;
      expect(request.method, 'MKCOL');
      return http.StreamedResponse(Stream.value([]), 409);
    });

    await expectLater(client.mkcol('/kinetic/shared/xp-reset'), completes);
  });

  // ---------------------------------------------------------------------------
  // PROPFIND parsing
  // ---------------------------------------------------------------------------

  group('parsePropfind', () {
    test('marks empty collection self-entry as collection', () {
      // Minimal Nextcloud-style Depth:1 response for an empty folder.
      const xml = '''
<?xml version="1.0"?>
<d:multistatus xmlns:d="DAV:">
  <d:response>
    <d:href>/remote.php/dav/files/sandy/kinetic/sandy/tasks/</d:href>
    <d:propstat>
      <d:prop>
        <d:resourcetype><d:collection/></d:resourcetype>
        <d:getetag>&quot;abc&quot;</d:getetag>
      </d:prop>
      <d:status>HTTP/1.1 200 OK</d:status>
    </d:propstat>
  </d:response>
</d:multistatus>
''';
      final entries = WebDavClient.parsePropfind(xml);
      expect(entries, hasLength(1));
      expect(entries.single.isCollection, isTrue);
      expect(entries.single.href, contains('/tasks/'));
    });

    test('distinguishes collection from .ics child', () {
      const xml = '''
<?xml version="1.0"?>
<d:multistatus xmlns:d="DAV:">
  <d:response>
    <d:href>/kinetic/sandy/tasks/</d:href>
    <d:propstat>
      <d:prop>
        <d:resourcetype><d:collection/></d:resourcetype>
      </d:prop>
      <d:status>HTTP/1.1 200 OK</d:status>
    </d:propstat>
  </d:response>
  <d:response>
    <d:href>/kinetic/sandy/tasks/uid-1.ics</d:href>
    <d:propstat>
      <d:prop>
        <d:resourcetype/>
        <d:getetag>&quot;etag1&quot;</d:getetag>
      </d:prop>
      <d:status>HTTP/1.1 200 OK</d:status>
    </d:propstat>
  </d:response>
</d:multistatus>
''';
      final entries = WebDavClient.parsePropfind(xml);
      expect(entries, hasLength(2));
      expect(entries[0].isCollection, isTrue);
      expect(entries[1].isCollection, isFalse);
      expect(entries[1].href, endsWith('uid-1.ics'));
      expect(entries[1].etag, 'etag1');
    });

    test('trailing slash implies collection when resourcetype omitted', () {
      // Some minimal WebDAV servers omit <d:collection/> — trailing slash still
      // marks the self-entry as a collection.
      const xml = '''
<?xml version="1.0"?>
<d:multistatus xmlns:d="DAV:">
  <d:response>
    <d:href>/kinetic/sandy/notes/</d:href>
    <d:propstat>
      <d:prop>
        <d:getetag>&quot;x&quot;</d:getetag>
      </d:prop>
      <d:status>HTTP/1.1 200 OK</d:status>
    </d:propstat>
  </d:response>
</d:multistatus>
''';
      final entries = WebDavClient.parsePropfind(xml);
      expect(entries, hasLength(1));
      expect(entries.single.isCollection, isTrue);
      expect(entries.single.href.endsWith('.ics'), isFalse);
    });

    test('unprefixed DAV elements still parse', () {
      const xml = '''
<?xml version="1.0"?>
<multistatus xmlns="DAV:">
  <response>
    <href>/kinetic/alex/</href>
    <propstat>
      <prop><resourcetype><collection/></resourcetype></prop>
      <status>HTTP/1.1 200 OK</status>
    </propstat>
  </response>
</multistatus>
''';
      final entries = WebDavClient.parsePropfind(xml);
      expect(entries, hasLength(1));
      expect(entries.single.isCollection, isTrue);
      expect(entries.single.href, endsWith('/alex/'));
    });
  });

  // ---------------------------------------------------------------------------
  // WebDavSyncService.mergeTasks
  // ---------------------------------------------------------------------------

  group('WebDavSyncService.mergeTasks', () {
    ICalTask _task(String uid, DateTime updated,
            [ICalTaskStatus status = ICalTaskStatus.needsAction]) =>
        ICalTask(
          uid: uid,
          summary: 'Task $uid',
          createdAt: updated,
          updatedAt: updated,
          status: status,
        );

    test('remote-only task is adopted', () {
      final remote = _task('r1', DateTime.utc(2026, 1, 1));
      final result = WebDavSyncService.mergeTasks([], [remote]);
      expect(result.merged.length, equals(1));
      expect(result.toPush, isEmpty);
    });

    test('local-only task is kept and queued for push', () {
      final local = _task('l1', DateTime.utc(2026, 1, 1));
      final result = WebDavSyncService.mergeTasks([local], []);
      expect(result.merged.length, equals(1));
      expect(result.toPush, contains(local));
    });

    test('newer remote wins, local not pushed', () {
      final old = _task('t1', DateTime.utc(2026, 1, 1));
      final newer = _task('t1', DateTime.utc(2026, 1, 2));
      final result = WebDavSyncService.mergeTasks([old], [newer]);
      expect(result.merged.single.updatedAt, equals(newer.updatedAt));
      expect(result.toPush, isEmpty);
    });

    test('newer local wins and is queued for push', () {
      final old = _task('t1', DateTime.utc(2026, 1, 1));
      final newer = _task('t1', DateTime.utc(2026, 1, 2));
      final result = WebDavSyncService.mergeTasks([newer], [old]);
      expect(result.merged.single.updatedAt, equals(newer.updatedAt));
      expect(result.toPush, isNotEmpty);
    });

    test('same updatedAt → remote wins, local not pushed', () {
      final t = DateTime.utc(2026, 1, 1);
      final local = _task('t1', t);
      final remote = _task('t1', t, ICalTaskStatus.completed);
      final result = WebDavSyncService.mergeTasks([local], [remote]);
      expect(result.merged.single.status, equals(ICalTaskStatus.completed));
      expect(result.toPush, isEmpty);
    });
  });
}
