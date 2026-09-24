import 'dart:async' show TimeoutException;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../l10n/generated/app_localizations.dart';

/// High-level sync phase shown in the app bar and settings.
enum SyncStatus { idle, syncing, error }

/// Snapshot pushed through [ValueNotifier]s for Link (and optionally Kids).
class SyncStatusInfo {
  final SyncStatus status;
  final String? lastError;
  final DateTime? lastSuccessAt;

  const SyncStatusInfo({
    this.status = SyncStatus.idle,
    this.lastError,
    this.lastSuccessAt,
  });

  SyncStatusInfo copyWith({
    SyncStatus? status,
    String? lastError,
    bool clearError = false,
    DateTime? lastSuccessAt,
  }) {
    return SyncStatusInfo(
      status: status ?? this.status,
      lastError: clearError ? null : (lastError ?? this.lastError),
      lastSuccessAt: lastSuccessAt ?? this.lastSuccessAt,
    );
  }
}

/// Maps raw exceptions to a short user-facing sync message.
String syncErrorMessage(Object error, AppLocalizations l10n) {
  final text = error.toString().toLowerCase();
  if (error is TimeoutException || text.contains('timeout')) {
    return l10n.syncErrorTimeout;
  }
  if (text.contains('401') ||
      text.contains('403') ||
      text.contains('unauthor') ||
      text.contains('forbidden')) {
    return l10n.syncErrorAuth;
  }
  if (text.contains('socket') ||
      text.contains('network') ||
      text.contains('failed host lookup') ||
      text.contains('connection')) {
    return l10n.syncErrorNetwork;
  }
  return l10n.syncErrorGeneric;
}

/// App-bar sync control: spinner while syncing; otherwise opens the status sheet.
class SyncStatusIcon extends StatelessWidget {
  final SyncStatusInfo info;
  final VoidCallback onRetry;

  const SyncStatusIcon({super.key, required this.info, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (info.status == SyncStatus.syncing) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 12),
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }
    final isError = info.status == SyncStatus.error;
    return IconButton(
      onPressed: () => showSyncStatusSheet(
        context,
        info: info,
        onRetry: onRetry,
      ),
      tooltip: isError ? l10n.tasksSyncOffline : l10n.tasksSyncing,
      icon: Icon(
        isError ? Icons.cloud_off_outlined : Icons.cloud_done_outlined,
        color: isError ? Theme.of(context).colorScheme.error : null,
      ),
    );
  }
}

/// Bottom sheet: current phase, last error, last success, Retry.
Future<void> showSyncStatusSheet(
  BuildContext context, {
  required SyncStatusInfo info,
  required VoidCallback onRetry,
}) {
  final l10n = AppLocalizations.of(context);
  final scheme = Theme.of(context).colorScheme;

  String phaseLabel(SyncStatus s) => switch (s) {
    SyncStatus.syncing => l10n.syncStatusSyncing,
    SyncStatus.error => l10n.syncStatusError,
    SyncStatus.idle => l10n.syncStatusIdle,
  };

  final lastOk = info.lastSuccessAt;
  final lastOkText = lastOk == null
      ? l10n.syncStatusNeverSynced
      : l10n.syncStatusLastSuccess(
          DateFormat.yMMMd().add_jm().format(lastOk.toLocal()),
        );

  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (ctx) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.syncStatusTitle,
              style: Theme.of(ctx).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(
                switch (info.status) {
                  SyncStatus.syncing => Icons.sync,
                  SyncStatus.error => Icons.cloud_off_outlined,
                  SyncStatus.idle => Icons.cloud_done_outlined,
                },
                color: info.status == SyncStatus.error
                    ? scheme.error
                    : scheme.primary,
              ),
              title: Text(phaseLabel(info.status)),
              subtitle: Text(lastOkText),
            ),
            if (info.lastError != null && info.lastError!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                info.lastError!,
                style: Theme.of(ctx).textTheme.bodyMedium?.copyWith(
                  color: scheme.error,
                ),
              ),
            ],
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () {
                Navigator.of(ctx).pop();
                onRetry();
              },
              icon: const Icon(Icons.sync),
              label: Text(l10n.syncStatusRetry),
            ),
          ],
        ),
      );
    },
  );
}
