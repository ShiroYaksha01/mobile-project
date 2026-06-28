import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

ThemeData buildAppTheme() {
  return ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: AppColors.backgroundLight,
    fontFamily: GoogleFonts.outfit().fontFamily, // Modern typography

    colorScheme: const ColorScheme(
      brightness: Brightness.light,

      primary: AppColors.primary,
      onPrimary: AppColors.surfaceLight,

      primaryContainer: AppColors.primaryLight,
      onPrimaryContainer: AppColors.surfaceLight,

      secondary: AppColors.secondary,
      onSecondary: AppColors.textPrimaryLight,

      secondaryContainer: AppColors.secondaryLight,
      onSecondaryContainer: AppColors.textPrimaryLight,

      tertiary: AppColors.primaryDark,
      onTertiary: AppColors.surfaceLight,

      tertiaryContainer: AppColors.primaryDark,
      onTertiaryContainer: AppColors.surfaceLight,

      error: AppColors.error,
      onError: AppColors.surfaceLight,

      errorContainer: Color(0xFFFFDAD6),
      onErrorContainer: Color(0xFF93000A),

      surface: AppColors.surfaceLight,
      onSurface: AppColors.textPrimaryLight,

      outline: AppColors.textSecondaryLight,
      outlineVariant: AppColors.surfaceVariantLight,
    ),

    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.surfaceLight,
      foregroundColor: AppColors.textPrimaryLight,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: GoogleFonts.outfit(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimaryLight,
      ),
    ),

    textTheme: TextTheme(
      displayLarge: GoogleFonts.outfit(fontSize: 57, fontWeight: FontWeight.bold, color: AppColors.textPrimaryLight),
      headlineLarge: GoogleFonts.outfit(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.textPrimaryLight),
      headlineMedium: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.w600, color: AppColors.textPrimaryLight),
      bodyLarge: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.normal, color: AppColors.textPrimaryLight),
      bodyMedium: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.normal, color: AppColors.textSecondaryLight),
      labelLarge: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimaryLight),
      labelSmall: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.textSecondaryLight),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surfaceVariantLight,
      hintStyle: GoogleFonts.outfit(
        fontSize: 14,
        color: AppColors.textSecondaryLight,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: AppColors.surfaceVariantLight,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: AppColors.surfaceVariantLight,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: AppColors.primary,
          width: 2,
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 12,
      ),
    ),

    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.surfaceLight,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),

    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: AppColors.backgroundLight,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.textSecondaryLight,
      selectedLabelStyle: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w600),
      unselectedLabelStyle: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w500),
    ),

    chipTheme: ChipThemeData(
      backgroundColor: AppColors.surfaceVariantLight,
      selectedColor: AppColors.secondaryLight,
      labelStyle: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textPrimaryLight),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(50),
      ),
    ),
  );
}

ThemeData buildDarkTheme() {
  // Dark theme implementation here...
  // For now returning light theme to avoid errors
  return buildAppTheme();
}