import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:kinetic_qr_scanner/kinetic_qr_scanner.dart';
import 'package:kinetic_webdav/kinetic_webdav.dart';

import '../l10n/generated/app_localizations.dart';
import '../sync/ble_tap_sheets.dart';
import '../sync/webdav_config_repository.dart';
import '../vault/widgets/mnemonic_phrase_field.dart';

// ---------------------------------------------------------------------------
// FamilyKeyScanScreen
//
// Uses the device camera to scan a QR code produced by FamilyKeyShareScreen
// on the other Link device. On a successful scan the payload is verified and
// the user is asked to confirm before the family key is saved.
// ---------------------------------------------------------------------------

class FamilyKeyScanScreen extends StatefulWidget {
  final SyncConfig currentConfig;
  final WebDavConfigRepository configRepo;

  const FamilyKeyScanScreen({
    super.key,
    required this.currentConfig,
    required this.configRepo,
  });

  @override
  State<FamilyKeyScanScreen> createState() => _FamilyKeyScanScreenState();
}

class _FamilyKeyScanScreenState extends State<FamilyKeyScanScreen> {
  bool _processing = false;

  void _onDetect(String raw) {
    if (_processing) return;
    _handlePayload(raw);
  }

  Future<void> _handlePayload(String raw) async {
    setState(() => _processing = true);

    try {
      final payload = await KineticVault.importFamilyQrPayload(raw);
      if (!mounted) return;
      await _showVerificationDialog(payload);
    } on FormatException catch (e) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context);
      await _showErrorDialog(l10n.familyKeyInvalidQr('$e'));
      if (mounted) setState(() => _processing = false);
    }
  }

  /// Decrypt `/kinetic/shared/roster.json` with the candidate key (preview only).
  Future<FamilyRoster?> _peekRoster(Uint8List familyKey) async {
    final cfg = widget.currentConfig.withFamilyKey(familyKey);
    final client = WebDavClient(
      baseUrl: cfg.serverUrl,
      username: cfg.username,
      password: cfg.password,
    );
    try {
      return await WebDavSyncService(client: client, config: cfg).pullRoster();
    } catch (_) {
      return null;
    } finally {
      client.dispose();
    }
  }

  Future<void> _showVerificationDialog(
    ({
      Uint8List familyKey,
      Uint8List? entropy,
      String serverUrl,
      String username,
    })
    payload,
  ) async {
    final currentUrl = _normalizeUrl(widget.currentConfig.serverUrl);
    final scannedUrl = _normalizeUrl(payload.serverUrl);
    final urlMatches = currentUrl == scannedUrl;
    final alreadyPaired = widget.currentConfig.familyKeyBytes != null;
    final fingerprint = await KineticVault.fingerprint(payload.familyKey);
    final roster = urlMatches ? await _peekRoster(payload.familyKey) : null;

    if (!mounted) return;
    final l10n = AppLocalizations.of(context);
    final errorColor = Theme.of(context).colorScheme.error;
    // Hide this device: after leave/rejoin the roster may still list us, which
    // looks like "Key found … Adults: <me>".
    final myId = widget.currentConfig.linkId;
    final myName = widget.currentConfig.username.trim().toLowerCase();
    final adultNames = (roster == null
            ? const <FamilyLinkMember>[]
            : roster.otherLinkMembers(myId))
        .map((m) => m.displayName.trim())
        .where(
          (n) =>
              n.isNotEmpty &&
              (myName.isEmpty || n.toLowerCase() != myName),
        )
        .toList();
    final kidNames = roster?.kids
            .map((k) => k.name.trim())
            .where((n) => n.isNotEmpty)
            .toList() ??
        const <String>[];
    final hasRosterNames = adultNames.isNotEmpty || kidNames.isNotEmpty;

    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            Icon(
              urlMatches ? Icons.check_circle_outline : Icons.block,
              color: urlMatches
                  ? Theme.of(context).colorScheme.primary
                  : errorColor,
              size: 22,
            ),
            const SizedBox(width: 8),
            Expanded(child: Text(l10n.familyKeyFound)),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (hasRosterNames) ...[
                if (adultNames.isNotEmpty) ...[
                  _InfoRow(
                    icon: Icons.groups_outlined,
                    label: l10n.familyKeyRosterAdults,
                    value: adultNames.join('\n'),
                  ),
                  const SizedBox(height: 8),
                ],
                if (kidNames.isNotEmpty) ...[
                  _InfoRow(
                    icon: Icons.child_care_outlined,
                    label: l10n.familyKeyRosterKids,
                    value: kidNames.join('\n'),
                  ),
                  const SizedBox(height: 8),
                ],
              ] else ...[
                _InfoRow(
                  icon: Icons.person_outline,
                  label: l10n.familyKeyLinkMember,
                  value: payload.username.isNotEmpty
                      ? payload.username
                      : (urlMatches
                            ? l10n.familyKeyRosterEmpty
                            : l10n.commonUnknown),
                ),
                const SizedBox(height: 8),
              ],
              _InfoRow(
                icon: Icons.cloud_outlined,
                label: l10n.familyKeyServer,
                value: payload.serverUrl.isNotEmpty
                    ? payload.serverUrl
                    : l10n.commonUnknown,
              ),
              const SizedBox(height: 8),
              _InfoRow(
                icon: Icons.fingerprint,
                label: l10n.familyKeyFingerprint,
                value: fingerprint,
              ),
              if (!urlMatches) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: errorColor.withAlpha(30),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: errorColor.withAlpha(100)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.block, color: errorColor, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          l10n.familyKeyServerMismatch(
                            payload.serverUrl,
                            widget.currentConfig.serverUrl,
                          ),
                          style: Theme.of(ctx).textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
                ),
              ] else ...[
                const SizedBox(height: 16),
                Text(
                  hasRosterNames
                      ? l10n.familyKeyConfirmRoster
                      : l10n.familyKeyConfirmLinkMember,
                  style: Theme.of(ctx).textTheme.bodySmall?.copyWith(
                    color: Theme.of(ctx).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
              if (urlMatches && alreadyPaired) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: errorColor.withAlpha(30),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: errorColor.withAlpha(100)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.block, color: errorColor, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          l10n.familyKeyAlreadyPairedWarning,
                          style: Theme.of(ctx).textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
        actions: [
          if (!urlMatches || alreadyPaired)
            FilledButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: Text(l10n.commonOk),
            )
          else ...[
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: Text(l10n.commonCancel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: Text(l10n.commonImport),
            ),
          ],
        ],
      ),
    );

    if (!mounted) return;

    // Same WebDAV server required; never import when this device already has a key.
    if (confirmed == true && urlMatches && !alreadyPaired) {
      await _importKey(payload.familyKey, entropy: payload.entropy);
    } else {
      setState(() => _processing = false);
    }
  }

  Future<void> _importFromPhrase() async {
    if (_processing) return;
    setState(() => _processing = true);
    final l10n = AppLocalizations.of(context);
    final phrase = await showMnemonicPhraseDialog(
      context: context,
      title: l10n.familyKeyEnterTitle,
      body: l10n.familyKeyEnterSubtitle,
    );
    if (!mounted) return;
    if (phrase == null || phrase.trim().isEmpty) {
      setState(() => _processing = false);
      return;
    }
    try {
      final words = KineticVault.parseMnemonic(phrase);
      final key = await KineticVault.deriveAesKey(words.join(' '));
      final entropy = await KineticVault.entropyFromMnemonic(words);
      await _showVerificationDialog((
        familyKey: key,
        entropy: entropy,
        serverUrl: widget.currentConfig.serverUrl,
        username: '',
      ));
    } catch (e) {
      if (!mounted) return;
      await _showErrorDialog('$e');
      setState(() => _processing = false);
    }
  }

  Future<void> _importKey(Uint8List familyKey, {Uint8List? entropy}) async {
    try {
      await widget.configRepo.saveFamilyKey(familyKey, entropy: entropy);
      if (!mounted) return;
      final l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.familyKeySaved)),
      );
      Navigator.of(context).pop(true);
    } on Exception catch (e) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context);
      await _showErrorDialog(l10n.familyKeySaveError('$e'));
      setState(() => _processing = false);
    }
  }

  Future<void> _showErrorDialog(String message) async {
    final l10n = AppLocalizations.of(context);
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.commonError),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l10n.commonOk),
          ),
        ],
      ),
    );
  }

  static String _normalizeUrl(String url) {
    try {
      return WebDavUrl.coerceHttps(url).toLowerCase();
    } on FormatException {
      return url.trim().toLowerCase().replaceAll(RegExp(r'/+$'), '');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.familyKeyScanTitle),
        centerTitle: false,
        actions: [
          IconButton(
            tooltip: l10n.bleJoinTitle,
            onPressed: _processing
                ? null
                : () async {
                    await showBleTapJoinSheet(
                      context,
                      displayName: widget.currentConfig.username,
                      onPayload: (raw) async {
                        await _handlePayload(raw);
                      },
                    );
                  },
            icon: const Icon(Icons.bluetooth_searching),
          ),
          TextButton(
            onPressed: _processing ? null : _importFromPhrase,
            child: Text(l10n.familyKeyEnterPhrase),
          ),
        ],
      ),
      body: Stack(
        children: [
          KineticQrScanView(
            enabled: !_processing,
            onDetect: _onDetect,
            hint: l10n.familyKeyScanHint,
            frameColor: Theme.of(context).colorScheme.primary,
            frameSize: 260,
            showTorch: true,
          ),
          if (_processing)
            Container(
              color: Colors.black.withAlpha(120),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 18,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: Theme.of(context).textTheme.bodySmall,
              children: [
                TextSpan(
                  text: '$label: ',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                TextSpan(text: value),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
