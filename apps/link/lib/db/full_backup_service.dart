import 'dart:convert';
import 'dart:typed_data';

import 'package:kinetic_webdav/kinetic_webdav.dart';

import 'app_database.dart';
import 'database_backup_service.dart';
import '../settings/settings_repository.dart';
import '../theme/app_themes.dart';

/// Bundles an encrypted DB snapshot (and optional theme) into a `.kvault` file.
///
/// The outer wrapper is AES-GCM with the vault key — no raw personal key or
/// WebDAV password is written to disk.
class FullBackupService {
  // ---------------------------------------------------------------------------
  // Encrypted vault backup (.kvault)
  // ---------------------------------------------------------------------------

  /// Encrypted-only backup: AES-GCM wrapper, no raw key, no WebDAV password.
  static Future<Uint8List> exportVaultToBytes(
    AppDatabase db,
    Uint8List personalKey, {
    String usernameHint = '',
    String? currentThemeName,
  }) async {
    final kbakBlob = await DatabaseBackupService.exportToBytes(db, personalKey);
    final inner = jsonEncode({
      'database': base64.encode(kbakBlob),
      if (currentThemeName != null) 'settings': {'theme': currentThemeName},
    });
    return KineticVault.wrapBackup(
      plaintext: Uint8List.fromList(utf8.encode(inner)),
      key: personalKey,
      usernameHint: usernameHint,
    );
  }

  /// Restores a `.kvault` produced by [exportVaultToBytes].
  ///
  /// Does not write the key; the caller unlocks the vault after a successful
  /// decrypt. Throws [FormatException] when the phrase does not match.
  static Future<void> importVaultFromBytes(
    AppDatabase db,
    Uint8List data,
    Uint8List personalKey, {
    SettingsRepository? settingsRepo,
    void Function(AppTheme)? onThemeRestored,
  }) async {
    final innerBytes = await KineticVault.unwrapBackup(data, personalKey);

    final Map<String, dynamic> inner;
    try {
      inner = jsonDecode(utf8.decode(innerBytes)) as Map<String, dynamic>;
    } catch (_) {
      throw const FormatException('Vault file is corrupt.');
    }

    final dbStr = inner['database'] as String?;
    if (dbStr == null || dbStr.isEmpty) {
      throw const FormatException('Vault file does not contain a database.');
    }

    final Uint8List kbakBlob;
    try {
      kbakBlob = Uint8List.fromList(base64.decode(dbStr));
    } catch (_) {
      throw const FormatException(
        'Database data in vault file is corrupt.',
      );
    }

    await DatabaseBackupService.importFromBytes(db, personalKey, kbakBlob);

    final settings = inner['settings'] as Map<String, dynamic>?;
    final themeName = settings?['theme'] as String?;
    if (themeName != null && settingsRepo != null) {
      final theme = appThemeFromName(themeName);
      await settingsRepo.saveTheme(theme);
      onThemeRestored?.call(theme);
    }
  }
}
