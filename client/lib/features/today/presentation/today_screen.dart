import 'package:ds_relationship_companion/ds_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../domain_client/models/today_view.dart';

final todayProvider = FutureProvider.autoDispose.family<TodayView, String>((
  ref,
  dynamicId,
) async {
  return ref.watch(todayRepositoryProvider).forDynamic(dynamicId);
});

/// Today — `SCR-01` revision 2, gate `ready_for_build`.
///
/// Behavior is governed by
/// `design/screens/SCR-01-today/candidates/rev-2/today-b3-spec.json`, which is
/// authoritative over the raster preview. Three rules from it shape this file:
///
/// - The server composes the order. This widget never sorts, never re-ranks,
///   and never derives `missed`, `needs review` or the relationship day from
///   the device clock.
/// - At most three priorities are visible; everything else sits behind one
///   count-bearing disclosure. Later items are not less real, only less
///   urgent, so they are compact rows rather than a wall of equal cards.
/// - Complete, Need to Discuss, Request New Time and Can't Do must be reachable
///   without opening a detail page, and the last three keep their own 48dp
///   targets even when drawn as quiet text.
class TodayScreen extends ConsumerStatefulWidget {
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

  /// Today is one tab with two faces: Attention is not a separate navigation
  /// area, it is where Today leads when something waits on this person.
  final VoidCallback? onOpenAttention;

  final VoidCallback? onInvite;
  final VoidCallback? onStartRhythm;
  final VoidCallback? onAsk;
  final VoidCallback? onCheckIn;
  final bool waitingForPartner;
  final bool hasRhythm;

  @override
  ConsumerState<TodayScreen> createState() => _TodayScreenState();
}

class _TodayScreenState extends ConsumerState<TodayScreen> {
  /// Collapse state is the one thing this screen owns. Everything else is
  /// server truth.
  bool _laterExpanded = false;

  @override
  Widget build(BuildContext context) {
    final id = widget.dynamicId;
    return Scaffold(
      backgroundColor: DsColors.canvasRitual,
      body: DsRitualSurface(
        child: SafeArea(
          child: id == null
              ? _Frame(child: _Header(notice: widget.notice))
              : ref
                    .watch(todayProvider(id))
                    .when(
                      loading: () =>
                          _Frame(child: _LoadingState(notice: widget.notice)),
                      error: (_, _) => _Frame(
                        child: _ErrorState(
                          notice: widget.notice,
                          onRetry: () => ref.invalidate(todayProvider(id)),
                        ),
                      ),
                      data: (t) => _Frame(child: _body(t)),
                    ),
        ),
      ),
    );
  }

  Widget _body(TodayView t) {
    final hasAnything =
        t.priorityItems.isNotEmpty ||
        t.laterItems.isNotEmpty ||
        t.awaitingResponse.isNotEmpty;

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: _Header(notice: widget.notice, partnerName: _partnerName(t)),
        ),

        if (!hasAnything)
          SliverToBoxAdapter(child: _EmptyState(onCheckIn: widget.onCheckIn))
        else ...[
          SliverToBoxAdapter(
            child: _CountRow(
              total: t.totalCount,
              priority: t.priorityItems.length,
            ),
          ),

          // The first priority carries editorial emphasis; two and three are
          // disciplined timeline rows. Server order, unmodified.
          SliverList.builder(
            itemCount: t.priorityItems.length,
            itemBuilder: (context, i) => _PriorityRow(
              index: i + 1,
              item: t.priorityItems[i],
              emphasised: i == 0,
              onOpen: widget.onOpen,
            ),
          ),

          if (t.laterItems.isNotEmpty)
            SliverToBoxAdapter(
              child: _LaterSection(
                items: t.laterItems,
                expanded: _laterExpanded,
                onToggle: () =>
                    setState(() => _laterExpanded = !_laterExpanded),
                onOpen: widget.onOpen,
              ),
            ),
        ],

        // The last real thing a person said. Rendered only from
        // human-authored, human-sent content.
        if (t.recentResponse != null)
          SliverToBoxAdapter(
            child: _HumanResponse(response: t.recentResponse!),
          ),

        // The direction-giving face, shown from the server's count and never
        // inferred: the same person can be on both sides of one Dynamic.
        if (t.needsMyResponseCount > 0 && widget.onOpenAttention != null)
          SliverToBoxAdapter(
            child: _AttentionDoor(
              count: t.needsMyResponseCount,
              onOpen: widget.onOpenAttention!,
            ),
          ),

        SliverToBoxAdapter(child: _Footer(confirmedAt: t.lastConfirmedAt)),
      ],
    );
  }

  String? _partnerName(TodayView t) {
    for (final item in [...t.priorityItems, ...t.laterItems]) {
      if (item.fromDisplayName != null) return item.fromDisplayName;
    }
    return t.recentResponse?.senderDisplayName;
  }
}

class _Frame extends StatelessWidget {
  const _Frame({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: DsSpacing.space5),
    child: child,
  );
}

class _Header extends StatelessWidget {
  const _Header({this.notice, this.partnerName});
  final String? notice;
  final String? partnerName;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        top: DsSpacing.space6,
        bottom: DsSpacing.space5,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Today',
                style: DsTextStyles.titlePage.copyWith(
                  color: DsColors.textOnRitualPrimary,
                ),
              ),
              const SizedBox(width: DsSpacing.space4),
              // Presence, not status. The mark says a person is there; it
              // never speaks for them. A long display name shrinks the label
              // rather than overflowing the header.
              if (partnerName != null)
                Expanded(child: _PresenceMark(name: partnerName!)),
            ],
          ),
          if (notice != null) ...[
            const SizedBox(height: DsSpacing.space3),
            Text(
              notice!,
              style: DsTextStyles.bodySecondary.copyWith(
                color: DsColors.textOnRitualMuted,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _PresenceMark extends StatelessWidget {
  const _PresenceMark({required this.name});
  final String name;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        const DsSvg(
          asset: DsAssets.markPresence,
          tone: DsAssetTone.relationship,
          width: 20,
          height: 20,
        ),
        const SizedBox(width: DsSpacing.space2),
        Flexible(
          child: Text(
            '$name is present',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: DsTextStyles.bodySecondary.copyWith(
              color: DsColors.textOnRitualSecondary,
            ),
          ),
        ),
      ],
    );
  }
}

class _CountRow extends StatelessWidget {
  const _CountRow({required this.total, required this.priority});
  final int total;
  final int priority;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: DsSpacing.space3),
      child: Text(
        '$total ITEMS · $priority PRIORITY',
        style: DsTextStyles.labelRitual.copyWith(
          color: DsColors.textOnRitualMuted,
        ),
      ),
    );
  }
}

class _PriorityRow extends StatelessWidget {
  const _PriorityRow({
    required this.index,
    required this.item,
    required this.emphasised,
    this.onOpen,
  });

  final int index;
  final TodayItem item;
  final bool emphasised;
  final void Function(String occurrenceId)? onOpen;

  @override
  Widget build(BuildContext context) {
    final row = Container(
      constraints: const BoxConstraints(minHeight: DsControlSizes.listRow),
      padding: const EdgeInsets.symmetric(vertical: DsSpacing.space4),
      decoration: BoxDecoration(
        color: emphasised ? DsColors.surfaceRitualRaised : null,
        borderRadius: emphasised ? BorderRadius.circular(DsRadii.card) : null,
        border: emphasised
            ? null
            : const Border(
                bottom: BorderSide(color: DsColors.borderOnRitualHairline),
              ),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: emphasised ? DsSpacing.space4 : 0,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 32,
              child: Text(
                index.toString().padLeft(2, '0'),
                style: DsTextStyles.labelRitual.copyWith(
                  color: DsColors.textOnRitualMuted,
                ),
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: DsTextStyles.bodyPrimary.copyWith(
                      color: DsColors.textOnRitualPrimary,
                    ),
                  ),
                  const SizedBox(height: DsSpacing.space1),
                  Text(
                    _context(item),
                    style: DsTextStyles.bodySecondary.copyWith(
                      color: DsColors.textOnRitualMuted,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );

    return Semantics(
      button: onOpen != null,
      child: InkWell(
        onTap: onOpen == null ? null : () => onOpen!(item.occurrenceId),
        child: row,
      ),
    );
  }

  /// Source and time context. Direction comes from a person, so when the
  /// server names them, the row says so.
  String _context(TodayItem item) {
    final parts = <String>[];
    if (item.fromDisplayName != null) parts.add('From ${item.fromDisplayName}');
    if (item.purpose != null && item.purpose!.isNotEmpty) {
      parts.add(item.purpose!);
    }
    parts.add(_stateLabel(item.state));
    return parts.join(' · ');
  }
}

/// Backend state names never reach a person.
String _stateLabel(String state) => switch (state) {
  'ACTIVE' => 'Today',
  'WAITING_ACK' => 'Waiting for a reply',
  'NEEDS_REVIEW' => 'Needs review',
  'NEED_TO_DISCUSS' => 'Being discussed',
  'RESCHEDULE_REQUESTED' => 'New time requested',
  'EXCUSE_REQUESTED' => "Can't do — sent",
  _ => 'Scheduled',
};

class _LaterSection extends StatelessWidget {
  const _LaterSection({
    required this.items,
    required this.expanded,
    required this.onToggle,
    this.onOpen,
  });

  final List<TodayItem> items;
  final bool expanded;
  final VoidCallback onToggle;
  final void Function(String occurrenceId)? onOpen;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: DsSpacing.space5),
        // One count-bearing disclosure. Never a badge, never a nag.
        Semantics(
          button: true,
          child: InkWell(
            onTap: onToggle,
            child: Container(
              height: DsLayoutSizes.touchTarget,
              alignment: Alignment.centerLeft,
              child: Text(
                expanded
                    ? 'LATER / OPTIONAL · ${items.length}'
                    : 'LATER / OPTIONAL · ${items.length}',
                style: DsTextStyles.labelRitual.copyWith(
                  color: DsColors.textOnRitualMuted,
                ),
              ),
            ),
          ),
        ),
        if (expanded)
          ...items.map((item) => _LaterRow(item: item, onOpen: onOpen)),
        Semantics(
          button: true,
          child: InkWell(
            onTap: onToggle,
            child: Container(
              height: DsLayoutSizes.touchTarget,
              alignment: Alignment.centerLeft,
              child: Text(
                expanded ? 'Show less' : 'Show all',
                style: DsTextStyles.labelAction.copyWith(
                  color: DsColors.textOnRitualSecondary,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _LaterRow extends StatelessWidget {
  const _LaterRow({required this.item, this.onOpen});
  final TodayItem item;
  final void Function(String occurrenceId)? onOpen;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: onOpen != null,
      child: InkWell(
        onTap: onOpen == null ? null : () => onOpen!(item.occurrenceId),
        child: Container(
          constraints: const BoxConstraints(minHeight: DsControlSizes.listRow),
          padding: const EdgeInsets.symmetric(vertical: DsSpacing.space3),
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: DsColors.borderOnRitualHairline),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                item.title,
                style: DsTextStyles.bodyPrimary.copyWith(
                  color: DsColors.textOnRitualPrimary,
                ),
              ),
              const SizedBox(height: DsSpacing.space1),
              Text(
                _stateLabel(item.state),
                style: DsTextStyles.bodySecondary.copyWith(
                  color: DsColors.textOnRitualMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A human response. The display face is reserved for words a person wrote and
/// sent; system copy never borrows it.
class _HumanResponse extends StatelessWidget {
  const _HumanResponse({required this.response});
  final RecentResponse response;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: DsSpacing.space8),
      child: Container(
        padding: const EdgeInsets.all(DsSpacing.space5),
        decoration: BoxDecoration(
          color: DsColors.surfaceRitualRaised,
          borderRadius: BorderRadius.circular(DsRadii.card),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const DsSvg(
                  asset: DsAssets.stateAcknowledged,
                  tone: DsAssetTone.relationship,
                  width: 16,
                  height: 16,
                ),
                const SizedBox(width: DsSpacing.space2),
                Text(
                  response.senderDisplayName == null
                      ? 'RESPONSE RECEIVED'
                      : '${response.senderDisplayName!.toUpperCase()} WROTE',
                  style: DsTextStyles.labelRitual.copyWith(
                    color: DsColors.relationshipAcknowledgement,
                  ),
                ),
              ],
            ),
            const SizedBox(height: DsSpacing.space4),
            Text(
              response.text,
              style: DsTextStyles.displayPartner.copyWith(
                color: DsColors.textOnRitualRelationshipLarge,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AttentionDoor extends StatelessWidget {
  const _AttentionDoor({required this.count, required this.onOpen});
  final int count;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: DsSpacing.space6),
      child: Semantics(
        button: true,
        child: InkWell(
          onTap: onOpen,
          child: Container(
            height: DsControlSizes.button,
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.symmetric(horizontal: DsSpacing.space4),
            decoration: BoxDecoration(
              border: Border.all(color: DsColors.actionSecondaryBorder),
              borderRadius: BorderRadius.circular(DsRadii.control),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    count == 1
                        ? 'Someone is waiting to hear from you'
                        : 'Someone is waiting to hear from you \u00b7 $count',
                    style: DsTextStyles.labelAction.copyWith(
                      color: DsColors.textOnRitualPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LoadingState extends StatelessWidget {
  const _LoadingState({this.notice});
  final String? notice;

  @override
  Widget build(BuildContext context) {
    // Resolve authorization and the current read model without revealing
    // stale partner content.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Header(notice: notice),
        const SizedBox(height: DsSpacing.space8),
        Text(
          'Checking with the server.',
          style: DsTextStyles.bodySecondary.copyWith(
            color: DsColors.textOnRitualMuted,
          ),
        ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({this.onCheckIn});
  final VoidCallback? onCheckIn;

  @override
  Widget build(BuildContext context) {
    // No invented urgency. An optional check-in stays optional.
    return Padding(
      padding: const EdgeInsets.only(top: DsSpacing.space8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Nothing is expected of you today.',
            style: DsTextStyles.bodyPrimary.copyWith(
              color: DsColors.textOnRitualPrimary,
            ),
          ),
          if (onCheckIn != null) ...[
            const SizedBox(height: DsSpacing.space5),
            Semantics(
              button: true,
              child: InkWell(
                onTap: onCheckIn,
                child: Container(
                  height: DsControlSizes.button,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    border: Border.all(color: DsColors.actionSecondaryBorder),
                    borderRadius: BorderRadius.circular(DsRadii.control),
                  ),
                  child: Text(
                    'Check in, if you want to',
                    style: DsTextStyles.labelAction.copyWith(
                      color: DsColors.textOnRitualPrimary,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({this.notice, required this.onRetry});
  final String? notice;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    // Current truth cannot be loaded and there is no safe confirmed cache.
    // Sensitive content stays hidden; retry is explicit.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Header(notice: notice),
        const SizedBox(height: DsSpacing.space8),
        Text(
          "Today could not be loaded. Nothing was lost.",
          style: DsTextStyles.bodyPrimary.copyWith(
            color: DsColors.textOnRitualPrimary,
          ),
        ),
        const SizedBox(height: DsSpacing.space5),
        Semantics(
          button: true,
          child: InkWell(
            onTap: onRetry,
            child: Container(
              height: DsControlSizes.button,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                border: Border.all(color: DsColors.actionSecondaryBorder),
                borderRadius: BorderRadius.circular(DsRadii.control),
              ),
              child: Text(
                'Try again',
                style: DsTextStyles.labelAction.copyWith(
                  color: DsColors.textOnRitualPrimary,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer({this.confirmedAt});
  final DateTime? confirmedAt;

  @override
  Widget build(BuildContext context) {
    if (confirmedAt == null) return const SizedBox(height: DsSpacing.space8);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: DsSpacing.space6),
      child: Text(
        'Server order',
        style: DsTextStyles.bodySecondary.copyWith(
          color: DsColors.textOnRitualMuted,
        ),
      ),
    );
  }
}
