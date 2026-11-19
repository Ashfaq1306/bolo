/// Conversion between Bangla digits (০-৯) and ASCII digits (0-9).
///
/// Speech recognizers may return either script, so all parsing code
/// normalises to ASCII first, and the UI converts back for display.
library;

const _bangla = ['০', '১', '২', '৩', '৪', '৫', '৬', '৭', '৮', '৯'];

/// "৫০০ টাকা" -> "500 টাকা"
String toAsciiDigits(String input) {
  final buffer = StringBuffer();
  for (final rune in input.runes) {
    final ch = String.fromCharCode(rune);
    final index = _bangla.indexOf(ch);
    buffer.write(index >= 0 ? index.toString() : ch);
  }
  return buffer.toString();
}

/// "500" -> "৫০০"
String toBanglaDigits(String input) {
  final buffer = StringBuffer();
  for (final unit in input.codeUnits) {
    if (unit >= 0x30 && unit <= 0x39) {
      buffer.write(_bangla[unit - 0x30]);
    } else {
      buffer.writeCharCode(unit);
    }
  }
  return buffer.toString();
}

/// Returns digits in the script that matches the UI language.
String localDigits(String input, String languageCode) =>
    languageCode == 'bn' ? toBanglaDigits(input) : input;
