import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../design_system/components/ds_nav_icons.dart';
import '../design_system/tokens/colors.dart';
import '../design_system/tokens/spacing.dart';

/// The four surfaces a member moves between — **Today · Dynamic · Explore ·
/// Us**, fixed by the canonical IA (Notion 02 §2, Warm Authority V5).
///
/// **Attention is deliberately NOT a tab.** Today already means "what needs
/// me today": the receiving side sees what is expected of them, the
/// direction-giving side sees what needs their response. Promoting Attention
/// to a fifth area would change the product's information architecture for
/// an MVP convenience, and adding Explore later would then force the whole
/// navigation to be rebuilt.
///
/// Explore is a light placeholder in Core Beta — the full library is out of
/// scope (Notion 01 §7) — but it keeps its slot so the IA is stable.
enum NavTab { today, dynamic, explore, us }

/// Persistent bottom navigation — 68dp, moss, four equal columns, the active
/// item in ivory over a 28×2 terracotta underline (DESIGN_SYSTEM §3).
///
/// Every screen inside the app lives above this. Without it the product is
/// not navigable: the other three surfaces exist but cannot be reached.
class NavShell extends StatelessWidget {
  const NavShell({
    super.key,
    required this.current,
    required this.dynamicId,
    required this.child,
  });

  final NavTab current;

  /// Null before a dynamic exists — the bar still renders so the app never
  /// looks broken, but the other surfaces have nothing to point at yet.
  final String? dynamicId;
  final Widget child;

  static const _height = 68.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DsColors.canvas,
      body: child,
      bottomNavigationBar: _Bar(current: current, dynamicId: dynamicId),
    );
  }
}

class _Bar extends StatelessWidget {
  const _Bar({required this.current, required this.dynamicId});

  final NavTab current;
  final String? dynamicId;

  @override
  Widget build(BuildContext context) {
    final id = dynamicId;
    return Container(
      height: NavShell._height + MediaQuery.paddingOf(context).bottom,
      color: DsColors.response,
      padding: EdgeInsets.only(bottom: MediaQuery.paddingOf(context).bottom),
      child: Row(
        children: [
          _Item(
            label: 'Today',
            shape: DsNavShape.home,
            active: current == NavTab.today,
            onTap: () => context.go(id == null ? '/today' : '/dynamics/$id/today'),
          ),
          _Item(
            label: 'Dynamic',
            shape: DsNavShape.page,
            active: current == NavTab.dynamic,
            onTap: id == null ? null : () => context.go('/dynamics/$id'),
          ),
          _Item(
            label: 'Explore',
            shape: DsNavShape.compass,
            active: current == NavTab.explore,
            onTap: id == null ? null : () => context.go('/dynamics/$id/explore'),
          ),
          _Item(
            label: 'Us',
            shape: DsNavShape.person,
            active: current == NavTab.us,
            onTap: id == null ? null : () => context.go('/dynamics/$id/us'),
          ),
        ],
      ),
    );
  }
}

class _Item extends StatelessWidget {
  const _Item({
    required this.label,
    required this.shape,
    required this.active,
    required this.onTap,
  });

  final String label;
  final DsNavShape shape;
  final bool active;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    // Muted-but-legible when inactive; ivory plus the terracotta underline
    // when active. Terracotta stays scarce — a 28×2 rule, never a fill.
    final color = active
        ? DsColors.surface
        : (onTap == null ? DsColors.muted : DsColors.onResponseMuted);

    return Expanded(
      child: Semantics(
        button: true,
        selected: active,
        label: label,
        child: InkWell(
          onTap: onTap,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              DsNavIcon(shape, color: color),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
              const SizedBox(height: DsSpacing.xs),
              // The active marker, 28×2 terracotta.
              Container(
                width: 28,
                height: 2,
                color: active ? DsColors.accent : Colors.transparent,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
