import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTypography {
  // Headings (Outfit)
  static TextStyle heading1 = GoogleFonts.outfit(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    height: 35.3 / 28,
    color: AppColors.paper,
  );

  static TextStyle heading2 = GoogleFonts.outfit(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    height: 30.2 / 24,
    color: AppColors.paper,
  );

  static TextStyle heading3 = GoogleFonts.outfit(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 25.2 / 20,
    color: AppColors.paper,
  );

  // Body text (Manrope)
  static TextStyle bodyLarge = GoogleFonts.manrope(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 24.0 / 16,
    color: AppColors.paper,
  );

  static TextStyle bodyMedium = GoogleFonts.manrope(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 21.0 / 14,
    color: AppColors.paper,
  );

  static TextStyle bodySmall = GoogleFonts.manrope(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    height: 19.5 / 13,
    color: AppColors.muted,
  );

  static TextStyle label = GoogleFonts.manrope(
    fontSize: 12,
    fontWeight: FontWeight.w700,
    height: 18.0 / 12,
    color: AppColors.paper,
  );

  static TextStyle numericLarge = GoogleFonts.manrope(
    fontSize: 36,
    fontWeight: FontWeight.w800,
    height: 49.2 / 36,
    color: AppColors.paper,
  );
}
