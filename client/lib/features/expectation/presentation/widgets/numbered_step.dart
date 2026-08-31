import 'package:ds_relationship_companion/ds_design_system.dart';
import 'package:flutter/material.dart';

import '../../../today/presentation/widgets/today_layout.dart';

/// One numbered step of the composition, with the rule that threads them.
///
/// The number and the vertical rule are what make this read as one continuous
/// act rather than a stack of unrelated fields — the approved composition
/// draws them as a single thread down the left, and the screen package
/// forbids flattening this into generic cards.
class NumberedStep extends StatelessWidget {
  const NumberedStep({
    super.key,
    required this.index,
    required this.label,
    required this.child,
    this.last = false,
  });

  final int index;
  final String label;
  final Widget child;

  /// The thread stops at the last step rather than running into the action.
  final bool last;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Padding(
        padding: todayInset,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              width: 28,
              child: Text(
                index.toString().padLeft(2, '0'),
                style: DsTextStyles.labelRitual.copyWith(
                  color: DsColors.textOnRitualMuted,
                ),
              ),
            ),
            // The thread, and the node marking this step on it.
            SizedBox(
              width: 24,
              child: Stack(
                alignment: Alignment.topCenter,
                children: [
                  Positioned.fill(
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: FractionallySizedBox(
                        heightFactor: last ? 0.5 : 1.0,
                        alignment: Alignment.topCenter,
                        child: Container(
                          width: 1,
                          color: DsColors.decorativeRitualLine,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Container(
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: DsColors.canvasRitual,
                        border: Border.all(
                          color: DsColors.borderOnRitualStrong,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: DsSpacing.space3),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: DsSpacing.space6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: DsTextStyles.labelRitual.copyWith(
                        color: DsColors.textOnRitualMuted,
                      ),
                    ),
                    const SizedBox(height: DsSpacing.space2),
                    child,
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
