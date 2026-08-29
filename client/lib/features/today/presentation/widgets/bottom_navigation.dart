import 'package:ds_relationship_companion/ds_design_system.dart';
import 'package:flutter/material.dart';

class TodayBottomNavigation extends StatelessWidget {
  const TodayBottomNavigation({super.key, this.onSelect, this.current = 0});

  /// Supplied when the other three surfaces exist. Today is the only screen
  /// with an open gate, so the remaining tabs are inert rather than wired to
  /// placeholders.
  final void Function(int index)? onSelect;

  /// Which surface is showing. Today is the only open gate, so it is the
  /// default.
  final int current;

  /// Exactly four, in this order. The set is fixed by the product: Attention
  /// is reached from Today, not from here.
  static const _tabs = <(DsAssetId, String)>[
    (DsAssets.navToday, 'Today'),
    (DsAssets.navDynamic, 'Dynamic'),
    (DsAssets.navExplore, 'Explore'),
    (DsAssets.navUs, 'Us'),
  ];

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
          for (final (index, (asset, label)) in _tabs.indexed)
            _NavTab(
              asset: asset,
              label: label,
              active: index == current,
              onTap: onSelect == null ? null : () => onSelect!(index),
            ),
        ],
      ),
    );
  }
}

class _NavTab extends StatelessWidget {
  const _NavTab({
    this.onTap,
    required this.asset,
    required this.label,
    this.active = false,
  });

  final VoidCallback? onTap;

  final DsAssetId asset;
  final String label;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final colour = active
        ? DsColors.textOnRitualPrimary
        : DsColors.textOnRitualMuted;
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            DsSvg(
              asset: asset,
              tone: active ? DsAssetTone.primary : DsAssetTone.muted,
              width: 24,
              height: 24,
            ),
            const SizedBox(height: DsSpacing.space1),
            Text(label, style: DsTextStyles.navLabel.copyWith(color: colour)),
          ],
        ),
      ),
    );
  }
}
