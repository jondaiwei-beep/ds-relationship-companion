// QA harness for SCR-01 Today. Renders the screen at the reference viewport
// with bundled fonts so the result can be compared with the approved design.
import 'package:ds_relationship_companion/ds_design_system.dart';
import 'package:flutter/material.dart';

import 'features/today/presentation/today_screen.dart';

void main() => runApp(
  MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: DsTheme.ritual(),
    home: const TodayScreen(),
  ),
);
