import 'package:flutter/material.dart';

/// "Night sky" palette. Replace with the designer's brand palette (docs/11 Q5).
class BoloColors {
  static const night = Color(0xFF0A0F24);
  static const nightSurface = Color(0xFF141A38);
  static const nightSurfaceHigh = Color(0xFF1D2550);
  static const teal = Color(0xFF2DD4BF);
  static const violet = Color(0xFF8B5CF6);
  static const pink = Color(0xFFF472B6);
  static const amber = Color(0xFFFBBF24);

  /// Money direction colours. Always paired with an icon and a label,
  /// never colour alone (accessibility).
  static const receive = Color(0xFF34D399);
  static const pay = Color(0xFFFB7185);
}

class BoloTheme {
  static const fontFamily = 'HindSiliguri';

  static ThemeData dark() {
    final scheme = ColorScheme.fromSeed(
      seedColor: BoloColors.violet,
      brightness: Brightness.dark,
      primary: BoloColors.teal,
      secondary: BoloColors.violet,
      surface: BoloColors.nightSurface,
    );
    return _base(scheme).copyWith(scaffoldBackgroundColor: BoloColors.night);
  }

  static ThemeData light() {
    final scheme = ColorScheme.fromSeed(
      seedColor: BoloColors.violet,
      brightness: Brightness.light,
      primary: const Color(0xFF0F766E),
      secondary: BoloColors.violet,
    );
    return _base(scheme);
  }

  static ThemeData _base(ColorScheme scheme) => ThemeData(
        useMaterial3: true,
        colorScheme: scheme,
        fontFamily: fontFamily,
        // Bangla script needs a little extra line height to avoid clipping.
        // Text colours must follow the brightness (white text on dark theme).
        textTheme: (scheme.brightness == Brightness.dark
                ? Typography.material2021().white
                : Typography.material2021().black)
            .apply(fontFamily: fontFamily)
            .merge(const TextTheme(bodyMedium: TextStyle(height: 1.45), bodyLarge: TextStyle(height: 1.45))),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            minimumSize: const Size(64, 52),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            textStyle: const TextStyle(fontFamily: fontFamily, fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(64, 52),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
        ),
        chipTheme: const ChipThemeData(labelStyle: TextStyle(fontFamily: fontFamily)),
      );
}
