import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import 'package:ds_relationship_companion/src/design_system/ds_assets.dart';
import 'package:ds_relationship_companion/src/design_system/generated/ds_design_tokens.g.dart';

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
    final texture = image;
    if (texture == null) return;
    final paint = Paint()
      ..blendMode = BlendMode.softLight
      ..color = DsPrimitiveColors.bone.withOpacity(DsOpacity.grain);
    final tileWidth = texture.width.toDouble();
    final tileHeight = texture.height.toDouble();
    for (double x = 0; x < size.width; x += tileWidth) {
      for (double y = 0; y < size.height; y += tileHeight) {
        canvas.drawImage(texture, Offset(x, y), paint);
      }
    }
  }

  @override
  bool shouldRepaint(_GrainPainter oldDelegate) => oldDelegate.image != image;
}
