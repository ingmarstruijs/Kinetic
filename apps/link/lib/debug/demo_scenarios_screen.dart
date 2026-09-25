import 'package:flutter/material.dart';

import '../db/app_database.dart';
import '../l10n/generated/app_localizations.dart';
import '../family/proposals/link_member_proposal_repository.dart';
import '../theme/app_header.dart';
import '../todo/services/ai_suggestion_repository.dart';
import '../todo/services/note_repository.dart';
import '../todo/services/todo_repository.dart';
import 'demo_scenarios.dart';
import 'demo_session.dart';

/// Debug-only catalog to load named UI states for screenshots and manual QA.
class DemoScenariosScreen extends StatelessWidget {
  final AppDatabase db;
  final void Function(DemoScenario scenario)? onApplied;

  /// Called after leaving demo mode so the app can resume WebDAV sync.
  final VoidCallback? onExited;

  const DemoScenariosScreen({
    super.key,
    required this.db,
    this.onApplied,
    this.onExited,
  });

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
      body: ListenableBuilder(
        listenable: DemoSession.instance,
        builder: (context, _) {
          final active = DemoSession.instance.active;
          return ListView(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Text(
                  nl
                      ? 'Vervangt taken, notities, suggesties en voorstellen op dit debug-toestel. WebDAV-sync wordt gepauzeerd zolang een scenario actief is (ook bij “leeg”), zodat de server je UI niet terugzet of demo-data uploadt.'
                      : 'Replaces tasks, notes, suggestions and proposals on this debug device. WebDAV sync pauses while a scenario is active (including Empty), so the server cannot restore or upload demo data.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
              if (active) ...[
                ListTile(
                  leading: Icon(
                    Icons.sync,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  title: Text(
                    nl
                        ? 'Scenario uitzetten & sync hervatten'
                        : 'Exit scenario & resume sync',
                  ),
                  subtitle: Text(
                    nl
                        ? 'Wist lokale demo-data en haalt weer je WebDAV-data op'
                        : 'Clears local demo data and pulls from WebDAV again',
                  ),
                  onTap: () => _exit(context, nl),
                ),
                const Divider(height: 1),
              ],
              for (final item in demoScenarioCatalog)
                ListTile(
                  leading: const Icon(Icons.movie_filter_outlined),
                  title: Text(item.title(nl)),
                  subtitle: Text(item.subtitle(nl)),
                  onTap: () => _apply(context, item, nl),
                ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _exit(BuildContext context, bool nl) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          nl
              ? 'Scenario uitzetten?'
              : 'Exit UI scenario?',
        ),
        content: Text(
          nl
              ? 'Lokale demo-taken/-notities verdwijnen. WebDAV-sync gaat weer aan en haalt je echte data op.'
              : 'Local demo tasks/notes are removed. WebDAV sync turns back on and pulls your real data.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.commonCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(nl ? 'Uitzetten' : 'Exit'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    await DemoScenarioLoader.exitDemoMode(db);
    if (!context.mounted) return;
    Navigator.of(context).pop();
    onExited?.call();
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
      proposalRepo: LinkMemberProposalRepository(
        db: db,
        todoRepository: todoRepo,
      ),
    );
    await loader.apply(item.id, dutch: nl);
    if (!context.mounted) return;
    Navigator.of(context).pop();
    onApplied?.call(item.id);
  }
}
