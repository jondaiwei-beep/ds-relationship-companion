import 'package:ds_relationship_companion/ds_design_system.dart';
import 'package:flutter/material.dart';

/// Pull down to ask the server again.
///
/// Every surface reads once when it is first opened and then keeps what it
/// has. Refetching on every tab switch made the four tabs feel like four
/// separate loads of the same app: a spinner between Today and Dynamic says
/// the app forgot where you were, when nothing about the relationship changed
/// in the second it took you to tap.
///
/// So fetching is now something a person asks for, or something a command
/// causes — completing an expectation still re-reads Today, because the server
/// decided what changed and the client must not guess. What is gone is the
/// fetch that happened for no reason but navigation.
///
/// The gesture has to exist even when the page is short. A ListView that fits
/// its viewport does not scroll by default, so without forcing it the pull
/// would work on a full Today and quietly vanish on an empty one — and on
/// every recovery state, which is exactly where a person most wants to try
/// again. `AlwaysScrollableScrollPhysics` is injected here rather than set on
/// each list so no surface can be added later that forgets it.
class DsRefreshable extends StatelessWidget {
  const DsRefreshable({
    super.key,
    required this.onRefresh,
    required this.child,
  });

  /// Returns when the new data has arrived — the indicator stays up until it
  /// does, which is the only honest signal that the request is still running.
  final Future<void> Function() onRefresh;

  final Widget child;

  @override
  Widget build(BuildContext context) => RefreshIndicator(
    onRefresh: onRefresh,
    // Matches the Attention surface, which had the only refresh gesture in
    // the product before this.
    color: DsPrimitiveColors.terracotta,
    backgroundColor: DsColors.surfaceRitualRaised,
    child: ScrollConfiguration(
      behavior: const _AlwaysScrollable(),
      child: child,
    ),
  );
}

class _AlwaysScrollable extends ScrollBehavior {
  const _AlwaysScrollable();

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) =>
      const AlwaysScrollableScrollPhysics();
}
