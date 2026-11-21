import 'package:bolo_app/core/dhaka_time.dart';
import 'package:bolo_app/features/command/command_service.dart';
import 'package:bolo_app/features/command/on_device_parser.dart';
import 'package:bolo_app/features/command/parsed_command.dart';
import 'package:bolo_app/features/records/models.dart';
import 'package:flutter_test/flutter_test.dart';

class _FailingService implements CommandService {
  _FailingService(this.failure);
  final ParseFailure failure;
  @override
  Future<ParsedCommand> parse(String text, {required RecordSource source, required String locale}) =>
      throw ParseException(failure);
}

void main() {
  setUpAll(DhakaTime.ensureInitialized);

  // "Now" = Thursday 2026-11-19, 14:15 in Dhaka.
  final now = DhakaTime.at(2026, 11, 19, 14, 15);
  Map<String, dynamic> p(String s) => parseOnDevice(s, now);

  group('parseOnDevice', () {
    test('Banglish reminder with tomorrow + morning time', () {
      final r = p('kal sokal 10 tay rent dite hobe mone koriye dio');
      expect(r['intent'], 'create_reminder');
      expect(r['date'], '2026-11-20');
      expect(r['time'], '10:00');
      expect(r['ambiguity'], 'none');
      expect(r['amount'], isNull);
      expect((r['title'] as String).toLowerCase(), isNot(contains('mone koriye')));
    });

    test('expense with amount and food category', () {
      final r = p('aaj lunch e 350 taka khoroch holo');
      expect(r['intent'], 'add_expense');
      expect(r['amount'], 350);
      expect(r['category'], 'food');
      expect(r['date'], '2026-11-19');
    });

    test('Bangla digits and Bangla text', () {
      final r = p('রিকশা ভাড়া ৮০ টাকা খরচ');
      expect(r['intent'], 'add_expense');
      expect(r['amount'], 80);
      expect(r['category'], 'transport');
      expect(r['language'], 'bn');
    });

    test('"kal" for money already spent means yesterday', () {
      final r = p('kal 200 taka bazar khoroch holo');
      expect(r['intent'], 'add_expense');
      expect(r['date'], '2026-11-18');
    });

    test('payable with person, multiplier and AM/PM ambiguity', () {
      final r = p('rahim ke kal 5 tay 2k dite hobe');
      expect(r['intent'], 'add_payable');
      expect(r['amount'], 2000);
      expect(r['person'], 'Rahim');
      expect(r['time'], '17:00');
      expect(r['ambiguity'], 'am_pm');
      expect(r['alternatives'], [
        {'date': '2026-11-20', 'time': '05:00'},
      ]);
    });

    test('a clock time is never read as the amount', () {
      final r = p('karim amake 500 taka dibe 3 tay');
      expect(r['intent'], 'add_receivable');
      expect(r['amount'], 500);
      expect(r['person'], 'Karim');
    });

    test('Bangla person + hajar multiplier', () {
      final r = p('রহিমকে ৫ হাজার টাকা ধার দিলাম');
      expect(r['intent'], 'add_receivable');
      expect(r['amount'], 5000);
      expect(r['person'], 'রহিম');
    });

    test('বিকাল is not read as কাল (tomorrow)', () {
      final r = p('আজ বিকাল ৪টায় মিটিং মনে করিয়ে দিও');
      expect(r['intent'], 'create_reminder');
      expect(r['date'], '2026-11-19');
      expect(r['time'], '16:00');
    });

    test('task with deadline', () {
      final r = p('porshu assignment submit korte hobe');
      expect(r['intent'], 'create_task');
      expect(r['date'], '2026-11-21');
    });

    test('reminder without a time today gets one hour from now', () {
      final r = p('remind me to call ammu');
      expect(r['intent'], 'create_reminder');
      expect(r['date'], '2026-11-19');
      expect(r['time'], '15:00');
    });

    test('daily repeat', () {
      expect(p('roj rat 10 tay oshudh khete mone koriye dio')['repeat'], 'daily');
      expect(p('roj rat 10 tay oshudh khete mone koriye dio')['time'], '22:00');
    });

    test('small talk stays unknown with low confidence', () {
      final r = p('hello kemon acho');
      expect(r['intent'], 'unknown');
      expect(r['confidence'], lessThan(0.5));
    });

    test('output always parses into a ParsedCommand', () {
      for (final s in ['', '???', '১২৩', 'pay 1e99 taka', '99:99 tay']) {
        final c = ParsedCommand.fromServer(p(s), transcript: s, source: RecordSource.text);
        expect(c.intent, isA<CommandIntent>());
      }
    });
  });

  group('FallbackCommandService', () {
    test('uses the on-device parser when the server fails', () async {
      final svc = FallbackCommandService(_FailingService(ParseFailure.server), clock: () => now);
      final c = await svc.parse('aaj lunch 120 taka khoroch', source: RecordSource.text, locale: 'bn');
      expect(c.intent, CommandIntent.addExpense);
      expect(c.amountPoisha, 12000);
      expect(c.onDevice, isTrue);
      expect(c.needsAttention, isTrue, reason: 'on-device results are never fully trusted');
    });

    test('keeps offline/quota errors for the normal handling', () async {
      for (final f in [ParseFailure.offline, ParseFailure.quotaExceeded, ParseFailure.tooLong, ParseFailure.notSignedIn]) {
        final svc = FallbackCommandService(_FailingService(f), clock: () => now);
        expect(
          () => svc.parse('aaj lunch 120 taka', source: RecordSource.text, locale: 'bn'),
          throwsA(isA<ParseException>().having((e) => e.failure, 'failure', f)),
        );
      }
    });
  });
}
