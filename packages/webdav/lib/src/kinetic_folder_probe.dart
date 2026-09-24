import 'webdav_client.dart';

/// Result of scanning `/kinetic/` for other Link users / family markers.
class KineticFolderProbeResult {
  /// Other user folders under `/kinetic/` (excludes [shared] and self).
  final List<String> otherUsernames;

  /// True when `/kinetic/shared/roster.json` exists (encrypted family roster).
  final bool hasSharedRoster;

  /// True when `/kinetic/shared/presence/` has at least one file.
  final bool hasSharedPresence;

  /// True when shared tasks/notes/proposals already contain files.
  final bool hasSharedContent;

  const KineticFolderProbeResult({
    required this.otherUsernames,
    required this.hasSharedRoster,
    required this.hasSharedPresence,
    this.hasSharedContent = false,
  });

  /// Enough signal that another Kinetic setup already lives on this server.
  ///
  /// Only visible when that data shares the **same WebDAV root**. Separate
  /// Nextcloud personal homes (`…/dav/files/alice/` vs `…/bob/`) cannot see
  /// each other — those need a shared folder / group folder as base URL.
  bool get suggestsExistingFamily =>
      otherUsernames.isNotEmpty ||
      hasSharedRoster ||
      hasSharedPresence ||
      hasSharedContent;
}

/// Discovers other Kinetic users / family data on a shared WebDAV root.
class KineticFolderProbe {
  KineticFolderProbe._();

  /// PROPFIND `/kinetic/` + cheap existence checks for shared family files.
  static Future<KineticFolderProbeResult> probe({
    required WebDavClient client,
    required String username,
  }) async {
    final me = username.trim();
    final others = <String>[];

    try {
      final entries = await client.propfind('/kinetic');
      for (final entry in entries) {
        final name = _collectionName(entry.href);
        if (name == null || name.isEmpty) continue;
        if (name == 'shared' || name == 'kinetic') continue;
        // Prefer collection flag; also accept trailing-slash siblings.
        final looksLikeDir =
            entry.isCollection || entry.href.split('?').first.endsWith('/');
        if (!looksLikeDir) continue;
        if (me.isNotEmpty && name.toLowerCase() == me.toLowerCase()) continue;
        if (!others.contains(name)) others.add(name);
      }
    } catch (_) {
      // Probe is best-effort — empty kinetic tree / no list permission is fine.
    }

    final hasSharedRoster = await _exists(client, '/kinetic/shared/roster.json');
    final hasSharedPresence = await _dirHasFiles(client, '/kinetic/shared/presence');
    final hasSharedContent = await _dirHasFiles(client, '/kinetic/shared/tasks') ||
        await _dirHasFiles(client, '/kinetic/shared/notes') ||
        await _dirHasFiles(client, '/kinetic/shared/proposals');

    others.sort();
    return KineticFolderProbeResult(
      otherUsernames: others,
      hasSharedRoster: hasSharedRoster,
      hasSharedPresence: hasSharedPresence,
      hasSharedContent: hasSharedContent,
    );
  }

  /// True when [path] lists at least one non-collection child.
  static Future<bool> _dirHasFiles(WebDavClient client, String path) async {
    try {
      final entries = await client.propfind(path);
      final normalized = path.endsWith('/') ? path : '$path/';
      return entries.any((e) {
        if (e.isCollection) return false;
        final href = e.href.split('?').first;
        if (href.endsWith(normalized) || href.endsWith(path)) return false;
        return true;
      });
    } catch (_) {
      return false;
    }
  }

  static Future<bool> _exists(WebDavClient client, String path) async {
    try {
      await client.get(path);
      return true;
    } on WebDavException catch (e) {
      if (e.isNotFound) return false;
      return false;
    } catch (_) {
      return false;
    }
  }

  /// Last non-empty path segment, without trailing slash.
  static String? _collectionName(String href) {
    var path = href.split('?').first;
    if (path.endsWith('/')) path = path.substring(0, path.length - 1);
    final i = path.lastIndexOf('/');
    if (i < 0 || i >= path.length - 1) return path.isEmpty ? null : path;
    return Uri.decodeComponent(path.substring(i + 1));
  }
}
