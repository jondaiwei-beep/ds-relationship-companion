import 'package:ds_relationship_companion/ds_design_system.dart';
import 'package:flutter/material.dart';

import '../../../../domain_client/models/dynamic_view.dart';
import '../../../../domain_client/models/today_view.dart';
import '../../../../l10n/app_localizations.dart';
import '../today_format.dart';
import 'today_layout.dart';
import 'word_button.dart';

/// The one line Today owes before its list: the state of the Dynamic itself.
///
/// Three facts change what a day means, and none of them lives in an
/// occurrence: the Dynamic is paused, the D is away, or the partner has not
/// joined yet. Each gets a sentence and, where there is something to do, one
/// word. Nothing when none applies — the list speaks for itself.
class TodayNotice extends StatelessWidget {
  const TodayNotice({
    super.key,
    required this.view,
    required this.detail,
    this.onInvite,
    this.onPause,
    this.now,
  });

  final TodayView view;

  /// Null while the detail is still loading or could not be read; then only
  /// what [view] itself carries (`dAwayUntil`) is shown.
  final DynamicDetail? detail;
  final VoidCallback? onInvite;
  final VoidCallback? onPause;

  /// Injectable for tests; defaults to the wall clock.
  final DateTime? now;

  static bool isPaused(DynamicDetail? d) =>
      d != null && (d.pausedAt != null || d.state.toUpperCase() == 'PAUSED');

  static bool isAlone(DynamicDetail? d) => d != null && d.members.length < 2;

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    final muted = DsTextStyles.bodySecondary.copyWith(color: DsColors.textOnRitualSecondary);
    final children = <Widget>[];

    if (isPaused(detail)) {
      children.add(_line(l.todayPausedLine, muted, action: onPause == null ? null : (l.todayPausedOpen, onPause!)));
    }

    final away = view.dAwayUntil;
    if (away != null && away.isAfter(now ?? DateTime.now())) {
      final date = TodayFormat.dayOfInstant(away, view.timezone, Localizations.localeOf(context).languageCode);
      final name = view.partnerDisplayName ?? l.todayPartnerFallback;
      children.add(_line(view.isD ? l.rulesAwayUntil(date) : l.rulesAwayPartner(name, date), muted));
    }

    if (isAlone(detail)) {
      children.add(
        _line(
          l.todayWaitingPartner,
          DsTextStyles.bodyPrimary.copyWith(color: DsColors.textOnRitualPrimary),
          support: l.todayWaitingPartnerBody,
          action: onInvite == null ? null : (l.todayInviteLink, onInvite!),
        ),
      );
    }

    if (children.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final c in children) ...[c, const SizedBox(height: DsSpacing.space4)],
        const SizedBox(height: DsSpacing.space2),
      ],
    );
  }

  Widget _line(String text, TextStyle style, {String? support, (String, VoidCallback)? action}) => Padding(
        padding: todayInset,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(text, style: style),
            if (support != null) ...[
              const SizedBox(height: DsSpacing.space1),
              Text(
                support,
                style: DsTextStyles.bodySecondary.copyWith(color: DsColors.textOnRitualMuted),
              ),
            ],
            if (action != null) ...[
              const SizedBox(height: DsSpacing.space3),
              WordButton(label: action.$1, onTap: action.$2, filled: true),
            ],
          ],
        ),
      );
}
