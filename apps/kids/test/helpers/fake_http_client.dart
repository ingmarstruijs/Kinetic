import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

/// In-memory file store shared between FakeHttpClients (same WebDAV server).
class SharedStorage {
  final _files = <String, Uint8List>{};

  void put(String path, Uint8List bytes) => _files[_normalize(path)] = bytes;

  Uint8List? get(String path) => _files[_normalize(path)];

  bool remove(String path) => _files.remove(_normalize(path)) != null;

  bool contains(String path) => _files.containsKey(_normalize(path));

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

  http.StreamedResponse _rawResponse(
    int status,
    Uint8List body, {
    Map<String, String>? headers,
  }) {
    return http.StreamedResponse(
      Stream.value(body),
      status,
      headers: headers ?? {'content-type': 'application/octet-stream'},
      contentLength: body.length,
    );
  }

  String _buildPropfindXml(String parentPath, List<String> children) {
    final buf = StringBuffer()
      ..writeln('<?xml version="1.0" encoding="utf-8"?>')
      ..writeln('<d:multistatus xmlns:d="DAV:">')
      ..writeln('  <d:response>')
      ..writeln('    <d:href>$parentPath</d:href>')
      ..writeln('    <d:propstat><d:status>HTTP/1.1 200 OK</d:status></d:propstat>')
      ..writeln('  </d:response>');
    for (final child in children) {
      buf
        ..writeln('  <d:response>')
        ..writeln('    <d:href>$child</d:href>')
        ..writeln(
          '    <d:propstat><d:status>HTTP/1.1 200 OK</d:status></d:propstat>',
        )
        ..writeln('  </d:response>');
    }
    buf.writeln('</d:multistatus>');
    return buf.toString();
  }
}
