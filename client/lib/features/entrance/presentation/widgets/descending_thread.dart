import 'package:ds_relationship_companion/ds_design_system.dart';
import 'package:flutter/material.dart';

/// The thread descending from the mark to a point of light.
///
/// The one piece of pure atmosphere in the entrance composition, and the
/// reason it reads as considered rather than empty. Ported from
/// `render-entrance.cjs`, which is the authority on its geometry.
///
/// It fades in from nothing rather than starting at full strength: the design
/// reads as light gathering, and a flat line reads as a border.
class DescendingThread extends StatelessWidget {
  const DescendingThread({
    super.key,
    required this.height,
    this.glow = true,
  });

  final double height;

  /// The point of light where the thread ends.
  final bool glow;

  @override
  Widget build(BuildContext context) {
    // 14dp of glow either side of a 1dp line, so the widget is as wide as the
    // halo rather than as wide as the thread.
    return SizedBox(
      width: 28,
      height: height + (glow ? 14 : 0),
      child: CustomPaint(
        painter: _ThreadPainter(length: height, glow: glow),
      ),
    );
  }
}

class _ThreadPainter extends CustomPainter {
  const _ThreadPainter({required this.length, required this.glow});

  final double length;
  final bool glow;

  @override
  void paint(Canvas canvas, Size size) {
    final x = size.width / 2;
    const t = DsPrimitiveColors.terracotta;

    canvas.drawRect(
      Rect.fromLTWH(x - 0.5, 0, 1, length),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            t.withValues(alpha: 0.05),
            t.withValues(alpha: 0.38),
            t.withValues(alpha: 0.90),
          ],
          stops: const [0, 0.55, 1],
        ).createShader(Rect.fromLTWH(x - 0.5, 0, 1, length)),
    );

    if (!glow) return;
    for (final (radius, alpha) in const [(14.0, 0.07), (6.0, 0.16), (1.8, 0.95)]) {
      canvas.drawCircle(
        Offset(x, length),
        radius,
        Paint()..color = t.withValues(alpha: alpha),
      );
    }
  }

  @override
  bool shouldRepaint(_ThreadPainter old) =>
      old.length != length || old.glow != glow;
}
