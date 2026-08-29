import 'package:flutter/material.dart';
import '../tokens/colors.dart';
import '../tokens/spacing.dart';
import '../tokens/typography.dart';

/// Primary and outline buttons.
///
/// Height is 48dp, not the mockup's 42px (ADR-0001 D-2): 48dp is the Android
/// minimum touch target and Notion 05 §8 states 48–52dp.
class DsButton extends StatelessWidget {
  const DsButton({super.key, required this.label, this.onPressed, this.outline = false});

  final String label;
  final VoidCallback? onPressed;
  final bool outline;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    return Opacity(
      opacity: enabled ? 1 : 0.45,
      child: Material(
        color: outline ? Colors.transparent : DsColors.response,
        borderRadius: BorderRadius.circular(DsSpacing.buttonRadius),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(DsSpacing.buttonRadius),
          child: Container(
            height: DsSpacing.buttonHeight,
            alignment: Alignment.center,
            decoration: outline
                ? BoxDecoration(
                    borderRadius: BorderRadius.circular(DsSpacing.buttonRadius),
                    border: Border.all(color: DsColors.lineStrong),
                  )
                : null,
            child: Text(
              label,
              style: DsType.button.copyWith(
                color: outline ? DsColors.response : DsColors.surface,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
