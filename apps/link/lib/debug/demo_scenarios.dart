import 'package:kinetic_webdav/kinetic_webdav.dart';
import 'package:uuid/uuid.dart';

import '../db/app_database.dart';
import '../family/proposals/link_member_proposal_repository.dart';
import '../settings/models/enrolled_kid.dart';
import '../todo/models/ai_suggestion.dart';
import '../todo/models/enums.dart';
import '../todo/services/ai_suggestion_repository.dart';
import '../todo/services/note_repository.dart';
import '../todo/services/todo_repository.dart';
import 'demo_session.dart';

enum DemoScenario {
  empty,
  busyDay,
  suggestions,
  kids,
  notes,
  family,
  fullHouse,
}

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
    subtitleEn: 'Overdue, today, Test1/2 (no Health), categories',
    subtitleNl: 'Te laat, vandaag, Test1/2 (geen Health), categorieën',
  ),
  DemoScenarioInfo(
    id: DemoScenario.suggestions,
    titleEn: 'Suggestions + ambient',
    titleNl: 'Suggesties + ambient',
    subtitleEn: 'Inbox, load-balance, presence/load chips',
    subtitleNl: 'Inbox, load-balance, presence/load-chips',
  ),
  DemoScenarioInfo(
    id: DemoScenario.kids,
    titleEn: 'Kids + enrollment',
    titleNl: 'Kinderen + koppelen',
    subtitleEn: 'Active kids, draft “waiting”, XP on/off, verify',
    subtitleNl: 'Actieve kids, draft “wacht”, XP aan/uit, verifieren',
  ),
  DemoScenarioInfo(
    id: DemoScenario.notes,
    titleEn: 'Notes privacy',
    titleNl: 'Notities privacy',
    subtitleEn: 'Unlock gate, local-only, note↔task link, shared',
    subtitleNl: 'Unlock, alleen-dit-apparaat, note↔taak, gedeeld',
  ),
  DemoScenarioInfo(
    id: DemoScenario.family,
    titleEn: 'Family household',
    titleNl: 'Gezin',
    subtitleEn: 'Alex + Sam, draft kid, ambient load, proposals',
    subtitleNl: 'Alex + Sam, draft-kind, ambient load, voorstellen',
  ),
  DemoScenarioInfo(
    id: DemoScenario.fullHouse,
    titleEn: 'Full house',
    titleNl: 'Vol huis',
    subtitleEn: 'Busy + privacy notes + kids draft + ambient',
    subtitleNl: 'Druk + privacy-notities + kids draft + ambient',
  ),
];

class DemoScenarioLoader {
  DemoScenarioLoader({
    required AppDatabase db,
    required TodoRepository todoRepo,
    required NoteRepository noteRepo,
    required AiSuggestionRepository suggestionRepo,
    required LinkMemberProposalRepository proposalRepo,
  }) : _db = db,
       _todoRepo = todoRepo,
       _noteRepo = noteRepo,
       _suggestionRepo = suggestionRepo,
       _proposalRepo = proposalRepo;

  final AppDatabase _db;
  final TodoRepository _todoRepo;
  final NoteRepository _noteRepo;
  final AiSuggestionRepository _suggestionRepo;
  final LinkMemberProposalRepository _proposalRepo;

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
        _setFamily(
          hasOtherLinkMembers: true,
          kids: const [],
          withLoadMetrics: true,
        );
      case DemoScenario.kids:
        await _seedBusyDay(dutch, compact: true);
        _setFamily(
          hasOtherLinkMembers: false,
          kids: _demoKids(includeDraft: true),
          withLoadMetrics: false,
        );
      case DemoScenario.notes:
        await _seedNotes(dutch, withPrivacyExtras: true);
        _setFamily(hasOtherLinkMembers: true, kids: const []);
      case DemoScenario.family:
        await _seedSuggestions(dutch);
        await _seedNotes(dutch, withPrivacyExtras: true);
        _setFamily(
          hasOtherLinkMembers: true,
          kids: _demoKids(includeDraft: true),
          withLoadMetrics: true,
        );
      case DemoScenario.fullHouse:
        await _seedBusyDay(dutch);
        await _seedSuggestions(dutch);
        await _seedNotes(dutch, withPrivacyExtras: true);
        _setFamily(
          hasOtherLinkMembers: true,
          kids: _demoKids(includeDraft: true),
          withLoadMetrics: true,
        );
    }
  }

  Future<void> _clearPersonalData() async {
    await _db.delete(_db.personalSubtasks).go();
    await _db.delete(_db.personalTasks).go();
    await _db.delete(_db.personalNotes).go();
    await _db.delete(_db.linkMemberProposals).go();
    await _db.delete(_db.aiSuggestions).go();
  }

  void _setFamily({
    required bool hasOtherLinkMembers,
    required List<EnrolledKid> kids,
    bool withLoadMetrics = false,
  }) {
    final now = DateTime.now().toUtc();
    final roster = _demoRoster(
      hasOtherLinkMembers: hasOtherLinkMembers,
      kids: kids,
      now: now,
    );
    DemoSession.instance.apply(
      hasOtherLinkMembers: hasOtherLinkMembers,
      kids: kids,
      kidTasks: kids.where((k) => k.isActive).isEmpty
          ? const []
          : _demoKidTasks(
              kids.where((k) => k.isActive).toList(),
              secondLinkMember: hasOtherLinkMembers,
            ),
      roster: roster,
      presence: _demoPresence(
        now,
        hasOtherLinkMembers: hasOtherLinkMembers,
        kids: kids,
      ),
      loadMetrics: withLoadMetrics && hasOtherLinkMembers
          ? _demoLoadMetrics(now)
          : const [],
    );
  }

  FamilyRoster _demoRoster({
    required bool hasOtherLinkMembers,
    required List<EnrolledKid> kids,
    required DateTime now,
  }) {
    final joined = now.subtract(const Duration(days: 90));
    final self = FamilyLinkMember(
      id: DemoSession.linkId,
      displayName: DemoSession.selfDisplayName,
      kidsParticipation: true,
      joinedAt: joined,
      updatedAt: now,
    );
    final linkMembers = <FamilyLinkMember>[
      self,
      if (hasOtherLinkMembers)
        for (final (i, member) in DemoSession.otherDemoMembers.indexed)
          FamilyLinkMember(
            id: member.id,
            displayName: member.name,
            kidsParticipation: i == 0, // Alex verifies kids; Sam opted out.
            joinedAt: joined.add(Duration(days: 2 + i)),
            updatedAt: now,
          ),
    ];
    return FamilyRoster(
      linkMembers: linkMembers,
      kids: [
        for (final k in kids)
          FamilyKidMember(
            id: k.id,
            name: k.name,
            enrolledAt: k.enrolledAt,
            xpEnabled: k.xpEnabled,
            updatedAt: k.enrolledAt,
            isActive: k.isActive,
          ),
      ],
      updatedAt: now,
    );
  }

  List<PresenceInfo> _demoPresence(
    DateTime now, {
    required bool hasOtherLinkMembers,
    required List<EnrolledKid> kids,
  }) {
    final list = <PresenceInfo>[
      PresenceInfo(
        deviceId: DemoSession.linkId,
        deviceType: 'link',
        displayName: DemoSession.selfDisplayName,
        lastSeen: now,
      ),
    ];
    if (hasOtherLinkMembers) {
      list.addAll([
        PresenceInfo(
          deviceId: DemoSession.linkMemberId,
          deviceType: 'link',
          displayName: DemoSession.linkMemberDisplayName,
          lastSeen: now.subtract(const Duration(minutes: 12)),
        ),
        PresenceInfo(
          deviceId: DemoSession.secondLinkMemberId,
          deviceType: 'link',
          displayName: DemoSession.secondLinkMemberDisplayName,
          // Stale-ish for ambient chip contrast.
          lastSeen: now.subtract(const Duration(days: 8)),
        ),
      ]);
    }
    // Only active kids with a heartbeat show as connected.
    for (final kid in kids.where((k) => k.isActive)) {
      if (kid.id == 'demo-mees') {
        list.add(
          PresenceInfo(
            deviceId: kid.id,
            deviceType: 'kid',
            displayName: kid.name,
            lastSeen: now.subtract(const Duration(hours: 2)),
          ),
        );
      }
      // Fien (and others): no presence → not connected in settings/ambient.
    }
    return list;
  }

  List<LoadMetrics> _demoLoadMetrics(DateTime now) => [
        LoadMetrics(
          linkId: DemoSession.linkMemberId,
          openByCategory: const {'household': 5, 'admin': 1, 'health': 0},
          updatedAt: now.subtract(const Duration(minutes: 40)),
        ),
        LoadMetrics(
          linkId: DemoSession.secondLinkMemberId,
          openByCategory: const {'household': 1, 'other': 2},
          updatedAt: now.subtract(const Duration(hours: 3)),
        ),
      ];

  List<EnrolledKid> _demoKids({bool includeDraft = false}) {
    final enrolledAt = DateTime.now().toUtc().subtract(
      const Duration(days: 40),
    );
    final kids = <EnrolledKid>[
      EnrolledKid(
        id: 'demo-mees',
        name: 'Mees',
        enrolledAt: enrolledAt,
        isActive: true,
      ),
      // Contrast: XP & goals off so the settings toggle is visible in demos.
      EnrolledKid(
        id: 'demo-fien',
        name: 'Fien',
        enrolledAt: enrolledAt,
        xpEnabled: false,
        isActive: true,
      ),
    ];
    if (includeDraft) {
      kids.add(
        EnrolledKid(
          id: 'demo-sara',
          name: 'Sara',
          enrolledAt: DateTime.now().toUtc().subtract(const Duration(hours: 2)),
          isActive: false,
        ),
      );
    }
    return kids;
  }

  /// When [otherLinkMembers] is true, adds missions verified by Alex and by Sam
  /// so the kids-panel verifier filter is visible with multiple Link members.
  List<ICalTask> _demoKidTasks(
    List<EnrolledKid> kids, {
    bool secondLinkMember = false,
  }) {
    final now = DateTime.now().toUtc();
    final todayLocal = DateTime.now();
    final today = DateTime(todayLocal.year, todayLocal.month, todayLocal.day);
    ICalTask chore({
      required String summary,
      required String kidId,
      ICalTaskStatus status = ICalTaskStatus.needsAction,
      int xp = 10,
      String? verifierLinkId,
      DateTime? dueAt,
      String? rrule,
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
        dueAt: dueAt?.toUtc(),
        rrule: rrule,
      );
    }

    final mees = kids.first.id;
    final fien = kids.length > 1 ? kids[1].id : kids.first.id;
    return [
      chore(
        summary: 'Shirts in the hamper',
        kidId: mees,
        dueAt: today.add(const Duration(hours: 18)),
      ),
      chore(summary: 'Brush teeth', kidId: mees),
      chore(
        summary: 'Make bed',
        kidId: mees,
        status: ICalTaskStatus.completed,
        xp: 15,
        dueAt: today.subtract(const Duration(days: 1)),
      ),
      // Weekly routine still open with RRULE (routines v1).
      chore(
        summary: 'Empty dishwasher',
        kidId: mees,
        dueAt: today.add(const Duration(days: 2)),
        rrule: 'FREQ=WEEKLY;BYDAY=WE',
      ),
      chore(summary: 'Tidy room', kidId: fien),
      // Awaiting verification by this device — accept/reject are offered.
      chore(
        summary: 'Walk the dog',
        kidId: mees,
        status: ICalTaskStatus.inProcess,
        verifierLinkId: DemoSession.linkId,
      ),
      // Alex is the designated verifier — this device only sees pending.
      if (secondLinkMember)
        chore(
          summary: 'Water the plants',
          kidId: fien,
          status: ICalTaskStatus.inProcess,
          verifierLinkId: DemoSession.linkMemberId,
        ),
      // Sam is the designated verifier — also pending-only for this device.
      if (secondLinkMember)
        chore(
          summary: 'Feed the cat',
          kidId: mees,
          status: ICalTaskStatus.inProcess,
          verifierLinkId: DemoSession.secondLinkMemberId,
        ),
      // Unassigned verifier — any participating link member may accept.
      ICalTask(
        uid: const Uuid().v4(),
        summary: 'Set the table',
        description: 'xKineticXpReward:10;xKineticTargetKidId:$mees',
        status: ICalTaskStatus.inProcess,
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
    // Heuristics false positives — should stay Other / not Health categorize.
    await add(en: 'Test1', nl: 'Test1');
    await add(en: 'Test2', nl: 'Test2');
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
            ? 'Peer-load: Alex heeft 5 huishouden-open; jij bent zwaarder.'
            : 'Peer load: Alex has 5 open household; you are heavier.',
        dedupeKey: 'demo-load-balance',
      ),
    );

    await _proposalRepo.createManualProposal(
      myLinkId: DemoSession.linkMemberId,
      taskTitle: dutch ? 'Hond uitlaten' : 'Walk the dog',
      taskNotes: dutch ? 'Graag voor 18:00' : 'Before 18:00 if you can',
      taskPriority: TaskPriority.medium,
      taskDueDate: due.toUtc(),
    );
    await _proposalRepo.createManualProposal(
      myLinkId: DemoSession.secondLinkMemberId,
      taskTitle: dutch ? 'Pakket ophalen' : 'Pick up the parcel',
      taskNotes: dutch ? 'Bij de buurvrouw' : 'At the neighbour\'s',
      taskPriority: TaskPriority.low,
      taskDueDate: due.toUtc(),
    );
  }

  Future<void> _seedNotes(
    bool dutch, {
    bool withPrivacyExtras = false,
  }) async {
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
      sharedMemberIds: [
        for (final m in DemoSession.otherDemoMembers) m.id,
      ],
    );

    if (!withPrivacyExtras) return;

    final linkedTask = await _todoRepo.createTask(
      title: dutch ? 'Cadeau kopen' : 'Buy gift',
      customCategory: dutch ? 'Huishouden' : 'Household',
    );
    await _noteRepo.insert(
      title: dutch ? 'Cadeaulijst (gekoppeld)' : 'Gift list (linked)',
      body: dutch
          ? 'Ideeën voor Mees — gekoppeld aan de taak.'
          : 'Ideas for Mees — linked to the task.',
      linkedTaskIds: [linkedTask.id],
    );
    await _noteRepo.insert(
      title: dutch ? 'Alleen dit apparaat' : 'This device only',
      body: dutch
          ? 'Lokale notitie — mag nooit naar WebDAV.'
          : 'Local-only note — must never PUT to WebDAV.',
      isLocalOnly: true,
    );
    await _noteRepo.insert(
      title: dutch ? 'Vereist ontgrendelen' : 'Require unlock',
      body: dutch
          ? 'Gevoelige tekst — alleen lokaal gated; body sync’t wél.'
          : 'Sensitive text — local biometric gate; body still syncs.',
      isContentHidden: true,
    );
  }
}
