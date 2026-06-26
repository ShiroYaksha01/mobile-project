import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Core Theme Colors: Festive, warm earth tones with gold accents
  static const primary = Color(0xFF8B3A2B); // Rich Terracotta / Angkor Red
  static const primaryLight = Color(0xFFB75D4E);
  static const primaryDark = Color(0xFF5A2117);

  static const secondary = Color(0xFFD4AF37); // Metallic Gold Accent
  static const secondaryLight = Color(0xFFFFE088);
  static const secondaryDark = Color(0xFF997A00);

  // Backgrounds & Surfaces
  static const backgroundLight = Color(0xFFFDFBF7); // Warm cream
  static const surfaceLight = Color(0xFFFFFFFF);
  static const surfaceVariantLight = Color(0xFFF0EDED);

  static const backgroundDark = Color(0xFF2C241E); // Deep earth brown
  static const surfaceDark = Color(0xFF3E332A);
  static const surfaceVariantDark = Color(0xFF4D4635);

  // Text Colors
  static const textPrimaryLight = Color(0xFF2C241E);
  static const textSecondaryLight = Color(0xFF6B5E53);

  static const textPrimaryDark = Color(0xFFFDFBF7);
  static const textSecondaryDark = Color(0xFFD1C7BD);

  // Status Colors
  static const error = Color(0xFFD32F2F);
  static const success = Color(0xFF388E3C);
  static const warning = Color(0xFFF57C00);
}

/// Material-3 semantic color aliases used by the UI layer.
class HColors {
  HColors._();

  // Primary
  static const primary = AppColors.primary;
  static const primaryContainer = AppColors.primaryLight;
  static const onPrimaryContainer = AppColors.surfaceLight;
  static const primaryFixed = AppColors.primaryLight;
  static const primaryFixedDim = AppColors.primary;

  // Secondary
  static const secondary = AppColors.secondary;
  static const secondaryContainer = AppColors.secondaryLight;
  static const onSecondary = AppColors.textPrimaryLight;
  static const onSecondaryContainer = AppColors.textPrimaryLight;

  // Tertiary
  static const tertiary = AppColors.primaryDark;

  // Status
  static const error = AppColors.error;
  static const success = AppColors.success;

  // Surface hierarchy
  static const background = AppColors.backgroundLight;
  static const onBackground = AppColors.textPrimaryLight;
  static const surface = AppColors.surfaceLight;
  static const onSurface = AppColors.textPrimaryLight;
  static const onSurfaceVariant = AppColors.textSecondaryLight;
  static const surfaceContainer = AppColors.surfaceVariantLight;
  static const surfaceContainerLow = Color(0xFFF8F6F3);
  static const surfaceContainerLowest = AppColors.surfaceLight;
  static const surfaceContainerHigh = Color(0xFFEBE8E5);
  static const surfaceContainerHighest = Color(0xFFE5E2DF);

  // Outline
  static const outline = AppColors.textSecondaryLight;
  static const outlineVariant = Color(0xFFD1C7BD);
}