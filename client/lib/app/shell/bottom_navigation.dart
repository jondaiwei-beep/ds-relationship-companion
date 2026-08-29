import 'package:ds_relationship_companion/ds_design_system.dart';
import 'package:flutter/material.dart';

/// The four surfaces the product navigates between.
///
/// Named, not indexed. The version this replaces took an `int`, which was
/// fine while one screen used it and would have been eight chances to pass
/// the wrong number once the rest exist.
///
/// Attention is deliberately absent: it is reached from Today, not from here.
/// The set is fixed by the product, so this enum is the whole contract.
enum NavSurface {
  today(DsAssets.navToday, 'Today'),
  dynamic_(DsAssets.navDynamic, 'Dynamic'),
  explore(DsAssets.navExplore, 'Explore'),
  us(DsAssets.navUs, 'Us');

  const NavSurface(this.asset, this.label);

  final DsAssetId asset;
  final String label;
}

/// Bottom navigation, shared by every surface that has it.
///
/// Promoted out of `features/today/` once a second caller was a fact rather
/// than a prediction: eight screens in the design index reference the nav
/// assets. The other components extracted alongside Today still have a reuse
/// count of one, and stay where they are.
class DsBottomNavigation extends StatelessWidget {
  const DsBottomNavigation({
    super.key,
    required this.current,
    this.onSelect,
  });

  /// The surface showing now. Highlighted, and not re-selectable.
  final NavSurface current;

  /// Omitted while the destinations do not exist. The bar then renders as it
  /// does in the design but does not respond — which is honest, where routing
  /// to a placeholder would not be.
  final void Function(NavSurface surface)? onSelect;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: DsControlSizes.bottomNavigation,
      padding: EdgeInsets.only(bottom: MediaQuery.paddingOf(context).bottom),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: DsColors.borderOnRitualHairline)),
      ),
      child: Row(
        children: [
          for (final surface in NavSurface.values)
            _NavTab(
              surface: surface,
              active: surface == current,
              // Re-selecting the current surface would rebuild the screen the
              // person is already reading, losing their scroll position.
              onTap: onSelect == null || surface == current
                  ? null
                  : () => onSelect!(surface),
            ),
        ],
      ),
    );
  }
}

class _NavTab extends StatelessWidget {
  const _NavTab({
    required this.surface,
    required this.active,
    this.onTap,
  });

  final NavSurface surface;
  final bool active;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colour =
        active ? DsColors.textOnRitualPrimary : DsColors.textOnRitualMuted;
    return Expanded(
      child: Semantics(
        selected: active,
        button: true,
        child: InkWell(
          onTap: onTap,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              DsSvg(
                asset: surface.asset,
                tone: active ? DsAssetTone.primary : DsAssetTone.muted,
                width: 24,
                height: 24,
              ),
              const SizedBox(height: DsSpacing.space1),
              Text(
                surface.label,
                style: DsTextStyles.navLabel.copyWith(color: colour),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
