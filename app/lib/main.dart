import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'core/dhaka_time.dart';
import 'core/providers.dart';
import 'data/bolo_database.dart';
import 'data/device_identity.dart';
import 'features/inbox/inbox_store.dart';
import 'features/migration/guest_migration.dart';
import 'features/reminders/reminder_scheduler.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Local development against the Firebase Emulator Suite (free, no real data):
  //   flutter run --dart-define=USE_EMULATORS=true
  // 10.0.2.2 is how the Android emulator reaches your PC's localhost.
  if (const bool.fromEnvironment('USE_EMULATORS')) {
    const host = String.fromEnvironment('EMULATOR_HOST', defaultValue: '10.0.2.2');
    await FirebaseAuth.instance.useAuthEmulator(host, 9099);
    FirebaseFirestore.instance.useFirestoreEmulator(host, 8085);
    FirebaseFunctions.instanceFor(region: 'asia-south1').useFunctionsEmulator(host, 5001);
  }

  // The local Drift database is the source of truth (ADR-10). Firestore's
  // cache still matters: the guest migration reads the old data from it, and
  // accounts registered before Phase 2 still use Firestore.
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );

  DhakaTime.ensureInitialized();
  await initializeDateFormatting('bn');
  await initializeDateFormatting('en');

  final prefs = await SharedPreferences.getInstance();
  final scheduler = LocalReminderScheduler();
  await scheduler.init();

  // Open the local database. Works offline from the very first launch.
  final db = BoloDatabase.open();
  final DeviceIdentity identity;
  try {
    identity = await DeviceIdentity.load(db);
  } catch (e) {
    // Never wipe the file: show a message and keep the data for recovery.
    debugPrint('Database open failed: ${e.runtimeType}');
    runApp(DatabaseErrorApp(locale: Locale(prefs.getString(LocaleNotifier.prefsKey) ?? 'bn')));
    return;
  }

  // The signed-in Firebase user is restored from the phone (no network).
  final initialUser = await FirebaseAuth.instance
      .authStateChanges()
      .first
      .timeout(const Duration(seconds: 5), onTimeout: () => FirebaseAuth.instance.currentUser);

  // First launch of this version: remember which anonymous uid owned the old
  // Firestore guest data, before any new session could replace it.
  await GuestMigration.rememberLegacyUser(
    db,
    anonymousUid: initialUser != null && initialUser.isAnonymous ? initialUser.uid : null,
  );
  await InboxStore(db, ownerScope: identity.guestScope).importLegacy(prefs);

  runApp(ProviderScope(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(prefs),
      reminderSchedulerProvider.overrideWithValue(scheduler),
      databaseProvider.overrideWithValue(db),
      deviceIdentityProvider.overrideWithValue(identity),
      initialUserProvider.overrideWithValue(initialUser),
    ],
    child: const BoloApp(),
  ));
}
