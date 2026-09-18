import 'package:flutter_test/flutter_test.dart';
import 'package:kinetic_webdav/kinetic_webdav.dart';
import 'package:link/debug/demo_scenarios.dart';
import 'package:link/debug/demo_session.dart';
import 'package:link/partner/services/partner_proposal_repository.dart';
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
        proposalRepo: PartnerProposalRepository(
          db: db,
          todoRepository: todoRepo,
        ),
      );

      await loader.apply(DemoScenario.fullHouse, dutch: true);

      final tasks = await todoRepo.watchAllTasks().first;
      final notes = await NoteRepository(db: db).watchAll().first;
      final suggestions = await AiSuggestionRepository(db).watchPending().first;
      final inbox = await PartnerProposalRepository(
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
      expect(DemoSession.instance.partnerPaired, isTrue);
      expect(DemoSession.instance.kids, hasLength(2));
      expect(DemoSession.instance.kidTasks, isNotEmpty);
      expect(DemoSession.instance.roster, isNotNull);
      expect(
        DemoSession.instance.roster!.otherLinkMembers(DemoSession.linkId),
        hasLength(2),
      );
      expect(
        DemoSession.instance.otherLinkMembers.map((m) => m.id),
        [DemoSession.partnerId, DemoSession.secondPartnerId],
      );
      expect(DemoSession.instance.presence, isNotEmpty);
      expect(
        DemoSession.instance.kidTasks.any(
          (t) =>
              t.status == ICalTaskStatus.inProcess &&
              (t.description ?? '').contains(
                'xKineticVerifierLinkId:${DemoSession.partnerId}',
              ),
        ),
        isTrue,
      );
      expect(
        DemoSession.instance.kidTasks.any(
          (t) =>
              t.status == ICalTaskStatus.inProcess &&
              (t.description ?? '').contains(
                'xKineticVerifierLinkId:${DemoSession.secondPartnerId}',
              ),
        ),
        isTrue,
      );

      await loader.apply(DemoScenario.empty, dutch: true);
      expect(await todoRepo.watchAllTasks().first, isEmpty);
      expect(DemoSession.instance.active, isFalse);
      expect(DemoSession.instance.roster, isNull);
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
      proposalRepo: PartnerProposalRepository(db: db, todoRepository: todoRepo),
    );

    await loader.apply(DemoScenario.family, dutch: false);

    expect(DemoSession.instance.partnerPaired, isTrue);
    expect(DemoSession.instance.kids, hasLength(2));
    expect(DemoSession.instance.otherLinkMembers, hasLength(2));
    expect(
      DemoSession.instance.otherLinkMembers.map((m) => m.name),
      ['Alex', 'Sam'],
    );
    expect(await NoteRepository(db: db).watchAll().first, isNotEmpty);
    expect(
      await PartnerProposalRepository(
        db: db,
        todoRepository: todoRepo,
      ).watchPending(myLinkId: DemoSession.linkId).first,
      isNotEmpty,
    );
  });

  test('notes scenario enables partner overlay for shared notes', () async {
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
      proposalRepo: PartnerProposalRepository(db: db, todoRepository: todoRepo),
    );

    await loader.apply(DemoScenario.notes, dutch: true);

    final notes = await NoteRepository(db: db).watchAll().first;
    expect(notes, isNotEmpty);
    expect(notes.any((n) => n.isShared), isTrue);
    expect(DemoSession.instance.active, isTrue);
    expect(DemoSession.instance.partnerPaired, isTrue);
    expect(DemoSession.instance.otherLinkMembers, isNotEmpty);
  });

  test('accept and reject update overlay kid tasks', () {
    addTearDown(DemoSession.instance.clear);
    final now = DateTime.utc(2026, 9, 16);
    DemoSession.instance.apply(
      partnerPaired: true,
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
      partnerPaired: true,
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
      partnerPaired: false,
      kids: [EnrolledKid(id: 'mees', name: 'Mees', enrolledAt: now)],
      kidTasks: [
        ICalTask(uid: 'keep', summary: 'Keep', createdAt: now, updatedAt: now),
        ICalTask(uid: 'drop', summary: 'Drop', createdAt: now, updatedAt: now),
      ],
    );
    DemoSession.instance.removeKidTask('drop');
    expect(DemoSession.instance.kidTasks.map((t) => t.uid), ['keep']);
  });
}
