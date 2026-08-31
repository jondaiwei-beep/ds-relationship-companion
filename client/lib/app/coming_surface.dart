import 'package:ds_relationship_companion/ds_design_system.dart';
import 'package:flutter/material.dart';

import 'shell/bottom_navigation.dart';

/// A navigation surface that is routed but not yet built.
///
/// The bar used to swallow taps on Dynamic, Explore and Us, on the theory that
/// silence was more honest than a placeholder. On a Samsung it read as a dead
/// app: three of four tabs did nothing, so the whole bar looked broken. A tap
/// that lands somewhere saying "not yet, and here is the way back" is the
/// honest version of the same fact.
///
/// The bar stays on this screen so Today is always one tap away.
class ComingSurface extends StatelessWidget {
  const ComingSurface({
    super.key,
    required this.surface,
    required this.onSelect,
  });

  final NavSurface surface;
  final void Function(NavSurface surface) onSelect;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DsColors.canvasRitual,
      body: DsRitualSurface(
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: DsSpacing.space6,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          surface.label,
                          style: DsTextStyles.displayRitual.copyWith(
                            color: DsColors.textOnRitualPrimary,
                          ),
                        ),
                        const SizedBox(height: DsSpacing.space4),
                        Text(
                          'Not open yet. Nothing here is missing from your '
                          'day — Today holds everything that is waiting.',
                          textAlign: TextAlign.center,
                          style: DsTextStyles.bodySecondary.copyWith(
                            color: DsColors.textOnRitualSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              DsBottomNavigation(current: surface, onSelect: onSelect),
            ],
          ),
        ),
      ),
    );
  }
}
