import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

// ---------------------------------------------------------------------------
// SharedStorage — in-memory file store shared between multiple FakeHttpClients.
//
// Keys are normalised URL paths, e.g. '/kinetic/shared/proposals/abc.json'.
// Two [FakeHttpClient] instances sharing one [SharedStorage] behave as if
// they talk to the same WebDAV server.
// ---------------------------------------------------------------------------

/// In-memory WebDAV blob store for multi-device sync tests.
class SharedStorage {
  final _files = <String, Uint8List>{};

  void put(String path, Uint8List bytes) => _files[_normalize(path)] = bytes;

  Uint8List? get(String path) => _files[_normalize(path)];

  bool contains(String path) => _files.containsKey(_normalize(path));

  bool remove(String path) => _files.remove(_normalize(path)) != null;

  /// Returns paths of all direct children of [parentPath].
  Iterable<String> listChildren(String parentPath) {
    final prefix = '${_normalize(parentPath)}/';
    return _files.keys.where((k) {
      if (!k.startsWith(prefix)) return false;
      final rest = k.substring(prefix.length);
      return rest.isNotEmpty && !rest.contains('/');
    });
  }

  static String _normalize(String path) {
    var p = path.startsWith('/') ? path : '/$path';
    while (p.endsWith('/')) {
      p = p.substring(0, p.length - 1);
    }
    return p;
  }
}

/// Minimal WebDAV HTTP fake: GET, PUT, DELETE, PROPFIND, MKCOL, OPTIONS.
///
/// Multiple clients on one [SharedStorage] model one family WebDAV root.
class FakeHttpClient extends http.BaseClient {
  final SharedStorage storage;

  FakeHttpClient(this.storage);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final path = request.url.path;
    final method = request.method.toUpperCase();

    Uint8List bodyBytes;
    if (request is http.Request) {
      bodyBytes = request.bodyBytes;
    } else {
      bodyBytes = await request.finalize().toBytes();
    }

    switch (method) {
      case 'GET':
        final bytes = storage.get(path);
        if (bytes == null) return _rawResponse(404, Uint8List(0));
        return _rawResponse(200, bytes);

      case 'PUT':
        storage.put(path, bodyBytes);
        return _rawResponse(201, Uint8List(0));

      case 'DELETE':
        storage.remove(path);
        return _rawResponse(204, Uint8List(0));

      case 'MKCOL':
        return _rawResponse(201, Uint8List(0));

      case 'PROPFIND':
        final children = storage.listChildren(path).toList();
        final xmlBytes = Uint8List.fromList(
          utf8.encode(_buildPropfindXml(path, children)),
        );
        return _rawResponse(207, xmlBytes);

      case 'OPTIONS':
        return _rawResponse(
          200,
          Uint8List(0),
          headers: {
            'dav': '1, 2',
            'allow': 'OPTIONS, GET, PUT, DELETE, PROPFIND, MKCOL',
          },
        );

      default:
        return _rawResponse(405, Uint8List(0));
    }
  }

  static http.StreamedResponse _rawResponse(
    int statusCode,
    Uint8List bytes, {
    Map<String, String>? headers,
  }) {
    return http.StreamedResponse(
      http.ByteStream.fromBytes(bytes),
      statusCode,
      contentLength: bytes.length,
      headers: headers ?? const {},
    );
  }

  static String _buildPropfindXml(
    String collectionPath,
    List<String> childPaths,
  ) {
    final collHref = collectionPath.endsWith('/')
        ? collectionPath
        : '$collectionPath/';

    final sb = StringBuffer()
      ..writeln('<?xml version="1.0" encoding="utf-8"?>')
      ..writeln('<d:multistatus xmlns:d="DAV:">');

    sb
      ..writeln('  <d:response>')
      ..writeln('    <d:href>$collHref</d:href>')
      ..writeln('    <d:propstat><d:prop>')
      ..writeln('      <d:resourcetype><d:collection/></d:resourcetype>')
      ..writeln('    </d:prop></d:propstat>')
      ..writeln('  </d:response>');

    for (final child in childPaths) {
      sb
        ..writeln('  <d:response>')
        ..writeln('    <d:href>$child</d:href>')
        ..writeln('    <d:propstat><d:prop>')
        ..writeln('      <d:getetag>"etag-${child.hashCode}"</d:getetag>')
        ..writeln('    </d:prop></d:propstat>')
        ..writeln('  </d:response>');
    }

    sb.writeln('</d:multistatus>');
    return sb.toString();
  }
}
