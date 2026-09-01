import 'package:ds_relationship_companion/ds_design_system.dart';
import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';

/// The one action a screen is asking for.
///
/// Promoted from `SecondaryButton(filled: true)` once three entrance screens
/// needed the same control with two states that one did not have: unavailable,
/// and working.
///
/// Both matter here specifically. A sign-in button that stays pressable while
/// the request is in flight invites a second tap, and the entrance is where a
/// person is least sure anything happened.
class DsPrimaryButton extends StatelessWidget {
  const DsPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.busy = false,
    this.busyLabel,
    this.icon,
  });

  final String label;

  /// A frozen mark inside the control, ahead of the label.
  ///
  /// The design draws the invite screen's primary action with one; a bare
  /// label there reads as a generic button where the reference reads as a
  /// specific act. Absent on every other caller, which is the default.
  final DsAssetId? icon;

  /// Null renders the button unavailable. The button never explains why —
  /// the form says what is missing, next to the field that is missing it.
  final VoidCallback? onPressed;

  /// A request is in flight. The control stays put and stops accepting taps.
  final bool busy;

  /// What to say while working. Defaults to [label], so the button does not
  /// change width mid-request unless a caller has a truer word.
  final String? busyLabel;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null && !busy;

    return Semantics(
      button: true,
      enabled: enabled,
      // Without this a screen reader announces a working button as an
      // ordinary one, and the person taps again.
      label: busy
          ? L.of(context).shellButtonWorking(busyLabel ?? label)
          : label,
      excludeSemantics: true,
      child: SizedBox(
        height: DsControlSizes.button,
        width: double.infinity,
        child: Material(
          color: enabled
              ? DsColors.actionPrimaryBackground
              : DsColors.actionPrimaryDisabledBackground,
          borderRadius: BorderRadius.circular(DsRadii.control),
          child: InkWell(
            borderRadius: BorderRadius.circular(DsRadii.control),
            onTap: enabled ? onPressed : null,
            child: Padding(
              // The label owns the width, and long ones ellipsize rather
              // than overflowing. Three screens hit this before it was the
              // component's problem instead of each caller's: a control that
              // breaks on a longer word is a trap for whoever writes the next
              // one, and for translation.
              padding: const EdgeInsets.symmetric(horizontal: DsSpacing.space4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (busy) ...[
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 1.5,
                        valueColor: AlwaysStoppedAnimation(
                          DsColors.actionPrimaryDisabledForeground,
                        ),
                      ),
                    ),
                    const SizedBox(width: DsSpacing.space3),
                  ] else if (icon case final icon?) ...[
                    // 20dp is the smallest size the freeze licenses for these
                    // action icons, which is the one that sits under a 16dp
                    // label without competing with it. The spinner replaces
                    // the mark rather than joining it — two glyphs in one
                    // control is a busier button than the design draws.
                    DsSvg(
                      asset: icon,
                      tone: DsAssetTone.primary,
                      width: 20,
                      height: 20,
                    ),
                    const SizedBox(width: DsSpacing.space3),
                  ],
                  Flexible(
                    child: Text(
                      busy ? (busyLabel ?? label) : label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: DsTextStyles.labelAction.copyWith(
                        color: enabled
                            ? DsColors.actionPrimaryForeground
                            : DsColors.actionPrimaryDisabledForeground,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
