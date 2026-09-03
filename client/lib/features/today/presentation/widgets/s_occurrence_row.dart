import 'package:ds_relationship_companion/ds_design_system.dart';
import 'package:flutter/material.dart';

import 'word_button.dart';
import 'today_layout.dart';

/// One thing asked of the s today. The row is the control: a tap delivers,
/// a long press (or a tap on something already said) shows the other words.
///
/// Paused rows are greyed and inert. Nothing here is red, nothing counts down.
class SOccurrenceRow extends StatelessWidget {
  const SOccurrenceRow({
    super.key,
    required this.title,
    this.detail,
    this.meta,
    this.status,
    this.note,
    this.error,
    this.muted = false,
    this.expanded = false,
    this.actions = const [],
    this.onTap,
    this.onLongPress,
  });

  final String title;
  final String? detail;

  /// Due time and points, when there are any.
  final String? meta;

  /// What has been said on either axis, in the D's or the s's own words.
  final String? status;

  /// The s's own attached line, echoed back.
  final String? note;

  /// Why the last attempt did not go through.
  final String? error;

  final bool muted;
  final bool expanded;
  final List<(String, VoidCallback)> actions;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final primary = muted ? DsColors.textOnRitualMuted : DsColors.textOnRitualPrimary;
    final secondary = DsColors.textOnRitualMuted;
    return InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        padding: todayInset.add(const EdgeInsets.symmetric(vertical: DsSpacing.space4)),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: DsColors.borderOnRitualHairline)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: DsTextStyles.bodyPrimary.copyWith(color: primary),
                  ),
                ),
                if (meta != null) ...[
                  const SizedBox(width: DsSpacing.space3),
                  Text(
                    meta!,
                    style: DsTextStyles.bodySecondary.copyWith(color: secondary),
                  ),
                ],
              ],
            ),
            if (detail != null && detail!.isNotEmpty) ...[
              const SizedBox(height: DsSpacing.space1),
              Text(
                detail!,
                style: DsTextStyles.bodySecondary.copyWith(color: secondary),
              ),
            ],
            if (note != null) ...[
              const SizedBox(height: DsSpacing.space2),
              Text(
                note!,
                style: DsTextStyles.bodySecondary.copyWith(color: DsColors.textOnRitualSecondary),
              ),
            ],
            if (status != null) ...[
              const SizedBox(height: DsSpacing.space2),
              Text(
                status!,
                style: DsTextStyles.bodySecondary.copyWith(color: DsColors.textOnRitualSecondary),
              ),
            ],
            if (error != null) ...[
              const SizedBox(height: DsSpacing.space2),
              Text(
                error!,
                style: DsTextStyles.bodySecondary.copyWith(color: DsColors.textOnRitualSecondary),
              ),
            ],
            if (expanded && actions.isNotEmpty) ...[
              const SizedBox(height: DsSpacing.space4),
              Wrap(
                spacing: DsSpacing.space3,
                runSpacing: DsSpacing.space3,
                children: [
                  for (final (label, onTap) in actions)
                    WordButton(label: label, onTap: onTap),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
