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
      home: const AuthGate(),
    );
  }
}

/// Signs in anonymously on first launch; shows a retry screen if offline.
class AuthGate extends ConsumerStatefulWidget {
  const AuthGate({super.key});
  @override
  ConsumerState<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends ConsumerState<AuthGate> {
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _signIn();
  }

  Future<void> _signIn() async {
    setState(() => _failed = false);
    try {
      await ref.read(authServiceProvider).ensureSignedIn();
    } catch (e) {
      debugPrint('Sign-in failed: $e');
      if (mounted) setState(() => _failed = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final user = ref.watch(authStateProvider).value;
    if (user != null) return const HomeShell();
    return Scaffold(
      body: Center(
        child: _failed
            ? Padding(
                padding: const EdgeInsets.all(24),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.wifi_off_rounded, size: 48),
                  const SizedBox(height: 12),
                  Text(l.signInFailed, textAlign: TextAlign.center),
                  const SizedBox(height: 12),
                  FilledButton(onPressed: _signIn, child: Text(l.retry)),
                ]),
              )
            : const CircularProgressIndicator(),
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
      _resyncNotifications();
      _checkForUpdate();
      _setUpWakeWord();
    });
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
