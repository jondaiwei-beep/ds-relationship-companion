import 'package:ds_relationship_companion/ds_design_system.dart';
import 'package:flutter/material.dart';

import 'today_header.dart';
import 'today_layout.dart';

/// Shared frame for every state where the server could not confirm the list.
///
/// All five recovery states carry the same structure — a header that names the
/// context instead of a partner, then an explanation, then at most one way
/// forward. Repeating that frame five times invited the versions to drift
/// apart, which is the one thing recovery copy must not do.
class RecoveryScaffold extends StatelessWidget {
  const RecoveryScaffold({
    super.key,
    required this.context_,
    required this.children,
    this.title = 'Today',
  });

  /// Replaces partner presence in the header. Protected content is never shown
  /// while access is unconfirmed.
  final String context_;

  /// The surface this recovery state belongs to. A person who cannot load
  /// Dynamic should still be told which screen they are on.
  final String title;

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        TodayHeader(title: title, partnerName: null, context_: context_),
        ...children,
      ],
    );
  }
}

/// Body copy inside a recovery state.
class RecoveryMessage extends StatelessWidget {
  const RecoveryMessage(this.text, {super.key, this.prominent = false});

  final String text;

  /// The one sentence that says what happened; supporting lines stay quieter.
  final bool prominent;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: todayInset,
      child: Text(
        text,
        style: prominent
            ? DsTextStyles.bodyPrimary.copyWith(
                color: DsColors.textOnRitualPrimary,
              )
            : DsTextStyles.bodySecondary.copyWith(
                color: DsColors.textOnRitualMuted,
                fontSize: todaySupportSize,
                height: todaySupportHeight,
              ),
      ),
    );
  }
}
