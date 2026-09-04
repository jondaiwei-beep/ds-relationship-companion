import 'package:ds_relationship_companion/ds_design_system.dart';
import 'package:flutter/material.dart';

/// The handful of universal marks this design system does not register as
/// assets: a close cross, a back and forward chevron, a settings mark.
///
/// SVG Freeze v1 rule 4 puts exactly this class of thing here rather than in
/// the manifest — "generic dividers, borders, circles, dots, progress axes and
/// layout rules are Flutter primitives driven by design tokens; they are not
/// standalone assets". So they are drawn, not imported, and they are not new
/// masters.
///
/// They existed as `Icons.close`, `Icons.arrow_back_ios_new` and
/// `Icons.settings_outlined`. Material's iconography is a different hand from
/// the 33 frozen masters beside it — heavier, rounder, and instantly
/// recognisable as Google's — which is the kind of detail that quietly tells
/// someone this screen was assembled rather than drawn. These match the frozen
/// navigation geometry instead: a 1.25–1.5 stroke on a 32×32 box, round caps.
enum DsGlyph { close, back, forward, settings, check, points, record, rules }

class DsGlyphIcon extends StatelessWidget {
  const DsGlyphIcon(
    this.glyph, {
    super.key,
    this.size = 22,
    this.color,
    this.semanticLabel,
  });

  final DsGlyph glyph;
  final double size;
  final Color? color;

  /// Supplied when the glyph is the only thing naming its control. Null when
  /// something beside it already says what the control does.
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final painted = CustomPaint(
      size: Size.square(size),
      painter: _GlyphPainter(
        glyph,
        color ?? DsColors.textOnRitualMuted,
      ),
    );

    return semanticLabel == null
        ? ExcludeSemantics(child: painted)
        : Semantics(label: semanticLabel, child: painted);
  }
}

class _GlyphPainter extends CustomPainter {
  const _GlyphPainter(this.glyph, this.color);

  final DsGlyph glyph;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    // Scaled from the frozen 32×32 navigation viewBox so the stroke stays in
    // the 1.25–1.5 range at the sizes these render at.
    final s = size.width / 32;
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.4 * s
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    Offset p(double x, double y) => Offset(x * s, y * s);

    switch (glyph) {
      case DsGlyph.close:
        canvas.drawLine(p(9, 9), p(23, 23), paint);
        canvas.drawLine(p(23, 9), p(9, 23), paint);

      case DsGlyph.back:
        canvas
          ..drawLine(p(19, 8), p(12, 16), paint)
          ..drawLine(p(12, 16), p(19, 24), paint);

      case DsGlyph.forward:
        canvas
          ..drawLine(p(13, 8), p(20, 16), paint)
          ..drawLine(p(20, 16), p(13, 24), paint);

      case DsGlyph.check:
        canvas
          ..drawLine(p(7, 16), p(13, 22), paint)
          ..drawLine(p(13, 22), p(25, 10), paint);

      // Three sliders, not a cogwheel. The cog's teeth are the loudest shape
      // in Material's set and the most obviously borrowed; four marks around a
      // ring — the first thing tried here — read as a camera control instead.
      // Horizontal rules with a dot on each are quiet, and this design system
      // is already built from rules and dots.
      // The points tab's mark. A small stack of tokens rather than a coin or
      // a star: a coin makes the thing currency and a star makes it a rating,
      // and this is neither — it is what is available to spend. Drawn under
      // SVG Freeze v1 rule 4 rather than added to the 33 frozen masters.
      case DsGlyph.points:
        for (final (i, y) in [21.0, 16.5, 12.0].indexed) {
          final inset = 4.0 + i * 1.5;
          canvas.drawRRect(
            RRect.fromRectAndRadius(
              Rect.fromLTRB(p(6 + inset, y).dx, p(0, y).dy,
                  p(26 - inset, y).dx, p(0, y + 3.2).dy),
              Radius.circular(1.6 * s),
            ),
            paint,
          );
        }

      // The record tab's mark: a month grid, one cell per day.
      case DsGlyph.record:
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromPoints(p(6, 8), p(26, 26)),
            Radius.circular(2 * s),
          ),
          paint,
        );
        canvas.drawLine(p(6, 13), p(26, 13), paint);
        for (final x in [11.0, 16.0, 21.0]) {
          canvas.drawCircle(p(x, 19.5), 1.3 * s, Paint()..color = color);
        }

      // The rules tab's mark: two standing rules and a shorter third — a
      // list that is written down, not a waveform (redesign-2026-09 §6).
      case DsGlyph.rules:
        canvas.drawLine(p(7, 10), p(25, 10), paint);
        canvas.drawLine(p(7, 16), p(25, 16), paint);
        canvas.drawLine(p(7, 22), p(18, 22), paint);

      case DsGlyph.settings:
        for (final (y, x) in [(10.0, 20.0), (16.0, 12.0), (22.0, 18.0)]) {
          canvas
            ..drawLine(p(6, y), p(26, y), paint)
            ..drawCircle(p(x, y), 2.2 * s, Paint()..color = color);
        }
    }
  }

  @override
  bool shouldRepaint(_GlyphPainter old) =>
      old.glyph != glyph || old.color != color;
}
