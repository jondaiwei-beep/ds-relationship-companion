import 'package:ds_relationship_companion/ds_design_system.dart';
import 'package:flutter/material.dart';

/// Back, mark, eyebrow, headline — the top of every entrance surface below
/// SCR-04 itself.
///
/// Shared because SCR-05 and SCR-06 are the same composition with different
/// words, and the design draws them from one renderer for exactly that reason.
/// Two screens diverging here is how the entrance stops feeling like one place.
class EntranceHeader extends StatelessWidget {
  const EntranceHeader({
    super.key,
    required this.eyebrow,
    required this.headline,
    this.onBack,
  });

  final String eyebrow;
  final String headline;

  /// Null while a request is in flight: leaving mid-submit would abandon a
  /// command whose result the person never sees.
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: IconButton(
            onPressed: onBack,
            iconSize: 20,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(
              minWidth: DsLayoutSizes.touchTarget,
              minHeight: DsLayoutSizes.touchTarget,
            ),
            icon: const Icon(
              Icons.arrow_back_ios_new,
              color: DsColors.textOnRitualSecondary,
            ),
          ),
        ),
        const DsSvg(
          asset: DsAssets.markAuthority,
          tone: DsAssetTone.primary,
          width: 32,
          height: 32,
        ),
        const SizedBox(height: DsSpacing.space8),
        Text(
          eyebrow,
          style: DsTextStyles.labelRitual.copyWith(
            color: DsColors.textOnRitualMuted,
          ),
        ),
        const SizedBox(height: DsSpacing.space5),
        Text(
          headline,
          textAlign: TextAlign.center,
          style: DsTextStyles.displayRitual.copyWith(
            color: DsColors.textOnRitualPrimary,
          ),
        ),
        const SizedBox(height: DsSpacing.space2),
      ],
    );
  }
}
