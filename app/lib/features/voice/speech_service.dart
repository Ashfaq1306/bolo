import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

/// Why a listening attempt failed. Each one gets its own message, so a phone
/// whose recognizer can't do Bangla isn't told "I didn't hear anything".
enum SpeechFailure {
  /// RECORD_AUDIO permission is missing (or was revoked).
  permissionDenied,

  /// No speech recognition service on the phone (or it refused to start).
  recognizerUnavailable,

  /// The recognizer doesn't support (or hasn't downloaded) the chosen language.
  languageUnavailable,

  /// The recognizer needs the internet and couldn't reach its server.
  network,

  /// The microphone gave no usable audio: busy (another app / Bolo's own
  /// wake word listener), or an audio error.
  micBusy,

  /// Listening started but there was silence.
  noSpeech,

  /// Sound was heard but nothing could be recognised.
  notRecognized,

  /// The recognizer's own server failed or rate-limited us.
  serviceError,

  /// Anything else.
  unknown,
}

/// Maps a speech_to_text error code (Android SpeechRecognizer.ERROR_*, as
/// named by the plugin) to a [SpeechFailure]. Pure, so it's unit-tested.
SpeechFailure classifySpeechError(String code) {
  final c = code.toLowerCase();
  if (c.contains('permission')) return SpeechFailure.permissionDenied;
  if (c.contains('language_not_supported') || c.contains('language_unavailable')) {
    return SpeechFailure.languageUnavailable;
  }
  if (c.contains('network')) return SpeechFailure.network; // error_network, error_network_timeout
  if (c.contains('audio') || c.contains('busy')) return SpeechFailure.micBusy;
  if (c.contains('speech_timeout')) return SpeechFailure.noSpeech;
  if (c.contains('no_match')) return SpeechFailure.notRecognized;
  if (c.contains('server') || c.contains('too_many_requests')) return SpeechFailure.serviceError;
  if (c.contains('recognizernotavailable') || c.contains('not available') || c.contains('unavailable')) {
    return SpeechFailure.recognizerUnavailable;
  }
  return SpeechFailure.unknown;
}

/// Picks the locale id the recognizer should actually be asked for.
///
/// The recognizer reports ids like "bn_BD" or "bn-IN". If the exact one we
/// want isn't listed but another variant of the same language is, use that
/// variant. If the list is empty (some recognizers don't report languages)
/// or the language isn't listed at all, keep the request unchanged and let
/// the recognizer answer: it may still work, and if not its error is shown.
String pickLocale(String wanted, List<String> available) {
  String norm(String s) => s.replaceAll('_', '-').toLowerCase();
  final w = norm(wanted);
  for (final a in available) {
    if (norm(a) == w) return a;
  }
  final lang = w.split('-').first;
  for (final a in available) {
    if (norm(a).split('-').first == lang) return a;
  }
  return wanted;
}

/// State of one listening session, consumed by the orb and home screen.
class SpeechState {
  const SpeechState({
    this.listening = false,
    this.available = true,
    this.text = '',
    this.isFinal = false,
    this.level = 0,
    this.error,
    this.failure,
  });

  final bool listening;
  final bool available;
  final String text;
  final bool isFinal;

  /// 0..1, normalised microphone loudness (drives the 3D orb).
  final double level;

  /// The raw error code (e.g. "error_no_match"). Never contains speech.
  final String? error;
  final SpeechFailure? failure;

  SpeechState copyWith({
    bool? listening,
    bool? available,
    String? text,
    bool? isFinal,
    double? level,
    String? error,
    SpeechFailure? failure,
    bool clearError = false,
  }) =>
      SpeechState(
        listening: listening ?? this.listening,
        available: available ?? this.available,
        text: text ?? this.text,
        isFinal: isFinal ?? this.isFinal,
        level: level ?? this.level,
        error: clearError ? null : (error ?? this.error),
        failure: clearError ? null : (failure ?? this.failure),
      );
}

/// What the Voice check screen shows. Only technical facts about the phone's
/// recognizer; no audio and no recognised text.
class SpeechDiagnostics {
  const SpeechDiagnostics({
    required this.initialised,
    required this.hasPermission,
    required this.locales,
    required this.lastError,
    required this.maxLevel,
  });

  final bool initialised;
  final bool hasPermission;
  final List<String> locales;
  final String? lastError;

  /// Loudest normalised mic level (0..1) in the last session: ~0 means the
  /// recognizer got silence (mic busy / muted / wrong audio route).
  final double maxLevel;
}

/// Wraps the platform speech recognizer behind an interface so that a cloud
/// STT provider can replace it later (docs/08). Bolo never records audio
/// itself; it only receives the recognizer's text.
abstract class SpeechService {
  Stream<SpeechState> get states;

  /// The failure from the last unsuccessful [init], if any.
  SpeechFailure? get initFailure;
  Future<bool> init();
  Future<List<String>> localeIds();
  Future<void> start({required String localeId});
  Future<void> stop();
  Future<void> cancel();
  Future<SpeechDiagnostics> diagnostics();
  void dispose();
}

class PlatformSpeechService implements SpeechService {
  final _stt = SpeechToText();
  final _controller = StreamController<SpeechState>.broadcast();
  SpeechState _state = const SpeechState();
  bool _ready = false;
  SpeechFailure? _initFailure;
  List<String>? _locales;
  String? _lastError;
  double _maxLevel = 0;

  void _emit(SpeechState s) {
    _state = s;
    if (!_controller.isClosed) _controller.add(s);
  }

  @override
  Stream<SpeechState> get states => _controller.stream;

  @override
  SpeechFailure? get initFailure => _initFailure;

  @override
  Future<bool> init() async {
    // Only success is cached: after a denied permission is granted in
    // Settings, the next tap must try again instead of failing forever.
    if (_ready) return true;
    try {
      final ok = await _stt.initialize(onError: _onError, onStatus: _onStatus, debugLogging: kDebugMode);
      _ready = ok;
      if (ok) {
        _initFailure = null;
      } else {
        _initFailure = await _stt.hasPermission ? SpeechFailure.recognizerUnavailable : SpeechFailure.permissionDenied;
      }
    } catch (e) {
      // e.g. PlatformException(recognizerNotAvailable, ...)
      _ready = false;
      _initFailure = classifySpeechError('$e');
      if (_initFailure == SpeechFailure.unknown) _initFailure = SpeechFailure.recognizerUnavailable;
      _lastError = 'init: ${e.runtimeType}';
    }
    _emit(_state.copyWith(available: _ready, failure: _initFailure));
    return _ready;
  }

  @override
  Future<List<String>> localeIds() async {
    if (!await init()) return const [];
    try {
      return _locales ??= (await _stt.locales()).map((l) => l.localeId).toList();
    } catch (_) {
      return const [];
    }
  }

  @override
  Future<void> start({required String localeId}) async {
    if (!await init()) {
      _emit(_state.copyWith(available: false, listening: false, error: 'unavailable', failure: _initFailure));
      return;
    }
    final locale = pickLocale(localeId, await localeIds());
    _maxLevel = 0;
    _emit(const SpeechState(listening: true));
    try {
      await _stt.listen(
        onResult: _onResult,
        onSoundLevelChange: _onLevel,
        listenOptions: SpeechListenOptions(
          localeId: locale,
          partialResults: true,
          cancelOnError: true,
          listenMode: ListenMode.dictation,
          // Hard cap per utterance (cost & runaway protection, docs/03 § F1).
          listenFor: const Duration(seconds: 30),
          pauseFor: const Duration(milliseconds: 2500),
        ),
      );
    } catch (e) {
      // ListenFailedException etc. Without this the orb stayed "listening".
      _lastError = 'listen: ${e.runtimeType}';
      debugPrint('Bolo speech: listen failed (${e.runtimeType})');
      _emit(_state.copyWith(listening: false, level: 0, error: _lastError, failure: SpeechFailure.recognizerUnavailable));
    }
  }

  void _onResult(SpeechRecognitionResult r) {
    _emit(_state.copyWith(text: r.recognizedWords, isFinal: r.finalResult, listening: !r.finalResult));
  }

  /// Android reports roughly -2..10 dB; map to 0..1 for the orb.
  void _onLevel(double level) {
    final normalised = ((level + 2) / 12).clamp(0.0, 1.0);
    if (normalised > _maxLevel) _maxLevel = normalised;
    _emit(_state.copyWith(level: normalised));
  }

  void _onStatus(String status) {
    if (status == 'done' || status == 'notListening') {
      _emit(_state.copyWith(listening: false, level: 0));
    }
  }

  void _onError(SpeechRecognitionError e) {
    _lastError = e.errorMsg;
    // The code only, never what was said.
    debugPrint('Bolo speech error: ${e.errorMsg} (peak level ${_maxLevel.toStringAsFixed(2)})');
    _emit(_state.copyWith(listening: false, level: 0, error: e.errorMsg, failure: classifySpeechError(e.errorMsg)));
  }

  @override
  Future<void> stop() => _stt.stop();

  @override
  Future<void> cancel() async {
    await _stt.cancel();
    _emit(const SpeechState());
  }

  @override
  Future<SpeechDiagnostics> diagnostics() async {
    final ok = await init();
    return SpeechDiagnostics(
      initialised: ok,
      hasPermission: await _stt.hasPermission,
      locales: ok ? await localeIds() : const [],
      lastError: _lastError,
      maxLevel: _maxLevel,
    );
  }

  @override
  void dispose() {
    _controller.close();
  }
}
