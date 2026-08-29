import 'package:ds_relationship_companion/ds_design_system.dart';
import 'package:flutter/material.dart';

/// A route that exists, for a screen that does not.
///
/// Every route in the contract is registered from the start, because the
/// alternative — adding paths as screens land — means deep links, Web refresh
/// and the invitation entry point are only tested at the very end, which is
/// when they are most expensive to get wrong.
///
/// This deliberately looks unfinished. A placeholder that renders something
/// plausible is worse than one that admits what it is: it gets screenshotted,
/// demoed and mistaken for progress. It uses the frozen tokens only so that
/// hitting it on a real device does not flash an off-palette white page.
class NotBuiltYet extends StatelessWidget {
  const NotBuiltYet({super.key, required this.screen});

  /// The screen this route is waiting for, named as the design index names it
  /// — so the reader can look it up rather than guess.
  final String screen;

  @override
  Widget build(BuildContext context) {
    return DsRitualSurface(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(DsSpacing.space6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                screen,
                textAlign: TextAlign.center,
                style: DsTextStyles.bodyPrimary.copyWith(
                  color: DsColors.textOnRitualPrimary,
                ),
              ),
              const SizedBox(height: DsSpacing.space2),
              Text(
                'This route is reserved. The screen is designed and its '
                'build gate is closed.',
                textAlign: TextAlign.center,
                style: DsTextStyles.bodyPrimary.copyWith(
                  color: DsColors.textOnRitualMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
