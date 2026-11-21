import 'package:cloud_functions/cloud_functions.dart';

import '../../core/dhaka_time.dart';
import '../records/models.dart';
import 'on_device_parser.dart';
import 'parsed_command.dart';

enum ParseFailure { offline, quotaExceeded, notSignedIn, tooLong, server }

class ParseException implements Exception {
  ParseException(this.failure, [this.detail]);
  final ParseFailure failure;
  final String? detail;
  @override
  String toString() => 'ParseException($failure, $detail)';
}

/// Sends text to the `parseCommand` Cloud Function. The API key for the AI
/// lives only on the server; the app sends the user's Firebase ID token.
abstract class CommandService {
  static const maxChars = 500;
  Future<ParsedCommand> parse(String text, {required RecordSource source, required String locale});
}

class CloudCommandService implements CommandService {
  CloudCommandService(this._functions);

  final FirebaseFunctions _functions;

  /// Exact-repeat cache: the same text on the same Dhaka day costs once.
  final _cache = <String, Map<String, dynamic>>{};

  @override
  Future<ParsedCommand> parse(String text, {required RecordSource source, required String locale}) async {
    final clean = text.trim().replaceAll(RegExp(r'\s+'), ' ');
    if (clean.isEmpty) throw ParseException(ParseFailure.server, 'empty');
    if (clean.length > CommandService.maxChars) throw ParseException(ParseFailure.tooLong);

    final key = '${DhakaTime.isoDate(DateTime.now())}|$locale|${clean.toLowerCase()}';
    final cached = _cache[key];
    if (cached != null) {
      return ParsedCommand.fromServer(cached, transcript: clean, source: source);
    }

    try {
      final callable = _functions.httpsCallable(
        'parseCommand',
        options: HttpsCallableOptions(timeout: const Duration(seconds: 20)),
      );
      final result = await callable.call<Map<String, dynamic>>({
        'text': clean,
        'locale': locale,
        'clientNow': DateTime.now().toUtc().toIso8601String(),
      });
      final data = Map<String, dynamic>.from(result.data);
      if (_cache.length > 50) _cache.clear();
      _cache[key] = data;
      return ParsedCommand.fromServer(data, transcript: clean, source: source);
    } on FirebaseFunctionsException catch (e) {
      throw ParseException(
        switch (e.code) {
          'resource-exhausted' => ParseFailure.quotaExceeded,
          'unauthenticated' => ParseFailure.notSignedIn,
          'unavailable' || 'deadline-exceeded' => ParseFailure.offline,
          'invalid-argument' => ParseFailure.tooLong,
          _ => ParseFailure.server,
        },
        e.message,
      );
    } catch (e) {
      // Socket errors etc. surface here when the phone is offline.
      throw ParseException(ParseFailure.offline, e.toString());
    }
  }
}

/// Tries [primary] (the AI). When the server fails — e.g. the function isn't
/// deployed yet, or the AI errored — it parses on the phone with
/// [parseOnDevice] so the user still gets a pre-filled card.
///
/// Offline, quota, sign-in and too-long errors are passed through unchanged:
/// those have their own handling (Inbox, messages) in the capture flow.
class FallbackCommandService implements CommandService {
  FallbackCommandService(this.primary, {DateTime Function()? clock}) : _clock = clock ?? DateTime.now;

  final CommandService primary;
  final DateTime Function() _clock;

  @override
  Future<ParsedCommand> parse(String text, {required RecordSource source, required String locale}) async {
    try {
      return await primary.parse(text, source: source, locale: locale);
    } on ParseException catch (e) {
      if (e.failure != ParseFailure.server || text.trim().isEmpty) rethrow;
      final clean = text.trim().replaceAll(RegExp(r'\s+'), ' ');
      return ParsedCommand.fromServer(parseOnDevice(clean, _clock()), transcript: clean, source: source)
          .copyWith(onDevice: true);
    }
  }
}
