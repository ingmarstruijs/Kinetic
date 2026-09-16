import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kinetic_webdav/kinetic_webdav.dart';
import 'package:parent/l10n/generated/app_localizations.dart';
import 'package:parent/settings/models/enrolled_kid.dart';
import 'package:parent/sync/webdav_config_repository.dart';
import 'package:parent/todo/widgets/kids_panel.dart';

void main() {
  final enrolled = [
    EnrolledKid(id: 'job', name: 'Job', enrolledAt: DateTime.utc(2026, 1, 1)),
    EnrolledKid(
      id: 'jolise',
      name: 'Jolise',
      enrolledAt: DateTime.utc(2026, 1, 1),
    ),
  ];

  ICalTask task({
    required String uid,
    required String summary,
    String? kidId,
    ICalTaskStatus status = ICalTaskStatus.needsAction,
    int xp = 10,
  }) {
    final desc = [
      if (kidId != null) 'xKineticTargetKidId:$kidId',
      'xKineticXpReward:$xp',
    ].join(';');
    final now = DateTime.utc(2026, 9, 15);
    return ICalTask(
      uid: uid,
      summary: summary,
      description: desc,
      status: status,
      createdAt: now,
      updatedAt: now,
    );
  }

  test('groups open tasks per enrolled kid and counts XP', () {
    final groups = groupKidsTasks(
      tasks: [
        task(uid: '1', summary: 'Shirts', kidId: 'job'),
        task(uid: '2', summary: 'Tanden', kidId: 'job'),
        task(
          uid: '3',
          summary: 'Done chore',
          kidId: 'job',
          status: ICalTaskStatus.completed,
          xp: 15,
        ),
        task(uid: '4', summary: 'Kamer', kidId: 'jolise'),
        task(uid: '5', summary: 'Everyone'),
      ],
      enrolledKids: enrolled,
      everyoneLabel: 'Everyone',
    );

    expect(groups.map((g) => g.name), ['Job', 'Jolise', 'Everyone']);
    final job = groups.firstWhere((g) => g.key == 'job');
    expect(job.openCount, 2);
    expect(job.xp, 15);
    expect(groups.firstWhere((g) => g.key == 'jolise').openCount, 1);
    expect(groups.firstWhere((g) => g.key == '__everyone__').openCount, 1);
  });

  test('includes enrolled kids with zero tasks', () {
    final groups = groupKidsTasks(
      tasks: const [],
      enrolledKids: enrolled,
      everyoneLabel: 'Everyone',
    );
    expect(groups, hasLength(2));
    expect(groups.every((g) => g.openCount == 0), isTrue);
  });

  test('kidInitials and avatar color are stable', () {
    expect(kidInitials('Job'), 'J');
    expect(kidInitials('Annemarie de Vries'), 'AV');
    expect(kidAvatarColor('Job'), kidAvatarColor('Job'));
  });

  testWidgets('parent can delete a kid task from the panel', (tester) async {
    await tester.runAsync(() async {
      final deleted = <String>[];
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          home: Scaffold(
            body: KidsPanel(
              configRepo: WebDavConfigRepository(InMemoryKeyValueStore()),
              enrolledKidsOverride: enrolled,
              pullSharedTasks: () async => [
                task(uid: '1', summary: 'Shirts', kidId: 'job'),
              ],
              onDeleteKidTask: (t) async => deleted.add(t.uid),
            ),
          ),
        ),
      );
      await tester.pump();
      await Future<void>.delayed(const Duration(milliseconds: 50));
      await tester.pump();

      await tester.tap(find.widgetWithText(FilterChip, 'Job'));
      await tester.pump();
      expect(find.text('Shirts'), findsOneWidget);

      await tester.tap(find.byTooltip('Delete'));
      await tester.pump();
      expect(find.text('Remove kids task?'), findsOneWidget);
      await tester.tap(find.text('Delete').last);
      await Future<void>.delayed(const Duration(milliseconds: 50));
      await tester.pump();

      expect(deleted, ['1']);
    });
  });
}
