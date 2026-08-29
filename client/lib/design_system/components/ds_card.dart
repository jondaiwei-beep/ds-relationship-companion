import 'package:flutter/material.dart';
import '../tokens/colors.dart';
import '../tokens/spacing.dart';

/// Card surfaces from Warm Authority V5 §4.
enum DsCardTone {
  /// Ivory on bone. Ordinary content.
  light,

  /// Olive. The authority / response surface — used for "waiting for human
  /// response" and "needs your response", the two highest-weight moments.
  dark,

  /// Stone, borderless. Soft secondary content such as a check-in.
  stone,
}

class DsCard extends StatelessWidget {
  const DsCard({
    super.key,
    required this.child,
    this.tone = DsCardTone.light,
    this.showRail = false,
    this.padding,
  });

  final Widget child;
  final DsCardTone tone;

  /// Kept as a parameter so call sites need not change, but it no longer
  /// paints a filled bar.
  ///
  /// Direction 02: accent is a mark — current position, focus, unread,
  /// selected nav — never a fill. A coloured rail down the side of a panel
  /// is decoration that carries no state, and on the reply plane the words
  /// themselves already are the emphasis. Adding a stripe next to them said
  /// the stripe mattered too.
  final bool showRail;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final (bg, border) = switch (tone) {
      DsCardTone.light => (DsColors.surface, DsColors.line),
      DsCardTone.dark => (DsColors.response, DsColors.line),
      DsCardTone.stone => (DsColors.stone, Colors.transparent),
    };

    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(DsSpacing.cardRadius),
        border: Border.all(color: border),
      ),
      clipBehavior: Clip.antiAlias,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [

            // Expanded gives the content a BOUNDED width, so a TextField or
            // Wrap inside a card cannot grow off-screen.
            Expanded(
              child: Padding(
                padding: padding ??
                    const EdgeInsets.fromLTRB(15, 14, 15, 14),
                child: child,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
