import 'package:ds_relationship_companion/ds_design_system.dart';
import 'package:flutter/widgets.dart';

/// Shown for the moment between launching and knowing whether a session can
/// be restored.
///
/// Deliberately empty. Two reasons, and the second is the important one:
///
/// A spinner here would be a lie about duration — the answer usually arrives
/// within a frame or two, and a spinner that flashes reads as a fault.
///
/// More importantly, this route exists so that *nothing is requested* while
/// the right to read is unestablished. Any content here would be content
/// asking for data. The canvas is painted so the wait is a considered pause
/// rather than a white flash on a dark app.
class SessionResolving extends StatelessWidget {
  const SessionResolving({super.key});

  @override
  Widget build(BuildContext context) =>
      const DsRitualSurface(child: SizedBox.expand());
}
