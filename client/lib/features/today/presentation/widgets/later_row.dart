import 'package:ds_relationship_companion/ds_design_system.dart';
import 'package:flutter/material.dart';

import 'today_layout.dart';

class LaterRow extends StatelessWidget {
  const LaterRow({
    super.key,
    required this.count,
    required this.expanded,
    required this.onToggle,
  });

  final int count;
  final bool expanded;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: todayInset,
      child: SizedBox(
        height: DsControlSizes.listRow,
        child: Row(
          children: [
            Text(
              'LATER / OPTIONAL',
              style: DsTextStyles.labelRitual.copyWith(
                color: DsColors.textOnRitualMuted,
              ),
            ),
            const Spacer(),
            InkWell(
              onTap: onToggle,
              child: SizedBox(
                height: DsLayoutSizes.touchTarget,
                child: Row(
                  children: [
                    Text(
                      expanded ? 'Hide' : 'Show',
                      style: DsTextStyles.bodyPrimary.copyWith(
                        color: DsColors.textOnRitualPrimary,
                      ),
                    ),
                    const SizedBox(width: DsSpacing.space3),
                    Container(
                      width: 28,
                      height: 28,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        color: DsColors.surfaceRitualRaised,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '$count',
                        style: DsTextStyles.bodySecondary.copyWith(
                          color: DsColors.textOnRitualSecondary,
                        ),
                      ),
                    ),
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

/// The relationship day, stated by the server in the Dynamic's own timezone.
