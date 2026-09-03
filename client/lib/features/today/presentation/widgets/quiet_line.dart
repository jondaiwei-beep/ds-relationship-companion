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
      padding: todayInset.add(const EdgeInsets.symmetric(vertical: DsSpacing.space6)),
      child: Text(
        text,
        style: DsTextStyles.bodyPrimary.copyWith(color: DsColors.textOnRitualSecondary),
      ),
    );
  }
}
