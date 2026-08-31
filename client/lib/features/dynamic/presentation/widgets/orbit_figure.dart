import 'package:ds_relationship_companion/ds_design_system.dart';
import 'package:flutter/material.dart';

/// The two crossed orbits from the approved composition.
///
/// Drawn as geometry rather than shipped as an asset on purpose. The SVG
/// freeze forbids tracing path data out of a preview, and there is no approved
/// master for this figure; two ellipses and a marker are describable exactly,
/// so nothing is being copied and nothing is being invented.
///
/// It carries no information the rows below do not also state in words, so it
/// is excluded from semantics — a screen reader should not have to listen to a
/// decoration.
class OrbitFigure extends StatelessWidget {
  const OrbitFigure({super.key, this.height = 300});

  final double height;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: CustomPaint(painter: _OrbitPainter()),
      ),
    );
  }
}

class _OrbitPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final centre = Offset(size.width / 2, size.height / 2);

    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = DsColors.decorativeRitualLine;

    // Proportions follow the approved composition: a tall narrow orbit crossed
    // by a wide flat one, both centred, with the axes running slightly past
    // where the curves meet them.
    final tall = Rect.fromCenter(
      center: centre,
      width: size.width * 0.38,
      height: size.height * 0.86,
    );
    final wide = Rect.fromCenter(
      center: centre,
      width: size.width * 0.84,
      height: size.height * 0.40,
    );

    canvas.drawOval(tall, stroke);
    canvas.drawOval(wide, stroke);

    // Axis rules, stopping short of the edges rather than bleeding off-screen.
    canvas.drawLine(
      Offset(centre.dx, centre.dy - size.height * 0.48),
      Offset(centre.dx, centre.dy - size.height * 0.40),
      stroke,
    );
    canvas.drawLine(
      Offset(centre.dx, centre.dy + size.height * 0.40),
      Offset(centre.dx, centre.dy + size.height * 0.48),
      stroke,
    );
    canvas.drawLine(
      Offset(centre.dx - size.width * 0.46, centre.dy),
      Offset(centre.dx + size.width * 0.46, centre.dy),
      stroke,
    );

    // The single Terracotta mark, where the two orbits cross on the right.
    // Terracotta is relational emphasis, and this is the one point on the
    // figure where the two paths actually meet.
    canvas.drawCircle(
      Offset(centre.dx + tall.width / 2, centre.dy),
      9,
      Paint()..color = DsColors.textOnRitualRelationshipLarge,
    );
  }

  @override
  bool shouldRepaint(covariant _OrbitPainter oldDelegate) => false;
}
