import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:kinetic_webdav/kinetic_webdav.dart';
import 'package:link/sync/webdav_config_repository.dart';

void main() {
  group('WebDavConfigRepository API', () {
    test('WebDavConfigRepository can be imported', () {
      expect(WebDavConfigRepository, isNotNull);
    });

    test('SyncConfig model has required fields', () {
      final config = SyncConfig(
        serverUrl: 'https://dav.example.com',
        username: 'user@example.com',
        password: 'password123',
        linkId: '',
        personalKeyBytes: Uint8List.fromList(List.filled(32, 0)),
        familyKeyBytes: null,
      );

      expect(config.serverUrl, equals('https://dav.example.com'));
      expect(config.username, equals('user@example.com'));
      expect(config.password, equals('password123'));
      expect(config.personalKeyBytes.length, equals(32));
      expect(config.familyKeyBytes, isNull);
    });
  });

  group('requirePersonalKey', () {
    test('throws when no vault key is stored', () async {
      final repo = WebDavConfigRepository(InMemoryKeyValueStore());
      expect(repo.requirePersonalKey, throwsA(isA<StateError>()));
    });

    test('returns the stored key', () async {
      final store = InMemoryKeyValueStore();
      final repo = WebDavConfigRepository(store);
      final key = Uint8List.fromList(List.filled(32, 7));
      await repo.savePersonalKey(key);
      expect(await repo.requirePersonalKey(), key);
    });
  });

  group('family vault', () {
    test('saveFamilyKey stores entropy and clearFamilyKey removes it', () async {
      final store = InMemoryKeyValueStore();
      final repo = WebDavConfigRepository(store);
      final key = Uint8List.fromList(List.filled(32, 3));
      final entropy = Uint8List.fromList(List.filled(16, 9));
      await repo.saveFamilyKey(key, entropy: entropy);
      expect(await repo.loadFamilyKey(), key);
      expect(await repo.loadFamilyEntropy(), entropy);
      await repo.clearFamilyKey();
      expect(await repo.loadFamilyKey(), isNull);
      expect(await repo.loadFamilyEntropy(), isNull);
    });

    test('disconnectWebDav clears server but keeps personal vault', () async {
      final store = InMemoryKeyValueStore();
      final repo = WebDavConfigRepository(store);
      final personalKey = Uint8List.fromList(List.filled(32, 7));
      final personalEntropy = Uint8List.fromList(List.filled(16, 4));
      final familyKey = Uint8List.fromList(List.filled(32, 3));

      await repo.save(
        SyncConfig(
          serverUrl: 'https://dav.example.com',
          username: 'user',
          password: 'secret',
          linkId: 'link-1',
          personalKeyBytes: personalKey,
          familyKeyBytes: familyKey,
        ),
      );
      await repo.savePersonalEntropy(personalEntropy);
      await repo.setHasOtherLinkMembers(true);
      await repo.addEnrolledKid('Mees');

      await repo.disconnectWebDav();

      expect(await repo.load(), isNull);
      expect(await repo.requirePersonalKey(), personalKey);
      expect(await repo.loadPersonalEntropy(), personalEntropy);
      expect(await repo.loadFamilyKey(), isNull);
      expect(await repo.hasOtherLinkMembers(), isFalse);
      expect(await repo.loadEnrolledKids(), isEmpty);
    });
  });

  group('family setup prompt', () {
    Future<WebDavConfigRepository> _repoWithoutFamily() async {
      final store = InMemoryKeyValueStore();
      final repo = WebDavConfigRepository(store);
      await repo.save(
        SyncConfig(
          serverUrl: 'https://dav.example.com',
          username: 'user',
          password: 'secret',
          linkId: 'link-1',
          personalKeyBytes: Uint8List.fromList(List.filled(32, 1)),
          familyKeyBytes: null,
        ),
      );
      return repo;
    }

    test('shows after delay, not before', () async {
      final repo = await _repoWithoutFamily();
      final t0 = DateTime.utc(2026, 1, 1);
      await repo.ensureFamilySetupEligibleSince(t0);

      expect(
        await repo.shouldShowFamilySetupPrompt(now: t0.add(const Duration(hours: 12))),
        isFalse,
      );
      expect(
        await repo.shouldShowFamilySetupPrompt(now: t0.add(const Duration(days: 1))),
        isTrue,
      );
    });

    test('ignore skips permanently; remind snoozes', () async {
      final repo = await _repoWithoutFamily();
      final t0 = DateTime.utc(2026, 1, 1);
      await repo.ensureFamilySetupEligibleSince(t0);
      final due = t0.add(const Duration(days: 2));

      await repo.remindFamilySetupPromptInDays(7, now: due);
      expect(await repo.shouldShowFamilySetupPrompt(now: due), isFalse);
      expect(
        await repo.shouldShowFamilySetupPrompt(
          now: due.add(const Duration(days: 7)),
        ),
        isTrue,
      );

      await repo.skipFamilySetupPrompt();
      expect(
        await repo.shouldShowFamilySetupPrompt(
          now: due.add(const Duration(days: 30)),
        ),
        isFalse,
      );
    });

    test('saving family key clears prompt state', () async {
      final repo = await _repoWithoutFamily();
      final t0 = DateTime.utc(2026, 1, 1);
      await repo.ensureFamilySetupEligibleSince(t0);
      await repo.saveFamilyKey(Uint8List.fromList(List.filled(32, 9)));
      expect(
        await repo.shouldShowFamilySetupPrompt(
          now: t0.add(const Duration(days: 10)),
        ),
        isFalse,
      );
    });
  });
}
