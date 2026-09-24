import '../l10n/generated/app_localizations.dart';

/// Maps [WebDavEnrollment.testConnection] error codes to localized text.
String localizeWebDavConnectionError(AppLocalizations l10n, String code) {
  if (code.startsWith('bad_url:')) {
    return code.substring('bad_url:'.length);
  }
  return switch (code) {
    'auth' => l10n.webdavErrorAuth,
    'no_webdav' => l10n.webdavErrorNoWebDav,
    'timeout' => l10n.webdavErrorTimeout,
    'unreachable' => l10n.webdavErrorUnreachable,
    _ => code,
  };
}
