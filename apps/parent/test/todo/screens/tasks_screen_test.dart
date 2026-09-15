import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:parent/l10n/generated/app_localizations.dart';
import 'package:parent/todo/models/ai_suggestion.dart';
import 'package:parent/todo/screens/tasks_screen.dart';
import 'package:parent/todo/services/ai_suggestion_repository.dart';
import 'package:parent/todo/services/todo_repository.dart';
import 'package:parent/todo/widgets/suggestions_panel.dart';

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

  testWidgets('SuggestionsPanel shows self suggestion as a tappable row', (
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

      await tester.tap(find.text('Bring shirts'));
      await Future<void>.delayed(const Duration(milliseconds: 50));
      await tester.pump();

      final open = await todoRepo.watchOpenTasks().first;
      expect(open.map((t) => t.title), contains('Bring shirts'));

      await tester.pumpWidget(const SizedBox.shrink());
      await db.close();
    });
  });
}
