import 'package:ds_relationship_companion/ds_design_system.dart';
import 'package:flutter/material.dart';

import 'ds_glyph.dart';

import '../../l10n/app_localizations.dart';

/// The four tabs (product/02-surfaces.md): 今天 / 规矩 / 记录 / 分.
///
/// Named, not indexed. Attention and Explore are reached from inside a tab,
/// not from here.
enum NavSurface {
  today(DsAssets.navToday, null),
  rules(null, DsGlyph.rules),
  record(null, DsGlyph.record),
  points(null, DsGlyph.points);

  const NavSurface(this.asset, this.glyph);

  /// The frozen SVG for the tab, or null when [glyph] draws it instead.
  final DsAssetId? asset;
  final DsGlyph? glyph;

  /// The tab's word, in the reader's language. A method rather than a const
  /// field because the enum is built before any locale is known.
  String label(L l) => switch (this) {
    NavSurface.today => l.navToday,
    NavSurface.rules => l.navRules,
    NavSurface.record => l.navRecord,
    NavSurface.points => l.navPoints,
  };
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
    // The system inset EXTENDS the bar, it does not eat into it.
    //
    // `height: 80` with `padding: bottom 48` gave a bar that was still 80 tall
    // with its tabs pushed 48dp down — straight into a Samsung's gesture bar,
    // where the labels sat under the system's own back and home controls.
    // Found on a real device; the widget test below it now measures the same
    // thing at a 48dp inset.
    final inset = MediaQuery.paddingOf(context).bottom;
    return Container(
      height: DsControlSizes.bottomNavigation + inset,
      padding: EdgeInsets.only(bottom: inset),
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
          key: ValueKey('nav-${surface.name}'),
          onTap: onTap,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (surface.asset case final asset?)
                DsSvg(
                  asset: asset,
                  tone: active ? DsAssetTone.primary : DsAssetTone.muted,
                  width: 24,
                  height: 24,
                )
              else
                DsGlyphIcon(
                  surface.glyph!,
                  size: 24,
                  color: colour,
                ),
              const SizedBox(height: DsSpacing.space1),
              Text(
                surface.label(L.of(context)),
                style: DsTextStyles.navLabel.copyWith(color: colour),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
