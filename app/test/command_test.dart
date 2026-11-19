import 'package:bolo_app/core/dhaka_time.dart';
import 'package:bolo_app/features/command/command_saver.dart';
import 'package:bolo_app/features/command/parsed_command.dart';
import 'package:bolo_app/features/records/models.dart';
import 'package:bolo_app/features/reminders/reminder_scheduler.dart';
import 'package:bolo_app/features/summary/daily_summary.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fakes/fake_records_repository.dart';

void main() {
  setUpAll(DhakaTime.ensureInitialized);

  // "Now" = Thursday 2026-11-19, 20:15 in Dhaka.
  final now = DhakaTime.at(2026, 11, 19, 20, 15);

  group('ParsedCommand.fromServer', () {
    test('parses a payable with an AM/PM ambiguity', () {
      final c = ParsedCommand.fromServer({
        'intent': 'add_payable',
        'confidence': 0.86,
        'title': 'Rahim ke taka deoa',
        'amount': 500,
        'person': 'Rahim',
        'date': '2026-11-20',
        'time': '05:00',
        'ambiguity': 'am_pm',
        'alternatives': [
          {'date': '2026-11-20', 'time': '17:00'},
        ],
      }, transcript: 'kal 5 tay Rahim ke 500 taka dite hobe', source: RecordSource.voice);

      expect(c.intent, CommandIntent.addPayable);
      expect(c.intent.isFinancial, isTrue);
      expect(c.amountPoisha, 50000);
      expect(c.ambiguity, Ambiguity.amPm);
      expect(c.alternatives.single.time, '17:00');
      expect(c.needsAttention, isTrue);
    });

    test('malformed fields become safe empty values', () {
      final c = ParsedCommand.fromServer({
        'intent': 'drop_database',
        'amount': -40,
        'date': '2026-13-45',
        'time': 'noon',
        'confidence': 7,
      }, transcript: 'x', source: RecordSource.text);
      expect(c.intent, CommandIntent.unknown);
      expect(c.amountPoisha, isNull);
      expect(c.date, isNull);
      expect(c.time, isNull);
      expect(c.confidence, 1.0);
    });
  });

  group('validateDraft', () {
    test('reminder in the past is rejected', () {
      const d = ParsedCommand(intent: CommandIntent.createReminder, title: 'x', date: '2026-11-19', time: '09:00');
      expect(validateDraft(d, now), contains(DraftProblem.timeInPast));
    });

    test('ledger entries need person and amount', () {
      const d = ParsedCommand(intent: CommandIntent.addReceivable);
      expect(validateDraft(d, now), containsAll([DraftProblem.missingAmount, DraftProblem.missingPerson]));
    });
  });

  group('CommandSaver', () {
    late FakeRecordsRepository repo;
    late NoopReminderScheduler scheduler;
    late CommandSaver saver;

    setUp(() {
      repo = FakeRecordsRepository();
      scheduler = NoopReminderScheduler();
      saver = CommandSaver(repo: repo, scheduler: scheduler, now: () => now);
    });

    test('REFUSES to save a financial record without explicit confirmation', () async {
      const expense = ParsedCommand(intent: CommandIntent.addExpense, amountPoisha: 35000);
      await expectLater(saver.save(expense, userConfirmed: false), throwsA(isA<FinancialConfirmationRequired>()));
      expect(repo.expenses, isEmpty);
    });

    test('saves a confirmed expense as integer poisha', () async {
      const expense = ParsedCommand(intent: CommandIntent.addExpense, amountPoisha: 35000, category: ExpenseCategory.food, title: 'lunch');
      await saver.save(expense, userConfirmed: true);
      expect(repo.expenses.values.single.amountPoisha, 35000);
      expect(repo.expenses.values.single.category, ExpenseCategory.food);
    });

    test('reminder is saved in Dhaka time and scheduled', () async {
      const d = ParsedCommand(intent: CommandIntent.createReminder, title: 'rent', date: '2026-11-20', time: '10:00');
      final result = await saver.save(d, userConfirmed: true);
      final r = repo.reminders[result.id]!;
      expect(r.remindAt.toUtc(), DateTime.utc(2026, 11, 20, 4, 0));
      expect(scheduler.scheduled, contains(r.notificationId));
    });

    test('undo removes a reminder and its notification', () async {
      const d = ParsedCommand(intent: CommandIntent.createReminder, title: 'rent', date: '2026-11-20', time: '10:00');
      final result = await saver.save(d, userConfirmed: true);
      await saver.undo(result);
      expect(repo.reminders, isEmpty);
      expect(scheduler.scheduled, isEmpty);
    });

    test('task deadline with remind-one-day-before', () async {
      const d = ParsedCommand(intent: CommandIntent.createTask, title: 'CSE215', date: '2026-11-25', reminderOffsetMinutes: 1440);
      final result = await saver.save(d, userConfirmed: true);
      final t = repo.tasks[result.id]!;
      expect(DhakaTime.isoDate(t.dueAt!), '2026-11-25');
      expect(DhakaTime.isoDate(t.remindAt!), '2026-11-24');
    });

    test('settling requires the user to pick an entry (never guess)', () async {
      const d = ParsedCommand(intent: CommandIntent.settleLedger, person: 'Karim');
      await expectLater(saver.save(d, userConfirmed: true), throwsA(isA<DraftInvalid>()));
    });

    test('receivable direction is preserved', () async {
      const d = ParsedCommand(intent: CommandIntent.addReceivable, person: 'Karim', amountPoisha: 200000);
      await saver.save(d, userConfirmed: true);
      expect(repo.ledger.values.single.direction, LedgerDirection.receivable);
    });
  });

  test('DailySummary totals', () {
    final s = DailySummary.compute(
      now: now,
      reminders: [Reminder(id: 'r', title: 'x', remindAt: DhakaTime.at(2026, 11, 19, 22))],
      tasks: [TaskItem(id: 't', title: 'y', dueAt: DhakaTime.at(2026, 11, 18))],
      monthExpenses: [
        Expense(id: 'a', amountPoisha: 35000, spentAt: DhakaTime.at(2026, 11, 19, 13)),
        Expense(id: 'b', amountPoisha: 10000, spentAt: DhakaTime.at(2026, 11, 2, 13)),
      ],
      openLedger: const [
        LedgerEntry(id: 'l1', direction: LedgerDirection.receivable, person: 'Karim', amountPoisha: 200000),
        LedgerEntry(id: 'l2', direction: LedgerDirection.payable, person: 'Rahim', amountPoisha: 50000),
      ],
    );
    expect(s.spentTodayPoisha, 35000);
    expect(s.spentMonthPoisha, 45000);
    expect(s.toReceivePoisha, 200000);
    expect(s.toPayPoisha, 50000);
    expect(s.remindersToday, hasLength(1));
    expect(s.tasksDueOrOverdue, hasLength(1));
  });
}
