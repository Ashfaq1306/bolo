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
  String tapToSpeak(String name) {
    return '$name-কে ট্যাপ করে বলুন';
  }

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
  String nothingToday(String name) {
    return 'আজকের জন্য এখনও কিছু নেই। $name-কে ট্যাপ করে কিছু বলুন।';
  }

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

  @override
  String speakExpense(String amount, String category) {
    return '$category-এ $amount টাকা খরচ। সেভ করব?';
  }

  @override
  String speakReminder(String when, String title) {
    return '$when মনে করিয়ে দেব: $title। ঠিক আছে?';
  }

  @override
  String speakTask(String title) {
    return 'নতুন কাজ: $title। সেভ করব?';
  }

  @override
  String speakReceivable(String person, String amount) {
    return '$person আপনাকে $amount টাকা দেবে। নিশ্চিত করুন।';
  }

  @override
  String speakPayable(String person, String amount) {
    return 'আপনি $person-কে $amount টাকা দেবেন। নিশ্চিত করুন।';
  }

  @override
  String speakSettle(String person) {
    return '$person-এর কোন হিসাবটি পরিশোধ হলো?';
  }

  @override
  String get speakUnknown => 'দুঃখিত, বুঝতে পারিনি। ধরনটি বেছে নিন।';

  @override
  String get speakSaved => 'হয়ে গেছে, সেভ করেছি!';

  @override
  String get voiceReplies => 'ভয়েস উত্তর (বলো কথা বলবে)';

  @override
  String get voiceUnavailable =>
      'এই ফোনে এই ভাষার ভয়েস ইনস্টল করা নেই। সেটিংস → টেক্সট-টু-স্পিচ থেকে ইনস্টল করুন।';

  @override
  String get pickContact => 'কন্টাক্ট থেকে বাছুন';

  @override
  String get addToCalendar => 'ফোনের ক্যালেন্ডারেও যোগ করুন';

  @override
  String get scanReceipt => 'রসিদ স্ক্যান';

  @override
  String get scanNoText =>
      'কোনো লেখা পড়া যায়নি। ভালো আলোতে আবার চেষ্টা করুন, অথবা হাতে লিখুন।';

  @override
  String get scanFailed => 'এই ফোনে স্ক্যান কাজ করেনি। হাতে লিখে যোগ করুন।';

  @override
  String get scanHint =>
      'ফোনেই পড়া হয়েছে, ছবিটি সাথে সাথে মুছে ফেলা হয়েছে। পরিমাণটি দেখে নিন।';

  @override
  String get devicePowers => 'ফোনের সুবিধা';

  @override
  String get devicePowersBody =>
      'আপনি যা বলবেন বলো শুধু সেটুকুই ব্যবহার করে: কাউকে কল করতে বললে কন্টাক্ট ফোনেই খোঁজা হয় (নাম কোথাও পাঠানো হয় না), কল করার আগে আপনার সম্মতি লাগে, গান ও অ্যাপ নিজ নিজ অ্যাপে খোলে, রসিদ ফোনেই পড়া হয় এবং ছবি মুছে ফেলা হয়। ব্যাকগ্রাউন্ডে শুধু ঐচ্ছিক \"বলো\" শোনার ব্যবস্থা চলে, যা ফোনেই কাজ করে এবং চালু থাকলে নোটিফিকেশন দেখায়।';

  @override
  String get updateTitle => 'নতুন আপডেট এসেছে';

  @override
  String updateBody(String version) {
    return 'বলো $version তৈরি। আপনার তথ্য আপনার অ্যাকাউন্টে নিরাপদ থাকবে।';
  }

  @override
  String get updateMandatoryBody =>
      'বলো ব্যবহার চালিয়ে যেতে এই আপডেটটি দরকার।';

  @override
  String get updateNow => 'আপডেট করুন';

  @override
  String get updateLater => 'পরে';

  @override
  String get updateHowTo =>
      'নতুন ভার্সন ব্রাউজারে ডাউনলোড হবে। ফাইলটি খুলে Install চাপুন (Android জিজ্ঞেস করলে \"Install unknown apps\" চালু করুন)।';

  @override
  String get updateOpenFailed => 'ডাউনলোড লিংক খোলা যায়নি।';

  @override
  String get checkUpdates => 'আপডেট আছে কিনা দেখুন';

  @override
  String get upToDate => 'আপনার কাছে সর্বশেষ ভার্সন আছে।';

  @override
  String appVersion(String version) {
    return 'ভার্সন $version';
  }

  @override
  String get offlineParserNote =>
      'ফোনেই বোঝা হয়েছে (AI সংযুক্ত নেই)। বিস্তারিত দেখে নিন।';

  @override
  String get nothingPlannedToday => 'আজ কোনো রিমাইন্ডার বা কাজ নেই।';

  @override
  String get exactAlarmTitle => 'রিমাইন্ডার ঠিক সময়ে বাজবে?';

  @override
  String get exactAlarmBody =>
      'Android রিমাইন্ডার কয়েক মিনিট দেরিতে দিতে পারে। পরের স্ক্রিনে বলোর জন্য \"Allow setting alarms and reminders\" চালু করুন, তাহলে ঠিক সময়ে বাজবে।';

  @override
  String get exactAlarmOpen => 'চালু করুন';

  @override
  String get intentCall => 'কল';

  @override
  String get intentPlay => 'গান';

  @override
  String get intentOpen => 'অ্যাপ খোলা';

  @override
  String speakCall(String name) {
    return '$name-কে কল করছি।';
  }

  @override
  String speakPlay(String query) {
    return 'চালাচ্ছি: $query।';
  }

  @override
  String speakOpen(String app) {
    return '$app খুলছি।';
  }

  @override
  String get wakeGreeting => 'জি, বলুন। কী করতে পারি?';

  @override
  String get needUnlock => 'আগে ফোনটা আনলক করুন।';

  @override
  String appNotFound(String app) {
    return '\"$app\" নামে কোনো অ্যাপ পাইনি।';
  }

  @override
  String get playFailed => 'এই ফোনে কোনো গানের অ্যাপ বা YouTube পাইনি।';

  @override
  String get callWho => 'কাকে কল করবো?';

  @override
  String get callButton => 'কল';

  @override
  String callNoMatch(String name) {
    return 'কন্টাক্টে \"$name\" নামে কাউকে পাইনি।';
  }

  @override
  String get callTypeNumber => 'অথবা নম্বর লিখুন';

  @override
  String get contactsPermissionNeeded =>
      'নাম দিয়ে খুঁজতে বলোকে কন্টাক্ট দেখার অনুমতি দিন। অথবা নিচ থেকে বাছুন।';

  @override
  String callConfirmQuestion(String name) {
    return '$name-কে কল করবো?';
  }

  @override
  String get callDialerNote =>
      'কল করার অনুমতি নেই, তাই নম্বরসহ ডায়ালার খোলা হলো।';

  @override
  String get lockedHint =>
      'ফোন লক করা আছে: বলো শুধু শুনছে। আনলক না করা পর্যন্ত আপনার তথ্য লুকানো থাকবে।';

  @override
  String get assistantTitle => 'সহকারী';

  @override
  String get assistantName => 'সহকারীর নাম';

  @override
  String get assistantNameHint =>
      'এই নামে ডাকবেন। ইংরেজি অক্ষরে লিখুন, যেমন Bolo, Robi, Mina।';

  @override
  String get assistantNameInvalid => '২–২০টি ইংরেজি অক্ষর ব্যবহার করুন।';

  @override
  String get assistantNameUnknown =>
      'অফলাইন শোনার ব্যবস্থা এই শব্দটি চেনে না, তাই শুনতে পাবে না। অন্য নাম দিন (যেমন Bolo, Robi, Mina, Jarvis)।';

  @override
  String handsFree(String name) {
    return '\"$name\" বললে সাড়া দেবে';
  }

  @override
  String handsFreeBody(String name) {
    return 'স্ক্রিন বন্ধ বা লক থাকলেও \"$name\" বলুন। শোনা হয় এই ফোনেই; কিছুই রেকর্ড বা পাঠানো হয় না।';
  }

  @override
  String get sensitivity => 'নাম কতটা সহজে শুনবে';

  @override
  String get sensLow => 'কম';

  @override
  String get sensNormal => 'স্বাভাবিক';

  @override
  String get sensHigh => 'বেশি';

  @override
  String get allowLockScreen => 'লক স্ক্রিনে আসতে দিন';

  @override
  String get allowOverApps => 'অন্য অ্যাপের উপরে আসতে দিন';

  @override
  String get allowButton => 'অনুমতি দিন';

  @override
  String get allowedLabel => 'চালু';

  @override
  String get handsFreeLimits =>
      'ফোন চালু থাকলে কাজ করবে (স্ক্রিন বন্ধ বা লক থাকলেও), ফোন পুরো বন্ধ থাকলে নয়। ব্যাটারি একটু বেশি লাগবে এবং একটি স্থায়ী নোটিফিকেশন থাকবে। ফোন রিস্টার্টের পর একবার বলো খুলুন।';

  @override
  String assistantCanDo(String name) {
    return 'বলে দেখুন: \"$name, আম্মুকে ফোন দাও\", \"আরিজিত সিং এর গান বাজাও\", \"YouTube খোলো\", \"১০ মিনিট পরে পানি খেতে মনে করিয়ে দিও\"।';
  }

  @override
  String get micPermission =>
      'মাইক্রোফোনের অনুমতি লাগবে। সেটিংস › অ্যাপ › বলো › অনুমতি থেকে চালু করুন।';

  @override
  String get micBusy =>
      'মাইক্রোফোন ব্যস্ত বা কোনো শব্দ পাচ্ছে না। মাইক ব্যবহার করছে এমন অ্যাপ বন্ধ করুন (বা ব্লুটুথ বিচ্ছিন্ন করুন), তারপর আবার চেষ্টা করুন।';

  @override
  String get speechLanguageUnavailable =>
      'এই ফোনের কথা চেনার সেবা এই ভাষা বোঝে না। Google-এর স্পিচ সেবা ইনস্টল বা আপডেট করুন, অথবা সেটিংসে কথা বলার ভাষা বদলান।';

  @override
  String get speechNetwork =>
      'এই ফোনে কথা চিনতে ইন্টারনেট লাগে। সংযোগ দেখুন, অথবা লিখে দিন।';

  @override
  String get speechServiceError =>
      'ফোনের কথা চেনার সেবায় সমস্যা হয়েছে। আবার চেষ্টা করুন।';

  @override
  String get notRecognized =>
      'শুনেছি, কিন্তু কথাগুলো বুঝতে পারিনি। আবার বলবেন?';

  @override
  String get voiceCheck => 'ভয়েস পরীক্ষা';

  @override
  String get voiceCheckHint =>
      'এই ফোনে কথা বলে কাজ না হলে এটি চালান এবং রিপোর্টটি বলো টিমকে পাঠান। এতে কোনো রেকর্ডিং বা ব্যক্তিগত তথ্য নেই।';

  @override
  String get voiceCheckRun => 'ভয়েস পরীক্ষা চালান';

  @override
  String get voiceCheckCopy => 'রিপোর্ট কপি করুন';

  @override
  String get voiceCheckCopied => 'রিপোর্ট কপি হয়েছে';

  @override
  String get guestLocalOnly =>
      'আপনার তথ্য শুধু এই ফোনে সংরক্ষিত আছে। অ্যাপ মুছে ফেললে বা অ্যাপের ডেটা ক্লিয়ার করলে তা আর ফেরত পাওয়া যাবে না। অ্যাকাউন্টে ব্যাকআপ ও সিঙ্ক পরের আপডেটে আসছে।';

  @override
  String get migrationRunning => 'আপনার তথ্য এই ফোনে আনা হচ্ছে…';

  @override
  String migrationDone(String count) {
    return 'আপনার তথ্য এখন এই ফোনে: $countটি আইটেম আনা হয়েছে।';
  }

  @override
  String get migrationCacheOnly => 'ইন্টারনেট পেলে বাকি আইটেমগুলো আনা হবে।';

  @override
  String get migrationFailed =>
      'আগের তথ্য আনা শেষ করা যায়নি। বলো আবার চেষ্টা করবে; কিছুই মুছে ফেলা হয়নি।';

  @override
  String get dbOpenFailed =>
      'বলো এই ফোনে তার তথ্য খুলতে পারেনি। কিছুই মুছে ফেলা হয়নি। অ্যাপটি বন্ধ করে আবার খুলুন।';
}
