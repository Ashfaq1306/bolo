import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

/// Bolo talks back using the phone's own text-to-speech engine. Nothing is
/// sent to a server and no permission is needed. Bangla voice quality and
/// availability depend on the phone (Google TTS usually ships "bn-BD"/"bn-IN").
abstract class VoiceReplyService {
  /// True while Bolo is speaking (the face's mouth animates).
  ValueListenable<bool> get speaking;

  /// Whether a voice exists for this app language ('bn' or 'en').
  Future<bool> isAvailable(String languageCode);
  Future<void> speak(String text, {required String languageCode});
  Future<void> stop();
}

class DeviceVoiceReplyService implements VoiceReplyService {
  DeviceVoiceReplyService() {
    _tts.setStartHandler(() => _speaking.value = true);
    _tts.setCompletionHandler(() => _speaking.value = false);
    _tts.setCancelHandler(() => _speaking.value = false);
    _tts.setErrorHandler((_) => _speaking.value = false);
    // speak() completes when Bolo has finished talking, so the assistant can
    // say "Yes?" and only then start listening (it must not hear itself).
    _tts.awaitSpeakCompletion(true);
  }

  final _tts = FlutterTts();
  final _speaking = ValueNotifier(false);
  final _resolved = <String, String?>{};

  @override
  ValueListenable<bool> get speaking => _speaking;

  /// Finds the best installed voice locale for the app language.
  Future<String?> _locale(String languageCode) async {
    if (_resolved.containsKey(languageCode)) return _resolved[languageCode];
    final candidates = languageCode == 'bn' ? ['bn-BD', 'bn-IN', 'bn'] : ['en-US', 'en-GB', 'en-IN'];
    String? found;
    for (final c in candidates) {
      try {
        final ok = await _tts.isLanguageAvailable(c);
        if (ok == true || ok == 1) {
          found = c;
          break;
        }
      } catch (e) {
        debugPrint('TTS check failed for $c: $e');
      }
    }
    _resolved[languageCode] = found;
    return found;
  }

  @override
  Future<bool> isAvailable(String languageCode) async => await _locale(languageCode) != null;

  @override
  Future<void> speak(String text, {required String languageCode}) async {
    final locale = await _locale(languageCode);
    // Never read Bangla text with an English voice: it sounds like nonsense.
    if (locale == null || text.trim().isEmpty) return;
    try {
      await _tts.stop();
      await _tts.setLanguage(locale);
      await _tts.setSpeechRate(0.5);
      await _tts.setPitch(1.18); // a little higher: a cute robot voice
      await _tts.speak(text);
    } catch (e) {
      debugPrint('TTS failed: $e');
      _speaking.value = false;
    }
  }

  @override
  Future<void> stop() async {
    await _tts.stop();
    _speaking.value = false;
  }
}

/// Silent implementation for tests.
class SilentVoiceReplyService implements VoiceReplyService {
  final spoken = <String>[];
  final _speaking = ValueNotifier(false);
  @override
  ValueListenable<bool> get speaking => _speaking;
  @override
  Future<bool> isAvailable(String languageCode) async => true;
  @override
  Future<void> speak(String text, {required String languageCode}) async => spoken.add(text);
  @override
  Future<void> stop() async {}
}
