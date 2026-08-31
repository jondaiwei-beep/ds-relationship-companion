import 'package:ds_relationship_companion/ds_design_system.dart';
import 'package:flutter/material.dart';

import '../../../../domain_client/models/dynamic_view.dart';
import '../../../today/presentation/widgets/today_layout.dart';

/// The two people, side by side: who you are here, and who they are.
///
/// A role preset is a self-description and grants nothing (Notion 03 §2), so
/// it is set in quiet secondary type beneath the name rather than styled as a
/// rank. A member who has not named a role shows no role line at all — an
/// invented "Unassigned" would read as a status the product does not have.
class MemberPair extends StatelessWidget {
  const MemberPair({
    super.key,
    required this.members,
    required this.viewerIsCreator,
  });

  final List<MemberView> members;
  final bool viewerIsCreator;

  @override
  Widget build(BuildContext context) {
    if (members.isEmpty) return const SizedBox.shrink();

    final you = members.firstWhere(
      (m) => viewerIsCreator
          ? m.roleContext == 'CREATOR'
          : m.roleContext == 'PARTNER',
      orElse: () => members.first,
    );
    final other = members.where((m) => m.userId != you.userId).firstOrNull;

    return Padding(
      padding: todayInset,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: _Member(label: 'YOU', role: you.rolePreset)),
          const SizedBox(width: DsSpacing.space4),
          Expanded(
            child: other == null
                // Before anyone joins there is no second person to name, and
                // a placeholder silhouette would imply someone is there.
                ? const _Member(label: 'NO ONE YET', role: null, muted: true)
                : _Member(
                    label: (other.displayName ?? 'PARTNER').toUpperCase(),
                    role: other.rolePreset,
                    alignEnd: true,
                  ),
          ),
        ],
      ),
    );
  }
}

class _Member extends StatelessWidget {
  const _Member({
    required this.label,
    required this.role,
    this.alignEnd = false,
    this.muted = false,
  });

  final String label;
  final String? role;
  final bool alignEnd;

  /// Quietens the label for the slot that has no one in it yet.
  final bool muted;

  @override
  Widget build(BuildContext context) {
    final children = [
      // mark.partner-bond licenses primary and relationship only. The empty
      // slot stays primary and is quietened by its label instead, rather than
      // reaching for a tone this asset does not allow.
      const DsSvg(
        asset: DsAssets.markPartnerBond,
        tone: DsAssetTone.primary,
        width: 18,
        height: 18,
      ),
      const SizedBox(width: DsSpacing.space2),
      Flexible(
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: DsTextStyles.labelRitual.copyWith(
            color: muted
                ? DsColors.textOnRitualMuted
                : DsColors.textOnRitualPrimary,
          ),
        ),
      ),
    ];

    return Column(
      crossAxisAlignment: alignEnd
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: alignEnd
              ? MainAxisAlignment.end
              : MainAxisAlignment.start,
          children: alignEnd ? children.reversed.toList() : children,
        ),
        if (role != null) ...[
          const SizedBox(height: DsSpacing.space1),
          Text(
            _humanRole(role!),
            style: DsTextStyles.bodySecondary.copyWith(
              color: DsColors.textOnRitualMuted,
              fontSize: todaySupportSize,
              height: todaySupportHeight,
            ),
          ),
        ],
      ],
    );
  }
}

String _humanRole(String preset) => switch (preset) {
  'DOMINANT' => 'Dominant',
  'SUBMISSIVE' => 'Submissive',
  'SWITCH' => 'Switch',
  'CUSTOM' => 'Their own words',
  _ => preset,
};
