import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_bn.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('bn'),
    Locale('en'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Bolo'**
  String get appTitle;

  /// No description provided for @greetingMorning.
  ///
  /// In en, this message translates to:
  /// **'Good morning'**
  String get greetingMorning;

  /// No description provided for @greetingAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good afternoon'**
  String get greetingAfternoon;

  /// No description provided for @greetingEvening.
  ///
  /// In en, this message translates to:
  /// **'Good evening'**
  String get greetingEvening;

  /// No description provided for @greetingNight.
  ///
  /// In en, this message translates to:
  /// **'Good night'**
  String get greetingNight;

  /// No description provided for @tapToSpeak.
  ///
  /// In en, this message translates to:
  /// **'Tap the orb and speak'**
  String get tapToSpeak;

  /// No description provided for @orbLabel.
  ///
  /// In en, this message translates to:
  /// **'Voice input. Double tap to start or stop listening.'**
  String get orbLabel;

  /// No description provided for @listening.
  ///
  /// In en, this message translates to:
  /// **'Listening…'**
  String get listening;

  /// No description provided for @thinking.
  ///
  /// In en, this message translates to:
  /// **'Understanding…'**
  String get thinking;

  /// No description provided for @typeInstead.
  ///
  /// In en, this message translates to:
  /// **'Type instead'**
  String get typeInstead;

  /// No description provided for @inputHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Remind me to pay rent tomorrow at 10 am'**
  String get inputHint;

  /// No description provided for @send.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get send;

  /// No description provided for @micUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Speech recognition isn\'t available. You can type instead.'**
  String get micUnavailable;

  /// No description provided for @heardNothing.
  ///
  /// In en, this message translates to:
  /// **'I didn\'t hear anything. Try again?'**
  String get heardNothing;

  /// No description provided for @offlineSaved.
  ///
  /// In en, this message translates to:
  /// **'You\'re offline. Saved to Inbox, so you can process it later.'**
  String get offlineSaved;

  /// No description provided for @quotaExceeded.
  ///
  /// In en, this message translates to:
  /// **'Today\'s voice-command limit is used up. You can still add things by hand.'**
  String get quotaExceeded;

  /// No description provided for @notUnderstood.
  ///
  /// In en, this message translates to:
  /// **'I didn\'t quite get that. Pick a type below.'**
  String get notUnderstood;

  /// No description provided for @serverError.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get serverError;

  /// No description provided for @tooLong.
  ///
  /// In en, this message translates to:
  /// **'That\'s too long (max 500 characters).'**
  String get tooLong;

  /// No description provided for @notSignedIn.
  ///
  /// In en, this message translates to:
  /// **'Not connected yet. Check the internet and try again.'**
  String get notSignedIn;

  /// No description provided for @heard.
  ///
  /// In en, this message translates to:
  /// **'Heard'**
  String get heard;

  /// No description provided for @navToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get navToday;

  /// No description provided for @navTasks.
  ///
  /// In en, this message translates to:
  /// **'Tasks'**
  String get navTasks;

  /// No description provided for @navMoney.
  ///
  /// In en, this message translates to:
  /// **'Money'**
  String get navMoney;

  /// No description provided for @navSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// No description provided for @intentReminder.
  ///
  /// In en, this message translates to:
  /// **'Reminder'**
  String get intentReminder;

  /// No description provided for @intentTask.
  ///
  /// In en, this message translates to:
  /// **'Task'**
  String get intentTask;

  /// No description provided for @intentExpense.
  ///
  /// In en, this message translates to:
  /// **'Expense'**
  String get intentExpense;

  /// No description provided for @intentReceivable.
  ///
  /// In en, this message translates to:
  /// **'They owe me'**
  String get intentReceivable;

  /// No description provided for @intentPayable.
  ///
  /// In en, this message translates to:
  /// **'I owe them'**
  String get intentPayable;

  /// No description provided for @intentSettle.
  ///
  /// In en, this message translates to:
  /// **'Settled'**
  String get intentSettle;

  /// No description provided for @intentSummary.
  ///
  /// In en, this message translates to:
  /// **'Summary'**
  String get intentSummary;

  /// No description provided for @intentUnknown.
  ///
  /// In en, this message translates to:
  /// **'Choose a type'**
  String get intentUnknown;

  /// No description provided for @fieldTitle.
  ///
  /// In en, this message translates to:
  /// **'What'**
  String get fieldTitle;

  /// No description provided for @fieldNote.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get fieldNote;

  /// No description provided for @fieldAmount.
  ///
  /// In en, this message translates to:
  /// **'Amount (৳)'**
  String get fieldAmount;

  /// No description provided for @fieldPerson.
  ///
  /// In en, this message translates to:
  /// **'Person'**
  String get fieldPerson;

  /// No description provided for @fieldCategory.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get fieldCategory;

  /// No description provided for @fieldDate.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get fieldDate;

  /// No description provided for @fieldTime.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get fieldTime;

  /// No description provided for @fieldRemindBefore.
  ///
  /// In en, this message translates to:
  /// **'Remind me one day before'**
  String get fieldRemindBefore;

  /// No description provided for @fieldRepeat.
  ///
  /// In en, this message translates to:
  /// **'Repeat'**
  String get fieldRepeat;

  /// No description provided for @repeatNone.
  ///
  /// In en, this message translates to:
  /// **'Once'**
  String get repeatNone;

  /// No description provided for @repeatDaily.
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get repeatDaily;

  /// No description provided for @repeatWeekly.
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get repeatWeekly;

  /// No description provided for @noDate.
  ///
  /// In en, this message translates to:
  /// **'No date'**
  String get noDate;

  /// No description provided for @pickDate.
  ///
  /// In en, this message translates to:
  /// **'Pick date'**
  String get pickDate;

  /// No description provided for @pickTime.
  ///
  /// In en, this message translates to:
  /// **'Pick time'**
  String get pickTime;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @undo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get undo;

  /// No description provided for @saved.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get saved;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @financialNote.
  ///
  /// In en, this message translates to:
  /// **'Money record: nothing is saved until you tap Confirm.'**
  String get financialNote;

  /// No description provided for @largeAmountTitle.
  ///
  /// In en, this message translates to:
  /// **'Large amount'**
  String get largeAmountTitle;

  /// No description provided for @largeAmountBody.
  ///
  /// In en, this message translates to:
  /// **'{amount}: are you sure this is correct?'**
  String largeAmountBody(String amount);

  /// No description provided for @ambiguityAmPm.
  ///
  /// In en, this message translates to:
  /// **'Morning or evening? Please check the time.'**
  String get ambiguityAmPm;

  /// No description provided for @ambiguityRelativeDay.
  ///
  /// In en, this message translates to:
  /// **'Which day did you mean? Please check.'**
  String get ambiguityRelativeDay;

  /// No description provided for @ambiguityRelativeWeek.
  ///
  /// In en, this message translates to:
  /// **'This week or next week? Please check.'**
  String get ambiguityRelativeWeek;

  /// No description provided for @ambiguityMissingDate.
  ///
  /// In en, this message translates to:
  /// **'Please pick a date.'**
  String get ambiguityMissingDate;

  /// No description provided for @problemMissingTitle.
  ///
  /// In en, this message translates to:
  /// **'Add what this is about'**
  String get problemMissingTitle;

  /// No description provided for @problemMissingAmount.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid amount'**
  String get problemMissingAmount;

  /// No description provided for @problemMissingPerson.
  ///
  /// In en, this message translates to:
  /// **'Enter the person\'s name'**
  String get problemMissingPerson;

  /// No description provided for @problemMissingDate.
  ///
  /// In en, this message translates to:
  /// **'Pick a date and time'**
  String get problemMissingDate;

  /// No description provided for @problemTimeInPast.
  ///
  /// In en, this message translates to:
  /// **'This time has already passed'**
  String get problemTimeInPast;

  /// No description provided for @pickEntryToSettle.
  ///
  /// In en, this message translates to:
  /// **'Which entry was settled?'**
  String get pickEntryToSettle;

  /// No description provided for @noOpenEntries.
  ///
  /// In en, this message translates to:
  /// **'No open entries for this person.'**
  String get noOpenEntries;

  /// No description provided for @catFood.
  ///
  /// In en, this message translates to:
  /// **'Food'**
  String get catFood;

  /// No description provided for @catTransport.
  ///
  /// In en, this message translates to:
  /// **'Transport'**
  String get catTransport;

  /// No description provided for @catBills.
  ///
  /// In en, this message translates to:
  /// **'Bills'**
  String get catBills;

  /// No description provided for @catShopping.
  ///
  /// In en, this message translates to:
  /// **'Shopping'**
  String get catShopping;

  /// No description provided for @catHealth.
  ///
  /// In en, this message translates to:
  /// **'Health'**
  String get catHealth;

  /// No description provided for @catEducation.
  ///
  /// In en, this message translates to:
  /// **'Education'**
  String get catEducation;

  /// No description provided for @catMobile.
  ///
  /// In en, this message translates to:
  /// **'Mobile recharge'**
  String get catMobile;

  /// No description provided for @catFamily.
  ///
  /// In en, this message translates to:
  /// **'Family'**
  String get catFamily;

  /// No description provided for @catOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get catOther;

  /// No description provided for @todayTitle.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get todayTitle;

  /// No description provided for @spentToday.
  ///
  /// In en, this message translates to:
  /// **'Spent today'**
  String get spentToday;

  /// No description provided for @spentMonth.
  ///
  /// In en, this message translates to:
  /// **'This month'**
  String get spentMonth;

  /// No description provided for @toReceive.
  ///
  /// In en, this message translates to:
  /// **'To receive'**
  String get toReceive;

  /// No description provided for @toPay.
  ///
  /// In en, this message translates to:
  /// **'To pay'**
  String get toPay;

  /// No description provided for @remindersToday.
  ///
  /// In en, this message translates to:
  /// **'Today\'s reminders'**
  String get remindersToday;

  /// No description provided for @dueTasks.
  ///
  /// In en, this message translates to:
  /// **'Due & overdue'**
  String get dueTasks;

  /// No description provided for @nothingToday.
  ///
  /// In en, this message translates to:
  /// **'Nothing for today yet. Tap the orb and tell me something.'**
  String get nothingToday;

  /// No description provided for @tasksTitle.
  ///
  /// In en, this message translates to:
  /// **'Tasks'**
  String get tasksTitle;

  /// No description provided for @remindersTitle.
  ///
  /// In en, this message translates to:
  /// **'Reminders'**
  String get remindersTitle;

  /// No description provided for @noTasks.
  ///
  /// In en, this message translates to:
  /// **'No open tasks'**
  String get noTasks;

  /// No description provided for @noReminders.
  ///
  /// In en, this message translates to:
  /// **'No upcoming reminders'**
  String get noReminders;

  /// No description provided for @addManually.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get addManually;

  /// No description provided for @due.
  ///
  /// In en, this message translates to:
  /// **'Due'**
  String get due;

  /// No description provided for @overdue.
  ///
  /// In en, this message translates to:
  /// **'Overdue'**
  String get overdue;

  /// No description provided for @expensesTitle.
  ///
  /// In en, this message translates to:
  /// **'This month\'s spending'**
  String get expensesTitle;

  /// No description provided for @ledgerTitle.
  ///
  /// In en, this message translates to:
  /// **'Owed & owing'**
  String get ledgerTitle;

  /// No description provided for @settle.
  ///
  /// In en, this message translates to:
  /// **'Mark settled'**
  String get settle;

  /// No description provided for @settleConfirm.
  ///
  /// In en, this message translates to:
  /// **'Mark {person} · {amount} as settled?'**
  String settleConfirm(String person, String amount);

  /// No description provided for @noExpenses.
  ///
  /// In en, this message translates to:
  /// **'No spending recorded this month'**
  String get noExpenses;

  /// No description provided for @noLedger.
  ///
  /// In en, this message translates to:
  /// **'No one owes anyone. Nice!'**
  String get noLedger;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'App language'**
  String get language;

  /// No description provided for @speechLanguage.
  ///
  /// In en, this message translates to:
  /// **'Speaking language'**
  String get speechLanguage;

  /// No description provided for @summaryTime.
  ///
  /// In en, this message translates to:
  /// **'Daily summary notification'**
  String get summaryTime;

  /// No description provided for @off.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get off;

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// No description provided for @anonymousWarning.
  ///
  /// In en, this message translates to:
  /// **'Your account isn\'t secured yet. If you uninstall the app, your data will be lost.'**
  String get anonymousWarning;

  /// No description provided for @secureAccount.
  ///
  /// In en, this message translates to:
  /// **'Secure with email'**
  String get secureAccount;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password (min 6 characters)'**
  String get password;

  /// No description provided for @accountSecured.
  ///
  /// In en, this message translates to:
  /// **'Secured: {email}'**
  String accountSecured(String email);

  /// No description provided for @privacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy'**
  String get privacy;

  /// No description provided for @privacyBody.
  ///
  /// In en, this message translates to:
  /// **'Bolo never records audio. The text of what you say is sent to an AI service only to understand it, and is not stored. Your records are visible only to you.'**
  String get privacyBody;

  /// No description provided for @inbox.
  ///
  /// In en, this message translates to:
  /// **'Inbox'**
  String get inbox;

  /// No description provided for @inboxEmpty.
  ///
  /// In en, this message translates to:
  /// **'Nothing waiting'**
  String get inboxEmpty;

  /// No description provided for @process.
  ///
  /// In en, this message translates to:
  /// **'Process'**
  String get process;

  /// No description provided for @signInFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t connect. Turn on the internet and try again.'**
  String get signInFailed;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @summaryNotificationTitle.
  ///
  /// In en, this message translates to:
  /// **'Today\'s summary'**
  String get summaryNotificationTitle;

  /// No description provided for @summaryNotificationBody.
  ///
  /// In en, this message translates to:
  /// **'{tasks} tasks left · spent {spent}'**
  String summaryNotificationBody(String tasks, String spent);

  /// No description provided for @notificationsOff.
  ///
  /// In en, this message translates to:
  /// **'Turn on notifications so reminders can reach you.'**
  String get notificationsOff;

  /// No description provided for @enable.
  ///
  /// In en, this message translates to:
  /// **'Enable'**
  String get enable;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['bn', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'bn':
      return AppLocalizationsBn();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
