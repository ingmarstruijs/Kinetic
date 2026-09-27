import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../db/app_database.dart';
import '../family/proposals/link_member_proposal_repository.dart';
import '../sync/sync_orchestrator.dart';
import '../sync/webdav_config_repository.dart';
import '../theme/app_header.dart';
import '../todo/services/ai_suggestion_engine.dart';
import '../todo/services/ai_suggestion_repository.dart';
import '../todo/services/todo_repository.dart';
import 'demo_session.dart';
import 'heuristic_log.dart';

/// Debug-only screen to force-run [AiSuggestionEngine] and inspect reasoning.
class HeuristicDebugScreen extends StatefulWidget {
  final AppDatabase db;
  final TodoRepository todoRepo;
  final WebDavConfigRepository configRepo;
  final SyncOrchestrator? syncOrchestrator;

  const HeuristicDebugScreen({
    super.key,
    required this.db,
    required this.todoRepo,
    required this.configRepo,
    this.syncOrchestrator,
  });

  @override
  State<HeuristicDebugScreen> createState() => _HeuristicDebugScreenState();
}

class _HeuristicDebugScreenState extends State<HeuristicDebugScreen> {
  bool _running = false;
  bool _clearPendingFirst = true;
  String? _status;

  Future<void> _run({required bool force}) async {
    if (_running) return;
    setState(() {
      _running = true;
      _status = null;
    });
    HeuristicLog.instance.clear();
    HeuristicLog.instance.add(
      force ? 'manual force run requested' : 'manual runIfDue requested',
    );

    try {
      final suggestionRepo = AiSuggestionRepository(widget.db);
      if (_clearPendingFirst) {
        final cleared = await suggestionRepo.clearPending();
        HeuristicLog.instance.add('cleared $cleared pending suggestion(s)');
      }

      final demo = DemoSession.instance;
      final config = demo.active
          ? demo.dummyConfig()
          : await widget.configRepo.load();
      final paired = demo.active
          ? demo.hasOtherLinkMembers
          : await widget.configRepo.hasOtherLinkMembers();
      HeuristicLog.instance.add(
        'context demo=${demo.active} paired=$paired '
        'demoLoadMetrics=${demo.loadMetrics.length}',
      );

      final engine = AiSuggestionEngine(
        db: widget.db,
        suggestionRepo: suggestionRepo,
        todoRepo: widget.todoRepo,
        proposalRepo: paired
            ? LinkMemberProposalRepository(
                db: widget.db,
                todoRepository: widget.todoRepo,
              )
            : null,
        pullLoadMetrics: demo.active
            ? () async => demo.loadMetrics
            : widget.syncOrchestrator?.pullLoadMetrics,
        myLinkId: config?.linkId ??
            (demo.active ? DemoSession.linkId : null),
      );
      await engine.runIfDue(force: force);
      final pendingSelf = await suggestionRepo.countPendingSelf();
      final pendingFamily = await suggestionRepo.countPendingFamilyMember();
      if (!mounted) return;
      setState(() {
        _status =
            'Done — pending self=$pendingSelf, family=$pendingFamily';
      });
    } catch (e) {
      HeuristicLog.instance.add('ERROR: $e');
      if (!mounted) return;
      setState(() => _status = 'Failed: $e');
    } finally {
      if (mounted) setState(() => _running = false);
    }
  }

  Future<void> _copyLog() async {
    final text = HeuristicLog.instance.lines.join('\n');
    await Clipboard.setData(ClipboardData(text: text));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Log copied')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final nl = Localizations.localeOf(context).languageCode == 'nl';
    final scheme = Theme.of(context).colorScheme;
    final demo = DemoSession.instance;

    return Scaffold(
      appBar: AppBar(
        title: AppHeader(
          title: 'Heuristic engine',
          centerTitle: false,
        ),
        centerTitle: false,
        actions: [
          IconButton(
            tooltip: nl ? 'Log wissen' : 'Clear log',
            onPressed: _running ? null : HeuristicLog.instance.clear,
            icon: const Icon(Icons.delete_outline),
          ),
          IconButton(
            tooltip: nl ? 'Kopieer log' : 'Copy log',
            onPressed: _copyLog,
            icon: const Icon(Icons.copy_outlined),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Text(
              nl
                  ? 'Force negeert de 24u-throttle. UI-scenario’s (zoals Full house) seeden al suggesties — wis pending eerst, anders blijft created=0. Demo-family wordt meegenomen.'
                  : 'Force ignores the 24h throttle. UI scenarios (e.g. Full house) already seed suggestions — clear pending first or created stays 0. Demo family pairing is respected.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          if (demo.active)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Text(
                nl
                    ? 'Demo actief: paired=${demo.hasOtherLinkMembers}, '
                        'loadMetrics=${demo.loadMetrics.length}'
                    : 'Demo active: paired=${demo.hasOtherLinkMembers}, '
                        'loadMetrics=${demo.loadMetrics.length}',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: scheme.tertiary,
                    ),
              ),
            ),
          SwitchListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            title: Text(
              nl
                  ? 'Pending suggesties wissen vóór run'
                  : 'Clear pending suggestions before run',
            ),
            value: _clearPendingFirst,
            onChanged: _running
                ? null
                : (v) => setState(() => _clearPendingFirst = v),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: _running ? null : () => _run(force: true),
                    icon: _running
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.play_arrow),
                    label: const Text('Force run'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _running ? null : () => _run(force: false),
                    icon: const Icon(Icons.schedule),
                    label: const Text('Run if due'),
                  ),
                ),
              ],
            ),
          ),
          if (_status != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Text(
                _status!,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: scheme.primary,
                    ),
              ),
            ),
          const Divider(height: 24),
          Expanded(
            child: ListenableBuilder(
              listenable: HeuristicLog.instance,
              builder: (context, _) {
                final lines = HeuristicLog.instance.lines;
                if (lines.isEmpty) {
                  return Center(
                    child: Text(
                      nl
                          ? 'Nog geen logregels — start een run.'
                          : 'No log lines yet — start a run.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                    ),
                  );
                }
                return SelectionArea(
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    itemCount: lines.length,
                    itemBuilder: (context, index) {
                      final line = lines[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(
                          line,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                fontFamily: 'monospace',
                                height: 1.35,
                              ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
