import 'dart:ui' as ui;

import 'package:ds_relationship_companion/src/design_system/ds_assets.dart';
import 'package:ds_relationship_companion/src/design_system/generated/ds_design_tokens.g.dart';
import 'package:flutter/material.dart';

/// Deterministic B-4 ritual ground. Product content remains responsible for
/// clipping and safe-area behavior.
class DsRitualSurface extends StatelessWidget {
  const DsRitualSurface({required this.child, super.key, this.grain = true});

  final Widget child;
  final bool grain;

  @override
  Widget build(BuildContext context) => ColoredBox(
        color: DsColors.canvasRitual,
        child: Stack(
          fit: StackFit.expand,
          children: [if (grain) const _GrainLayer(), child],
        ),
      );
}

class _GrainLayer extends StatefulWidget {
  const _GrainLayer();

  @override
  State<_GrainLayer> createState() => _GrainLayerState();
}

class _GrainLayerState extends State<_GrainLayer> {
  ImageStream? _stream;
  ImageStreamListener? _listener;
  ui.Image? _image;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final nextStream = const AssetImage(DsTextureAssets.ritualGrain).resolve(
      createLocalImageConfiguration(context),
    );
    if (nextStream.key == _stream?.key) return;
    if (_listener != null) _stream?.removeListener(_listener!);
    _stream = nextStream;
    _listener = ImageStreamListener(
      (info, _) {
        if (mounted) setState(() => _image = info.image);
      },
      onError: (_, __) {
        if (mounted) setState(() => _image = null);
      },
    );
    _stream!.addListener(_listener!);
  }

  @override
  void dispose() {
    if (_listener != null) _stream?.removeListener(_listener!);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => IgnorePointer(
        child: ExcludeSemantics(
          child: CustomPaint(painter: _GrainPainter(_image)),
        ),
      );
}

class _GrainPainter extends CustomPainter {
  const _GrainPainter(this.image);

  final ui.Image? image;

  @override
  void paint(Canvas canvas, Size size) {
    // The vignette comes first, under the grain: B-2 freezes both, and the
    // grain is a film emulsion sitting on top of the light, not under it.
    //
    // It was frozen as `opacity.vignetteEdge = 0.18` and then never drawn,
    // which is why the surface read as flat black next to the approved
    // reference. The composition depends on it — the eye is meant to fall to
    // the centre of the page, and on a pure #080B07 field there is nothing to
    // fall towards.
    _paintVignette(canvas, size);

    final texture = image;
    if (texture == null) return;
    final paint = Paint()
      ..blendMode = BlendMode.softLight
      ..color = DsPrimitiveColors.bone.withValues(alpha: DsOpacity.grain);
    final tileWidth = texture.width.toDouble();
    final tileHeight = texture.height.toDouble();
    for (double x = 0; x < size.width; x += tileWidth) {
      for (double y = 0; y < size.height; y += tileHeight) {
        canvas.drawImage(texture, Offset(x, y), paint);
      }
    }
  }

  /// Darkens the edges towards the frozen maximum, leaving the centre alone.
  ///
  /// A radial stop rather than a border: the reference has no visible edge to
  /// it, and anything with a boundary would read as a frame around the page.
  /// The centre is fully transparent so the canvas colour is exactly the token
  /// wherever content sits.
  void _paintVignette(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = ui.Gradient.radial(
          rect.center,
          // Past the corners, so the darkest point of the ramp falls outside
          // the screen and no ring is ever visible on it.
          size.longestSide * 0.75,
          [
            DsPrimitiveColors.black.withValues(alpha: 0),
            DsPrimitiveColors.black.withValues(alpha: DsOpacity.vignetteEdge),
          ],
          // Nothing happens across the middle half; the ramp lives entirely in
          // the outer edges, which is what "vignette edge" names.
          [0.55, 1.0],
        ),
    );
  }

  @override
  bool shouldRepaint(_GrainPainter oldDelegate) => oldDelegate.image != image;
}
