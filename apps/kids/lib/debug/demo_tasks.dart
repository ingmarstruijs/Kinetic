import 'package:uuid/uuid.dart';

import '../db/app_database.dart';
import '../task/models/kids_task.dart';
import '../task/services/kids_task_repository.dart';

/// Debug-only chores so the kids app can be screenshot and tapped through
/// without WebDAV enrollment.
Future<void> loadKidsDemoTasks(AppDatabase db, {required bool dutch}) async {
  await db.delete(db.kidsTasks).go();
  final repo = KidsTaskRepository(db: db);
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day, 18);
  final yesterday = today.subtract(const Duration(days: 1));
  final tomorrow = today.add(const Duration(days: 1));

  Future<void> add({
    required String en,
    required String nl,
    DateTime? due,
    bool done = false,
    int xp = 10,
    TaskCategory category = TaskCategory.household,
    TaskPriority priority = TaskPriority.normal,
  }) {
    final created = DateTime.now().toUtc();
    return repo.upsertTask(
      KidsTask(
        id: const Uuid().v4(),
        parentId: 'demo-parent',
        title: dutch ? nl : en,
        category: category,
        priority: priority,
        dueDate: due?.toUtc(),
        isCompleted: done,
        completedAt: done ? created : null,
        xpReward: xp,
        syncState: 'clean',
        createdAt: created,
        updatedAt: created,
      ),
    );
  }

  await add(
    en: 'Brush teeth',
    nl: 'Tanden poetsen',
    due: yesterday,
    category: TaskCategory.health,
    priority: TaskPriority.high,
  );
  await add(en: 'Tidy room', nl: 'Kamer opruimen', due: today);
  await add(en: 'Set the table', nl: 'Tafel dekken', due: tomorrow, xp: 15);
  await add(en: 'Make the bed', nl: 'Bed opmaken', done: true, xp: 10);
}
