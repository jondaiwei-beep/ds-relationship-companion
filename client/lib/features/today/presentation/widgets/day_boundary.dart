import 'package:ds_relationship_companion/ds_design_system.dart';
import 'package:flutter/material.dart';

import 'today_layout.dart';

/// The relationship day, stated by the server in the Dynamic's own timezone.
class DayBoundary extends StatelessWidget {
  const DayBoundary({required this.boundaryMinutes, super.key});

  /// Minutes past midnight, from the server. Never the device's idea of a day.
  final int boundaryMinutes;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: todayInset.add(
        const EdgeInsets.only(top: DsSpacing.space2, bottom: DsSpacing.space4),
      ),
      child: Text(
        'Relationship day ends at ${_boundaryClock(boundaryMinutes)}',
        style: DsTextStyles.bodySecondary.copyWith(
          color: DsColors.textOnRitualMuted,
        ),
      ),
    );
  }
}

/// Minutes past midnight as a person reads a clock. Kept local to this widget
/// because it formats a wall-clock offset, not a moment in time.
String _boundaryClock(int minutes) {
  final wrapped = minutes % (24 * 60);
  final hour24 = wrapped ~/ 60;
  final hour = hour24 % 12 == 0 ? 12 : hour24 % 12;
  final minute = (wrapped % 60).toString().padLeft(2, '0');
  return '$hour:$minute ${hour24 < 12 ? 'AM' : 'PM'}';
}
