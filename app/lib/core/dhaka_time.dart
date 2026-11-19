import 'package:intl/intl.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import 'bangla_digits.dart';

/// All date logic in Bolo happens in the Asia/Dhaka time zone, whatever the
/// phone's own time-zone setting is. Records are stored as UTC instants.
class DhakaTime {
  DhakaTime._();

  static tz.Location? _location;

  /// Must be called once at startup (and in tests) before any other method.
  static void ensureInitialized() {
    if (_location != null) return;
    tzdata.initializeTimeZones();
    _location = tz.getLocation('Asia/Dhaka');
  }

  static tz.Location get location {
    ensureInitialized();
    return _location!;
  }

  /// Converts any instant to Dhaka wall-clock time.
  static tz.TZDateTime toDhaka(DateTime instant) => tz.TZDateTime.from(instant, location);

  /// Builds an instant from a Dhaka calendar date and wall-clock time.
  static tz.TZDateTime at(int year, int month, int day, [int hour = 0, int minute = 0]) =>
      tz.TZDateTime(location, year, month, day, hour, minute);

  static tz.TZDateTime startOfDay(DateTime instant) {
    final d = toDhaka(instant);
    return at(d.year, d.month, d.day);
  }

  static tz.TZDateTime endOfDay(DateTime instant) =>
      startOfDay(instant).add(const Duration(days: 1));

  static tz.TZDateTime startOfMonth(DateTime instant) {
    final d = toDhaka(instant);
    return at(d.year, d.month, 1);
  }

  /// "2026-11-20" (a Dhaka calendar date) -> DateTime parts, or null if invalid.
  static ({int year, int month, int day})? parseIsoDate(String? iso) {
    if (iso == null) return null;
    final m = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$').firstMatch(iso);
    if (m == null) return null;
    final y = int.parse(m.group(1)!), mo = int.parse(m.group(2)!), d = int.parse(m.group(3)!);
    final check = DateTime.utc(y, mo, d);
    if (check.year != y || check.month != mo || check.day != d) return null;
    return (year: y, month: mo, day: d);
  }

  /// "17:05" -> (17, 5), or null if invalid.
  static ({int hour, int minute})? parseHm(String? hm) {
    if (hm == null) return null;
    final m = RegExp(r'^(\d{1,2}):(\d{2})$').firstMatch(hm);
    if (m == null) return null;
    final h = int.parse(m.group(1)!), mi = int.parse(m.group(2)!);
    if (h > 23 || mi > 59) return null;
    return (hour: h, minute: mi);
  }

  /// Combines an ISO date and an optional "HH:mm" time into a Dhaka instant.
  static tz.TZDateTime? combine(String? isoDate, String? hm, {int defaultHour = 9}) {
    final d = parseIsoDate(isoDate);
    if (d == null) return null;
    final t = parseHm(hm);
    return at(d.year, d.month, d.day, t?.hour ?? defaultHour, t?.minute ?? 0);
  }

  static String isoDate(DateTime instant) =>
      DateFormat('yyyy-MM-dd').format(toDhaka(instant));

  static String hm(DateTime instant) => DateFormat('HH:mm').format(toDhaka(instant));

  /// "শুক্রবার, ২১ নভেম্বর" / "Friday, 21 November"
  static String formatDate(DateTime instant, String languageCode) {
    final d = toDhaka(instant);
    return localDigits(DateFormat('EEEE, d MMMM', languageCode).format(d), languageCode);
  }

  /// "সকাল ১০:০০" (bn) / "10:00 AM" (en)
  static String formatTime(DateTime instant, String languageCode) {
    final d = toDhaka(instant);
    if (languageCode != 'bn') return DateFormat('h:mm a', 'en').format(d);
    final h12 = d.hour % 12 == 0 ? 12 : d.hour % 12;
    final text = '${banglaDayPart(d.hour)} $h12:${d.minute.toString().padLeft(2, '0')}';
    return toBanglaDigits(text);
  }

  /// The Bangla word for the part of day, used to make times unambiguous.
  static String banglaDayPart(int hour) {
    if (hour >= 4 && hour < 12) return 'সকাল';
    if (hour >= 12 && hour < 15) return 'দুপুর';
    if (hour >= 15 && hour < 18) return 'বিকাল';
    if (hour >= 18 && hour < 20) return 'সন্ধ্যা';
    return 'রাত';
  }

  /// Greeting for the home screen based on Dhaka time.
  static String greetingKey(DateTime now) {
    final h = toDhaka(now).hour;
    if (h >= 4 && h < 12) return 'morning';
    if (h >= 12 && h < 17) return 'afternoon';
    if (h >= 17 && h < 20) return 'evening';
    return 'night';
  }
}
