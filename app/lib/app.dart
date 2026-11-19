import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/bangla_digits.dart';
import 'core/money.dart';
import 'core/providers.dart';
import 'core/theme.dart';
import 'features/home/home_screen.dart';
import 'features/money/money_screen.dart';
import 'features/settings/settings_screen.dart';
import 'features/tasks/tasks_screen.dart';
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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _resyncNotifications());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
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
