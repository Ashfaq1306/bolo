import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import 'device_bridge.dart';

final deviceBridgeProvider = Provider<DeviceBridge>((ref) => ChannelDeviceBridge());

/// The assistant's name. It is also the wake word, so it must be written in
/// English letters (the offline recogniser is an English model).
class AssistantNameNotifier extends Notifier<String> {
  static const _key = 'assistant.name';
  static const defaultName = 'Bolo';

  @override
  String build() => ref.watch(sharedPreferencesProvider).getString(_key) ?? defaultName;

  Future<void> set(String name) async {
    final clean = normalizeAssistantName(name);
    if (clean == null) return;
    state = clean;
    await ref.read(sharedPreferencesProvider).setString(_key, clean);
  }
}

final assistantNameProvider = NotifierProvider<AssistantNameNotifier, String>(AssistantNameNotifier.new);

/// "  bolo " -> "Bolo"; null if it isn't 2–20 English letters (spaces allowed).
String? normalizeAssistantName(String input) {
  final t = input.trim().replaceAll(RegExp(r'\s+'), ' ');
  if (!RegExp(r'^[A-Za-z][A-Za-z ]{1,19}$').hasMatch(t)) return null;
  return t.split(' ').map((w) => w.isEmpty ? w : w[0].toUpperCase() + w.substring(1).toLowerCase()).join(' ');
}

/// How the name is shown/spoken: the default "Bolo" is "বলো" in Bangla.
String assistantDisplayName(String name, String languageCode) =>
    languageCode == 'bn' && name.toLowerCase() == 'bolo' ? 'বলো' : name;

/// Hands-free mode: listen for the name even when the screen is off.
class HandsFreeNotifier extends Notifier<bool> {
  static const _key = 'assistant.handsFree';
  @override
  bool build() => ref.watch(sharedPreferencesProvider).getBool(_key) ?? false;

  Future<void> set(bool on) async {
    state = on;
    await ref.read(sharedPreferencesProvider).setBool(_key, on);
  }
}

final handsFreeProvider = NotifierProvider<HandsFreeNotifier, bool>(HandsFreeNotifier.new);

/// 0 = fewer false alarms, 1 = normal, 2 = hears you more easily.
class WakeSensitivityNotifier extends Notifier<int> {
  static const _key = 'assistant.sensitivity';
  @override
  int build() => ref.watch(sharedPreferencesProvider).getInt(_key) ?? 1;

  Future<void> set(int v) async {
    state = v.clamp(0, 2);
    await ref.read(sharedPreferencesProvider).setInt(_key, state);
  }
}

final wakeSensitivityProvider = NotifierProvider<WakeSensitivityNotifier, int>(WakeSensitivityNotifier.new);

/// Minimum recogniser confidence for the name (tested on the PC: 0.6 caught
/// 11/11 wake clips with 0/15 false alarms).
double wakeThreshold(int sensitivity) => switch (sensitivity) {
      0 => 0.75,
      2 => 0.5,
      _ => 0.6,
    };

/// Starts or stops the wake word service to match the settings.
/// Returns false if hands-free is on but the microphone isn't allowed.
Future<bool> syncWakeService(Ref ref) async {
  final device = ref.read(deviceBridgeProvider);
  if (!ref.read(handsFreeProvider)) {
    await device.wakeStop();
    return true;
  }
  if (!await device.hasPermission('microphone')) return false;
  final name = ref.read(assistantNameProvider);
  await device.wakeStart(name: name.toLowerCase(), label: name, threshold: wakeThreshold(ref.read(wakeSensitivityProvider)));
  return true;
}

final wakeSyncProvider = Provider<Future<bool> Function()>((ref) => () => syncWakeService(ref));

// ---------------------------------------------------------------------------
// Wake session: from "Bolo!" until the conversation is over.
// ---------------------------------------------------------------------------

class WakeSession {
  const WakeSession({this.active = false, this.locked = false});
  final bool active;

  /// Shown over the lock screen: hide personal data, ask to unlock for actions.
  final bool locked;
}

class WakeSessionNotifier extends Notifier<WakeSession> {
  Timer? _idle;

  @override
  WakeSession build() {
    ref.onDispose(() => _idle?.cancel());
    return const WakeSession();
  }

  void begin({required bool locked}) {
    state = WakeSession(active: true, locked: locked);
    touch();
  }

  /// Something happened (listening, a card, speech): keep the session alive.
  void touch({Duration idle = const Duration(seconds: 30)}) {
    if (!state.active) return;
    _idle?.cancel();
    _idle = Timer(idle, end);
  }

  /// Conversation over: leave the lock screen and listen for the name again.
  Future<void> end() async {
    _idle?.cancel();
    if (!state.active) return;
    state = const WakeSession();
    final device = ref.read(deviceBridgeProvider);
    await device.endWakeSession();
    await device.wakeResume();
  }
}

final wakeSessionProvider = NotifierProvider<WakeSessionNotifier, WakeSession>(WakeSessionNotifier.new);
