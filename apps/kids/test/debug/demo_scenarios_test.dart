import 'package:flutter_test/flutter_test.dart';
import 'package:kids/debug/demo_scenarios.dart';
import 'package:kids/debug/demo_session.dart';
import 'package:kids/task/services/kids_task_repository.dart';

import '../helpers/test_database.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(KidsDemoSession.instance.clear);

  test('full scenario seeds chores, waiting, completed and a goal', () async {
    final db = createTestDatabase();
    addTearDown(db.close);

    final result = await KidsDemoScenarioLoader(db: db).apply(
      KidsDemoScenario.full,
      dutch: true,
    );

    final tasks = await KidsTaskRepository(db: db).watchAll().first;
    expect(tasks.where((t) => t.isOpen), isNotEmpty);
    expect(tasks.where((t) => t.awaitingVerification), isNotEmpty);
    expect(tasks.where((t) => t.isCompleted), isNotEmpty);
    expect(result.goal, isNotNull);
    expect(result.goal!.targetXp, 50);
    expect(KidsDemoSession.instance.active, isTrue);
  });

  test('offlineQueued scenario seeds dirty awaiting completions', () async {
    final db = createTestDatabase();
    addTearDown(db.close);

    await KidsDemoScenarioLoader(db: db).apply(
      KidsDemoScenario.offlineQueued,
      dutch: false,
    );

    final tasks = await KidsTaskRepository(db: db).watchAll().first;
    final dirty = tasks.where((t) => t.syncState == 'dirty').toList();
    expect(dirty, isNotEmpty);
    expect(dirty.every((t) => t.awaitingVerification), isTrue);
    expect(KidsDemoSession.instance.active, isTrue);
  });

  test('empty scenario enrolls with no tasks', () async {
    final db = createTestDatabase();
    addTearDown(db.close);

    final result = await KidsDemoScenarioLoader(db: db).apply(
      KidsDemoScenario.empty,
      dutch: false,
    );

    final tasks = await KidsTaskRepository(db: db).watchAll().first;
    expect(tasks, isEmpty);
    expect(result.goal, isNull);
    expect(KidsDemoSession.instance.active, isTrue);
  });
}
