import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:link/l10n/generated/app_localizations.dart';
import 'package:link/todo/screens/notes_screen.dart';
import 'package:link/todo/services/note_repository.dart';

import '../../helpers/test_database.dart';

Widget _app({required NoteRepository repo, required bool hasOtherLinkMembers}) {
  return MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    locale: const Locale('en'),
    home: NotesScreen(repo: repo, hasOtherLinkMembers: hasOtherLinkMembers),
  );
}

void main() {
  testWidgets('NotesScreen lists private and shared in one view without tabs', (
    tester,
  ) async {
    await tester.runAsync(() async {
      final db = createTestDatabase();
      final repo = NoteRepository(db: db);

      await tester.pumpWidget(_app(repo: repo, hasOtherLinkMembers: true));
      await tester.pump();
      await tester.pumpAndSettle();
      expect(find.byType(TabBar), findsNothing);
      expect(find.text('No notes'), findsOneWidget);
      expect(find.byType(FloatingActionButton), findsNothing);
      expect(find.byTooltip('New note'), findsOneWidget);
      expect(find.text('New note…'), findsOneWidget);

      await repo.insert(title: 'Mine', isShared: false);
      await repo.insert(title: 'Ours', isShared: true);
      await tester.pumpAndSettle();

      expect(find.byType(TabBar), findsNothing);
      expect(find.text('Private'), findsOneWidget);
      expect(find.text('Shared'), findsOneWidget);
      expect(find.text('Mine'), findsOneWidget);
      expect(find.text('Ours'), findsOneWidget);

      await tester.pumpWidget(const SizedBox.shrink());
      await db.close();
    });
  });

  testWidgets('NotesScreen quick-add creates a note from the bottom bar', (
    tester,
  ) async {
    await tester.runAsync(() async {
      final db = createTestDatabase();
      final repo = NoteRepository(db: db);

      await tester.pumpWidget(_app(repo: repo, hasOtherLinkMembers: false));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'Quick title');
      await tester.pump();
      await tester.tap(find.byKey(const Key('note-quick-add-submit')));
      await tester.pump();
      await Future<void>.delayed(const Duration(milliseconds: 100));
      await tester.pumpAndSettle();

      final notes = await repo.watchAll().first;
      expect(notes.map((n) => n.title), contains('Quick title'));
      expect(find.text('Quick title'), findsOneWidget);

      await tester.pumpWidget(const SizedBox.shrink());
      await db.close();
    });
  });

  testWidgets('NotesScreen groups by category within private/shared', (
    tester,
  ) async {
    await tester.runAsync(() async {
      final db = createTestDatabase();
      final repo = NoteRepository(db: db);

      await repo.insert(title: 'Groceries', isShared: false, category: 'Home');
      await repo.insert(title: 'Invoice', isShared: false, category: 'Work');
      await repo.insert(title: 'Shared plan', isShared: true, category: 'Work');

      await tester.pumpWidget(_app(repo: repo, hasOtherLinkMembers: true));
      await tester.pumpAndSettle();

      expect(find.text('Private'), findsOneWidget);
      expect(find.text('Shared'), findsOneWidget);
      expect(find.text('HOME'), findsOneWidget);
      expect(find.text('WORK'), findsNWidgets(2));
      expect(find.text('Groceries'), findsOneWidget);
      expect(find.text('Invoice'), findsOneWidget);
      expect(find.text('Shared plan'), findsOneWidget);

      await tester.pumpWidget(const SizedBox.shrink());
      await db.close();
    });
  });
}
