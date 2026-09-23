import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kinetic_webdav/kinetic_webdav.dart';
import 'package:link/l10n/generated/app_localizations.dart';
import 'package:link/settings/kids_settings_screen.dart';
import 'package:link/settings/models/enrolled_kid.dart';
import 'package:link/settings/settings_repository.dart';
import 'package:link/settings/settings_screen.dart';
import 'package:link/sync/sync_orchestrator.dart';
import 'package:link/sync/webdav_config_repository.dart';

import '../helpers/test_database.dart';

void main() {
  group('disconnectIncludesSelf', () {
    test('true when my id is listed', () {
      expect(disconnectIncludesSelf('me', ['other', 'me']), isTrue);
    });

    test('false when my id is absent or empty', () {
      expect(disconnectIncludesSelf('me', ['other']), isFalse);
      expect(disconnectIncludesSelf('', ['']), isFalse);
    });
  });

  group('Settings family kids participation', () {
    testWidgets('shows kids participation switch on Settings family section', (
      tester,
    ) async {
      await tester.runAsync(() async {
        final db = createTestDatabase();
        final store = InMemoryKeyValueStore();
        final configRepo = WebDavConfigRepository(store);
        await configRepo.save(
          SyncConfig(
            serverUrl: 'https://dav.example.com',
            username: 'user',
            password: 'pass',
            linkId: 'link-1',
            personalKeyBytes: Uint8List.fromList(List.filled(32, 1)),
          ),
        );
        await configRepo.saveKidsParticipation(true);
        await configRepo.restoreEnrolledKids([
          EnrolledKid(
            id: 'kid-1',
            name: 'Mees',
            enrolledAt: DateTime.utc(2026, 1, 1),
          ),
        ]);

        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: const Locale('en'),
            home: SettingsScreen(
              db: db,
              configRepo: configRepo,
              settingsRepo: SettingsRepository(db: db),
            ),
          ),
        );
        await tester.pump();
        await Future<void>.delayed(const Duration(milliseconds: 50));
        await tester.pumpAndSettle();

        expect(find.text('Kids tasks on this device'), findsOneWidget);
        expect(find.byType(SwitchListTile), findsWidgets);

        await tester.pumpWidget(const SizedBox.shrink());
        await db.close();
      });
    });

    testWidgets('hides kids participation switch when no kids enrolled', (
      tester,
    ) async {
      await tester.runAsync(() async {
        final db = createTestDatabase();
        final store = InMemoryKeyValueStore();
        final configRepo = WebDavConfigRepository(store);
        await configRepo.save(
          SyncConfig(
            serverUrl: 'https://dav.example.com',
            username: 'user',
            password: 'pass',
            linkId: 'link-1',
            personalKeyBytes: Uint8List.fromList(List.filled(32, 1)),
          ),
        );

        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: const Locale('en'),
            home: SettingsScreen(
              db: db,
              configRepo: configRepo,
              settingsRepo: SettingsRepository(db: db),
            ),
          ),
        );
        await tester.pump();
        await Future<void>.delayed(const Duration(milliseconds: 100));
        await tester.pumpAndSettle();

        expect(find.text('Family members'), findsOneWidget);
        expect(find.text('Kids tasks on this device'), findsNothing);

        await tester.pumpWidget(const SizedBox.shrink());
        await db.close();
      });
    });

    testWidgets('Kids settings has no participation switch', (tester) async {
      await tester.runAsync(() async {
        final store = InMemoryKeyValueStore();
        final configRepo = WebDavConfigRepository(store);

        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: const Locale('en'),
            home: KidsSettingsScreen(configRepo: configRepo),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Kids tasks on this device'), findsNothing);
        expect(find.text('Link kids app'), findsOneWidget);

        await tester.pumpWidget(const SizedBox.shrink());
      });
    });
  });
}
