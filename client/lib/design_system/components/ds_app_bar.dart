import 'package:flutter/material.dart';

import '../tokens/colors.dart';
import 'ds_nav_icons.dart';

/// The 76dp app bar from Warm Authority V5 (DESIGN_SYSTEM §3): olive, a
/// centred serif title, 24×24 icon slots left and right.
///
/// Sub-screens need a visible way back. Relying on the Android system button
/// leaves iOS Safari and the web build with no exit at all, and even on
/// Android an unmarked screen reads as a place you fell into.
class DsAppBar extends StatelessWidget implements PreferredSizeWidget {
  const DsAppBar({
    super.key,
    required this.title,
    this.onBack,
    this.trailing,
  });

  final String title;

  /// Omitted on the four navigation surfaces: a tab is not somewhere you
  /// came from, so offering "back" there would be a lie about the stack.
  final VoidCallback? onBack;
  final Widget? trailing;

  static const _height = 76.0;

  @override
  Size get preferredSize => const Size.fromHeight(_height);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: DsColors.response,
      padding: EdgeInsets.only(top: MediaQuery.paddingOf(context).top),
      height: _height + MediaQuery.paddingOf(context).top,
      child: Stack(
        children: [
          Center(
            child: Text(
              title,
              style: const TextStyle(
                fontFamily: 'Lora',
                fontSize: 21,
                color: DsColors.surface,
              ),
            ),
          ),
          if (onBack != null)
            Align(
              alignment: Alignment.centerLeft,
              child: Semantics(
                button: true,
                label: 'Back',
                child: InkWell(
                  onTap: onBack,
                  // A 24dp mark inside a 48dp target: the design's line-work
                  // stays light, the touch area stays reachable.
                  child: const SizedBox(
                    width: 48,
                    height: 48,
                    child: Center(
                      child: DsNavIcon(
                        DsNavShape.chevronLeft,
                        color: DsColors.surface,
                        size: 24,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          if (trailing != null)
            Align(alignment: Alignment.centerRight, child: trailing),
        ],
      ),
    );
  }
}
