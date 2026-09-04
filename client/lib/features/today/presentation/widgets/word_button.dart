import 'package:ds_relationship_companion/ds_design_system.dart';
import 'package:flutter/material.dart';

/// One word a person can say, sized to the word. Sits inline in a row where
/// the full-width [SecondaryButton] would not fit.
class WordButton extends StatelessWidget {
  const WordButton({super.key, required this.label, required this.onTap, this.filled = false});

  final String label;
  final VoidCallback onTap;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: filled ? DsColors.actionPrimaryBackground : DsPrimitiveColors.transparent,
      borderRadius: BorderRadius.circular(DsRadii.control),
      child: InkWell(
        borderRadius: BorderRadius.circular(DsRadii.control),
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: 40),
          padding: const EdgeInsets.symmetric(horizontal: DsSpacing.space4),
          decoration: BoxDecoration(
            border: filled ? null : Border.all(color: DsColors.actionSecondaryBorder),
            borderRadius: BorderRadius.circular(DsRadii.control),
          ),
          // Not `alignment:` — a Container with an alignment fills whatever
          // width it is given, which turned a word into a full-width bar
          // inside any Wrap or Align.
          child: Center(
            widthFactor: 1,
            child: Text(
              label,
              style: DsTextStyles.labelAction.copyWith(
                color: filled ? DsColors.actionPrimaryForeground : DsColors.textOnRitualPrimary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
