import 'package:flutter/material.dart';
import '../tokens/colors.dart';
import '../tokens/spacing.dart';
import '../tokens/typography.dart';

/// Uppercase tracked section label. `terra` variant for accent.
class DsEyebrow extends StatelessWidget {
  const DsEyebrow(this.text, {super.key, this.terra = false, this.onDark = false});

  final String text;
  final bool terra;
  final bool onDark;

  @override
  Widget build(BuildContext context) => Text(
        text.toUpperCase(),
        style: DsType.eyebrow.copyWith(
          // Direction 02: accent is a mark, never text. Emphasis in an
          // eyebrow comes from weight, not from colour.
          color: onDark ? DsColors.onResponseMuted : DsColors.inkSoft,
        ),
      );
}

/// A short structural rule.
///
/// Direction 02 deletes the terracotta branding tick: a decorative mark that
/// carries no state is the clearest signal of generated design. What remains
/// is a plain hairline used to open a section, in the structural line colour.
class DsAccentRule extends StatelessWidget {
  const DsAccentRule({super.key});

  @override
  Widget build(BuildContext context) =>
      Container(width: 40, height: 1, color: DsColors.lineStrong);
}

/// Partner-authored text.
///
/// Red line #2: this styling is reserved for content a real person wrote and
/// sent. System suggestions must never be rendered in it.
class DsQuote extends StatelessWidget {
  const DsQuote(this.text, {super.key, this.onDark = false});

  final String text;
  final bool onDark;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.only(left: 14),
        decoration: const BoxDecoration(
          border: Border(left: BorderSide(color: DsColors.lineStrong, width: 2)),
        ),
        child: Text(
          text,
          style: (onDark ? DsType.bigQuote : DsType.cardTitle),
        ),
      );
}

/// Stone helper block, used for privacy notes and system-suggestion framing.
class DsNote extends StatelessWidget {
  const DsNote({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: DsSpacing.lg),
        decoration: BoxDecoration(
          color: DsColors.stone,
          borderRadius: BorderRadius.circular(8),
        ),
        child: child,
      );
}
