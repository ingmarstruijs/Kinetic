import 'package:flutter/material.dart';

import '../db/app_database.dart';
import '../l10n/generated/app_localizations.dart';
import 'demo_scenarios.dart';

/// Debug-only catalog to load named UI states for screenshots and manual QA.
class KidsDemoScenariosScreen extends StatelessWidget {
  final AppDatabase db;
  final void Function(KidsDemoScenarioResult result)? onApplied;

  const KidsDemoScenariosScreen({
    super.key,
    required this.db,
    this.onApplied,
  });

  @override
  Widget build(BuildContext context) {
    final nl = Localizations.localeOf(context).languageCode == 'nl';
    return Scaffold(
      appBar: AppBar(
        title: Text(nl ? 'UI-scenario\'s' : 'UI scenarios'),
        centerTitle: false,
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              nl
                  ? 'Start de app alsof je gekoppeld bent aan een gezin. Vervangt lokale klusjes op dit debug-toestel (geen WebDAV).'
                  : 'Start the app as if enrolled in a family. Replaces local chores on this debug device (no WebDAV).',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          for (final item in kidsDemoScenarioCatalog)
            ListTile(
              leading: const Icon(Icons.movie_filter_outlined),
              title: Text(item.title(nl)),
              subtitle: Text(item.subtitle(nl)),
              onTap: () => _apply(context, item, nl),
            ),
        ],
      ),
    );
  }

  Future<void> _apply(
    BuildContext context,
    KidsDemoScenarioInfo item,
    bool nl,
  ) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(item.title(nl)),
        content: Text(
          nl
              ? 'Huidige klusjes worden vervangen. Je gaat naar het startscherm alsof je bent gekoppeld.'
              : 'Current chores will be replaced. You will enter the home screen as if enrolled.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(nl ? 'Laden' : 'Load'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    final result = await KidsDemoScenarioLoader(
      db: db,
    ).apply(item.id, dutch: nl);
    if (!context.mounted) return;
    onApplied?.call(result);
    Navigator.of(context).pop();
  }
}
