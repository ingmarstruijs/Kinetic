import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kids/l10n/generated/app_localizations.dart';
import 'package:kids/sync/webdav_config_repository.dart';
import 'package:kids/task/models/kids_task.dart';
import 'package:kids/task/screens/kids_home_screen.dart';
import 'package:kids/task/screens/kids_task_detail_screen.dart';
import 'package:kids/task/services/kids_task_repository.dart';
import 'package:kinetic_webdav/kinetic_webdav.dart';

import '../helpers/test_database.dart';

Widget _l10nApp({required Widget home}) {
  return MaterialApp(
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: AppLocalizations.supportedLocales,
    locale: const Locale('en'),
    home: home,
  );
}

KidsTask _chore(DateTime now) => KidsTask(
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
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('xpEnabled config', () {
    test('defaults true and round-trips false', () async {
      final repo = WebDavConfigRepository(InMemoryKeyValueStore());
      expect(await repo.loadXpEnabled(), isTrue);
      await repo.saveXpEnabled(false);
      expect(await repo.loadXpEnabled(), isFalse);
      await repo.saveXpEnabled(true);
      expect(await repo.loadXpEnabled(), isTrue);
    });
  });

  group('KidsHomeScreen xpEnabled', () {
    testWidgets('hides XP chip and goal hero when xpEnabled is false', (
      tester,
    ) async {
      await tester.runAsync(() async {
        final appDb = createTestDatabase();
        final repo = KidsTaskRepository(db: appDb);
        final now = DateTime.now().toUtc();
        await repo.upsertTask(_chore(now));

        await tester.pumpWidget(
          _l10nApp(
            home: KidsHomeScreen(
              appDb: appDb,
              repository: repo,
              xpEnabled: false,
              goal: KidGoal(
                kidId: 'kid-1',
                title: 'New bike',
                targetXp: 100,
                updatedAt: now,
              ),
            ),
          ),
        );
        await tester.pump();
        await Future<void>.delayed(const Duration(milliseconds: 20));
        await tester.pump();

        expect(find.text('Brush teeth'), findsOneWidget);
        expect(find.textContaining('XP'), findsNothing);
        expect(find.text('New bike'), findsNothing);

        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pump();
        await appDb.close();
      });
    });

    testWidgets('shows XP chip when xpEnabled is true', (tester) async {
      await tester.runAsync(() async {
        final appDb = createTestDatabase();
        final repo = KidsTaskRepository(db: appDb);
        final now = DateTime.now().toUtc();
        await repo.upsertTask(_chore(now));

        await tester.pumpWidget(
          _l10nApp(
            home: KidsHomeScreen(
              appDb: appDb,
              repository: repo,
              xpEnabled: true,
            ),
          ),
        );
        await tester.pump();
        await Future<void>.delayed(const Duration(milliseconds: 20));
        await tester.pump();

        expect(find.textContaining('10 XP'), findsOneWidget);

        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pump();
        await appDb.close();
      });
    });
  });

  group('KidsTaskDetailScreen xpEnabled', () {
    testWidgets('hides Experience card when xpEnabled is false', (
      tester,
    ) async {
      await tester.runAsync(() async {
        final appDb = createTestDatabase();
        final repo = KidsTaskRepository(db: appDb);
        final now = DateTime.now().toUtc();
        await repo.upsertTask(_chore(now));

        await tester.pumpWidget(
          _l10nApp(
            home: KidsTaskDetailScreen(
              repository: repo,
              taskId: 't1',
              xpEnabled: false,
            ),
          ),
        );
        await tester.pump();
        await Future<void>.delayed(const Duration(milliseconds: 20));
        await tester.pump();

        expect(find.text('Brush teeth'), findsOneWidget);
        expect(find.text('Experience'), findsNothing);
        expect(find.textContaining('XP'), findsNothing);

        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pump();
        await appDb.close();
      });
    });
  });
}
