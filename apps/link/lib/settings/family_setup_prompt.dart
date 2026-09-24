import 'package:flutter/material.dart';

import '../db/app_database.dart';
import '../l10n/generated/app_localizations.dart';
import '../sync/sync_orchestrator.dart';
import '../sync/webdav_config_repository.dart';
import 'family_setup_wizard.dart';
import 'settings_repository.dart';

/// Default snooze when the user picks "remind me later".
const kFamilySetupRemindDays = 7;

enum FamilySetupPromptChoice { ignore, remind, start }

/// Shows the Start-family nudge when WebDAV is on but no family key exists yet
/// (after [kFamilySetupPromptDelay], unless skipped or snoozed).
Future<void> maybeShowFamilySetupPrompt({
  required BuildContext context,
  required WebDavConfigRepository configRepo,
  required AppDatabase db,
  required SettingsRepository settingsRepo,
  SyncOrchestrator? syncOrchestrator,
  VoidCallback? onConfigSaved,
  VoidCallback? onRestoreComplete,
  VoidCallback? onOpenTasksTab,
}) async {
  if (!context.mounted) return;
  if (!await configRepo.shouldShowFamilySetupPrompt()) return;
  if (!context.mounted) return;

  final l10n = AppLocalizations.of(context);
  final choice = await showDialog<FamilySetupPromptChoice>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => AlertDialog(
      title: Text(l10n.familySetupPromptTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l10n.familySetupPromptBody),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: () =>
                Navigator.of(ctx).pop(FamilySetupPromptChoice.start),
            child: Text(l10n.familySetupPromptStart),
          ),
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: () =>
                Navigator.of(ctx).pop(FamilySetupPromptChoice.remind),
            child: Text(l10n.familySetupPromptRemind(kFamilySetupRemindDays)),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () =>
                Navigator.of(ctx).pop(FamilySetupPromptChoice.ignore),
            child: Text(l10n.familySetupPromptIgnore),
          ),
        ],
      ),
    ),
  );

  if (!context.mounted || choice == null) return;

  switch (choice) {
    case FamilySetupPromptChoice.ignore:
      await configRepo.skipFamilySetupPrompt();
    case FamilySetupPromptChoice.remind:
      await configRepo.remindFamilySetupPromptInDays(kFamilySetupRemindDays);
    case FamilySetupPromptChoice.start:
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => FamilySetupWizard(
            db: db,
            configRepo: configRepo,
            settingsRepo: settingsRepo,
            syncOrchestrator: syncOrchestrator,
            onConfigSaved: onConfigSaved,
            onRestoreComplete: onRestoreComplete,
            onOpenTasksTab: onOpenTasksTab,
          ),
        ),
      );
  }
}
