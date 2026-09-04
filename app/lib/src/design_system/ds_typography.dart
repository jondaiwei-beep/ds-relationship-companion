import 'dart:ui' show FontFeature;

import 'package:flutter/material.dart';

/// The eight roles frozen in design/system/typography.md.
///
/// Every style names `_package`. The font files ship inside this package, and
/// without that qualifier Flutter resolves the bare family name against the
/// host application only — which silently falls back to a platform font in any
/// app that depends on this one. Silent substitution is forbidden: a screen
/// that quietly renders in Times has lost the type system without failing.
abstract final class DsTextStyles {
  static const String displayFamily = 'CormorantGaramond';
  static const String uiFamily = 'Inter';

  /// Resolves the bundled fonts from this package rather than the host.
  static const String _package = 'ds_relationship_companion';

  /// The one anchor a surface is allowed: the day, the page name, or the
  /// balance. 44px against 12px labels is what gives a page a hierarchy at
  /// all (design/system/redesign-2026-09.md §1). Lining figures, because the
  /// family's default old-style zero reads as an "o" at this size.
  static const TextStyle displayHero = TextStyle(
    fontFamily: displayFamily,
    package: _package,
    fontSize: 44,
    fontWeight: FontWeight.w400,
    height: 48 / 44,
    fontFeatures: [FontFeature.liningFigures()],
  );

  static const TextStyle displayRitual = TextStyle(
    fontFamily: displayFamily,
    package: _package,
    fontSize: 34,
    fontWeight: FontWeight.w400,
    height: 42 / 34,
  );

  static const TextStyle displayPartner = TextStyle(
    fontFamily: displayFamily,
    package: _package,
    fontSize: 28,
    fontWeight: FontWeight.w400,
    height: 36 / 28,
  );

  static const TextStyle titlePage = TextStyle(
    fontFamily: uiFamily,
    package: _package,
    fontSize: 22,
    fontWeight: FontWeight.w600,
    height: 28 / 22,
    letterSpacing: -0.2,
  );

  static const TextStyle bodyPrimary = TextStyle(
    fontFamily: uiFamily,
    package: _package,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 24 / 16,
  );

  static const TextStyle bodySecondary = TextStyle(
    fontFamily: uiFamily,
    package: _package,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 20 / 14,
  );

  static const TextStyle labelAction = TextStyle(
    fontFamily: uiFamily,
    package: _package,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 20 / 16,
    letterSpacing: 0.1,
  );

  static const TextStyle labelRitual = TextStyle(
    fontFamily: uiFamily,
    package: _package,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 16 / 12,
    letterSpacing: 2.4,
  );

  static const TextStyle navLabel = TextStyle(
    fontFamily: uiFamily,
    package: _package,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 16 / 12,
  );
}
