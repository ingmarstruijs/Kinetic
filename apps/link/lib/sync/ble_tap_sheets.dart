import 'package:flutter/material.dart';

import '../l10n/generated/app_localizations.dart';
import '../sync/ble_tap_link_controller.dart';
import '../sync/ble_tap_session.dart';

/// Host: wait for a nearby guest, confirm, send QR-equivalent payload.
class BleTapShareSheet extends StatefulWidget {
  final String displayName;
  final String Function() payloadProvider;

  const BleTapShareSheet({
    super.key,
    required this.displayName,
    required this.payloadProvider,
  });

  @override
  State<BleTapShareSheet> createState() => _BleTapShareSheetState();
}

class _BleTapShareSheetState extends State<BleTapShareSheet> {
  late final BleTapLinkController _controller;

  @override
  void initState() {
    super.initState();
    _controller = BleTapLinkController(displayName: widget.displayName);
    _controller.addListener(_onUpdate);
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    final ok = await _controller.isAvailable;
    if (!mounted) return;
    if (!ok) {
      _controller.markUnavailable();
      return;
    }
    await _controller.startHostAwaitingGuest(
      payloadProvider: widget.payloadProvider,
    );
  }

  void _onUpdate() {
    if (!mounted) return;
    setState(() {});
    if (_controller.phase == BleTapPhase.success) {
      final l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.bleSuccess)),
      );
      Navigator.of(context).pop(true);
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onUpdate);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final phase = _controller.phase;

    String body = l10n.bleAdvertising;
    if (phase == BleTapPhase.awaitingConfirm) {
      body = l10n.bleConfirmBody(_controller.peerName ?? '…');
    } else if (phase == BleTapPhase.failed) {
      final reason = _controller.failureReason;
      body = reason == 'unavailable' || reason == 'peripheral'
          ? l10n.bleUnavailable
          : reason == 'timeout'
              ? l10n.bleTimeout
              : l10n.bleFailed;
    } else if (phase == BleTapPhase.transferring) {
      body = l10n.syncStatusSyncing;
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l10n.bleShareTitle, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          Text(body),
          const SizedBox(height: 16),
          if (phase == BleTapPhase.awaitingConfirm)
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _controller.denyGuest,
                    child: Text(l10n.bleConfirmDeny),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: _controller.confirmGuest,
                    child: Text(l10n.bleConfirmAllow),
                  ),
                ),
              ],
            )
          else if (phase == BleTapPhase.advertising)
            const Center(child: CircularProgressIndicator())
          else if (phase == BleTapPhase.failed)
            FilledButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(l10n.wizardDone),
            ),
        ],
      ),
    );
  }
}

/// Guest: scan for a nearby host and import the offered QR payload.
class BleTapJoinSheet extends StatefulWidget {
  final String displayName;
  final Future<void> Function(String payload) onPayload;

  const BleTapJoinSheet({
    super.key,
    required this.displayName,
    required this.onPayload,
  });

  @override
  State<BleTapJoinSheet> createState() => _BleTapJoinSheetState();
}

class _BleTapJoinSheetState extends State<BleTapJoinSheet> {
  late final BleTapLinkController _controller;
  bool _importing = false;

  @override
  void initState() {
    super.initState();
    _controller = BleTapLinkController(displayName: widget.displayName);
    _controller.addListener(_onUpdate);
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    final ok = await _controller.isAvailable;
    if (!mounted) return;
    if (!ok) {
      _controller.markUnavailable();
      return;
    }
    await _controller.startGuest();
  }

  Future<void> _onUpdate() async {
    if (!mounted) return;
    setState(() {});
    if (_controller.phase == BleTapPhase.success &&
        !_importing &&
        _controller.receivedPayload != null) {
      _importing = true;
      try {
        await widget.onPayload(_controller.receivedPayload!);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context).bleSuccess)),
        );
        Navigator.of(context).pop(true);
      } catch (_) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context).bleFailed)),
        );
        Navigator.of(context).pop(false);
      }
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onUpdate);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final phase = _controller.phase;

    String body = l10n.bleSearching;
    if (phase == BleTapPhase.failed) {
      final reason = _controller.failureReason;
      body = reason == 'unavailable'
          ? l10n.bleUnavailable
          : reason == 'timeout'
              ? l10n.bleTimeout
              : l10n.bleFailed;
    } else if (phase == BleTapPhase.transferring ||
        phase == BleTapPhase.success) {
      body = l10n.syncStatusSyncing;
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l10n.bleJoinTitle, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          Text(body),
          const SizedBox(height: 16),
          if (phase == BleTapPhase.scanning ||
              phase == BleTapPhase.transferring)
            const Center(child: CircularProgressIndicator())
          else if (phase == BleTapPhase.failed)
            FilledButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(l10n.wizardDone),
            ),
        ],
      ),
    );
  }
}

Future<bool?> showBleTapShareSheet(
  BuildContext context, {
  required String displayName,
  required String Function() payloadProvider,
}) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => BleTapShareSheet(
      displayName: displayName,
      payloadProvider: payloadProvider,
    ),
  );
}

Future<bool?> showBleTapJoinSheet(
  BuildContext context, {
  required String displayName,
  required Future<void> Function(String payload) onPayload,
}) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => BleTapJoinSheet(
      displayName: displayName,
      onPayload: onPayload,
    ),
  );
}
