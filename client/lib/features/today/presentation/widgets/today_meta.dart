import 'package:ds_relationship_companion/ds_design_system.dart';
import 'package:flutter/material.dart';

import '../../../../domain_client/models/today_view.dart';
import '../../../../l10n/app_localizations.dart';
import '../today_format.dart';
import 'today_layout.dart';

/// The facts of the day under the header: which day, where it starts, the
/// balance, how long the two have been at this. Plain, no verdicts.
class TodayMeta extends StatelessWidget {
  const TodayMeta({super.key, required this.view});
  final TodayView view;

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    final locale = Localizations.localeOf(context).toString();
    final muted = DsTextStyles.bodySecondary.copyWith(color: DsColors.textOnRitualMuted);
    return Padding(
      padding: todayInset,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            TodayFormat.dayLong(view.day, locale),
            style: DsTextStyles.bodyPrimary.copyWith(color: DsColors.textOnRitualPrimary),
          ),
          const SizedBox(height: DsSpacing.space1),
          Text(
            l.todayDayStartsAt(TodayFormat.minutesClock(view.dayBoundaryMinutes, locale)),
            style: muted,
          ),
          const SizedBox(height: DsSpacing.space1),
          Text(
            '${l.todayBalance(view.balance)} · ${l.todayDaysTogether(view.daysTogether)}',
            style: muted,
          ),
        ],
      ),
    );
  }
}
