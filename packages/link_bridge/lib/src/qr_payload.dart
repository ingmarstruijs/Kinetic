import 'dart:convert';
import 'dart:math';

import 'auth.dart';

/// QR / paste payload that opens a Link Web LAN session.
class LinkWebQrPayload {
  static const int version = 1;
  static const String type = 'link-web';

  final String httpUrl;
  final String wsUrl;
  final String sid;
  final String sec;
  final int expMs;

  const LinkWebQrPayload({
    required this.httpUrl,
    required this.wsUrl,
    required this.sid,
    required this.sec,
    required this.expMs,
  });

  bool get isExpired =>
      DateTime.now().toUtc().millisecondsSinceEpoch >= expMs;

  Map<String, dynamic> toJson() => {
        'v': version,
        'type': type,
        'http': httpUrl,
        'ws': wsUrl,
        'sid': sid,
        'sec': sec,
        'exp': expMs,
      };

  String encode() => jsonEncode(toJson());

  static LinkWebQrPayload? tryParse(String raw) {
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      if (map['v'] != version) return null;
      if (map['type'] != type) return null;
      final http = map['http'] as String?;
      final ws = map['ws'] as String?;
      final sid = map['sid'] as String?;
      final sec = map['sec'] as String?;
      final exp = map['exp'];
      if (http == null || ws == null || sid == null || sec == null) {
        return null;
      }
      final expMs = exp is int ? exp : int.tryParse('$exp');
      if (expMs == null) return null;
      return LinkWebQrPayload(
        httpUrl: http,
        wsUrl: ws,
        sid: sid,
        sec: sec,
        expMs: expMs,
      );
    } catch (_) {
      return null;
    }
  }

  /// Creates a fresh payload for [lanHost] and [port].
  static LinkWebQrPayload mint({
    required String lanHost,
    required int port,
    Duration ttl = const Duration(minutes: 30),
    Random? random,
  }) {
    final sid = BridgeAuth.randomHex(16, random);
    final sec = BridgeAuth.randomHex(32, random);
    final exp = DateTime.now().toUtc().add(ttl).millisecondsSinceEpoch;
    final http = 'http://$lanHost:$port/';
    final ws = 'ws://$lanHost:$port/bridge';
    return LinkWebQrPayload(
      httpUrl: http,
      wsUrl: ws,
      sid: sid,
      sec: sec,
      expMs: exp,
    );
  }
}
