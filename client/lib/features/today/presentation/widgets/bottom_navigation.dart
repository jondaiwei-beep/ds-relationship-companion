import 'package:ds_relationship_companion/ds_design_system.dart';
import 'package:flutter/material.dart';

class TodayBottomNavigation extends StatelessWidget {
  const TodayBottomNavigation({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: DsControlSizes.bottomNavigation,
      padding: EdgeInsets.only(bottom: MediaQuery.paddingOf(context).bottom),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: DsColors.borderOnRitualHairline)),
      ),
      child: Row(
        children: const [
          _NavTab(asset: DsAssets.navToday, label: 'Today', active: true),
          _NavTab(asset: DsAssets.navDynamic, label: 'Dynamic'),
          _NavTab(asset: DsAssets.navExplore, label: 'Explore'),
          _NavTab(asset: DsAssets.navUs, label: 'Us'),
        ],
      ),
    );
  }
}

class _NavTab extends StatelessWidget {
  const _NavTab({
    required this.asset,
    required this.label,
    this.active = false,
  });

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
        onTap: () {},
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
