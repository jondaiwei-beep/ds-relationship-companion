import 'package:ds_relationship_companion/src/design_system/ds_typography.dart';
import 'package:ds_relationship_companion/src/design_system/generated/ds_design_tokens.g.dart';
import 'package:flutter/material.dart';

abstract final class DsTheme {
  static ThemeData ritual() => _base(
        brightness: Brightness.dark,
        canvas: DsColors.canvasRitual,
        surface: DsColors.surfaceRitualRaised,
        primary: DsColors.actionPrimaryBackground,
        onPrimary: DsColors.actionPrimaryForeground,
        onSurface: DsColors.textOnRitualPrimary,
        outline: DsColors.borderOnRitualHairline,
      );

  static ThemeData living() => _base(
        brightness: Brightness.light,
        canvas: DsColors.canvasLiving,
        surface: DsColors.surfaceLivingRaised,
        primary: DsColors.actionPrimaryBackground,
        onPrimary: DsColors.actionPrimaryForeground,
        onSurface: DsColors.textOnLivingPrimary,
        outline: DsColors.borderOnLivingHairline,
      );

  static ThemeData _base({
    required Brightness brightness,
    required Color canvas,
    required Color surface,
    required Color primary,
    required Color onPrimary,
    required Color onSurface,
    required Color outline,
  }) {
    final scheme = ColorScheme(
      brightness: brightness,
      primary: primary,
      onPrimary: onPrimary,
      secondary: DsColors.relationshipPresence,
      onSecondary: DsColors.textInverse,
      error: DsColors.stateError,
      onError: DsColors.textInverse,
      surface: surface,
      onSurface: onSurface,
      outline: outline,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: canvas,
      canvasColor: canvas,
      fontFamily: DsTextStyles.uiFamily,
      textTheme: TextTheme(
        displayLarge: DsTextStyles.displayRitual.copyWith(color: onSurface),
        displayMedium: DsTextStyles.displayPartner.copyWith(color: onSurface),
        titleLarge: DsTextStyles.titlePage.copyWith(color: onSurface),
        bodyLarge: DsTextStyles.bodyPrimary.copyWith(color: onSurface),
        bodyMedium: DsTextStyles.bodySecondary.copyWith(color: onSurface),
        labelLarge: DsTextStyles.labelAction.copyWith(color: onSurface),
        labelMedium: DsTextStyles.labelRitual.copyWith(color: onSurface),
        labelSmall: DsTextStyles.navLabel.copyWith(color: onSurface),
      ),
      visualDensity: VisualDensity.standard,
    );
  }
}
