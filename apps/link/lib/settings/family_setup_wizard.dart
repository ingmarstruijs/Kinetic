import 'package:flutter/material.dart';
import 'package:kinetic_webdav/kinetic_webdav.dart';

import '../db/app_database.dart';
import '../l10n/generated/app_localizations.dart';
import '../sync/sync_orchestrator.dart';
import '../sync/webdav_config_repository.dart';
import '../theme/app_header.dart';
import 'family_members_settings_screen.dart';
import 'kids_settings_screen.dart';
import 'settings_repository.dart';
import 'settings_screen.dart' show WebDavSetupScreen;

/// Guided Start-family flow: WebDAV → family → invite → kids → done.
class FamilySetupWizard extends StatefulWidget {
  final AppDatabase db;
  final WebDavConfigRepository configRepo;
  final SettingsRepository settingsRepo;
  final SyncOrchestrator? syncOrchestrator;
  final VoidCallback? onConfigSaved;
  final VoidCallback? onRestoreComplete;
  final VoidCallback? onOpenTasksTab;

  const FamilySetupWizard({
    super.key,
    required this.db,
    required this.configRepo,
    required this.settingsRepo,
    this.syncOrchestrator,
    this.onConfigSaved,
    this.onRestoreComplete,
    this.onOpenTasksTab,
  });

  @override
  State<FamilySetupWizard> createState() => _FamilySetupWizardState();
}

class _FamilySetupWizardState extends State<FamilySetupWizard> {
  int _step = 0;
  SyncConfig? _config;
  bool _hasFamilyKey = false;
  bool _hasOtherMembers = false;
  int _kidsCount = 0;

  static const _stepCount = 5;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    final config = await widget.configRepo.load();
    final hasKey = config?.familyKeyBytes != null;
    final paired = await widget.configRepo.hasOtherLinkMembers();
    final kids = await widget.configRepo.loadEnrolledKids();
    if (!mounted) return;
    setState(() {
      _config = config;
      _hasFamilyKey = hasKey;
      _hasOtherMembers = paired;
      _kidsCount = kids.length;
    });
  }

  Future<void> _openWebDav() async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => WebDavSetupScreen(
          db: widget.db,
          configRepo: widget.configRepo,
          settingsRepo: widget.settingsRepo,
          syncOrchestrator: widget.syncOrchestrator,
          onConfigSaved: () {
            widget.onConfigSaved?.call();
            _refresh();
          },
          onRestoreComplete: widget.onRestoreComplete,
        ),
      ),
    );
    await _refresh();
  }

  Future<void> _openFamily() async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => FamilyMembersSettingsScreen(
          db: widget.db,
          configRepo: widget.configRepo,
          syncOrchestrator: widget.syncOrchestrator,
          onConfigSaved: () {
            widget.onConfigSaved?.call();
            _refresh();
          },
        ),
      ),
    );
    await _refresh();
  }

  Future<void> _openKids() async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => KidsSettingsScreen(
          configRepo: widget.configRepo,
          syncOrchestrator: widget.syncOrchestrator,
          onConfigSaved: () {
            widget.onConfigSaved?.call();
            _refresh();
          },
        ),
      ),
    );
    await _refresh();
  }

  bool get _webDavOk => _config != null;
  bool get _familyOk => _hasFamilyKey;
  bool get _inviteOk => _hasOtherMembers;
  bool get _kidsOk => _kidsCount > 0;

  void _next() {
    if (_step < _stepCount - 1) {
      setState(() => _step++);
    } else {
      Navigator.of(context).pop();
      widget.onOpenTasksTab?.call();
    }
  }

  void _skip() => _next();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final titles = [
      l10n.wizardStepWebDav,
      l10n.wizardStepFamily,
      l10n.wizardStepInvite,
      l10n.wizardStepKids,
      l10n.wizardStepDone,
    ];

    return Scaffold(
      appBar: AppBar(
        title: AppHeader(title: l10n.wizardTitle, centerTitle: false),
        centerTitle: false,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
            child: Row(
              children: List.generate(_stepCount, (i) {
                final done = i < _step;
                final current = i == _step;
                return Expanded(
                  child: Container(
                    margin: EdgeInsets.only(right: i < _stepCount - 1 ? 6 : 0),
                    height: 4,
                    decoration: BoxDecoration(
                      color: done || current
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                );
              }),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                titles[_step],
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
          ),
          Expanded(child: _buildStepBody(l10n)),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
              child: Row(
                children: [
                  if (_step < _stepCount - 1)
                    TextButton(
                      onPressed: _skip,
                      child: Text(l10n.wizardSkip),
                    ),
                  const Spacer(),
                  FilledButton(
                    onPressed: _next,
                    child: Text(
                      _step == _stepCount - 1
                          ? l10n.wizardDone
                          : l10n.wizardNext,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepBody(AppLocalizations l10n) {
    return switch (_step) {
      0 => _StepCard(
          done: _webDavOk,
          body: l10n.settingsWebDavConnectHint,
          actionLabel: l10n.settingsWebDavConfigure,
          onAction: _openWebDav,
        ),
      1 => _StepCard(
          done: _familyOk,
          body: l10n.settingsFamilyMemberLinkHint,
          actionLabel: l10n.settingsFamilyMembers,
          onAction: _webDavOk ? _openFamily : null,
        ),
      2 => _StepCard(
          done: _inviteOk,
          body: l10n.wizardInviteHint,
          actionLabel: l10n.familyKeyShareTitle,
          onAction: _familyOk ? _openFamily : null,
        ),
      3 => _StepCard(
          done: _kidsOk,
          body: l10n.wizardKidsPasswordHint,
          actionLabel: l10n.settingsKids,
          onAction: _webDavOk ? _openKids : null,
        ),
      _ => _StepCard(
          done: true,
          body: l10n.wizardFirstSuccessHint,
          actionLabel: l10n.wizardOpenTasks,
          onAction: () {
            Navigator.of(context).pop();
            widget.onOpenTasksTab?.call();
          },
        ),
    };
  }
}

class _StepCard extends StatelessWidget {
  final bool done;
  final String body;
  final String actionLabel;
  final VoidCallback? onAction;

  const _StepCard({
    required this.done,
    required this.body,
    required this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      children: [
        if (done)
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.check_circle, color: scheme.primary),
            title: Text(AppLocalizations.of(context).wizardStepDone),
          ),
        Text(body, style: Theme.of(context).textTheme.bodyLarge),
        const SizedBox(height: 24),
        FilledButton.tonal(
          onPressed: onAction,
          child: Text(actionLabel),
        ),
      ],
    );
  }
}
