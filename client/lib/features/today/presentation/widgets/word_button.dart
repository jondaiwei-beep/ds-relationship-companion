import 'package:ds_relationship_companion/ds_design_system.dart';
import 'package:flutter/material.dart';

/// One word a person can say, sized to the word.
///
/// The three kinds are the whole button grammar of the app
/// (design/system/redesign-2026-09.md §2): [filled] is the thing you came to
/// do, the outlined default is create/adjust, [quiet] is navigation and the
/// low-frequency actions that used to look as loud as everything else. A
/// [danger] outline is for the destructive word inside a confirm sheet.
class WordButton extends StatelessWidget {
  const WordButton({
    super.key,
    required this.label,
    required this.onTap,
    this.filled = false,
    this.quiet = false,
    this.danger = false,
  }) : assert(!(filled && quiet), 'a button is loud or quiet, not both');

  final String label;
  final VoidCallback onTap;
  final bool filled;
  final bool quiet;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final Color fg;
    final Color? border;
    if (filled) {
      fg = DsColors.actionPrimaryForeground;
      border = null;
    } else if (danger) {
      fg = DsColors.actionDestructiveFinalForeground;
      border = DsColors.actionDestructiveFinalBorder;
    } else if (quiet) {
      fg = DsColors.textOnRitualSecondary;
      border = null;
    } else {
      fg = DsColors.textOnRitualPrimary;
      border = DsColors.actionSecondaryBorder;
    }
    final style = quiet
        ? DsTextStyles.labelAction.copyWith(color: fg, fontSize: 14, fontWeight: FontWeight.w500)
        : DsTextStyles.labelAction.copyWith(color: fg);
    return Material(
      color: filled ? DsColors.actionPrimaryBackground : DsPrimitiveColors.transparent,
      borderRadius: BorderRadius.circular(DsRadii.control),
      child: InkWell(
        borderRadius: BorderRadius.circular(DsRadii.control),
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: 40),
          // A quiet word keeps its 44dp touch height but no horizontal
          // padding, so it lines up with the text above it.
          padding: EdgeInsets.symmetric(horizontal: quiet ? 0 : DsSpacing.space4),
          decoration: BoxDecoration(
            border: border == null ? null : Border.all(color: border),
            borderRadius: BorderRadius.circular(DsRadii.control),
          ),
          // Not `alignment:` — a Container with an alignment fills whatever
          // width it is given, which turned a word into a full-width bar
          // inside any Wrap or Align.
          child: Center(
            widthFactor: 1,
            // The label stays a plain Text so `find.text` and screen readers
            // see the word, not the word plus a chevron.
            child: quiet
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(label, style: style),
                      const SizedBox(width: DsSpacing.space1),
                      Text('›', style: style.copyWith(color: DsColors.textOnRitualMuted)),
                    ],
                  )
                : Text(label, style: style),
          ),
        ),
      ),
    );
  }
}
