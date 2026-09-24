import 'package:kinetic_webdav/kinetic_webdav.dart';
import 'package:uuid/uuid.dart';

import '../db/app_database.dart';
import '../task/models/kids_task.dart';
import '../task/services/kids_task_repository.dart';
import 'demo_session.dart';

enum KidsDemoScenario { empty, chores, waiting, offlineQueued, goal, full }

class KidsDemoScenarioInfo {
  final KidsDemoScenario id;
  final String titleEn;
  final String titleNl;
  final String subtitleEn;
  final String subtitleNl;

  const KidsDemoScenarioInfo({
    required this.id,
    required this.titleEn,
    required this.titleNl,
    required this.subtitleEn,
    required this.subtitleNl,
  });

  String title(bool nl) => nl ? titleNl : titleEn;
  String subtitle(bool nl) => nl ? subtitleNl : subtitleEn;
}

const kidsDemoScenarioCatalog = <KidsDemoScenarioInfo>[
  KidsDemoScenarioInfo(
    id: KidsDemoScenario.empty,
    titleEn: 'Empty home',
    titleNl: 'Leeg startscherm',
    subtitleEn: 'Enrolled look — no chores yet',
    subtitleNl: 'Alsof gekoppeld — nog geen klusjes',
  ),
  KidsDemoScenarioInfo(
    id: KidsDemoScenario.chores,
    titleEn: 'Open chores',
    titleNl: 'Open klusjes',
    subtitleEn: 'Overdue, today, and tomorrow',
    subtitleNl: 'Te laat, vandaag en morgen',
  ),
  KidsDemoScenarioInfo(
    id: KidsDemoScenario.waiting,
    titleEn: 'Awaiting Link',
    titleNl: 'Wacht op Link',
    subtitleEn: 'Open chores plus pending verification',
    subtitleNl: 'Open klusjes plus wachtend op bevestiging',
  ),
  KidsDemoScenarioInfo(
    id: KidsDemoScenario.offlineQueued,
    titleEn: 'Offline queue',
    titleNl: 'Offline wachtrij',
    subtitleEn: 'Completed locally — dirty rows waiting to sync',
    subtitleNl: 'Lokaal afgerond — dirty rijen wachten op sync',
  ),
  KidsDemoScenarioInfo(
    id: KidsDemoScenario.goal,
    titleEn: 'XP goal',
    titleNl: 'XP-doel',
    subtitleEn: 'Progress toward a reward with some completed XP',
    subtitleNl: 'Voortgang naar een beloning met wat verdiende XP',
  ),
  KidsDemoScenarioInfo(
    id: KidsDemoScenario.full,
    titleEn: 'Full house',
    titleNl: 'Vol huis',
    subtitleEn: 'Open, waiting, queued, done, and a goal',
    subtitleNl: 'Open, wachtend, queue, klaar en een doel',
  ),
];

class KidsDemoScenarioResult {
  final KidGoal? goal;

  const KidsDemoScenarioResult({this.goal});
}

class KidsDemoScenarioLoader {
  KidsDemoScenarioLoader({required AppDatabase db}) : _db = db;

  final AppDatabase _db;

  Future<KidsDemoScenarioResult> apply(
    KidsDemoScenario scenario, {
    required bool dutch,
  }) async {
    await _db.delete(_db.kidsTasks).go();
    KidsDemoSession.instance.clear();

    KidGoal? goal;
    switch (scenario) {
      case KidsDemoScenario.empty:
        break;
      case KidsDemoScenario.chores:
        await _seedChores(dutch);
      case KidsDemoScenario.waiting:
        await _seedChores(dutch);
        await _seedWaiting(dutch);
      case KidsDemoScenario.offlineQueued:
        await _seedChores(dutch);
        await _seedQueuedOffline(dutch);
      case KidsDemoScenario.goal:
        await _seedChores(dutch, includeCompleted: true);
        goal = _demoGoal(dutch);
      case KidsDemoScenario.full:
        await _seedChores(dutch, includeCompleted: true);
        await _seedWaiting(dutch);
        await _seedQueuedOffline(dutch);
        goal = _demoGoal(dutch, targetXp: 50);
    }

    KidsDemoSession.instance.apply(goal: goal);
    return KidsDemoScenarioResult(goal: goal);
  }

  KidGoal _demoGoal(bool dutch, {int targetXp = 40}) {
    return KidGoal(
      kidId: KidsDemoSession.kidId,
      title: dutch ? 'Nieuw voetbalspel' : 'New soccer game',
      targetXp: targetXp,
      updatedAt: DateTime.now().toUtc(),
    );
  }

  Future<void> _seedChores(bool dutch, {bool includeCompleted = false}) async {
    final repo = KidsTaskRepository(db: _db);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day, 18);
    final yesterday = today.subtract(const Duration(days: 1));
    final tomorrow = today.add(const Duration(days: 1));

    Future<void> add({
      required String en,
      required String nl,
      DateTime? due,
      bool done = false,
      bool awaiting = false,
      int xp = 10,
      TaskCategory category = TaskCategory.household,
      TaskPriority priority = TaskPriority.normal,
      String syncState = 'clean',
    }) {
      final created = DateTime.now().toUtc();
      return repo.upsertTask(
        KidsTask(
          id: const Uuid().v4(),
          linkTaskId: KidsDemoSession.linkTaskId,
          title: dutch ? nl : en,
          category: category,
          priority: priority,
          dueDate: due?.toUtc(),
          isCompleted: done,
          awaitingVerification: awaiting,
          completedAt: done ? created : null,
          xpReward: xp,
          syncState: syncState,
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
    if (includeCompleted) {
      await add(en: 'Make the bed', nl: 'Bed opmaken', done: true, xp: 10);
      await add(
        en: 'Feed the pet',
        nl: 'Huisdier voeren',
        done: true,
        xp: 15,
        category: TaskCategory.other,
      );
    }
  }

  Future<void> _seedWaiting(bool dutch) async {
    final repo = KidsTaskRepository(db: _db);
    final created = DateTime.now().toUtc();
    await repo.upsertTask(
      KidsTask(
        id: const Uuid().v4(),
        linkTaskId: KidsDemoSession.linkTaskId,
        title: dutch ? 'Schoenen poetsen' : 'Polish shoes',
        category: TaskCategory.household,
        priority: TaskPriority.normal,
        dueDate: created,
        awaitingVerification: true,
        xpReward: 10,
        syncState: 'dirty',
        createdAt: created,
        updatedAt: created,
      ),
    );
  }

  /// Kid finished chores while offline — dirty rows queue until sync succeeds.
  Future<void> _seedQueuedOffline(bool dutch) async {
    final repo = KidsTaskRepository(db: _db);
    final created = DateTime.now().toUtc();
    await repo.upsertTask(
      KidsTask(
        id: const Uuid().v4(),
        linkTaskId: KidsDemoSession.linkTaskId,
        title: dutch ? 'Afval buiten (offline)' : 'Take out trash (offline)',
        category: TaskCategory.household,
        priority: TaskPriority.normal,
        dueDate: created,
        awaitingVerification: true,
        xpReward: 10,
        syncState: 'dirty',
        createdAt: created,
        updatedAt: created,
      ),
    );
    await repo.upsertTask(
      KidsTask(
        id: const Uuid().v4(),
        linkTaskId: KidsDemoSession.linkTaskId,
        title: dutch ? 'Rugzak pakken (offline)' : 'Pack backpack (offline)',
        category: TaskCategory.school,
        priority: TaskPriority.high,
        dueDate: created,
        awaitingVerification: true,
        xpReward: 15,
        syncState: 'dirty',
        createdAt: created,
        updatedAt: created,
      ),
    );
  }
}
