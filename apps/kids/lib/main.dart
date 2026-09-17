import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:kinetic_webdav/kinetic_webdav.dart';

import 'db/app_database.dart';
import 'debug/demo_tasks.dart';
import 'enrollment/kids_enrollment_screen.dart';
import 'enrollment/kids_language_picker.dart';
import 'l10n/generated/app_localizations.dart';
import 'notifications/kids_notification_service.dart';
import 'settings/kids_settings_screen.dart';
import 'sync/sync_orchestrator.dart';
import 'sync/webdav_config_repository.dart';
import 'task/screens/kids_home_screen.dart';
import 'task/services/kids_task_repository.dart';

const _kLocaleKey = 'kinetic_locale';
const _kThemeKey = 'kinetic_theme';
const _kLocaleChosenKey = 'kinetic_locale_chosen';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final appDb = AppDatabase();
  final notificationService = KidsNotificationService();
  await notificationService.initialize();
  runApp(
    KineticKidsApp(appDb: appDb, notificationService: notificationService),
  );
}

ThemeData _kidsTheme(Brightness brightness) {
  const seed = Color(0xFFF97316);
  final scheme = ColorScheme.fromSeed(
    seedColor: seed,
    brightness: brightness,
    surface: brightness == Brightness.dark
        ? const Color(0xFF1A1410)
        : const Color(0xFFFFF8F3),
    surfaceContainerLow: brightness == Brightness.dark
        ? const Color(0xFF2A211C)
        : const Color(0xFFF5E8DC),
  );
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    brightness: brightness,
    scaffoldBackgroundColor: scheme.surface,
    appBarTheme: AppBarTheme(
      backgroundColor: scheme.surface,
      foregroundColor: scheme.onSurface,
      elevation: 0,
      centerTitle: false,
    ),
    cardTheme: CardThemeData(
      color: scheme.surfaceContainerLow,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
  );
}

class KineticKidsApp extends StatefulWidget {
  final AppDatabase appDb;
  final KidsNotificationService notificationService;

  const KineticKidsApp({
    super.key,
    required this.appDb,
    required this.notificationService,
  });

  @override
  State<KineticKidsApp> createState() => _KineticKidsAppState();
}

class _KineticKidsAppState extends State<KineticKidsApp> {
  Locale? _locale;
  ThemeMode _themeMode = ThemeMode.dark;
  bool _prefsLoaded = false;
  bool _localeChosen = false;

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final store = FlutterSecureKeyValueStore();
    final localeCode = await store.read(key: _kLocaleKey);
    final theme = await store.read(key: _kThemeKey);
    final chosen = await store.read(key: _kLocaleChosenKey);
    if (!mounted) return;
    setState(() {
      _locale = localeCode == 'nl' ? const Locale('nl') : const Locale('en');
      _themeMode = theme == 'light' ? ThemeMode.light : ThemeMode.dark;
      _localeChosen = chosen == '1';
      _prefsLoaded = true;
    });
  }

  Future<void> _setLocale(Locale locale) async {
    final store = FlutterSecureKeyValueStore();
    await store.write(key: _kLocaleKey, value: locale.languageCode);
    await store.write(key: _kLocaleChosenKey, value: '1');
    if (mounted) {
      setState(() {
        _locale = locale;
        _localeChosen = true;
      });
    }
  }

  Future<void> _setThemeMode(ThemeMode mode) async {
    final store = FlutterSecureKeyValueStore();
    await store.write(
      key: _kThemeKey,
      value: mode == ThemeMode.light ? 'light' : 'dark',
    );
    if (mounted) setState(() => _themeMode = mode);
  }

  @override
  Widget build(BuildContext context) {
    if (!_prefsLoaded) {
      return MaterialApp(
        theme: _kidsTheme(Brightness.light),
        darkTheme: _kidsTheme(Brightness.dark),
        themeMode: ThemeMode.dark,
        home: const Scaffold(body: Center(child: CircularProgressIndicator())),
      );
    }

    return MaterialApp(
      title: 'Kinetic Kids',
      debugShowCheckedModeBanner: false,
      locale: _locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      theme: _kidsTheme(Brightness.light),
      darkTheme: _kidsTheme(Brightness.dark),
      themeMode: _themeMode,
      home: !_localeChosen
          ? Scaffold(
              body: SafeArea(
                child: KidsLanguagePicker(
                  selected: _locale ?? const Locale('en'),
                  onSelected: _setLocale,
                  onContinue: () => _setLocale(_locale ?? const Locale('en')),
                ),
              ),
            )
          : _KidsAppShell(
              appDb: widget.appDb,
              notificationService: widget.notificationService,
              locale: _locale ?? const Locale('en'),
              themeMode: _themeMode,
              onLocaleChanged: _setLocale,
              onThemeModeChanged: _setThemeMode,
            ),
    );
  }
}

class _KidsAppShell extends StatefulWidget {
  final AppDatabase appDb;
  final KidsNotificationService notificationService;
  final Locale locale;
  final ThemeMode themeMode;
  final ValueChanged<Locale> onLocaleChanged;
  final ValueChanged<ThemeMode> onThemeModeChanged;

  const _KidsAppShell({
    required this.appDb,
    required this.notificationService,
    required this.locale,
    required this.themeMode,
    required this.onLocaleChanged,
    required this.onThemeModeChanged,
  });

  @override
  State<_KidsAppShell> createState() => _KidsAppShellState();
}

class _KidsAppShellState extends State<_KidsAppShell>
    with WidgetsBindingObserver {
  late final KidsTaskRepository _repository;
  KidsSyncOrchestrator? _orchestrator;
  bool _enrolled = false;
  bool _initDone = false;
  DateTime? _xpResetAt;
  KidGoal? _goal;

  @override
  void initState() {
    super.initState();
    _repository = KidsTaskRepository(db: widget.appDb);
    WidgetsBinding.instance.addObserver(this);
    _initSync();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _orchestrator?.sync();
    }
  }

  Future<void> _initSync() async {
    final store = FlutterSecureKeyValueStore();
    final configRepo = WebDavConfigRepository(store);
    final config = await configRepo.load();
    final kidId = await configRepo.loadKidId() ?? '';
    final resetAtStr = await store.read(key: 'kinetic_xp_reset_at');
    final xpResetAt = resetAtStr != null ? DateTime.tryParse(resetAtStr) : null;
    if (!mounted) return;
    if (config != null) {
      setState(() {
        _enrolled = true;
        _initDone = true;
        _xpResetAt = xpResetAt;
        _orchestrator = KidsSyncOrchestrator(
          db: widget.appDb,
          repo: _repository,
          config: config,
          myKidId: kidId,
          onDisconnected: () {
            if (mounted) _leaveFamily();
          },
          onXpResetReceived: (resetAt) async {
            await FlutterSecureKeyValueStore().write(
              key: 'kinetic_xp_reset_at',
              value: resetAt.toUtc().toIso8601String(),
            );
            await _repository.hardDeleteCompleted();
            if (mounted) setState(() => _xpResetAt = resetAt);
          },
          onGoalReceived: (goal) {
            if (mounted) setState(() => _goal = goal);
          },
          onNewTaskReceived: (taskTitle) {
            final l10n = AppLocalizations.of(context);
            widget.notificationService.showNewTaskNotification(
              taskTitle,
              title: l10n.newTaskNotificationTitle,
            );
          },
        );
      });
      unawaited(_orchestrator!.sync());
    } else {
      setState(() {
        _enrolled = false;
        _initDone = true;
        _orchestrator = null;
      });
    }
  }

  Future<void> _loadDemo() async {
    final dutch = widget.locale.languageCode == 'nl';
    await loadKidsDemoTasks(widget.appDb, dutch: dutch);
    if (!mounted) return;
    setState(() {
      _enrolled = true;
      _initDone = true;
      _orchestrator = null;
    });
  }

  Future<void> _leaveFamily() async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.leaveFamilyTitle),
        content: Text(l10n.leaveFamilyMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(ctx).colorScheme.error,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l10n.leave),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    final store = FlutterSecureKeyValueStore();
    final configRepo = WebDavConfigRepository(store);
    await configRepo.clearEnrollment();
    if (mounted) {
      setState(() {
        _enrolled = false;
        _orchestrator = null;
        _goal = null;
      });
    }
  }

  void _openSettings() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => KidsSettingsScreen(
          locale: widget.locale,
          themeMode: widget.themeMode,
          onLocaleChanged: widget.onLocaleChanged,
          onThemeModeChanged: widget.onThemeModeChanged,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_initDone) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (!_enrolled) {
      return KidsEnrollmentScreen(
        configRepo: WebDavConfigRepository(FlutterSecureKeyValueStore()),
        onEnrolled: _initSync,
        onLoadDemo: kDebugMode ? _loadDemo : null,
      );
    }

    return KidsHomeScreen(
      appDb: widget.appDb,
      repository: _repository,
      orchestrator: _orchestrator,
      xpResetAt: _xpResetAt,
      goal: _goal,
      onLeaveFamily: _enrolled && _orchestrator != null ? _leaveFamily : null,
      onLoadDemo: kDebugMode ? _loadDemo : null,
      onOpenSettings: _openSettings,
    );
  }
}

void unawaited(Future<void> future) {
  future.ignore();
}
