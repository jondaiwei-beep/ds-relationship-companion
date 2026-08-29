import 'package:ds_relationship_companion/ds_design_system.dart';
import 'package:flutter/material.dart';

import 'today_layout.dart';

/// The relationship day, stated by the server in the Dynamic's own timezone.
class DayBoundary extends StatelessWidget {
  const DayBoundary({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: todayInset.add(
        const EdgeInsets.only(top: DsSpacing.space2, bottom: DsSpacing.space4),
      ),
      child: Text(
        'Relationship day ends at 2:00 AM',
        style: DsTextStyles.bodySecondary.copyWith(
          color: DsColors.textOnRitualMuted,
        ),
      ),
    );
  }
}
