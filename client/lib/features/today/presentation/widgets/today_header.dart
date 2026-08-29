import 'package:ds_relationship_companion/ds_design_system.dart';
import 'package:flutter/material.dart';

import 'today_layout.dart';

/// Today's header: the surface name, and partner presence when there is a
/// partner to name.
class TodayHeader extends StatelessWidget {
  const TodayHeader({super.key, this.partnerName, this.context_});

  /// Null when no partner presence may be shown — a Solo Dynamic, or a session
  /// whose authorization has not been confirmed.
  final String? partnerName;

  /// Replaces the presence line while the server is still being consulted.
  final String? context_;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: todayInset.add(
        const EdgeInsets.only(top: DsSpacing.space5, bottom: DsSpacing.space6),
      ),
      child: Row(
        children: [
          Text(
            'Today',
            style: DsTextStyles.titlePage.copyWith(
              color: DsColors.textOnRitualPrimary,
              fontSize: 23,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: DsSpacing.space4),
          // Presence is a mark plus neutral copy. Terracotta carries the mark;
          // the label stays Stone because it sits below the Terracotta text
          // size floor. A long display name shrinks the label rather than
          // pushing the row past the viewport.
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const DsSvg(
                  asset: DsAssets.markPresence,
                  tone: DsAssetTone.relationship,
                  width: 22,
                  height: 22,
                ),
                const SizedBox(width: DsSpacing.space2),
                Flexible(
                  child: Text(
                    'Morgan is present',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: DsTextStyles.bodySecondary.copyWith(
                      color: DsColors.textOnRitualSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
