import 'package:ds_relationship_companion/ds_design_system.dart';
import 'package:flutter/material.dart';

import 'today_layout.dart';

/// A surface header: the surface name, and partner presence when there is a
/// partner to name.
///
/// Shared with Dynamic rather than copied. Presence is the one thing on this
/// row carrying a privacy rule — Terracotta only when a partner is really
/// there, hidden entirely while access is unconfirmed — and two copies of that
/// rule would eventually disagree about it.
class TodayHeader extends StatelessWidget {
  const TodayHeader({
    super.key,
    this.title = 'Today',
    this.partnerName,
    this.context_,
  });

  /// The surface name shown at the left.
  final String title;

  /// Null when no partner presence may be shown — a Solo Dynamic, or a session
  /// whose authorization has not been confirmed.
  final String? partnerName;

  /// Replaces the presence line while the server is still being consulted.
  final String? context_;

  /// A named context wins over presence: while access is unconfirmed the
  /// header must say so rather than imply a partner is there.
  String get _label =>
      context_ ?? (partnerName == null ? 'Private' : '$partnerName is present');

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: todayInset.add(
        const EdgeInsets.only(top: DsSpacing.space5, bottom: DsSpacing.space6),
      ),
      child: Row(
        children: [
          Text(
            title,
            style: DsTextStyles.titlePage.copyWith(
              color: DsColors.textOnRitualPrimary,
              fontSize: 23,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: DsSpacing.space4),
          // Presence is a mark plus neutral copy. Terracotta carries the mark
          // only when a partner is actually present; the label stays Stone
          // because it sits below the Terracotta text size floor. A long
          // display name shrinks the label rather than pushing the row past
          // the viewport.
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                DsSvg(
                  asset: DsAssets.markPresence,
                  // mark.presence licenses primary and relationship only.
                  // Relationship — the Terracotta — is reserved for a partner
                  // who is actually there.
                  tone: partnerName == null
                      ? DsAssetTone.primary
                      : DsAssetTone.relationship,
                  width: 22,
                  height: 22,
                ),
                const SizedBox(width: DsSpacing.space2),
                Flexible(
                  child: Text(
                    _label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: DsTextStyles.bodySecondary.copyWith(
                      color: partnerName == null
                          ? DsColors.textOnRitualMuted
                          : DsColors.textOnRitualSecondary,
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
