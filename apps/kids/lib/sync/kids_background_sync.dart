import 'package:kinetic_webdav/kinetic_webdav.dart';
import 'package:workmanager/workmanager.dart';

import '../db/app_database.dart';
import '../notifications/kids_notification_service.dart';
import '../task/services/kids_task_repository.dart';
import 'sync_orchestrator.dart';
import 'webdav_config_repository.dart';

const kidsSyncUniqueName = 'kinetic-kids-sync';
const kidsSyncTaskName = 'kineticKidsSync';

/// Entry point for the OS background worker. Must stay a top-level function.
@pragma('vm:entry-point')
void kidsSyncCallbackDispatcher() {
  Workmanager().executeTask((taskName, _) async {
    if (taskName != kidsSyncTaskName &&
        taskName != kidsSyncUniqueName &&
        taskName != Workmanager.iOSBackgroundTask) {
      return true;
    }
    final db = AppDatabase();
    try {
      await syncKidsAndNotify(db);
      return true;
    } catch (_) {
      return false;
    } finally {
      await db.close();
    }
  });
}

/// Registers a periodic WebDAV poll so a new chore can notify while the app
/// is not in the foreground. Android's minimum interval is 15 minutes.
Future<void> registerKidsBackgroundSync() async {
  await Workmanager().initialize(kidsSyncCallbackDispatcher);
  await Workmanager().registerPeriodicTask(
    kidsSyncUniqueName,
    kidsSyncTaskName,
    frequency: const Duration(minutes: 15),
    existingWorkPolicy: ExistingPeriodicWorkPolicy.update,
    constraints: Constraints(networkType: NetworkType.connected),
  );
}

/// One sync cycle. Safe to call from the UI isolate or a background worker.
Future<void> syncKidsAndNotify(AppDatabase db) async {
  final store = FlutterSecureKeyValueStore();
  final configRepo = WebDavConfigRepository(store);
  final config = await configRepo.load();
  if (config == null) return;

  final kidId = await configRepo.loadKidId() ?? '';
  final notifications = KidsNotificationService();
  await notifications.initialize();
  final orchestrator = KidsSyncOrchestrator(
    db: db,
    repo: KidsTaskRepository(db: db),
    config: config,
    myKidId: kidId,
    configRepo: configRepo,
    onNewTaskReceived: (title) {
      notifications.showNewTaskNotification(title);
    },
  );
  await orchestrator.sync();
}
