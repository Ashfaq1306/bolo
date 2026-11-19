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

  // Firestore's on-device cache is our offline database (docs/04 § 4.3).
  // It is on by default on Android; we set it explicitly so it's obvious.
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

  runApp(ProviderScope(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(prefs),
      reminderSchedulerProvider.overrideWithValue(scheduler),
    ],
    child: const BoloApp(),
  ));
}
