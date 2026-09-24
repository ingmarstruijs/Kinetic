import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../db/app_database.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../settings/family_key_share_screen.dart';
import '../../settings/kids_enrollment_qr_screen.dart';
import '../../settings/models/enrolled_kid.dart';
import '../../sync/webdav_config_repository.dart';
import '../family_key_rotation.dart';
import 'family_create_screen.dart';

enum _WizardPhase { intro, reencrypt, shareLink, shareKids, done }

/// Optional wizard after removing a link member: new family mnemonic, re-wrap
/// shared WebDAV data, then QR/BLE for remaining adults and kids.
class FamilyKeyRotationWizardScreen extends StatefulWidget {
  const FamilyKeyRotationWizardScreen({
    super.key,
    required this.db,
    required this.configRepo,
    this.onFinished,
  });

  final AppDatabase db;
  final WebDavConfigRepository configRepo;
  final VoidCallback? onFinished;

  @override
  State<FamilyKeyRotationWizardScreen> createState() =>
      _FamilyKeyRotationWizardScreenState();
}

class _FamilyKeyRotationWizardScreenState
    extends State<FamilyKeyRotationWizardScreen> {
  _WizardPhase _phase = _WizardPhase.intro;
  Uint8List? _oldFamilyKey;
  Uint8List? _newEntropy;
  String? _error;
  int _reencryptDone = 0;
  int _reencryptTotal = 0;
  List<EnrolledKid> _kids = const [];
  bool _hasOtherLinkMembers = false;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    final oldKey = await widget.configRepo.loadFamilyKey();
    final kids = await widget.configRepo.loadEnrolledKids();
    final paired = await widget.configRepo.hasOtherLinkMembers();
    if (!mounted) return;
    setState(() {
      _oldFamilyKey = oldKey;
      _kids = kids;
      _hasOtherLinkMembers = paired;
    });
  }

  Future<void> _startNewKeyFlow() async {
    final oldKey = _oldFamilyKey;
    if (oldKey == null) {
      setState(() => _error = 'No family key on this device');
      return;
    }
    final created = await Navigator.of(context).push<FamilyCreateResult>(
      MaterialPageRoute(builder: (_) => const FamilyCreateScreen()),
    );
    if (created == null || !mounted) return;
    setState(() {
      _newEntropy = created.entropy;
      _phase = _WizardPhase.reencrypt;
      _error = null;
    });
    await _runReencrypt(oldKey, created.key, created.entropy);
  }

  Future<void> _runReencrypt(
    Uint8List oldKey,
    Uint8List newKey,
    Uint8List entropy,
  ) async {
    try {
      await applyFamilyKeyRotation(
        configRepo: widget.configRepo,
        db: widget.db,
        oldFamilyKey: oldKey,
        newFamilyKey: newKey,
        newEntropy: entropy,
        onProgress: (p) {
          if (!mounted) return;
          setState(() {
            _reencryptDone = p.index + 1;
            _reencryptTotal = p.total;
          });
        },
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = '$e';
        _phase = _WizardPhase.intro;
      });
      return;
    }
    if (!mounted) return;
    widget.onFinished?.call();
    if (_hasOtherLinkMembers) {
      setState(() => _phase = _WizardPhase.shareLink);
    } else if (_kids.isNotEmpty) {
      setState(() => _phase = _WizardPhase.shareKids);
    } else {
      setState(() => _phase = _WizardPhase.done);
    }
  }

  Future<void> _openLinkShare() async {
    final config = await widget.configRepo.load();
    if (config == null || !mounted) return;
    final entropy = _newEntropy ?? await widget.configRepo.loadFamilyEntropy();
    if (!mounted) return;
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => FamilyKeyShareScreen(
          config: config,
          configRepo: widget.configRepo,
          entropy: entropy,
        ),
      ),
    );
    if (!mounted) return;
    if (_kids.isNotEmpty) {
      setState(() => _phase = _WizardPhase.shareKids);
    } else {
      setState(() => _phase = _WizardPhase.done);
    }
  }

  Future<void> _openKidReEnroll(EnrolledKid kid) async {
    final config = await widget.configRepo.load();
    if (config == null || config.familyKeyBytes == null || !mounted) return;
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => KidsEnrollmentQrScreen(
          config: config,
          configRepo: widget.configRepo,
          existingKid: kid,
        ),
      ),
    );
  }

  void _finish() {
    widget.onFinished?.call();
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.familyKeyRotationTitle),
        centerTitle: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: switch (_phase) {
            _WizardPhase.intro => _buildIntro(context, l10n),
            _WizardPhase.reencrypt => _buildReencrypt(context, l10n),
            _WizardPhase.shareLink => _buildShareLink(context, l10n),
            _WizardPhase.shareKids => _buildShareKids(context, l10n),
            _WizardPhase.done => _buildDone(context, l10n),
          },
        ),
      ),
    );
  }

  Widget _buildIntro(BuildContext context, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Icon(
          Icons.vpn_key_outlined,
          size: 56,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(height: 24),
        Text(
          l10n.familyKeyRotationIntroTitle,
          style: Theme.of(context).textTheme.headlineSmall,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Text(
          l10n.familyKeyRotationIntroBody,
          style: Theme.of(context).textTheme.bodyLarge,
          textAlign: TextAlign.center,
        ),
        if (_error != null) ...[
          const SizedBox(height: 16),
          Text(
            _error!,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
            textAlign: TextAlign.center,
          ),
        ],
        const Spacer(),
        FilledButton(
          onPressed: _oldFamilyKey == null ? null : _startNewKeyFlow,
          child: Text(l10n.familyKeyRotationStart),
        ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(l10n.commonCancel),
        ),
      ],
    );
  }

  Widget _buildReencrypt(BuildContext context, AppLocalizations l10n) {
    final total = _reencryptTotal;
    final done = _reencryptDone;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Spacer(),
        const Center(child: CircularProgressIndicator()),
        const SizedBox(height: 24),
        Text(
          l10n.familyKeyRotationReencryptTitle,
          style: Theme.of(context).textTheme.titleLarge,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          total > 0
              ? l10n.familyKeyRotationReencryptProgress(done, total)
              : l10n.familyKeyRotationReencryptPreparing,
          textAlign: TextAlign.center,
        ),
        const Spacer(),
      ],
    );
  }

  Widget _buildShareLink(BuildContext context, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.familyKeyRotationShareLinkTitle,
          style: Theme.of(context).textTheme.titleLarge,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Text(
          l10n.familyKeyRotationShareLinkBody,
          style: Theme.of(context).textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
        const Spacer(),
        FilledButton(
          onPressed: _openLinkShare,
          child: Text(l10n.familyKeyRotationShareLinkButton),
        ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: () {
            if (_kids.isNotEmpty) {
              setState(() => _phase = _WizardPhase.shareKids);
            } else {
              setState(() => _phase = _WizardPhase.done);
            }
          },
          child: Text(l10n.familyKeyRotationShareLinkSkip),
        ),
      ],
    );
  }

  Widget _buildShareKids(BuildContext context, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.familyKeyRotationShareKidsTitle,
          style: Theme.of(context).textTheme.titleLarge,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          l10n.familyKeyRotationShareKidsBody,
          style: Theme.of(context).textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Expanded(
          child: ListView(
            children: [
              for (final kid in _kids)
                ListTile(
                  leading: const Icon(Icons.child_care),
                  title: Text(kid.name),
                  trailing: const Icon(Icons.qr_code),
                  onTap: () => _openKidReEnroll(kid),
                ),
            ],
          ),
        ),
        FilledButton(
          onPressed: () => setState(() => _phase = _WizardPhase.done),
          child: Text(l10n.commonContinue),
        ),
      ],
    );
  }

  Widget _buildDone(BuildContext context, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Spacer(),
        Icon(
          Icons.check_circle_outline,
          size: 56,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(height: 24),
        Text(
          l10n.familyKeyRotationDoneTitle,
          style: Theme.of(context).textTheme.headlineSmall,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Text(
          l10n.familyKeyRotationDoneBody,
          style: Theme.of(context).textTheme.bodyLarge,
          textAlign: TextAlign.center,
        ),
        const Spacer(),
        FilledButton(
          onPressed: _finish,
          child: Text(l10n.wizardDone),
        ),
      ],
    );
  }
}
