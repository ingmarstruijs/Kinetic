import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:link/l10n/generated/app_localizations.dart';
import 'package:link/todo/services/todo_repository.dart';
import 'package:link/todo/widgets/task_tile.dart';

import '../../helpers/test_database.dart';

void main() {
  testWidgets(
    'completeTaskWithUndo shows brief non-persistent SnackBar with Undo',
    (tester) async {
      await tester.runAsync(() async {
        final db = createTestDatabase();
        final repo = TodoRepository(db: db);
        final task = await repo.createTask(title: 'Take out trash');

        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: const Locale('en'),
            home: Scaffold(
              body: Builder(
                builder: (context) => TextButton(
                  onPressed: () {
                    completeTaskWithUndo(
                      context: context,
                      repo: repo,
                      taskId: task.id,
                    );
                  },
                  child: const Text('mark done'),
                ),
              ),
            ),
          ),
        );
        await tester.pump();

        await tester.tap(find.text('mark done'));
        await tester.pump();
        await Future<void>.delayed(const Duration(milliseconds: 50));
        await tester.pump();

        expect(find.text('Task marked done'), findsOneWidget);
        expect(find.text('Undo'), findsOneWidget);

        final snackBar = tester.widget<SnackBar>(find.byType(SnackBar));
        expect(snackBar.persist, isFalse);
        expect(snackBar.duration, const Duration(seconds: 4));
        expect(snackBar.behavior, SnackBarBehavior.floating);
        expect(snackBar.actionOverflowThreshold, 1);

        await tester.pumpWidget(const SizedBox.shrink());
        await db.close();
      });
    },
  );
}
