/// Active bridge session state on the phone.
class BridgeSession {
  final String sid;
  final String secret;
  final DateTime createdAt;
  final DateTime expiresAt;
  final Duration idleTtl;

  DateTime lastActivityAt;
  bool revoked;

  BridgeSession({
    required this.sid,
    required this.secret,
    required this.createdAt,
    required this.expiresAt,
    this.idleTtl = const Duration(minutes: 20),
    DateTime? lastActivityAt,
    this.revoked = false,
  }) : lastActivityAt = lastActivityAt ?? createdAt;

  bool isAlive([DateTime? now]) {
    final n = now ?? DateTime.now().toUtc();
    if (revoked) return false;
    if (!n.isBefore(expiresAt)) return false;
    if (n.difference(lastActivityAt) > idleTtl) return false;
    return true;
  }

  void touch([DateTime? now]) {
    lastActivityAt = now ?? DateTime.now().toUtc();
  }

  void revoke() {
    revoked = true;
  }
}

/// Result of accepting a session hello.
class SessionHelloResult {
  final bool ok;
  final String? error;
  final int? expiresAtMs;
  final List<String> scopes;

  const SessionHelloResult.ok({
    required this.expiresAtMs,
    this.scopes = const ['tasks', 'notes'],
  })  : ok = true,
        error = null;

  const SessionHelloResult.fail(this.error)
      : ok = false,
        expiresAtMs = null,
        scopes = const [];
}
