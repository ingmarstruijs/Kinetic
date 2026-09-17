import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../l10n/generated/app_localizations.dart';

class KidsSettingsScreen extends StatelessWidget {
  final Locale locale;
  final ThemeMode themeMode;
  final ValueChanged<Locale> onLocaleChanged;
  final ValueChanged<ThemeMode> onThemeModeChanged;
  final VoidCallback? onOpenDemoScenarios;

  const KidsSettingsScreen({
    super.key,
    required this.locale,
    required this.themeMode,
    required this.onLocaleChanged,
    required this.onThemeModeChanged,
    this.onOpenDemoScenarios,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.settings)),
      body: ListView(
        children: [
          ListTile(
            title: Text(l10n.settingsLanguage),
            subtitle: Text(
              locale.languageCode == 'nl'
                  ? l10n.languageDutch
                  : l10n.languageEnglish,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SegmentedButton<String>(
              segments: [
                ButtonSegment(value: 'en', label: Text(l10n.languageEnglish)),
                ButtonSegment(value: 'nl', label: Text(l10n.languageDutch)),
              ],
              selected: {locale.languageCode},
              onSelectionChanged: (s) {
                onLocaleChanged(Locale(s.first));
              },
            ),
          ),
          const SizedBox(height: 16),
          ListTile(
            title: Text(l10n.settingsTheme),
            subtitle: Text(
              themeMode == ThemeMode.light ? l10n.themeLight : l10n.themeDark,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SegmentedButton<ThemeMode>(
              segments: [
                ButtonSegment(
                  value: ThemeMode.light,
                  label: Text(l10n.themeLight),
                  icon: const Icon(Icons.light_mode_outlined),
                ),
                ButtonSegment(
                  value: ThemeMode.dark,
                  label: Text(l10n.themeDark),
                  icon: const Icon(Icons.dark_mode_outlined),
                ),
              ],
              selected: {themeMode},
              onSelectionChanged: (s) => onThemeModeChanged(s.first),
            ),
          ),
          if (kDebugMode && onOpenDemoScenarios != null) ...[
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.movie_filter_outlined),
              title: Text(
                locale.languageCode == 'nl'
                    ? 'UI-scenario\'s'
                    : 'UI scenarios',
              ),
              subtitle: Text(
                locale.languageCode == 'nl'
                    ? 'Laad testdata alsof je gekoppeld bent'
                    : 'Load test data as if enrolled',
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: onOpenDemoScenarios,
            ),
          ],
        ],
      ),
    );
  }
}
