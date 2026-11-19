// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Bengali Bangla (`bn`).
class AppLocalizationsBn extends AppLocalizations {
  AppLocalizationsBn([String locale = 'bn']) : super(locale);

  @override
  String get appTitle => 'বলো';

  @override
  String get greetingMorning => 'শুভ সকাল';

  @override
  String get greetingAfternoon => 'শুভ দুপুর';

  @override
  String get greetingEvening => 'শুভ সন্ধ্যা';

  @override
  String get greetingNight => 'শুভ রাত্রি';

  @override
  String get tapToSpeak => 'অরবে ট্যাপ করে বলুন';

  @override
  String get orbLabel => 'ভয়েস ইনপুট। শোনা শুরু বা বন্ধ করতে ডাবল ট্যাপ করুন।';

  @override
  String get listening => 'শুনছি…';

  @override
  String get thinking => 'বুঝছি…';

  @override
  String get typeInstead => 'লিখে দিন';

  @override
  String get inputHint =>
      'যেমন: কাল সকাল ১০টায় ভাড়া দেওয়ার কথা মনে করিয়ে দিও';

  @override
  String get send => 'পাঠান';

  @override
  String get micUnavailable => 'কথা শোনার সেবা পাওয়া যায়নি। লিখে দিতে পারেন।';

  @override
  String get heardNothing => 'কিছু শুনতে পাইনি। আবার বলবেন?';

  @override
  String get offlineSaved =>
      'ইন্টারনেট নেই। ইনবক্সে রাখা হলো, পরে প্রসেস করতে পারবেন।';

  @override
  String get quotaExceeded =>
      'আজকের ভয়েস কমান্ডের সীমা শেষ। হাতে লিখে যোগ করতে পারেন।';

  @override
  String get notUnderstood => 'ঠিক বুঝতে পারিনি। নিচ থেকে ধরন বেছে নিন।';

  @override
  String get serverError => 'কিছু একটা সমস্যা হয়েছে। আবার চেষ্টা করুন।';

  @override
  String get tooLong => 'লেখাটি অনেক বড় (সর্বোচ্চ ৫০০ অক্ষর)।';

  @override
  String get notSignedIn =>
      'এখনও সংযোগ হয়নি। ইন্টারনেট দেখে আবার চেষ্টা করুন।';

  @override
  String get heard => 'শুনেছি';

  @override
  String get navToday => 'আজ';

  @override
  String get navTasks => 'কাজ';

  @override
  String get navMoney => 'টাকা';

  @override
  String get navSettings => 'সেটিংস';

  @override
  String get intentReminder => 'রিমাইন্ডার';

  @override
  String get intentTask => 'কাজ';

  @override
  String get intentExpense => 'খরচ';

  @override
  String get intentReceivable => 'আমি পাব';

  @override
  String get intentPayable => 'আমি দেব';

  @override
  String get intentSettle => 'পরিশোধ হয়েছে';

  @override
  String get intentSummary => 'সারাংশ';

  @override
  String get intentUnknown => 'ধরন বেছে নিন';

  @override
  String get fieldTitle => 'বিষয়';

  @override
  String get fieldNote => 'নোট';

  @override
  String get fieldAmount => 'পরিমাণ (৳)';

  @override
  String get fieldPerson => 'কার সাথে';

  @override
  String get fieldCategory => 'খাত';

  @override
  String get fieldDate => 'তারিখ';

  @override
  String get fieldTime => 'সময়';

  @override
  String get fieldRemindBefore => 'এক দিন আগে মনে করিয়ে দিও';

  @override
  String get fieldRepeat => 'পুনরাবৃত্তি';

  @override
  String get repeatNone => 'একবার';

  @override
  String get repeatDaily => 'প্রতিদিন';

  @override
  String get repeatWeekly => 'প্রতি সপ্তাহে';

  @override
  String get noDate => 'তারিখ নেই';

  @override
  String get pickDate => 'তারিখ বাছুন';

  @override
  String get pickTime => 'সময় বাছুন';

  @override
  String get save => 'সেভ করুন';

  @override
  String get confirm => 'নিশ্চিত করুন';

  @override
  String get cancel => 'বাতিল';

  @override
  String get undo => 'ফিরিয়ে নিন';

  @override
  String get saved => 'সেভ হয়েছে';

  @override
  String get delete => 'মুছুন';

  @override
  String get financialNote =>
      'টাকার হিসাব: “নিশ্চিত করুন” না চাপলে কিছুই সেভ হবে না।';

  @override
  String get largeAmountTitle => 'বড় অঙ্ক';

  @override
  String largeAmountBody(String amount) {
    return '$amount। আপনি কি নিশ্চিত যে এটি ঠিক?';
  }

  @override
  String get ambiguityAmPm => 'সকাল নাকি বিকাল/রাত? সময়টি দেখে নিন।';

  @override
  String get ambiguityRelativeDay => 'কোন দিন বোঝালেন? দেখে নিন।';

  @override
  String get ambiguityRelativeWeek => 'এই সপ্তাহ নাকি পরের সপ্তাহ? দেখে নিন।';

  @override
  String get ambiguityMissingDate => 'একটি তারিখ বেছে নিন।';

  @override
  String get problemMissingTitle => 'বিষয়টি লিখুন';

  @override
  String get problemMissingAmount => 'সঠিক পরিমাণ লিখুন';

  @override
  String get problemMissingPerson => 'ব্যক্তির নাম লিখুন';

  @override
  String get problemMissingDate => 'তারিখ ও সময় বেছে নিন';

  @override
  String get problemTimeInPast => 'এই সময়টি পেরিয়ে গেছে';

  @override
  String get pickEntryToSettle => 'কোন হিসাবটি পরিশোধ হলো?';

  @override
  String get noOpenEntries => 'এই নামে কোনো খোলা হিসাব নেই।';

  @override
  String get catFood => 'খাবার';

  @override
  String get catTransport => 'যাতায়াত';

  @override
  String get catBills => 'বিল';

  @override
  String get catShopping => 'কেনাকাটা';

  @override
  String get catHealth => 'স্বাস্থ্য';

  @override
  String get catEducation => 'পড়াশোনা';

  @override
  String get catMobile => 'মোবাইল রিচার্জ';

  @override
  String get catFamily => 'পরিবার';

  @override
  String get catOther => 'অন্যান্য';

  @override
  String get todayTitle => 'আজ';

  @override
  String get spentToday => 'আজ খরচ';

  @override
  String get spentMonth => 'এই মাসে';

  @override
  String get toReceive => 'পাব';

  @override
  String get toPay => 'দেব';

  @override
  String get remindersToday => 'আজকের রিমাইন্ডার';

  @override
  String get dueTasks => 'বাকি ও সময় পেরোনো কাজ';

  @override
  String get nothingToday =>
      'আজকের জন্য এখনও কিছু নেই। অরবে ট্যাপ করে কিছু বলুন।';

  @override
  String get tasksTitle => 'কাজ';

  @override
  String get remindersTitle => 'রিমাইন্ডার';

  @override
  String get noTasks => 'কোনো বাকি কাজ নেই';

  @override
  String get noReminders => 'সামনে কোনো রিমাইন্ডার নেই';

  @override
  String get addManually => 'যোগ করুন';

  @override
  String get due => 'শেষ সময়';

  @override
  String get overdue => 'সময় পেরিয়েছে';

  @override
  String get expensesTitle => 'এই মাসের খরচ';

  @override
  String get ledgerTitle => 'পাওনা-দেনা';

  @override
  String get settle => 'পরিশোধ হয়েছে';

  @override
  String settleConfirm(String person, String amount) {
    return '$person · $amount পরিশোধ হয়েছে বলে চিহ্নিত করবেন?';
  }

  @override
  String get noExpenses => 'এই মাসে কোনো খরচ লেখা হয়নি';

  @override
  String get noLedger => 'কারও কাছে কোনো পাওনা-দেনা নেই!';

  @override
  String get settingsTitle => 'সেটিংস';

  @override
  String get language => 'অ্যাপের ভাষা';

  @override
  String get speechLanguage => 'কথা বলার ভাষা';

  @override
  String get summaryTime => 'দৈনিক সারাংশের নোটিফিকেশন';

  @override
  String get off => 'বন্ধ';

  @override
  String get account => 'অ্যাকাউন্ট';

  @override
  String get anonymousWarning =>
      'আপনার অ্যাকাউন্ট এখনও সুরক্ষিত নয়। অ্যাপ মুছে ফেললে ডেটা হারিয়ে যাবে।';

  @override
  String get secureAccount => 'ইমেইল দিয়ে সুরক্ষিত করুন';

  @override
  String get email => 'ইমেইল';

  @override
  String get password => 'পাসওয়ার্ড (কমপক্ষে ৬ অক্ষর)';

  @override
  String accountSecured(String email) {
    return 'সুরক্ষিত: $email';
  }

  @override
  String get privacy => 'গোপনীয়তা';

  @override
  String get privacyBody =>
      'বলো কখনও অডিও রেকর্ড করে না। আপনি যা বলেন তার লেখাটি শুধু বোঝার জন্য একটি AI সেবায় পাঠানো হয়, সংরক্ষণ করা হয় না। আপনার হিসাব শুধু আপনিই দেখতে পান।';

  @override
  String get inbox => 'ইনবক্স';

  @override
  String get inboxEmpty => 'কিছু অপেক্ষায় নেই';

  @override
  String get process => 'প্রসেস করুন';

  @override
  String get signInFailed =>
      'সংযোগ করা যায়নি। ইন্টারনেট চালু করে আবার চেষ্টা করুন।';

  @override
  String get retry => 'আবার চেষ্টা';

  @override
  String get summaryNotificationTitle => 'আজকের সারাংশ';

  @override
  String summaryNotificationBody(String tasks, String spent) {
    return '$tasksটি কাজ বাকি · খরচ $spent';
  }

  @override
  String get notificationsOff => 'রিমাইন্ডার পেতে নোটিফিকেশন চালু করুন।';

  @override
  String get enable => 'চালু করুন';
}
