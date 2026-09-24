import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:link/l10n/generated/app_localizations_en.dart';
import 'package:link/sync/sync_status.dart';

void main() {
  final l10n = AppLocalizationsEn();

  test('syncErrorMessage maps timeout', () {
    expect(
      syncErrorMessage(TimeoutException('x'), l10n),
      l10n.syncErrorTimeout,
    );
  });

  test('syncErrorMessage maps auth', () {
    expect(syncErrorMessage(Exception('401 unauthorized'), l10n), l10n.syncErrorAuth);
  });

  test('SyncStatusInfo copyWith clearError', () {
    const a = SyncStatusInfo(
      status: SyncStatus.error,
      lastError: 'boom',
    );
    final b = a.copyWith(status: SyncStatus.syncing, clearError: true);
    expect(b.status, SyncStatus.syncing);
    expect(b.lastError, isNull);
  });
}
