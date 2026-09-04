import 'package:ds_relationship_companion/ds_design_system.dart';
import 'package:flutter/material.dart';

import '../../features/today/presentation/widgets/today_layout.dart';

/// The one anchor a surface gets: an eyebrow in the tracked label, the hero in
/// Cormorant at `display.hero`, and an optional support line.
///
/// design/system/redesign-2026-09.md §1. Today and Record anchor on the day,
/// Rules on its name, Points on the balance. Nothing else on a surface may use
/// the display family at this size; the hierarchy only exists if this is the
/// only large thing.
class PageHero extends StatelessWidget {
  const PageHero({super.key, this.eyebrow, required this.hero, this.support, this.heroKey});

  final String? eyebrow;
  final String hero;
  final String? support;
  final Key? heroKey;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: todayInset,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (eyebrow != null) ...[
            Text(
              eyebrow!.toUpperCase(),
              style: DsTextStyles.labelRitual.copyWith(color: DsColors.textOnRitualMuted),
            ),
            const SizedBox(height: DsSpacing.space2),
          ],
          Text(
            hero,
            key: heroKey,
            style: DsTextStyles.displayHero.copyWith(color: DsColors.textOnRitualPrimary),
          ),
          if (support != null) ...[
            const SizedBox(height: DsSpacing.space2),
            Text(
              support!,
              style: DsTextStyles.bodySecondary.copyWith(color: DsColors.textOnRitualSecondary),
            ),
          ],
        ],
      ),
    );
  }
}
