import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';
import 'app_text_styles.dart';

ThemeData buildAppTheme() {
  return ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: HColors.background,
    fontFamily: 'BeVietnamPro',

    colorScheme: const ColorScheme(
      brightness: Brightness.light,

      primary: HColors.primary,
      onPrimary: HColors.onPrimary,

      primaryContainer: HColors.primaryContainer,
      onPrimaryContainer: HColors.onPrimaryContainer,

      secondary: HColors.secondary,
      onSecondary: HColors.onSecondary,

      secondaryContainer: HColors.secondaryContainer,
      onSecondaryContainer: HColors.onSecondaryContainer,

      tertiary: HColors.tertiary,
      onTertiary: HColors.onTertiary,

      tertiaryContainer: HColors.tertiaryContainer,
      onTertiaryContainer: HColors.onTertiaryContainer,

      error: Color(0xFFBA1A1A),
      onError: Colors.white,

      errorContainer: Color(0xFFFFDAD6),
      onErrorContainer: Color(0xFF93000A),

      surface: HColors.surface,
      onSurface: HColors.onSurface,

      outline: HColors.outline,
      outlineVariant: HColors.outlineVariant,
    ),

    appBarTheme: AppBarTheme(
      backgroundColor: HColors.surface,
      foregroundColor: HColors.onSurface,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: HText.headlineMd,
    ),

    textTheme: TextTheme(
      displayLarge: HText.displayLg,
      headlineLarge: HText.headlineLg,
      headlineMedium: HText.headlineMd,
      bodyLarge: HText.bodyLg,
      bodyMedium: HText.bodyMd,
      labelLarge: HText.labelLg,
      labelSmall: HText.labelSm,
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: HColors.surfaceContainerLowest,
      hintStyle: HText.bodyMd.copyWith(
        color: HColors.onSurfaceVariant,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: HColors.outlineVariant,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: HColors.outlineVariant,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: HColors.primary,
          width: 2,
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 12,
      ),
    ),

    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: HColors.primary,
      foregroundColor: HColors.onPrimary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),

    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: HColors.background,
      selectedItemColor: HColors.primary,
      unselectedItemColor: HColors.onSurfaceVariant,
      selectedLabelStyle: HText.labelSm,
      unselectedLabelStyle: HText.labelSm,
    ),

    chipTheme: ChipThemeData(
      backgroundColor: HColors.surfaceContainerHighest,
      selectedColor: HColors.secondary,
      labelStyle: HText.labelLg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(50),
      ),
    ),

    tabBarTheme: TabBarThemeData(
      labelStyle: HText.labelLg,
      unselectedLabelStyle: HText.labelLg.copyWith(
        color: HColors.onSurfaceVariant,
      ),
      labelColor: HColors.primary,
      unselectedLabelColor: HColors.onSurfaceVariant,
      indicatorColor: HColors.primary,
      dividerColor: HColors.surfaceContainerHigh,
    ),
  );
}