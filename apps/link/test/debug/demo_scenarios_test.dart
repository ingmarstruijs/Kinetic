import 'package:flutter_test/flutter_test.dart';
import 'package:kinetic_webdav/kinetic_webdav.dart';
import 'package:link/debug/demo_scenarios.dart';
import 'package:link/debug/demo_session.dart';
import 'package:link/family/proposals/link_member_proposal_repository.dart';
import 'package:link/settings/models/enrolled_kid.dart';
import 'package:link/todo/services/ai_suggestion_repository.dart';
import 'package:link/todo/services/note_repository.dart';
import 'package:link/todo/services/todo_repository.dart';

import '../helpers/test_database.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'full house scenario seeds tasks, notes, suggestions and kids overlay',
    () async {
      final db = createTestDatabase();
      addTearDown(db.close);
      final todoRepo = TodoRepository(db: db);
      final loader = DemoScenarioLoader(
        db: db,
        todoRepo: todoRepo,
        noteRepo: NoteRepository(db: db),
        suggestionRepo: AiSuggestionRepository(db),
        proposalRepo: LinkMemberProposalRepository(
          db: db,
          todoRepository: todoRepo,
        ),
      );

      await loader.apply(DemoScenario.fullHouse, dutch: true);

      final tasks = await todoRepo.watchAllTasks().first;
      final notes = await NoteRepository(db: db).watchAll().first;
      final suggestions = await AiSuggestionRepository(db).watchPending().first;
      final inbox = await LinkMemberProposalRepository(
        db: db,
        todoRepository: todoRepo,
      ).watchPending(myLinkId: DemoSession.linkId).first;

      expect(tasks, isNotEmpty);
      expect(notes, isNotEmpty);
      expect(notes.any((n) => n.isShared), isTrue);
      expect(
        notes.firstWhere((n) => n.isShared).sharedMemberIds,
        [for (final m in DemoSession.otherDemoMembers) m.id],
      );
      expect(suggestions.length, greaterThanOrEqualTo(2));
      expect(inbox, hasLength(2));
      expect(DemoSession.instance.active, isTrue);
      expect(DemoSession.instance.hasOtherLinkMembers, isTrue);
      expect(DemoSession.instance.kids, hasLength(3));
      expect(
        DemoSession.instance.kids.where((k) => !k.isActive),
        hasLength(1),
      );
      expect(DemoSession.instance.loadMetrics, isNotEmpty);
      expect(DemoSession.instance.kidTasks, isNotEmpty);
      expect(
        DemoSession.instance.kidTasks.any((t) => t.rrule != null),
        isTrue,
      );
      expect(DemoSession.instance.roster, isNotNull);
      expect(
        DemoSession.instance.roster!.otherLinkMembers(DemoSession.linkId),
        hasLength(2),
      );
      expect(
        DemoSession.instance.otherLinkMembers.map((m) => m.id),
        [DemoSession.linkMemberId, DemoSession.secondLinkMemberId],
      );
      expect(DemoSession.instance.presence, isNotEmpty);
      expect(
        DemoSession.instance.kidTasks.any(
          (t) =>
              t.status == ICalTaskStatus.inProcess &&
              (t.description ?? '').contains(
                'xKineticVerifierLinkId:${DemoSession.linkMemberId}',
              ),
        ),
        isTrue,
      );
      expect(
        DemoSession.instance.kidTasks.any(
          (t) =>
              t.status == ICalTaskStatus.inProcess &&
              (t.description ?? '').contains(
                'xKineticVerifierLinkId:${DemoSession.secondLinkMemberId}',
              ),
        ),
        isTrue,
      );

      await loader.apply(DemoScenario.empty, dutch: true);
      expect(await todoRepo.watchAllTasks().first, isEmpty);
      expect(DemoSession.instance.active, isTrue);
      expect(DemoSession.instance.roster, isNull);
      expect(DemoSession.instance.kids, isEmpty);
    },
  );

  test('family scenario seeds roster without requiring a busy day', () async {
    final db = createTestDatabase();
    addTearDown(() async {
      DemoSession.instance.clear();
      await db.close();
    });
    final todoRepo = TodoRepository(db: db);
    final loader = DemoScenarioLoader(
      db: db,
      todoRepo: todoRepo,
      noteRepo: NoteRepository(db: db),
      suggestionRepo: AiSuggestionRepository(db),
      proposalRepo: LinkMemberProposalRepository(db: db, todoRepository: todoRepo),
    );

    await loader.apply(DemoScenario.family, dutch: false);

    expect(DemoSession.instance.hasOtherLinkMembers, isTrue);
    expect(DemoSession.instance.kids, hasLength(3));
    expect(DemoSession.instance.kids.any((k) => !k.isActive), isTrue);
    expect(DemoSession.instance.loadMetrics, isNotEmpty);
    expect(DemoSession.instance.otherLinkMembers, hasLength(2));
    final notes = await NoteRepository(db: db).watchAll().first;
    expect(notes.any((n) => n.isLocalOnly), isTrue);
    expect(notes.any((n) => n.isContentHidden), isTrue);
    expect(
      notes.any((n) => (n.linkedTaskIds ?? const []).isNotEmpty),
      isTrue,
    );
    expect(
      await LinkMemberProposalRepository(
        db: db,
        todoRepository: todoRepo,
      ).watchPending(myLinkId: DemoSession.linkId).first,
      isNotEmpty,
    );
  });

  test('notes scenario seeds privacy variants and family overlay', () async {
    final db = createTestDatabase();
    addTearDown(() async {
      DemoSession.instance.clear();
      await db.close();
    });
    final todoRepo = TodoRepository(db: db);
    final loader = DemoScenarioLoader(
      db: db,
      todoRepo: todoRepo,
      noteRepo: NoteRepository(db: db),
      suggestionRepo: AiSuggestionRepository(db),
      proposalRepo: LinkMemberProposalRepository(db: db, todoRepository: todoRepo),
    );

    await loader.apply(DemoScenario.notes, dutch: true);

    final notes = await NoteRepository(db: db).watchAll().first;
    expect(notes, isNotEmpty);
    expect(notes.any((n) => n.isShared), isTrue);
    expect(notes.any((n) => n.isLocalOnly), isTrue);
    expect(notes.any((n) => n.isContentHidden), isTrue);
    expect(
      notes.any((n) => (n.linkedTaskIds ?? const []).isNotEmpty),
      isTrue,
    );
    expect(DemoSession.instance.active, isTrue);
    expect(DemoSession.instance.hasOtherLinkMembers, isTrue);
    expect(DemoSession.instance.otherLinkMembers, isNotEmpty);
  });

  test('suggestions scenario seeds ambient load metrics', () async {
    final db = createTestDatabase();
    addTearDown(() async {
      DemoSession.instance.clear();
      await db.close();
    });
    final todoRepo = TodoRepository(db: db);
    final loader = DemoScenarioLoader(
      db: db,
      todoRepo: todoRepo,
      noteRepo: NoteRepository(db: db),
      suggestionRepo: AiSuggestionRepository(db),
      proposalRepo: LinkMemberProposalRepository(db: db, todoRepository: todoRepo),
    );

    await loader.apply(DemoScenario.suggestions, dutch: false);
    expect(DemoSession.instance.loadMetrics, isNotEmpty);
    expect(DemoSession.instance.presence, isNotEmpty);
    expect(await todoRepo.watchAllTasks().first, isNotEmpty);
  });

  test('accept and reject update overlay kid tasks', () {
    addTearDown(DemoSession.instance.clear);
    final now = DateTime.utc(2026, 9, 16);
    DemoSession.instance.apply(
      hasOtherLinkMembers: true,
      kids: [EnrolledKid(id: 'mees', name: 'Mees', enrolledAt: now)],
      kidTasks: [
        ICalTask(
          uid: 'pending',
          summary: 'Walk',
          status: ICalTaskStatus.inProcess,
          createdAt: now,
          updatedAt: now,
        ),
      ],
    );

    DemoSession.instance.acceptKidTask('pending');
    expect(
      DemoSession.instance.kidTasks.single.status,
      ICalTaskStatus.completed,
    );

    DemoSession.instance.apply(
      hasOtherLinkMembers: true,
      kids: [EnrolledKid(id: 'mees', name: 'Mees', enrolledAt: now)],
      kidTasks: [
        ICalTask(
          uid: 'pending',
          summary: 'Walk',
          status: ICalTaskStatus.inProcess,
          createdAt: now,
          updatedAt: now,
        ),
      ],
    );
    DemoSession.instance.rejectKidTask('pending');
    expect(
      DemoSession.instance.kidTasks.single.status,
      ICalTaskStatus.needsAction,
    );
  });

  test('removeKidTask drops an overlay assignment', () {
    addTearDown(DemoSession.instance.clear);
    final now = DateTime.utc(2026, 9, 16);
    DemoSession.instance.apply(
      hasOtherLinkMembers: false,
      kids: [EnrolledKid(id: 'mees', name: 'Mees', enrolledAt: now)],
      kidTasks: [
        ICalTask(uid: 'keep', summary: 'Keep', createdAt: now, updatedAt: now),
        ICalTask(uid: 'drop', summary: 'Drop', createdAt: now, updatedAt: now),
      ],
    );
    DemoSession.instance.removeKidTask('drop');
    expect(DemoSession.instance.kidTasks.map((t) => t.uid), ['keep']);
  });

  test('exitDemoMode clears seeded rows and deactivates session', () async {
    final db = createTestDatabase();
    addTearDown(() async {
      DemoSession.instance.clear();
      await db.close();
    });
    final todoRepo = TodoRepository(db: db);
    final loader = DemoScenarioLoader(
      db: db,
      todoRepo: todoRepo,
      noteRepo: NoteRepository(db: db),
      suggestionRepo: AiSuggestionRepository(db),
      proposalRepo: LinkMemberProposalRepository(
        db: db,
        todoRepository: todoRepo,
      ),
    );

    await loader.apply(DemoScenario.busyDay, dutch: false);
    expect(DemoSession.instance.active, isTrue);
    expect(await todoRepo.watchAllTasks().first, isNotEmpty);

    await DemoScenarioLoader.exitDemoMode(db);
    expect(DemoSession.instance.active, isFalse);
    expect(DemoSession.instance.kids, isEmpty);
    expect(await todoRepo.watchAllTasks().first, isEmpty);
    expect(await NoteRepository(db: db).watchAll().first, isEmpty);
  });
}
