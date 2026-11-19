import '../../core/bangla_digits.dart';
import '../../core/dhaka_time.dart';
import '../../core/labels.dart';
import '../../l10n/app_localizations.dart';
import 'parsed_command.dart';

/// The sentence Bolo says out loud when it shows a confirmation card.
/// If the AI had a clarifying question, Bolo asks that first.
String spokenSummary(ParsedCommand c, AppLocalizations l, String languageCode) {
  String amount() {
    final poisha = c.amountPoisha;
    if (poisha == null) return '';
    final taka = poisha % 100 == 0 ? '${poisha ~/ 100}' : (poisha / 100).toStringAsFixed(2);
    return localDigits(taka, languageCode);
  }

  final main = switch (c.intent) {
    CommandIntent.addExpense => l.speakExpense(amount(), l.category(c.category)),
    CommandIntent.createReminder => () {
        final at = c.instant;
        final when = at == null
            ? ''
            : '${DhakaTime.formatDate(at, languageCode)}, ${DhakaTime.formatTime(at, languageCode)}';
        return l.speakReminder(when, c.title);
      }(),
    CommandIntent.createTask => l.speakTask(c.title),
    CommandIntent.addReceivable => l.speakReceivable(c.person, amount()),
    CommandIntent.addPayable => l.speakPayable(c.person, amount()),
    CommandIntent.settleLedger => l.speakSettle(c.person),
    CommandIntent.querySummary || CommandIntent.unknown => l.speakUnknown,
  };
  final question = c.clarification;
  return question == null || question.isEmpty ? main : '$question $main';
}
