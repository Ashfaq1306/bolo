import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/bolo_database.dart';
import '../data/device_identity.dart';
import '../features/auth/auth_service.dart';
import '../features/command/command_saver.dart';
import '../features/command/command_service.dart';
import '../features/inbox/inbox_store.dart';
import '../features/migration/guest_migration.dart';
import '../features/migration/legacy_source.dart';
import '../features/records/drift_records_repository.dart';
import '../features/records/models.dart';
import '../features/records/records_repository.dart';
import '../features/reminders/reminder_scheduler.dart';
import '../features/summary/daily_summary.dart';
import '../features/update/app_updater.dart';
import '../features/receipt/receipt_scanner.dart';
import '../features/voice/speech_service.dart';
import '../features/voice/voice_reply.dart';
import 'dhaka_time.dart';

/// Global dependency graph. Each provider can be overridden in tests with a
/// fake, which is the main reason we use Riverpod.

/// Features must use this instead of DateTime.now() so tests can fake time.
final clockProvider = Provider<DateTime Function()>((ref) => DateTime.now);

final sharedPreferencesProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError('Overridden in main()'),
);

/// The local database (ADR-10). Opened in main().
final databaseProvider = Provider<BoloDatabase>(
  (ref) => throw UnimplementedError('Overridden in main()'),
);

/// This phone's device identity: owns the guest workspace (ADR-11).
final deviceIdentityProvider = Provider<DeviceIdentity>(
  (ref) => throw UnimplementedError('Overridden in main()'),
);

final authServiceProvider = Provider<AuthService>((ref) => AuthService(FirebaseAuth.instance));

final authStateProvider = StreamProvider<User?>((ref) => ref.watch(authServiceProvider).userChanges);

/// The Firebase user restored at startup, used until [authStateProvider]
/// delivers its first value (so a registered user never flashes guest data).
final initialUserProvider = Provider<User?>((ref) => null);

final currentUserProvider = Provider<User?>((ref) {
  final auth = ref.watch(authStateProvider);
  return auth.hasValue ? auth.value : ref.watch(initialUserProvider);
});

/// The uid of a registered (non-anonymous) account, or null for a guest.
/// An anonymous Firebase session never owns records (ADR-11).
final registeredUidProvider = Provider<String?>((ref) {
  final user = ref.watch(currentUserProvider);
  return user == null || user.isAnonymous ? null : user.uid;
});

final recordsRepositoryProvider = Provider<RecordsRepository>((ref) {
  final registeredUid = ref.watch(registeredUidProvider);
  // Accounts registered before Phase 2 keep their Firestore data until
  // registered sync ships. Guests are local-only.
  if (registeredUid != null) return FirestoreRecordsRepository(FirebaseFirestore.instance, registeredUid);
  final identity = ref.watch(deviceIdentityProvider);
  return DriftRecordsRepository(
    ref.watch(databaseProvider),
    ownerScope: identity.guestScope,
    deviceId: identity.deviceId,
    clock: ref.watch(clockProvider),
  );
});

/// One-time copy of the old Firestore guest data into the local database.
final guestMigrationProvider = Provider<GuestMigration>((ref) => GuestMigration(
      db: ref.watch(databaseProvider),
      identity: ref.watch(deviceIdentityProvider),
      clock: ref.watch(clockProvider),
      sourceFor: (legacyUid) => FirestoreLegacySource(
        FirebaseFirestore.instance,
        legacyUid: legacyUid,
        currentUid: () => FirebaseAuth.instance.currentUser?.uid,
      ),
    ));

class MigrationStatusNotifier extends Notifier<MigrationStatus?> {
  Future<MigrationStatus>? _running;

  @override
  MigrationStatus? build() => null;

  /// Runs or resumes the migration; concurrent calls share one run.
  Future<MigrationStatus> run() => _running ??= () async {
        try {
          final migration = ref.read(guestMigrationProvider);
          final before = await migration.status();
          if (before.phase == MigrationPhase.notNeeded || before.phase == MigrationPhase.done) {
            state = before;
            return before;
          }
          state = MigrationStatus(MigrationPhase.running, copied: before.copied);
          final result = await migration.run();
          state = result;
          return result.phase == MigrationPhase.done
              ? MigrationStatus(result.phase, copied: result.copied, justCompleted: true)
              : result;
        } finally {
          _running = null;
        }
      }();
}

final migrationStatusProvider =
    NotifierProvider<MigrationStatusNotifier, MigrationStatus?>(MigrationStatusNotifier.new);

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
  // The AI first; if the server can't answer (function not deployed yet, or
  // it failed), the free on-device rules parser fills the card instead.
  (ref) => FallbackCommandService(
    CloudCommandService(FirebaseFunctions.instanceFor(region: 'asia-south1')),
    clock: ref.read(clockProvider),
  ),
);

/// Checks Firebase Remote Config for a newer APK (see app_updater.dart).
final appUpdaterProvider = Provider<AppUpdater>((ref) => RemoteConfigAppUpdater());

final commandSaverProvider = Provider<CommandSaver>((ref) {
  return CommandSaver(
    repo: ref.watch(recordsRepositoryProvider),
    scheduler: ref.watch(reminderSchedulerProvider),
    now: ref.watch(clockProvider),
  );
});

/// Inbox captures are always local to this phone, for guests and accounts.
final inboxStoreProvider = Provider<InboxStore>(
  (ref) => InboxStore(ref.watch(databaseProvider), ownerScope: ref.watch(deviceIdentityProvider).guestScope),
);

final inboxItemsProvider = StreamProvider<List<InboxItem>>((ref) => ref.watch(inboxStoreProvider).watch());

/// Bolo's voice (phone text-to-speech).
final voiceReplyProvider = Provider<VoiceReplyService>((ref) => DeviceVoiceReplyService());

final receiptScannerProvider = Provider<ReceiptScanner>((ref) => ReceiptScanner());

// ---- Live data streams --------------------------------------------------

final remindersProvider = StreamProvider<List<Reminder>>((ref) {
  return ref.watch(recordsRepositoryProvider).watchPendingReminders();
});

final tasksProvider = StreamProvider<List<TaskItem>>((ref) {
  return ref.watch(recordsRepositoryProvider).watchOpenTasks();
});

final monthExpensesProvider = StreamProvider<List<Expense>>((ref) {
  final now = ref.watch(clockProvider)();
  return ref.watch(recordsRepositoryProvider).watchExpensesSince(DhakaTime.startOfMonth(now));
});

final openLedgerProvider = StreamProvider<List<LedgerEntry>>((ref) {
  return ref.watch(recordsRepositoryProvider).watchOpenLedger();
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
  static const prefsKey = 'settings.locale';
  static const _key = prefsKey;
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

class VoiceRepliesNotifier extends Notifier<bool> {
  static const _key = 'settings.voiceReplies';
  @override
  bool build() => ref.watch(sharedPreferencesProvider).getBool(_key) ?? true;

  Future<void> set(bool on) async {
    state = on;
    await ref.read(sharedPreferencesProvider).setBool(_key, on);
    if (!on) await ref.read(voiceReplyProvider).stop();
  }
}

final voiceRepliesProvider = NotifierProvider<VoiceRepliesNotifier, bool>(VoiceRepliesNotifier.new);

final summaryHourProvider = NotifierProvider<SummaryHourNotifier, int>(SummaryHourNotifier.new);
