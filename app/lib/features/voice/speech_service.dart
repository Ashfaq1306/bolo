import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

/// State of one listening session, consumed by the orb and home screen.
class SpeechState {
  const SpeechState({
    this.listening = false,
    this.available = true,
    this.text = '',
    this.isFinal = false,
    this.level = 0,
    this.error,
  });

  final bool listening;
  final bool available;
  final String text;
  final bool isFinal;

  /// 0..1, normalised microphone loudness (drives the 3D orb).
  final double level;
  final String? error;

  SpeechState copyWith({bool? listening, bool? available, String? text, bool? isFinal, double? level, String? error, bool clearError = false}) =>
      SpeechState(
        listening: listening ?? this.listening,
        available: available ?? this.available,
        text: text ?? this.text,
        isFinal: isFinal ?? this.isFinal,
        level: level ?? this.level,
        error: clearError ? null : (error ?? this.error),
      );
}

/// Wraps the platform speech recognizer behind an interface so that a cloud
/// STT provider can replace it later (docs/08). Bolo never records audio
/// itself; it only receives the recognizer's text.
abstract class SpeechService {
  Stream<SpeechState> get states;
  Future<bool> init();
  Future<List<String>> localeIds();
  Future<void> start({required String localeId});
  Future<void> stop();
  Future<void> cancel();
  void dispose();
}

class PlatformSpeechService implements SpeechService {
  final _stt = SpeechToText();
  final _controller = StreamController<SpeechState>.broadcast();
  SpeechState _state = const SpeechState();
  bool _initialised = false;

  void _emit(SpeechState s) {
    _state = s;
    _controller.add(s);
  }

  @override
  Stream<SpeechState> get states => _controller.stream;

  @override
  Future<bool> init() async {
    if (_initialised) return _state.available;
    try {
      final ok = await _stt.initialize(
        onError: _onError,
        onStatus: _onStatus,
        debugLogging: kDebugMode,
      );
      _initialised = true;
      _emit(_state.copyWith(available: ok));
      return ok;
    } catch (e) {
      _emit(_state.copyWith(available: false, error: 'init: $e'));
      return false;
    }
  }

  @override
  Future<List<String>> localeIds() async {
    if (!await init()) return const [];
    final locales = await _stt.locales();
    return locales.map((l) => l.localeId).toList();
  }

  @override
  Future<void> start({required String localeId}) async {
    if (!await init()) {
      _emit(_state.copyWith(available: false, error: 'unavailable'));
      return;
    }
    _emit(const SpeechState(listening: true));
    await _stt.listen(
      onResult: _onResult,
      onSoundLevelChange: _onLevel,
      listenOptions: SpeechListenOptions(
        localeId: localeId,
        partialResults: true,
        cancelOnError: true,
        listenMode: ListenMode.dictation,
        // Hard cap per utterance (cost & runaway protection, docs/03 § F1).
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(milliseconds: 2500),
      ),
    );
  }

  void _onResult(SpeechRecognitionResult r) {
    _emit(_state.copyWith(text: r.recognizedWords, isFinal: r.finalResult, listening: !r.finalResult));
  }

  /// Android reports roughly -2..10 dB; map to 0..1 for the orb.
  void _onLevel(double level) {
    final normalised = ((level + 2) / 12).clamp(0.0, 1.0);
    _emit(_state.copyWith(level: normalised));
  }

  void _onStatus(String status) {
    if (status == 'done' || status == 'notListening') {
      _emit(_state.copyWith(listening: false, level: 0));
    }
  }

  void _onError(SpeechRecognitionError e) {
    _emit(_state.copyWith(listening: false, level: 0, error: e.errorMsg));
  }

  @override
  Future<void> stop() => _stt.stop();

  @override
  Future<void> cancel() async {
    await _stt.cancel();
    _emit(const SpeechState());
  }

  @override
  void dispose() {
    _controller.close();
  }
}
