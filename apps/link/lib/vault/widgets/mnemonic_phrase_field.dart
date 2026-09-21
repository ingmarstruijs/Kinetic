import 'package:flutter/material.dart';

import '../../l10n/generated/app_localizations.dart';

class MnemonicPhraseField extends StatelessWidget {
  const MnemonicPhraseField({
    super.key,
    required this.controller,
    this.errorText,
  });

  final TextEditingController controller;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return TextField(
      controller: controller,
      minLines: 3,
      maxLines: 4,
      autocorrect: false,
      enableSuggestions: false,
      textCapitalization: TextCapitalization.none,
      decoration: InputDecoration(
        labelText: l10n.vaultPhraseFieldLabel,
        alignLabelWithHint: true,
        errorText: errorText,
      ),
    );
  }
}

/// Prompt for a 12-word phrase. Owns the [TextEditingController] so it is not
/// disposed while the dialog route is still unmounting.
Future<String?> showMnemonicPhraseDialog({
  required BuildContext context,
  required String title,
  required String body,
  String? confirmLabel,
}) {
  return showDialog<String>(
    context: context,
    builder: (ctx) => _MnemonicPhraseDialog(
      title: title,
      body: body,
      confirmLabel: confirmLabel,
    ),
  );
}

class _MnemonicPhraseDialog extends StatefulWidget {
  const _MnemonicPhraseDialog({
    required this.title,
    required this.body,
    this.confirmLabel,
  });

  final String title;
  final String body;
  final String? confirmLabel;

  @override
  State<_MnemonicPhraseDialog> createState() => _MnemonicPhraseDialogState();
}

class _MnemonicPhraseDialogState extends State<_MnemonicPhraseDialog> {
  late final TextEditingController _ctrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(widget.title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(widget.body),
          const SizedBox(height: 12),
          MnemonicPhraseField(controller: _ctrl),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.commonCancel),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, _ctrl.text),
          child: Text(widget.confirmLabel ?? l10n.commonContinue),
        ),
      ],
    );
  }
}
