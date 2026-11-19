import 'bangla_digits.dart';

/// Money helpers. Bolo stores money as an **integer number of poisha**
/// (৳1 = 100 poisha) so that sums are exact. Never use `double` for money.
class Money {
  Money._();

  /// Largest amount we accept anywhere: ৳1,000,000,000 (100 crore).
  static const int maxPoisha = 100000000000;

  /// Amounts above this need a second confirmation (৳10 lakh).
  static const int largeAmountPoisha = 100000000;

  /// ৳350.5 -> 35050. Rounds to the nearest poisha.
  static int poishaFromTaka(num taka) => (taka * 100).round();

  /// Parses user-typed text such as "1,200", "১২০০", "350.50".
  /// Returns null when the text is not a valid positive amount.
  static int? tryParsePoisha(String text) {
    final cleaned = toAsciiDigits(text).replaceAll(',', '').replaceAll('৳', '').trim();
    if (cleaned.isEmpty) return null;
    final value = num.tryParse(cleaned);
    if (value == null || value <= 0) return null;
    final poisha = poishaFromTaka(value);
    if (poisha <= 0 || poisha > maxPoisha) return null;
    return poisha;
  }

  static bool isValid(int poisha) => poisha > 0 && poisha <= maxPoisha;

  /// Formats with South Asian grouping: 12345678 poisha -> "৳১,২৩,৪৫৬.৭৮" (bn)
  /// or "৳1,23,456.78" (en). Whole-taka amounts omit the decimals.
  static String format(int poisha, {String languageCode = 'bn'}) {
    final negative = poisha < 0;
    final abs = poisha.abs();
    final taka = abs ~/ 100;
    final rest = abs % 100;
    var text = _groupIndian(taka.toString());
    if (rest != 0) text = '$text.${rest.toString().padLeft(2, '0')}';
    text = '${negative ? '-' : ''}৳$text';
    return localDigits(text, languageCode);
  }

  /// "12345678" -> "1,23,45,678" (lakh/crore grouping used in Bangladesh).
  static String _groupIndian(String digits) {
    if (digits.length <= 3) return digits;
    final last3 = digits.substring(digits.length - 3);
    var rest = digits.substring(0, digits.length - 3);
    final parts = <String>[];
    while (rest.length > 2) {
      parts.insert(0, rest.substring(rest.length - 2));
      rest = rest.substring(0, rest.length - 2);
    }
    if (rest.isNotEmpty) parts.insert(0, rest);
    return '${parts.join(',')},$last3';
  }
}
