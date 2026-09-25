import 'dart:convert';

/// Wire message kinds for the bridge JSON protocol.
abstract final class BridgeMethods {
  static const sessionHello = 'session.hello';
  static const sessionOk = 'session.ok';
  static const sessionError = 'session.error';
  static const sessionRevoke = 'session.revoke';
  static const tasksList = 'tasks.list';
  static const tasksCreate = 'tasks.create';
  static const tasksComplete = 'tasks.complete';
  static const tasksUpdate = 'tasks.update';
  static const notesList = 'notes.list';
  static const eventTasksChanged = 'event.tasksChanged';
}

/// One JSON-RPC-style frame over the WebSocket.
class BridgeMessage {
  final String method;
  final String? id;
  final Map<String, dynamic> params;
  final Map<String, dynamic>? error;

  const BridgeMessage({
    required this.method,
    this.id,
    this.params = const {},
    this.error,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'method': method,
      if (id != null) 'id': id,
      'params': params,
    };
    if (error != null) map['error'] = error;
    return map;
  }

  String encode() => jsonEncode(toJson());

  static BridgeMessage? tryParse(String raw) {
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      final method = map['method'] as String?;
      if (method == null || method.isEmpty) return null;
      final paramsRaw = map['params'];
      final params = paramsRaw is Map<String, dynamic>
          ? paramsRaw
          : <String, dynamic>{};
      final errorRaw = map['error'];
      final error =
          errorRaw is Map<String, dynamic> ? errorRaw : null;
      return BridgeMessage(
        method: method,
        id: map['id'] as String?,
        params: params,
        error: error,
      );
    } catch (_) {
      return null;
    }
  }

  BridgeMessage replyOk(Map<String, dynamic> params) => BridgeMessage(
        method: method,
        id: id,
        params: params,
      );

  BridgeMessage replyError(String code, String message) => BridgeMessage(
        method: BridgeMethods.sessionError,
        id: id,
        params: const {},
        error: {'code': code, 'message': message},
      );
}
