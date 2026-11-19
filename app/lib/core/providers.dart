import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../features/auth/auth_service.dart';
import '../features/command/command_saver.dart';
import '../features/command/command_service.dart';
import '../features/inbox/inbox_store.dart';
import '../features/records/models.dart';
import '../features/records/records_repository.dart';
import '../features/reminders/reminder_scheduler.dart';
import '../features/summary/daily_summary.dart';
import '../features/voice/speech_service.dart';
import 'dhaka_time.dart';

/// Global dependency graph. Each provider can be overridden in tests with a
/// fake, which is the main reason we use Riverpod.

/// Features must use this instead of DateTime.now() so tests can fake time.
final clockProvider = Provider<DateTime Function()>((ref) => DateTime.now);

final sharedPreferencesProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError('Overridden in main()'),
);

final authServiceProvider = Provider<AuthService>((ref) => AuthService(FirebaseAuth.instance));

final authStateProvider = StreamProvider<User?>((ref) => ref.watch(authServiceProvider).userChanges);

final uidProvider = Provider<String?>((ref) => ref.watch(authStateProvider).value?.uid);

final recordsRepositoryProvider = Provider<RecordsRepository?>((ref) {
  final uid = ref.watch(uidProvider);
  if (uid == null) return null;
  return FirestoreRecordsRepository(FirebaseFirestore.instance, uid);
});

final reminderSchedulerProvider = Provider<ReminderScheduler>(
  (ref) => throw UnimplementedError('Overridden in main()'),
);

final speechServiceProvider = Provider<SpeechService>((ref) {
  final service = PlatformSpeechService();
  ref.onDispose(service.dispose);
  return service;
});

/// Cloud Functions in the same region as Firestore (Mumbai, closest to Dhaka).
final commandServiceProvider = Provider<CommandService>(
  (ref) => CloudCommandService(FirebaseFunctions.instanceFor(region: 'asia-south1')),
);

final commandSaverProvider = Provider<CommandSaver?>((ref) {
  final repo = ref.watch(recordsRepositoryProvider);
  if (repo == null) return null;
  return CommandSaver(
    repo: repo,
    scheduler: ref.watch(reminderSchedulerProvider),
    now: ref.watch(clockProvider),
  );
});

final inboxStoreProvider = Provider<InboxStore>((ref) => InboxStore(ref.watch(sharedPreferencesProvider)));

// ---- Live data streams --------------------------------------------------

final remindersProvider = StreamProvider<List<Reminder>>((ref) {
  final repo = ref.watch(recordsRepositoryProvider);
  return repo == null ? const Stream.empty() : repo.watchPendingReminders();
});

final tasksProvider = StreamProvider<List<TaskItem>>((ref) {
  final repo = ref.watch(recordsRepositoryProvider);
  return repo == null ? const Stream.empty() : repo.watchOpenTasks();
});

final monthExpensesProvider = StreamProvider<List<Expense>>((ref) {
  final repo = ref.watch(recordsRepositoryProvider);
  final now = ref.watch(clockProvider)();
  return repo == null ? const Stream.empty() : repo.watchExpensesSince(DhakaTime.startOfMonth(now));
});

final openLedgerProvider = StreamProvider<List<LedgerEntry>>((ref) {
  final repo = ref.watch(recordsRepositoryProvider);
  return repo == null ? const Stream.empty() : repo.watchOpenLedger();
});

final dailySummaryProvider = Provider<DailySummary>((ref) => DailySummary.compute(
      now: ref.watch(clockProvider)(),
      reminders: ref.watch(remindersProvider).value ?? const [],
      tasks: ref.watch(tasksProvider).value ?? const [],
      monthExpenses: ref.watch(monthExpensesProvider).value ?? const [],
      openLedger: ref.watch(openLedgerProvider).value ?? const [],
    ));

// ---- Settings -----------------------------------------------------------

class LocaleNotifier extends Notifier<Locale> {
  static const _key = 'settings.locale';
  @override
  Locale build() => Locale(ref.watch(sharedPreferencesProvider).getString(_key) ?? 'bn');

  Future<void> set(String code) async {
    state = Locale(code);
    await ref.read(sharedPreferencesProvider).setString(_key, code);
  }
}

final localeProvider = NotifierProvider<LocaleNotifier, Locale>(LocaleNotifier.new);

/// Which language the speech recognizer listens for: 'bn-BD' or 'en-US'.
class SpeechLocaleNotifier extends Notifier<String> {
  static const _key = 'settings.speechLocale';
  @override
  String build() => ref.watch(sharedPreferencesProvider).getString(_key) ?? 'bn-BD';

  Future<void> set(String id) async {
    state = id;
    await ref.read(sharedPreferencesProvider).setString(_key, id);
  }
}

final speechLocaleProvider = NotifierProvider<SpeechLocaleNotifier, String>(SpeechLocaleNotifier.new);

class SummaryHourNotifier extends Notifier<int> {
  static const _key = 'settings.summaryHour';
  @override
  int build() => ref.watch(sharedPreferencesProvider).getInt(_key) ?? 21;

  Future<void> set(int hour) async {
    state = hour;
    await ref.read(sharedPreferencesProvider).setInt(_key, hour);
  }
}

final summaryHourProvider = NotifierProvider<SummaryHourNotifier, int>(SummaryHourNotifier.new);
