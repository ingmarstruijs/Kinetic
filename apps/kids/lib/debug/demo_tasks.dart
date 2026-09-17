import '../db/app_database.dart';
import 'demo_scenarios.dart';

/// Back-compat helper used by older call sites.
/// Prefer [KidsDemoScenariosScreen] / [KidsDemoScenarioLoader].
Future<void> loadKidsDemoTasks(AppDatabase db, {required bool dutch}) async {
  await KidsDemoScenarioLoader(db: db).apply(
    KidsDemoScenario.chores,
    dutch: dutch,
  );
}
