import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Result of trying to place a call.
enum CallOutcome { called, dialer, invalid, failed }

/// Talks to the Android side (MainActivity.kt, "bolo/device" channel):
/// calls, music, apps, permissions, the wake word service, and the lock screen.
abstract class DeviceBridge {
  Future<bool> requestPermission(String name);
  Future<bool> hasPermission(String name);
  Future<CallOutcome> callNumber(String number);

  /// 'player' (a music app), 'youtube', or 'none'.
  Future<String> playMedia(String query);

  /// The opened app's name, or null if nothing matched.
  Future<String?> openApp(String name);

  Future<bool> isLocked();
  Future<bool> requestUnlock();
  Future<void> endWakeSession();

  /// Whether Bolo was opened by the wake word (and over the lock screen).
  Future<({bool wake, bool locked})> consumeWake();

  Future<void> wakeStart({required String name, required String label, required double threshold});
  Future<void> wakeStop();
  Future<void> wakePause();
  Future<void> wakeResume();
  Future<bool> wakeRunning();
  Future<bool> wakeKnowsName(String name);

  Future<bool> canAppearOverApps();
  Future<void> openAppearOverAppsSettings();
  Future<bool> canUseFullScreen();
  Future<void> openFullScreenSettings();

  /// Fires when the user says the wake word while Bolo is open
  /// (locked = it was shown over the lock screen).
  set onWake(void Function(bool locked)? handler);
}

class ChannelDeviceBridge implements DeviceBridge {
  ChannelDeviceBridge() {
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'onWake') {
        final locked = (call.arguments as Map?)?['locked'] == true;
        _onWake?.call(locked);
      }
    });
  }

  static const _channel = MethodChannel('bolo/device');
  void Function(bool locked)? _onWake;

  @override
  set onWake(void Function(bool locked)? handler) => _onWake = handler;

  Future<T?> _call<T>(String method, [Map<String, Object?>? args]) async {
    try {
      return await _channel.invokeMethod<T>(method, args);
    } on MissingPluginException {
      return null; // not Android (tests, other platforms)
    } on PlatformException catch (e) {
      debugPrint('bolo/device $method failed: ${e.message}');
      return null;
    }
  }

  @override
  Future<bool> requestPermission(String name) async => await _call<bool>('requestPermission', {'name': name}) ?? false;
  @override
  Future<bool> hasPermission(String name) async => await _call<bool>('hasPermission', {'name': name}) ?? false;

  @override
  Future<CallOutcome> callNumber(String number) async => switch (await _call<String>('callNumber', {'number': number})) {
        'called' => CallOutcome.called,
        'dialer' => CallOutcome.dialer,
        'invalid' => CallOutcome.invalid,
        _ => CallOutcome.failed,
      };

  @override
  Future<String> playMedia(String query) async => await _call<String>('playMedia', {'query': query}) ?? 'none';
  @override
  Future<String?> openApp(String name) => _call<String>('openApp', {'name': name});

  @override
  Future<bool> isLocked() async => await _call<bool>('isLocked') ?? false;
  @override
  Future<bool> requestUnlock() async => await _call<bool>('requestUnlock') ?? false;
  @override
  Future<void> endWakeSession() => _call<void>('endWakeSession');

  @override
  Future<({bool wake, bool locked})> consumeWake() async {
    final r = await _call<Map<Object?, Object?>>('consumeWake');
    return (wake: r?['wake'] == true, locked: r?['locked'] == true);
  }

  @override
  Future<void> wakeStart({required String name, required String label, required double threshold}) =>
      _call<bool>('wakeStart', {'name': name, 'label': label, 'threshold': threshold});
  @override
  Future<void> wakeStop() => _call<void>('wakeStop');
  @override
  Future<void> wakePause() => _call<void>('wakePause');
  @override
  Future<void> wakeResume() => _call<void>('wakeResume');
  @override
  Future<bool> wakeRunning() async => (await _call<Map<Object?, Object?>>('wakeStatus'))?['running'] == true;
  @override
  Future<bool> wakeKnowsName(String name) async => await _call<bool>('wakeKnowsName', {'name': name}) ?? false;

  @override
  Future<bool> canAppearOverApps() async => await _call<bool>('canAppearOverApps') ?? false;
  @override
  Future<void> openAppearOverAppsSettings() => _call<void>('openAppearOverAppsSettings');
  @override
  Future<bool> canUseFullScreen() async => await _call<bool>('canUseFullScreen') ?? false;
  @override
  Future<void> openFullScreenSettings() => _call<void>('openFullScreenSettings');
}

/// Does nothing; for tests.
class FakeDeviceBridge implements DeviceBridge {
  final calls = <String>[];
  bool locked = false;
  bool permissions = true;
  String? appToOpen;

  @override
  Future<bool> requestPermission(String name) async => permissions;
  @override
  Future<bool> hasPermission(String name) async => permissions;
  @override
  Future<CallOutcome> callNumber(String number) async {
    calls.add('call:$number');
    return permissions ? CallOutcome.called : CallOutcome.dialer;
  }

  @override
  Future<String> playMedia(String query) async {
    calls.add('play:$query');
    return 'player';
  }

  @override
  Future<String?> openApp(String name) async {
    calls.add('open:$name');
    return appToOpen;
  }

  @override
  Future<bool> isLocked() async => locked;
  @override
  Future<bool> requestUnlock() async => !locked;
  @override
  Future<void> endWakeSession() async => calls.add('endWake');
  @override
  Future<({bool wake, bool locked})> consumeWake() async => (wake: false, locked: false);
  @override
  Future<void> wakeStart({required String name, required String label, required double threshold}) async =>
      calls.add('wakeStart:$name');
  @override
  Future<void> wakeStop() async => calls.add('wakeStop');
  @override
  Future<void> wakePause() async => calls.add('wakePause');
  @override
  Future<void> wakeResume() async => calls.add('wakeResume');
  @override
  Future<bool> wakeRunning() async => false;
  @override
  Future<bool> wakeKnowsName(String name) async => name != 'tuntuni';
  @override
  Future<bool> canAppearOverApps() async => true;
  @override
  Future<void> openAppearOverAppsSettings() async {}
  @override
  Future<bool> canUseFullScreen() async => true;
  @override
  Future<void> openFullScreenSettings() async {}
  @override
  set onWake(void Function(bool locked)? handler) {}
}
