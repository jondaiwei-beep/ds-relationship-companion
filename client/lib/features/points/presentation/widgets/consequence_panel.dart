import 'package:ds_relationship_companion/ds_design_system.dart';
import 'package:flutter/material.dart';

import '../../../../domain_client/models/points.dart';
import '../../../../l10n/app_localizations.dart';

/// What the person who set an expectation sees when it was not done, and the
/// couple has an agreement covering it.
///
/// This is where "more authority and more warmth" is either true or it is not.
/// Three properties are non-negotiable, and are why this is a widget of its
/// own rather than a row in a list:
///
/// 1. **"Let it go" carries identical weight to "Hold to it".** Not a text
///    link, not smaller, not grey. Mercy is not the escape hatch from
///    authority — it is one of two equal exercises of it, and it is the move
///    an automatic system structurally cannot make.
/// 2. **There is no default and no timer.** If this is never opened, nothing
///    happens, forever. The line saying so is on screen, because someone who
///    has just missed something needs to know the app is not about to act on
///    its own.
/// 3. **The quoted text is the couple's own words.** The app adds nothing and
///    never rephrases them as a verdict.
///
/// Obedience's equivalent has a `Randomize` field — "add multiple punishments
/// and let fate decide". That is the abdication of the thing the dominant is
/// supposedly holding: if a die chose, nobody did.
class ConsequencePanel extends StatelessWidget {
  const ConsequencePanel({
    super.key,
    required this.agreement,
    required this.onHold,
    required this.onLetGo,
    required this.onTalk,
    this.busy = false,
  });

  final ConsequenceAgreement agreement;
  final VoidCallback onHold;
  final VoidCallback onLetGo;
  final VoidCallback onTalk;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);

    return Container(
      padding: const EdgeInsets.all(DsSpacing.space5),
      decoration: BoxDecoration(
        color: DsColors.surfaceRitualRaised,
        border: Border.all(
          color: DsColors.textOnRitualMuted.withValues(alpha: 0.25),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l.consequenceHeading,
            style: DsTextStyles.labelRitual.copyWith(
              color: DsColors.textOnRitualMuted,
              fontSize: 10,
              letterSpacing: 1.9,
            ),
          ),
          const SizedBox(height: DsSpacing.space4),

          // Their words, quoted. Never restated by the app.
          Text(
            agreement.label,
            style: DsTextStyles.bodySecondary.copyWith(
              color: DsColors.textOnRitualMuted,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: DsSpacing.space2),
          Text(
            agreement.consequence,
            style: DsTextStyles.bodyPrimary.copyWith(
              color: DsColors.textOnRitualPrimary,
            ),
          ),

          const SizedBox(height: DsSpacing.space5),
          // IntrinsicHeight so the three doors match even when one label
          // wraps and another does not: a shorter box reads as a lesser
          // option, and "Let it go" must never look like the small one. A
          // width-only check missed this — the render did not.
          IntrinsicHeight(
            child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Equal width, equal treatment. Holding comes first because it
              // is what was agreed, not because it is preferred.
              Expanded(
                child: _Door(label: l.consequenceHold, onTap: busy ? null : onHold),
              ),
              const SizedBox(width: DsSpacing.space2),
              Expanded(
                child: _Door(label: l.consequenceLetGo, onTap: busy ? null : onLetGo),
              ),
              const SizedBox(width: DsSpacing.space2),
              Expanded(
                child: _Door(label: l.consequenceTalk, onTap: busy ? null : onTalk),
              ),
            ],
            ),
          ),

          const SizedBox(height: DsSpacing.space3),
          Text(
            l.consequenceNothingHappens,
            style: DsTextStyles.bodySecondary.copyWith(
              color: DsColors.textOnRitualMuted,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

/// One of three, all identical. Styling any of them as primary would be the
/// app expressing a preference about someone else's relationship.
class _Door extends StatelessWidget {
  const _Door({required this.label, required this.onTap});

  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(
        vertical: DsSpacing.space3,
        horizontal: DsSpacing.space1,
      ),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        border: Border.all(
          color: onTap == null
              ? DsColors.textOnRitualMuted.withValues(alpha: 0.2)
              : DsPrimitiveColors.terracotta,
        ),
      ),
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: DsTextStyles.labelRitual.copyWith(
          color: onTap == null
              ? DsColors.textOnRitualMuted
              : DsPrimitiveColors.terracotta,
          fontSize: 11,
        ),
      ),
    ),
  );
}
