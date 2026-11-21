import '../../core/bangla_digits.dart';
import '../../core/dhaka_time.dart';

/// A free, offline, rule-based parser that runs on the phone.
///
/// It is the **fallback** for when the AI (the `parseCommand` Cloud Function)
/// can't be used: the function isn't deployed yet, or the server failed. It
/// understands common Bangla / Banglish / English patterns, but it is much
/// less clever than the AI, so it always reports a modest confidence and the
/// user reviews everything on the confirmation card (money still needs an
/// explicit Confirm).
///
/// It returns the same JSON shape as the server (functions/src/parse/validate.ts)
/// so it plugs into `ParsedCommand.fromServer`.
Map<String, dynamic> parseOnDevice(String raw, DateTime now) {
  final text = toAsciiDigits(raw).toLowerCase().replaceAll(RegExp(r'(?<=\d),(?=\d)'), '');
  final today = DhakaTime.toDhaka(now);

  String dayOffset(int days) => DhakaTime.isoDate(DhakaTime.at(today.year, today.month, today.day + days, 12));

  bool has(String pattern) => RegExp(pattern).hasMatch(text);

  // ---------- intent ----------
  final amount = _amount(text);
  var intent = 'unknown';
  if (has(r'remind|mone kor|mone koriye|মনে কর|মনে করি|alarm|reminder|যেন ভুলে না')) {
    intent = 'create_reminder';
  } else if (has(_callPattern)) {
    // Assistant actions. ("Remind me to call X" stays a reminder: checked above.)
    intent = 'call_contact';
  } else if (has(_playPattern)) {
    intent = 'play_media';
  } else if (has(_openPattern)) {
    intent = 'open_app';
  } else if (has(r'shodh|শোধ|ferot (dilo|dise|diyeche)|ফেরত (দিল|দিয়েছে|দিসে)|paid back|settle|returned')) {
    intent = 'settle_ledger';
  } else if (amount != null && has(r'pabo|পাব|owes me|dhar dilam|dhar disi|ধার দিলাম|ধার দিয়েছি|ধার দিসি|amake .{0,30}(dibe|debe|diben|dite hobe|ferot dibe)|আমাকে .{0,30}(দিবে|দেবে|দিবেন|দিতে হবে)')) {
    intent = 'add_receivable';
  } else if (amount != null && has(r'dite hobe|দিতে হবে|owe|dhar nilam|dhar nisi|ধার নিলাম|ধার নিয়েছি|ধার নিসি|pay korte hobe|ke dibo|কে দিব')) {
    intent = 'add_payable';
  } else if (amount != null && has(r'khoroch|খরচ|spent|spend|kinlam|কিনলাম|kinsi|কিনেছি|dilam|দিলাম|bill|বিল|recharge|রিচার্জ|vara|ভাড়া|paid|kharach')) {
    intent = 'add_expense';
  } else if (has(r'korte hobe|করতে হবে|submit|deadline|task|jama dite|জমা দিতে|শেষ করতে|shesh korte|porte hobe|পড়তে হবে')) {
    intent = 'create_task';
  } else if (has(r'summary|hisab|হিসাব|koto khoroch|কত খরচ|ajke ki|আজকে কী|আজ কী')) {
    intent = 'query_summary';
  } else if (amount != null && has(r'taka|টাকা|tk|৳')) {
    // "lunch 350 taka" with no verb: most likely an expense.
    intent = 'add_expense';
  }

  // ---------- date ----------
  String? date;
  var ambiguity = 'none';
  if (has(r'gotokal|গতকাল|yesterday')) {
    date = dayOffset(-1);
  } else if (has(r'porshu|পরশু|day after tomorrow')) {
    date = dayOffset(2);
  } else if (has(r'(^|[^a-z])(kal|kalke|tomorrow)([^a-z]|$)|আগামীকাল|(?<![ঀ-৿])কাল')) {
    // "kal" means yesterday OR tomorrow. Money already spent -> yesterday.
    date = intent == 'add_expense' ? dayOffset(-1) : dayOffset(1);
  } else if (has(r'(^|[^a-z])(aaj|aj|ajke|aajke|today|tonight)([^a-z]|$)|আজ')) {
    date = dayOffset(0);
  }

  // ---------- time ----------
  String? time;
  final alternatives = <Map<String, dynamic>>[];
  final tm = RegExp(r'(?<![\d.])(\d{1,2})(?:[:.](\d{2}))?\s*(?:tay|tai|tar|ta(?!ka)|টায়|টায়|টার|টা(?!কা)|am(?![a-z])|pm(?![a-z])|baje|বাজে|o.?clock)').firstMatch(text);
  if (tm != null) {
    var h = int.parse(tm.group(1)!);
    final m = int.tryParse(tm.group(2) ?? '') ?? 0;
    final after = text.substring(tm.start, (tm.end + 3).clamp(0, text.length));
    final pm = after.contains('pm') || has(r'bikal|bikel|বিকাল|বিকেল|shondha|sondha|সন্ধ্যা|evening|afternoon');
    final night = has(r'(^|[^a-z])rat|রাত|night|tonight');
    final noon = has(r'dupur|দুপুর|noon');
    final morning = after.contains('am') || has(r'sokal|shokal|সকাল|morning|bhor|ভোর');
    if (h <= 23 && m < 60) {
      if (pm && h < 12) {
        h += 12;
      } else if (night && h >= 6 && h < 12) {
        h += 12;
      } else if (noon && h <= 4) {
        h += 12;
      } else if (after.contains('am') && h == 12) {
        h = 0;
      } else if (!morning && !night && !noon && h >= 1 && h <= 11) {
        // "5 tay" with no day-part: AM or PM? Guess the likelier one and
        // offer the other as a one-tap alternative on the card.
        ambiguity = 'am_pm';
        final guess = h <= 6 ? h + 12 : h;
        final other = h <= 6 ? h : h + 12;
        final d = date ?? dayOffset(0);
        // The card shows our main guess first; list only the other reading.
        alternatives.add({'date': d, 'time': _hm(other, m)});
        h = guess;
      }
      time = _hm(h, m);
    }
  }

  // "10 minute pore", "in 2 hours", "আধা ঘণ্টা পরে": relative to now.
  final rel = _relativeMinutes(text);
  if (rel != null && (intent == 'create_reminder' || intent == 'create_task')) {
    final at = today.add(Duration(minutes: rel));
    date = DhakaTime.isoDate(at);
    time = _hm(at.hour, at.minute);
    ambiguity = 'none';
    alternatives.clear();
  }

  if (intent == 'create_reminder') {
    date ??= dayOffset(0);
    if (time == null) {
      // No time said: tomorrow/later -> 9 AM; today -> one hour from now.
      if (date == dayOffset(0)) {
        final inAnHour = today.add(const Duration(hours: 1));
        time = _hm(inAnHour.hour, 0);
        if (inAnHour.day != today.day) date = dayOffset(1);
      } else {
        time = '09:00';
      }
    }
  }
  if (intent == 'add_expense') date ??= dayOffset(0);

  final language = RegExp(r'[ঀ-৿]').hasMatch(raw) ? 'bn' : (RegExp(r'[a-z]').hasMatch(text) && !_looksBanglish(text) ? 'en' : 'mixed');

  return {
    'intent': intent,
    // Modest on purpose: this is a rules engine, not the AI.
    'confidence': intent == 'unknown' ? 0.2 : 0.6,
    'title': switch (intent) {
      'play_media' => _mediaQuery(raw),
      'open_app' => _appName(raw),
      'call_contact' => '',
      _ => _title(raw, intent),
    },
    'amount': const {'add_expense', 'add_receivable', 'add_payable', 'settle_ledger'}.contains(intent) ? amount : null,
    'person': switch (intent) {
      'call_contact' => _callee(raw, text),
      'add_expense' || 'create_reminder' || 'create_task' || 'query_summary' || 'play_media' || 'open_app' => null,
      _ => _person(raw, text),
    },
    'category': intent == 'add_expense' ? _category(text) : null,
    'date': date,
    'time': time,
    'ambiguity': ambiguity,
    'alternatives': alternatives,
    'reminderOffsetMinutes': null,
    'repeat': has(r'roj|রোজ|protidin|প্রতিদিন|every ?day|daily') ? 'daily' : (has(r'protisoptah|প্রতি সপ্তাহে|every week|weekly') ? 'weekly' : 'none'),
    'clarification': null,
    'language': language,
  };
}

String _hm(int h, int m) => '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}';

/// Finds the money amount in taka. Prefers a number next to "taka"/"tk"/"৳",
/// then one with a multiplier (k, hajar, lakh), and skips clock times.
double? _amount(String text) {
  final number = RegExp(r'(?<![\d.:])(\d+(?:\.\d+)?)\s*(k(?![a-z])|hajar|hazar|হাজার|lakh|lac|লাখ|লক্ষ)?(?![\d])');
  double? withTaka;
  double? withMultiplier;
  double? plain;
  for (final m in number.allMatches(text)) {
    final rest = text.substring(m.end).trimLeft();
    if (RegExp(r'^(tay|tai|tar|ta(?!ka)|টা(?!কা)|টায়|টায়|am(?![a-z])|pm(?![a-z])|baje|বাজে|[:.]\d)').hasMatch(rest) && m.group(2) == null) continue;
    var value = double.parse(m.group(1)!);
    final mult = m.group(2);
    if (mult != null) value *= RegExp(r'lakh|lac|লাখ|লক্ষ').hasMatch(mult) ? 100000 : 1000;
    final before = text.substring(0, m.start).trimRight();
    final nearTaka = RegExp(r'^(taka|tk|টাকা|৳|/-)').hasMatch(rest) || before.endsWith('৳') || before.endsWith('tk');
    if (nearTaka) {
      withTaka ??= value;
    } else if (mult != null) {
      withMultiplier ??= value;
    } else {
      plain ??= value;
    }
  }
  final v = withTaka ?? withMultiplier ?? plain;
  if (v == null || v <= 0 || v > 1e9) return null;
  return v;
}

/// "rahim ke 500 dite hobe" -> Rahim; "রহিমকে" -> রহিম; "karim er kache" -> Karim.
String? _person(String raw, String text) {
  const stop = {'ami', 'amake', 'amar', 'tomake', 'take', 'ke', 'kal', 'aaj', 'ajke', 'office', 'bari', 'basa', 'shob', 'sob', 'or', 'oke', 'ma', 'baba'};
  final latin = [
    RegExp(r'([a-z]{3,})\s+(?:ke|k)(?:\s|$)'),
    RegExp(r'([a-z]{3,})\s+(?:er|r)\s+(?:kache|kase|theke)'),
    RegExp(r'(?:to|from|with)\s+([a-z]{3,})'),
    RegExp(r'([a-z]{3,})\s+(?:amake|amk)(?:\s|$)'),
    RegExp(r'([a-z]{3,})\s+owes'),
    RegExp(r'^([a-z]{3,})\s+(?:taka|tk|ferot|shodh|amar)'),
  ];
  for (final re in latin) {
    final m = re.firstMatch(text);
    final name = m?.group(1);
    if (name != null && !stop.contains(name) && !RegExp(r'^(taka|tk|bill|rent|lunch|dinner|office|class|exam|kaj)$').hasMatch(name)) {
      return name[0].toUpperCase() + name.substring(1);
    }
  }
  final bn = [
    RegExp(r'([ঀ-৿]{2,})কে(?=\s|$)'),
    RegExp(r'([ঀ-৿]{2,}?)(?:এর|র) কাছে'),
    RegExp(r'([ঀ-৿]{2,}) আমাকে'),
    RegExp(r'^([ঀ-৿]{2,}) (?:টাকা|ফেরত|শোধ)'),
  ];
  const bnStop = {'আমা', 'তোমা', 'তা', 'ও', 'আমি', 'সবাই', 'আম'};
  for (final re in bn) {
    final m = re.firstMatch(raw);
    final name = m?.group(1);
    if (name != null && !bnStop.contains(name)) return name;
  }
  return null;
}

String _category(String text) {
  const rules = <String, String>{
    'mobile_recharge': r'recharge|রিচার্জ|flexi|ফ্লেক্সি|mb kinlam|internet pack|gp |robi|banglalink|airtel|teletalk',
    'transport': r'rickshaw|riksha|rikshaw|রিকশা|uber|pathao|পাঠাও|bus|বাস|cng|সিএনজি|train|ট্রেন|taxi|launch|লঞ্চ|metro|মেট্রো|vara diye|bike',
    'food': r'lunch|dinner|breakfast|nasta|nashta|নাস্তা|khabar|খাবার|cha|চা|coffee|restaurant|biriyani|বিরিয়ানি|bazar|বাজার|fuchka|ফুচকা|snacks|kacchi|খাওয়া|khawa',
    'bills': r'bill|বিল|electricity|current|বিদ্যুৎ|gas|গ্যাস|wifi|internet|rent|ভাড়া|vara|water|পানি',
    'health': r'doctor|ডাক্তার|medicine|oshudh|osudh|ওষুধ|hospital|হাসপাতাল|pharmacy|test',
    'education': r'book|boi|বই|tuition|টিউশন|fee|school|college|university|coaching|exam|পরীক্ষা|class',
    'shopping': r'shirt|jama|জামা|kapor|কাপড়|shopping|daraz|shoe|juta|জুতা|panjabi|পাঞ্জাবি|saree|শাড়ি',
    'family': r'ammu|abbu|ammake|abbuke|আম্মু|আব্বু|family|পরিবার|bhai|bon|ভাই|বোন|bari pathalam',
  };
  for (final e in rules.entries) {
    if (RegExp(e.value).hasMatch(text)) return e.key;
  }
  return 'other';
}

/// Makes a short title: drops the "remind me" part, dates, times, money and
/// filler, so "kal sokal 10 tay rent dite hobe mone koriye dio" becomes
/// "rent dite hobe" and "aaj lunch e 350 taka khoroch holo" becomes "lunch".
String _title(String raw, String intent) {
  var t = ' ${raw.trim().replaceAll(RegExp(r'\s+'), ' ')} ';
  RegExp ci(String p) => RegExp(p, caseSensitive: false);
  const d = '[0-9০-৯]';
  final drop = <RegExp>[
    // "remind me" phrases
    ci(r'\b(mone koriye dio|mone koriye dao|mone koriye diyo|mone koro|remind me( to)?|reminder|alarm dao)\b'),
    ci(r'মনে করিয়ে দিও|মনে করিয়ে দাও|মনে করিয়ে দিবে|মনে করিয়ে দিয়ো|মনে কর(ো|িও)?'),
    // relative times
    ci('\\b(in )?$d+ ?(minute|minutes|min|mins|ghonta|hour|hours)( pore| por| later)?\\b'),
    ci('$d+ ?(মিনিট|ঘণ্টা) ?(পরে|পর)?'),
    ci(r'\b(adha|half an?) (ghonta|hour)( pore)?\b|আধা ঘণ্টা (পরে|পর)?'),
    // clock times
    ci('\\b(at )?$d{1,2}([:.]$d{2})? ?(tay|tai|tar|ta(?!ka)|am|pm|baje|o.?clock)\\b( e)?'),
    ci('$d{1,2}([:.]$d{2})? ?(টায়|টায়|টার|টা(?!কা)|বাজে)'),
    // day parts and dates
    ci(r'\b(aaj|aj|ajke|aajke|today|tonight|kal|kalke|tomorrow|porshu|gotokal|yesterday|sokal|shokal|bikal|bikel|dupur|rat|shondha|sondha|bhor|morning|evening|afternoon|night)\b( e)?'),
    ci(r'(আজকে|আজ|আগামীকাল|গতকাল|পরশু|কাল|সকালে|সকাল|বিকালে|বিকাল|বিকেলে|দুপুরে|দুপুর|রাতে|রাত|সন্ধ্যায়|সন্ধ্যা|ভোরে)(?![ঀ-৿])'),
  ];
  if (intent == 'add_expense' || intent == 'add_receivable' || intent == 'add_payable' || intent == 'settle_ledger') {
    drop.addAll([
      ci('(৳ ?)?$d+(\\.$d+)? ?(k|hajar|hazar|lakh|হাজার|লাখ)? ?(taka|tk|টাকা|/-)?'),
      ci(r'\b(khoroch|kharach|holo|hoise|hoyeche|korlam|dilam|disi|kinlam|kinsi|spent|spend|on|for|e)\b'),
      ci(r'(খরচ|হলো|হয়েছে|করলাম|দিলাম|কিনলাম)(?![ঀ-৿])'),
    ]);
  }
  for (final re in drop) {
    t = t.replaceAll(re, ' ');
  }
  t = t.replaceAll(RegExp(r'\s+'), ' ').trim();
  // Leftover particles at the edges ("e", "te", "-").
  t = t.replaceAll(RegExp(r'^(e|te|ke|-|,)\s+|\s+(e|te|-|,)$', caseSensitive: false), '').trim();
  if (t.isEmpty) t = raw.trim();
  return t.length > 80 ? t.substring(0, 80) : t;
}

// ---------- assistant actions ----------

const _callPattern =
    r'(^|[^a-z])(call|kol|phone|fon|ring)\s*(koro|kor|dao|de|din|diye|daw|kore|dite|lagao)([^a-z]|$)|(^|[^a-z])call\s+[a-z0-9+]|(ফোন|কল)\s*(দাও|করো|কর|দিন|দে|লাগাও)';
const _playPattern =
    r'(gaan|gan|song|songs|music|গান|মিউজিক).{0,40}(bajao|chalao|shunao|play|charo|শোনাও|বাজাও|চালাও|ছাড়ো|ছাড়)|(^|[^a-z])play\s+\S';
const _openPattern = r'(^|[^a-z])(open|kholo|khulo|launch)([^a-z]|$)|খোলো|খুলো|খুলুন|চালু করো';

/// Who to call: "rahim ke call koro" -> Rahim, "call mom" -> Mom,
/// "মাকে ফোন দাও" -> মা, "01712345678 e call koro" -> the number.
String? _callee(String raw, String text) {
  final number = RegExp(r'(\+?\d[\d\s-]{5,}\d)').firstMatch(text);
  if (number != null) return number.group(1)!.replaceAll(RegExp(r'[\s-]'), '');
  final latin = [
    RegExp(r'([a-z]+(?:\s[a-z]+)?)\s+(?:ke|k|re)\s+(?:call|kol|phone|fon|ring)'),
    RegExp(r'(?:call|ring|phone)\s+(?:to\s+)?([a-z]+(?:\s[a-z]+)?)'),
  ];
  const notNames = {'koro', 'kor', 'dao', 'de', 'din', 'diye', 'daw', 'kore', 'dite', 'lagao', 'me', 'please', 'now', 'ekhon', 'ekta', 'akta'};
  for (final re in latin) {
    final m = re.firstMatch(text);
    final name = m?.group(1)?.split(' ').where((w) => !notNames.contains(w)).join(' ');
    if (name != null && name.isNotEmpty) {
      return name.split(' ').map((w) => w[0].toUpperCase() + w.substring(1)).join(' ');
    }
  }
  final bn = RegExp(r'([ঀ-৿]{2,}?)(?:কে|রে)\s*(?:ফোন|কল)').firstMatch(raw);
  return bn?.group(1);
}

/// "arijit singh er gaan bajao" -> "arijit singh"; "play shape of you" -> "shape of you".
String _mediaQuery(String raw) {
  var t = ' ${raw.trim()} ';
  for (final p in [
    r'\b(please|plz|ekta|akta|kichu|ektu)\b',
    r'\b(gaan|gan|song|songs|music)\b',
    r'\b(bajao|chalao|shunao|play|charo|koro|kore|dao|ta|er|r)\b',
    r'(একটা|কিছু|একটু|গান|মিউজিক|বাজাও|চালাও|শোনাও|ছাড়ো|করো|দাও)(?![ঀ-৿])',
    r'(?<=[ঀ-৿])(এর|র|টা)(?![ঀ-৿])',
  ]) {
    t = t.replaceAll(RegExp(p, caseSensitive: false), ' ');
  }
  return t.replaceAll(RegExp(r'\s+'), ' ').trim();
}

/// "youtube kholo" -> "youtube"; "open whatsapp" -> "whatsapp".
String _appName(String raw) {
  var t = ' ${raw.trim()} ';
  for (final p in [
    r'\b(open|kholo|khulo|launch|chalu|koro|app|apps|ta|please)\b',
    r'(খোলো|খুলো|খুলুন|চালু|করো|অ্যাপ|অ্যাপটা)(?![ঀ-৿])',
  ]) {
    t = t.replaceAll(RegExp(p, caseSensitive: false), ' ');
  }
  return t.replaceAll(RegExp(r'\s+'), ' ').trim();
}

/// "10 minute pore" / "in 2 hours" / "১০ মিনিট পরে" / "adha ghonta pore" -> minutes.
int? _relativeMinutes(String text) {
  if (RegExp(r'(adha|half an?) (ghonta|hour)|আধা ঘণ্টা').hasMatch(text)) return 30;
  final m = RegExp(r'(in\s+)?(\d{1,3})\s*(minutes|minute|mins|min|মিনিট|ghonta|hours|hour|hrs|hr|ঘণ্টা)\s*(pore|por|later|পরে|পর)?')
      .firstMatch(text);
  if (m == null || (m.group(1) == null && m.group(4) == null)) return null;
  final n = int.parse(m.group(2)!);
  final minutes = RegExp(r'ghonta|hour|hr|ঘণ্টা').hasMatch(m.group(3)!) ? n * 60 : n;
  return minutes > 0 && minutes <= 7 * 24 * 60 ? minutes : null;
}

bool _looksBanglish(String text) => RegExp(
      r'(^|[^a-z])(ami|amar|amake|taka|kal|aaj|ajke|hobe|korte|dite|khoroch|kinlam|dilam|pabo|mone|koriye|dio|ta|tay|ke|er|kache|sokal|bikal|rat)([^a-z]|$)',
    ).hasMatch(text);
