import 'package:flutter/material.dart';

/// The eight roles frozen in design/system/typography.md.
abstract final class DsTextStyles {
  static const String displayFamily = 'CormorantGaramond';
  static const String uiFamily = 'Inter';

  static const TextStyle displayRitual = TextStyle(
    fontFamily: displayFamily,
    fontSize: 34,
    fontWeight: FontWeight.w400,
    height: 42 / 34,
  );

  static const TextStyle displayPartner = TextStyle(
    fontFamily: displayFamily,
    fontSize: 28,
    fontWeight: FontWeight.w400,
    height: 36 / 28,
  );

  static const TextStyle titlePage = TextStyle(
    fontFamily: uiFamily,
    fontSize: 22,
    fontWeight: FontWeight.w600,
    height: 28 / 22,
    letterSpacing: -0.2,
  );

  static const TextStyle bodyPrimary = TextStyle(
    fontFamily: uiFamily,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 24 / 16,
  );

  static const TextStyle bodySecondary = TextStyle(
    fontFamily: uiFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 20 / 14,
  );

  static const TextStyle labelAction = TextStyle(
    fontFamily: uiFamily,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 20 / 16,
    letterSpacing: 0.1,
  );

  static const TextStyle labelRitual = TextStyle(
    fontFamily: uiFamily,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 16 / 12,
    letterSpacing: 2.4,
  );

  static const TextStyle navLabel = TextStyle(
    fontFamily: uiFamily,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 16 / 12,
  );
}
