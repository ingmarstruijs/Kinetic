import 'dart:typed_data';

import 'package:kinetic_webdav/kinetic_webdav.dart';
import 'package:link/db/app_database.dart';
import 'package:link/sync/sync_orchestrator.dart';
import 'package:link/sync/webdav_config_repository.dart';

import 'fake_http_client.dart';

/// Shared family key for multi-device FakeHttpClient tests.
final syncTestFamilyKey = Uint8List.fromList(List.generate(32, (i) => i + 50));

final syncTestPersonalKeyA =
    Uint8List.fromList(List.generate(32, (i) => i + 1));
final syncTestPersonalKeyB =
    Uint8List.fromList(List.generate(32, (i) => i + 100));

/// Builds a Link [SyncOrchestrator] + [WebDavSyncService] on [storage].
///
/// When [configRepo] is provided, roster sync runs (save a family key on the
/// repo first, or `_syncRoster` no-ops on the live-key check).
Future<({SyncOrchestrator orchestrator, WebDavSyncService service, SyncConfig config})>
    makeLinkOrchestrator(
  AppDatabase db,
  SharedStorage storage, {
  String username = 'testuser',
  String linkId = '',
  required Uint8List personalKey,
  WebDavConfigRepository? configRepo,
  void Function(List<String> disconnectedIds)? onDisconnectsDetected,
  void Function(FamilyRoster roster)? onRosterUpdated,
}) async {
  final config = SyncConfig(
    serverUrl: 'https://fake-dav',
    username: username,
    password: 'pass',
    linkId: linkId,
    personalKeyBytes: personalKey,
    familyKeyBytes: syncTestFamilyKey,
  );
  if (configRepo != null) {
    await configRepo.saveFamilyKey(syncTestFamilyKey);
  }
  final client = WebDavClient(
    baseUrl: config.baseUrl,
    username: config.username,
    password: config.password,
    httpClient: FakeHttpClient(storage),
  );
  final service = WebDavSyncService(client: client, config: config);
  final orchestrator = SyncOrchestrator(
    db: db,
    config: config,
    configRepository: configRepo,
    onDisconnectsDetected: onDisconnectsDetected,
    onRosterUpdated: onRosterUpdated,
  );
  return (orchestrator: orchestrator, service: service, config: config);
}
