import 'package:ds_relationship_companion/ds_design_system.dart';
import 'package:intl/intl.dart';
import '../../../../l10n/app_localizations.dart';
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
        L.of(context).todayDayEndsAt(
          _boundaryClock(boundaryMinutes, L.of(context).localeName),
        ),
        style: DsTextStyles.bodySecondary.copyWith(
          color: DsColors.textOnRitualMuted,
        ),
      ),
    );
  }
}

/// Minutes past midnight as a person reads a clock, in their own convention.
///
/// Formatted through `intl` rather than by hand: a hardcoded "AM"/"PM" leaves
/// English inside an otherwise translated sentence, and Chinese reads 上午 /
/// 下午 with the marker before the time rather than after it.
String _boundaryClock(int minutes, String localeName) {
  final wrapped = minutes % (24 * 60);
  return DateFormat.jm(
    localeName,
  ).format(DateTime(2000, 1, 1, wrapped ~/ 60, wrapped % 60));
}
