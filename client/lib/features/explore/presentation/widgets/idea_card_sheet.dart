import 'package:ds_relationship_companion/ds_design_system.dart';
import 'package:flutter/material.dart';

import '../../../../domain_client/models/explore.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../today/presentation/widgets/secondary_button.dart';
import '../../../today/presentation/widgets/word_button.dart';

/// The verbs a card offers this side (04-explore.md §2). Every one is a verb;
/// the server accepts exactly these strings.
List<(String, String)> ideaCardActions(L l, {required bool isD, required String dName}) => [
      if (isD) ...[
        (l.exploreActAddToday, IdeaCardAction.addToday),
        (l.exploreActAddRule, IdeaCardAction.addRule),
      ] else
        (l.exploreActPropose(dName), IdeaCardAction.addToday),
      (l.exploreActSave, IdeaCardAction.save),
      (l.exploreActTriedAgain, IdeaCardAction.triedAgain),
      (l.exploreActTriedNever, IdeaCardAction.triedNever),
    ];

/// One card, read in full, with its verbs. Returns the chosen action string,
/// [drawAgainSentinel] when the person asked for another card, or null.
Future<String?> showIdeaCardSheet(
  BuildContext context, {
  required IdeaCard card,
  required bool isD,
  required String dName,
  bool canDrawAgain = false,
}) {
  return showModalBottomSheet<String>(
    context: context,
    backgroundColor: DsColors.canvasRitual,
    isScrollControlled: true,
    builder: (sheet) => _IdeaCardSheet(card: card, isD: isD, dName: dName, canDrawAgain: canDrawAgain),
  );
}

const drawAgainSentinel = '__draw_again__';

class _IdeaCardSheet extends StatelessWidget {
  const _IdeaCardSheet({
    required this.card,
    required this.isD,
    required this.dName,
    required this.canDrawAgain,
  });

  final IdeaCard card;
  final bool isD;
  final String dName;
  final bool canDrawAgain;

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    final locale = Localizations.localeOf(context).toString();
    final needs = card.needs(locale);
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(DsSpacing.space5, DsSpacing.space6, DsSpacing.space5, DsSpacing.space6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(card.title(locale), style: DsTextStyles.bodyPrimary.copyWith(color: DsColors.textOnRitualPrimary)),
            const SizedBox(height: DsSpacing.space2),
            Text(
              l.exploreCardIntensity(card.intensity),
              style: DsTextStyles.bodySecondary.copyWith(color: DsColors.textOnRitualMuted),
            ),
            const SizedBox(height: DsSpacing.space4),
            Text(card.how(locale), style: DsTextStyles.bodySecondary.copyWith(color: DsColors.textOnRitualSecondary)),
            if (needs != null && needs.isNotEmpty) ...[
              const SizedBox(height: DsSpacing.space3),
              Text(
                l.exploreCardNeeds(needs),
                style: DsTextStyles.bodySecondary.copyWith(color: DsColors.textOnRitualMuted),
              ),
            ],
            const SizedBox(height: DsSpacing.space5),
            Wrap(
              spacing: DsSpacing.space2,
              runSpacing: DsSpacing.space2,
              children: [
                for (final (label, action) in ideaCardActions(l, isD: isD, dName: dName))
                  WordButton(
                    label: label,
                    filled: action == IdeaCardAction.addToday,
                    onTap: () => Navigator.of(context).pop(action),
                  ),
              ],
            ),
            const SizedBox(height: DsSpacing.space4),
            if (canDrawAgain) ...[
              SecondaryButton(label: l.exploreDrawAgain, onTap: () => Navigator.of(context).pop(drawAgainSentinel)),
              const SizedBox(height: DsSpacing.space3),
            ],
            SecondaryButton(label: l.todayCancel, onTap: () => Navigator.of(context).pop()),
          ],
        ),
      ),
    );
  }
}
