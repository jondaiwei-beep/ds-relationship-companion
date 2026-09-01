import 'package:ds_relationship_companion/ds_design_system.dart';
import '../../../../l10n/app_localizations.dart';
import 'package:flutter/material.dart';

import '../../../../domain_client/models/today_view.dart';
import 'today_layout.dart';
import 'today_meta.dart';

/// Words a person wrote and sent. The display face and Terracotta appear here
/// and, on this screen, only here.
class PartnerResponse extends StatelessWidget {
  const PartnerResponse({super.key, required this.response});

  final RecentResponse response;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: DsSpacing.space2),
      padding: todayInset.add(
        const EdgeInsets.symmetric(vertical: DsSpacing.space4),
      ),
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: DsColors.borderOnRitualHairline),
          bottom: BorderSide(color: DsColors.borderOnRitualHairline),
        ),
      ),
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
