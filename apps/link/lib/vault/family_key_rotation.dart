import 'package:drift/drift.dart';
import 'package:kinetic_webdav/kinetic_webdav.dart';

import '../db/app_database.dart';
import '../sync/webdav_config_repository.dart';
import 'family_vault_sync.dart';

/// Marks shared family data so the next sync pushes with the new family key.
Future<void> markSharedFamilyItemsDirty(AppDatabase db) async {
  await (db.update(db.personalNotes)..where((n) => n.isShared.equals(true)))
      .write(const PersonalNotesCompanion(syncState: Value('dirty')));
  await (db.update(db.personalTasks)..where((t) => t.kidsTaskId.isNotNull()))
      .write(const PersonalTasksCompanion(syncState: Value('dirty')));
}

/// Re-encrypts remote shared data and stores [newFamilyKey] locally.
///
/// Throws when WebDAV is unreachable or re-encryption reports failures.
Future<FamilySharedReencryptReport> applyFamilyKeyRotation({
  required WebDavConfigRepository configRepo,
  required AppDatabase db,
  required Uint8List oldFamilyKey,
  required Uint8List newFamilyKey,
  required Uint8List newEntropy,
  void Function(FamilySharedReencryptProgress progress)? onProgress,
}) async {
  final config = await configRepo.load();
  final personal = await configRepo.loadPersonalKeyBytes();
  if (config == null || personal == null) {
    throw StateError('WebDAV or personal vault not configured');
  }

  final client = WebDavClient(
    baseUrl: config.serverUrl,
    username: config.username,
    password: config.password,
  );
  try {
    final service = WebDavSyncService(client: client, config: config);
    final report = await service.reencryptSharedTree(
      oldFamilyKey: oldFamilyKey,
      newFamilyKey: newFamilyKey,
      onProgress: onProgress,
    );
    if (!report.ok) {
      throw StateError(
        'Re-encryption incomplete (${report.failed} file(s) failed)',
      );
    }

    await configRepo.saveFamilyKey(newFamilyKey, entropy: newEntropy);
    await markSharedFamilyItemsDirty(db);
    await FamilyVaultSync.pushIfPossible(configRepo);
    return report;
  } finally {
    client.dispose();
  }
}
