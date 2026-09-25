import 'auth.dart';
import 'messages.dart';
import 'qr_payload.dart';
import 'session.dart';
import 'task_store.dart';

/// Handles bridge JSON-RPC after WebSocket framing (phone or in-memory tests).
class BridgeRpcHandler {
  BridgeSession? _session;
  bool _authed = false;
  final BridgeTaskStore store;
  DateTime Function() clock;
  final Duration helloSkew;

  BridgeRpcHandler({
    required this.store,
    DateTime Function()? clock,
    this.helloSkew = const Duration(minutes: 2),
  }) : clock = clock ?? (() => DateTime.now().toUtc());

  BridgeSession? get session => _session;
  bool get isAuthed => _authed;

  void armFromQr(LinkWebQrPayload qr) {
    _authed = false;
    _session = BridgeSession(
      sid: qr.sid,
      secret: qr.sec,
      createdAt: clock(),
      expiresAt: DateTime.fromMillisecondsSinceEpoch(qr.expMs, isUtc: true),
    );
  }

  void revoke() {
    _session?.revoke();
    _authed = false;
  }

  Future<BridgeMessage> handle(BridgeMessage msg) async {
    switch (msg.method) {
      case BridgeMethods.sessionHello:
        return _hello(msg);
      case BridgeMethods.sessionRevoke:
        return _revoke(msg);
      case BridgeMethods.tasksList:
        return _requireSession(msg, _listTasks);
      case BridgeMethods.tasksCreate:
        return _requireSession(msg, _createTask);
      case BridgeMethods.tasksComplete:
        return _requireSession(msg, _completeTask);
      case BridgeMethods.tasksUpdate:
        return _requireSession(msg, _updateTask);
      case BridgeMethods.notesList:
        return _requireSession(
          msg,
          (m) async => BridgeMessage(
            method: BridgeMethods.notesList,
            id: m.id,
            params: {'notes': <Map<String, dynamic>>[]},
          ),
        );
      default:
        return msg.replyError(
          'unknown_method',
          'Unknown method: ${msg.method}',
        );
    }
  }

  BridgeMessage _hello(BridgeMessage msg) {
    final s = _session;
    if (s == null || s.revoked) {
      return msg.replyError('no_session', 'No active session');
    }
    final sid = msg.params['sid'] as String? ?? '';
    final nonce = msg.params['nonce'] as String? ?? '';
    final ts = msg.params['ts'];
    final mac = msg.params['mac'] as String? ?? '';
    final timestampMs = ts is int ? ts : int.tryParse('$ts') ?? 0;
    if (sid != s.sid) {
      return msg.replyError('bad_sid', 'Session id mismatch');
    }
    final now = clock();
    final skew = Duration(
      milliseconds: (now.millisecondsSinceEpoch - timestampMs).abs(),
    );
    if (skew > helloSkew) {
      return msg.replyError('bad_ts', 'Timestamp skew too large');
    }
    if (!BridgeAuth.verifyHello(
      secret: s.secret,
      sid: sid,
      nonce: nonce,
      timestampMs: timestampMs,
      mac: mac,
    )) {
      return msg.replyError('bad_mac', 'Authentication failed');
    }
    if (!s.isAlive(now)) {
      return msg.replyError('expired', 'Session expired');
    }
    s.touch(now);
    _authed = true;
    return BridgeMessage(
      method: BridgeMethods.sessionOk,
      id: msg.id,
      params: {
        'expiresAt': s.expiresAt.toUtc().millisecondsSinceEpoch,
        'scopes': ['tasks', 'notes'],
      },
    );
  }

  BridgeMessage _revoke(BridgeMessage msg) {
    revoke();
    return BridgeMessage(
      method: BridgeMethods.sessionRevoke,
      id: msg.id,
      params: {'ok': true},
    );
  }

  Future<BridgeMessage> _requireSession(
    BridgeMessage msg,
    Future<BridgeMessage> Function(BridgeMessage) next,
  ) async {
    final s = _session;
    final now = clock();
    if (s == null || !_authed || !s.isAlive(now)) {
      return msg.replyError('unauthorized', 'Session not active');
    }
    s.touch(now);
    return next(msg);
  }

  Future<BridgeMessage> _listTasks(BridgeMessage msg) async {
    final tasks = await store.listTasks();
    return BridgeMessage(
      method: BridgeMethods.tasksList,
      id: msg.id,
      params: {'tasks': tasks.map((t) => t.toJson()).toList()},
    );
  }

  Future<BridgeMessage> _createTask(BridgeMessage msg) async {
    final title = (msg.params['title'] as String?)?.trim() ?? '';
    if (title.isEmpty) {
      return msg.replyError('bad_request', 'title required');
    }
    final task = await store.createTask(
      title: title,
      notes: msg.params['notes'] as String?,
    );
    return BridgeMessage(
      method: BridgeMethods.tasksCreate,
      id: msg.id,
      params: {'task': task.toJson()},
    );
  }

  Future<BridgeMessage> _completeTask(BridgeMessage msg) async {
    final id = msg.params['id'] as String? ?? '';
    final task = await store.completeTask(id);
    if (task == null) {
      return msg.replyError('not_found', 'Task not found');
    }
    return BridgeMessage(
      method: BridgeMethods.tasksComplete,
      id: msg.id,
      params: {'task': task.toJson()},
    );
  }

  Future<BridgeMessage> _updateTask(BridgeMessage msg) async {
    final id = msg.params['id'] as String? ?? '';
    final task = await store.updateTask(
      id,
      title: msg.params['title'] as String?,
      notes: msg.params.containsKey('notes')
          ? msg.params['notes'] as String?
          : null,
    );
    if (task == null) {
      return msg.replyError('not_found', 'Task not found');
    }
    return BridgeMessage(
      method: BridgeMethods.tasksUpdate,
      id: msg.id,
      params: {'task': task.toJson()},
    );
  }
}

/// Client helper that builds authenticated hello messages.
class BridgeClientHello {
  static BridgeMessage build({
    required String sid,
    required String secret,
    required String nonce,
    required int timestampMs,
    String? id,
  }) {
    final mac = BridgeAuth.hmacHex(
      secret,
      BridgeAuth.helloMessage(
        sid: sid,
        nonce: nonce,
        timestampMs: timestampMs,
      ),
    );
    return BridgeMessage(
      method: BridgeMethods.sessionHello,
      id: id ?? 'hello-1',
      params: {
        'sid': sid,
        'nonce': nonce,
        'ts': timestampMs,
        'mac': mac,
      },
    );
  }
}
