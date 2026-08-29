import 'package:flutter/material.dart';

import '../../../design_system/components/ds_button.dart';
import '../../../design_system/tokens/colors.dart';
import '../../../design_system/tokens/spacing.dart';
import '../../../design_system/tokens/typography.dart';
import '../../../domain_client/models/occurrence_view.dart';

/// The emotional peak of the product — Warm Authority V5 screen 6.
///
/// Their words become the page rather than a component on it.
///
/// This used to be composed like a confirmation receipt: a headline, a card
/// holding the quote, and a note explaining that responses become shared
/// history — an explanation of the product at the exact moment the product
/// should be proving itself. The partner's words were one element among
/// system chrome.
///
/// Dark fills the stage here and almost nowhere else. That is what the
/// scarcity is for: this is the response moment it was reserved for.
class AcknowledgementReceivedScreen extends StatelessWidget {
  const AcknowledgementReceivedScreen({
    super.key,
    required this.occurrence,
    this.onReturn,
  });

  final OccurrenceView occurrence;
  final VoidCallback? onReturn;

  @override
  Widget build(BuildContext context) {
    final ack = occurrence.acknowledgement;
    final them = ack?.senderDisplayName ?? 'your partner';

    return ColoredBox(
      color: DsColors.canvas,
      child: Column(
        children: [
          Expanded(
            child: ColoredBox(
              color: DsColors.response,
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                      DsSpacing.screenPadding, DsSpacing.xxl,
                      DsSpacing.screenPadding, DsSpacing.xxl),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'FROM ${them.toUpperCase()}',
                        style: DsType.eyebrow.copyWith(
                            color: DsColors.inkSoft),
                      ),
                      // Their words sit near the optical centre, not tucked
                      // under a headline.
                      Expanded(
                        child: Center(
                          child: SingleChildScrollView(
                            child: Text(
                              ack?.text ?? '',
                              style: DsType.h1.copyWith(
                                color: DsColors.surface,
                                fontSize: _size(ack?.text ?? ''),
                                height: 1.22,
                              ),
                            ),
                          ),
                        ),
                      ),
                      // The originating action gives context without
                      // becoming another card.
                      Text(
                        _footnote(ack?.sentAt),
                        style: DsType.fine.copyWith(color: DsColors.onResponseMuted),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          SafeArea(
              top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                  DsSpacing.screenPadding, DsSpacing.xxl,
                  DsSpacing.screenPadding, DsSpacing.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('You were seen.', style: DsType.h2),
                  const SizedBox(height: DsSpacing.xxl),
                  if (onReturn != null)
                    DsButton(
                      label: 'Back to Today',
                      outline: true,
                      onPressed: onReturn,
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Long words step down rather than being cut off. Nothing a partner wrote
  /// is ever ellipsized.
  double _size(String text) {
    if (text.length > 140) return 24;
    if (text.length > 80) return 28;
    return 34;
  }

  String _footnote(DateTime? at) {
    final title = occurrence.title;
    if (at == null) return title;
    final h = at.hour % 12 == 0 ? 12 : at.hour % 12;
    final m = at.minute.toString().padLeft(2, '0');
    return '$h:$m ${at.hour < 12 ? 'AM' : 'PM'} · $title';
  }
}
