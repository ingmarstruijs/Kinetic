import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:adult/l10n/generated/app_localizations.dart';
import 'package:adult/todo/screens/notes_screen.dart';
import 'package:adult/todo/services/note_repository.dart';

import '../../helpers/test_database.dart';

Widget _app({required NoteRepository repo, required bool partnerPaired}) {
  return MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    locale: const Locale('en'),
    home: NotesScreen(repo: repo, partnerPaired: partnerPaired),
  );
}

void main() {
  testWidgets('NotesScreen lists private and shared in one view without tabs', (
    tester,
  ) async {
    await tester.runAsync(() async {
      final db = createTestDatabase();
      final repo = NoteRepository(db: db);

      await tester.pumpWidget(_app(repo: repo, partnerPaired: true));
      await tester.pump();
      await tester.pumpAndSettle();
      expect(find.byType(TabBar), findsNothing);
      expect(find.text('No notes'), findsOneWidget);

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
}
