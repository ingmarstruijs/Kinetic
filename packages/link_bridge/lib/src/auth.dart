import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';

/// HMAC-SHA256 helpers for session hello authentication.
class BridgeAuth {
  BridgeAuth._();

  /// Hex-encoded HMAC-SHA256 of [message] with UTF-8 [secret].
  static String hmacHex(String secret, String message) {
    final key = utf8.encode(secret);
    final bytes = utf8.encode(message);
    return Hmac(sha256, key).convert(bytes).toString();
  }

  /// Constant-time compare of two hex (or arbitrary) strings.
  static bool secureEquals(String a, String b) {
    final aa = utf8.encode(a);
    final bb = utf8.encode(b);
    if (aa.length != bb.length) return false;
    var diff = 0;
    for (var i = 0; i < aa.length; i++) {
      diff |= aa[i] ^ bb[i];
    }
    return diff == 0;
  }

  /// Canonical hello payload: `sid|nonce|ts`.
  static String helloMessage({
    required String sid,
    required String nonce,
    required int timestampMs,
  }) =>
      '$sid|$nonce|$timestampMs';

  /// Verifies [mac] for a session hello.
  static bool verifyHello({
    required String secret,
    required String sid,
    required String nonce,
    required int timestampMs,
    required String mac,
  }) {
    final expected = hmacHex(
      secret,
      helloMessage(sid: sid, nonce: nonce, timestampMs: timestampMs),
    );
    return secureEquals(expected, mac);
  }

  static String randomHex(int byteLength, [Random? random]) {
    final r = random ?? Random.secure();
    final bytes = Uint8List.fromList(
      List.generate(byteLength, (_) => r.nextInt(256)),
    );
    return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }
}
