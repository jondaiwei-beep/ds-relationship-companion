import 'package:ds_relationship_companion/ds_design_system.dart';
import 'package:flutter/material.dart';

import '../../../../app/shell/auth_image.dart';
import '../../../today/presentation/widgets/today_layout.dart';
import '../../../today/presentation/widgets/word_button.dart';

/// One line of the day: the clock at the left, what happened at the right,
/// and beneath it whatever was said about it and whatever may still be done.
class TimelineRow extends StatelessWidget {
  const TimelineRow({
    super.key,
    required this.clock,
    required this.text,
    this.sub,
    this.photoId,
    this.error,
    this.actions = const [],
    this.onLongPress,
  });

  final String clock;
  final String text;

  /// A note, a proof, a consequence — the words that went with it.
  final String? sub;
  /// The proof photo that went with a delivery.
  final String? photoId;
  final String? error;
  final List<(String, VoidCallback)> actions;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onLongPress: onLongPress,
      child: Padding(
        padding: todayInset.add(const EdgeInsets.symmetric(vertical: DsSpacing.space3)),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 48,
              child: Padding(
                padding: const EdgeInsets.only(top: 3),
                child: Text(
                  clock,
                  style: DsTextStyles.labelRitual.copyWith(
                    color: DsColors.textOnRitualMuted,
                    fontSize: todaySupportSize,
                  ),
                ),
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    text,
                    style: DsTextStyles.bodyPrimary.copyWith(color: DsColors.textOnRitualPrimary),
                  ),
                  if (sub != null && sub!.isNotEmpty) ...[
                    const SizedBox(height: DsSpacing.space1),
                    Text(
                      sub!,
                      style: DsTextStyles.bodySecondary.copyWith(
                        color: DsColors.textOnRitualSecondary,
                      ),
                    ),
                  ],
                  if (photoId != null) ...[
                    const SizedBox(height: DsSpacing.space2),
                    AuthImage(
                      mediaId: photoId!,
                      onTap: () => showProofPhoto(context, photoId!),
                    ),
                  ],
                  if (error != null) ...[
                    const SizedBox(height: DsSpacing.space1),
                    Text(
                      error!,
                      style: DsTextStyles.bodySecondary.copyWith(color: DsColors.stateError),
                    ),
                  ],
                  if (actions.isNotEmpty) ...[
                    const SizedBox(height: DsSpacing.space3),
                    Wrap(
                      spacing: DsSpacing.space2,
                      runSpacing: DsSpacing.space2,
                      children: [
                        for (final (label, onTap) in actions)
                          WordButton(label: label, onTap: onTap),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
