import 'package:ds_relationship_companion/ds_design_system.dart';
import 'package:flutter/material.dart';

import 'word_button.dart';
import 'today_layout.dart';

/// Something the s has said that the D has not answered. Tapping opens it —
/// which is the receipt — and shows the five words the D may answer with.
class DNeedsMeRow extends StatelessWidget {
  const DNeedsMeRow({
    super.key,
    required this.title,
    required this.said,
    this.day,
    this.note,
    this.proof,
    this.error,
    required this.expanded,
    required this.actions,
    required this.onTap,
  });

  final String title;

  /// The s's outcome in words, with its time.
  final String said;

  /// Shown when the occurrence is not from today.
  final String? day;
  final String? note;
  final String? proof;
  final String? error;
  final bool expanded;
  final List<(String, VoidCallback)> actions;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final secondary = DsTextStyles.bodySecondary.copyWith(color: DsColors.textOnRitualSecondary);
    final muted = DsTextStyles.bodySecondary.copyWith(color: DsColors.textOnRitualMuted);
    return InkWell(
      onTap: onTap,
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
                    style: DsTextStyles.bodyPrimary.copyWith(color: DsColors.textOnRitualPrimary),
                  ),
                ),
                if (day != null) ...[
                  const SizedBox(width: DsSpacing.space3),
                  Text(day!, style: muted),
                ],
              ],
            ),
            const SizedBox(height: DsSpacing.space1),
            Text(said, style: secondary),
            if (note != null) ...[
              const SizedBox(height: DsSpacing.space1),
              Text(note!, style: secondary),
            ],
            if (proof != null) ...[
              const SizedBox(height: DsSpacing.space1),
              Text(proof!, style: muted),
            ],
            if (error != null) ...[
              const SizedBox(height: DsSpacing.space2),
              Text(error!, style: secondary),
            ],
            if (expanded) ...[
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
