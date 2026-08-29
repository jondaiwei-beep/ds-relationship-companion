import 'package:flutter/material.dart';

import 'tokens/colors.dart';

/// The one theme the app runs under.
///
/// Extracted so screenshots render under the SAME theme as the build. A
/// golden captured under a different ThemeData is not evidence of anything —
/// the purple Material caret shipped for weeks precisely because the capture
/// harness constructed its own theme and never showed it.
ThemeData dsTheme() => ThemeData(
      scaffoldBackgroundColor: DsColors.canvas,
      colorScheme: ColorScheme.fromSeed(
        seedColor: DsColors.response,
        surface: DsColors.canvas,
      ),
      fontFamily: 'Inter',
      useMaterial3: true,
      // Material's default seed produces a purple caret and selection, which
      // belongs to no part of this palette. Terracotta is the single accent,
      // and a caret is exactly the kind of small mark it is for.
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: DsColors.accent,
        selectionHandleColor: DsColors.accent,
        selectionColor: Color(0x33B5533B),
      ),
    );
