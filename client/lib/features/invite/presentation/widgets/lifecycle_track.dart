import 'package:ds_relationship_companion/ds_design_system.dart';
import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';

/// Where this invitation stands: Pending → Accepted → Expired → Revoked.
///
/// The contract calls this the screen's "lifecycle geometry" and asks that it
/// be preserved even while the current state is unknown. That reads as a
/// contradiction until the two halves are separated: the track holds its place
/// so nothing moves when truth arrives, and **no node is filled** until the
/// server has said which one is true.
///
/// A cached position is outlined rather than filled, and paired with words —
/// the one case where the screen shows something it cannot currently vouch
/// for, so shape and copy carry it together rather than colour alone.
class LifecycleTrack extends StatelessWidget {
  const LifecycleTrack({super.key, this.current, this.cached});

  /// The server-confirmed position, or null while it is unknown.
  final int? current;

  /// A last-known position, shown as an outline.
  final int? cached;

  /// The four positions, in order. Read from the locale rather than held as
  /// a constant: the track's geometry is fixed, its words are not.
  static List<String> _labelsOf(BuildContext context) {
    final l = L.of(context);
    return [
      l.inviteLifecyclePending,
      l.inviteLifecycleAccepted,
      l.inviteLifecycleExpired,
      l.inviteLifecycleRevoked,
    ];
  }

  @override
  Widget build(BuildContext context) {
    final labels = _labelsOf(context);
    return Column(
      children: [
        SizedBox(
          height: 18,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Container(
                  height: DsBorderWidths.hairline,
                  color: DsColors.borderOnRitualHairline,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  for (final i in List.generate(labels.length, (i) => i))
                    _Node(
                      filled: i == current,
                      outlined: i == cached,
                    ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: DsSpacing.space3),
        // Equal columns rather than natural widths: "Accepted" and "Revoked"
        // are wider than the nodes they sit under, and laid out freely they
        // push each other off the 390dp viewport.
        Row(
          children: [
            for (final (i, label) in labels.indexed)
              Expanded(
                child: Text(
                  label,
                  textAlign: switch (i) {
                    0 => TextAlign.left,
                    3 => TextAlign.right,
                    _ => TextAlign.center,
                  },
                  style: DsTextStyles.bodySecondary.copyWith(
                    fontSize: 12,
                    color: i == current
                        ? DsColors.textOnRitualPrimary
                        : DsColors.textOnRitualMuted,
                    fontWeight:
                        i == current ? FontWeight.w500 : FontWeight.w400,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _Node extends StatelessWidget {
  const _Node({required this.filled, required this.outlined});

  final bool filled;
  final bool outlined;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 18,
      height: 18,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: DsColors.canvasRitual,
        border: Border.all(
          color: filled
              ? DsPrimitiveColors.terracotta
              : (outlined
                  ? DsColors.textOnRitualSecondary
                  : DsColors.borderOnRitualHairline),
          width: outlined ? 1.6 : 1.2,
        ),
      ),
      child: filled
          ? Center(
              child: Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: DsPrimitiveColors.terracotta,
                ),
              ),
            )
          : null,
    );
  }
}
