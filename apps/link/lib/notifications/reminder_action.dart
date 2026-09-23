import 'dart:async';

/// Kind of item a reminder notification refers to.
enum ReminderKind { task, note }

/// Notification action identifiers. Must match Android/iOS action ids.
abstract final class ReminderActionId {
  static const done = 'done';
  static const snooze = 'snooze';
}

/// Encodes `task:<id>` / `note:<id>` into the notification payload.
class ReminderPayload {
  final ReminderKind kind;
  final String id;

  const ReminderPayload({required this.kind, required this.id});

  factory ReminderPayload.task(String id) =>
      ReminderPayload(kind: ReminderKind.task, id: id);

  factory ReminderPayload.note(String id) =>
      ReminderPayload(kind: ReminderKind.note, id: id);

  String encode() => '${kind.name}:$id';

  static ReminderPayload? tryParse(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    final split = raw.indexOf(':');
    if (split <= 0 || split == raw.length - 1) return null;
    final kindName = raw.substring(0, split);
    final id = raw.substring(split + 1);
    final kind = switch (kindName) {
      'task' => ReminderKind.task,
      'note' => ReminderKind.note,
      _ => null,
    };
    if (kind == null || id.isEmpty) return null;
    return ReminderPayload(kind: kind, id: id);
  }
}

class ReminderActionEvent {
  final String actionId;
  final ReminderPayload payload;

  const ReminderActionEvent({required this.actionId, required this.payload});
}

/// App-locale labels for the OS notification action buttons.
///
/// Kept here (not in l10n) so [LinkNotificationService] can read them
/// without a BuildContext. [languageCode] is updated from the root shell.
abstract final class ReminderActionLabels {
  static String languageCode = 'en';

  static String get done => languageCode == 'nl' ? 'Klaar' : 'Done';
  static String get snooze => languageCode == 'nl' ? 'Uitstellen' : 'Snooze';
}

/// Broadcasts reminder quick-actions from the notification plugin to the UI.
class ReminderActionBus {
  ReminderActionBus._();
  static final ReminderActionBus instance = ReminderActionBus._();

  final _controller = StreamController<ReminderActionEvent>.broadcast();
  String? _lastKey;
  DateTime? _lastAt;

  Stream<ReminderActionEvent> get stream => _controller.stream;

  void emit(ReminderActionEvent event) {
    final key = '${event.actionId}:${event.payload.encode()}';
    final now = DateTime.now();
    if (_lastKey == key &&
        _lastAt != null &&
        now.difference(_lastAt!) < const Duration(seconds: 2)) {
      return;
    }
    _lastKey = key;
    _lastAt = now;
    _controller.add(event);
  }

  void dispatch({required String? actionId, required String? payload}) {
    final parsed = ReminderPayload.tryParse(payload);
    if (parsed == null) return;
    final id = actionId ?? '';
    if (id != ReminderActionId.done && id != ReminderActionId.snooze) {
      return;
    }
    emit(ReminderActionEvent(actionId: id, payload: parsed));
  }
}
