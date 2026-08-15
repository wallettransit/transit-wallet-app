import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTypography {
  // Headings (Outfit)
  static TextStyle heading1 = GoogleFonts.outfit(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    height: 1.2,
    color: AppColors.paper,
  );

  static TextStyle heading2 = GoogleFonts.outfit(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    height: 1.2,
    color: AppColors.paper,
  );

  static TextStyle heading3 = GoogleFonts.outfit(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    height: 1.2,
    color: AppColors.paper,
  );

  // Body text (Manrope)
  static TextStyle bodyLarge = GoogleFonts.manrope(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.4,
    color: AppColors.paper,
  );

  static TextStyle bodyMedium = GoogleFonts.manrope(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.4,
    color: AppColors.paper,
  );

  static TextStyle bodySmall = GoogleFonts.manrope(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    height: 1.4,
    color: AppColors.muted,
  );

  static TextStyle label = GoogleFonts.manrope(
    fontSize: 10,
    fontWeight: FontWeight.w700,
    height: 1.4,
    color: AppColors.paper,
  );

  static TextStyle numericLarge = GoogleFonts.manrope(
    fontSize: 28,
    fontWeight: FontWeight.w800,
    height: 1.2,
    color: AppColors.paper,
  );
}
