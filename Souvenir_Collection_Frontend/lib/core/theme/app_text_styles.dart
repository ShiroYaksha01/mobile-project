import 'package:flutter/material.dart';
import 'app_colors.dart';

class HText {
  HText._();

  static const _garamond = 'EBGaramond';
  static const _vietnam = 'BeVietnamPro';

  static const displayLg = TextStyle(
    fontFamily: _garamond,
    fontSize: 36,
    fontWeight: FontWeight.w600,
    height: 1.17,
    letterSpacing: -0.3,
    color: HColors.onBackground,
  );

  static const headlineLg = TextStyle(
    fontFamily: _garamond,
    fontSize: 28,
    fontWeight: FontWeight.w600,
    height: 1.29,
    color: HColors.onBackground,
  );

  static const headlineMd = TextStyle(
    fontFamily: _garamond,
    fontSize: 22,
    fontWeight: FontWeight.w500,
    height: 1.36,
    color: HColors.onBackground,
  );

  static const bodyLg = TextStyle(
    fontFamily: _vietnam,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.5,
    color: HColors.onBackground,
  );

  static const bodyMd = TextStyle(
    fontFamily: _vietnam,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.5,
    color: HColors.onBackground,
  );

  static const labelLg = TextStyle(
    fontFamily: _vietnam,
    fontSize: 13,
    fontWeight: FontWeight.w600,
    height: 1.54,
    letterSpacing: 0.65,
    color: HColors.onBackground,
  );

  static const labelSm = TextStyle(
    fontFamily: _vietnam,
    fontSize: 11,
    fontWeight: FontWeight.w500,
    height: 1.45,
    letterSpacing: 0.33,
    color: HColors.onBackground,
  );
}