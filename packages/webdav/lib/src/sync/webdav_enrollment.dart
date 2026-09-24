import 'dart:async';
import 'dart:typed_data';

import '../encryption/kinetic_encryption.dart';
import '../sync_config.dart';
import '../webdav_client.dart';
import '../webdav_url.dart';

/// First-time setup helpers for a WebDAV-backed Kinetic Link account.
class WebDavEnrollment {
  // ---------------------------------------------------------------------------
  // Connection test
  // ---------------------------------------------------------------------------

  /// Tests whether [serverUrl] is reachable and supports WebDAV with the
  /// given credentials.
  ///
  /// Returns `null` on success, or a stable error code on failure:
  /// `auth`, `no_webdav`, `timeout`, `unreachable`, or `bad_url:<message>`.
  /// Times out after 10 seconds.
  static Future<String?> testConnection(
    String serverUrl,
    String username,
    String password,
  ) async {
    final String httpsUrl;
    try {
      httpsUrl = WebDavUrl.requireHttps(serverUrl);
    } on FormatException catch (e) {
      return 'bad_url:${e.message}';
    }

    final client = WebDavClient(
      baseUrl: httpsUrl,
      username: username,
      password: password,
    );
    try {
      final status = await client.probeConnection().timeout(
            const Duration(seconds: 10),
            onTimeout: () => throw TimeoutException(
              'WebDAV connection test timed out after 10 seconds',
            ),
          );
      return switch (status) {
        WebDavConnectionStatus.ok => null,
        WebDavConnectionStatus.authFailed => 'auth',
        WebDavConnectionStatus.noWebDav => 'no_webdav',
        WebDavConnectionStatus.unreachable => 'unreachable',
      };
    } on TimeoutException {
      return 'timeout';
    } on Exception {
      return 'unreachable';
    } finally {
      client.dispose();
    }
  }

  // ---------------------------------------------------------------------------
  // Directory provisioning
  // ---------------------------------------------------------------------------

  /// Creates the required WebDAV directory tree for [username]:
  ///
  /// ```
  /// /kinetic/
  ///   {username}/
  ///     tasks/
  ///     notes/
  ///   shared/
  ///     notes/
  ///     tasks/
  ///     proposals/
  ///     load/
  /// ```
  static Future<void> setupDirectories(
    WebDavClient client,
    String username,
  ) async {
    final dirs = [
      '/kinetic',
      '/kinetic/$username',
      '/kinetic/$username/tasks',
      '/kinetic/$username/notes',
      '/kinetic/shared',
      '/kinetic/shared/notes',
      '/kinetic/shared/tasks',
      '/kinetic/shared/proposals',
      '/kinetic/shared/load',
      '/kinetic/shared/presence',
      '/kinetic/shared/disconnect',
      '/kinetic/shared/xp-reset',
      '/kinetic/shared/goals',
    ];
    for (final dir in dirs) {
      await client.mkcol(dir);
    }
  }

  // ---------------------------------------------------------------------------
  // Key generation
  // ---------------------------------------------------------------------------

  /// Generates fresh personal and family keys for a new account.
  ///
  /// Both keys are randomly generated and independent of the WebDAV password.
  /// The family key must be explicitly shared with other link devices via
  /// [KineticEncryption.exportFamilyKeyJson] / [KineticEncryption.importFamilyKeyJson].
  static ({Uint8List personalKey, Uint8List familyKey}) generateKeys() {
    final personalKey = KineticEncryption.generatePersonalKey();
    final familyKey = KineticEncryption.generateFamilyKey();
    return (personalKey: personalKey, familyKey: familyKey);
  }

  // ---------------------------------------------------------------------------
  // Full first-run workflow
  // ---------------------------------------------------------------------------

  /// Convenience method that runs the full first-time enrollment:
  ///
  /// 1. Tests the connection.
  /// 2. Creates the directory tree.
  /// 3. Generates personal + family keys.
  ///
  /// Returns a ready-to-use [SyncConfig] with both keys populated, or throws
  /// [EnrollmentException] on failure.
  static Future<SyncConfig> enroll({
    required String serverUrl,
    required String username,
    required String password,
  }) async {
    final error = await testConnection(serverUrl, username, password);
    if (error != null) throw EnrollmentException(error);

    final client = WebDavClient(
      baseUrl: serverUrl,
      username: username,
      password: password,
    );
    try {
      await setupDirectories(client, username);
    } finally {
      client.dispose();
    }

    final keys = generateKeys();
    return SyncConfig(
      serverUrl: serverUrl,
      username: username,
      password: password,
      linkId: '',
      personalKeyBytes: keys.personalKey,
      familyKeyBytes: keys.familyKey,
    );
  }
}

/// Thrown when [WebDavEnrollment.enroll] fails.
class EnrollmentException implements Exception {
  final String message;
  const EnrollmentException(this.message);

  @override
  String toString() => 'EnrollmentException: $message';
}
