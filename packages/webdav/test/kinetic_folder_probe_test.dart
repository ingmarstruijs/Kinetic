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
      username: 'test-user',
      // ggignore: mocked HTTP, not a real login
      password: 'test-password',
      httpClient: mockHttp,
    );
  });

  http.StreamedResponse _propfind(String body) {
    return http.StreamedResponse(
      Stream.value(Uint8List.fromList(body.codeUnits)),
      207,
    );
  }

  test('probe finds other users and shared roster', () async {
    when(mockHttp.send(any)).thenAnswer((invocation) async {
      final req = invocation.positionalArguments[0] as http.BaseRequest;
      final path = req.url.path;
      if (req.method == 'PROPFIND' && path.endsWith('/kinetic/')) {
        return _propfind('''
<?xml version="1.0"?>
<d:multistatus xmlns:d="DAV:">
  <d:response>
    <d:href>/kinetic/</d:href>
    <d:propstat><d:prop><d:resourcetype><d:collection/></d:resourcetype></d:prop>
    <d:status>HTTP/1.1 200 OK</d:status></d:propstat>
  </d:response>
  <d:response>
    <d:href>/kinetic/test-user/</d:href>
    <d:propstat><d:prop><d:resourcetype><d:collection/></d:resourcetype></d:prop>
    <d:status>HTTP/1.1 200 OK</d:status></d:propstat>
  </d:response>
  <d:response>
    <d:href>/kinetic/alex/</d:href>
    <d:propstat><d:prop><d:resourcetype><d:collection/></d:resourcetype></d:prop>
    <d:status>HTTP/1.1 200 OK</d:status></d:propstat>
  </d:response>
  <d:response>
    <d:href>/kinetic/shared/</d:href>
    <d:propstat><d:prop><d:resourcetype><d:collection/></d:resourcetype></d:prop>
    <d:status>HTTP/1.1 200 OK</d:status></d:propstat>
  </d:response>
</d:multistatus>
''');
      }
      if (req.method == 'PROPFIND' && path.contains('/presence')) {
        return _propfind('''
<?xml version="1.0"?>
<d:multistatus xmlns:d="DAV:">
  <d:response>
    <d:href>/kinetic/shared/presence/</d:href>
    <d:propstat><d:prop><d:resourcetype><d:collection/></d:resourcetype></d:prop>
    <d:status>HTTP/1.1 200 OK</d:status></d:propstat>
  </d:response>
</d:multistatus>
''');
      }
      if (req.method == 'PROPFIND' &&
          (path.contains('/tasks') ||
              path.contains('/notes') ||
              path.contains('/proposals'))) {
        return _propfind('''
<?xml version="1.0"?>
<d:multistatus xmlns:d="DAV:">
  <d:response>
    <d:href>$path</d:href>
    <d:propstat><d:prop><d:resourcetype><d:collection/></d:resourcetype></d:prop>
    <d:status>HTTP/1.1 200 OK</d:status></d:propstat>
  </d:response>
</d:multistatus>
''');
      }
      fail('unexpected ${req.method} $path');
    });

    when(mockHttp.get(any, headers: anyNamed('headers'))).thenAnswer((
      invocation,
    ) async {
      final uri = invocation.positionalArguments[0] as Uri;
      if (uri.path.endsWith('/roster.json')) {
        return http.Response.bytes(Uint8List.fromList([1, 2, 3]), 200);
      }
      return http.Response('missing', 404);
    });

    final result = await KineticFolderProbe.probe(
      client: client,
      username: 'test-user',
    );
    expect(result.otherUsernames, ['alex']);
    expect(result.hasSharedRoster, isTrue);
    expect(result.suggestsExistingFamily, isTrue);
  });

  test('empty kinetic folder does not suggest family', () async {
    when(mockHttp.send(any)).thenAnswer((invocation) async {
      final req = invocation.positionalArguments[0] as http.BaseRequest;
      if (req.method == 'PROPFIND') {
        final path = req.url.path;
        return _propfind('''
<?xml version="1.0"?>
<d:multistatus xmlns:d="DAV:">
  <d:response>
    <d:href>$path</d:href>
    <d:propstat><d:prop><d:resourcetype><d:collection/></d:resourcetype></d:prop>
    <d:status>HTTP/1.1 200 OK</d:status></d:propstat>
  </d:response>
  <d:response>
    <d:href>/kinetic/test-user/</d:href>
    <d:propstat><d:prop><d:resourcetype><d:collection/></d:resourcetype></d:prop>
    <d:status>HTTP/1.1 200 OK</d:status></d:propstat>
  </d:response>
  <d:response>
    <d:href>/kinetic/shared/</d:href>
    <d:propstat><d:prop><d:resourcetype><d:collection/></d:resourcetype></d:prop>
    <d:status>HTTP/1.1 200 OK</d:status></d:propstat>
  </d:response>
</d:multistatus>
''');
      }
      fail('unexpected');
    });
    when(mockHttp.get(any, headers: anyNamed('headers'))).thenAnswer(
      (_) async => http.Response('missing', 404),
    );

    final result = await KineticFolderProbe.probe(
      client: client,
      username: 'test-user',
    );
    expect(result.otherUsernames, isEmpty);
    expect(result.hasSharedRoster, isFalse);
    expect(result.hasSharedContent, isFalse);
    expect(result.suggestsExistingFamily, isFalse);
  });
}
