import 'package:kinetic_webdav/kinetic_webdav.dart';
import 'package:uuid/uuid.dart';

import '../db/app_database.dart';
import '../partner/services/partner_proposal_repository.dart';
import '../settings/models/enrolled_kid.dart';
import '../todo/models/ai_suggestion.dart';
import '../todo/models/enums.dart';
import '../todo/services/ai_suggestion_repository.dart';
import '../todo/services/note_repository.dart';
import '../todo/services/todo_repository.dart';
import 'demo_session.dart';

enum DemoScenario { empty, busyDay, suggestions, kids, notes, fullHouse }

class DemoScenarioInfo {
  final DemoScenario id;
  final String titleEn;
  final String titleNl;
  final String subtitleEn;
  final String subtitleNl;

  const DemoScenarioInfo({
    required this.id,
    required this.titleEn,
    required this.titleNl,
    required this.subtitleEn,
    required this.subtitleNl,
  });

  String title(bool nl) => nl ? titleNl : titleEn;
  String subtitle(bool nl) => nl ? subtitleNl : subtitleEn;
}

const demoScenarioCatalog = <DemoScenarioInfo>[
  DemoScenarioInfo(
    id: DemoScenario.empty,
    titleEn: 'Empty tasks',
    titleNl: 'Lege takenlijst',
    subtitleEn: 'All done — no suggestions, no kids',
    subtitleNl: 'Alles klaar — geen suggesties, geen kinderen',
  ),
  DemoScenarioInfo(
    id: DemoScenario.busyDay,
    titleEn: 'Busy day',
    titleNl: 'Drukke dag',
    subtitleEn: 'Overdue, today, reminders, categories',
    subtitleNl: 'Te laat, vandaag, herinneringen, categorieën',
  ),
  DemoScenarioInfo(
    id: DemoScenario.suggestions,
    titleEn: 'Suggestions + partner',
    titleNl: 'Suggesties + partner',
    subtitleEn: 'For you, for partner, and inbox',
    subtitleNl: 'Voor jou, voor partner, en inbox',
  ),
  DemoScenarioInfo(
    id: DemoScenario.kids,
    titleEn: 'Kids overview',
    titleNl: 'Kinderen',
    subtitleEn: 'Two enrolled kids — one with XP, one without',
    subtitleNl: 'Twee gekoppelde kinderen — één met XP, één zonder',
  ),
  DemoScenarioInfo(
    id: DemoScenario.notes,
    titleEn: 'Notes',
    titleNl: 'Notities',
    subtitleEn: 'Private and shared notes with a reminder',
    subtitleNl: 'Privé- en gedeelde notities met herinnering',
  ),
  DemoScenarioInfo(
    id: DemoScenario.fullHouse,
    titleEn: 'Full house',
    titleNl: 'Vol huis',
    subtitleEn: 'Tasks, suggestions, kids, and notes together',
    subtitleNl: 'Taken, suggesties, kinderen en notities samen',
  ),
];

class DemoScenarioLoader {
  DemoScenarioLoader({
    required AppDatabase db,
    required TodoRepository todoRepo,
    required NoteRepository noteRepo,
    required AiSuggestionRepository suggestionRepo,
    required PartnerProposalRepository proposalRepo,
  }) : _db = db,
       _todoRepo = todoRepo,
       _noteRepo = noteRepo,
       _suggestionRepo = suggestionRepo,
       _proposalRepo = proposalRepo;

  final AppDatabase _db;
  final TodoRepository _todoRepo;
  final NoteRepository _noteRepo;
  final AiSuggestionRepository _suggestionRepo;
  final PartnerProposalRepository _proposalRepo;

  Future<void> apply(DemoScenario scenario, {required bool dutch}) async {
    await _clearPersonalData();
    DemoSession.instance.clear();

    switch (scenario) {
      case DemoScenario.empty:
        break;
      case DemoScenario.busyDay:
        await _seedBusyDay(dutch);
      case DemoScenario.suggestions:
        await _seedBusyDay(dutch, compact: true);
        await _seedSuggestions(dutch);
        _setFamily(partner: true, kids: const []);
      case DemoScenario.kids:
        await _seedBusyDay(dutch, compact: true);
        _setFamily(partner: false, kids: _demoKids());
      case DemoScenario.notes:
        await _seedNotes(dutch);
        _setFamily(partner: true, kids: const []);
      case DemoScenario.fullHouse:
        await _seedBusyDay(dutch);
        await _seedSuggestions(dutch);
        await _seedNotes(dutch);
        _setFamily(partner: true, kids: _demoKids());
    }
  }

  Future<void> _clearPersonalData() async {
    await _db.delete(_db.personalSubtasks).go();
    await _db.delete(_db.personalTasks).go();
    await _db.delete(_db.personalNotes).go();
    await _db.delete(_db.partnerProposals).go();
    await _db.delete(_db.aiSuggestions).go();
  }

  void _setFamily({required bool partner, required List<EnrolledKid> kids}) {
    DemoSession.instance.apply(
      partnerPaired: partner,
      kids: kids,
      kidTasks: kids.isEmpty
          ? const []
          : _demoKidTasks(kids, secondLinkMember: partner),
    );
  }

  List<EnrolledKid> _demoKids() {
    final enrolledAt = DateTime.now().toUtc().subtract(
      const Duration(days: 40),
    );
    return [
      EnrolledKid(
        id: 'demo-mees',
        name: 'Mees',
        enrolledAt: enrolledAt,
      ),
      // Contrast: XP & goals off so the settings toggle is visible in demos.
      EnrolledKid(
        id: 'demo-fien',
        name: 'Fien',
        enrolledAt: enrolledAt,
        xpEnabled: false,
      ),
    ];
  }

  /// [secondLinkMember] adds a mission that another link member must verify, so the
  /// verifier filter in the kids panel is visible in partner demos.
  List<ICalTask> _demoKidTasks(
    List<EnrolledKid> kids, {
    bool secondLinkMember = false,
  }) {
    final now = DateTime.now().toUtc();
    ICalTask chore({
      required String summary,
      required String kidId,
      ICalTaskStatus status = ICalTaskStatus.needsAction,
      int xp = 10,
      String? verifierLinkId,
    }) {
      final verifierPart = verifierLinkId != null
          ? ';xKineticVerifierLinkId:$verifierLinkId'
          : '';
      return ICalTask(
        uid: const Uuid().v4(),
        summary: summary,
        description:
            'xKineticTargetKidId:$kidId;xKineticXpReward:$xp$verifierPart',
        status: status,
        createdAt: now,
        updatedAt: now,
      );
    }

    final mees = kids.first.id;
    final fien = kids.last.id;
    return [
      chore(summary: 'Shirts in the hamper', kidId: mees),
      chore(summary: 'Brush teeth', kidId: mees),
      chore(
        summary: 'Make bed',
        kidId: mees,
        status: ICalTaskStatus.completed,
        xp: 15,
      ),
      chore(summary: 'Tidy room', kidId: fien),
      // Awaiting verification by this device — accept/reject are offered.
      chore(
        summary: 'Walk the dog',
        kidId: mees,
        status: ICalTaskStatus.inProcess,
        verifierLinkId: DemoSession.linkId,
      ),
      // Assigned by the second link member in the roster, so this device only sees
      // it as pending. The demo session fakes that member with an id; a real
      // household gets the name from the shared roster.
      if (secondLinkMember)
        chore(
          summary: 'Water the plants',
          kidId: fien,
          status: ICalTaskStatus.inProcess,
          verifierLinkId: 'demo-second-link',
        ),
      ICalTask(
        uid: const Uuid().v4(),
        summary: 'Set the table',
        description: 'xKineticXpReward:10',
        createdAt: now,
        updatedAt: now,
      ),
    ];
  }

  Future<void> _seedBusyDay(bool dutch, {bool compact = false}) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day, 16, 0);
    final yesterday = today.subtract(const Duration(days: 1));
    final tomorrow = today.add(const Duration(days: 1));

    Future<void> add({
      required String en,
      required String nl,
      TaskPriority priority = TaskPriority.none,
      DateTime? due,
      bool allDay = true,
      DateTime? remindAt,
      String? categoryEn,
      String? categoryNl,
    }) {
      return _todoRepo.createTask(
        title: dutch ? nl : en,
        priority: priority,
        dueDate: due?.toUtc(),
        isAllDay: allDay,
        remindAt: remindAt?.toUtc(),
        customCategory: dutch ? categoryNl : categoryEn,
      );
    }

    await add(
      en: 'File tax return',
      nl: 'Belastingaangifte',
      priority: TaskPriority.high,
      due: yesterday,
      categoryEn: 'Admin',
      categoryNl: 'Admin',
    );
    await add(
      en: 'School run',
      nl: 'Schoolrondje',
      due: today,
      allDay: false,
      remindAt: DateTime(now.year, now.month, now.day, now.hour + 1),
      categoryEn: 'School',
      categoryNl: 'School',
    );
    await add(
      en: 'Call the dentist',
      nl: 'Tandarts bellen',
      priority: TaskPriority.high,
      categoryEn: 'Health',
      categoryNl: 'Gezondheid',
    );
    await add(
      en: 'Groceries',
      nl: 'Boodschappen',
      due: tomorrow,
      categoryEn: 'Household',
      categoryNl: 'Huishouden',
    );
    if (!compact) {
      await add(en: 'Unpack the attic box', nl: 'Zolderdoos uitpakken');
      final done = await _todoRepo.createTask(
        title: dutch ? 'Vaatwasser leeghalen' : 'Empty the dishwasher',
        customCategory: dutch ? 'Huishouden' : 'Household',
      );
      await _todoRepo.completeTask(done.id);
    }
  }

  Future<void> _seedSuggestions(bool dutch) async {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    final due = DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 10);

    await _suggestionRepo.upsertSuggestion(
      AiSuggestion.create(
        title: dutch ? 'Boodschappen' : 'Groceries',
        reason: SuggestionReason.habit,
        suggestedDueDate: due.toUtc(),
        explanation: dutch
            ? 'Ongeveer elke 7 dagen, voor het laatst 8 dagen geleden'
            : 'About every 7 days, last 8 days ago',
        dedupeKey: 'demo-habit-groceries',
      ),
    );
    await _suggestionRepo.upsertSuggestion(
      AiSuggestion.create(
        title: dutch ? 'Oude klus' : 'Old chore',
        reason: SuggestionReason.stale,
        explanation: dutch
            ? 'Staat 12 dagen open zonder herinnering'
            : 'Has been open 12 days without a reminder',
        dedupeKey: 'demo-stale',
      ),
    );
    await _suggestionRepo.upsertSuggestion(
      AiSuggestion.create(
        title: dutch
            ? 'Kun jij deze week iets in huishouden oppakken?'
            : 'Can you pick something up in household this week?',
        reason: SuggestionReason.loadBalance,
        category: 'household',
        explanation: dutch
            ? 'Je hebt 4 open taken in huishouden. De hint is bewust algemeen.'
            : 'You have 4 open household tasks. The hint is intentionally generic.',
        dedupeKey: 'demo-load-balance',
      ),
    );

    await _proposalRepo.createManualProposal(
      myLinkId: DemoSession.partnerId,
      taskTitle: dutch ? 'Hond uitlaten' : 'Walk the dog',
      taskNotes: dutch ? 'Graag voor 18:00' : 'Before 18:00 if you can',
      taskPriority: TaskPriority.medium,
      taskDueDate: due.toUtc(),
    );
  }

  Future<void> _seedNotes(bool dutch) async {
    final remind = DateTime.now().add(const Duration(hours: 3));
    await _noteRepo.insert(
      title: dutch ? 'Verjaardag Mees' : "Mees' birthday",
      body: dutch
          ? 'Cadeau: boek. Taart zaterdag bakken.'
          : 'Gift: book. Bake the cake on Saturday.',
      remindAt: remind.toUtc(),
    );
    await _noteRepo.insert(
      title: dutch ? 'Weekmenu' : 'Weekly menu',
      body: dutch
          ? 'Ma: pasta\nDi: soep\nWo: rijst'
          : 'Mon: pasta\nTue: soup\nWed: rice',
      isShared: true,
    );
  }
}
