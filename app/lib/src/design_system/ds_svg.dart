import 'package:ds_relationship_companion/src/design_system/ds_assets.dart';
import 'package:ds_relationship_companion/src/design_system/generated/ds_design_tokens.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class DsSvg extends StatelessWidget {
  const DsSvg({
    required this.asset,
    required this.tone,
    super.key,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
    this.excludeFromSemantics = true,
    this.semanticLabel,
  });

  final DsAssetId asset;
  final DsAssetTone tone;
  final double? width;
  final double? height;
  final BoxFit fit;
  final bool excludeFromSemantics;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    if (!asset.allowedTones.contains(tone)) {
      throw FlutterError('${asset.id} does not allow $tone');
    }
    return SvgPicture.asset(
      asset.path,
      width: width,
      height: height,
      fit: fit,
      excludeFromSemantics: excludeFromSemantics,
      semanticsLabel: semanticLabel,
      colorFilter: ColorFilter.mode(_color(tone), BlendMode.srcIn),
    );
  }

  Color _color(DsAssetTone value) => switch (value) {
        DsAssetTone.primary => DsColors.iconPrimary,
        DsAssetTone.muted => DsColors.iconMuted,
        DsAssetTone.authority => DsColors.iconAuthority,
        DsAssetTone.relationship => DsColors.iconRelationship,
        DsAssetTone.decorative => DsColors.decorativeBotanical,
      };
}
