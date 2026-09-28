import 'package:flutter_test/flutter_test.dart';
import 'package:link/todo/models/enums.dart';
import 'package:link/todo/models/personal_note.dart';
import 'package:link/todo/models/personal_task.dart';
import 'package:link/todo/smart_sort.dart';

void main() {
  group('smart_sort', () {
    test('orders overdue before due-today before high priority', () {
      final now = DateTime.now();
      final overdue = PersonalTask.create(
        title: 'overdue',
        dueDate: now.subtract(const Duration(days: 2)),
        isAllDay: true,
      );
      final today = PersonalTask.create(
        title: 'today',
        dueDate: now,
        isAllDay: true,
      );
      final high = PersonalTask.create(
        title: 'high',
        priority: TaskPriority.high,
      );
      final plain = PersonalTask.create(title: 'plain');

      final list = [plain, high, today, overdue]..sort(compareTasksSmart);
      expect(list.map((t) => t.title), ['overdue', 'today', 'high', 'plain']);
    });

    test('orders note categories by newest activity', () {
      final older = PersonalNote(
        id: '1',
        title: 'a',
        body: '',
        isShared: false,
        category: 'Old',
        createdAt: DateTime.utc(2024, 1, 1),
        updatedAt: DateTime.utc(2024, 1, 1),
      );
      final newer = PersonalNote(
        id: '2',
        title: 'b',
        body: '',
        isShared: false,
        category: 'New',
        createdAt: DateTime.utc(2024, 1, 1),
        updatedAt: DateTime.utc(2025, 6, 1),
      );
      final groups = <String?, List<PersonalNote>>{
        'Old': [older],
        'New': [newer],
      };
      final keys = groups.keys.toList()
        ..sort((a, b) => compareNoteCategoriesSmart(a, b, groups));
      expect(keys.first, 'New');
    });
  });
}
