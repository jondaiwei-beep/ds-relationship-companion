import 'package:ds_relationship_companion/ds_design_system.dart';
import 'package:flutter/material.dart';

/// A block standing in for content that has not arrived.
///
/// Shaped like what is coming, so the page does not jump when it does. The
/// approved SCR-01 loading state draws exactly this: raised bars in the
/// proportions of the real rows, never a spinner and never a sentence of
/// apology on an empty screen.
///
/// It carries no information, so it is hidden from screen readers — the
/// surface announces its own status in words instead.
class DsSkeletonBar extends StatelessWidget {
  const DsSkeletonBar({
    super.key,
    this.width,
    this.widthFactor,
    this.height = 12,
    this.emphasis = false,
  });

  final double? width;

  /// A share of the available width, for bars that should track the column
  /// rather than a fixed measure.
  final double? widthFactor;

  final double height;

  /// The one bar standing in for a headline. Slightly brighter, so the shape
  /// of the page is legible before its content is.
  final bool emphasis;

  @override
  Widget build(BuildContext context) {
    // `surfaceRitualDisabled` is byte-identical to `surfaceRitualRaised`, the
    // card these sit on (both 0xFF1E241F), so bars drawn in it were invisible:
    // on the simulator each card showed only its emphasis bar, which uses a
    // different token. Widget tests could not see it — `findsWidgets` passes
    // for something painted in the background colour. `surfaceRitualAction`
    // is the next step up the same ramp and is what the approved loading
    // state's bars read as.
    final bar = Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: emphasis
            ? DsColors.borderOnRitualStrong
            : DsColors.surfaceRitualAction,
        borderRadius: BorderRadius.circular(height / 2),
      ),
    );

    return ExcludeSemantics(
      child: widthFactor == null
          ? bar
          : FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: widthFactor,
              child: bar,
            ),
    );
  }
}

/// Several bars inside a raised card, in the shape of one item.
class DsSkeletonCard extends StatelessWidget {
  const DsSkeletonCard({
    super.key,
    required this.lines,
    this.emphasis = false,
  });

  /// Width factors, top to bottom. Uneven lengths read as text; equal ones
  /// read as a loading graphic, which is the thing being avoided.
  final List<double> lines;

  /// The primary item. Taller, with a brighter first bar.
  final bool emphasis;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(DsSpacing.space4),
      decoration: BoxDecoration(
        color: DsColors.surfaceRitualRaised,
        borderRadius: BorderRadius.circular(DsRadii.card),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final (i, factor) in lines.indexed) ...[
            if (i > 0) const SizedBox(height: DsSpacing.space3),
            DsSkeletonBar(
              widthFactor: factor,
              height: emphasis && i == 0 ? 16 : 12,
              emphasis: emphasis && i == 0,
            ),
          ],
        ],
      ),
    );
  }
}

/// The breathing that tells a person the app is working rather than stuck.
///
/// Deliberately slow and small — 1.6s, and only between 45% and 75% opacity.
/// A fast or high-contrast shimmer reads as urgency, and nothing on these
/// surfaces is urgent. Respects the platform's reduce-motion setting, where a
/// still skeleton is still perfectly legible.
class DsSkeletonPulse extends StatefulWidget {
  const DsSkeletonPulse({super.key, required this.child});

  final Widget child;

  @override
  State<DsSkeletonPulse> createState() => _DsSkeletonPulseState();
}

class _DsSkeletonPulseState extends State<DsSkeletonPulse>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1600),
  );

  late final Animation<double> _opacity = Tween<double>(
    begin: 0.45,
    end: 0.75,
  ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

  @override
  void initState() {
    super.initState();
    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.disableAnimationsOf(context)) {
      return Opacity(opacity: 0.6, child: widget.child);
    }
    return FadeTransition(opacity: _opacity, child: widget.child);
  }
}
