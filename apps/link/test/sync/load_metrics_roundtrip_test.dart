import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:flutter_test/flutter_test.dart';
import 'package:kinetic_webdav/kinetic_webdav.dart';
import 'package:link/sync/webdav_config_repository.dart';
import 'package:link/todo/models/enums.dart';
import 'package:link/todo/services/todo_repository.dart';

import '../helpers/fake_http_client.dart';
import '../helpers/sync_test_harness.dart';
import '../helpers/test_database.dart';

void main() {
  setUpAll(() {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  });

  test('Alice pushLoadMetrics → Bob pullLoadMetrics sees peer counts', () async {
    final storage = SharedStorage();
    final aliceRepo = WebDavConfigRepository(InMemoryKeyValueStore());
    final bobRepo = WebDavConfigRepository(InMemoryKeyValueStore());

    final aliceDb = createTestDatabase();
    final bobDb = createTestDatabase();
    addTearDown(aliceDb.close);
    addTearDown(bobDb.close);

    final aliceTodos = TodoRepository(db: aliceDb);
    await aliceTodos.createTask(
      title: 'Dishes',
      category: TaskCategory.household,
    );
    await aliceTodos.createTask(
      title: 'Laundry',
      category: TaskCategory.household,
    );
    await aliceTodos.createTask(
      title: 'Passport',
      category: TaskCategory.admin,
    );

    final alice = await makeLinkOrchestrator(
      aliceDb,
      storage,
      username: 'alice',
      linkId: 'link-alice',
      personalKey: syncTestPersonalKeyA,
      configRepo: aliceRepo,
    );
    final bob = await makeLinkOrchestrator(
      bobDb,
      storage,
      username: 'bob',
      linkId: 'link-bob',
      personalKey: syncTestPersonalKeyB,
      configRepo: bobRepo,
    );

    await alice.orchestrator.syncWithService(alice.service);

    final peerMetrics = await bob.service.pullLoadMetrics();
    final aliceMetrics = peerMetrics.singleWhere((m) => m.linkId == 'link-alice');
    expect(aliceMetrics.openByCategory['household'], 2);
    expect(aliceMetrics.openByCategory['admin'], 1);
  });
}
