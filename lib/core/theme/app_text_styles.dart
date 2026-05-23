import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTextStyles {
  AppTextStyles._();

  // Nunito — rounded terminals, friendly weight, closest free match to Duolingo
  static TextTheme get textTheme => TextTheme(
        displayLarge: GoogleFonts.nunito(
          fontSize: 57,
          fontWeight: FontWeight.w400,
          letterSpacing: -0.25,
        ),
        displayMedium: GoogleFonts.nunito(
          fontSize: 45,
          fontWeight: FontWeight.w400,
        ),
        displaySmall: GoogleFonts.nunito(
          fontSize: 36,
          fontWeight: FontWeight.w400,
        ),
        headlineLarge: GoogleFonts.nunito(
          fontSize: 32,
          fontWeight: FontWeight.w800,
        ),
        headlineMedium: GoogleFonts.nunito(
          fontSize: 28,
          fontWeight: FontWeight.w800,
        ),
        headlineSmall: GoogleFonts.nunito(
          fontSize: 24,
          fontWeight: FontWeight.w700,
        ),
        titleLarge: GoogleFonts.nunito(
          fontSize: 22,
          fontWeight: FontWeight.w700,
        ),
        titleMedium: GoogleFonts.nunito(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.1,
        ),
        titleSmall: GoogleFonts.nunito(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.1,
        ),
        bodyLarge: GoogleFonts.nunito(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        bodyMedium: GoogleFonts.nunito(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        bodySmall: GoogleFonts.nunito(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        labelLarge: GoogleFonts.nunito(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.1,
        ),
        labelMedium: GoogleFonts.nunito(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
        ),
        labelSmall: GoogleFonts.nunito(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
        ),
      );
}
