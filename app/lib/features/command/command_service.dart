import 'package:cloud_functions/cloud_functions.dart';

import '../../core/dhaka_time.dart';
import '../records/models.dart';
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
