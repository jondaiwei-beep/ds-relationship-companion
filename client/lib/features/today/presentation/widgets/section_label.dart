import 'package:ds_relationship_companion/ds_design_system.dart';
import 'package:flutter/material.dart';

import 'today_layout.dart';

class SectionLabel extends StatelessWidget {
  const SectionLabel(this.text, {super.key});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: todayInset.add(const EdgeInsets.only(bottom: DsSpacing.space4)),
      child: Text(
        text,
        style: DsTextStyles.labelRitual.copyWith(
          color: DsColors.textOnRitualMuted,
        ),
      ),
    );
  }
}

/// The first priority. A vertical authority rule runs the full height of the
/// block, and the four contract actions are reachable here — never behind a
/// detail page.
