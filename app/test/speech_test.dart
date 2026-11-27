import 'dart:async';

import 'package:bolo_app/core/providers.dart';
import 'package:bolo_app/features/assistant/assistant_settings.dart';
import 'package:bolo_app/features/assistant/device_bridge.dart';
import 'package:bolo_app/features/command/capture_controller.dart';
import 'package:bolo_app/features/voice/speech_service.dart';
import 'package:bolo_app/features/voice/voice_check_card.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A scripted recognizer: [start] replays [script] after recording the call.
class FakeSpeechService implements SpeechService {
  FakeSpeechService({this.initOk = true, this.initFailureValue, this.script = const []});

  final bool initOk;
  final SpeechFailure? initFailureValue;
  final List<SpeechState> script;
  final _controller = StreamController<SpeechState>.broadcast();
  final events = <String>[];

  @override
  Stream<SpeechState> get states => _controller.stream;
  @override
  SpeechFailure? get initFailure => initOk ? null : initFailureValue;
  @override
  Future<bool> init() async => initOk;
  @override
  Future<List<String>> localeIds() async => const ['bn_BD', 'en_US'];
  @override
  Future<void> start({required String localeId}) async {
    events.add('start:$localeId');
    _controller.add(const SpeechState(listening: true));
    for (final s in script) {
      await Future<void>.delayed(Duration.zero);
      _controller.add(s);
    }
  }

  @override
  Future<void> stop() async => events.add('stop');
  @override
  Future<void> cancel() async => events.add('cancel');
  @override
  Future<SpeechDiagnostics> diagnostics() async =>
      const SpeechDiagnostics(initialised: true, hasPermission: true, locales: [], lastError: null, maxLevel: 0);
  @override
  void dispose() => _controller.close();
}

Future<ProviderContainer> _container(FakeSpeechService speech, FakeDeviceBridge device) async {
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();
  final c = ProviderContainer(overrides: [
    sharedPreferencesProvider.overrideWithValue(prefs),
    speechServiceProvider.overrideWithValue(speech),
    deviceBridgeProvider.overrideWithValue(device),
  ]);
  addTearDown(c.dispose);
  return c;
}

Future<void> _settle() async {
  for (var i = 0; i < 10; i++) {
    await Future<void>.delayed(Duration.zero);
  }
}

void main() {
  group('classifySpeechError', () {
    test('maps every Android recognizer error to a distinct cause', () {
      expect(classifySpeechError('error_permission'), SpeechFailure.permissionDenied);
      expect(classifySpeechError('error_language_not_supported'), SpeechFailure.languageUnavailable);
      expect(classifySpeechError('error_language_unavailable'), SpeechFailure.languageUnavailable);
      expect(classifySpeechError('error_network'), SpeechFailure.network);
      expect(classifySpeechError('error_network_timeout'), SpeechFailure.network);
      expect(classifySpeechError('error_audio_error'), SpeechFailure.micBusy);
      expect(classifySpeechError('error_busy'), SpeechFailure.micBusy);
      expect(classifySpeechError('error_speech_timeout'), SpeechFailure.noSpeech);
      expect(classifySpeechError('error_no_match'), SpeechFailure.notRecognized);
      expect(classifySpeechError('error_server'), SpeechFailure.serviceError);
      expect(classifySpeechError('error_server_disconnected'), SpeechFailure.serviceError);
      expect(classifySpeechError('error_too_many_requests'), SpeechFailure.serviceError);
      expect(classifySpeechError('PlatformException(recognizerNotAvailable, ...)'), SpeechFailure.recognizerUnavailable);
      expect(classifySpeechError('error_client'), SpeechFailure.unknown);
      expect(classifySpeechError('error_unknown (99)'), SpeechFailure.unknown);
    });

    test('only silence maps to "heard nothing"', () {
      final heardNothing = SpeechFailure.values.where((f) => messageForSpeechFailure(f) == CaptureMessage.heardNothing);
      expect(heardNothing, [SpeechFailure.noSpeech]);
    });
  });

  group('pickLocale', () {
    test('matches regardless of _ or -', () {
      expect(pickLocale('bn-BD', ['en_US', 'bn_BD']), 'bn_BD');
    });
    test('falls back to another variant of the same language', () {
      expect(pickLocale('bn-BD', ['en_US', 'bn_IN']), 'bn_IN');
    });
    test('keeps the request when the language is not listed or the list is empty', () {
      expect(pickLocale('bn-BD', ['en_US']), 'bn-BD');
      expect(pickLocale('bn-BD', const []), 'bn-BD');
    });
  });

  group('CaptureController', () {
    test('a language error shows the language message, not "heard nothing"', () async {
      final speech = FakeSpeechService(script: const [
        SpeechState(error: 'error_language_not_supported', failure: SpeechFailure.languageUnavailable),
      ]);
      final c = await _container(speech, FakeDeviceBridge());
      await c.read(captureControllerProvider.notifier).toggleListening();
      await _settle();
      final s = c.read(captureControllerProvider);
      expect(s.phase, CapturePhase.idle);
      expect(s.message, CaptureMessage.speechLanguageUnavailable);
    });

    test('silence shows "heard nothing"', () async {
      final speech = FakeSpeechService(script: const [
        SpeechState(error: 'error_speech_timeout', failure: SpeechFailure.noSpeech),
      ]);
      final c = await _container(speech, FakeDeviceBridge());
      await c.read(captureControllerProvider.notifier).toggleListening();
      await _settle();
      expect(c.read(captureControllerProvider).message, CaptureMessage.heardNothing);
    });

    test('a failed init explains permission vs missing recognizer', () async {
      final denied = await _container(
          FakeSpeechService(initOk: false, initFailureValue: SpeechFailure.permissionDenied), FakeDeviceBridge());
      await denied.read(captureControllerProvider.notifier).toggleListening();
      expect(denied.read(captureControllerProvider).message, CaptureMessage.micPermission);

      final missing = await _container(
          FakeSpeechService(initOk: false, initFailureValue: SpeechFailure.recognizerUnavailable), FakeDeviceBridge());
      await missing.read(captureControllerProvider.notifier).toggleListening();
      expect(missing.read(captureControllerProvider).message, CaptureMessage.micUnavailable);
    });

    test('pauses the wake word listener before the recognizer starts', () async {
      final speech = FakeSpeechService();
      final device = FakeDeviceBridge()..wakeListening = true;
      final c = await _container(speech, device);
      await c.read(captureControllerProvider.notifier).toggleListening();
      expect(device.calls, contains('wakePause'));
      expect(device.wakeListening, isFalse);
      expect(speech.events, ['start:bn-BD']);
    });

    test('does not touch the wake word listener when it is off', () async {
      final device = FakeDeviceBridge();
      final c = await _container(FakeSpeechService(), device);
      await c.read(captureControllerProvider.notifier).toggleListening();
      expect(device.calls, isNot(contains('wakePause')));
    });
  });

  test('voice report has the facts needed to compare phones and no speech', () {
    final report = buildVoiceReport(
      env: {
        'manufacturer': 'samsung',
        'model': 'SM-A155F',
        'android': '14',
        'sdk': 34,
        'defaultRecognizer': 'com.samsung.android.bixby.agent/.asr.RecognitionService',
        'recognizers': ['com.samsung.android.bixby.agent', 'com.google.android.tts'],
        'recognitionAvailable': true,
        'onDeviceAvailable': false,
        'googleApp': null,
        'speechServices': '1.2.3',
        'playServices': '24.1',
        'micInputs': ['builtin_mic'],
        'wakeWordListening': false,
      },
      speech: const SpeechDiagnostics(
        initialised: true,
        hasPermission: true,
        locales: ['en_US', 'ko_KR'],
        lastError: 'error_language_not_supported',
        maxLevel: 0.4,
      ),
      speechLocale: 'bn-BD',
    );
    expect(report, contains('Default recognizer: com.samsung.android.bixby.agent'));
    expect(report, contains('(no Bangla)'));
    expect(report, contains('Google app: not installed'));
    expect(report, contains('Last error: error_language_not_supported'));
  });
}
