import 'package:ds_relationship_companion/ds_design_system.dart';
import 'package:flutter/material.dart';

import '../../../../domain_client/models/record.dart';

/// A plain line through the days that have a number; no library, no axis
/// clutter — the first and last values and the range are enough to read it.
class SeriesChart extends StatelessWidget {
  const SeriesChart({super.key, required this.points, this.height = 180});

  final List<SeriesPoint> points;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: CustomPaint(painter: SeriesPainter(points)),
    );
  }
}

class SeriesPainter extends CustomPainter {
  SeriesPainter(this.points);

  final List<SeriesPoint> points;

  @override
  void paint(Canvas canvas, Size size) {
    final pts = points.where((p) => p.value != null).toList(growable: false);
    if (pts.isEmpty) return;
    const inset = 12.0;
    final w = size.width - inset * 2;
    final h = size.height - inset * 2;
    var min = pts.first.value!;
    var max = min;
    for (final p in pts) {
      if (p.value! < min) min = p.value!;
      if (p.value! > max) max = p.value!;
    }
    final span = max - min == 0 ? 1.0 : max - min;
    Offset at(int i) {
      final x = pts.length == 1 ? w / 2 : w * i / (pts.length - 1);
      final y = h - (pts[i].value! - min) / span * h;
      return Offset(inset + x, inset + y);
    }

    final base = Paint()
      ..color = DsColors.borderOnRitualHairline
      ..strokeWidth = 1;
    canvas.drawLine(Offset(inset, inset + h), Offset(inset + w, inset + h), base);

    final line = Paint()
      ..color = DsColors.textOnRitualPrimary
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final path = Path()..moveTo(at(0).dx, at(0).dy);
    for (var i = 1; i < pts.length; i++) {
      final o = at(i);
      path.lineTo(o.dx, o.dy);
    }
    if (pts.length > 1) canvas.drawPath(path, line);

    final dot = Paint()..color = DsColors.textOnRitualPrimary;
    for (var i = 0; i < pts.length; i++) {
      canvas.drawCircle(at(i), 3, dot);
    }
  }

  @override
  bool shouldRepaint(covariant SeriesPainter old) => old.points != points;
}
