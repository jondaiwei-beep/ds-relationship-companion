import 'package:ds_relationship_companion/ds_design_system.dart';
import 'package:flutter/material.dart';

import '../../../../app/shell/ds_skeleton.dart';
import '../../../../domain_client/models/record.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../today/presentation/widgets/quiet_line.dart';
import '../../../today/presentation/widgets/today_layout.dart';

/// Counts for the week and the month, side by side. Numbers only — the
/// surface relays what happened and leaves the reading of it to the two
/// people (product/02-surfaces.md: 不评价、不建议).
///
/// A row that is 0 in both columns says nothing, so it is not shown
/// (redesign-2026-09 §7). When every row is 0 the table gives way to one line.
class FactsTable extends StatelessWidget {
  const FactsTable({super.key, required this.week, required this.month});

  /// Null while still being read.
  final FactsView? week;
  final FactsView? month;

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    if (week == null && month == null) {
      return const Padding(padding: todayInset, child: DsSkeletonBar(widthFactor: 0.6));
    }
    final rows = <(String, int Function(FactsView))>[
      (l.recordFactDelivered, (f) => f.delivered),
      (l.recordFactLate, (f) => f.late),
      (l.recordFactFlagged, (f) => f.flagged),
      (l.recordFactMissed, (f) => f.missed),
      (l.recordFactLetGo, (f) => f.letGo),
      (l.recordFactPraised, (f) => f.praised),
      (l.recordFactMadeUp, (f) => f.madeUp),
      (l.recordFactPunished, (f) => f.punished),
      (l.recordFactComments, (f) => f.comments),
      (l.recordFactPointsEarned, (f) => f.pointsEarned),
      (l.recordFactPointsDeducted, (f) => f.pointsDeducted),
      (l.recordFactRedemptions, (f) => f.redemptions),
    ];
    int value(FactsView? f, int Function(FactsView) pick) => f == null ? 0 : pick(f);
    final shown = [
      for (final row in rows)
        if (value(week, row.$2) != 0 || value(month, row.$2) != 0) row,
    ];
    if (shown.isEmpty) return QuietLine(l.recordFactsNone);

    final labelStyle = DsTextStyles.bodySecondary.copyWith(color: DsColors.textOnRitualSecondary);
    final headStyle = DsTextStyles.labelRitual.copyWith(
      color: DsColors.textOnRitualMuted,
      fontSize: todaySupportSize,
    );
    final numStyle = DsTextStyles.bodyPrimary.copyWith(color: DsColors.textOnRitualPrimary);

    String cell(FactsView? f, int Function(FactsView) pick) => f == null ? '–' : '${pick(f)}';

    return Padding(
      padding: todayInset,
      child: Table(
        columnWidths: const {0: FlexColumnWidth(), 1: FixedColumnWidth(64), 2: FixedColumnWidth(64)},
        children: [
          TableRow(
            children: [
              const SizedBox.shrink(),
              Text(l.recordFactsWeek, textAlign: TextAlign.right, style: headStyle),
              Text(l.recordFactsMonth, textAlign: TextAlign.right, style: headStyle),
            ],
          ),
          for (final (label, pick) in shown)
            TableRow(
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: DsColors.borderOnRitualHairline)),
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: DsSpacing.space2),
                  child: Text(label, style: labelStyle),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: DsSpacing.space2),
                  child: Text(cell(week, pick), textAlign: TextAlign.right, style: numStyle),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: DsSpacing.space2),
                  child: Text(cell(month, pick), textAlign: TextAlign.right, style: numStyle),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
