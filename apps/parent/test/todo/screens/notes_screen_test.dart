import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:parent/l10n/generated/app_localizations.dart';
import 'package:parent/todo/screens/notes_screen.dart';
import 'package:parent/todo/services/note_repository.dart';

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
  testWidgets(
    'NotesScreen can toggle partner pairing without creating multiple tickers',
    (tester) async {
      await tester.runAsync(() async {
        final db = createTestDatabase();
        final repo = NoteRepository(db: db);

        await tester.pumpWidget(_app(repo: repo, partnerPaired: false));
        await tester.pump();
        expect(find.byType(TabBar), findsNothing);

        await tester.pumpWidget(_app(repo: repo, partnerPaired: true));
        await tester.pump();
        expect(find.byType(TabBar), findsOneWidget);
        expect(find.text('Private'), findsOneWidget);
        expect(find.text('Shared'), findsOneWidget);

        await tester.pumpWidget(_app(repo: repo, partnerPaired: false));
        await tester.pump();
        expect(find.byType(TabBar), findsNothing);

        await tester.pumpWidget(_app(repo: repo, partnerPaired: true));
        await tester.pump();
        expect(find.byType(TabBar), findsOneWidget);

        await tester.pumpWidget(const SizedBox.shrink());
        await db.close();
      });
    },
  );
}
