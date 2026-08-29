import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../design_system/components/ds_button.dart';
import '../../../design_system/components/ds_card.dart';
import '../../../design_system/components/ds_nav_icons.dart';
import '../../../design_system/components/ds_page.dart';
import '../../../design_system/components/ds_text.dart';
import '../../../design_system/tokens/colors.dart';
import '../../../design_system/tokens/spacing.dart';
import '../../../design_system/tokens/typography.dart';
import '../../../domain_client/models/today_view.dart';

final todayProvider =
    FutureProvider.autoDispose.family<TodayView, String>((ref, dynamicId) async {
  return ref.watch(todayRepositoryProvider).forDynamic(dynamicId);
});

/// Today — Warm Authority V5 screen 1, Journey B.
///
/// The receiving side must know what matters within about ten seconds
/// (Notion 01 §11), so this stays a focus surface: a handful of expectations,
/// what is awaiting a response, and the last real thing a person said.
///
/// ADR-0001 D-3: the greeting is NEUTRAL. Hardcoding "Sir" would make the
/// system speak in the Dom's voice (red line #1).
class TodayScreen extends ConsumerWidget {
  const TodayScreen({
    super.key,
    this.dynamicId,
    this.notice,
    this.onOpen,
    this.onOpenAttention,
    this.onInvite,
    this.onStartRhythm,
    this.onAsk,
    this.onCheckIn,
    this.waitingForPartner = false,
    this.hasRhythm = true,
  });

  final String? dynamicId;

  /// Shown when the user arrived from a stale or invalid link.
  final String? notice;
  final void Function(String occurrenceId)? onOpen;

  /// Today is one tab with two faces (Notion 02 §2): Attention is not a
  /// separate navigation area, it is where Today leads when something is
  /// waiting on this person's response.
  final VoidCallback? onOpenAttention;

  /// The next real step when a dynamic exists but nothing is in it yet.
  /// An empty Today that only says "nothing is expected" is where a new
  /// user concludes the product does nothing.
  final VoidCallback? onInvite;
  final VoidCallback? onStartRhythm;

  /// Ask something of the other person, and share how today is going.
  /// Both are Journey requirements that had no way in.
  final VoidCallback? onAsk;
  final VoidCallback? onCheckIn;
  final bool waitingForPartner;
  final bool hasRhythm;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final id = dynamicId;
    return Scaffold(
      backgroundColor: DsColors.canvas,
      body: id == null
          ? DsPage(child: _Header(notice: notice))
          : ref.watch(todayProvider(id)).when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, _) => DsPage(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _Header(notice: notice),
                      const SizedBox(height: DsSpacing.xl),
                      Text(
                        "We couldn't load today just now. Nothing was lost.",
                        style: DsType.body.copyWith(color: DsColors.muted),
                      ),
                    ],
                  ),
                ),
                data: (t) => DsPage(child: _body(t)),
              ),
    );
  }

  Widget _body(TodayView t) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Header(notice: notice),

        // The last real thing a person said comes FIRST when it is fresh:
        // presence is the point, not the task list (Notion 01 §5).
        //
        // This ordering was previously stated in a comment while the widget
        // tree did the opposite — the routing row sat above it, so the
        // highest-value content on the whole screen lost first position to
        // administration.
        if (t.recentResponse != null) ...[
          const SizedBox(height: DsSpacing.xxl),
          _RecentResponseCard(response: t.recentResponse!),
        ],

        // The direction-giving face of Today. Shown from the server's count,
        // never inferred: a person can give direction in one dynamic and
        // receive it in another, and can be on both sides of the same one.
        //
        // Below the response deliberately: this is a door, not a moment.
        if (t.needsMyResponseCount > 0 && onOpenAttention != null) ...[
          const SizedBox(height: DsSpacing.xxl),
          _NeedsYouCard(
            count: t.needsMyResponseCount,
            onOpen: onOpenAttention!,
          ),
        ],

        if (t.expectations.isNotEmpty) ...[
          const SizedBox(height: DsSpacing.xxxl),
          const DsEyebrow('Today'),
          const SizedBox(height: DsSpacing.md),
          for (final e in t.expectations) ...[
            _ExpectationCard(item: e, onOpen: onOpen),
            const SizedBox(height: DsSpacing.md),
          ],
        ],

        if (t.awaitingResponse.isNotEmpty) ...[
          const SizedBox(height: DsSpacing.xl),
          const DsEyebrow('Waiting for your partner'),
          const SizedBox(height: DsSpacing.md),
          for (final e in t.awaitingResponse) ...[
            _WaitingRow(item: e, onOpen: onOpen),
            const SizedBox(height: DsSpacing.sm),
          ],
        ],

        if (onAsk != null || onCheckIn != null) ...[
          const SizedBox(height: DsSpacing.xxl),
          Row(
            children: [
              if (onCheckIn != null)
                Expanded(
                  child: DsButton(
                    label: 'Check in',
                    outline: true,
                    onPressed: onCheckIn,
                  ),
                ),
              if (onCheckIn != null && onAsk != null)
                const SizedBox(width: DsSpacing.md),
              if (onAsk != null)
                Expanded(
                  child: DsButton(
                    label: 'Ask for something',
                    outline: true,
                    onPressed: onAsk,
                  ),
                ),
            ],
          ),
        ],

        if (t.expectations.isEmpty &&
            t.awaitingResponse.isEmpty &&
            t.needsMyResponseCount == 0) ...[
          const SizedBox(height: DsSpacing.xxl),
          if (waitingForPartner && onInvite != null)
            _NextStep(
              title: 'No one has joined yet.',
              body: 'Send them a link and this becomes a shared day.',
              action: 'Invite them',
              onTap: onInvite!,
            )
          else if (!hasRhythm && onStartRhythm != null)
            _NextStep(
              title: 'Nothing is set up yet.',
              body: 'Start with a small rhythm. You can change all of it.',
              action: 'See a starting rhythm',
              onTap: onStartRhythm!,
            )
          else
            Text(
              // A genuinely quiet day is a good state, not an empty one.
              'Nothing is expected of you today.',
              style: DsType.body.copyWith(color: DsColors.muted),
            ),
        ],
      ],
    );
  }
}

/// What to do when a dynamic exists but there is nothing in it yet.
///
/// Restrained on purpose: this is guidance, not a relationship moment, so it
/// must not take the dark surface that a partner's words earn.
class _NextStep extends StatelessWidget {
  const _NextStep({
    required this.title,
    required this.body,
    required this.action,
    required this.onTap,
  });

  final String title;
  final String body;
  final String action;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: DsType.h2),
        const SizedBox(height: DsSpacing.sm),
        Text(body, style: DsType.body.copyWith(color: DsColors.muted)),
        const SizedBox(height: DsSpacing.xl),
        DsButton(label: action, onPressed: onTap),
      ],
    );
  }
}

/// The way into Attention when something is waiting on this person.
///
/// Deliberately NOT a dark card. Dark is the scarce authority surface, and
/// Today already spends it on the partner's own words — which is the
/// emotional peak of the product. Two dark cards stacked would dilute both
/// and make a routing affordance outrank a human being's voice.
///
/// So this is a quiet, high-contrast row: unmissable, but clearly a door
/// rather than a destination.
class _NeedsYouCard extends StatelessWidget {
  const _NeedsYouCard({required this.count, required this.onOpen});

  final int count;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onOpen,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(15, 14, 15, 14),
        decoration: BoxDecoration(
          color: DsColors.stone,
          border: const Border(
            left: BorderSide(color: DsColors.lineStrong, width: 2),
          ),
          borderRadius: const BorderRadius.horizontal(
            left: Radius.circular(3),
            right: Radius.circular(DsSpacing.cardRadius),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    count == 1
                        ? 'One thing needs your response.'
                        : '$count things need your response.',
                    style: DsType.cardTitle.copyWith(fontSize: 16),
                  ),
                  const SizedBox(height: DsSpacing.xs),
                  Text(
                    // Never a count of what is late — a person acted and is
                    // waiting to be seen.
                    'Someone is waiting to hear from you.',
                    style: DsType.fine.copyWith(color: DsColors.muted),
                  ),
                ],
              ),
            ),
            const SizedBox(width: DsSpacing.md),
            const DsNavIcon(DsNavShape.chevronRight, color: DsColors.muted),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({this.notice});
  final String? notice;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (notice != null) ...[
            DsNote(child: Text(notice!, style: DsType.fine)),
            const SizedBox(height: DsSpacing.xl),
          ],
          Text('Good morning.', style: DsType.h1),
        ],
      );
}

class _RecentResponseCard extends StatelessWidget {
  const _RecentResponseCard({required this.response});
  final RecentResponse response;

  @override
  Widget build(BuildContext context) => DsCard(
        tone: DsCardTone.dark,
        showRail: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DsEyebrow(
              'From ${response.senderDisplayName ?? 'your partner'}',
              onDark: true,
            ),
            const SizedBox(height: DsSpacing.lg),
            // Their words, verbatim. Never paraphrased or generated.
            Text(response.text, style: DsType.bigQuote),
            const SizedBox(height: DsSpacing.lg),
            Text(
              response.title,
              style: DsType.fine.copyWith(color: DsColors.onResponseMuted),
            ),
          ],
        ),
      );
}

class _ExpectationCard extends StatelessWidget {
  const _ExpectationCard({required this.item, this.onOpen});

  final TodayItem item;
  final void Function(String occurrenceId)? onOpen;

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onOpen == null ? null : () => onOpen!(item.occurrenceId),
        borderRadius: BorderRadius.circular(DsSpacing.cardRadius),
        child: DsCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (item.fromDisplayName != null)
                DsEyebrow('From ${item.fromDisplayName}', terra: true),
              const SizedBox(height: DsSpacing.sm),
              Text(item.title, style: DsType.cardTitle),
              if (item.dueAt != null) ...[
                const SizedBox(height: DsSpacing.xs),
                // Notion 02 §3: the card must be understandable without
                // opening it — title, from, and time context. The time was
                // in the payload but never shown.
                Text(_when(item.dueAt!),
                    style: DsType.fine.copyWith(
                        color: DsColors.inkSoft,
                        fontWeight: FontWeight.w700)),
              ],
              if (item.purpose != null) ...[
                const SizedBox(height: DsSpacing.xs),
                Text(item.purpose!, style: DsType.fine),
              ],
              if (item.state != 'ACTIVE') ...[
                const SizedBox(height: DsSpacing.sm),
                Text(_stateLabel(item.state),
                    style: DsType.fine.copyWith(color: DsColors.critical)),
              ],
            ],
          ),
        ),
      );

  /// Backend state names never reach the user (Notion 05 §12).
  /// Time as a person would say it, in their own day - never a raw date.
  String _when(DateTime due) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final day = DateTime(due.year, due.month, due.day);
    final h = due.hour % 12 == 0 ? 12 : due.hour % 12;
    final mm = due.minute.toString().padLeft(2, '0');
    final ampm = due.hour < 12 ? 'AM' : 'PM';
    final time = '$h:$mm $ampm';
    final diff = day.difference(today).inDays;
    if (diff == 0) return 'By $time';
    if (diff == 1) return 'Tomorrow, $time';
    // Never "overdue" or "late": past due is Needs review, not a verdict.
    if (diff < 0) return 'Was $time';
    return 'In $diff days, $time';
  }

  String _stateLabel(String s) => switch (s) {
        'NEED_TO_DISCUSS' => 'Being discussed',
        'RESCHEDULE_REQUESTED' => 'New time requested',
        'EXCUSE_REQUESTED' => 'Asked to skip',
        'NEEDS_REVIEW' => 'Needs review',
        _ => '',
      };
}

class _WaitingRow extends StatelessWidget {
  const _WaitingRow({required this.item, this.onOpen});

  final TodayItem item;
  final void Function(String occurrenceId)? onOpen;

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onOpen == null ? null : () => onOpen!(item.occurrenceId),
        borderRadius: BorderRadius.circular(DsSpacing.cardRadius),
        child: DsCard(
          tone: DsCardTone.stone,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(item.title, style: DsType.cardTitle),
              const SizedBox(height: DsSpacing.xs),
              // Completing is not being seen (red line #2).
              Text('Completed · waiting for a response', style: DsType.fine),
            ],
          ),
        ),
      );
}
