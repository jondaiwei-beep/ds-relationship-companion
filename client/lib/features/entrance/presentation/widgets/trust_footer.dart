import 'package:ds_relationship_companion/ds_design_system.dart';
import 'package:flutter/material.dart';

/// Facts, not promises.
///
/// An earlier draft said "Your space stays between you." That both exposed the
/// relationship context and promised an absolute the product cannot deliver —
/// it cannot speak for the device, the browser or anyone nearby. Replaced with
/// what is verifiably true (decision D8).
class TrustFooter extends StatelessWidget {
  const TrustFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const DsSvg(
          asset: DsAssets.stateLocked,
          tone: DsAssetTone.muted,
          width: 20,
          height: 20,
        ),
        const SizedBox(height: DsSpacing.space5),
        Opacity(
          opacity: 0.72,
          child: Text(
            'For adults 18+. Use of this service is subject to our Terms.\n'
            'See how we handle data in our Privacy Policy.\n'
            'Accounts are private by default.',
            textAlign: TextAlign.center,
            style: DsTextStyles.navLabel.copyWith(
              color: DsColors.textOnRitualMuted,
              fontSize: 10,
              height: 15 / 10,
            ),
          ),
        ),
      ],
    );
  }
}
