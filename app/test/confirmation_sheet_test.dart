import 'package:bolo_app/core/dhaka_time.dart';
import 'package:bolo_app/core/providers.dart';
import 'package:bolo_app/core/theme.dart';
import 'package:bolo_app/features/command/command_saver.dart';
import 'package:bolo_app/features/command/confirmation_sheet.dart';
import 'package:bolo_app/features/command/parsed_command.dart';
import 'package:bolo_app/features/records/models.dart';
import 'package:bolo_app/features/reminders/reminder_scheduler.dart';
import 'package:bolo_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'fakes/fake_records_repository.dart';

void main() {
  setUpAll(() async {
    DhakaTime.ensureInitialized();
    await initializeDateFormatting('bn');
  });

  final now = DhakaTime.at(2026, 11, 19, 20, 15);

  Future<FakeRecordsRepository> pump(WidgetTester tester, ParsedCommand proposal) async {
    final repo = FakeRecordsRepository();
    final scheduler = NoopReminderScheduler();
    await tester.pumpWidget(ProviderScope(
      overrides: [
        clockProvider.overrideWithValue(() => now),
        reminderSchedulerProvider.overrideWithValue(scheduler),
        commandSaverProvider.overrideWithValue(CommandSaver(repo: repo, scheduler: scheduler, now: () => now)),
        openLedgerProvider.overrideWith((ref) => Stream.value(const <LedgerEntry>[])),
      ],
      child: MaterialApp(
        theme: BoloTheme.dark(),
        locale: const Locale('bn'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: Scaffold(body: ConfirmationSheet(proposal: proposal)),
      ),
    ));
    await tester.pumpAndSettle();
    return repo;
  }

  testWidgets('expense card shows Confirm (not Save) and saves only on tap', (tester) async {
    final repo = await pump(
      tester,
      const ParsedCommand(intent: CommandIntent.addExpense, amountPoisha: 35000, category: ExpenseCategory.food, title: 'lunch'),
    );

    expect(find.text('নিশ্চিত করুন'), findsOneWidget); // Confirm
    expect(find.text('সেভ করুন'), findsNothing); // no plain Save for money
    expect(find.textContaining('টাকার হিসাব'), findsOneWidget); // financial note
    expect(repo.expenses, isEmpty);

    await tester.tap(find.text('নিশ্চিত করুন'));
    await tester.pumpAndSettle();
    expect(repo.expenses.values.single.amountPoisha, 35000);
  });

  testWidgets('Confirm is disabled until a valid amount is entered', (tester) async {
    await pump(tester, const ParsedCommand(intent: CommandIntent.addExpense));
    final button = tester.widget<FilledButton>(find.ancestor(of: find.text('নিশ্চিত করুন'), matching: find.byWidgetPredicate((w) => w is FilledButton)));
    expect(button.onPressed, isNull);
  });

  testWidgets('ambiguous time shows a clarification banner with choices', (tester) async {
    await pump(
      tester,
      const ParsedCommand(
        intent: CommandIntent.createReminder,
        title: 'meeting',
        date: '2026-11-20',
        time: '05:00',
        ambiguity: Ambiguity.amPm,
        alternatives: [DateTimeOption(date: '2026-11-20', time: '17:00')],
      ),
    );
    expect(find.textContaining('সকাল নাকি বিকাল'), findsOneWidget);
    expect(find.textContaining('বিকাল ৫:০০'), findsWidgets);
  });
}
