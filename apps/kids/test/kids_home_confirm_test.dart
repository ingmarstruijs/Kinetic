import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kids/l10n/generated/app_localizations.dart';
import 'package:kids/task/models/kids_task.dart';
import 'package:kids/task/screens/kids_home_screen.dart';
import 'package:kids/task/services/kids_task_repository.dart';

import 'helpers/test_database.dart';

void main() {
  testWidgets('shows confirm dialog when completing a task', (tester) async {
    await tester.runAsync(() async {
      final appDb = createTestDatabase();
      final repo = KidsTaskRepository(db: appDb);
      final now = DateTime.now().toUtc();
      await repo.upsertTask(
        KidsTask(
          id: 't1',
          linkTaskId: 'p',
          title: 'Brush teeth',
          notes: '',
          category: TaskCategory.household,
          priority: TaskPriority.normal,
          dueDate: now,
          isCompleted: false,
          xpReward: 10,
          syncState: 'clean',
          createdAt: now,
          updatedAt: now,
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          home: KidsHomeScreen(appDb: appDb, repository: repo),
        ),
      );
      await tester.pump();
      await Future<void>.delayed(const Duration(milliseconds: 20));
      await tester.pump();

      expect(find.text('Brush teeth'), findsOneWidget);

      await tester.tap(find.byType(Checkbox));
      await tester.pump();

      expect(find.text('Are you done?'), findsOneWidget);
      expect(
        find.textContaining('confirmation request to Link'),
        findsOneWidget,
      );

      await tester.tap(find.text('Cancel'));
      await tester.pump();
      expect(find.text('Are you done?'), findsNothing);

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
      await appDb.close();
    });
  });
}
