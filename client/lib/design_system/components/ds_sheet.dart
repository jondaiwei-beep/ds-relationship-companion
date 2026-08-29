import 'package:flutter/material.dart';

import '../tokens/colors.dart';
import '../tokens/spacing.dart';

/// The grab handle at the top of a bottom sheet.
///
/// Without it a sheet has no visible way out: these sheets carry Discuss,
/// Reschedule and Can't-do, and a person must never feel committed just
/// because they opened one (red line #4 — agency is inviolable).
class DsSheetHandle extends StatelessWidget {
  const DsSheetHandle({super.key});

  @override
  Widget build(BuildContext context) => Semantics(
        label: 'Drag down to close',
        child: Center(
          child: Container(
            width: 36,
            height: 4,
            margin: const EdgeInsets.only(bottom: DsSpacing.xl),
            decoration: BoxDecoration(
              color: DsColors.line,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
      );
}
