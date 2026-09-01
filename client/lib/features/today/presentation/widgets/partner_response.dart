import 'package:ds_relationship_companion/ds_design_system.dart';
import '../../../../l10n/app_localizations.dart';
import 'package:flutter/material.dart';

import '../../../../domain_client/models/today_view.dart';
import 'today_layout.dart';
import 'today_meta.dart';

/// Words a person wrote and sent. The display face and Terracotta appear here
/// and, on this screen, only here.
/// Four corner marks instead of a border.
///
/// Drawn rather than composed from Containers so the brackets stay short and
/// square at any height, and so nothing closes into a box: an unbroken frame
/// would read as a card, which is what the design is avoiding here.
class _BracketDecoration extends Decoration {
  const _BracketDecoration();

  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) => _BracketPainter();
}

class _BracketPainter extends BoxPainter {
  /// Long enough to read as a deliberate mark, short enough never to look
  /// like an unfinished border.
  static const _arm = 14.0;

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration cfg) {
    final size = cfg.size;
    if (size == null) return;
    final r = offset & size;
    final p = Paint()
      ..color = DsColors.borderOnRitualRelationship
      ..strokeWidth = DsBorderWidths.hairline
      ..style = PaintingStyle.stroke;

    for (final (corner, dx, dy) in [
      (r.topLeft, 1.0, 1.0),
      (r.topRight, -1.0, 1.0),
      (r.bottomLeft, 1.0, -1.0),
      (r.bottomRight, -1.0, -1.0),
    ]) {
      canvas.drawLine(corner, corner.translate(_arm * dx, 0), p);
      canvas.drawLine(corner, corner.translate(0, _arm * dy), p);
    }
  }
}

class PartnerResponse extends StatelessWidget {
  const PartnerResponse({super.key, required this.response});

  final RecentResponse response;

  @override
  Widget build(BuildContext context) {
    return Container(
      // The inset is a margin, not padding: the brackets are drawn on the
      // decoration, so with padding they landed on the container's full width
      // and ran off both edges of the screen.
      margin: todayInset.add(
        const EdgeInsets.only(top: DsSpacing.space2),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: DsSpacing.space4,
        vertical: DsSpacing.space4,
      ),
      // Corner brackets, not full rules. The approved composition sets the
      // partner's words apart with four short marks at the corners — the
      // difference between "this is quoted from a person" and "this is the
      // next row of a table". Terracotta, because this is the one thing on
      // Today another human actually wrote.
      decoration: const _BracketDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const DsSvg(
                asset: DsAssets.stateAcknowledged,
                tone: DsAssetTone.relationship,
                width: 26,
                height: 26,
              ),
              const SizedBox(width: DsSpacing.space3),
              // labelRitual carries 2.4 tracking, so this line is wider than
              // it reads. It shrinks rather than pushing the row off-screen.
              Flexible(
                child: Text(
                  responseHeading(L.of(context), response),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: DsTextStyles.labelRitual.copyWith(
                    color: DsColors.textOnRitualSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: DsSpacing.space3),
          Padding(
            padding: const EdgeInsets.only(left: DsSpacing.space10),
            child: Text(
              '“${response.text}”',
              style: DsTextStyles.displayPartner.copyWith(
                color: DsColors.relationshipAcknowledgement,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
