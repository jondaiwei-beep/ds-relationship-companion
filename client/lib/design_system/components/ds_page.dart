import 'package:flutter/material.dart';
import '../tokens/spacing.dart';

/// Page shell shared by Android and Web.
///
/// The design is specified at 390dp (Warm Authority V5). On a desktop browser
/// the same layout must not stretch to the full window — Notion 04 §1 requires
/// a real Web companion, not a scaled-up phone UI, and an 1800px-wide line of
/// body text is unreadable. Content is therefore capped and centred.
class DsPage extends StatelessWidget {
  const DsPage({super.key, required this.child, this.maxWidth = 480});

  final Widget child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) => SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Center alone would hand the child unbounded width when the
            // incoming constraints are unbounded (as in a test surface),
            // letting a TextField or Wrap grow off-screen. Resolve an explicit
            // width instead.
            final available = constraints.hasBoundedWidth
                ? constraints.maxWidth
                : maxWidth;
            final width = available < maxWidth ? available : maxWidth;
            return Align(
              alignment: Alignment.topCenter,
              child: SizedBox(
                width: width,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(DsSpacing.screenPadding),
                  child: child,
                ),
              ),
            );
          },
        ),
      );
}
