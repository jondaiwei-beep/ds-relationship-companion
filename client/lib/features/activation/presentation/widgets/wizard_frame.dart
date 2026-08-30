import 'package:ds_relationship_companion/ds_design_system.dart';
import 'package:flutter/material.dart';

import '../../../../app/shell/ds_primary_button.dart';

/// The frame every activation step shares: step counter, back, eyebrow,
/// question, body, then one action.
///
/// Shared because the four steps are one composition with different middles.
/// The design draws them from a single renderer for the same reason.
class WizardFrame extends StatelessWidget {
  const WizardFrame({
    super.key,
    required this.step,
    required this.eyebrow,
    required this.question,
    required this.child,
    required this.actionLabel,
    required this.onAction,
    this.onBack,
    this.lead,
    this.support,
    this.footnote,
    this.unmet,
    this.busy = false,
    this.notice,
  });

  /// 1-based, and always out of four. A wizard that hides its length asks for
  /// an open-ended commitment.
  final int step;

  final String eyebrow;
  final String question;
  final Widget child;
  final String actionLabel;
  final VoidCallback onAction;

  /// Null on the first step, and while a command is in flight.
  final VoidCallback? onBack;

  /// A mark above the eyebrow. Only step one carries one.
  final Widget? lead;

  /// What the question means, under it.
  final String? support;

  /// The reassurance above the action — "not your limits", "you can change
  /// this later". Part of the product, not decoration: this wizard asks
  /// someone to describe their relationship to a piece of software.
  final String? footnote;

  /// What is missing, shown under the action after it is pressed.
  final String? unmet;

  final bool busy;

  /// Recovery context: offline, a failed save, an ended session.
  final Widget? notice;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DsColors.canvasRitual,
      body: DsRitualSurface(
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) => SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: DsSpacing.space5,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _Top(step: step, onBack: busy ? null : onBack),
                    if (lead case final lead?) ...[
                      Center(child: lead),
                      const SizedBox(height: DsSpacing.space4),
                    ],
                    Text(
                      eyebrow,
                      style: DsTextStyles.labelRitual.copyWith(
                        color: DsColors.textOnRitualMuted,
                        fontSize: 10,
                        letterSpacing: 1.9,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: DsSpacing.space3),
                    Text(
                      question,
                      style: DsTextStyles.displayRitual.copyWith(
                        color: DsColors.textOnRitualPrimary,
                        fontSize: 31,
                        height: 40 / 31,
                      ),
                    ),
                    if (support case final support?) ...[
                      const SizedBox(height: DsSpacing.space4),
                      Text(
                        support,
                        style: DsTextStyles.bodySecondary.copyWith(
                          color: DsColors.textOnRitualMuted,
                          fontSize: 13,
                        ),
                      ),
                    ],
                    const SizedBox(height: DsSpacing.space6),
                    child,
                    const SizedBox(height: DsSpacing.space6),
                    if (notice case final notice?) ...[
                      notice,
                      const SizedBox(height: DsSpacing.space5),
                    ],
                    if (footnote case final footnote?) ...[
                      Text(
                        footnote,
                        style: DsTextStyles.bodySecondary.copyWith(
                          color: DsColors.textOnRitualMuted,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: DsSpacing.space4),
                    ],
                    // Never disabled for an unmade choice. Pressing it says
                    // what is missing; a dead control explains nothing to
                    // anyone and nothing at all to a screen reader.
                    DsPrimaryButton(
                      label: actionLabel,
                      busy: busy,
                      onPressed: onAction,
                    ),
                    if (unmet case final unmet?) ...[
                      const SizedBox(height: DsSpacing.space4),
                      Center(
                        child: Text(
                          unmet,
                          style: DsTextStyles.bodySecondary.copyWith(
                            color: DsColors.stateError,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: DsSpacing.space6),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Top extends StatelessWidget {
  const _Top({required this.step, required this.onBack});

  final int step;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: DsLayoutSizes.touchTarget,
      child: Row(
        children: [
          if (onBack != null)
            IconButton(
              onPressed: onBack,
              iconSize: 18,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(
                minWidth: DsLayoutSizes.touchTarget,
                minHeight: DsLayoutSizes.touchTarget,
              ),
              icon: const Icon(
                Icons.arrow_back_ios_new,
                color: DsColors.textOnRitualSecondary,
              ),
            ),
          const Spacer(),
          Text(
            '$step of 4',
            style: DsTextStyles.bodySecondary.copyWith(
              color: DsColors.textOnRitualMuted,
              fontSize: 11,
              letterSpacing: 0.6,
            ),
          ),
        ],
      ),
    );
  }
}
