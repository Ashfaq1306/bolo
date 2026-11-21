import '../../core/dhaka_time.dart';
import '../../core/money.dart';
import '../records/models.dart';

/// What the user wants to do. Mirrors `intent` in functions/src/parse/schema.ts.
enum CommandIntent {
  createReminder('create_reminder'),
  createTask('create_task'),
  addExpense('add_expense'),
  addReceivable('add_receivable'),
  addPayable('add_payable'),
  settleLedger('settle_ledger'),
  querySummary('query_summary'),
  unknown('unknown');

  const CommandIntent(this.wire);
  final String wire;

  /// Financial actions ALWAYS need an explicit Confirm tap (docs/03 § F4).
  bool get isFinancial =>
      this == addExpense || this == addReceivable || this == addPayable || this == settleLedger;

  /// Intents that produce a record the user can save.
  bool get isSavable => this != querySummary && this != unknown;

  static CommandIntent fromWire(String? v) =>
      values.firstWhere((i) => i.wire == v, orElse: () => unknown);
}

/// Why the date/time might not be what the user meant.
enum Ambiguity {
  none('none'),
  amPm('am_pm'),
  relativeDay('relative_day'),
  relativeWeek('relative_week'),
  missingDate('missing_date');

  const Ambiguity(this.wire);
  final String wire;
  static Ambiguity fromWire(String? v) => values.firstWhere((a) => a.wire == v, orElse: () => none);
}

class DateTimeOption {
  const DateTimeOption({required this.date, this.time});
  final String date; // YYYY-MM-DD (Dhaka calendar date)
  final String? time; // HH:mm or null
}

/// An editable *proposal*. Nothing is saved until the user confirms it.
/// Built either from the AI response or empty for manual entry.
class ParsedCommand {
  const ParsedCommand({
    required this.intent,
    this.confidence = 1,
    this.title = '',
    this.amountPoisha,
    this.person = '',
    this.category = ExpenseCategory.other,
    this.date,
    this.time,
    this.ambiguity = Ambiguity.none,
    this.alternatives = const [],
    this.reminderOffsetMinutes,
    this.repeat = ReminderRepeat.none,
    this.clarification,
    this.transcript = '',
    this.source = RecordSource.manual,
    this.onDevice = false,
  });

  final CommandIntent intent;
  final double confidence;
  final String title;
  final int? amountPoisha;
  final String person;
  final ExpenseCategory category;
  final String? date;
  final String? time;
  final Ambiguity ambiguity;
  final List<DateTimeOption> alternatives;
  final int? reminderOffsetMinutes;
  final ReminderRepeat repeat;
  final String? clarification;
  final String transcript;
  final RecordSource source;

  /// True when the free on-device rules parser filled this card (the AI
  /// wasn't reachable). The card says so, so the user checks it carefully.
  final bool onDevice;

  /// The exact Dhaka instant this command refers to (null if no date).
  DateTime? get instant => DhakaTime.combine(date, time);

  bool get needsAttention => ambiguity != Ambiguity.none || confidence < 0.8;

  ParsedCommand copyWith({
    CommandIntent? intent,
    String? title,
    int? amountPoisha,
    bool clearAmount = false,
    String? person,
    ExpenseCategory? category,
    String? date,
    bool clearDate = false,
    String? time,
    bool clearTime = false,
    Ambiguity? ambiguity,
    int? reminderOffsetMinutes,
    ReminderRepeat? repeat,
    bool? onDevice,
  }) =>
      ParsedCommand(
        intent: intent ?? this.intent,
        confidence: confidence,
        title: title ?? this.title,
        amountPoisha: clearAmount ? null : (amountPoisha ?? this.amountPoisha),
        person: person ?? this.person,
        category: category ?? this.category,
        date: clearDate ? null : (date ?? this.date),
        time: clearTime ? null : (time ?? this.time),
        ambiguity: ambiguity ?? this.ambiguity,
        alternatives: alternatives,
        reminderOffsetMinutes: reminderOffsetMinutes ?? this.reminderOffsetMinutes,
        repeat: repeat ?? this.repeat,
        clarification: clarification,
        transcript: transcript,
        source: source,
        onDevice: onDevice ?? this.onDevice,
      );

  /// Builds a command from the `parseCommand` function response.
  /// Defensive: any malformed field becomes "unknown/empty" instead of crashing.
  factory ParsedCommand.fromServer(Map<String, dynamic> json, {required String transcript, required RecordSource source}) {
    final amount = json['amount'];
    final amountPoisha =
        amount is num && amount > 0 ? Money.poishaFromTaka(amount) : null;
    final date = json['date'] as String?;
    final time = json['time'] as String?;
    final alts = (json['alternatives'] as List?) ?? const [];
    return ParsedCommand(
      intent: CommandIntent.fromWire(json['intent'] as String?),
      confidence: (json['confidence'] as num?)?.toDouble().clamp(0, 1).toDouble() ?? 0,
      title: (json['title'] as String?)?.trim() ?? '',
      amountPoisha: amountPoisha != null && Money.isValid(amountPoisha) ? amountPoisha : null,
      person: (json['person'] as String?)?.trim() ?? '',
      category: ExpenseCategory.fromWire(json['category'] as String?),
      date: DhakaTime.parseIsoDate(date) != null ? date : null,
      time: DhakaTime.parseHm(time) != null ? time : null,
      ambiguity: Ambiguity.fromWire(json['ambiguity'] as String?),
      alternatives: [
        for (final a in alts)
          if (a is Map && DhakaTime.parseIsoDate(a['date'] as String?) != null)
            DateTimeOption(
              date: a['date'] as String,
              time: DhakaTime.parseHm(a['time'] as String?) != null ? a['time'] as String : null,
            ),
      ],
      reminderOffsetMinutes: (json['reminderOffsetMinutes'] as num?)?.toInt(),
      repeat: switch (json['repeat']) {
        'daily' => ReminderRepeat.daily,
        'weekly' => ReminderRepeat.weekly,
        _ => ReminderRepeat.none,
      },
      clarification: json['clarification'] as String?,
      transcript: transcript,
      source: source,
    );
  }
}

/// Problems that block saving. Shown on the confirmation card.
enum DraftProblem { missingTitle, missingAmount, missingPerson, missingDate, timeInPast, notSavable }

List<DraftProblem> validateDraft(ParsedCommand d, DateTime now) {
  final problems = <DraftProblem>[];
  switch (d.intent) {
    case CommandIntent.createReminder:
      if (d.title.trim().isEmpty) problems.add(DraftProblem.missingTitle);
      final at = d.instant;
      if (at == null) {
        problems.add(DraftProblem.missingDate);
      } else if (!at.isAfter(now)) {
        problems.add(DraftProblem.timeInPast);
      }
    case CommandIntent.createTask:
      if (d.title.trim().isEmpty) problems.add(DraftProblem.missingTitle);
    case CommandIntent.addExpense:
      if (d.amountPoisha == null || !Money.isValid(d.amountPoisha!)) {
        problems.add(DraftProblem.missingAmount);
      }
    case CommandIntent.addReceivable || CommandIntent.addPayable:
      if (d.amountPoisha == null || !Money.isValid(d.amountPoisha!)) {
        problems.add(DraftProblem.missingAmount);
      }
      if (d.person.trim().isEmpty) problems.add(DraftProblem.missingPerson);
    case CommandIntent.settleLedger:
      if (d.person.trim().isEmpty) problems.add(DraftProblem.missingPerson);
    case CommandIntent.querySummary || CommandIntent.unknown:
      problems.add(DraftProblem.notSavable);
  }
  return problems;
}
