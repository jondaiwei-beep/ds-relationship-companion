import 'package:ds_relationship_companion/ds_design_system.dart';
import '../../../../l10n/app_localizations.dart';
import 'package:flutter/material.dart';

import '../../../../domain_client/models/today_view.dart';
import 'today_layout.dart';
import 'today_meta.dart';

class CompactRow extends StatelessWidget {
  const CompactRow({
    super.key,
    required this.index,
    required this.item,
    required this.zone,
    this.lastInGroup = false,
  });

  /// One-based position in the list, rendered as the design's zero-padded
  /// ordinal.
  final int index;

  final TodayItem item;

  /// The Dynamic's IANA zone, for rendering the due time (REQ-TIME-001).
  final String? zone;

  /// The last row closes against the next module's own border rather than
  /// drawing a second one.
  final bool lastInGroup;

  @override
  Widget build(BuildContext context) {
    final mark = assetFor(item);
    return Padding(
      padding: todayInset,
      child: Container(
        height: DsControlSizes.listRow,
        decoration: BoxDecoration(
          border: Border(
            // The last row in the group closes against the response module's
            // own top border, so it does not draw its own.
            bottom: BorderSide(
              color: lastInGroup
                  ? DsPrimitiveColors.transparent
                  : DsColors.borderOnRitualHairline,
              width: DsBorderWidths.hairline,
            ),
          ),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 34,
              child: Text(
                index.toString().padLeft(2, '0'),
                style: DsTextStyles.labelRitual.copyWith(
                  color: DsColors.textOnRitualMuted,
                ),
              ),
            ),
            DsSvg(
              asset: mark,
              // Each master licenses its own tones; muted is not universal.
              tone: mark.allowedTones.contains(DsAssetTone.muted)
                  ? DsAssetTone.muted
                  : DsAssetTone.primary,
              width: 26,
              height: 26,
            ),
            const SizedBox(width: DsSpacing.space4),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: DsTextStyles.bodyPrimary.copyWith(
                      color: DsColors.textOnRitualPrimary,
                      fontSize: 17,
                    ),
                  ),
                  const SizedBox(height: DsSpacing.space1),
                  Text(
                    itemMeta(L.of(context), item, zone: zone),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: DsTextStyles.bodySecondary.copyWith(
                      color: DsColors.textOnRitualMuted,
                      fontSize: todaySupportSize,
                      height: todaySupportHeight,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Words a person wrote and sent. The display face and Terracotta appear here
/// and, on this screen, only here.
