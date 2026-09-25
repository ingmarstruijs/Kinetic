import 'dart:typed_data';

import 'package:drift/drift.dart' hide Column;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:kinetic_webdav/kinetic_webdav.dart';
import 'package:uuid/uuid.dart';

import '../db/app_database.dart';
import '../db/backup_file_io.dart';
import '../db/full_backup_service.dart';
import '../l10n/generated/app_localizations.dart';
import '../sync/sync_orchestrator.dart';
import '../sync/sync_status.dart';
import '../sync/webdav_config_repository.dart';
import '../sync/webdav_connection_errors.dart';
import '../theme/app_header.dart';
import '../theme/app_themes.dart';
import '../main.dart';
import '../vault/family_vault_sync.dart';
import '../vault/vault_repository.dart';
import '../vault/widgets/mnemonic_phrase_field.dart';
import '../debug/demo_scenarios.dart';
import '../debug/demo_scenarios_screen.dart';
import '../debug/demo_session.dart';
import '../bridge/link_web_bridge_screen.dart';
import '../todo/services/todo_repository.dart';
import 'family_key_scan_screen.dart';
import 'kids_settings_screen.dart';
import 'family_members_settings_screen.dart';
import 'family_setup_wizard.dart';
import 'settings_repository.dart';

class SettingsScreen extends StatefulWidget {
  final AppDatabase db;
  final WebDavConfigRepository configRepo;
  final SettingsRepository settingsRepo;
  final SyncOrchestrator? syncOrchestrator;
  final ValueNotifier<SyncStatusInfo>? syncStatus;
  final VoidCallback? onConfigSaved;

  final VoidCallback? onRestoreComplete;
  final VoidCallback? onOpenTasksTab;
  final VoidCallback? onOpenNotesTab;
  final VoidCallback? onSyncRetry;
  final TodoRepository? todoRepository;

  const SettingsScreen({
    super.key,
    required this.db,
    required this.configRepo,
    required this.settingsRepo,
    this.syncOrchestrator,
    this.syncStatus,
    this.onConfigSaved,
    this.onRestoreComplete,
    this.onOpenTasksTab,
    this.onOpenNotesTab,
    this.onSyncRetry,
    this.todoRepository,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  SyncConfig? _config;
  bool _hasFamilyKey = false;
  bool _hasOtherLinkMembers = false;
  int _enrolledKidsCount = 0;
  bool _kidsParticipation = true;
  bool _kidsParticipationLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadConfig();
  }

  Future<void> _loadConfig() async {
    final config = await widget.configRepo.load();
    final paired = await widget.configRepo.hasOtherLinkMembers();
    final kids = await widget.configRepo.loadEnrolledKids();
    final kidsParticipation = await widget.configRepo.loadKidsParticipation();
    if (mounted) {
      setState(() {
        _config = config;
        _hasFamilyKey = config?.familyKeyBytes != null;
        _hasOtherLinkMembers = paired;
        _enrolledKidsCount = kids.length;
        _kidsParticipation = kidsParticipation;
        _kidsParticipationLoaded = true;
      });
    }
  }

  Future<void> _setKidsParticipation(bool enabled) async {
    setState(() => _kidsParticipation = enabled);
    await widget.configRepo.saveKidsParticipation(enabled);
    widget.onConfigSaved?.call();
  }

  Future<void> _openFamilySetupWizard() async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => FamilySetupWizard(
          db: widget.db,
          configRepo: widget.configRepo,
          settingsRepo: widget.settingsRepo,
          syncOrchestrator: widget.syncOrchestrator,
          onConfigSaved: widget.onConfigSaved,
          onRestoreComplete: widget.onRestoreComplete,
          onOpenTasksTab: widget.onOpenTasksTab,
        ),
      ),
    );
    _loadConfig();
  }

  int get _displayKidsCount {
    final demo = DemoSession.instance;
    if (demo.active) return demo.kids.length;
    return _enrolledKidsCount;
  }

  bool get _displayHasOtherLinkMembers {
    final demo = DemoSession.instance;
    if (demo.active) return demo.hasOtherLinkMembers;
    return _hasOtherLinkMembers;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isConnected = _config != null;
    return Scaffold(
      appBar: AppBar(
        title: AppHeader(title: l10n.settingsTitle, centerTitle: false),
        centerTitle: false,
      ),
      body: ListenableBuilder(
        listenable: DemoSession.instance,
        builder: (context, _) {
          return ValueListenableBuilder<AppTheme>(
            valueListenable: themeNotifier,
            builder: (context, currentTheme, _) {
              final iconColor = Theme.of(context).colorScheme.primary;
              return ListView(
                children: [
                  _SectionHeader(label: l10n.settingsSectionAppearance),
                  ListTile(
                    leading: Icon(Icons.palette_outlined, color: iconColor),
                    title: Text(l10n.settingsTheme),
                    subtitle: Text(currentTheme.label(l10n)),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _showThemeSelector(context),
                  ),
                  ListTile(
                    leading: Icon(Icons.language_outlined, color: iconColor),
                    title: Text(l10n.settingsLanguage),
                    subtitle: Text(
                      localeNotifier.value.languageCode == 'nl'
                          ? l10n.settingsLanguageDutch
                          : l10n.settingsLanguageEnglish,
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _showLanguageSelector(context),
                  ),
                  _SectionHeader(label: l10n.settingsSectionSync),
                  ListTile(
                    leading: Icon(Icons.cloud_outlined, color: iconColor),
                    title: Text(l10n.settingsWebDavConfigure),
                    subtitle: Text(
                      isConnected
                          ? l10n.settingsWebDavConnected
                          : l10n.settingsWebDavConnectHint,
                    ),
                    trailing: isConnected
                        ? Icon(Icons.check_circle, color: iconColor)
                        : const Icon(Icons.chevron_right),
                    onTap: () async {
                      await Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => WebDavSetupScreen(
                            db: widget.db,
                            configRepo: widget.configRepo,
                            settingsRepo: widget.settingsRepo,
                            syncOrchestrator: widget.syncOrchestrator,
                            onConfigSaved: widget.onConfigSaved,
                            onRestoreComplete: widget.onRestoreComplete,
                          ),
                        ),
                      );
                      _loadConfig();
                    },
                  ),
                  if (widget.todoRepository != null)
                    ListTile(
                      leading: Icon(Icons.laptop_windows_outlined, color: iconColor),
                      title: Text(l10n.linkWebTitle),
                      subtitle: Text(l10n.linkWebSettingsSubtitle),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => LinkWebBridgeScreen(
                              todoRepository: widget.todoRepository!,
                            ),
                          ),
                        );
                      },
                    ),
                  if (isConnected && widget.syncStatus != null)
                    ValueListenableBuilder<SyncStatusInfo>(
                      valueListenable: widget.syncStatus!,
                      builder: (context, info, _) {
                        final subtitle = switch (info.status) {
                          SyncStatus.syncing => l10n.settingsSyncHealthSyncing,
                          SyncStatus.error => l10n.settingsSyncHealthError,
                          SyncStatus.idle => info.lastSuccessAt == null
                              ? l10n.settingsSyncHealthNever
                              : l10n.settingsSyncHealthIdle,
                        };
                        return ListTile(
                          leading: Icon(
                            info.status == SyncStatus.error
                                ? Icons.cloud_off_outlined
                                : Icons.sync,
                            color: info.status == SyncStatus.error
                                ? Theme.of(context).colorScheme.error
                                : iconColor,
                          ),
                          title: Text(l10n.syncStatusTitle),
                          subtitle: Text(subtitle),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => showSyncStatusSheet(
                            context,
                            info: info,
                            onRetry: widget.onSyncRetry ?? () {},
                          ),
                        );
                      },
                    ),
                  if (isConnected || DemoSession.instance.active) ...[
                    _SectionHeader(
                      label: l10n.settingsSectionFamily,
                      trailing: !_hasFamilyKey
                          ? TextButton(
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                ),
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                visualDensity: VisualDensity.compact,
                              ),
                              onPressed: _openFamilySetupWizard,
                              child: Text(l10n.settingsStartFamily),
                            )
                          : null,
                    ),
                    if (_kidsParticipationLoaded && _displayKidsCount > 0)
                      SwitchListTile(
                        secondary: Icon(
                          Icons.child_care_outlined,
                          color: iconColor,
                        ),
                        title: Text(l10n.settingsKidsParticipation),
                        subtitle: Text(
                          l10n.settingsKidsParticipationSubtitle,
                        ),
                        value: _kidsParticipation,
                        onChanged: _setKidsParticipation,
                      ),
                    ListTile(
                      leading: Icon(Icons.people_outline, color: iconColor),
                      title: Text(l10n.settingsFamilyMembers),
                      subtitle: Text(
                        _displayHasOtherLinkMembers
                            ? l10n.settingsFamilyMemberLinked
                            : l10n.settingsFamilyMemberLinkHint,
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () async {
                        await Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => FamilyMembersSettingsScreen(
                              db: widget.db,
                              configRepo: widget.configRepo,
                              syncOrchestrator: widget.syncOrchestrator,
                              onConfigSaved: widget.onConfigSaved,
                            ),
                          ),
                        );
                        _loadConfig();
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.child_care, color: iconColor),
                      title: Text(l10n.settingsKids),
                      subtitle: Text(
                        _displayKidsCount > 0
                            ? l10n.settingsKidsEnrolledCount(
                                _displayKidsCount,
                              )
                            : l10n.settingsKidsLinkHint,
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () async {
                        await Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => KidsSettingsScreen(
                              configRepo: widget.configRepo,
                              syncOrchestrator: widget.syncOrchestrator,
                              onConfigSaved: widget.onConfigSaved,
                            ),
                          ),
                        );
                        _loadConfig();
                      },
                    ),
                  ],
              _SectionHeader(label: l10n.settingsSectionVault),
              ListTile(
                leading: Icon(Icons.verified_user_outlined, color: iconColor),
                title: Text(l10n.settingsVerifyPhrase),
                subtitle: Text(l10n.settingsVerifyPhraseSubtitle),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _verifyPhrase(),
              ),
              if (kDebugMode) ...[
                const _SectionHeader(label: 'Debug'),
                ListTile(
                  leading: Icon(Icons.movie_filter_outlined, color: iconColor),
                  title: Text(
                    localeNotifier.value.languageCode == 'nl'
                        ? 'UI-scenario\'s'
                        : 'UI scenarios',
                  ),
                  subtitle: Text(
                    localeNotifier.value.languageCode == 'nl'
                        ? 'Laad testdata voor screenshots'
                        : 'Load test data for screenshots',
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => DemoScenariosScreen(
                          db: widget.db,
                          onApplied: (scenario) {
                            if (scenario == DemoScenario.notes) {
                              widget.onOpenNotesTab?.call();
                            } else {
                              widget.onOpenTasksTab?.call();
                            }
                          },
                        ),
                      ),
                    );
                  },
                ),
              ],
              _SectionHeader(label: l10n.settingsSectionBackup),
              ListTile(
                leading: Icon(Icons.backup_outlined, color: iconColor),
                title: Text(l10n.settingsExportBackup),
                subtitle: Text(l10n.settingsExportBackupSubtitle),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _exportFullBackup(),
              ),
              ListTile(
                leading: Icon(Icons.restore_outlined, color: iconColor),
                title: Text(l10n.settingsImportBackup),
                subtitle: Text(l10n.settingsImportBackupSubtitle),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _importFullBackup(),
              ),
            ],
          );
            },
          );
        },
      ),
    );
  }

  void _showThemeSelector(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.themeChoose),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final theme in AppTheme.values)
                RadioListTile<AppTheme>(
                  title: Text(theme.label(l10n)),
                  subtitle: Text(theme.description(l10n)),
                  value: theme,
                  groupValue: themeNotifier.value,
                  onChanged: (newTheme) async {
                    if (newTheme != null) {
                      themeNotifier.value = newTheme;
                      await widget.settingsRepo.saveTheme(newTheme);
                      if (context.mounted) {
                        Navigator.pop(dialogContext);
                      }
                    }
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLanguageSelector(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.settingsLanguageChoose),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final entry in [
              (const Locale('en'), l10n.settingsLanguageEnglish),
              (const Locale('nl'), l10n.settingsLanguageDutch),
            ])
              RadioListTile<Locale>(
                title: Text(entry.$2),
                value: entry.$1,
                groupValue: localeNotifier.value,
                onChanged: (locale) async {
                  if (locale == null) return;
                  localeNotifier.value = locale;
                  await widget.settingsRepo.saveLocale(locale);
                  if (context.mounted) Navigator.pop(dialogContext);
                },
              ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Combined backup export (.kvault)
  // ---------------------------------------------------------------------------

  Future<void> _exportFullBackup() async {
    final l10n = AppLocalizations.of(context);
    final key = await widget.configRepo.loadPersonalKeyBytes();
    if (key == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.backupNoVault)));
      return;
    }

    if (!mounted) return;
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        content: Row(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(width: 20),
            Text(AppLocalizations.of(ctx).commonExporting),
          ],
        ),
      ),
    );

    try {
      final bytes = await FullBackupService.exportVaultToBytes(
        widget.db,
        key,
        usernameHint: _config?.username ?? '',
        currentThemeName: themeNotifier.value.name,
      );
      final now = DateTime.now();
      final stamp =
          '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';
      final fileName = 'kinetic_backup_$stamp.kvault';

      if (!mounted) return;
      Navigator.of(context).pop();

      final savedUri = await FilePicker.saveFile(
        fileName: fileName,
        bytes: bytes,
      );

      if (!mounted) return;
      if (savedUri != null) {
        final savedPath =
            savedUri.scheme == 'file' ? savedUri.toFilePath() : '$savedUri';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).backupSaved(savedPath)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).backupExportError('$e')),
          ),
        );
      }
    }
  }

  // ---------------------------------------------------------------------------
  // Combined backup import
  // ---------------------------------------------------------------------------

  Future<String?> _askPhrase({
    required String title,
    required String body,
  }) {
    return showMnemonicPhraseDialog(
      context: context,
      title: title,
      body: body,
    );
  }

  /// Warns that import wipes local data — including anything newer than the backup.
  Future<bool> _confirmBackupOverwrite() async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.backupImportOverwriteTitle),
        content: Text(l10n.backupImportOverwriteBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.commonCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l10n.backupImportOverwriteConfirm),
          ),
        ],
      ),
    );
    return confirmed == true;
  }

  Future<void> _verifyPhrase() async {
    final l10n = AppLocalizations.of(context);
    final phrase = await _askPhrase(
      title: l10n.backupVerifyTitle,
      body: l10n.backupVerifyBody,
    );
    if (phrase == null || !mounted) return;
    final vaultRepo = VaultRepository(
      FlutterSecureKeyValueStore(),
      widget.configRepo,
    );
    final ok = await vaultRepo.verifyPhrase(phrase);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(ok ? l10n.backupVerifyOk : l10n.backupVerifyMismatch),
      ),
    );
  }

  Future<void> _importFullBackup() async {
    final l10n = AppLocalizations.of(context);
    if (!await _confirmBackupOverwrite() || !mounted) return;

    final files = await FilePicker.pickFiles(
      type: FileType.any,
    );
    if (files.isEmpty || !mounted) return;

    final fileBytes = await readPlatformFileBytes(files.first);
    if (fileBytes == null || fileBytes.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.backupCouldNotReadFile)));
      return;
    }

    final storedKey = await widget.configRepo.loadPersonalKeyBytes();
    Uint8List? key = storedKey;
    String? phraseForUnlock;

    // Same-device re-import: use the unlocked vault key (no phrase typing).
    // Only ask for 12 words when there is no local key, or the file belongs
    // to a different vault.
    if (key == null) {
      phraseForUnlock = await _askPhrase(
        title: l10n.backupImportTitle,
        body: l10n.backupImportBody,
      );
      if (phraseForUnlock == null ||
          phraseForUnlock.trim().isEmpty ||
          !mounted) {
        return;
      }
      try {
        key = await KineticVault.deriveAesKey(phraseForUnlock);
      } on FormatException catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_backupUserMessage(e, l10n))),
        );
        return;
      }
    }

    if (!mounted) return;
    final importKey = key;
    if (importKey == null) return;

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        content: Row(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(width: 20),
            Text(AppLocalizations.of(ctx).commonImporting),
          ],
        ),
      ),
    );

    Future<void> finishWith(Uint8List decryptKey, {String? phrase}) async {
      await FullBackupService.importVaultFromBytes(
        widget.db,
        fileBytes,
        decryptKey,
        settingsRepo: widget.settingsRepo,
        onThemeRestored: (theme) => themeNotifier.value = theme,
      );
      if (phrase != null) {
        await VaultRepository(
          FlutterSecureKeyValueStore(),
          widget.configRepo,
        ).unlockWithPhrase(phrase);
      }
    }

    try {
      await finishWith(importKey, phrase: phraseForUnlock);
      if (mounted) {
        Navigator.of(context).pop();
        await _loadConfig();
        widget.onRestoreComplete?.call();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context).backupRestored)),
        );
      }
    } on FormatException catch (e) {
      if (!mounted) return;
      Navigator.of(context).pop();

      // Backup from another vault — ask for that file's phrase once.
      if (storedKey != null && _isWrongBackupPhrase(e)) {
        phraseForUnlock = await _askPhrase(
          title: l10n.backupImportTitle,
          body: l10n.backupImportOtherVaultBody,
        );
        if (phraseForUnlock == null ||
            phraseForUnlock.trim().isEmpty ||
            !mounted) {
          return;
        }
        final Uint8List retryKey;
        try {
          retryKey = await KineticVault.deriveAesKey(phraseForUnlock);
        } on FormatException catch (phraseErr) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(_backupUserMessage(phraseErr, l10n))),
          );
          return;
        }
        if (!mounted) return;
        showDialog<void>(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => AlertDialog(
            content: Row(
              children: [
                const CircularProgressIndicator(),
                const SizedBox(width: 20),
                Text(AppLocalizations.of(ctx).commonImporting),
              ],
            ),
          ),
        );
        try {
          await finishWith(retryKey, phrase: phraseForUnlock);
          if (mounted) {
            Navigator.of(context).pop();
            await _loadConfig();
            widget.onRestoreComplete?.call();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(AppLocalizations.of(context).backupRestored),
              ),
            );
          }
        } on FormatException catch (e2) {
          if (mounted) {
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(_backupUserMessage(e2, l10n))),
            );
          }
        } catch (e2) {
          if (mounted) {
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(l10n.backupImportError('$e2'))),
            );
          }
        }
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_backupUserMessage(e, l10n))),
      );
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.backupImportError('$e'))),
        );
      }
    }
  }

  static bool _isWrongBackupPhrase(FormatException e) {
    final m = e.message;
    return m.contains('Verkeerde herstelzin') ||
        m.contains('Wrong recovery phrase');
  }

  static String _backupUserMessage(Object e, AppLocalizations l10n) {
    if (e is FormatException && _isWrongBackupPhrase(e)) {
      return l10n.backupImportWrongPhrase;
    }
    if (e is FormatException) {
      return l10n.backupInvalidFile(e.message);
    }
    return l10n.backupImportError('$e');
  }
}

// ---------------------------------------------------------------------------
// WebDAV setup screen
// ---------------------------------------------------------------------------

class WebDavSetupScreen extends StatefulWidget {
  final AppDatabase db;
  final WebDavConfigRepository configRepo;
  final SettingsRepository? settingsRepo;
  final SyncOrchestrator? syncOrchestrator;
  final VoidCallback? onConfigSaved;
  final VoidCallback? onRestoreComplete;

  const WebDavSetupScreen({
    super.key,
    required this.db,
    required this.configRepo,
    this.settingsRepo,
    this.syncOrchestrator,
    this.onConfigSaved,
    this.onRestoreComplete,
  });

  @override
  State<WebDavSetupScreen> createState() => _WebDavSetupScreenState();
}

class _WebDavSetupScreenState extends State<WebDavSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _urlCtrl = TextEditingController();
  final _userCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  bool _obscurePassword = true;
  bool _testing = false;
  bool _saving = false;
  String? _testResult; // null=untested, 'ok', or error message
  SyncConfig? _existing;

  @override
  void initState() {
    super.initState();
    _loadExisting();
  }

  Future<void> _loadExisting() async {
    final config = await widget.configRepo.load();
    if (config != null && mounted) {
      setState(() {
        _existing = config;
        _urlCtrl.text = config.serverUrl;
        _userCtrl.text = config.username;
        _passCtrl.text = config.password;
      });
    }
  }

  @override
  void dispose() {
    _urlCtrl.dispose();
    _userCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _testConnection() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _testing = true;
      _testResult = null;
    });
    final error = await WebDavEnrollment.testConnection(
      _urlCtrl.text.trim(),
      _userCtrl.text.trim(),
      _passCtrl.text,
    );
    if (mounted) {
      final l10n = AppLocalizations.of(context);
      setState(() {
        _testing = false;
        _testResult =
            error == null ? 'ok' : localizeWebDavConnectionError(l10n, error);
      });
    }
  }

  Future<void> _handleMigration(
    String serverUrl,
    String username,
    String password,
    Uint8List personalKey,
  ) async {
    try {
      final client = WebDavClient(
        baseUrl: serverUrl,
        username: username,
        password: password,
      );

      try {
        final tasksPath = '/kinetic/$username/tasks';
        final notesPath = '/kinetic/$username/notes';

        final taskFiles = await _listServerFiles(client, tasksPath);
        final noteFiles = await _listServerFiles(client, notesPath);

        if (taskFiles.isEmpty && noteFiles.isEmpty) return;

        if (!mounted) return;

        final choice = await showDialog<_MigrationChoice>(
          context: context,
          barrierDismissible: false,
          builder: (ctx) {
            final l10n = AppLocalizations.of(ctx);
            return AlertDialog(
              title: Text(l10n.webdavMigrationTitle),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.webdavMigrationIntro),
                  const SizedBox(height: 8),
                  Text(l10n.webdavMigrationTaskFiles(taskFiles.length)),
                  Text(l10n.webdavMigrationNoteFiles(noteFiles.length)),
                  const SizedBox(height: 16),
                  Text(l10n.webdavMigrationChoose),
                  const SizedBox(height: 12),
                  Text(
                    l10n.webdavMigrationCleanOption,
                    style: const TextStyle(fontSize: 13),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.webdavMigrationImportOption,
                    style: const TextStyle(fontSize: 13),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, _MigrationChoice.clean),
                  child: Text(l10n.webdavMigrationClean),
                ),
                FilledButton(
                  onPressed: () =>
                      Navigator.pop(ctx, _MigrationChoice.importBackup),
                  child: Text(l10n.webdavMigrationImport),
                ),
              ],
            );
          },
        );

        if (choice == null) return;

        if (choice == _MigrationChoice.clean) {
          await _cleanupRemoteFiles(client, taskFiles, noteFiles);
          return;
        }

        // --- Import backup flow ---
        if (!mounted) return;
        final overwriteOk = await showDialog<bool>(
          context: context,
          builder: (ctx) {
            final d = AppLocalizations.of(ctx);
            return AlertDialog(
              title: Text(d.backupImportOverwriteTitle),
              content: Text(d.backupImportOverwriteBody),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: Text(d.commonCancel),
                ),
                FilledButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  child: Text(d.backupImportOverwriteConfirm),
                ),
              ],
            );
          },
        );
        if (overwriteOk != true || !mounted) return;

        final files = await FilePicker.pickFiles(
          type: FileType.any,
        );
        if (files.isEmpty) return;
        final fileBytes = await readPlatformFileBytes(files.first);
        if (fileBytes == null || fileBytes.isEmpty) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  AppLocalizations.of(context).backupCouldNotReadFile,
                ),
              ),
            );
          }
          return;
        }

        if (!mounted) return;
        showDialog<void>(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => AlertDialog(
            content: Row(
              children: [
                const CircularProgressIndicator(),
                const SizedBox(width: 20),
                Text(AppLocalizations.of(ctx).backupRestoring),
              ],
            ),
          ),
        );

        try {
          await FullBackupService.importVaultFromBytes(
            widget.db,
            fileBytes,
            personalKey,
            settingsRepo: widget.settingsRepo,
            onThemeRestored: (theme) => themeNotifier.value = theme,
          );
          if (mounted) {
            Navigator.of(context).pop(); // dismiss progress
            widget.onRestoreComplete?.call();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  AppLocalizations.of(context).webdavBackupRestoredSync,
                ),
              ),
            );
          }
        } catch (e) {
          if (mounted) {
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  AppLocalizations.of(context).webdavRestoreError('$e'),
                ),
              ),
            );
          }
        }
      } finally {
        client.dispose();
      }
    } catch (e, st) {
      debugPrint('[Migration] Error: $e');
      debugPrintStack(stackTrace: st);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context).webdavMigrationCheckFailed('$e'),
            ),
          ),
        );
      }
    }
  }

  Future<List<String>> _listServerFiles(
    WebDavClient client,
    String path,
  ) async {
    try {
      final entries = await client.propfind(path);
      // PROPFIND depth-1 includes the collection itself. Some servers omit
      // <d:collection/>, so !isCollection alone falsely counts the folder as
      // a file (exactly one "task" + one "note" on a clean empty server).
      // Only Kinetic .ics blobs are real encrypted data files.
      final basePath = Uri.parse(client.baseUrl).path;
      final collectionNorm = path.endsWith('/')
          ? path.substring(0, path.length - 1)
          : path;
      return entries
          .where((e) {
            final hrefPath = e.href.split('?').first;
            if (!hrefPath.endsWith('.ics')) return false;
            final stripped = (basePath.isNotEmpty && hrefPath.startsWith(basePath))
                ? hrefPath.substring(basePath.length)
                : hrefPath;
            final norm =
                stripped.endsWith('/') ? stripped.substring(0, stripped.length - 1) : stripped;
            return norm != collectionNorm;
          })
          .map((e) {
            final href = e.href.split('?').first;
            if (basePath.isNotEmpty && href.startsWith(basePath)) {
              return href.substring(basePath.length);
            }
            return href;
          })
          .toList();
    } catch (e) {
      debugPrint('[Migration] Error listing $path: $e');
      return [];
    }
  }

  Future<void> _cleanupRemoteFiles(
    WebDavClient client,
    List<String> taskFiles,
    List<String> noteFiles,
  ) async {
    try {
      // Delete task files
      for (final file in taskFiles) {
        try {
          await client.delete(file);
        } catch (e) {
          debugPrint('[Migration] Error deleting task file $file: $e');
        }
      }

      // Delete note files
      for (final file in noteFiles) {
        try {
          await client.delete(file);
        } catch (e) {
          debugPrint('[Migration] Error deleting note file $file: $e');
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(
                context,
              ).webdavFilesDeleted(taskFiles.length + noteFiles.length),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context).webdavCleanupError('$e'),
            ),
          ),
        );
      }
    }
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context);
    if (_testResult != 'ok') {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.webdavTestFirst)));
      return;
    }

    setState(() => _saving = true);

    try {
      final serverUrl = _urlCtrl.text.trim();
      final username = _userCtrl.text.trim();
      final password = _passCtrl.text;

      final bool isSameAccount =
          _existing != null &&
          _existing!.username == username &&
          _existing!.serverUrl == serverUrl;

      final Uint8List personalKey;
      final existingKey = await widget.configRepo.loadPersonalKeyBytes();
      if (existingKey == null) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(l10n.webdavCreateVaultFirst)));
        }
        setState(() => _saving = false);
        return;
      }
      personalKey = existingKey;

      // Reuse existing linkId, or generate a stable UUID for a new account.
      final String linkId = (isSameAccount && _existing!.linkId.isNotEmpty)
          ? _existing!.linkId
          : const Uuid().v4();

      // Preserve family key only when editing the same server+user. A new
      // WebDAV identity must not reuse a leftover family key (that skipped the
      // "others already on this folder" prompt).
      if (!isSameAccount) {
        await widget.configRepo.clearFamilyLinkageForNewAccount();
      }
      final existingFamilyKey =
          isSameAccount ? _existing!.familyKeyBytes : null;

      // Always ensure directories exist (needed for both new and updated configs)
      final client = WebDavClient(
        baseUrl: serverUrl,
        username: username,
        password: password,
      );
      var familyRestored = false;
      KineticFolderProbeResult? folderProbe;
      try {
        await WebDavEnrollment.setupDirectories(client, username);
        final meta = await KineticVaultRemote.ensureMeta(
          client: client,
          username: username,
          key: personalKey,
        );
        if (meta == VaultMetaStatus.wrongPhrase) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  AppLocalizations.of(context).webdavPhraseMismatchServer,
                ),
              ),
            );
          }
          setState(() => _saving = false);
          return;
        }
        final localFamily = existingFamilyKey;
        if (localFamily == null) {
          familyRestored = await FamilyVaultSync.pullIfPresent(
            client: client,
            username: username,
            personalKey: personalKey,
            configRepo: widget.configRepo,
          );
          if (!familyRestored) {
            folderProbe = await KineticFolderProbe.probe(
              client: client,
              username: username,
            );
          }
        } else {
          final entropy = await widget.configRepo.loadFamilyEntropy();
          if (entropy != null) {
            await KineticVaultRemote.pushFamilyRecovery(
              client: client,
              username: username,
              personalKey: personalKey,
              familyKey: localFamily,
              entropy: entropy,
            );
          }
        }
      } finally {
        client.dispose();
      }

      final familyKeyToSave =
          existingFamilyKey ?? await widget.configRepo.loadFamilyKey();

      await widget.configRepo.save(
        SyncConfig(
          serverUrl: serverUrl,
          username: username,
          password: password,
          linkId: linkId,
          personalKeyBytes: personalKey,
          familyKeyBytes: familyKeyToSave,
        ),
      );
      if (familyKeyToSave == null) {
        await widget.configRepo.ensureFamilySetupEligibleSince();
      } else {
        await widget.configRepo.clearFamilySetupPrompt();
      }

      // Mark all existing non-deleted items as dirty so they'll be synced to the server
      if (_existing == null) {
        // Only do this on first-time setup, not on edits
        // Include items with syncState='clean' or NULL (for items created before sync was added)
        await (widget.db.update(
              widget.db.personalTasks,
            )..where((t) => t.syncState.equals('clean') | t.syncState.isNull()))
            .write(PersonalTasksCompanion(syncState: const Value('dirty')));
        await (widget.db.update(
              widget.db.personalNotes,
            )..where((n) => n.syncState.equals('clean') | n.syncState.isNull()))
            .write(PersonalNotesCompanion(syncState: const Value('dirty')));

        // Check for existing remote data and ask user what to do
        if (mounted) {
          await _handleMigration(serverUrl, username, password, personalKey);
        }
      }

      if (!mounted) return;

      if (familyRestored) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.webdavFamilyRestored)),
        );
      }

      if (familyKeyToSave == null &&
          folderProbe != null &&
          folderProbe.suggestsExistingFamily) {
        await _offerJoinExistingFamily(
          probe: folderProbe,
          serverUrl: serverUrl,
          username: username,
          password: password,
          linkId: linkId,
          personalKey: personalKey,
        );
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.webdavConfigSaved)),
      );
      widget.onConfigSaved?.call();
      Navigator.of(context).pop();
    } on Exception catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).webdavSaveError('$e')),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  /// Propose a fast family link when other Kinetic data is already on this folder.
  Future<void> _offerJoinExistingFamily({
    required KineticFolderProbeResult probe,
    required String serverUrl,
    required String username,
    required String password,
    required String linkId,
    required Uint8List personalKey,
  }) async {
    final l10n = AppLocalizations.of(context);
    final peers = probe.otherUsernames;
    final linkNow = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.webdavJoinFamilyTitle),
        content: Text(
          peers.length == 1
              ? l10n.webdavJoinFamilyMembersOne(peers.single)
              : peers.length > 1
              ? '${l10n.webdavJoinFamilyMembersMany(peers.length)}\n${peers.map((n) => '• $n').join('\n')}'
              : l10n.webdavJoinFamilySharedOnly,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.webdavJoinFamilyLater),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l10n.webdavJoinFamilyLink),
          ),
        ],
      ),
    );
    if (linkNow != true || !mounted) return;

    final config = SyncConfig(
      serverUrl: serverUrl,
      username: username,
      password: password,
      linkId: linkId,
      personalKeyBytes: personalKey,
      familyKeyBytes: null,
    );
    final linked = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => FamilyKeyScanScreen(
          currentConfig: config,
          configRepo: widget.configRepo,
        ),
      ),
    );
    if (linked == true) {
      await widget.configRepo.setHasOtherLinkMembers(true);
      await FamilyVaultSync.pushIfPossible(widget.configRepo);
      await widget.configRepo.clearFamilySetupPrompt();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.webdavSetupTitle), centerTitle: false),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Server URL
            TextFormField(
              controller: _urlCtrl,
              decoration: InputDecoration(
                labelText: l10n.vaultServerUrl,
                hintText: 'https://nextcloud.example.com/remote.php/dav',
                prefixIcon: const Icon(Icons.link),
              ),
              keyboardType: TextInputType.url,
              autocorrect: false,
              onChanged: (_) => setState(() => _testResult = null),
              validator: (v) => WebDavUrl.validationError(
                v,
                emptyMessage: l10n.webdavUrlRequired,
              ),
            ),
            const SizedBox(height: 16),
            // Username
            TextFormField(
              controller: _userCtrl,
              decoration: InputDecoration(
                labelText: l10n.vaultUsername,
                prefixIcon: const Icon(Icons.person_outline),
              ),
              autocorrect: false,
              onChanged: (_) => setState(() => _testResult = null),
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? l10n.webdavUsernameRequired
                  : null,
            ),
            const SizedBox(height: 16),
            // Password
            TextFormField(
              controller: _passCtrl,
              decoration: InputDecoration(
                labelText: l10n.vaultPassword,
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),
              obscureText: _obscurePassword,
              onChanged: (_) => setState(() => _testResult = null),
              validator: (v) =>
                  (v == null || v.isEmpty) ? l10n.webdavPasswordRequired : null,
            ),
            const SizedBox(height: 28),
            // Test connection button
            OutlinedButton.icon(
              onPressed: _testing ? null : _testConnection,
              icon: _testing
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.wifi_tethering),
              label: Text(
                _testing
                    ? l10n.webdavTestingConnection
                    : l10n.webdavTestConnection,
              ),
            ),
            if (_testResult != null) ...[
              const SizedBox(height: 12),
              _TestResultBanner(result: _testResult!),
            ],
            const SizedBox(height: 16),
            // Save button
            FilledButton.icon(
              onPressed: _saving ? null : _save,
              icon: _saving
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.save_outlined),
              label: Text(_saving ? l10n.commonSaving : l10n.commonSave),
            ),
            if (_existing != null) ...[
              const SizedBox(height: 32),
              TextButton.icon(
                onPressed: _saving ? null : _turnOffWebDav,
                style: TextButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.error,
                ),
                icon: const Icon(Icons.cloud_off_outlined),
                label: Text(l10n.settingsWebDavTurnOff),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _turnOffWebDav() async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.settingsWebDavTurnOffTitle),
        content: Text(l10n.settingsWebDavTurnOffBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.commonCancel),
          ),
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(ctx).colorScheme.error,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l10n.settingsWebDavTurnOffConfirm),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _saving = true);
    try {
      try {
        await widget.syncOrchestrator?.pushDisconnect();
      } catch (_) {}

      await (widget.db.delete(
        widget.db.personalNotes,
      )..where((n) => n.isShared.equals(true))).go();
      await widget.db.delete(widget.db.linkMemberProposals).go();
      await widget.configRepo.disconnectWebDav();

      if (!mounted) return;
      widget.onConfigSaved?.call();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.settingsWebDavTurnedOff)),
      );
      Navigator.of(context).pop();
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}

// ---------------------------------------------------------------------------
// Test result banner
// ---------------------------------------------------------------------------

class _TestResultBanner extends StatelessWidget {
  final String result; // 'ok' or error message

  const _TestResultBanner({required this.result});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isOk = result == 'ok';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isOk
            ? Colors.green.withValues(alpha: 0.15)
            : Colors.red.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isOk ? Colors.green : Colors.redAccent,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            isOk ? Icons.check_circle_outline : Icons.error_outline,
            color: isOk ? Colors.green : Colors.redAccent,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              isOk ? l10n.webdavConnectionOk : result,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: isOk ? Colors.green : Colors.redAccent,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Section header
// ---------------------------------------------------------------------------

class _SectionHeader extends StatelessWidget {
  final String label;
  final Widget? trailing;

  const _SectionHeader({required this.label, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label.toUpperCase(),
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.8,
              ),
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

enum _MigrationChoice { clean, importBackup }
