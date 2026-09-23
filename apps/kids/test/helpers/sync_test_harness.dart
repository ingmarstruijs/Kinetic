import 'dart:typed_data';

import 'package:kids/db/app_database.dart';
import 'package:kids/sync/sync_orchestrator.dart';
import 'package:kids/task/services/kids_task_repository.dart';
import 'package:kinetic_webdav/kinetic_webdav.dart';

import 'fake_http_client.dart';

final kidsSyncTestFamilyKey =
    Uint8List.fromList(List.generate(32, (i) => i + 50));

final kidsSyncTestPersonalKey =
    Uint8List.fromList(List.generate(32, (i) => i + 1));

({KidsSyncOrchestrator orchestrator, WebDavSyncService service, SyncConfig config})
    makeKidsOrchestrator(
  AppDatabase db,
  SharedStorage storage, {
  required String myKidId,
  String username = 'kid-device',
  void Function()? onDisconnected,
  void Function(String taskTitle)? onNewTaskReceived,
  void Function(KidGoal? goal)? onGoalReceived,
}) {
  final config = SyncConfig(
    serverUrl: 'https://fake-dav',
    username: username,
    password: 'pass',
    linkId: myKidId,
    personalKeyBytes: kidsSyncTestPersonalKey,
    familyKeyBytes: kidsSyncTestFamilyKey,
  );
  final client = WebDavClient(
    baseUrl: config.baseUrl,
    username: config.username,
    password: config.password,
    httpClient: FakeHttpClient(storage),
  );
  final service = WebDavSyncService(client: client, config: config);
  final repo = KidsTaskRepository(db: db);
  final orchestrator = KidsSyncOrchestrator(
    db: db,
    repo: repo,
    config: config,
    myKidId: myKidId,
    onDisconnected: onDisconnected,
    onNewTaskReceived: onNewTaskReceived,
    onGoalReceived: onGoalReceived,
  );
  return (orchestrator: orchestrator, service: service, config: config);
}
