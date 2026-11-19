import 'package:bolo_app/core/dhaka_time.dart';
import 'package:bolo_app/features/command/parsed_command.dart';
import 'package:bolo_app/features/command/spoken_summary.dart';
import 'package:bolo_app/features/receipt/receipt_parser.dart';
import 'package:bolo_app/features/records/models.dart';
import 'package:bolo_app/features/voice/orb_face.dart';
import 'package:bolo_app/features/voice/voice_orb.dart';
import 'package:bolo_app/l10n/app_localizations_bn.dart';
import 'package:bolo_app/l10n/app_localizations_en.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  setUpAll(() async {
    DhakaTime.ensureInitialized();
    await initializeDateFormatting('bn');
    await initializeDateFormatting('en');
  });

  group('receipt parser', () {
    test('restaurant receipt: prefers Grand Total over Sub Total', () {
      const text = '''
Kacchi Bhai Restaurant
Dhanmondi 27, Dhaka
Tel: 01712345678
Invoice No: 000123456
Kacchi Basmati x2   780.00
Borhani x2          160.00
Sub Total           940.00
VAT 5%               47.00
Grand Total         987.00
Cash               1000.00
Change               13.00''';
      final g = parseReceipt(text);
      expect(g.amountPoisha, 98700);
      expect(g.merchant, 'Kacchi Bhai Restaurant');
      expect(g.category, ExpenseCategory.food);
    });

    test('pharmacy receipt with Bangla digits and মোট', () {
      const text = 'Lazz Pharma\nNapa Extra  ৪০.০০\nSeclo 20  ১২০.০০\nমোট ১৬০.০০';
      final g = parseReceipt(text);
      expect(g.amountPoisha, 16000);
      expect(g.category, ExpenseCategory.health);
    });

    test('ignores phone and invoice numbers when guessing the largest amount', () {
      const text = 'Shwapno Super Shop\n01811223344\nRice 5kg 450\nOil 1L 185\n';
      final g = parseReceipt(text);
      expect(g.amountPoisha, 45000);
      expect(g.category, ExpenseCategory.shopping);
    });

    test('comma thousands', () {
      expect(parseReceipt('Star Tech\nNet Payable 12,500.00').amountPoisha, 1250000);
    });

    test('nothing readable', () {
      expect(parseReceipt('Thank you!').amountPoisha, isNull);
    });
  });

  group('spoken summary', () {
    test('Bangla expense', () {
      const c = ParsedCommand(intent: CommandIntent.addExpense, amountPoisha: 35000, category: ExpenseCategory.food);
      expect(spokenSummary(c, AppLocalizationsBn(), 'bn'), 'খাবার-এ ৩৫০ টাকা খরচ। সেভ করব?');
    });

    test('asks the clarifying question first', () {
      const c = ParsedCommand(
        intent: CommandIntent.createReminder,
        title: 'meeting',
        date: '2026-11-20',
        time: '17:00',
        clarification: 'সকাল ৫টা নাকি বিকাল ৫টা?',
      );
      final text = spokenSummary(c, AppLocalizationsBn(), 'bn');
      expect(text, startsWith('সকাল ৫টা নাকি বিকাল ৫টা?'));
      expect(text, contains('বিকাল ৫:০০'));
    });

    test('English payable', () {
      const c = ParsedCommand(intent: CommandIntent.addPayable, person: 'Rafi', amountPoisha: 75000);
      expect(spokenSummary(c, AppLocalizationsEn(), 'en'), 'You will give Rafi 750 taka. Please confirm.');
    });
  });

  group('face expressions', () {
    test('listening mouth follows the voice level', () {
      final quiet = FaceParams.target(FaceExpression.listening, 0, 0, null);
      final loud = FaceParams.target(FaceExpression.listening, 0, 1, null);
      expect(loud.mouthOpen, greaterThan(quiet.mouthOpen));
    });

    test('happy smiles with ^ ^ eyes; confused frowns', () {
      final happy = FaceParams.target(FaceExpression.happy, 0, 0, null);
      final confused = FaceParams.target(FaceExpression.confused, 0, 0, null);
      expect(happy.smile, 1);
      expect(happy.happyEyes, 1);
      expect(confused.smile, lessThan(0));
    });

    test('eyes look where the finger is', () {
      final f = FaceParams.target(FaceExpression.idle, 0, 0, const Offset(0.8, -0.5));
      expect(f.gazeX, 0.8);
      expect(f.gazeY, -0.5);
    });

    test('lerp moves toward the target', () {
      const a = FaceParams(smile: 0);
      const b = FaceParams(smile: 1);
      expect(a.lerpTo(b, 0.5).smile, 0.5);
    });
  });

  testWidgets('VoiceOrb renders with a face and is an accessible button', (tester) async {
    var taps = 0;
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Center(
          child: VoiceOrb(
            expression: FaceExpression.happy,
            level: 0,
            semanticLabel: 'Voice input',
            onTap: () => taps++,
          ),
        ),
      ),
    ));
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.bySemanticsLabel('Voice input'), findsOneWidget);
    expect(find.byWidgetPredicate((w) => w is CustomPaint && w.painter is FacePainter), findsOneWidget);
    await tester.tap(find.byType(VoiceOrb));
    expect(taps, 1);
  });
}
