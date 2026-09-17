import 'package:flutter/material.dart';

import '../l10n/generated/app_localizations.dart';

/// Language picker shown before family enrollment (and reusable from settings).
class KidsLanguagePicker extends StatelessWidget {
  final Locale selected;
  final ValueChanged<Locale> onSelected;
  final VoidCallback? onContinue;

  const KidsLanguagePicker({
    super.key,
    required this.selected,
    required this.onSelected,
    this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            l10n.chooseLanguage,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          _LangCard(
            label: l10n.languageEnglish,
            selected: selected.languageCode == 'en',
            color: scheme.primary,
            onTap: () => onSelected(const Locale('en')),
          ),
          const SizedBox(height: 12),
          _LangCard(
            label: l10n.languageDutch,
            selected: selected.languageCode == 'nl',
            color: scheme.primary,
            onTap: () => onSelected(const Locale('nl')),
          ),
          if (onContinue != null) ...[
            const SizedBox(height: 32),
            FilledButton(
              onPressed: onContinue,
              child: Text(l10n.continueLabel),
            ),
          ],
        ],
      ),
    );
  }
}

class _LangCard extends StatelessWidget {
  final String label;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  const _LangCard({
    required this.label,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: selected ? color.withValues(alpha: 0.2) : scheme.surfaceContainerLow,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
              if (selected) Icon(Icons.check_circle, color: color),
            ],
          ),
        ),
      ),
    );
  }
}
