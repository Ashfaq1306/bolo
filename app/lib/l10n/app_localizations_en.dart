// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Bolo';

  @override
  String get greetingMorning => 'Good morning';

  @override
  String get greetingAfternoon => 'Good afternoon';

  @override
  String get greetingEvening => 'Good evening';

  @override
  String get greetingNight => 'Good night';

  @override
  String get tapToSpeak => 'Tap the orb and speak';

  @override
  String get orbLabel => 'Voice input. Double tap to start or stop listening.';

  @override
  String get listening => 'Listening…';

  @override
  String get thinking => 'Understanding…';

  @override
  String get typeInstead => 'Type instead';

  @override
  String get inputHint => 'e.g. Remind me to pay rent tomorrow at 10 am';

  @override
  String get send => 'Send';

  @override
  String get micUnavailable =>
      'Speech recognition isn\'t available. You can type instead.';

  @override
  String get heardNothing => 'I didn\'t hear anything. Try again?';

  @override
  String get offlineSaved =>
      'You\'re offline. Saved to Inbox, so you can process it later.';

  @override
  String get quotaExceeded =>
      'Today\'s voice-command limit is used up. You can still add things by hand.';

  @override
  String get notUnderstood => 'I didn\'t quite get that. Pick a type below.';

  @override
  String get serverError => 'Something went wrong. Please try again.';

  @override
  String get tooLong => 'That\'s too long (max 500 characters).';

  @override
  String get notSignedIn =>
      'Not connected yet. Check the internet and try again.';

  @override
  String get heard => 'Heard';

  @override
  String get navToday => 'Today';

  @override
  String get navTasks => 'Tasks';

  @override
  String get navMoney => 'Money';

  @override
  String get navSettings => 'Settings';

  @override
  String get intentReminder => 'Reminder';

  @override
  String get intentTask => 'Task';

  @override
  String get intentExpense => 'Expense';

  @override
  String get intentReceivable => 'They owe me';

  @override
  String get intentPayable => 'I owe them';

  @override
  String get intentSettle => 'Settled';

  @override
  String get intentSummary => 'Summary';

  @override
  String get intentUnknown => 'Choose a type';

  @override
  String get fieldTitle => 'What';

  @override
  String get fieldNote => 'Note';

  @override
  String get fieldAmount => 'Amount (৳)';

  @override
  String get fieldPerson => 'Person';

  @override
  String get fieldCategory => 'Category';

  @override
  String get fieldDate => 'Date';

  @override
  String get fieldTime => 'Time';

  @override
  String get fieldRemindBefore => 'Remind me one day before';

  @override
  String get fieldRepeat => 'Repeat';

  @override
  String get repeatNone => 'Once';

  @override
  String get repeatDaily => 'Daily';

  @override
  String get repeatWeekly => 'Weekly';

  @override
  String get noDate => 'No date';

  @override
  String get pickDate => 'Pick date';

  @override
  String get pickTime => 'Pick time';

  @override
  String get save => 'Save';

  @override
  String get confirm => 'Confirm';

  @override
  String get cancel => 'Cancel';

  @override
  String get undo => 'Undo';

  @override
  String get saved => 'Saved';

  @override
  String get delete => 'Delete';

  @override
  String get financialNote =>
      'Money record: nothing is saved until you tap Confirm.';

  @override
  String get largeAmountTitle => 'Large amount';

  @override
  String largeAmountBody(String amount) {
    return '$amount: are you sure this is correct?';
  }

  @override
  String get ambiguityAmPm => 'Morning or evening? Please check the time.';

  @override
  String get ambiguityRelativeDay => 'Which day did you mean? Please check.';

  @override
  String get ambiguityRelativeWeek => 'This week or next week? Please check.';

  @override
  String get ambiguityMissingDate => 'Please pick a date.';

  @override
  String get problemMissingTitle => 'Add what this is about';

  @override
  String get problemMissingAmount => 'Enter a valid amount';

  @override
  String get problemMissingPerson => 'Enter the person\'s name';

  @override
  String get problemMissingDate => 'Pick a date and time';

  @override
  String get problemTimeInPast => 'This time has already passed';

  @override
  String get pickEntryToSettle => 'Which entry was settled?';

  @override
  String get noOpenEntries => 'No open entries for this person.';

  @override
  String get catFood => 'Food';

  @override
  String get catTransport => 'Transport';

  @override
  String get catBills => 'Bills';

  @override
  String get catShopping => 'Shopping';

  @override
  String get catHealth => 'Health';

  @override
  String get catEducation => 'Education';

  @override
  String get catMobile => 'Mobile recharge';

  @override
  String get catFamily => 'Family';

  @override
  String get catOther => 'Other';

  @override
  String get todayTitle => 'Today';

  @override
  String get spentToday => 'Spent today';

  @override
  String get spentMonth => 'This month';

  @override
  String get toReceive => 'To receive';

  @override
  String get toPay => 'To pay';

  @override
  String get remindersToday => 'Today\'s reminders';

  @override
  String get dueTasks => 'Due & overdue';

  @override
  String get nothingToday =>
      'Nothing for today yet. Tap the orb and tell me something.';

  @override
  String get tasksTitle => 'Tasks';

  @override
  String get remindersTitle => 'Reminders';

  @override
  String get noTasks => 'No open tasks';

  @override
  String get noReminders => 'No upcoming reminders';

  @override
  String get addManually => 'Add';

  @override
  String get due => 'Due';

  @override
  String get overdue => 'Overdue';

  @override
  String get expensesTitle => 'This month\'s spending';

  @override
  String get ledgerTitle => 'Owed & owing';

  @override
  String get settle => 'Mark settled';

  @override
  String settleConfirm(String person, String amount) {
    return 'Mark $person · $amount as settled?';
  }

  @override
  String get noExpenses => 'No spending recorded this month';

  @override
  String get noLedger => 'No one owes anyone. Nice!';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get language => 'App language';

  @override
  String get speechLanguage => 'Speaking language';

  @override
  String get summaryTime => 'Daily summary notification';

  @override
  String get off => 'Off';

  @override
  String get account => 'Account';

  @override
  String get anonymousWarning =>
      'Your account isn\'t secured yet. If you uninstall the app, your data will be lost.';

  @override
  String get secureAccount => 'Secure with email';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password (min 6 characters)';

  @override
  String accountSecured(String email) {
    return 'Secured: $email';
  }

  @override
  String get privacy => 'Privacy';

  @override
  String get privacyBody =>
      'Bolo never records audio. The text of what you say is sent to an AI service only to understand it, and is not stored. Your records are visible only to you.';

  @override
  String get inbox => 'Inbox';

  @override
  String get inboxEmpty => 'Nothing waiting';

  @override
  String get process => 'Process';

  @override
  String get signInFailed =>
      'Couldn\'t connect. Turn on the internet and try again.';

  @override
  String get retry => 'Retry';

  @override
  String get summaryNotificationTitle => 'Today\'s summary';

  @override
  String summaryNotificationBody(String tasks, String spent) {
    return '$tasks tasks left · spent $spent';
  }

  @override
  String get notificationsOff =>
      'Turn on notifications so reminders can reach you.';

  @override
  String get enable => 'Enable';
}
