import 'package:flutter/material.dart';

import '../../../design_system/components/ds_button.dart';
import '../../../design_system/components/ds_text.dart';
import '../../../design_system/tokens/colors.dart';
import '../../../design_system/tokens/spacing.dart';
import '../../../design_system/tokens/typography.dart';
import '../../../domain_client/models/occurrence_view.dart';

/// After completing — Warm Authority V5 screen 3.
///
/// This screen carries product red line #2: the action is done, but the
/// moment is not finished until a real person responds.
///
/// It used to say "complete" and "waiting" four times across four
/// containers, ending in a dark card that read as a status receipt — which
/// closed the loop visually while the copy insisted it was open.
///
/// Now the distinction is structural rather than stated: the completed
/// action is one plain settled line, and the largest region on the screen is
/// **an empty place reserved for words that have not arrived**. Nothing
/// fills it but a person.
class WaitingScreen extends StatelessWidget {
  const WaitingScreen({
    super.key,
    required this.occurrence,
    this.partnerName,
    this.onBack,
  });

  final OccurrenceView occurrence;

  /// Naming them keeps this about the two of them rather than about a
  /// workflow state. "Waiting for human response" sounds like a queue.
  final String? partnerName;
  final VoidCallback? onBack;

  String get _them => partnerName ?? 'your partner';

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: DsColors.canvas,
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(DsSpacing.screenPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DsEyebrow('Shared with $_them', terra: true),
              const SizedBox(height: DsSpacing.md),
              Text(occurrence.title, style: DsType.h1),
              const SizedBox(height: DsSpacing.md),
              // Said once, plainly. Repeating it made the screen anxious.
              Text(_completedLine(),
                  style: DsType.body.copyWith(color: DsColors.muted)),

              const SizedBox(height: DsSpacing.xxxl),
              _ResponsePlace(them: _them),

              const SizedBox(height: DsSpacing.xxl),
              // A real outline, not warm gray — the old treatment read as a
              // disabled control on a screen with nothing else to press.
              DsButton(label: 'Back to Today', outline: true, onPressed: onBack),
              const SizedBox(height: DsSpacing.xxl),
            ],
          ),
        ),
      ),
    );
  }

  String _completedLine() {
    final at = occurrence.completedAt;
    if (at == null) return 'You completed this.';
    final h = at.hour % 12 == 0 ? 12 : at.hour % 12;
    final m = at.minute.toString().padLeft(2, '0');
    return 'You completed this at $h:$m ${at.hour < 12 ? 'AM' : 'PM'}.';
  }
}

/// The space held open for someone else's words.
///
/// Deliberately not a card and not filled: a dark "done" panel would close
/// the loop that the whole screen exists to keep open. The terracotta rail
/// stops short of the bottom so the edge reads as unfinished rather than as
/// a progress track.
///
/// This is not a two-step indicator. No dots, no percentage, no checkmarks —
/// the emptiness is the message.
class _ResponsePlace extends StatelessWidget {
  const _ResponsePlace({required this.them});

  final String them;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 148,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stops before the bottom: an open edge, not a filled track.
          Container(
            width: 2,
            height: 104,
            decoration: const BoxDecoration(
              color: DsColors.accent,
              borderRadius: BorderRadius.all(Radius.circular(2)),
            ),
          ),
          const SizedBox(width: DsSpacing.xl),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Waiting for $them's words",
                    style: DsType.fine.copyWith(color: DsColors.muted)),
                const SizedBox(height: DsSpacing.xl),
                // The quotation mark opens and nothing follows it. That gap
                // is the distinction between done and answered.
                Text(
                  '“',
                  style: DsType.h1.copyWith(
                    fontSize: 44,
                    color: DsColors.line,
                    height: 0.9,
                  ),
                ),
                const Spacer(),
                Text(
                  "We'll let you know when $them responds.",
                  style: DsType.fine.copyWith(color: DsColors.muted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
