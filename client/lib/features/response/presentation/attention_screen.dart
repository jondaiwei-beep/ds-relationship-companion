import 'package:ds_relationship_companion/ds_design_system.dart';
import 'package:flutter/material.dart';

import '../../../app/shell/ds_glyph.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/shell/bottom_navigation.dart';
import '../../../domain_client/models/attention_view.dart';
import '../../../l10n/app_localizations.dart';
import '../application/response_actions.dart';

/// SCR-32 — Attention. The direction-giving side's daily entry.
///
/// Today answers "what is expected of me". This answers "what is waiting on
/// me", and the difference is the whole product: one person's completion is
/// unfinished until another person answers it, so the answering has to have
/// somewhere to live.
///
/// `REQ-ATTN-001` fixes the order and it is not negotiable: someone who asked
/// to discuss something is waiting on a *conversation*, and that outranks a
/// completion waiting on a tap. The server sorts; this screen groups what it
/// is given and never re-sorts (`REQ-STATE-001`).
class AttentionScreen extends ConsumerStatefulWidget {
  const AttentionScreen({
    super.key,
    required this.view,
    required this.partnerName,
    required this.onOpen,
    required this.onRefresh,
  });

  final AttentionView view;

  final String partnerName;

  /// Open one item in full. Everything an inline control cannot do lives
  /// there — words, adjustment resolution, review.
  final void Function(AttentionItem) onOpen;

  final Future<void> Function() onRefresh;

  @override
  ConsumerState<AttentionScreen> createState() => _AttentionScreenState();
}

class _AttentionScreenState extends ConsumerState<AttentionScreen> {
  /// The item currently being answered inline, so two taps cannot start two
  /// sends and the rest of the list stays live.
  String? _sending;

  ResponseFailureReason? _failure;

  Future<void> _respond(AttentionItem item, HumanResponse type) async {
    if (_sending != null) return;
    setState(() {
      _sending = item.occurrenceId;
      _failure = null;
    });

    final outcome = await ref.read(responseActionsProvider).send(
          occurrenceId: item.occurrenceId,
          type: type,
        );

    if (!mounted) return;
    setState(() => _sending = null);

    switch (outcome) {
      // Both leave the list stale, and both are resolved the same way: ask
      // the server again rather than removing the row locally. A list that
      // edits itself is a list that can disagree with the truth.
      case ResponseSent() || ResponseAlreadySent():
        await widget.onRefresh();
      case ResponseFailed(:final reason):
        setState(() => _failure = reason);
      case ResponseNeedsWords():
        // Unreachable inline — only wordless types are offered here — but if
        // it ever happens, the full screen is where words are written.
        widget.onOpen(item);
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = widget.view.items;
    return Scaffold(
      backgroundColor: DsColors.canvasRitual,
      body: DsRitualSurface(
        child: SafeArea(
          bottom: false,
          child: RefreshIndicator(
            onRefresh: widget.onRefresh,
            color: DsPrimitiveColors.terracotta,
            backgroundColor: DsColors.surfaceRitualRaised,
            child: items.isEmpty
                ? _Empty(partnerName: widget.partnerName)
                : _List(
                    view: widget.view,
                    partnerName: widget.partnerName,
                    sending: _sending,
                    failure: _failure,
                    onRespond: _respond,
                    onOpen: widget.onOpen,
                  ),
          ),
        ),
      ),
      bottomNavigationBar: const DsBottomNavigation(
        current: NavSurface.today,
      ),
    );
  }
}

class _List extends StatelessWidget {
  const _List({
    required this.view,
    required this.partnerName,
    required this.sending,
    required this.failure,
    required this.onRespond,
    required this.onOpen,
  });

  final AttentionView view;
  final String partnerName;
  final String? sending;
  final ResponseFailureReason? failure;
  final void Function(AttentionItem, HumanResponse) onRespond;
  final void Function(AttentionItem) onOpen;

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    // Grouped by the server's own priority, never re-sorted here.
    final waiting = view.items.where((i) => i.priority == 1).toList();
    final toAnswer = view.items.where((i) => i.priority == 2).toList();
    final toRevisit = view.items.where((i) => i.priority >= 3).toList();

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: DsSpacing.space5),
      children: [
        _Header(partnerName: partnerName),
        _Summary(view: view),
        if (failure case final failure?) ...[
          const SizedBox(height: DsSpacing.space4),
          Text(
            switch (failure) {
              ResponseFailureReason.offline => l.responseErrorOffline,
              ResponseFailureReason.unknown => l.responseErrorGeneric,
            },
            style: DsTextStyles.bodySecondary.copyWith(
              color: DsColors.stateError,
            ),
          ),
        ],
        if (waiting.isNotEmpty)
          _Section(
            // Named for the person, not the state. "$name is waiting" is what
            // is actually true; "NEED_TO_DISCUSS" is how the database says it.
            label: l.responseAttentionSectionWaiting(
              partnerName.toUpperCase(),
            ),
            count: waiting.length,
            accent: true,
            children: [
              for (final item in waiting)
                _Row(
                  item: item,
                  partnerName: partnerName,
                  onOpen: () => onOpen(item),
                ),
            ],
          ),
        if (toAnswer.isNotEmpty)
          _Section(
            label: l.responseAttentionSectionCompletions,
            count: toAnswer.length,
            children: [
              for (final (index, item) in toAnswer.indexed)
                // Only the first carries inline controls. Offering them on
                // every row turns answering into clearing a queue, and this
                // screen is the one place that must not read like a task list.
                index == 0
                    ? _InlineRespond(
                        item: item,
                        partnerName: partnerName,
                        busy: sending == item.occurrenceId,
                        onRespond: (type) => onRespond(item, type),
                      )
                    : _Row(
                        item: item,
                        partnerName: partnerName,
                        onOpen: () => onOpen(item),
                      ),
            ],
          ),
        if (toRevisit.isNotEmpty)
          _Section(
            // Never "overdue" or "missed". `REQ-REVIEW-001`: past due is a
            // prompt to look, and the software assigns no consequence.
            label: l.responseAttentionSectionLookBack,
            count: toRevisit.length,
            children: [
              for (final item in toRevisit)
                _Row(
                  item: item,
                  partnerName: partnerName,
                  onOpen: () => onOpen(item),
                ),
            ],
          ),
        const SizedBox(height: DsSpacing.space10),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.partnerName});

  final String partnerName;

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    return Padding(
      padding: const EdgeInsets.only(
        top: DsSpacing.space4,
        bottom: DsSpacing.space6,
      ),
      child: Row(
        children: [
          Text(
            l.responseAttention,
            style: DsTextStyles.titlePage.copyWith(
              color: DsColors.textOnRitualPrimary,
              fontSize: 23,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: DsSpacing.space4),
          const Spacer(),
          const DsSvg(
            asset: DsAssets.markPresence,
            tone: DsAssetTone.relationship,
            width: 20,
            height: 20,
          ),
          const SizedBox(width: DsSpacing.space3),
          Flexible(
            child: Text(
              l.responsePartnerPresent(partnerName),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: DsTextStyles.bodySecondary.copyWith(
                color: DsColors.textOnRitualRelationshipLarge,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// How much is here, in human terms. Counts, never a score.
class _Summary extends StatelessWidget {
  const _Summary({required this.view});

  final AttentionView view;

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    final moments = view.items.length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l.responseAttentionSummaryLabel,
          style: DsTextStyles.labelRitual.copyWith(
            color: DsColors.textOnRitualMuted,
            fontSize: 10,
            letterSpacing: 1.8,
          ),
        ),
        const SizedBox(height: DsSpacing.space3),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              l.responseAttentionMoments(moments),
              style: DsTextStyles.bodyPrimary.copyWith(
                color: DsColors.textOnRitualPrimary,
                fontSize: 17,
              ),
            ),
            const Spacer(),
            Flexible(
              child: Text(
                [
                  if (view.needsResponseCount > 0)
                    l.responseAttentionAwaiting(view.needsResponseCount),
                  if (view.needsReviewCount > 0)
                    l.responseAttentionToRevisit(view.needsReviewCount),
                ].join(' · '),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.right,
                style: DsTextStyles.bodySecondary.copyWith(
                  color: DsColors.textOnRitualMuted,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({
    required this.label,
    required this.count,
    required this.children,
    this.accent = false,
  });

  final String label;
  final int count;
  final List<Widget> children;

  /// The waiting section carries a Terracotta rule down its edge: someone is
  /// waiting on a conversation, which is the most human thing on the screen.
  final bool accent;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: DsSpacing.space6),
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: DsTextStyles.labelRitual.copyWith(
                  color: DsColors.textOnRitualMuted,
                  fontSize: 10,
                  letterSpacing: 1.8,
                ),
              ),
            ),
            _Count(count),
          ],
        ),
        const SizedBox(height: DsSpacing.space4),
        if (accent)
          // A left border rather than an `IntrinsicHeight` + `Row`: that
          // combination lays the row out at unbounded width, so every child
          // takes its natural size and a sentence becomes 99,692 pixels wide.
          // The border draws the same rule and constrains nothing.
          Container(
            padding: const EdgeInsets.only(left: DsSpacing.space4),
            decoration: const BoxDecoration(
              border: Border(
                left: BorderSide(
                  color: DsPrimitiveColors.terracotta,
                  width: DsBorderWidths.selected,
                ),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: children,
            ),
          )
        else
          ...children,
      ],
    );
  }
}

class _Count extends StatelessWidget {
  const _Count(this.value);

  final int value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22,
      height: 22,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: DsColors.surfaceRitualRaised,
      ),
      child: Text(
        '$value',
        style: DsTextStyles.bodySecondary.copyWith(
          color: DsColors.textOnRitualSecondary,
          fontSize: 11,
        ),
      ),
    );
  }
}

/// One item, opened in full to answer.
class _Row extends StatelessWidget {
  const _Row({
    required this.item,
    required this.partnerName,
    required this.onOpen,
  });

  final AttentionItem item;
  final String partnerName;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onOpen,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: DsSpacing.space3),
        child: Row(
          children: [
            DsSvg(
              asset: _markFor(item.state),
              // The tone follows the mark: `mark.guidance` licenses primary
              // and authority, not relationship. The freeze refuses the wrong
              // pairing at runtime, which is how this was caught.
              tone: _toneFor(item.state),
              width: 24,
              height: 24,
            ),
            const SizedBox(width: DsSpacing.space4),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: DsTextStyles.displayRitual.copyWith(
                      color: DsColors.textOnRitualPrimary,
                      fontSize: 17,
                      height: 1.15,
                    ),
                  ),
                  const SizedBox(height: DsSpacing.space2),
                  Text(
                    _lineFor(L.of(context), item, partnerName),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: DsTextStyles.bodySecondary.copyWith(
                      color: DsColors.textOnRitualMuted,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: DsSpacing.space3),
            const DsGlyphIcon(DsGlyph.forward),
          ],
        ),
      ),
    );
  }
}

/// The first completion, answerable without leaving.
///
/// `REQ-ATTN-001` asks for common responses inline and `REQ-ACK-001` puts basic
/// acknowledgement at two taps. Both are satisfied here and nowhere else on
/// this screen: only wordless types appear, because a field in a list row
/// would make writing feel like filling in a form.
class _InlineRespond extends StatelessWidget {
  const _InlineRespond({
    required this.item,
    required this.partnerName,
    required this.busy,
    required this.onRespond,
  });

  final AttentionItem item;
  final String partnerName;
  final bool busy;
  final void Function(HumanResponse) onRespond;

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    return Container(
      margin: const EdgeInsets.symmetric(vertical: DsSpacing.space3),
      padding: const EdgeInsets.all(DsSpacing.space4),
      decoration: BoxDecoration(
        color: DsColors.surfaceRitualRaised,
        borderRadius: BorderRadius.circular(DsRadii.card),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            item.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: DsTextStyles.displayRitual.copyWith(
              color: DsColors.textOnRitualPrimary,
              fontSize: 18,
              height: 1.15,
            ),
          ),
          const SizedBox(height: DsSpacing.space2),
          Text(
            _lineFor(l, item, partnerName),
            style: DsTextStyles.bodySecondary.copyWith(
              color: DsColors.textOnRitualMuted,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: DsSpacing.space5),
          Text(
            l.responseAttentionRespondTo(partnerName.toUpperCase()),
            style: DsTextStyles.labelRitual.copyWith(
              color: DsColors.textOnRitualMuted,
              fontSize: 9,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: DsSpacing.space3),
          Row(
            children: [
              Expanded(
                child: _InlineButton(
                  asset: DsAssets.stateAcknowledged,
                  label: l.responseTypeAcknowledge,
                  busy: busy,
                  onTap: () => onRespond(HumanResponse.acknowledge),
                ),
              ),
              const SizedBox(width: DsSpacing.space3),
              Expanded(
                child: _InlineButton(
                  // `response.praise` belongs to SCR-33's contract, not this
                  // screen's. Presence is the registered mark here, and the
                  // label carries the meaning.
                  asset: DsAssets.markPresence,
                  label: l.responseTypePraise,
                  busy: busy,
                  onTap: () => onRespond(HumanResponse.praise),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InlineButton extends StatelessWidget {
  const _InlineButton({
    required this.asset,
    required this.label,
    required this.busy,
    required this.onTap,
  });

  final DsAssetId asset;
  final String label;
  final bool busy;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: busy ? null : onTap,
      borderRadius: BorderRadius.circular(DsRadii.control),
      child: Container(
        height: 48,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(DsRadii.control),
          border: Border.all(
            color: DsColors.borderOnRitualHairline,
            width: DsBorderWidths.hairline,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            DsSvg(
              asset: asset,
              tone: DsAssetTone.relationship,
              width: 18,
              height: 18,
            ),
            const SizedBox(width: DsSpacing.space3),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: DsTextStyles.bodySecondary.copyWith(
                  color: busy
                      ? DsColors.textOnRitualMuted
                      : DsColors.textOnRitualPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Nothing waiting. Calm, and explicitly not an achievement.
class _Empty extends StatelessWidget {
  const _Empty({required this.partnerName});

  final String partnerName;

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: DsSpacing.space5),
      children: [
        _Header(partnerName: partnerName),
        const SizedBox(height: DsSpacing.space10),
        Center(
          child: Text(
            l.responseAttentionEmptyTitle,
            textAlign: TextAlign.center,
            style: DsTextStyles.displayRitual.copyWith(
              color: DsColors.textOnRitualPrimary,
            ),
          ),
        ),
        const SizedBox(height: DsSpacing.space6),
        Center(
          child: Text(
            // No "all caught up", no tick, no streak. An empty list is a fact
            // about now, not a reward for clearing one.
            l.responseAttentionEmptyDetail,
            textAlign: TextAlign.center,
            style: DsTextStyles.bodySecondary.copyWith(
              color: DsColors.textOnRitualMuted,
              height: 22 / 14,
            ),
          ),
        ),
      ],
    );
  }
}

/// Backend state names never reach a person.
String _lineFor(L l, AttentionItem item, String partner) {
  final who = item.actorDisplayName ?? partner;
  final when = item.occurredAt == null ? null : _ago(l, item.occurredAt!);
  final what = switch (item.state) {
    'NEED_TO_DISCUSS' => l.responseStateAskedToDiscuss,
    'RESCHEDULE_REQUESTED' => l.responseStateAskedForNewTime,
    'EXCUSE_REQUESTED' => l.responseStateCantDoThis,
    'WAITING_ACK' => l.responseStateCompleted,
    'NEEDS_REVIEW' => l.responseStateStillOpen,
    _ => l.responseStateWaiting,
  };
  return [who, what, ?when].join(' · ');
}

/// Only the three marks SCR-32's asset contract registers.
DsAssetId _markFor(String state) => switch (state) {
      'WAITING_ACK' => DsAssets.stateAcknowledged,
      'NEEDS_REVIEW' => DsAssets.markGuidance,
      _ => DsAssets.markPresence,
    };

/// The tone each mark licenses. A review is a prompt to look, and `authority`
/// is the register the freeze gives it — never the relationship tone, which
/// belongs to something a person did.
DsAssetTone _toneFor(String state) => switch (state) {
      'NEEDS_REVIEW' => DsAssetTone.primary,
      _ => DsAssetTone.relationship,
    };

/// Elapsed time, in the coarse terms a person uses. Formatting only: it
/// decides no state, ordering or affordance (REQ-STATE-001).
String _ago(L l, DateTime at) {
  final elapsed = DateTime.now().difference(at.toLocal());
  if (elapsed.inMinutes < 60) return l.responseAgoMinutes(elapsed.inMinutes);
  if (elapsed.inHours < 24) return l.responseAgoHours(elapsed.inHours);
  if (elapsed.inDays == 1) return l.responseAgoYesterday;
  return l.responseAgoDays(elapsed.inDays);
}
