import 'package:flutter/material.dart';

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

    appBarTheme: const AppBarTheme(
      backgroundColor: HColors.surface,
      foregroundColor: HColors.onSurface,
      elevation: 0,
      centerTitle: true,
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: HColors.surfaceContainerLowest,
      hintStyle: HText.bodyMd.copyWith(
        color: HColors.onSurfaceVariant,
      ),
    ),
  );
}