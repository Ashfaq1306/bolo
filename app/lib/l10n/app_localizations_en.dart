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
  String tapToSpeak(String name) {
    return 'Tap $name and speak';
  }

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
  String nothingToday(String name) {
    return 'Nothing for today yet. Tap $name and tell me something.';
  }

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

  @override
  String speakExpense(String amount, String category) {
    return '$amount taka for $category. Shall I save it?';
  }

  @override
  String speakReminder(String when, String title) {
    return 'I\'ll remind you $when: $title. Okay?';
  }

  @override
  String speakTask(String title) {
    return 'New task: $title. Shall I save it?';
  }

  @override
  String speakReceivable(String person, String amount) {
    return '$person will give you $amount taka. Please confirm.';
  }

  @override
  String speakPayable(String person, String amount) {
    return 'You will give $person $amount taka. Please confirm.';
  }

  @override
  String speakSettle(String person) {
    return 'Which of $person\'s entries was settled?';
  }

  @override
  String get speakUnknown =>
      'Sorry, I didn\'t understand. Please choose a type.';

  @override
  String get speakSaved => 'Done, saved!';

  @override
  String get voiceReplies => 'Voice replies (Bolo talks back)';

  @override
  String get voiceUnavailable =>
      'No voice for this language is installed on this phone. Install it from Settings → Text-to-speech.';

  @override
  String get pickContact => 'Choose from contacts';

  @override
  String get addToCalendar => 'Also add to phone calendar';

  @override
  String get scanReceipt => 'Scan receipt';

  @override
  String get scanNoText =>
      'Couldn\'t read any text. Try again with better light, or enter it by hand.';

  @override
  String get scanFailed =>
      'Scanning didn\'t work on this phone. Please enter it by hand.';

  @override
  String get scanHint =>
      'Read on your phone; the photo is deleted right away. Please check the amount.';

  @override
  String get devicePowers => 'Device features';

  @override
  String get devicePowersBody =>
      'Bolo only uses what you ask for: contacts are searched on the phone when you ask it to call someone (names are never uploaded), calls need your confirmation, music and apps open in their own apps, receipts are read on the phone and the photo is deleted. The only background access is the optional \"Bolo\" listener, which runs on the phone and shows a notification while on.';

  @override
  String get updateTitle => 'Update available';

  @override
  String updateBody(String version) {
    return 'Bolo $version is ready. Your data stays safe in your account.';
  }

  @override
  String get updateMandatoryBody =>
      'This update is required to keep using Bolo.';

  @override
  String get updateNow => 'Update';

  @override
  String get updateLater => 'Later';

  @override
  String get updateHowTo =>
      'The new version downloads in your browser. Open it and tap Install (allow \"Install unknown apps\" if Android asks).';

  @override
  String get updateOpenFailed => 'Couldn\'t open the download link.';

  @override
  String get checkUpdates => 'Check for updates';

  @override
  String get upToDate => 'You have the latest version.';

  @override
  String appVersion(String version) {
    return 'Version $version';
  }

  @override
  String get offlineParserNote =>
      'Understood on your phone (AI not connected). Please check the details.';

  @override
  String get nothingPlannedToday => 'No reminders or tasks today.';

  @override
  String get exactAlarmTitle => 'Ring reminders on time?';

  @override
  String get exactAlarmBody =>
      'Android may delay reminders by a few minutes. On the next screen, turn on \"Allow setting alarms and reminders\" for Bolo so they ring exactly on time.';

  @override
  String get exactAlarmOpen => 'Turn on';

  @override
  String get intentCall => 'Call';

  @override
  String get intentPlay => 'Play music';

  @override
  String get intentOpen => 'Open app';

  @override
  String speakCall(String name) {
    return 'Calling $name.';
  }

  @override
  String speakPlay(String query) {
    return 'Playing $query.';
  }

  @override
  String speakOpen(String app) {
    return 'Opening $app.';
  }

  @override
  String get wakeGreeting => 'Yes? What can I do for you?';

  @override
  String get needUnlock => 'Please unlock your phone first.';

  @override
  String appNotFound(String app) {
    return 'I couldn\'t find an app called \"$app\".';
  }

  @override
  String get playFailed =>
      'I couldn\'t find a music app or YouTube on this phone.';

  @override
  String get callWho => 'Who should I call?';

  @override
  String get callButton => 'Call';

  @override
  String callNoMatch(String name) {
    return 'I couldn\'t find \"$name\" in your contacts.';
  }

  @override
  String get callTypeNumber => 'Or type a number';

  @override
  String get contactsPermissionNeeded =>
      'To find people by name, allow Bolo to read your contacts. Or pick one below.';

  @override
  String callConfirmQuestion(String name) {
    return 'Shall I call $name?';
  }

  @override
  String get callDialerNote =>
      'Calling isn\'t allowed, so the dialer opened with the number.';

  @override
  String get lockedHint =>
      'Your phone is locked: Bolo is only listening. Your data stays hidden until you unlock.';

  @override
  String get assistantTitle => 'Assistant';

  @override
  String get assistantName => 'Assistant\'s name';

  @override
  String get assistantNameHint =>
      'Call it by this name. English letters, e.g. Bolo, Robi, Mina.';

  @override
  String get assistantNameInvalid => 'Use 2–20 English letters.';

  @override
  String get assistantNameUnknown =>
      'The offline listener doesn\'t know this word, so it couldn\'t hear it. Try another name (e.g. Bolo, Robi, Mina, Jarvis).';

  @override
  String handsFree(String name) {
    return 'Answer when I say \"$name\"';
  }

  @override
  String handsFreeBody(String name) {
    return 'Say \"$name\" even when the screen is off or locked. Listening happens on this phone; nothing is recorded or sent.';
  }

  @override
  String get sensitivity => 'How easily it hears its name';

  @override
  String get sensLow => 'Less';

  @override
  String get sensNormal => 'Normal';

  @override
  String get sensHigh => 'More';

  @override
  String get allowLockScreen => 'Appear on the lock screen';

  @override
  String get allowOverApps => 'Appear over other apps';

  @override
  String get allowButton => 'Allow';

  @override
  String get allowedLabel => 'On';

  @override
  String get handsFreeLimits =>
      'Works while the phone is on (screen off or locked is fine), not when it is switched off. Uses a little more battery and shows a permanent notification. After restarting the phone, open Bolo once.';

  @override
  String assistantCanDo(String name) {
    return 'Try: \"$name, call Ammu\", \"play Arijit Singh\", \"open YouTube\", \"remind me in 10 minutes to drink water\".';
  }
}
