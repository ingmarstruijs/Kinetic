import 'dart:async';

import 'package:flutter/material.dart';
import 'package:kinetic_webdav/kinetic_webdav.dart';

import '../db/app_database.dart';
import '../debug/demo_session.dart';
import '../l10n/generated/app_localizations.dart';
import '../sync/sync_orchestrator.dart';
import '../sync/webdav_config_repository.dart';
import '../theme/app_themes.dart';
import '../vault/family_vault_sync.dart';
import '../vault/screens/family_create_screen.dart';
import '../vault/screens/family_key_rotation_wizard_screen.dart';
import '../vault/screens/mnemonic_reveal_screen.dart';
import '../vault/widgets/mnemonic_phrase_field.dart';
import 'family_key_scan_screen.dart';
import 'family_key_share_screen.dart';
import 'kids_enrollment_qr_screen.dart';
import 'models/enrolled_kid.dart';

/// Optional deep-link into a primary hub action.
enum FamilyHubAction { start, join, invite, kids }

// ---------------------------------------------------------------------------
// FamilyMembersSettingsScreen — Family hub
//
// Invite adults / invite kids, join family, and a unified Adults + Kids roster.
// Only reachable when WebDAV is configured.
// ---------------------------------------------------------------------------

class FamilyMembersSettingsScreen extends StatefulWidget {
  final AppDatabase db;
  final WebDavConfigRepository configRepo;
  final SyncOrchestrator? syncOrchestrator;
  final VoidCallback? onConfigSaved;
  final FamilyHubAction? initialAction;

  const FamilyMembersSettingsScreen({
    super.key,
    required this.db,
    required this.configRepo,
    this.syncOrchestrator,
    this.onConfigSaved,
    this.initialAction,
  });

  @override
  State<FamilyMembersSettingsScreen> createState() =>
      _FamilyMembersSettingsScreenState();
}

class _FamilyMembersSettingsScreenState
    extends State<FamilyMembersSettingsScreen>
    with WidgetsBindingObserver {
  SyncConfig? _config;
  bool _hasOtherLinkMembers = false;
  List<PresenceInfo> _presenceList = [];
  Map<String, PresenceInfo> _presenceByKidId = {};
  List<FamilyLinkMember> _otherLinkMembers = const [];
  List<EnrolledKid> _kids = const [];
  String? _fingerprint;
  var _didRunInitialAction = false;
  var _refreshing = false;

  bool get _hasFamilyKey => _config?.familyKeyBytes != null;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    DemoSession.instance.addListener(_onDemoChanged);
    unawaited(_bootstrap());
  }

  Future<void> _bootstrap() async {
    await _loadConfig();
    if (!mounted) return;
    // Pull roster/presence so Adults update after a partner joins without
    // requiring a full home sync first.
    await _refreshFamily();
    if (!mounted || _didRunInitialAction) return;
    _didRunInitialAction = true;
    final action = widget.initialAction;
    if (action == null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      switch (action) {
        case FamilyHubAction.start:
          _startFamily();
        case FamilyHubAction.join:
          _importFamilyKey();
        case FamilyHubAction.invite:
          _exportFamilyKey();
        case FamilyHubAction.kids:
          _inviteKid();
      }
    });
  }

  /// Syncs roster + presence from WebDAV, then reloads local hub state.
  Future<void> _refreshFamily() async {
    if (_refreshing || DemoSession.instance.active) return;
    _refreshing = true;
    if (mounted) setState(() {});
    try {
      await widget.syncOrchestrator?.syncFamilyState();
      if (!mounted) return;
      await _loadConfig();
      if (!mounted) return;
      await _loadPresence();
    } finally {
      _refreshing = false;
      if (mounted) setState(() {});
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(_refreshFamily());
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    DemoSession.instance.removeListener(_onDemoChanged);
    super.dispose();
  }

  void _onDemoChanged() {
    if (!mounted || !DemoSession.instance.active) return;
    setState(() {
      _kids = List.of(DemoSession.instance.kids);
      _otherLinkMembers = DemoSession.instance.otherLinkMembers
          .map(
            (m) => FamilyLinkMember(
              id: m.id,
              displayName: m.name,
              joinedAt: DateTime.now().toUtc(),
              updatedAt: DateTime.now().toUtc(),
            ),
          )
          .toList();
    });
  }

  Future<void> _loadConfig() async {
    if (DemoSession.instance.active) {
      if (mounted) {
        setState(() {
          _kids = List.of(DemoSession.instance.kids);
          _otherLinkMembers = DemoSession.instance.otherLinkMembers
              .map(
                (m) => FamilyLinkMember(
                  id: m.id,
                  displayName: m.name,
                  joinedAt: DateTime.now().toUtc(),
                  updatedAt: DateTime.now().toUtc(),
                ),
              )
              .toList();
          _hasOtherLinkMembers = _otherLinkMembers.isNotEmpty;
        });
      }
      return;
    }
    final config = await widget.configRepo.load();
    final paired = await widget.configRepo.hasOtherLinkMembers();
    final roster = await widget.configRepo.loadCachedRoster();
    final kids = await widget.configRepo.loadEnrolledKids();
    String? fingerprint;
    if (config?.familyKeyBytes != null) {
      fingerprint = await KineticVault.fingerprint(config!.familyKeyBytes!);
    }
    if (mounted) {
      setState(() {
        _config = config;
        _hasOtherLinkMembers = paired;
        _fingerprint = fingerprint;
        _otherLinkMembers =
            roster?.otherLinkMembers(config?.linkId ?? '') ?? const [];
        _kids = kids;
      });
    }
  }

  Future<void> _loadPresence() async {
    final orchestrator = widget.syncOrchestrator;
    if (orchestrator == null) return;
    try {
      final presence = await orchestrator.pullPresence();
      final kidPresence = <String, PresenceInfo>{};
      for (final p in presence) {
        if (p.deviceType == 'kid') kidPresence[p.deviceId] = p;
      }
      var activated = false;
      for (final kidId in kidPresence.keys) {
        final updated = await widget.configRepo.activateEnrolledKid(kidId);
        if (updated != null) activated = true;
      }
      if (activated) {
        await _loadConfig();
        // Push activated status onto the shared roster for other Links.
        unawaited(widget.syncOrchestrator?.sync() ?? Future<void>.value());
      }
      if (mounted) {
        setState(() {
          _presenceList = presence;
          _presenceByKidId = kidPresence;
        });
      }
    } catch (_) {}
  }

  Future<bool> _ensureFamilyVault() async {
    final existing = await widget.configRepo.loadFamilyKey();
    if (existing != null) return true;
    if (!mounted) return false;
    final created = await Navigator.of(context).push<FamilyCreateResult>(
      MaterialPageRoute(builder: (_) => const FamilyCreateScreen()),
    );
    if (created == null) return false;
    await widget.configRepo.saveFamilyKey(
      created.key,
      entropy: created.entropy,
    );
    await FamilyVaultSync.pushIfPossible(widget.configRepo);
    await _loadConfig();
    return true;
  }

  Future<void> _exportFamilyKey() async {
    if (_config == null) return;
    if (!await _ensureFamilyVault()) return;
    if (!mounted) return;
    final config = await widget.configRepo.load();
    if (config == null || !mounted) return;
    final entropy = await widget.configRepo.loadFamilyEntropy();
    if (!mounted) return;
    final keyWasGenerated = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => FamilyKeyShareScreen(
          config: config,
          configRepo: widget.configRepo,
          entropy: entropy,
        ),
      ),
    );
    if ((keyWasGenerated ?? false) && mounted) {
      await widget.configRepo.setHasOtherLinkMembers(true);
      await FamilyVaultSync.pushIfPossible(widget.configRepo);
    }
    // Always refresh: the partner may have joined while the QR was open.
    await _refreshFamily();
    if (mounted) widget.onConfigSaved?.call();
  }

  Future<void> _startFamily() async {
    if (!await _ensureFamilyVault()) return;
    await _refreshFamily();
    if (mounted) widget.onConfigSaved?.call();
  }

  /// Invite kid: ensure family key, then name → enrollment QR.
  Future<void> _inviteKid() async {
    if (!await _ensureFamilyVault()) return;
    final config = await widget.configRepo.load();
    if (!mounted || config == null || config.familyKeyBytes == null) return;
    widget.onConfigSaved?.call();

    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => KidsEnrollmentQrScreen(
          config: config,
          configRepo: widget.configRepo,
          onKidRegistered: _loadConfig,
        ),
      ),
    );
    await _refreshFamily();
    if (mounted) widget.onConfigSaved?.call();
  }

  Future<void> _importFamilyKey() async {
    if (_hasFamilyKey) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.familyKeyAlreadyPairedWarning)),
      );
      return;
    }
    if (_config == null) return;
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => FamilyKeyScanScreen(
          currentConfig: _config!,
          configRepo: widget.configRepo,
        ),
      ),
    );
    if (result == true && mounted) {
      await widget.configRepo.setHasOtherLinkMembers(true);
      await FamilyVaultSync.pushIfPossible(widget.configRepo);
    }
    await _refreshFamily();
    if (mounted) widget.onConfigSaved?.call();
  }

  Future<void> _leaveFamily() async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.familyMemberUnlinkTitle),
        content: SingleChildScrollView(
          child: Text(l10n.familyMemberUnlinkBody),
        ),
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
            child: Text(l10n.commonLeave),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    final kids = List<EnrolledKid>.of(_kids);
    for (final kid in kids) {
      try {
        await widget.syncOrchestrator?.pushKidDisconnect(kid);
      } catch (_) {}
    }
    try {
      await widget.syncOrchestrator?.pushDisconnect();
    } catch (_) {}

    await (widget.db.delete(
      widget.db.personalNotes,
    )..where((n) => n.isShared.equals(true))).go();
    await widget.db.delete(widget.db.linkMemberProposals).go();
    await widget.configRepo.clearEnrolledKids();
    await widget.configRepo.clearFamilyKey();
    if (!mounted) return;
    widget.onConfigSaved?.call();
    Navigator.of(context).pop();
  }

  Future<void> _verifyFamilyPhrase() async {
    final stored = await widget.configRepo.loadFamilyKey();
    if (stored == null || !mounted) return;
    final l10n = AppLocalizations.of(context);
    final phrase = await showMnemonicPhraseDialog(
      context: context,
      title: l10n.familyMemberVerifyTitle,
      body: l10n.familyMemberVerifyBody,
      confirmLabel: l10n.commonVerify,
    );
    if (phrase == null || !mounted) return;
    try {
      final derived = await KineticVault.deriveAesKey(phrase);
      final ok = KineticVault.equalKeys(stored, derived);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            ok ? l10n.familyMemberVerifyOk : l10n.familyMemberVerifyMismatch,
          ),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.familyMemberVerifyMismatch)),
      );
    }
  }

  Future<void> _revealFamilyPhrase() async {
    final l10n = AppLocalizations.of(context);
    await showMnemonicReveal(
      context: context,
      title: l10n.familyCreateTitle,
      loadWords: () async {
        final entropy = await widget.configRepo.loadFamilyEntropy();
        if (entropy == null) return null;
        return KineticVault.mnemonicFromEntropy(entropy);
      },
      missingMessage: l10n.familyMemberRevealMissing,
    );
  }

  Future<void> _confirmRemoveMember(FamilyLinkMember member) async {
    final l10n = AppLocalizations.of(context);
    final name = member.displayName.isEmpty
        ? l10n.familyMemberGenericName
        : member.displayName;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.familyMemberRemoveTitle(name)),
        content: Text(l10n.familyMemberRemoveBody(name)),
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
            child: Text(l10n.commonDelete),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    try {
      await widget.syncOrchestrator?.removeLinkMember(member.id);
    } catch (_) {}
    await _loadConfig();
    await _loadPresence();
    if (mounted) widget.onConfigSaved?.call();
    if (!mounted) return;
    await _offerFamilyKeyRotationAfterRemove();
  }

  Future<void> _confirmRemoveKid(EnrolledKid kid) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.kidsRemoveTitle(kid.name)),
        content: Text(l10n.kidsRemoveBody(kid.name)),
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
            child: Text(l10n.commonDelete),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    try {
      await widget.syncOrchestrator?.pushKidDisconnect(kid);
    } catch (_) {}
    if (DemoSession.instance.active) {
      DemoSession.instance.removeKid(kid.id);
    } else {
      await widget.configRepo.removeEnrolledKid(kid.id);
    }
    await _loadConfig();
    if (mounted) widget.onConfigSaved?.call();
  }

  Future<void> _toggleKidXp(EnrolledKid kid) async {
    final updated = kid.copyWith(xpEnabled: !kid.xpEnabled);
    if (DemoSession.instance.active) {
      DemoSession.instance.updateKid(updated);
      return;
    }
    await widget.configRepo.updateEnrolledKid(updated);
    await _loadConfig();
    if (mounted) widget.onConfigSaved?.call();
  }

  Future<void> _markKidActive(EnrolledKid kid) async {
    if (DemoSession.instance.active) return;
    await widget.configRepo.activateEnrolledKid(kid.id);
    await _loadConfig();
    if (mounted) widget.onConfigSaved?.call();
  }

  Future<void> _offerFamilyKeyRotationAfterRemove() async {
    final l10n = AppLocalizations.of(context);
    final rotate = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.familyKeyRotationOfferTitle),
        content: Text(l10n.familyKeyRotationOfferBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.familyKeyRotationOfferLater),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l10n.familyKeyRotationOfferNow),
          ),
        ],
      ),
    );
    if (rotate != true || !mounted) return;
    await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => FamilyKeyRotationWizardScreen(
          db: widget.db,
          configRepo: widget.configRepo,
          onFinished: widget.onConfigSaved,
        ),
      ),
    );
    if (mounted) {
      await _loadConfig();
      widget.onConfigSaved?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final demo = DemoSession.instance;
    if (demo.active) {
      return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerLowest,
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.surfaceContainerLowest,
          title: Text(l10n.settingsFamilyMembers),
          centerTitle: false,
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            _sectionHeader(context, l10n.settingsFamilyHubAdultsSection),
            if (demo.otherLinkMembers.isEmpty)
              _emptyCard(
                context,
                icon: Icons.groups_outlined,
                text: l10n.settingsFamilyHubAdultsNone,
              )
            else
              _HubCard(
                children: [
                  for (var i = 0; i < demo.otherLinkMembers.length; i++) ...[
                    if (i > 0) const _CardDivider(),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      child: ListTile(
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 8),
                        leading: const _HubIconBadge(icon: Icons.person_outline),
                        title: Text(demo.otherLinkMembers[i].name),
                        subtitle: Text(
                          _demoPresenceSubtitle(
                            l10n,
                            demo.otherLinkMembers[i].name,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            _sectionHeader(context, l10n.settingsFamilyHubKidsSection),
            if (_kids.isEmpty)
              _emptyCard(
                context,
                icon: Icons.face_outlined,
                text: l10n.kidsNoneEnrolled,
              )
            else
              _HubCard(
                children: [
                  for (var i = 0; i < _kids.length; i++) ...[
                    if (i > 0) const _CardDivider(),
                    _buildKidTile(context, l10n, _kids[i]),
                  ],
                ],
              ),
          ],
        ),
      );
    }

    final config = _config;
    final paired = _hasOtherLinkMembers;
    final hasKey = _hasFamilyKey;

    final partnerPresence = _presenceList
        .where((p) => p.deviceType == 'link')
        .toList();

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerLowest,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerLowest,
        title: Text(l10n.settingsFamilyMembers),
        centerTitle: false,
        actions: [
          if (hasKey)
            PopupMenuButton<_FamilyMenuAction>(
              tooltip: l10n.settingsFamilyMembers,
              onSelected: (action) {
                switch (action) {
                  case _FamilyMenuAction.verify:
                    _verifyFamilyPhrase();
                  case _FamilyMenuAction.showKey:
                    _revealFamilyPhrase();
                  case _FamilyMenuAction.leave:
                    _leaveFamily();
                }
              },
              itemBuilder: (ctx) => [
                PopupMenuItem(
                  value: _FamilyMenuAction.verify,
                  child: Text(l10n.familyMemberVerifyPhrase),
                ),
                PopupMenuItem(
                  value: _FamilyMenuAction.showKey,
                  child: Text(l10n.familyMemberShowKey),
                ),
                PopupMenuItem(
                  value: _FamilyMenuAction.leave,
                  child: Text(
                    l10n.familyMemberUnlink,
                    style: TextStyle(
                      color: Theme.of(ctx).colorScheme.error,
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshFamily,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
          if (_refreshing)
            const Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: LinearProgressIndicator(minHeight: 2),
            ),
          if (config != null) ...[
            _HubCard(
              children: [
                _FamilyKeySummary(
                  fingerprint: _fingerprint,
                  paired: paired,
                  presenceList: partnerPresence,
                ),
                if (!hasKey) ...[
                  const _CardDivider(),
                  _hubActionRow(
                    context,
                    icon: Icons.family_restroom,
                    title: l10n.settingsFamilyHubStart,
                    trailing: const Icon(Icons.chevron_right),
                    onTap: _startFamily,
                  ),
                  const _CardDivider(),
                  _hubActionRow(
                    context,
                    icon: Icons.qr_code_scanner,
                    title: l10n.settingsFamilyHubJoin,
                    trailing: const Icon(Icons.chevron_right),
                    onTap: _importFamilyKey,
                  ),
                  const _CardDivider(),
                  _hubActionRow(
                    context,
                    icon: Icons.child_care,
                    title: l10n.settingsFamilyHubLinkKids,
                    trailing: const _QrChevron(),
                    onTap: _inviteKid,
                  ),
                ] else ...[
                  const _CardDivider(),
                  _hubActionRow(
                    context,
                    icon: Icons.person_add_alt_1_outlined,
                    title: l10n.settingsFamilyHubInvite,
                    trailing: const _QrChevron(),
                    onTap: _exportFamilyKey,
                  ),
                  const _CardDivider(),
                  _hubActionRow(
                    context,
                    icon: Icons.child_care,
                    title: l10n.settingsFamilyHubLinkKids,
                    trailing: const _QrChevron(),
                    onTap: _inviteKid,
                  ),
                ],
              ],
            ),
            _sectionHeader(context, l10n.settingsFamilyHubAdultsSection),
            if (_otherLinkMembers.isEmpty)
              _emptyCard(
                context,
                icon: Icons.groups_outlined,
                text: l10n.settingsFamilyHubAdultsNone,
              )
            else
              _HubCard(
                children: [
                  for (var i = 0; i < _otherLinkMembers.length; i++) ...[
                    if (i > 0) const _CardDivider(),
                    _buildAdultRow(context, l10n, _otherLinkMembers[i]),
                  ],
                ],
              ),
            _sectionHeader(context, l10n.settingsFamilyHubKidsSection),
            if (_kids.isEmpty)
              _emptyCard(
                context,
                icon: Icons.face_outlined,
                text: l10n.kidsNoneEnrolled,
              )
            else
              _HubCard(
                children: [
                  for (var i = 0; i < _kids.length; i++) ...[
                    if (i > 0) const _CardDivider(),
                    _buildKidTile(context, l10n, _kids[i]),
                  ],
                ],
              ),
          ],
        ],
        ),
      ),
    );
  }

  Widget _hubActionRow(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Widget trailing,
    required VoidCallback onTap,
  }) {
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            _HubIconBadge(icon: icon),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            IconTheme(
              data: IconThemeData(color: scheme.onSurfaceVariant, size: 22),
              child: trailing,
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader(BuildContext context, String label) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 20, 4, 8),
      child: Text(
        label.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
            ),
      ),
    );
  }

  Widget _emptyCard(
    BuildContext context, {
    required IconData icon,
    required String text,
  }) {
    final muted = Theme.of(context).colorScheme.onSurfaceVariant;
    return _HubCard(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            children: [
              Icon(icon, color: muted),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  text,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: muted,
                      ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAdultRow(
    BuildContext context,
    AppLocalizations l10n,
    FamilyLinkMember member,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 8),
        leading: _HubIconBadge(icon: Icons.person_outline),
        title: Text(
          member.displayName.isEmpty
              ? l10n.familyMemberGenericName
              : member.displayName,
        ),
        subtitle: Text(
          _presenceSubtitleFor(l10n, member.id),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: IconButton(
          icon: Icon(
            Icons.person_remove_outlined,
            color: Theme.of(context).colorScheme.error,
          ),
          tooltip: l10n.familyMemberRemoveTooltip,
          onPressed: () => _confirmRemoveMember(member),
        ),
      ),
    );
  }

  bool _kidIsLinked(EnrolledKid kid) =>
      kid.isActive || _presenceByKidId.containsKey(kid.id);

  Widget _buildKidTile(
    BuildContext context,
    AppLocalizations l10n,
    EnrolledKid kid,
  ) {
    final linked = _kidIsLinked(kid);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 8),
        leading: _HubIconBadge(
          icon: linked ? Icons.face : Icons.hourglass_top_outlined,
          emphasize: linked,
        ),
        title: Text(kid.name),
        subtitle: _buildKidSubtitle(context, l10n, kid, linked: linked),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!linked)
              IconButton(
                icon: Icon(
                  Icons.check_circle_outline,
                  color: Theme.of(context).colorScheme.primary,
                ),
                tooltip: l10n.kidsMarkActive,
                onPressed: () => _markKidActive(kid),
              ),
            IconButton(
              icon: Icon(
                kid.xpEnabled ? Icons.star : Icons.star_border_outlined,
                color: kid.xpEnabled
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.outline,
              ),
              tooltip: l10n.kidsXpAndGoals,
              onPressed: () => _toggleKidXp(kid),
            ),
            IconButton(
              icon: Icon(
                Icons.person_remove_outlined,
                color: Theme.of(context).colorScheme.error,
              ),
              tooltip: l10n.kidsRemoveTooltip,
              onPressed: () => _confirmRemoveKid(kid),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKidSubtitle(
    BuildContext context,
    AppLocalizations l10n,
    EnrolledKid kid, {
    required bool linked,
  }) {
    if (!linked) {
      return Text(
        l10n.kidsWaitingForDevice,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 12,
          color: Theme.of(context).colorScheme.tertiary,
          fontWeight: FontWeight.w600,
        ),
      );
    }
    final presence = _presenceByKidId[kid.id];
    if (presence == null) {
      return Text(
        l10n.kidsEnrolledOn(formatNumericDate(kid.enrolledAt, l10n)),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      );
    }
    final now = DateTime.now().toUtc();
    final diff = now.difference(presence.lastSeen);
    final stale = diff.inDays >= 14;
    final lastSeenText = _formatRelative(l10n, diff);
    return Text(
      stale
          ? l10n.kidsLastSeenWarning(lastSeenText)
          : l10n.kidsLastSeen(lastSeenText),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontSize: 12,
        color: stale
            ? Theme.of(context).colorScheme.error
            : Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }

  static String _formatRelative(AppLocalizations l10n, Duration diff) {
    if (diff.inMinutes < 2) return l10n.relativeJustNow;
    if (diff.inMinutes < 60) return l10n.relativeMinutesAgo(diff.inMinutes);
    if (diff.inHours < 24) return l10n.relativeHoursAgo(diff.inHours);
    if (diff.inDays == 1) return l10n.relativeYesterday;
    return l10n.relativeDaysAgo(diff.inDays);
  }

  String _demoPresenceSubtitle(AppLocalizations l10n, String name) {
    final match = DemoSession.instance.presence
        .where((p) => p.deviceType == 'link' && p.displayName == name)
        .firstOrNull;
    if (match == null) return l10n.settingsFamilyMemberLinked;
    return l10n.familyMemberLastSeen(
      _FamilyKeySummary.formatLastSeen(
        l10n,
        DateTime.now(),
        match.lastSeen,
      ),
    );
  }

  String _presenceSubtitleFor(AppLocalizations l10n, String linkId) {
    final match = _presenceList
        .where((p) => p.deviceType == 'link' && p.deviceId == linkId)
        .firstOrNull;
    if (match == null) return l10n.settingsFamilyMemberLinked;
    return l10n.familyMemberLastSeen(
      _FamilyKeySummary.formatLastSeen(
        l10n,
        DateTime.now(),
        match.lastSeen,
      ),
    );
  }
}

enum _FamilyMenuAction { verify, showKey, leave }

class _HubCard extends StatelessWidget {
  final List<Widget> children;

  const _HubCard({required this.children});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.surface,
      elevation: 0,
      shadowColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: scheme.outlineVariant.withValues(alpha: 0.45),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: children,
      ),
    );
  }
}

class _CardDivider extends StatelessWidget {
  const _CardDivider();

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      thickness: 1,
      indent: 62,
      endIndent: 16,
      color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.5),
    );
  }
}

class _HubIconBadge extends StatelessWidget {
  final IconData icon;
  final bool emphasize;

  const _HubIconBadge({required this.icon, this.emphasize = true});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: emphasize
            ? scheme.primaryContainer.withValues(alpha: 0.65)
            : scheme.surfaceContainerHighest,
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        size: 22,
        color: emphasize ? scheme.primary : scheme.onSurfaceVariant,
      ),
    );
  }
}

class _QrChevron extends StatelessWidget {
  const _QrChevron();

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.onSurfaceVariant;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.qr_code, size: 20, color: color),
        const SizedBox(width: 4),
        Icon(Icons.chevron_right, color: color),
      ],
    );
  }
}

/// Family-key row: theme badge + label, fingerprint value on the right.
class _FamilyKeySummary extends StatelessWidget {
  final String? fingerprint;
  final bool paired;
  final List<PresenceInfo> presenceList;

  const _FamilyKeySummary({
    required this.fingerprint,
    required this.paired,
    required this.presenceList,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final muted = scheme.onSurfaceVariant;

    final now = DateTime.now().toUtc();
    final partnerPresence = presenceList.isNotEmpty ? presenceList.first : null;
    final isStale = paired &&
        partnerPresence != null &&
        now.difference(partnerPresence.lastSeen) > const Duration(days: 14);
    final lastSeenText = paired && partnerPresence != null
        ? formatLastSeen(l10n, now, partnerPresence.lastSeen)
        : null;

    final hasKey = fingerprint != null;
    final valueColor = isStale
        ? scheme.error
        : hasKey
            ? scheme.onSurface
            : muted;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          _HubIconBadge(
            icon: isStale ? Icons.warning_amber_rounded : Icons.vpn_key_outlined,
            emphasize: !isStale,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.settingsFamilyHubKeyLabel,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                if (lastSeenText != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    isStale
                        ? l10n.familyMemberLastSeenWarning(lastSeenText)
                        : l10n.familyMemberLastSeen(lastSeenText),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: isStale ? scheme.error : muted,
                        ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            hasKey ? fingerprint! : l10n.settingsFamilyHubKeyMissing,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontFamily: hasKey ? 'monospace' : null,
                  letterSpacing: hasKey ? 1.0 : null,
                  color: valueColor,
                  fontWeight: hasKey ? FontWeight.w600 : FontWeight.w400,
                ),
          ),
        ],
      ),
    );
  }

  static String formatLastSeen(
    AppLocalizations l10n,
    DateTime now,
    DateTime lastSeen,
  ) {
    final diff = now.difference(lastSeen);
    if (diff.inMinutes < 2) return l10n.relativeJustNow;
    if (diff.inMinutes < 60) return l10n.relativeMinutesAgo(diff.inMinutes);
    if (diff.inHours < 24) return l10n.relativeHoursAgo(diff.inHours);
    if (diff.inDays == 1) return l10n.relativeYesterday;
    return l10n.relativeDaysAgo(diff.inDays);
  }
}
