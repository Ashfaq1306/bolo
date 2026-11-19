import 'package:bolo_app/core/bangla_digits.dart';
import 'package:bolo_app/core/dhaka_time.dart';
import 'package:bolo_app/core/money.dart';
import 'package:bolo_app/features/records/models.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  setUpAll(() async {
    DhakaTime.ensureInitialized();
    await initializeDateFormatting('bn');
    await initializeDateFormatting('en');
  });

  group('Bangla digits', () {
    test('round trip', () {
      expect(toAsciiDigits('৫০০ টাকা'), '500 টাকা');
      expect(toBanglaDigits('1,250'), '১,২৫০');
      expect(toAsciiDigits(toBanglaDigits('0123456789')), '0123456789');
    });
  });

  group('Money', () {
    test('parses typed amounts in both scripts', () {
      expect(Money.tryParsePoisha('350'), 35000);
      expect(Money.tryParsePoisha('৩৫০'), 35000);
      expect(Money.tryParsePoisha('1,200.50'), 120050);
      expect(Money.tryParsePoisha('৳ 99'), 9900);
    });

    test('rejects invalid amounts', () {
      expect(Money.tryParsePoisha(''), isNull);
      expect(Money.tryParsePoisha('-5'), isNull);
      expect(Money.tryParsePoisha('0'), isNull);
      expect(Money.tryParsePoisha('abc'), isNull);
      expect(Money.tryParsePoisha('99999999999'), isNull); // above max
    });

    test('integer sums are exact (the reason we use poisha)', () {
      final sum = [10, 20].map((t) => Money.poishaFromTaka(t / 100)).reduce((a, b) => a + b);
      expect(sum, 30); // 0.10 + 0.20 taka == 30 poisha exactly
    });

    test('formats with lakh grouping', () {
      expect(Money.format(12345678, languageCode: 'en'), '৳1,23,456.78');
      expect(Money.format(10000000000, languageCode: 'en'), '৳10,00,00,000');
      expect(Money.format(35000, languageCode: 'bn'), '৳৩৫০');
      expect(Money.format(99, languageCode: 'en'), '৳0.99');
    });
  });

  group('DhakaTime', () {
    test('Dhaka is UTC+6', () {
      final instant = DhakaTime.at(2026, 11, 20, 10, 0);
      expect(instant.toUtc(), DateTime.utc(2026, 11, 20, 4, 0));
    });

    test('start of day uses the Dhaka date, not UTC', () {
      // 2026-11-19 20:30 UTC is already 2026-11-20 02:30 in Dhaka.
      final utc = DateTime.utc(2026, 11, 19, 20, 30);
      expect(DhakaTime.isoDate(utc), '2026-11-20');
      expect(DhakaTime.startOfDay(utc).toUtc(), DateTime.utc(2026, 11, 19, 18, 0));
    });

    test('combine validates input', () {
      expect(DhakaTime.combine('2026-02-30', '10:00'), isNull); // no Feb 30
      expect(DhakaTime.combine('2026-11-20', '25:00')!.hour, 9); // bad time -> default hour
      expect(DhakaTime.combine('2026-11-20', '17:05')!.minute, 5);
      expect(DhakaTime.combine(null, '10:00'), isNull);
    });

    test('Bangla time format uses day-part words', () {
      expect(DhakaTime.formatTime(DhakaTime.at(2026, 11, 20, 17, 0), 'bn'), 'বিকাল ৫:০০');
      expect(DhakaTime.formatTime(DhakaTime.at(2026, 11, 20, 5, 0), 'bn'), 'সকাল ৫:০০');
      expect(DhakaTime.formatTime(DhakaTime.at(2026, 11, 20, 21, 30), 'bn'), 'রাত ৯:৩০');
    });
  });

  test('notification ids are stable and positive', () {
    expect(notificationIdFor('abc'), notificationIdFor('abc'));
    expect(notificationIdFor('abc'), isNot(notificationIdFor('abd')));
    expect(notificationIdFor('xyz'), greaterThanOrEqualTo(0));
    expect(notificationIdFor('a' * 40), lessThan(0x80000000));
  });
}
