import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kinetic_webdav/kinetic_webdav.dart';
import 'package:link/l10n/generated/app_localizations.dart';
import 'package:link/settings/models/enrolled_kid.dart';
import 'package:link/sync/webdav_config_repository.dart';
import 'package:link/todo/models/ai_suggestion.dart';
import 'package:link/todo/screens/tasks_screen.dart';
import 'package:link/todo/services/ai_suggestion_repository.dart';
import 'package:link/todo/services/todo_repository.dart';
import 'package:link/todo/widgets/suggestions_panel.dart';

import '../../helpers/test_database.dart';

Widget _app(Widget home) {
  return MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    locale: const Locale('en'),
    home: home,
  );
}

void main() {
  testWidgets('TasksScreen has no tab bar without kids', (tester) async {
    await tester.runAsync(() async {
      final db = createTestDatabase();
      final repo = TodoRepository(db: db);

      await tester.pumpWidget(_app(TasksScreen(repo: repo)));
      await tester.pump();

      expect(find.byType(TabBar), findsNothing);
      expect(find.text('Private'), findsNothing);
      expect(find.text('Suggestions'), findsNothing);
      expect(find.text('Kids'), findsNothing);
      expect(find.text('Tasks'), findsOneWidget);

      await tester.pumpWidget(const SizedBox.shrink());
      await db.close();
    });
  });

  testWidgets('TasksScreen still has no tabs when kids are enrolled', (
    tester,
  ) async {
    await tester.runAsync(() async {
      final db = createTestDatabase();
      final repo = TodoRepository(db: db);

      await tester.pumpWidget(
        _app(TasksScreen(repo: repo, enrolledKidsCount: 2)),
      );
      await tester.pump();

      expect(find.byType(TabBar), findsNothing);
      expect(find.text('Kids'), findsNothing);

      await tester.pumpWidget(const SizedBox.shrink());
      await db.close();
    });
  });

  testWidgets('SuggestionsPanel accepts a self suggestion via Accept', (
    tester,
  ) async {
    await tester.runAsync(() async {
      final db = createTestDatabase();
      final todoRepo = TodoRepository(db: db);
      final suggestionRepo = AiSuggestionRepository(db);
      await suggestionRepo.upsertSuggestion(
        AiSuggestion.create(
          title: 'Bring shirts',
          reason: SuggestionReason.habit,
          suggestedDueDate: DateTime(2026, 9, 17, 17),
        ),
      );

      await tester.pumpWidget(
        _app(
          Scaffold(
            body: SuggestionsPanel(
              suggestionRepo: suggestionRepo,
              todoRepo: todoRepo,
            ),
          ),
        ),
      );
      await tester.pump();
      await Future<void>.delayed(const Duration(milliseconds: 50));
      await tester.pump();

      expect(find.text('SUGGESTIONS'), findsOneWidget);
      expect(find.text('Bring shirts'), findsOneWidget);
      expect(find.text('For you'), findsOneWidget);
      expect(find.text('Decline'), findsOneWidget);
      expect(find.text('Accept'), findsOneWidget);

      await tester.tap(find.text('Accept'));
      await Future<void>.delayed(const Duration(milliseconds: 50));
      await tester.pump();

      final open = await todoRepo.watchOpenTasks().first;
      expect(open.map((t) => t.title), contains('Bring shirts'));
      expect(find.text('SUGGESTIONS'), findsNothing);

      await tester.pumpWidget(const SizedBox.shrink());
      await db.close();
    });
  });

  testWidgets('SuggestionsPanel declines a self suggestion via Decline', (
    tester,
  ) async {
    await tester.runAsync(() async {
      final db = createTestDatabase();
      final todoRepo = TodoRepository(db: db);
      final suggestionRepo = AiSuggestionRepository(db);
      await suggestionRepo.upsertSuggestion(
        AiSuggestion.create(
          title: 'Bring shirts',
          reason: SuggestionReason.habit,
        ),
      );

      await tester.pumpWidget(
        _app(
          Scaffold(
            body: SuggestionsPanel(
              suggestionRepo: suggestionRepo,
              todoRepo: todoRepo,
            ),
          ),
        ),
      );
      await tester.pump();
      await Future<void>.delayed(const Duration(milliseconds: 50));
      await tester.pump();

      await tester.tap(find.text('Decline'));
      await Future<void>.delayed(const Duration(milliseconds: 50));
      await tester.pump();

      expect(find.text('Bring shirts'), findsNothing);
      expect(find.text('SUGGESTIONS'), findsNothing);
      expect(await todoRepo.watchOpenTasks().first, isEmpty);

      await tester.pumpWidget(const SizedBox.shrink());
      await db.close();
    });
  });

  testWidgets('SuggestionsPanel load-balance copy follows Dutch locale', (
    tester,
  ) async {
    await tester.runAsync(() async {
      final db = createTestDatabase();
      final todoRepo = TodoRepository(db: db);
      final suggestionRepo = AiSuggestionRepository(db);
      await suggestionRepo.upsertSuggestion(
        AiSuggestion.create(
          title: 'Can you pick something up this week?',
          reason: SuggestionReason.loadBalance,
          category: 'other',
          relatedTaskIds: const ['a', 'b', 'c', 'd', 'e'],
          explanation:
              'You have 5 open tasks in Other. The suggestion is intentionally generic.',
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('nl'),
          home: Scaffold(
            body: SuggestionsPanel(
              suggestionRepo: suggestionRepo,
              todoRepo: todoRepo,
              hasOtherLinkMembers: true,
            ),
          ),
        ),
      );
      await tester.pump();
      await Future<void>.delayed(const Duration(milliseconds: 50));
      await tester.pump();

      expect(find.text('Kun jij deze week iets oppakken?'), findsOneWidget);
      expect(find.textContaining('5 open taken'), findsOneWidget);
      expect(find.textContaining('Overig'), findsOneWidget);
      expect(find.text('Can you pick something up this week?'), findsNothing);

      await tester.pumpWidget(const SizedBox.shrink());
      await db.close();
    });
  });

  testWidgets(
    'SuggestionsPanel drops a declined family-member suggestion immediately',
    (tester) async {
      await tester.runAsync(() async {
        final db = createTestDatabase();
        final todoRepo = TodoRepository(db: db);
        final suggestionRepo = AiSuggestionRepository(db);
        await suggestionRepo.upsertSuggestion(
          AiSuggestion.create(
            title: 'Can you pick something up this week?',
            reason: SuggestionReason.loadBalance,
            category: 'other',
          ),
        );

        await tester.pumpWidget(
          _app(
            Scaffold(
              body: SuggestionsPanel(
                suggestionRepo: suggestionRepo,
                todoRepo: todoRepo,
                hasOtherLinkMembers: true,
              ),
            ),
          ),
        );
        await tester.pump();
        await Future<void>.delayed(const Duration(milliseconds: 50));
        await tester.pump();

        expect(find.text('Decline'), findsOneWidget);

        await tester.tap(find.text('Decline'));
        await Future<void>.delayed(const Duration(milliseconds: 50));
        await tester.pump();

        expect(find.text('Decline'), findsNothing);
        expect(find.text('SUGGESTIONS'), findsNothing);

        await tester.pumpWidget(const SizedBox.shrink());
        await db.close();
      });
    },
  );

  testWidgets(
    'full-house header scrolls instead of overflowing the quick-add bar',
    (tester) async {
      await tester.runAsync(() async {
        final view = tester.view;
        view.physicalSize = const Size(1080, 1920);
        view.devicePixelRatio = 2.625;
        addTearDown(view.resetPhysicalSize);
        addTearDown(view.resetDevicePixelRatio);

        final db = createTestDatabase();
        final todoRepo = TodoRepository(db: db);
        final suggestionRepo = AiSuggestionRepository(db);
        await todoRepo.createTask(title: 'Dinner');
        await suggestionRepo.upsertSuggestion(
          AiSuggestion.create(
            title: 'Groceries',
            reason: SuggestionReason.habit,
            suggestedDueDate: DateTime(2026, 9, 17, 10),
          ),
        );
        await suggestionRepo.upsertSuggestion(
          AiSuggestion.create(
            title: 'Old chore',
            reason: SuggestionReason.stale,
          ),
        );
        await suggestionRepo.upsertSuggestion(
          AiSuggestion.create(
            title: 'Can you pick something up this week?',
            reason: SuggestionReason.loadBalance,
            category: 'household',
            relatedTaskIds: const ['a', 'b', 'c', 'd', 'e'],
          ),
        );

        final enrolledAt = DateTime.utc(2026, 1, 1);
        await tester.pumpWidget(
          _app(
            TasksScreen(
              repo: todoRepo,
              suggestionRepo: suggestionRepo,
              hasOtherLinkMembers: true,
              configRepo: WebDavConfigRepository(InMemoryKeyValueStore()),
              enrolledKidsCount: 2,
              enrolledKidsOverride: [
                EnrolledKid(id: 'mees', name: 'Mees', enrolledAt: enrolledAt),
                EnrolledKid(id: 'fien', name: 'Fien', enrolledAt: enrolledAt),
              ],
              pullSharedTasks: () async => const [],
            ),
          ),
        );
        await tester.pump();
        await Future<void>.delayed(const Duration(milliseconds: 50));
        await tester.pump();

        expect(tester.takeException(), isNull);
        expect(find.text('SUGGESTIONS'), findsOneWidget);
        expect(find.text('KIDS'), findsOneWidget);
        expect(find.byType(Scrollable), findsWidgets);

        await tester.pumpWidget(const SizedBox.shrink());
        await db.close();
      });
    },
  );
}
