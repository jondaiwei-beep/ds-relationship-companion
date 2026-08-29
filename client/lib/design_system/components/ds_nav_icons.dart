import 'package:flutter/widgets.dart';

/// The four bottom-nav marks, drawn to the V5 spec: 18×18, 1.5 stroke,
/// round caps and joins, **no fill** (DESIGN_SYSTEM §3).
///
/// Drawn rather than taken from Material because the design's line-work is
/// part of the visual direction — Material glyphs are heavier and filled,
/// and read as a generic app.
class DsNavIcon extends StatelessWidget {
  const DsNavIcon(this.shape, {super.key, required this.color, this.size = 18});

  final DsNavShape shape;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) => CustomPaint(
        size: Size.square(size),
        painter: _NavIconPainter(shape, color),
      );
}

enum DsNavShape { home, page, compass, person, chevronRight, chevronLeft }

class _NavIconPainter extends CustomPainter {
  _NavIconPainter(this.shape, this.color);

  final DsNavShape shape;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = color;

    // The V5 paths are authored on a 24×24 grid.
    final k = size.width / 24.0;
    Offset at(double x, double y) => Offset(x * k, y * k);

    switch (shape) {
      case DsNavShape.home:
        canvas.drawPath(
          Path()
            ..moveTo(at(4, 11).dx, at(4, 11).dy)
            ..lineTo(at(12, 4).dx, at(12, 4).dy)
            ..lineTo(at(20, 11).dx, at(20, 11).dy)
            ..lineTo(at(20, 20).dx, at(20, 20).dy)
            ..lineTo(at(4, 20).dx, at(4, 20).dy)
            ..close(),
          p,
        );
      case DsNavShape.compass:
        // V5's Explore mark: a four-point star, close to the botanical
        // line motif and deliberately not a magnifying glass — Explore is
        // a library to wander, not a search box.
        canvas.drawPath(
          Path()
            ..moveTo(at(12, 4).dx, at(12, 4).dy)
            ..lineTo(at(14.5, 9).dx, at(14.5, 9).dy)
            ..lineTo(at(20, 12).dx, at(20, 12).dy)
            ..lineTo(at(14.5, 15).dx, at(14.5, 15).dy)
            ..lineTo(at(12, 20).dx, at(12, 20).dy)
            ..lineTo(at(9.5, 15).dx, at(9.5, 15).dy)
            ..lineTo(at(4, 12).dx, at(4, 12).dy)
            ..lineTo(at(9.5, 9).dx, at(9.5, 9).dy)
            ..close(),
          p,
        );
      case DsNavShape.person:
        canvas.drawCircle(at(12, 8), 3 * k, p);
        canvas.drawPath(
          Path()
            ..moveTo(at(6, 20).dx, at(6, 20).dy)
            ..cubicTo(at(7, 16).dx, at(7, 16).dy, at(9, 14).dx, at(9, 14).dy,
                at(12, 14).dx, at(12, 14).dy)
            ..cubicTo(at(15, 14).dx, at(15, 14).dy, at(17, 16).dx,
                at(17, 16).dy, at(18, 20).dx, at(18, 20).dy),
          p,
        );
      case DsNavShape.chevronRight:
        canvas.drawPath(
          Path()
            ..moveTo(at(9.5, 5).dx, at(9.5, 5).dy)
            ..lineTo(at(16, 12).dx, at(16, 12).dy)
            ..lineTo(at(9.5, 19).dx, at(9.5, 19).dy),
          p,
        );
      case DsNavShape.chevronLeft:
        canvas.drawPath(
          Path()
            ..moveTo(at(14.5, 5).dx, at(14.5, 5).dy)
            ..lineTo(at(8, 12).dx, at(8, 12).dy)
            ..lineTo(at(14.5, 19).dx, at(14.5, 19).dy),
          p,
        );
      case DsNavShape.page:
        canvas.drawRect(
          Rect.fromPoints(at(5, 4), at(19, 20)),
          p,
        );
        canvas.drawLine(at(8, 9), at(16, 9), p);
        canvas.drawLine(at(8, 13), at(16, 13), p);
    }
  }

  @override
  bool shouldRepaint(_NavIconPainter old) =>
      old.shape != shape || old.color != color;
}
