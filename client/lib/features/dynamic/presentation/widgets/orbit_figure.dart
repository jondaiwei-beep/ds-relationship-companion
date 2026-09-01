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

    // Warm Gray, not the hairline olive.
    //
    // `decorativeRitualLine` (#2F3A2E) is the colour of a *rule* — a divider
    // that should barely register. This figure is not a divider; it is the one
    // piece of visual weight the screen has, and on the approved preview its
    // strokes read at roughly (180, 185, 170) against the #080B07 canvas.
    // Painted in the hairline olive they came out at (47, 58, 46) — about a
    // quarter of the reference's luminance — which turned a confident armature
    // into a ghost and left the upper two-thirds of the screen looking empty.
    //
    // `decorativeBotanical` is the token for decorative line work as opposed
    // to structural rules, and its Warm Gray is what the preview samples to.
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = DsBorderWidths.hairline
      ..color = DsColors.decorativeBotanical;

    // Proportions are the approved composition's own, taken off the preview
    // rather than eyeballed: with the tall orbit's height as the unit, its
    // width is 0.41 of that, the wide orbit is 1.08 across and 0.41 deep. The
    // previous numbers were fractions of the *box* instead, which made the
    // tall orbit half again too wide (0.38 of the width against the preview's
    // 0.29) and flattened the crossing into something much rounder than the
    // reference's narrow vertical loop.
    //
    // Deriving the widths from the height rather than the box also keeps the
    // figure honest when the box is short: its height is a share of the
    // viewport, so a box-relative width would stretch the whole composition
    // sideways on a small screen.
    final tallHeight = size.height * 0.86;
    final tall = Rect.fromCenter(
      center: centre,
      width: tallHeight * 0.41,
      height: tallHeight,
    );
    final wide = Rect.fromCenter(
      center: centre,
      width: tallHeight * 1.08,
      height: tallHeight * 0.41,
    );

    canvas.drawOval(tall, stroke);
    canvas.drawOval(wide, stroke);

    // Vertical axis: two stubs, above the tall orbit's crown and below its
    // foot, never crossing the interior.
    final stub = tallHeight * 0.09;
    canvas.drawLine(
      Offset(centre.dx, tall.top - stub),
      Offset(centre.dx, tall.top),
      stroke,
    );
    canvas.drawLine(
      Offset(centre.dx, tall.bottom),
      Offset(centre.dx, tall.bottom + stub),
      stroke,
    );

    // Horizontal axis: the same rule, and the reason this is not one line.
    //
    // The preview draws it only *outside* the wide orbit — from the screen
    // edge in to the orbit's left tangent, then again from the marker out to
    // the right edge. Drawn straight through as a single rule it read as a
    // line struck across the figure; interrupted, it reads as the horizon the
    // figure is standing on, which is what the composition is doing. The outer
    // ends bleed off both edges rather than stopping short, so the horizon has
    // no visible termination to make it look like a drawn object.
    canvas.drawLine(
      Offset(0, centre.dy),
      Offset(wide.left, centre.dy),
      stroke,
    );

    // The single Terracotta mark, where the two orbits cross on the right.
    // Terracotta is relational emphasis, and this is the one point on the
    // figure where the two paths actually meet.
    final marker = Offset(centre.dx + tall.width / 2, centre.dy);
    const markerRadius = 8.0;

    // The right-hand horizon starts at the marker, not at the wide orbit's
    // tangent: in the preview the mark is where the line re-enters, so it
    // reads as the point the horizon is pinned to.
    canvas.drawLine(
      Offset(marker.dx + markerRadius, centre.dy),
      Offset(size.width, centre.dy),
      stroke,
    );

    canvas.drawCircle(
      marker,
      markerRadius,
      Paint()..color = DsColors.textOnRitualRelationshipLarge,
    );
  }

  @override
  bool shouldRepaint(covariant _OrbitPainter oldDelegate) => false;
}
