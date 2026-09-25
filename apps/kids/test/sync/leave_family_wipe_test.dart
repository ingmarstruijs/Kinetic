import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:kids/debug/demo_scenarios.dart';
import 'package:kids/sync/webdav_config_repository.dart';
import 'package:kids/task/services/kids_task_repository.dart';
import 'package:kinetic_webdav/kinetic_webdav.dart';

import '../helpers/test_database.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('clearAllTasks wipes chores so re-enroll starts empty locally', () async {
    final db = createTestDatabase();
    addTearDown(db.close);
    final repo = KidsTaskRepository(db: db);

    await KidsDemoScenarioLoader(db: db).apply(
      KidsDemoScenario.full,
      dutch: false,
    );
    expect(await repo.watchAll().first, isNotEmpty);

    await repo.clearAllTasks();
    expect(await repo.watchAll().first, isEmpty);
  });

  test('clearEnrollment removes last-sync and credentials', () async {
    final store = InMemoryKeyValueStore();
    final configRepo = WebDavConfigRepository(store);
    await configRepo.saveEnrollment(
      serverUrl: 'https://example.test/remote.php/dav',
      username: 'parent',
      password: 'test-password',
      familyKey: Uint8List.fromList(List.generate(32, (i) => i)),
      kidId: 'kid-1',
    );
    await configRepo.saveLastSyncAt(DateTime.utc(2026, 9, 1));

    expect(await configRepo.load(), isNotNull);
    expect(await configRepo.loadLastSyncAt(), isNotNull);

    await configRepo.clearEnrollment();
    expect(await configRepo.load(), isNull);
    expect(await configRepo.loadKidId(), isNull);
    expect(await configRepo.loadLastSyncAt(), isNull);
  });
}
