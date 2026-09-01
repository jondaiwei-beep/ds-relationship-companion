import 'package:ds_relationship_companion/ds_design_system.dart';
import 'package:flutter/material.dart';

import '../../../../app/shell/ds_glyph.dart';
import '../../../../l10n/app_localizations.dart';

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
    this.markSize = markSmall,
  });

  /// The sizes `mark.authority` is frozen at, of which this header uses two.
  ///
  /// SVG Freeze v1 licenses 32/40/64dp and nothing else. The renderer throws
  /// on any other value; `DsSvg` only checks the tone, so an unfrozen size
  /// reaches the screen silently — which is how this header was drawing the
  /// mark at 26dp on a short viewport. Stroke weight is drawn at the frozen
  /// sizes and stops matching the rest of the product at any other.
  static const markMedium = 40.0;
  static const markSmall = 32.0;

  /// Which frozen size this surface takes. SCR-05 is drawn at 40dp and SCR-06
  /// at 32dp — the entrance renderer composes all three together, and the two
  /// forms are not the same size in it.
  final double markSize;

  /// Below this the composition is decoration a person has to scroll past to
  /// reach a form. The design is drawn at 844dp; a Samsung in gesture mode
  /// gives about 700 of usable height, and the fixed ornament does not shrink
  /// on its own — so the form ends up below the fold and its primary button
  /// under the system bar.
  static const compactBelow = 760.0;

  static bool isCompact(BuildContext context) =>
      MediaQuery.sizeOf(context).height < compactBelow;

  final String eyebrow;
  final String headline;

  /// Null while a request is in flight: leaving mid-submit would abandon a
  /// command whose result the person never sees.
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    final compact = isCompact(context);
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
            icon: DsGlyphIcon(
              DsGlyph.back,
              color: DsColors.textOnRitualSecondary,
              semanticLabel: L.of(context).shellBack,
            ),
          ),
        ),
        // A short viewport steps the mark down to the next frozen size rather
        // than scaling it to fit. 26dp was neither frozen nor a step — it was
        // the ornament shrinking to buy space the spacing below should give.
        DsSvg(
          asset: DsAssets.markAuthority,
          tone: DsAssetTone.primary,
          width: compact ? markSmall : markSize,
          height: compact ? markSmall : markSize,
        ),
        SizedBox(height: compact ? DsSpacing.space4 : DsSpacing.space8),
        Text(
          eyebrow,
          style: DsTextStyles.labelRitual.copyWith(
            color: DsColors.textOnRitualMuted,
          ),
        ),
        SizedBox(height: compact ? DsSpacing.space3 : DsSpacing.space5),
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
