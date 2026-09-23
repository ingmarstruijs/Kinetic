import 'package:flutter/material.dart';

import '../db/app_database.dart';
import '../l10n/generated/app_localizations.dart';
import '../family/proposals/link_member_proposal_repository.dart';
import '../theme/app_header.dart';
import '../todo/services/ai_suggestion_repository.dart';
import '../todo/services/note_repository.dart';
import '../todo/services/todo_repository.dart';
import 'demo_scenarios.dart';

/// Debug-only catalog to load named UI states for screenshots and manual QA.
class DemoScenariosScreen extends StatelessWidget {
  final AppDatabase db;
  final void Function(DemoScenario scenario)? onApplied;

  const DemoScenariosScreen({super.key, required this.db, this.onApplied});

  @override
  Widget build(BuildContext context) {
    final nl = Localizations.localeOf(context).languageCode == 'nl';
    return Scaffold(
      appBar: AppBar(
        title: AppHeader(
          title: nl ? 'UI-scenario\'s' : 'UI scenarios',
          centerTitle: false,
        ),
        centerTitle: false,
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              nl
                  ? 'Vervangt taken, notities, suggesties en voorstellen op dit debug-toestel. Partnerkoppeling en kinderen blijven lokaal (niet in WebDAV).'
                  : 'Replaces tasks, notes, suggestions and proposals on this debug device. Family linking and kids stay local (not on WebDAV).',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          for (final item in demoScenarioCatalog)
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
    DemoScenarioInfo item,
    bool nl,
  ) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(item.title(nl)),
        content: Text(
          nl
              ? 'Huidige taken, notities, suggesties en voorstellen worden vervangen.'
              : 'Current tasks, notes, suggestions and proposals will be replaced.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.commonCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(nl ? 'Laden' : 'Load'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    final todoRepo = TodoRepository(db: db);
    final loader = DemoScenarioLoader(
      db: db,
      todoRepo: todoRepo,
      noteRepo: NoteRepository(db: db),
      suggestionRepo: AiSuggestionRepository(db),
      proposalRepo: LinkMemberProposalRepository(db: db, todoRepository: todoRepo),
    );
    await loader.apply(item.id, dutch: nl);
    if (!context.mounted) return;
    Navigator.of(context).pop();
    onApplied?.call(item.id);
  }
}
