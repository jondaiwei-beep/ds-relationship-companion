import 'package:ds_relationship_companion/ds_design_system.dart';
import 'package:flutter/material.dart';

/// A single line of input, as the entrance screens draw it: a small label, the
/// value, and a hairline beneath.
///
/// No filled box and no outline. The approved composition puts almost nothing
/// on the canvas, and a boxed field would be the loudest thing on the screen.
class DsTextField extends StatelessWidget {
  const DsTextField({
    super.key,
    required this.label,
    required this.controller,
    this.hint,
    this.error,
    this.obscure = false,
    this.onToggleObscure,
    this.keyboardType,
    this.textInputAction,
    this.autofillHints,
    this.enabled = true,
    this.onSubmitted,
  });

  final String label;
  final TextEditingController controller;
  final String? hint;

  /// Shown beneath the line, and colours it. Null while the field is fine.
  final String? error;

  /// Whether the value is hidden. A password field passes this and
  /// [onToggleObscure] together.
  final bool obscure;

  /// Supplied only when the value can be revealed. The eye is absent
  /// otherwise, rather than present and inert.
  final VoidCallback? onToggleObscure;

  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final Iterable<String>? autofillHints;

  /// False while a request is in flight, so the value cannot change under a
  /// submission that has already been sent.
  final bool enabled;

  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    final hasError = error != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: DsTextStyles.labelRitual.copyWith(
            color: hasError ? DsColors.stateError : DsColors.textOnRitualMuted,
          ),
        ),
        const SizedBox(height: DsSpacing.space2),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                enabled: enabled,
                obscureText: obscure,
                keyboardType: keyboardType,
                textInputAction: textInputAction,
                autofillHints: autofillHints,
                onSubmitted: onSubmitted,
                style: DsTextStyles.bodyPrimary.copyWith(
                  color: DsColors.textOnRitualPrimary,
                ),
                cursorColor: DsColors.textOnRitualPrimary,
                decoration: InputDecoration(
                  isDense: true,
                  hintText: hint,
                  hintStyle: DsTextStyles.bodyPrimary.copyWith(
                    color: DsColors.textOnRitualMuted,
                  ),
                  // The line is drawn below, spanning the reveal control too,
                  // so the field's own borders are removed rather than
                  // restyled — two hairlines would sit a pixel apart.
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: DsSpacing.space2,
                  ),
                ),
              ),
            ),
            if (onToggleObscure != null)
              _RevealToggle(hidden: obscure, onTap: onToggleObscure!),
          ],
        ),
        Container(
          height: DsBorderWidths.hairline,
          color: hasError
              ? DsColors.stateError
              : DsColors.borderOnRitualHairline,
        ),
        if (hasError) ...[
          const SizedBox(height: DsSpacing.space2),
          Text(
            error!,
            style: DsTextStyles.bodySecondary.copyWith(
              color: DsColors.stateError,
            ),
          ),
        ],
      ],
    );
  }
}

/// Show or hide the password.
///
/// Typing a password blind on a phone is where people give up, and this is a
/// private app someone may be using somewhere they would rather not be
/// overlooked — so the control matters in both directions.
///
/// **The design draws an eye glyph; SVG Freeze v1 has no such asset.** Tracing
/// one from the raster preview is forbidden, and a Material icon would be the
/// only non-frozen mark in the product. So this is a word until the asset
/// exists — legible, on-palette, and it keeps the 48dp target. Requested in
/// `design/assets/svg/REQUESTED.md`.
class _RevealToggle extends StatelessWidget {
  const _RevealToggle({required this.hidden, required this.onTap});

  final bool hidden;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: hidden ? 'Show password' : 'Hide password',
      excludeSemantics: true,
      child: InkResponse(
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(
            minWidth: DsControlSizes.iconButton,
            minHeight: DsControlSizes.iconButton,
          ),
          alignment: Alignment.centerRight,
          child: Text(
            hidden ? 'Show' : 'Hide',
            style: DsTextStyles.bodySecondary.copyWith(
              color: DsColors.textOnRitualMuted,
            ),
          ),
        ),
      ),
    );
  }
}
