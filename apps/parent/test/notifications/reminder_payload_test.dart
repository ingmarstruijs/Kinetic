import 'package:flutter_test/flutter_test.dart';
import 'package:parent/notifications/reminder_action.dart';

void main() {
  group('ReminderPayload', () {
    test('encodes and parses task ids', () {
      const id = 'abc-123';
      final payload = ReminderPayload.task(id);
      expect(payload.encode(), 'task:$id');
      final parsed = ReminderPayload.tryParse(payload.encode());
      expect(parsed?.kind, ReminderKind.task);
      expect(parsed?.id, id);
    });

    test('encodes and parses note ids', () {
      const id = 'note-9';
      expect(ReminderPayload.note(id).encode(), 'note:$id');
      final parsed = ReminderPayload.tryParse('note:$id');
      expect(parsed?.kind, ReminderKind.note);
      expect(parsed?.id, id);
    });

    test('rejects malformed payloads', () {
      expect(ReminderPayload.tryParse(null), isNull);
      expect(ReminderPayload.tryParse(''), isNull);
      expect(ReminderPayload.tryParse('task:'), isNull);
      expect(ReminderPayload.tryParse(':id'), isNull);
      expect(ReminderPayload.tryParse('other:id'), isNull);
    });
  });

  group('ReminderActionBus', () {
    test('dispatch emits done and snooze, ignores taps', () async {
      final events = <ReminderActionEvent>[];
      final sub = ReminderActionBus.instance.stream.listen(events.add);

      ReminderActionBus.instance.dispatch(
        actionId: ReminderActionId.done,
        payload: 'task:1',
      );
      ReminderActionBus.instance.dispatch(actionId: '', payload: 'task:1');
      ReminderActionBus.instance.dispatch(
        actionId: ReminderActionId.snooze,
        payload: 'note:2',
      );
      await Future<void>.delayed(Duration.zero);
      await sub.cancel();

      expect(events, hasLength(2));
      expect(events[0].actionId, ReminderActionId.done);
      expect(events[0].payload.id, '1');
      expect(events[1].actionId, ReminderActionId.snooze);
      expect(events[1].payload.kind, ReminderKind.note);
    });
  });
}
