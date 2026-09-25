import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kinetic_link_bridge/kinetic_link_bridge.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../l10n/generated/app_localizations.dart';
import '../todo/services/todo_repository.dart';
import 'link_bridge_server.dart';

/// Starts the LAN bridge and shows a QR for Kinetic Link Web.
class LinkWebBridgeScreen extends StatefulWidget {
  final TodoRepository todoRepository;

  const LinkWebBridgeScreen({super.key, required this.todoRepository});

  @override
  State<LinkWebBridgeScreen> createState() => _LinkWebBridgeScreenState();
}

class _LinkWebBridgeScreenState extends State<LinkWebBridgeScreen> {
  late final LinkBridgeServer _server;
  List<String> _hosts = [];
  String? _selectedHost;
  LinkWebQrPayload? _qr;
  String? _error;
  var _starting = false;

  @override
  void initState() {
    super.initState();
    _server = LinkBridgeServer(todoRepository: widget.todoRepository);
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    final hosts = await LinkBridgeServer.listLanIpv4();
    if (!mounted) return;
    setState(() {
      _hosts = hosts;
      _selectedHost = hosts.isNotEmpty ? hosts.first : null;
    });
    await _start();
  }

  Future<void> _start() async {
    setState(() {
      _starting = true;
      _error = null;
    });
    try {
      final qr = await _server.start(preferredHost: _selectedHost);
      if (!mounted) return;
      setState(() {
        _qr = qr;
        _starting = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = '$e';
        _starting = false;
        _qr = null;
      });
    }
  }

  Future<void> _revoke() async {
    await _server.revokeAndStop();
    if (!mounted) return;
    setState(() => _qr = null);
    Navigator.of(context).pop();
  }

  Future<void> _rotate() async {
    try {
      final qr = await _server.rotateSession();
      if (!mounted) return;
      setState(() => _qr = qr);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = '$e');
    }
  }

  @override
  void dispose() {
    _server.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.linkWebTitle),
        actions: [
          if (_qr != null)
            TextButton(
              onPressed: _rotate,
              child: Text(l10n.linkWebNewSession),
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(
            l10n.linkWebIntro,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 16),
          if (_hosts.length > 1) ...[
            Text(l10n.linkWebPickIp, style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: _selectedHost,
              items: _hosts
                  .map((h) => DropdownMenuItem(value: h, child: Text(h)))
                  .toList(),
              onChanged: (v) async {
                setState(() => _selectedHost = v);
                await _server.stop();
                await _start();
              },
            ),
            const SizedBox(height: 16),
          ],
          if (_starting)
            const Center(child: CircularProgressIndicator())
          else if (_error != null)
            Text(_error!, style: TextStyle(color: scheme.error))
          else if (_qr != null) ...[
            Center(
              child: QrImageView(
                data: _qr!.encode(),
                size: 240,
                backgroundColor: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            SelectableText(
              _qr!.httpUrl,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.linkWebKeepAwake,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: _qr!.httpUrl));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l10n.linkWebCopied)),
                );
              },
              icon: const Icon(Icons.copy),
              label: Text(l10n.linkWebCopyUrl),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _revoke,
              icon: const Icon(Icons.link_off),
              label: Text(l10n.linkWebRevoke),
            ),
          ] else
            FilledButton(
              onPressed: _start,
              child: Text(l10n.linkWebStart),
            ),
        ],
      ),
    );
  }
}
