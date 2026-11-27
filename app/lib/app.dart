import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/bangla_digits.dart';
import 'core/money.dart';
import 'core/providers.dart';
import 'core/theme.dart';
import 'features/assistant/assistant_settings.dart';
import 'features/command/capture_controller.dart';
import 'features/home/home_screen.dart';
import 'features/migration/guest_migration.dart';
import 'features/money/money_screen.dart';
import 'features/settings/settings_screen.dart';
import 'features/tasks/tasks_screen.dart';
import 'features/update/app_updater.dart';
import 'features/update/update_prompt.dart';
import 'l10n/app_localizations.dart';

class BoloApp extends ConsumerWidget {
  const BoloApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      onGenerateTitle: (c) => AppLocalizations.of(c).appTitle,
      debugShowCheckedModeBanner: false,
      theme: BoloTheme.light(),
      darkTheme: BoloTheme.dark(),
      themeMode: ThemeMode.dark,
      locale: ref.watch(localeProvider),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const HomeShell(),
    );
  }
}

/// Shown only if the local database can't be opened. The file is kept as it
/// is (never wiped automatically), docs/13 § 9.
class DatabaseErrorApp extends StatelessWidget {
  const DatabaseErrorApp({super.key, required this.locale});
  final Locale locale;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: BoloTheme.dark(),
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: Builder(
        builder: (context) => Scaffold(
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.error_outline_rounded, size: 48),
                const SizedBox(height: 12),
                Text(AppLocalizations.of(context).dbOpenFailed, textAlign: TextAlign.center),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}

class HomeShell extends ConsumerStatefulWidget {
  const HomeShell({super.key});
  @override
  ConsumerState<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends ConsumerState<HomeShell> with WidgetsBindingObserver {
  int _index = 0;
  StreamSubscription<AppUpdate?>? _liveUpdates;
  int _shownUpdateBuild = 0;
  VoidCallback? _speakingListener;
  ValueListenable<bool>? _speaking;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startSession();
      _resyncNotifications();
      _checkForUpdate();
      _setUpWakeWord();
    });
  }

  // ---------------- data and session ----------------

  /// Nothing here blocks the app: records are local and work offline.
  Future<void> _startSession() async {
    // 1. Copy old Firestore guest data (if any) onto the phone.
    await _runMigration();
    // 2. An anonymous session is used only for the AI quota (ADR-11); no
    //    record depends on it, so failing offline is fine.
    try {
      await ref.read(authServiceProvider).ensureSignedIn();
    } catch (e) {
      debugPrint('Anonymous session unavailable: ${e.runtimeType}');
    }
  }

  Future<void> _runMigration() async {
    final result = await ref.read(migrationStatusProvider.notifier).run();
    if (!mounted || !result.justCompleted) return;
    // Alarms for the copied reminders and tasks.
    await _resyncNotifications();
    if (!mounted || result.copied == 0) return;
    final l = AppLocalizations.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l.migrationDone(localDigits('${result.copied}', lang)))),
    );
  }

  // ---------------- hands-free: "Bolo!" ----------------

  Future<void> _setUpWakeWord() async {
    final device = ref.read(deviceBridgeProvider);
    device.onWake = (locked) => _onWake(locked: locked);
    final speaking = _speaking = ref.read(voiceReplyProvider).speaking;
    _speakingListener = () =>
        _wakeMicGuard(speaking.value || ref.read(captureControllerProvider).phase != CapturePhase.idle);
    speaking.addListener(_speakingListener!);
    // (Re)start the listener if hands-free is on (e.g. after a reboot).
    await ref.read(wakeSyncProvider)();
    // Opened by the wake word from the background / lock screen?
    final launch = await device.consumeWake();
    if (launch.wake) await _onWake(locked: launch.locked);
  }

  /// The user said the assistant's name: come forward, greet, and listen.
  Future<void> _onWake({required bool locked}) async {
    if (!mounted) return;
    final l = AppLocalizations.of(context);
    final lang = ref.read(localeProvider).languageCode;
    Navigator.of(context).popUntil((r) => r.isFirst);
    setState(() => _index = 0);
    ref.read(wakeSessionProvider.notifier).begin(locked: locked);
    final voice = ref.read(voiceReplyProvider);
    await voice.stop();
    if (ref.read(voiceRepliesProvider)) {
      await voice.speak(l.wakeGreeting, languageCode: lang);
    }
    final capture = ref.read(captureControllerProvider);
    if (mounted && capture.phase == CapturePhase.idle) {
      await ref.read(captureControllerProvider.notifier).toggleListening();
    }
  }

  /// While Bolo itself listens or talks, the wake word listener must not use
  /// the microphone (and must not hear Bolo say its own name).
  void _wakeMicGuard(bool busy) {
    final device = ref.read(deviceBridgeProvider);
    if (busy) {
      device.wakePause();
    } else if (!ref.read(wakeSessionProvider).active) {
      device.wakeResume();
    }
  }

  @override
  void dispose() {
    _liveUpdates?.cancel();
    if (_speakingListener != null) _speaking?.removeListener(_speakingListener!);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// Asks Firebase Remote Config whether a newer APK was published, and keeps
  /// listening so a release made while the app is open shows up right away.
  Future<void> _checkForUpdate() async {
    final updater = ref.read(appUpdaterProvider);
    _offerUpdate(updater, await updater.check());
    _liveUpdates ??= updater.liveUpdates.listen((u) => _offerUpdate(updater, u));
  }

  void _offerUpdate(AppUpdater updater, AppUpdate? update) {
    if (update == null || !mounted || update.latestBuild <= _shownUpdateBuild) return;
    _shownUpdateBuild = update.latestBuild; // once per new build per session
    showUpdateDialog(context, updater, update);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Refresh the summary text when the app goes to the background.
    if (state == AppLifecycleState.paused) _refreshSummaryNotification();
    // Back in the app: finish an interrupted migration or session (maybe
    // the phone is online now).
    if (state == AppLifecycleState.resumed) {
      final phase = ref.read(migrationStatusProvider)?.phase;
      if (phase == MigrationPhase.cacheOnly || phase == MigrationPhase.failed || ref.read(currentUserProvider) == null) {
        _startSession();
      }
    }
  }

  /// Re-creates alarms from the database (reinstall / new phone / lost alarms).
  Future<void> _resyncNotifications() async {
    final reminders = await ref.read(remindersProvider.future);
    final tasks = await ref.read(tasksProvider.future);
    await ref.read(reminderSchedulerProvider).resync(reminders: reminders, tasks: tasks);
    await _refreshSummaryNotification();
  }

  Future<void> _refreshSummaryNotification() async {
    if (!mounted) return;
    final l = AppLocalizations.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    final s = ref.read(dailySummaryProvider);
    await ref.read(reminderSchedulerProvider).scheduleDailySummary(
          hour: ref.read(summaryHourProvider),
          title: l.summaryNotificationTitle,
          body: l.summaryNotificationBody(
            localDigits('${s.openTasks}', lang),
            Money.format(s.spentTodayPoisha, languageCode: lang),
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final session = ref.watch(wakeSessionProvider);
    ref.listen(captureControllerProvider.select((c) => c.phase), (prev, phase) {
      _wakeMicGuard(phase != CapturePhase.idle);
      ref.read(wakeSessionProvider.notifier).touch();
    });

    // Over the lock screen: only the robot, no personal data, no tabs.
    if (session.locked) {
      return const Scaffold(body: HomeScreen(privacy: true));
    }
    return Scaffold(
      body: IndexedStack(index: _index, children: const [
        HomeScreen(),
        TasksScreen(),
        MoneyScreen(),
        SettingsScreen(),
      ]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: [
          NavigationDestination(icon: const Icon(Icons.graphic_eq_rounded), label: l.navToday),
          NavigationDestination(icon: const Icon(Icons.checklist_rounded), label: l.navTasks),
          NavigationDestination(icon: const Icon(Icons.account_balance_wallet_rounded), label: l.navMoney),
          NavigationDestination(icon: const Icon(Icons.settings_rounded), label: l.navSettings),
        ],
      ),
    );
  }
}
