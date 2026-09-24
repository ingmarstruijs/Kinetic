import 'package:flutter/material.dart';
import 'package:kinetic_webdav/kinetic_webdav.dart';

import '../db/app_database.dart';
import '../debug/demo_session.dart';
import '../l10n/generated/app_localizations.dart';
import '../sync/sync_orchestrator.dart';
import '../sync/webdav_config_repository.dart';
import '../vault/family_vault_sync.dart';
import '../vault/screens/family_create_screen.dart';
import '../vault/screens/family_key_rotation_wizard_screen.dart';
import '../vault/screens/mnemonic_reveal_screen.dart';
import '../vault/widgets/mnemonic_phrase_field.dart';
import 'family_key_scan_screen.dart';
import 'family_key_share_screen.dart';

// ---------------------------------------------------------------------------
// FamilyMembersSettingsScreen
//
// Manages family linking: share/scan family key QR, backup family key,
// and leaving the family.  Only reachable when WebDAV is configured.
// ---------------------------------------------------------------------------

class FamilyMembersSettingsScreen extends StatefulWidget {
  final AppDatabase db;
  final WebDavConfigRepository configRepo;
  final SyncOrchestrator? syncOrchestrator;
  final VoidCallback? onConfigSaved;

  const FamilyMembersSettingsScreen({
    super.key,
    required this.db,
    required this.configRepo,
    this.syncOrchestrator,
    this.onConfigSaved,
  });

  @override
  State<FamilyMembersSettingsScreen> createState() => _FamilyMembersSettingsScreenState();
}

class _FamilyMembersSettingsScreenState extends State<FamilyMembersSettingsScreen> {
  SyncConfig? _config;
  bool _hasOtherLinkMembers = false;
  List<PresenceInfo> _presenceList = [];
  List<FamilyLinkMember> _otherLinkMembers = const [];
  String? _fingerprint;

  @override
  void initState() {
    super.initState();
    _loadConfig();
    _loadPresence();
  }

  Future<void> _loadConfig() async {
    final config = await widget.configRepo.load();
    final paired = await widget.configRepo.hasOtherLinkMembers();
    final roster = await widget.configRepo.loadCachedRoster();
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
      });
    }
  }

  Future<void> _loadPresence() async {
    final orchestrator = widget.syncOrchestrator;
    if (orchestrator == null) return;
    try {
      final presence = await orchestrator.pullPresence();
      if (mounted) setState(() => _presenceList = presence);
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
      await _loadConfig();
      widget.onConfigSaved?.call();
    }
  }

  Future<void> _importFamilyKey() async {
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
      await _loadConfig();
      widget.onConfigSaved?.call();
    }
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

  Future<void> _leaveFamily() async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.familyMemberUnlinkTitle),
        content: Text(l10n.familyMemberUnlinkBody),
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

    await (widget.db.delete(
      widget.db.personalNotes,
    )..where((n) => n.isShared.equals(true))).go();
    await widget.db.delete(widget.db.linkMemberProposals).go();
    // Write disconnect tombstone so the other link member is notified.
    try {
      await widget.syncOrchestrator?.pushDisconnect();
    } catch (_) {}
    await widget.configRepo.clearFamilyKey();
    if (!mounted) return;
    widget.onConfigSaved?.call();
    Navigator.of(context).pop();
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
        appBar: AppBar(title: Text(l10n.settingsFamilyMember), centerTitle: false),
        body: ListView(
          children: [
            const SizedBox(height: 8),
            ListTile(
              leading: Icon(
                Icons.check_circle_outline,
                color: Theme.of(context).colorScheme.primary,
              ),
              title: Text(l10n.otherLinkMemberStatusPaired),
              subtitle: Text(
                demo.otherLinkMembers.isEmpty
                    ? l10n.settingsFamilyMemberLinkHint
                    : demo.otherLinkMembers
                        .map((m) => m.name)
                        .join(', '),
              ),
            ),
            for (final member in demo.otherLinkMembers)
              ListTile(
                leading: Icon(
                  Icons.person_outline,
                  color: Theme.of(context).colorScheme.primary,
                ),
                title: Text(member.name),
                subtitle: Text(_demoPresenceSubtitle(l10n, member.name)),
              ),
          ],
        ),
      );
    }

    final config = _config;
    final paired = _hasOtherLinkMembers;

    // Link-member presence: other Kinetic Link devices only.
    final partnerPresence = _presenceList
        .where((p) => p.deviceType == 'link')
        .toList();

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsFamilyMember), centerTitle: false),
      body: ListView(
        children: [
          if (config != null) ...[
            const SizedBox(height: 8),
            _FamilyMemberStatusBanner(
              paired: paired,
              presenceList: partnerPresence,
              fingerprint: _fingerprint,
            ),
            const SizedBox(height: 8),
            if (paired) ...[
              for (final member in _otherLinkMembers)
                ListTile(
                  leading: Icon(
                    Icons.person_outline,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  title: Text(
                    member.displayName.isEmpty
                        ? l10n.familyMemberGenericName
                        : member.displayName,
                  ),
                  subtitle: Text(_presenceSubtitleFor(l10n, member.id)),
                  trailing: IconButton(
                    icon: Icon(
                      Icons.person_remove_outlined,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    tooltip: l10n.familyMemberRemoveTooltip,
                    onPressed: () => _confirmRemoveMember(member),
                  ),
                ),
            ],
            if (!paired) ...[
              ListTile(
                leading: Icon(
                  Icons.people_outline,
                  color: Theme.of(context).colorScheme.primary,
                ),
                title: Text(l10n.familyMemberShareViaQr),
                subtitle: Text(l10n.familyMemberShareViaQrSubtitle),
                trailing: const Icon(Icons.qr_code),
                onTap: _exportFamilyKey,
              ),
              ListTile(
                leading: Icon(
                  Icons.qr_code_scanner,
                  color: Theme.of(context).colorScheme.primary,
                ),
                title: Text(l10n.familyMemberScanKey),
                subtitle: Text(l10n.familyMemberScanKeySubtitle),
                onTap: _importFamilyKey,
              ),
            ],
            if (paired) ...[
              ListTile(
                leading: Icon(
                  Icons.qr_code,
                  color: Theme.of(context).colorScheme.primary,
                ),
                title: Text(l10n.familyMemberReshareKey),
                subtitle: Text(l10n.familyMemberReshareKeySubtitle),
                trailing: const Icon(Icons.qr_code),
                onTap: _exportFamilyKey,
              ),
              ListTile(
                leading: Icon(
                  Icons.verified_user_outlined,
                  color: Theme.of(context).colorScheme.primary,
                ),
                title: Text(l10n.familyMemberVerifyPhrase),
                subtitle: Text(l10n.familyMemberVerifyPhraseSubtitle),
                onTap: _verifyFamilyPhrase,
              ),
              ListTile(
                leading: Icon(
                  Icons.visibility_outlined,
                  color: Theme.of(context).colorScheme.primary,
                ),
                title: Text(l10n.familyMemberShowKey),
                subtitle: Text(l10n.familyMemberShowKeySubtitle),
                onTap: _revealFamilyPhrase,
              ),
              ListTile(
                leading: Icon(
                  Icons.person_remove_outlined,
                  color: Theme.of(context).colorScheme.error,
                ),
                title: Text(
                  l10n.familyMemberUnlink,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
                subtitle: Text(l10n.familyMemberUnlinkSubtitle),
                onTap: _leaveFamily,
              ),
            ],
          ],
        ],
      ),
    );
  }

  String _demoPresenceSubtitle(AppLocalizations l10n, String name) {
    final match = DemoSession.instance.presence
        .where((p) => p.deviceType == 'link' && p.displayName == name)
        .firstOrNull;
    if (match == null) return l10n.settingsFamilyMemberLinked;
    return l10n.familyMemberLastSeen(
      _FamilyMemberStatusBanner._formatLastSeen(
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
      _FamilyMemberStatusBanner._formatLastSeen(
        l10n,
        DateTime.now(),
        match.lastSeen,
      ),
    );
  }
}

class _FamilyMemberStatusBanner extends StatelessWidget {
  final bool paired;
  final List<PresenceInfo> presenceList;
  final String? fingerprint;

  const _FamilyMemberStatusBanner({
    required this.paired,
    required this.presenceList,
    this.fingerprint,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;

    // Determine stale state: warn if the family member hasn't synced in 14 days.
    final now = DateTime.now().toUtc();
    const staleThreshold = Duration(days: 14);
    final partnerPresence = presenceList.isNotEmpty ? presenceList.first : null;
    final isStale =
        partnerPresence != null &&
        now.difference(partnerPresence.lastSeen) > staleThreshold;
    final lastSeenText = partnerPresence != null
        ? _formatLastSeen(l10n, now, partnerPresence.lastSeen)
        : null;

    final statusColor = isStale
        ? scheme.error
        : paired
        ? scheme.primary
        : scheme.onSurfaceVariant;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isStale
              ? scheme.error.withAlpha(15)
              : paired
              ? scheme.primary.withAlpha(20)
              : scheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isStale
                ? scheme.error.withAlpha(80)
                : paired
                ? scheme.primary.withAlpha(80)
                : scheme.outlineVariant,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isStale
                  ? Icons.warning_amber_rounded
                  : paired
                  ? Icons.people
                  : Icons.people_outline,
              size: 20,
              color: statusColor,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    paired
                        ? l10n.otherLinkMemberStatusPaired
                        : l10n.otherLinkMemberStatusUnpaired,
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: statusColor),
                  ),
                  if (lastSeenText != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      isStale
                          ? l10n.familyMemberLastSeenWarning(lastSeenText)
                          : l10n.familyMemberLastSeen(lastSeenText),
                      style: Theme.of(
                        context,
                      ).textTheme.labelSmall?.copyWith(color: statusColor),
                    ),
                  ],
                  if (fingerprint != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      l10n.familyMemberFingerprint(fingerprint!),
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        fontFamily: 'monospace',
                        letterSpacing: 1.2,
                        color: statusColor,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _formatLastSeen(
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
