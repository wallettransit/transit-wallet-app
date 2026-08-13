import 'package:flutter/material.dart';

class AppTheme {
  // Primitive Colors (Light Theme overrides for legacy components)
  static const Color ink = Color(0xFFFFFFFF); // Was Dark, now White background
  static const Color asphalt = Color(0xFFF9F9F8); // Light grey cards
  static const Color asphalt2 = Color(0xFFF0F2F1); // Lighter grey
  static const Color asphalt3 = Color(0xFFE0E5E2); // Grey borders
  
  static const Color danfoYellow = Color(0xFFF5B300);
  static const Color danfoYellowDim = Color(0xFFC28E00);
  static const Color danfoYellowGlow = Color(0x33F5B300); // 20% opacity

  static const Color kekeGreen = Color(0xFF00A86B);
  static const Color kekeGreenGlow = Color(0x3300A86B); // 20% opacity
  
  static const Color okGreen = Color(0xFF22C55E);
  static const Color warnRust = Color(0xFFEF4444);
  static const Color errorRed = Color(0xFFFF4D4D);
  
  static const Color paper = Color(0xFF0A0A0B); // Was White, now Dark text
  static const Color muted = Color(0xFF6B7A73); // Muted dark grey
  static const Color line = Color(0xFFE0E5E2); // Light grey lines

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: ink,
      primaryColor: danfoYellow,
      fontFamily: 'Inter',
      colorScheme: const ColorScheme.light(
        primary: danfoYellow,
        secondary: kekeGreen,
        surface: asphalt,
        error: warnRust,
        onPrimary: ink,
        onSecondary: paper,
        onSurface: paper,
        onError: paper,
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(fontFamily: 'Outfit', fontSize: 64, fontWeight: FontWeight.bold, color: paper),
        displayMedium: TextStyle(fontFamily: 'Outfit', fontSize: 48, fontWeight: FontWeight.bold, color: paper),
        displaySmall: TextStyle(fontFamily: 'Outfit', fontSize: 32, fontWeight: FontWeight.bold, color: paper),
        headlineMedium: TextStyle(fontFamily: 'Outfit', fontSize: 24, fontWeight: FontWeight.w600, color: paper),
        titleLarge: TextStyle(fontFamily: 'Outfit', fontSize: 18, fontWeight: FontWeight.w600, color: paper),
        bodyLarge: TextStyle(fontFamily: 'Inter', fontSize: 16, color: paper),
        bodyMedium: TextStyle(fontFamily: 'Inter', fontSize: 14, color: paper),
        labelLarge: TextStyle(fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w600, color: paper),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: danfoYellow,
          foregroundColor: ink,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'Inter'),
        ),
      ),
    );
  }
}
