import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class HText {
  HText._();

  static TextStyle get displayLg => GoogleFonts.ebGaramond(
        fontSize: 36,
        fontWeight: FontWeight.w600,
        height: 1.17,
        letterSpacing: -0.3,
        color: HColors.onBackground,
      );

  static TextStyle get headlineLg => GoogleFonts.ebGaramond(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        height: 1.29,
        color: HColors.onBackground,
      );

  static TextStyle get headlineMd => GoogleFonts.ebGaramond(
        fontSize: 22,
        fontWeight: FontWeight.w500,
        height: 1.36,
        color: HColors.onBackground,
      );

  static TextStyle get bodyLg => GoogleFonts.beVietnamPro(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.5,
        color: HColors.onBackground,
      );

  static TextStyle get bodyMd => GoogleFonts.beVietnamPro(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.5,
        color: HColors.onBackground,
      );

  static TextStyle get labelLg => GoogleFonts.beVietnamPro(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        height: 1.54,
        letterSpacing: 0.65,
        color: HColors.onBackground,
      );

  static TextStyle get labelSm => GoogleFonts.beVietnamPro(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        height: 1.45,
        letterSpacing: 0.33,
        color: HColors.onBackground,
      );
}