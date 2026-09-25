import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:kinetic_link_bridge/kinetic_link_bridge.dart';
import 'package:mime/mime.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_router/shelf_router.dart';
import 'package:shelf_web_socket/shelf_web_socket.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'todo_bridge_task_store.dart';
import '../todo/services/todo_repository.dart';

/// LAN HTTP + WebSocket bridge for Kinetic Link Web.
class LinkBridgeServer {
  LinkBridgeServer({required TodoRepository todoRepository})
      : _handler = BridgeRpcHandler(store: TodoBridgeTaskStore(todoRepository));

  final BridgeRpcHandler _handler;
  HttpServer? _server;
  LinkWebQrPayload? _qr;
  final _sockets = <WebSocketChannel>{};
  String? _lanHost;
  int? _port;

  BridgeRpcHandler get handler => _handler;
  LinkWebQrPayload? get qr => _qr;
  bool get isRunning => _server != null;
  String? get lanHost => _lanHost;
  int? get port => _port;
  String? get httpUrl => _qr?.httpUrl;

  /// Lists non-loopback IPv4 addresses for the QR host picker.
  static Future<List<String>> listLanIpv4() async {
    final result = <String>[];
    try {
      final interfaces = await NetworkInterface.list(
        type: InternetAddressType.IPv4,
        includeLinkLocal: false,
      );
      for (final ni in interfaces) {
        for (final addr in ni.addresses) {
          if (!addr.isLoopback) result.add(addr.address);
        }
      }
    } catch (e) {
      if (kDebugMode) debugPrint('listLanIpv4: $e');
    }
    return result;
  }

  Future<LinkWebQrPayload> start({
    String? preferredHost,
    int port = 8787,
    Duration sessionTtl = const Duration(hours: 8),
  }) async {
    await stop();
    final hosts = await listLanIpv4();
    _lanHost = preferredHost ??
        (hosts.isNotEmpty ? hosts.first : InternetAddress.loopbackIPv4.address);
    _port = port;

    final qr = LinkWebQrPayload.mint(
      lanHost: _lanHost!,
      port: port,
      ttl: sessionTtl,
    );
    _handler.armFromQr(qr);
    _qr = qr;

    final router = Router();
    router.get('/bridge', webSocketHandler(_onWebSocket));
    router.get('/health', (Request _) => Response.ok('ok'));
    router.get('/qr.json', (Request _) {
      final q = _qr;
      if (q == null) return Response.notFound('no session');
      return Response.ok(
        q.encode(),
        headers: {'content-type': 'application/json'},
      );
    });

    final cascade = Cascade()
        .add(router.call)
        .add(_staticAssetHandler)
        .handler;

    final pipeline = Pipeline()
        .addMiddleware(_cors())
        .addMiddleware(logRequests())
        .addHandler(cascade);

    _server = await shelf_io.serve(
      pipeline,
      InternetAddress.anyIPv4,
      port,
    );
    if (kDebugMode) {
      debugPrint('Link bridge listening on http://$_lanHost:$port/');
    }
    return qr;
  }

  /// Remint QR / session secret while keeping the same HTTP server.
  Future<LinkWebQrPayload> rotateSession({
    Duration sessionTtl = const Duration(hours: 8),
  }) async {
    if (_lanHost == null || _port == null) {
      throw StateError('Bridge not started');
    }
    for (final ws in List.of(_sockets)) {
      await ws.sink.close();
    }
    _sockets.clear();
    final qr = LinkWebQrPayload.mint(
      lanHost: _lanHost!,
      port: _port!,
      ttl: sessionTtl,
    );
    _handler.armFromQr(qr);
    _qr = qr;
    return qr;
  }

  Future<void> revokeAndStop() async {
    _handler.revoke();
    await stop();
  }

  Future<void> stop() async {
    for (final ws in List.of(_sockets)) {
      try {
        await ws.sink.close();
      } catch (_) {}
    }
    _sockets.clear();
    await _server?.close(force: true);
    _server = null;
    _qr = null;
  }

  void _onWebSocket(WebSocketChannel webSocket) {
    _sockets.add(webSocket);
    webSocket.stream.listen(
      (data) async {
        final raw = data is String ? data : null;
        if (raw == null) return;
        final msg = BridgeMessage.tryParse(raw);
        if (msg == null) {
          webSocket.sink.add(
            BridgeMessage(
              method: BridgeMethods.sessionError,
              error: {'code': 'bad_json', 'message': 'Invalid message'},
            ).encode(),
          );
          return;
        }
        final reply = await _handler.handle(msg);
        webSocket.sink.add(reply.encode());
        if (msg.method == BridgeMethods.sessionRevoke ||
            (_handler.session?.revoked ?? false)) {
          await webSocket.sink.close();
        }
      },
      onDone: () => _sockets.remove(webSocket),
      onError: (_) => _sockets.remove(webSocket),
      cancelOnError: true,
    );
  }

  FutureOr<Response> _staticAssetHandler(Request request) async {
    var path = request.url.path;
    if (path.isEmpty || path.endsWith('/')) {
      path = '${path}index.html';
    }
    // Prevent path escape
    if (path.contains('..')) {
      return Response.forbidden('invalid path');
    }
    final assetPath = 'assets/link_web/$path';
    try {
      final data = await rootBundle.load(assetPath);
      final bytes = data.buffer.asUint8List();
      final mime = lookupMimeType(path) ?? 'application/octet-stream';
      return Response.ok(
        bytes,
        headers: {
          'content-type': mime,
          'cache-control': 'no-cache',
        },
      );
    } catch (_) {
      // SPA fallback
      if (!path.endsWith('.html') && !path.contains('.')) {
        try {
          final data = await rootBundle.load('assets/link_web/index.html');
          return Response.ok(
            data.buffer.asUint8List(),
            headers: {'content-type': 'text/html; charset=utf-8'},
          );
        } catch (_) {}
      }
      return Response.notFound('Not found');
    }
  }

  Middleware _cors() {
    return (inner) {
      return (request) async {
        if (request.method == 'OPTIONS') {
          return Response.ok('', headers: _corsHeaders);
        }
        final response = await inner(request);
        return response.change(headers: _corsHeaders);
      };
    };
  }

  static const _corsHeaders = {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
    'Access-Control-Allow-Headers': 'Content-Type',
  };
}
