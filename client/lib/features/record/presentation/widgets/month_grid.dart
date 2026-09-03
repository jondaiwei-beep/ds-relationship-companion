import 'package:ds_relationship_companion/ds_design_system.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../app/shell/ds_glyph.dart';
import '../../../../domain_client/models/record.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../today/presentation/today_format.dart';
import '../../../today/presentation/widgets/today_layout.dart';
import '../../application/calendar_math.dart';

/// Month name with a step either way. Swiping the grid does the same.
class MonthNav extends StatelessWidget {
  const MonthNav({
    super.key,
    required this.month,
    required this.onPrevious,
    required this.onNext,
  });

  final YearMonth month;
  final VoidCallback onPrevious;

  /// Null when the next month has not happened yet.
  final VoidCallback? onNext;

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    final locale = Localizations.localeOf(context).toString();
    final title = DateFormat.yMMMM(locale).format(DateTime(month.year, month.month));
    return Padding(
      padding: todayInset,
      child: Row(
        children: [
          _Step(glyph: DsGlyph.back, label: l.recordPrevMonth, onTap: onPrevious),
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: DsTextStyles.bodyPrimary.copyWith(color: DsColors.textOnRitualPrimary),
            ),
          ),
          _Step(glyph: DsGlyph.forward, label: l.recordNextMonth, onTap: onNext),
        ],
      ),
    );
  }
}

class _Step extends StatelessWidget {
  const _Step({required this.glyph, required this.label, required this.onTap});
  final DsGlyph glyph;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      enabled: onTap != null,
      label: label,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: SizedBox(
          width: 48,
          height: 48,
          child: Center(
            child: DsGlyphIcon(
              glyph,
              size: 20,
              color: onTap == null ? DsColors.textOnRitualMuted : DsColors.textOnRitualSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

/// The month, Monday first. A cell says how many were delivered of how many
/// were due, whether something still waits for the D, and whether a line was
/// left. It says nothing about whether any of that was good.
class MonthGrid extends StatelessWidget {
  const MonthGrid({
    super.key,
    required this.month,
    required this.cells,
    required this.today,
    required this.onOpenDay,
    this.onSwipe,
  });

  final YearMonth month;
  final List<MonthCell> cells;

  /// The current relationship day, `yyyy-MM-dd`, as the server named it.
  final String today;
  final void Function(String isoDay) onOpenDay;

  /// `-1` for the previous month, `+1` for the next.
  final void Function(int direction)? onSwipe;

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).toString();
    final byDay = {for (final c in cells) c.day: c};
    final blanks = month.leadingBlanks;
    final total = blanks + month.length;
    final rows = (total + 6) ~/ 7;

    // Monday..Sunday labels, from a week known to start on a Monday.
    final weekdays = List.generate(
      7,
      (i) => DateFormat.E(locale).format(DateTime(2024, 1, 1 + i)),
    );

    return GestureDetector(
      onHorizontalDragEnd: onSwipe == null
          ? null
          : (d) {
              final v = d.primaryVelocity ?? 0;
              if (v < -200) onSwipe!(1);
              if (v > 200) onSwipe!(-1);
            },
      child: Padding(
        padding: todayInset,
        child: Column(
          children: [
            Row(
              children: [
                for (final w in weekdays)
                  Expanded(
                    child: Text(
                      w,
                      textAlign: TextAlign.center,
                      style: DsTextStyles.labelRitual.copyWith(
                        color: DsColors.textOnRitualMuted,
                        fontSize: todaySupportSize,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: DsSpacing.space2),
            for (var r = 0; r < rows; r++)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (var c = 0; c < 7; c++)
                    Expanded(
                      child: () {
                        final i = r * 7 + c - blanks;
                        if (i < 0 || i >= month.length) return const SizedBox(height: 56);
                        final iso = month.isoDayOf(i + 1);
                        final future = compareIsoDays(iso, today) > 0;
                        return MonthCellTile(
                          dayOfMonth: i + 1,
                          isoDay: iso,
                          cell: byDay[iso],
                          isToday: iso == today,
                          onTap: future ? null : () => onOpenDay(iso),
                        );
                      }(),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class MonthCellTile extends StatelessWidget {
  const MonthCellTile({
    super.key,
    required this.dayOfMonth,
    required this.isoDay,
    required this.cell,
    required this.isToday,
    required this.onTap,
  });

  final int dayOfMonth;
  final String isoDay;
  final MonthCell? cell;
  final bool isToday;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).toString();
    final c = cell;
    final muted = onTap == null;
    final numberColor = muted ? DsColors.textOnRitualMuted : DsColors.textOnRitualPrimary;
    final undisposed = (c?.undisposed ?? 0) > 0;
    final commented = (c?.comments ?? 0) > 0;
    final ratio = c != null && c.due > 0 ? '${c.delivered}/${c.due}' : null;

    return Semantics(
      button: onTap != null,
      label: TodayFormat.day(isoDay, locale),
      value: [
        ?ratio,
        if (undisposed) 'undisposed',
        if (commented) 'comments',
      ].join(' '),
      child: InkWell(
        key: ValueKey('cell-$isoDay'),
        onTap: onTap,
        borderRadius: BorderRadius.circular(DsRadii.control),
        child: Container(
          height: 56,
          margin: const EdgeInsets.all(1),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(DsRadii.control),
            border: isToday ? Border.all(color: DsColors.borderOnRitualStrong) : null,
          ),
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                '$dayOfMonth',
                style: DsTextStyles.bodyPrimary.copyWith(color: numberColor, height: 1.1),
              ),
              const SizedBox(height: 2),
              Text(
                ratio ?? '',
                style: DsTextStyles.labelRitual.copyWith(
                  color: DsColors.textOnRitualSecondary,
                  fontSize: todaySupportSize,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 3),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (undisposed)
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 2),
                      child: Icon(Icons.circle, size: 6, color: DsColors.relationshipPresence),
                    ),
                  if (commented)
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 2),
                      child: Icon(
                        Icons.mode_comment_outlined,
                        size: 9,
                        color: DsColors.textOnRitualSecondary,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
