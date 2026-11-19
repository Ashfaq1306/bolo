import '../../core/bangla_digits.dart';
import '../../core/money.dart';
import '../records/models.dart';

/// What we could read from a receipt photo. Everything is a *guess*: the
/// result always opens the confirmation card for the user to check.
class ReceiptGuess {
  const ReceiptGuess({this.amountPoisha, this.merchant, this.category = ExpenseCategory.other});
  final int? amountPoisha;
  final String? merchant;
  final ExpenseCategory category;
}

final _number = RegExp(r'(\d{1,3}(?:,\d{2,3})+|\d+)(?:\.(\d{1,2}))?');
final _strongTotal = RegExp(r'grand\s*total|net\s*total|net\s*payable|total\s*payable|amount\s*due|total\s*amount|সর্বমোট|মোট\s*টাকা|নিট', caseSensitive: false);
final _total = RegExp(r'\btotal\b|payable|মোট', caseSensitive: false);
final _notTotal = RegExp(r'sub\s*-?\s*total|discount|vat|tax|change|cash|paid|qty|quantity', caseSensitive: false);
final _notMerchant = RegExp(r'invoice|receipt|bill\s*no|date|time|tel|phone|mobile|vat|bin|www|@|cashier|table', caseSensitive: false);

/// Parses OCR text from a receipt. Pure function, so it is easy to unit-test.
///
/// Strategy (in order):
/// 1. The number on a "Grand total / Net payable / সর্বমোট" line.
/// 2. Otherwise the number on a plain "Total / মোট" line (not "Sub total").
/// 3. Otherwise the largest plausible amount on the receipt.
ReceiptGuess parseReceipt(String rawText) {
  final lines = toAsciiDigits(rawText)
      .split('\n')
      .map((l) => l.trim())
      .where((l) => l.isNotEmpty)
      .toList();

  int? amountOn(String line) {
    final matches = _number.allMatches(line).toList();
    if (matches.isEmpty) return null;
    final m = matches.last; // totals are usually right-aligned
    return _toPoisha(m);
  }

  int? amount;
  for (final pattern in [_strongTotal, _total]) {
    for (final line in lines.reversed) {
      if (pattern.hasMatch(line) && !(pattern == _total && _notTotal.hasMatch(line))) {
        amount = amountOn(line);
        if (amount != null) break;
      }
    }
    if (amount != null) break;
  }

  amount ??= () {
    int? best;
    for (final line in lines) {
      if (_notTotal.hasMatch(line)) continue;
      for (final m in _number.allMatches(line)) {
        final p = _toPoisha(m);
        if (p != null && (best == null || p > best)) best = p;
      }
    }
    return best;
  }();

  final merchant = lines
      .take(5)
      .firstWhere(
        (l) => RegExp(r'[A-Za-zঀ-৿]{3,}').hasMatch(l) && l.length <= 40 && !_notMerchant.hasMatch(l),
        orElse: () => '',
      );

  return ReceiptGuess(
    amountPoisha: amount,
    merchant: merchant.isEmpty ? null : merchant,
    category: guessCategory(rawText),
  );
}

int? _toPoisha(RegExpMatch m) {
  final whole = m.group(1)!.replaceAll(',', '');
  // Long digit runs are phone numbers, BINs or invoice numbers, not prices.
  if (whole.length > 7) return null;
  final frac = m.group(2);
  final taka = num.parse(frac == null ? whole : '$whole.$frac');
  final poisha = Money.poishaFromTaka(taka);
  // Ignore tiny numbers (quantities, line numbers) and implausible amounts.
  if (poisha < 1000 || poisha > 1000000000) return null;
  return poisha;
}

ExpenseCategory guessCategory(String text) {
  final t = text.toLowerCase();
  bool any(List<String> words) => words.any(t.contains);
  if (any(['pharma', 'medicine', 'hospital', 'clinic', 'diagnostic', 'ঔষধ', 'ফার্মেসি'])) return ExpenseCategory.health;
  if (any(['restaurant', 'cafe', 'coffee', 'food', 'kitchen', 'biryani', 'pizza', 'burger', 'bakery', 'রেস্টুরেন্ট', 'খাবার'])) return ExpenseCategory.food;
  if (any(['uber', 'pathao', 'fuel', 'petrol', 'octane', 'cng', 'bus', 'railway', 'ticket'])) return ExpenseCategory.transport;
  if (any(['desco', 'dpdc', 'electric', 'wasa', 'titas', 'gas', 'internet', 'broadband', 'বিদ্যুৎ'])) return ExpenseCategory.bills;
  if (any(['book', 'library', 'tuition', 'school', 'college', 'university'])) return ExpenseCategory.education;
  if (any(['grameenphone', 'robi', 'banglalink', 'teletalk', 'airtel', 'recharge'])) return ExpenseCategory.mobileRecharge;
  if (any(['mart', 'shop', 'store', 'bazar', 'super', 'fashion', 'mall'])) return ExpenseCategory.shopping;
  return ExpenseCategory.other;
}
