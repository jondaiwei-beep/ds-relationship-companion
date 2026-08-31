import 'package:ds_relationship_companion/ds_design_system.dart';
import 'package:flutter/material.dart';

import '../../../today/presentation/widgets/today_layout.dart';

/// One fact about the current shape of things: a quiet label, and the fact
/// itself in editorial type.
///
/// Rows are separated by a hairline rather than boxed into cards. The preview
/// reads as a single continuous surface, and the screen package explicitly
/// forbids forcing this hierarchy into a generic card template.
class StructureRow extends StatelessWidget {
  const StructureRow({
    super.key,
    required this.asset,
    required this.label,
    required this.value,
  });

  final DsAssetId asset;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: DsColors.borderOnRitualHairline),
        ),
      ),
      padding: todayInset.add(
        const EdgeInsets.symmetric(vertical: DsSpacing.space5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          DsSvg(
            asset: asset,
            tone: DsAssetTone.primary,
            width: 36,
            height: 36,
          ),
          const SizedBox(width: DsSpacing.space4),
          Expanded(
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
                Text(
                  value,
                  style: DsTextStyles.displayRitual.copyWith(
                    color: DsColors.textOnRitualPrimary,
                    fontSize: 22,
                    height: 27 / 22,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
