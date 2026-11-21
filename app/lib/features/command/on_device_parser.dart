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
    'title': _title(raw, intent),
    'amount': intent == 'create_reminder' || intent == 'create_task' || intent == 'query_summary' ? null : amount,
    'person': _person(raw, text),
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

String _title(String raw, String intent) {
  var t = raw.trim().replaceAll(RegExp(r'\s+'), ' ');
  if (intent == 'create_reminder') {
    // Drop the "remind me" part so the title reads like the thing to do.
    t = t.replaceAll(RegExp(r'\b(mone koriye dio|mone koriye dao|mone koro|remind me( to)?|reminder)\b', caseSensitive: false), '');
    t = t.replaceAll(RegExp(r'মনে করিয়ে দিও|মনে করিয়ে দাও|মনে করিয়ে দিবে|মনে কর(ো|িও)?'), '');
  }
  t = t.trim();
  return t.length > 80 ? t.substring(0, 80) : t;
}

bool _looksBanglish(String text) => RegExp(
      r'(^|[^a-z])(ami|amar|amake|taka|kal|aaj|ajke|hobe|korte|dite|khoroch|kinlam|dilam|pabo|mone|koriye|dio|ta|tay|ke|er|kache|sokal|bikal|rat)([^a-z]|$)',
    ).hasMatch(text);
