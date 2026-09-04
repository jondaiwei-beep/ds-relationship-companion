import 'package:ds_relationship_companion/ds_design_system.dart';
import 'package:flutter/material.dart';

import 'today_layout.dart';

/// A single sentence with nothing around it — the empty state, a private note.
class QuietLine extends StatelessWidget {
  const QuietLine(this.text, {super.key});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: todayInset.add(const EdgeInsets.symmetric(vertical: DsSpacing.space2)),
      // Full width, so a centring Column cannot float it to the middle.
      child: SizedBox(
        width: double.infinity,
        child: Text(
          text,
          style: DsTextStyles.bodySecondary.copyWith(color: DsColors.textOnRitualSecondary),
        ),
      ),
    );
  }
}
