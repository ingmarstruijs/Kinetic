import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:kinetic_webdav/kinetic_webdav.dart';

import 'db/app_database.dart';
import 'l10n/generated/app_localizations.dart';
import 'notifications/notification_service.dart';
import 'notifications/reminder_action.dart';
import 'family/proposals/link_member_proposal_repository.dart';
import 'settings/settings_repository.dart';
import 'settings/settings_screen.dart';
import 'support/link_notification_service.dart';
import 'sync/sync_orchestrator.dart';
import 'sync/webdav_config_repository.dart';
import 'theme/app_themes.dart';
import 'todo/screens/notes_screen.dart';
import 'todo/screens/tasks_screen.dart';
import 'todo/services/ai_suggestion_engine.dart';
import 'todo/services/ai_suggestion_repository.dart';
import 'todo/services/note_repository.dart';
import 'todo/services/todo_repository.dart';
import 'todo/widgets/snooze_dialog.dart';
import 'vault/vault_gate.dart';
import 'debug/demo_session.dart';

// Global theme notifier — allows theme changes from anywhere in the app
final themeNotifier = ValueNotifier<AppTheme>(AppTheme.light);

/// Global locale notifier — English by default; `en` / `nl` only.
final localeNotifier = ValueNotifier<Locale>(const Locale('en'));

enum SyncStatus { idle, syncing, error }

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load persisted theme + locale preference
  final db = AppDatabase();
  final settingsRepo = SettingsRepository(db: db);
  final savedTheme = await settingsRepo.loadTheme();
  themeNotifier.value = savedTheme;
  localeNotifier.value = await settingsRepo.loadLocale();

  runApp(KineticLinkApp(db: db, settingsRepo: settingsRepo));
}

class KineticLinkApp extends StatelessWidget {
  final AppDatabase db;
  final SettingsRepository settingsRepo;

  const KineticLinkApp({
    super.key,
    required this.db,
    required this.settingsRepo,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AppTheme>(
      valueListenable: themeNotifier,
      builder: (context, theme, _) {
        return ValueListenableBuilder<Locale>(
          valueListenable: localeNotifier,
          builder: (context, locale, _) {
            return MaterialApp(
              title: 'Kinetic Link',
              debugShowCheckedModeBanner: false,
              theme: buildTheme(theme),
              locale: locale,
              localizationsDelegates: const [
                ...AppLocalizations.localizationsDelegates,
                FlutterQuillLocalizations.delegate,
              ],
              supportedLocales: AppLocalizations.supportedLocales,
              home: VaultGate(
                db: db,
                settingsRepo: settingsRepo,
                readyBuilder: (context) =>
                    _RootShell(db: db, settingsRepo: settingsRepo),
              ),
            );
          },
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Root Shell — bottom-nav scaffold shared by all top-level screens.
// ---------------------------------------------------------------------------

class _RootShell extends StatefulWidget {
  final AppDatabase db;
  final SettingsRepository settingsRepo;

  const _RootShell({required this.db, required this.settingsRepo});

  @override
  State<_RootShell> createState() => _RootShellState();
}

class _RootShellState extends State<_RootShell> with WidgetsBindingObserver {
  late final NotificationService _notifSvc;
  late final TodoRepository _todoRepository;
  late final NoteRepository _noteRepository;
  late final LinkMemberProposalRepository _proposalRepository;
  late final WebDavConfigRepository _webDavConfig;
  late final AiSuggestionRepository _aiSuggestionRepository;
  AiSuggestionEngine? _aiSuggestionEngine;
  SyncOrchestrator? _syncOrchestrator;
  final syncStatus = ValueNotifier<SyncStatus>(SyncStatus.idle);
  final hasOtherLinkMembers = ValueNotifier<bool>(false);
  final enrolledKidsCount = ValueNotifier<int>(0);
  final webDavConfigured = ValueNotifier<bool>(false);

  /// False when this link member turned off kids panels in settings.
  bool _kidsParticipation = true;

  /// Other link members from the cached family roster (for note/task targeting).
  List<({String id, String name})> _otherLinkMembers = const [];

  /// Incremented after every successful sync — lets the kids panel reload.
  final _syncDoneCount = ValueNotifier<int>(0);

  /// False when the user has permanently blocked notifications in system settings.
  final notificationsEnabled = ValueNotifier<bool>(true);

  /// False when the Alarms & Reminders permission is not granted (Android 12+).
  final exactAlarmsGranted = ValueNotifier<bool>(true);

  /// Non-null when notification plugin initialization failed.
  final notifInitError = ValueNotifier<String?>(null);
  Timer? _syncDebounce;
  StreamSubscription<ReminderActionEvent>? _reminderSub;

  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _notifSvc = LinkNotificationService();
    _todoRepository = TodoRepository(
      db: widget.db,
      notifications: _notifSvc,
      onWrite: _scheduleDebouncedSync,
    );
    _noteRepository = NoteRepository(
      db: widget.db,
      notifications: _notifSvc,
      onWrite: _scheduleDebouncedSync,
    );
    _proposalRepository = LinkMemberProposalRepository(
      db: widget.db,
      todoRepository: _todoRepository,
    );
    _webDavConfig = WebDavConfigRepository(FlutterSecureKeyValueStore());

    _aiSuggestionRepository = AiSuggestionRepository(widget.db);

    ReminderActionLabels.languageCode = localeNotifier.value.languageCode;
    localeNotifier.addListener(_onLocaleChanged);
    _reminderSub = ReminderActionBus.instance.stream.listen(_onReminderAction);

    _initSync();
    // Request notification permissions immediately so the Android dialog
    // is shown on first launch rather than waiting for the first reminder.
    _notifSvc.init().then((_) => _checkNotificationPermission()).catchError((
      Object e,
      StackTrace st,
    ) {
      // Store error — visible in both debug and release via the banner.
      final svc = _notifSvc;
      if (svc is LinkNotificationService && svc.initError != null) {
        if (mounted) notifInitError.value = svc.initError.toString();
      } else {
        if (mounted) notifInitError.value = e.toString();
      }
    });
  }

  void _onLocaleChanged() {
    ReminderActionLabels.languageCode = localeNotifier.value.languageCode;
  }

  Future<void> _onReminderAction(ReminderActionEvent event) async {
    await WidgetsBinding.instance.endOfFrame;
    if (!mounted) return;
    final l10n = AppLocalizations.of(context);

    if (event.actionId == ReminderActionId.done) {
      if (event.payload.kind == ReminderKind.task) {
        await _todoRepository.completeTask(event.payload.id);
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.reminderDone)));
      } else {
        await _noteRepository.clearReminder(event.payload.id);
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.noteReminderCleared)));
      }
      return;
    }

    if (event.actionId == ReminderActionId.snooze) {
      final until = await showSnoozeDialog(context);
      if (until == null || !mounted) return;
      if (event.payload.kind == ReminderKind.task) {
        await _todoRepository.snoozeReminder(event.payload.id, until);
      } else {
        await _noteRepository.snoozeReminder(event.payload.id, until);
      }
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.snoozeDone)));
    }
  }

  Future<void> _checkNotificationPermission() async {
    final enabled = await _notifSvc.areNotificationsEnabled();
    final exact = await _notifSvc.canScheduleExactAlarms();
    if (mounted) {
      notificationsEnabled.value = enabled;
      exactAlarmsGranted.value = exact;
    }
  }

  Future<void> _initSync() async {
    final config = await _webDavConfig.load();
    final isPaired = await _webDavConfig.hasOtherLinkMembers();
    final kidsCount = (await _webDavConfig.loadEnrolledKids()).length;
    final kidsParticipation = await _webDavConfig.loadKidsParticipation();
    if (mounted) {
      setState(() => _kidsParticipation = kidsParticipation);
    }

    // Create the orchestrator FIRST so that when the ValueNotifiers below
    // trigger a rebuild, _syncOrchestrator!.config already contains the
    // updated config (including the family key for enrolled kids).
    if (config != null) {
      _syncOrchestrator = SyncOrchestrator(
        db: widget.db,
        config: config,
        configRepository: _webDavConfig,
        onDisconnectsDetected: _handleDisconnects,
        onRosterUpdated: (roster) {
          final myId = config.linkId;
          hasOtherLinkMembers.value = roster.otherLinkMembers(myId).isNotEmpty;
          enrolledKidsCount.value = roster.kids.length;
          _otherLinkMembers = [
            for (final a in roster.otherLinkMembers(myId))
              (id: a.id, name: a.displayName),
          ];
          if (mounted) setState(() {});
        },
      );
      webDavConfigured.value = true;
    } else {
      _syncOrchestrator = null;
      webDavConfigured.value = false;
      syncStatus.value = SyncStatus.idle;
    }

    // Set notifiers after the orchestrator is ready so any rebuild triggered
    // by these changes sees the correct config.
    hasOtherLinkMembers.value = isPaired;
    enrolledKidsCount.value = kidsCount;

    final roster = await _webDavConfig.loadCachedRoster();
    final myId = config?.linkId ?? '';
    _noteRepository.currentLinkId = config?.linkId;
    _otherLinkMembers = [
      for (final a in roster?.otherLinkMembers(myId) ?? const [])
        (id: a.id, name: a.displayName),
    ];
    if (mounted) setState(() {});

    if (config != null) _triggerSync(); // fire-and-forget initial sync

    // Rebuild engine whenever sync config changes (proposal repo may be null initially).
    _aiSuggestionEngine = AiSuggestionEngine(
      db: widget.db,
      suggestionRepo: _aiSuggestionRepository,
      todoRepo: _todoRepository,
      proposalRepo: isPaired ? _proposalRepository : null,
      myLinkId: config?.linkId,
    );
    unawaited(_aiSuggestionEngine!.runIfDue());
  }

  Future<void> _triggerSync() async {
    if (_syncOrchestrator == null) return;
    syncStatus.value = SyncStatus.syncing;
    try {
      // Set timeout of 30 seconds for sync operations
      await _syncOrchestrator!.sync().timeout(
        const Duration(seconds: 30),
        onTimeout: () =>
            throw TimeoutException('Sync operation timed out after 30 seconds'),
      );
      syncStatus.value = SyncStatus.idle;
      _syncDoneCount.value++;
    } catch (e) {
      if (kDebugMode) debugPrint('Sync error: $e');
      syncStatus.value = SyncStatus.error;
    }
  }

  void _scheduleDebouncedSync() {
    _syncDebounce?.cancel();
    _syncDebounce = Timer(const Duration(seconds: 3), _triggerSync);
  }

  /// Called after a backup is restored. Re-schedules all notifications and
  /// re-initialises sync so the restored config takes effect immediately.
  Future<void> _onRestoreComplete() async {
    await _todoRepository.rescheduleAllReminders();
    await _noteRepository.rescheduleAllReminders();
    await _initSync();
  }

  /// Called by [SyncOrchestrator] when disconnect tombstones are found.
  ///
  /// Updates the family-linked and enrolled-kids notifiers so the UI reacts
  /// immediately without requiring the user to navigate away and back.
  Future<void> _handleDisconnects(List<String> disconnectedIds) async {
    final myId = _syncOrchestrator?.linkId ?? '';
    if (disconnectIncludesSelf(myId, disconnectedIds)) {
      await _applyRemoteFamilyRemoval();
      return;
    }

    final isPaired = await _webDavConfig.hasOtherLinkMembers();
    final kids = await _webDavConfig.loadEnrolledKids();
    hasOtherLinkMembers.value = isPaired;
    enrolledKidsCount.value = kids.length;
  }

  /// Called when this device's link id appears in a disconnect tombstone
  /// (another member removed us from the family).
  Future<void> _applyRemoteFamilyRemoval() async {
    await (widget.db.delete(
      widget.db.personalNotes,
    )..where((n) => n.isShared.equals(true))).go();
    await widget.db.delete(widget.db.linkMemberProposals).go();
    await _webDavConfig.clearFamilyKey();
    await _initSync();
    if (!mounted) return;
    final l10n = AppLocalizations.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.familyMemberRemovedFromFamily)),
    );
  }

  /// Trigger a sync whenever the app returns to the foreground.
  /// Also re-check notification permission — user may have toggled it in Settings.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _triggerSync();
      _checkNotificationPermission();
      unawaited(_aiSuggestionEngine?.runIfDue());
    }
  }

  @override
  void dispose() {
    _reminderSub?.cancel();
    localeNotifier.removeListener(_onLocaleChanged);
    _syncDebounce?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    widget.db.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: notificationsEnabled,
      builder: (context, notifEnabled, _) {
        return ValueListenableBuilder<bool>(
          valueListenable: exactAlarmsGranted,
          builder: (context, exactEnabled, _) {
            return ValueListenableBuilder<String?>(
              valueListenable: notifInitError,
              builder: (context, initErr, _) {
                return _buildShell(
                  context,
                  notifEnabled,
                  exactEnabled,
                  initErr,
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildShell(
    BuildContext context,
    bool notifEnabled,
    bool exactEnabled,
    String? initErr,
  ) {
    return ListenableBuilder(
      listenable: DemoSession.instance,
      builder: (context, _) {
        return ValueListenableBuilder<bool>(
          valueListenable: hasOtherLinkMembers,
          builder: (context, pairedReal, _) {
            return ValueListenableBuilder<int>(
              valueListenable: enrolledKidsCount,
              builder: (context, kidsCountReal, _) {
                return ValueListenableBuilder<bool>(
                  valueListenable: webDavConfigured,
                  builder: (context, hasWebDav, _) {
                    final demo = DemoSession.instance;
                    final paired = demo.active
                        ? demo.hasOtherLinkMembers
                        : pairedReal;
                    final kidsCount = demo.active
                        ? demo.kids.length
                        : kidsCountReal;
                    final otherLinks = demo.active
                        ? demo.otherLinkMembers
                        : _otherLinkMembers;
                    _noteRepository.currentLinkId = demo.active
                        ? DemoSession.linkId
                        : _syncOrchestrator?.linkId;
                    final screens = <Widget>[
                      TasksScreen(
                        repo: _todoRepository,
                        settingsRepo: widget.settingsRepo,
                        proposalRepo: paired ? _proposalRepository : null,
                        suggestionRepo: _aiSuggestionRepository,
                        myLinkId: demo.active
                            ? DemoSession.linkId
                            : _syncOrchestrator?.linkId,
                        syncStatus: hasWebDav ? syncStatus : null,
                        hasFamilyKey: paired || kidsCount > 0,
                        hasOtherLinkMembers: paired,
                        otherLinkMembers: otherLinks,
                        onSyncRetry: _triggerSync,
                        configRepo: _webDavConfig,
                        enrolledKidsCount: kidsCount,
                        kidsParticipation: _kidsParticipation,
                        syncDoneCount: _syncDoneCount,
                        syncConfig: demo.active && demo.kids.isNotEmpty
                            ? demo.dummyConfig()
                            : _syncOrchestrator?.config,
                        pullPresence: demo.active
                            ? () async => demo.presence
                            : _syncOrchestrator?.pullPresence,
                        pullSharedTasks: demo.active && demo.kids.isNotEmpty
                            ? () async => demo.kidTasks
                            : null,
                        enrolledKidsOverride:
                            demo.active && demo.kids.isNotEmpty
                            ? demo.kids
                            : null,
                        onDeleteKidTask: demo.active
                            ? (task) async {
                                DemoSession.instance.removeKidTask(task.uid);
                              }
                            : null,
                        onAcceptKidTask: demo.active
                            ? (task) async {
                                DemoSession.instance.acceptKidTask(task.uid);
                              }
                            : (task) async {
                                await _syncOrchestrator
                                    ?.acceptKidsTaskCompletion(task);
                              },
                        onRejectKidTask: demo.active
                            ? (task) async {
                                DemoSession.instance.rejectKidTask(task.uid);
                              }
                            : (task) async {
                                await _syncOrchestrator
                                    ?.rejectKidsTaskCompletion(task);
                              },
                      ),
                      NotesScreen(
                        repo: _noteRepository,
                        settingsRepo: widget.settingsRepo,
                        onSyncRetry: _triggerSync,
                        syncStatus: hasWebDav ? syncStatus : null,
                        hasOtherLinkMembers: paired,
                        myLinkId: demo.active
                            ? DemoSession.linkId
                            : _syncOrchestrator?.linkId,
                        otherLinkMembers: otherLinks,
                      ),
                      SettingsScreen(
                        db: widget.db,
                        configRepo: _webDavConfig,
                        settingsRepo: widget.settingsRepo,
                        syncOrchestrator: _syncOrchestrator,
                        onConfigSaved: _initSync,
                        onRestoreComplete: _onRestoreComplete,
                        onOpenTasksTab: () =>
                            setState(() => _selectedIndex = 0),
                        onOpenNotesTab: () =>
                            setState(() => _selectedIndex = 1),
                      ),
                    ];

                    final l10n = AppLocalizations.of(context);
                    final destinations = <NavigationDestination>[
                      NavigationDestination(
                        icon: const Icon(Icons.check_circle_outline),
                        selectedIcon: const Icon(Icons.check_circle),
                        label: l10n.navTasks,
                      ),
                      NavigationDestination(
                        icon: const Icon(Icons.note_outlined),
                        selectedIcon: const Icon(Icons.note),
                        label: l10n.navNotes,
                      ),
                      NavigationDestination(
                        icon: const Icon(Icons.settings_outlined),
                        selectedIcon: const Icon(Icons.settings),
                        label: l10n.navSettings,
                      ),
                    ];

                    final clampedIndex = _selectedIndex.clamp(
                      0,
                      screens.length - 1,
                    );

                    return Scaffold(
                      body: Column(
                        children: [
                          if (initErr != null)
                            MaterialBanner(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              content: Text(l10n.notifServiceFailed(initErr)),
                              leading: const Icon(
                                Icons.error_outline,
                                color: Colors.red,
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => notifInitError.value = null,
                                  child: Text(l10n.commonClose),
                                ),
                              ],
                            ),
                          if (!notifEnabled)
                            MaterialBanner(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              content: Text(l10n.notifDisabledBanner),
                              leading: const Icon(
                                Icons.notifications_off_outlined,
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    const channel = MethodChannel(
                                      'net.moonbaseone.kinetic.link/settings',
                                    );
                                    channel
                                        .invokeMethod<void>(
                                          'openNotificationSettings',
                                        )
                                        .catchError((_) {});
                                  },
                                  child: Text(l10n.navSettings),
                                ),
                              ],
                            ),
                          if (notifEnabled && !exactEnabled)
                            MaterialBanner(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              content: Text(l10n.notifExactAlarmBanner),
                              leading: const Icon(Icons.alarm_off_outlined),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    const channel = MethodChannel(
                                      'net.moonbaseone.kinetic.link/settings',
                                    );
                                    channel
                                        .invokeMethod<void>(
                                          'openExactAlarmSettings',
                                        )
                                        .catchError((_) {});
                                  },
                                  child: Text(l10n.navSettings),
                                ),
                              ],
                            ),
                          Expanded(
                            child: IndexedStack(
                              index: clampedIndex,
                              children: screens,
                            ),
                          ),
                        ],
                      ),
                      bottomNavigationBar: NavigationBar(
                        selectedIndex: clampedIndex,
                        onDestinationSelected: (i) =>
                            setState(() => _selectedIndex = i),
                        destinations: destinations,
                      ),
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }
}
