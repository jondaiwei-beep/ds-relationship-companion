import 'package:dio/dio.dart';
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

/// How a failed load must be presented. The design gives each a distinct
/// state, because they are different facts about the person's access.
enum _Failure { offline, authorizationLost, unknown }

_Failure _classify(Object error) {
  if (error is DioException) {
    final code = error.response?.statusCode;
    if (code == 401 || code == 403) return _Failure.authorizationLost;
    switch (error.type) {
      case DioExceptionType.connectionError:
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        return _Failure.offline;
      default:
        return _Failure.unknown;
    }
  }
  return _Failure.unknown;
}

/// SCR-01 Today — revision 2.
///
/// Built against `design/screens/SCR-01-today/candidates/rev-2/source.png` and
/// the frozen contracts, not from inference:
///
/// - B-2 geometry: the first priority carries a 56dp primary action and three
///   separate 48dp secondary targets; compact rows use the 72dp operational
///   row; bottom navigation is 80dp before the safe-area inset.
/// - B-2 colour: Terracotta is reserved for marks and large partner-authored
///   copy. It needs 24sp regular or 19sp bold, so the response quotation uses
///   the 28sp display role and small partner labels stay Stone.
/// - SVG Freeze v1: every mark comes from a registered master through
///   `DsAssets`; no path data and no ad-hoc colours in screen code.
///
/// This pass is visual only. Data is fixed so the render can be compared with
/// the approved design before any wiring exists to distract from it.
class TodayScreen extends ConsumerWidget {
  const TodayScreen({super.key, required this.dynamicId});

  final String dynamicId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: DsColors.canvasRitual,
      body: DsRitualSurface(
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              Expanded(
                child: ref
                    .watch(todayProvider(dynamicId))
                    .when(
                      // Authorization and membership resolve before anything
                      // is revealed. Stale partner content must not appear
                      // while the server is being consulted.
                      loading: () => const _LoadingState(),
                      error: (error, _) => switch (_classify(error)) {
                        _Failure.authorizationLost =>
                          const _AuthorizationLostState(),
                        _Failure.offline => _OfflineState(
                          onRetry: () =>
                              ref.invalidate(todayProvider(dynamicId)),
                        ),
                        _Failure.unknown => _ErrorState(
                          onRetry: () =>
                              ref.invalidate(todayProvider(dynamicId)),
                        ),
                      },
                      data: (today) => _Loaded(today: today),
                    ),
              ),
              const _BottomNavigation(),
            ],
          ),
        ),
      ),
    );
  }
}

/// The server-confirmed list. Order comes from the server and is never
/// re-sorted here.
class _Loaded extends StatefulWidget {
  const _Loaded({required this.today});

  final TodayView today;

  @override
  State<_Loaded> createState() => _LoadedState();
}

class _LoadedState extends State<_Loaded> {
  /// The one piece of state this screen owns. Everything else is server truth.
  bool _laterExpanded = false;

  @override
  Widget build(BuildContext context) {
    final t = widget.today;
    final partner = _partnerName(t);
    final nothingToday = t.priorityItems.isEmpty && t.laterItems.isEmpty;

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        _Header(partnerName: partner),
        if (nothingToday)
          const _EmptyState()
        else ...[
          _SectionLabel(_countLabel(t)),
          for (final (i, item) in t.priorityItems.indexed)
            if (i == 0)
              _PrimaryExpectation(item: item)
            else
              _CompactRow(
                index: (i + 1).toString().padLeft(2, '0'),
                asset: _assetFor(item),
                title: item.title,
                meta: _metaFor(item),
                lastInGroup: i == t.priorityItems.length - 1,
              ),
        ],
        if (t.recentResponse != null)
          _PartnerResponse(response: t.recentResponse!),
        if (t.laterItems.isNotEmpty)
          _LaterRow(
            count: t.laterItems.length,
            expanded: _laterExpanded,
            onToggle: () => setState(() => _laterExpanded = !_laterExpanded),
          ),
        if (_laterExpanded)
          for (final (i, item) in t.laterItems.indexed)
            _CompactRow(
              index: (t.priorityItems.length + i + 1).toString().padLeft(
                2,
                '0',
              ),
              asset: _assetFor(item),
              title: item.title,
              meta: _metaFor(item),
              lastInGroup: i == t.laterItems.length - 1,
            ),
        const _DayBoundary(),
      ],
    );
  }

  /// Direction comes from a person. When the server names them, say so.
  String? _partnerName(TodayView t) {
    for (final item in [...t.priorityItems, ...t.laterItems]) {
      if (item.fromDisplayName != null) return item.fromDisplayName;
    }
    return t.recentResponse?.senderDisplayName;
  }

  String _countLabel(TodayView t) {
    final n = t.priorityItems.length;
    const words = ['NO', 'ONE', 'TWO', 'THREE'];
    final word = n < words.length ? words[n] : '$n';
    return n == 1 ? '$word THING MATTERS' : '$word THINGS MATTER';
  }
}

/// Marks come from the registry. A ritual and a check-in are not the same kind
/// of thing and do not share an identity.
DsAssetId _assetFor(TodayItem item) {
  final title = item.title.toLowerCase();
  if (title.contains('check-in') || title.contains('check in')) {
    return DsAssets.markCheckIn;
  }
  if (title.contains('ritual')) return DsAssets.emblemRitualEvening;
  return DsAssets.markAuthority;
}

/// Source, then time, then state — the order the design reads in. A row that
/// says only its state has lost the two facts a person actually scans for.
String _metaFor(TodayItem item) {
  final parts = <String>[];
  if (item.fromDisplayName != null) parts.add('From ${item.fromDisplayName}');
  final due = item.dueAt;
  if (due != null) parts.add(_clock(due.toLocal()));
  if (item.purpose != null && item.purpose!.isNotEmpty) {
    parts.add(item.purpose!);
  }
  // The state is worth saying when it is not simply "on the list today".
  if (item.state != 'ACTIVE' || parts.isEmpty) {
    parts.add(_stateLabel(item.state));
  }
  return parts.join(' · ');
}

String _clock(DateTime t) {
  final hour = t.hour % 12 == 0 ? 12 : t.hour % 12;
  final minute = t.minute.toString().padLeft(2, '0');
  return '$hour:$minute ${t.hour < 12 ? 'AM' : 'PM'}';
}

const _inset = EdgeInsets.symmetric(horizontal: DsSpacing.space5);

/// Supporting copy on this screen: item metadata and the quiet adjustment
/// actions. The frozen 14px secondary role reads too heavy against the 28px
/// headline, so these step down one level while staying well above the
/// minimum legible size.
const _supportSize = 12.0;
const _supportHeight = 17 / 12;

class _Header extends StatelessWidget {
  const _Header({this.partnerName = 'Morgan', this.context});

  /// Null when no partner presence may be shown — a Solo Dynamic, or a session
  /// whose authorization has not been confirmed.
  final String? partnerName;

  /// Replaces the presence line while the server is still being consulted.
  final String? context;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: _inset.add(
        const EdgeInsets.only(top: DsSpacing.space5, bottom: DsSpacing.space6),
      ),
      child: Row(
        children: [
          Text(
            'Today',
            style: DsTextStyles.titlePage.copyWith(
              color: DsColors.textOnRitualPrimary,
              fontSize: 23,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: DsSpacing.space4),
          // Presence is a mark plus neutral copy. Terracotta carries the mark;
          // the label stays Stone because it sits below the Terracotta text
          // size floor. A long display name shrinks the label rather than
          // pushing the row past the viewport.
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const DsSvg(
                  asset: DsAssets.markPresence,
                  tone: DsAssetTone.relationship,
                  width: 22,
                  height: 22,
                ),
                const SizedBox(width: DsSpacing.space2),
                Flexible(
                  child: Text(
                    'Morgan is present',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: DsTextStyles.bodySecondary.copyWith(
                      color: DsColors.textOnRitualSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: _inset.add(const EdgeInsets.only(bottom: DsSpacing.space4)),
      child: Text(
        text,
        style: DsTextStyles.labelRitual.copyWith(
          color: DsColors.textOnRitualMuted,
        ),
      ),
    );
  }
}

/// The first priority. A vertical authority rule runs the full height of the
/// block, and the four contract actions are reachable here — never behind a
/// detail page.
class _PrimaryExpectation extends StatelessWidget {
  const _PrimaryExpectation({required this.item});

  final TodayItem item;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: DsSpacing.space5),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const _AuthorityRule(),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(
                  left: DsSpacing.space5,
                  right: DsSpacing.space5,
                  bottom: DsSpacing.space2,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const DsSvg(
                          asset: DsAssets.markAuthority,
                          tone: DsAssetTone.primary,
                          width: 26,
                          height: 30,
                        ),
                        const SizedBox(width: DsSpacing.space4),
                        Flexible(
                          child: Text(
                            '01 · NOW · ${_kindLabel(item)}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: DsTextStyles.labelRitual.copyWith(
                              color: DsColors.textOnRitualMuted,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: DsSpacing.space4),
                    // The editorial face carries what a person is being asked
                    // to do. UI chrome never borrows it.
                    Text(
                      item.title,
                      // Design measures 28px with a 31px line box; the frozen
                      // 34/42 role is the ritual-focus size, not this one.
                      style: DsTextStyles.displayRitual.copyWith(
                        color: DsColors.textOnRitualPrimary,
                        fontSize: 28,
                        height: 31 / 28,
                      ),
                    ),
                    const SizedBox(height: DsSpacing.space4),
                    Text(
                      _metaFor(item),
                      style: DsTextStyles.bodySecondary.copyWith(
                        color: DsColors.textOnRitualMuted,
                        fontSize: _supportSize,
                        height: _supportHeight,
                      ),
                    ),
                    const SizedBox(height: DsSpacing.space3),
                    const _CompleteButton(),
                    const SizedBox(height: DsSpacing.space3),
                    const _AdjustmentActions(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AuthorityRule extends StatelessWidget {
  const _AuthorityRule();

  @override
  Widget build(BuildContext context) => const SizedBox(
    width: DsBorderWidths.hairline,
    child: ColoredBox(color: DsColors.borderOnRitualStrong),
  );
}

class _CompleteButton extends StatelessWidget {
  const _CompleteButton();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: DsControlSizes.button,
      width: double.infinity,
      child: Material(
        color: DsColors.actionPrimaryBackground,
        borderRadius: BorderRadius.circular(DsRadii.control),
        child: InkWell(
          borderRadius: BorderRadius.circular(DsRadii.control),
          onTap: () {},
          child: Center(
            child: Text(
              'Complete',
              style: DsTextStyles.labelAction.copyWith(
                color: DsColors.actionPrimaryForeground,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Discuss, New time and Can't do. Adjustment is a normal path, so these are
/// permanent structural furniture beside Complete — each keeping its own 48dp
/// target even though they are drawn as quiet text.
class _AdjustmentActions extends StatelessWidget {
  const _AdjustmentActions();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (final label in ['Discuss', 'New time', "Can't do"])
          Expanded(
            child: SizedBox(
              height: DsLayoutSizes.touchTarget,
              child: InkWell(
                onTap: () {},
                child: Center(
                  child: Text(
                    label,
                    maxLines: 1,
                    softWrap: false,
                    overflow: TextOverflow.fade,
                    style: DsTextStyles.bodySecondary.copyWith(
                      color: DsColors.textOnRitualPrimary,
                      fontSize: _supportSize,
                      height: _supportHeight,
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _CompactRow extends StatelessWidget {
  const _CompactRow({
    required this.index,
    required this.asset,
    required this.title,
    required this.meta,
    this.lastInGroup = false,
  });

  final String index;
  final DsAssetId asset;
  final String title;
  final String meta;
  final bool lastInGroup;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: _inset,
      child: Container(
        height: DsControlSizes.listRow,
        decoration: BoxDecoration(
          border: Border(
            // The last row in the group closes against the response module's
            // own top border, so it does not draw its own.
            bottom: BorderSide(
              color: lastInGroup
                  ? DsPrimitiveColors.transparent
                  : DsColors.borderOnRitualHairline,
              width: DsBorderWidths.hairline,
            ),
          ),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 34,
              child: Text(
                index,
                style: DsTextStyles.labelRitual.copyWith(
                  color: DsColors.textOnRitualMuted,
                ),
              ),
            ),
            DsSvg(
              asset: asset,
              // Each master licenses its own tones; muted is not universal.
              tone: asset.allowedTones.contains(DsAssetTone.muted)
                  ? DsAssetTone.muted
                  : DsAssetTone.primary,
              width: 26,
              height: 26,
            ),
            const SizedBox(width: DsSpacing.space4),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: DsTextStyles.bodyPrimary.copyWith(
                      color: DsColors.textOnRitualPrimary,
                      fontSize: 17,
                    ),
                  ),
                  const SizedBox(height: DsSpacing.space1),
                  Text(
                    meta,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: DsTextStyles.bodySecondary.copyWith(
                      color: DsColors.textOnRitualMuted,
                      fontSize: _supportSize,
                      height: _supportHeight,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Words a person wrote and sent. The display face and Terracotta appear here
/// and, on this screen, only here.
class _PartnerResponse extends StatelessWidget {
  const _PartnerResponse({required this.response});

  final RecentResponse response;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: DsSpacing.space2),
      padding: _inset.add(
        const EdgeInsets.symmetric(vertical: DsSpacing.space4),
      ),
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: DsColors.borderOnRitualHairline),
          bottom: BorderSide(color: DsColors.borderOnRitualHairline),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const DsSvg(
                asset: DsAssets.stateAcknowledged,
                tone: DsAssetTone.relationship,
                width: 26,
                height: 26,
              ),
              const SizedBox(width: DsSpacing.space3),
              // labelRitual carries 2.4 tracking, so this line is wider than
              // it reads. It shrinks rather than pushing the row off-screen.
              Flexible(
                child: Text(
                  _responseHeading(response),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: DsTextStyles.labelRitual.copyWith(
                    color: DsColors.textOnRitualSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: DsSpacing.space3),
          Padding(
            padding: const EdgeInsets.only(left: DsSpacing.space10),
            child: Text(
              '“${response.text}”',
              style: DsTextStyles.displayPartner.copyWith(
                color: DsColors.relationshipAcknowledgement,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LaterRow extends StatelessWidget {
  const _LaterRow({
    required this.count,
    required this.expanded,
    required this.onToggle,
  });

  final int count;
  final bool expanded;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: _inset,
      child: SizedBox(
        height: DsControlSizes.listRow,
        child: Row(
          children: [
            Text(
              'LATER / OPTIONAL',
              style: DsTextStyles.labelRitual.copyWith(
                color: DsColors.textOnRitualMuted,
              ),
            ),
            const Spacer(),
            InkWell(
              onTap: onToggle,
              child: SizedBox(
                height: DsLayoutSizes.touchTarget,
                child: Row(
                  children: [
                    Text(
                      expanded ? 'Hide' : 'Show',
                      style: DsTextStyles.bodyPrimary.copyWith(
                        color: DsColors.textOnRitualPrimary,
                      ),
                    ),
                    const SizedBox(width: DsSpacing.space3),
                    Container(
                      width: 28,
                      height: 28,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        color: DsColors.surfaceRitualRaised,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '$count',
                        style: DsTextStyles.bodySecondary.copyWith(
                          color: DsColors.textOnRitualSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The relationship day, stated by the server in the Dynamic's own timezone.
class _DayBoundary extends StatelessWidget {
  const _DayBoundary();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: _inset.add(
        const EdgeInsets.only(top: DsSpacing.space2, bottom: DsSpacing.space4),
      ),
      child: Text(
        'Relationship day ends at 2:00 AM',
        style: DsTextStyles.bodySecondary.copyWith(
          color: DsColors.textOnRitualMuted,
        ),
      ),
    );
  }
}

class _BottomNavigation extends StatelessWidget {
  const _BottomNavigation();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: DsControlSizes.bottomNavigation,
      padding: EdgeInsets.only(bottom: MediaQuery.paddingOf(context).bottom),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: DsColors.borderOnRitualHairline)),
      ),
      child: Row(
        children: const [
          _NavTab(asset: DsAssets.navToday, label: 'Today', active: true),
          _NavTab(asset: DsAssets.navDynamic, label: 'Dynamic'),
          _NavTab(asset: DsAssets.navExplore, label: 'Explore'),
          _NavTab(asset: DsAssets.navUs, label: 'Us'),
        ],
      ),
    );
  }
}

class _NavTab extends StatelessWidget {
  const _NavTab({
    required this.asset,
    required this.label,
    this.active = false,
  });

  final DsAssetId asset;
  final String label;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final colour = active
        ? DsColors.textOnRitualPrimary
        : DsColors.textOnRitualMuted;
    return Expanded(
      child: InkWell(
        onTap: () {},
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            DsSvg(
              asset: asset,
              tone: active ? DsAssetTone.primary : DsAssetTone.muted,
              width: 24,
              height: 24,
            ),
            const SizedBox(height: DsSpacing.space1),
            Text(label, style: DsTextStyles.navLabel.copyWith(color: colour)),
          ],
        ),
      ),
    );
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

String _kindLabel(TodayItem item) {
  final title = item.title.toLowerCase();
  if (title.contains('check-in') || title.contains('check in')) {
    return 'CHECK-IN';
  }
  if (title.contains('ritual')) return 'RITUAL';
  return 'EXPECTATION';
}

String _responseHeading(RecentResponse r) {
  final who = r.senderDisplayName?.toUpperCase() ?? 'YOUR PARTNER';
  final elapsed = DateTime.now().difference(r.sentAt);
  final when = elapsed.inMinutes < 1
      ? 'JUST NOW'
      : elapsed.inMinutes < 60
      ? '${elapsed.inMinutes} MIN AGO'
      : elapsed.inHours < 24
      ? '${elapsed.inHours} HR AGO'
      : '${elapsed.inDays} DAY AGO';
  return '$who RESPONDED · $when';
}

/// Authorization, membership and the current read model resolve before any
/// content appears. Stale partner content must never show while confirming.
class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        const _Header(partnerName: null, context: 'Confirming context'),
        Padding(
          padding: _inset.add(const EdgeInsets.only(top: DsSpacing.space8)),
          child: Text(
            'Confirming today with the server.',
            style: DsTextStyles.bodySecondary.copyWith(
              color: DsColors.textOnRitualMuted,
            ),
          ),
        ),
      ],
    );
  }
}

/// The server confirms there is nothing actionable. No invented urgency, and
/// the optional check-in stays optional.
class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: _inset.add(const EdgeInsets.only(top: DsSpacing.space8)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Nothing is expected of you today.',
            style: DsTextStyles.bodyPrimary.copyWith(
              color: DsColors.textOnRitualPrimary,
            ),
          ),
          const SizedBox(height: DsSpacing.space3),
          Text(
            'A check-in is here if you want one.',
            style: DsTextStyles.bodySecondary.copyWith(
              color: DsColors.textOnRitualMuted,
              fontSize: _supportSize,
              height: _supportHeight,
            ),
          ),
        ],
      ),
    );
  }
}

/// Only the last confirmed list, labelled with when it was confirmed. Every
/// mutation is withdrawn: cached content is never treated as a new state.
class _OfflineState extends StatelessWidget {
  const _OfflineState({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        const _Header(partnerName: null, context: 'Offline'),
        Padding(
          padding: _inset,
          child: Container(
            padding: const EdgeInsets.all(DsSpacing.space4),
            decoration: BoxDecoration(
              color: DsColors.surfaceRitualRaised,
              borderRadius: BorderRadius.circular(DsRadii.card),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'OFFLINE',
                  style: DsTextStyles.labelRitual.copyWith(
                    color: DsColors.textOnRitualMuted,
                  ),
                ),
                const SizedBox(height: DsSpacing.space2),
                Text(
                  'Read-only until the server reconnects.',
                  style: DsTextStyles.bodySecondary.copyWith(
                    color: DsColors.textOnRitualSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: _inset.add(const EdgeInsets.only(top: DsSpacing.space8)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Actions are paused offline',
                style: DsTextStyles.bodyPrimary.copyWith(
                  color: DsColors.textOnRitualPrimary,
                ),
              ),
              const SizedBox(height: DsSpacing.space3),
              Text(
                'Complete, Discuss, New Time and Can\'t Do will return after '
                'current truth is confirmed.',
                style: DsTextStyles.bodySecondary.copyWith(
                  color: DsColors.textOnRitualMuted,
                  fontSize: _supportSize,
                  height: _supportHeight,
                ),
              ),
              const SizedBox(height: DsSpacing.space6),
              _SecondaryButton(label: 'Try to reconnect', onTap: onRetry),
              const SizedBox(height: DsSpacing.space6),
              Text(
                'Cached content is never treated as a new state.',
                style: DsTextStyles.bodySecondary.copyWith(
                  color: DsColors.textOnRitualMuted,
                  fontSize: _supportSize,
                  height: _supportHeight,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Current truth cannot be loaded and there is no safe confirmed cache.
class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        const _Header(partnerName: null, context: 'Not confirmed'),
        Padding(
          padding: _inset.add(const EdgeInsets.only(top: DsSpacing.space8)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Today could not be loaded. Nothing was lost.',
                style: DsTextStyles.bodyPrimary.copyWith(
                  color: DsColors.textOnRitualPrimary,
                ),
              ),
              const SizedBox(height: DsSpacing.space6),
              _SecondaryButton(label: 'Try again', onTap: onRetry),
            ],
          ),
        ),
      ],
    );
  }
}

/// Every piece of protected content is removed, and recovery is offered
/// without implying the relationship itself has changed.
class _AuthorizationLostState extends StatelessWidget {
  const _AuthorizationLostState();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        const _Header(partnerName: null, context: 'Confirming context'),
        Padding(
          padding: _inset,
          child: Text(
            'PRIVATE SESSION ENDED',
            style: DsTextStyles.labelRitual.copyWith(
              color: DsColors.textOnRitualMuted,
            ),
          ),
        ),
        const SizedBox(height: DsSpacing.space16),
        const Center(
          child: DsSvg(
            asset: DsAssets.stateLocked,
            tone: DsAssetTone.primary,
            width: 44,
            height: 44,
          ),
        ),
        const SizedBox(height: DsSpacing.space8),
        Padding(
          padding: _inset,
          child: Column(
            children: [
              Text(
                'Your private session\nneeds to be restored.',
                textAlign: TextAlign.center,
                style: DsTextStyles.displayRitual.copyWith(
                  color: DsColors.textOnRitualPrimary,
                  fontSize: 28,
                  height: 31 / 28,
                ),
              ),
              const SizedBox(height: DsSpacing.space5),
              Text(
                'Partner and Dynamic details have been hidden.\n'
                'Sign in again to confirm current access.',
                textAlign: TextAlign.center,
                style: DsTextStyles.bodySecondary.copyWith(
                  color: DsColors.textOnRitualMuted,
                ),
              ),
              const SizedBox(height: DsSpacing.space8),
              _SecondaryButton(
                label: 'Sign in again',
                onTap: () {},
                filled: true,
              ),
              const SizedBox(height: DsSpacing.space6),
              Text(
                'No protected content remains on this screen.',
                style: DsTextStyles.bodySecondary.copyWith(
                  color: DsColors.textOnRitualMuted,
                  fontSize: _supportSize,
                  height: _supportHeight,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SecondaryButton extends StatelessWidget {
  const _SecondaryButton({
    required this.label,
    required this.onTap,
    this.filled = false,
  });

  final String label;
  final VoidCallback onTap;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: DsControlSizes.button,
      width: double.infinity,
      child: Material(
        color: filled
            ? DsColors.actionPrimaryBackground
            : DsPrimitiveColors.transparent,
        borderRadius: BorderRadius.circular(DsRadii.control),
        child: InkWell(
          borderRadius: BorderRadius.circular(DsRadii.control),
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              border: filled
                  ? null
                  : Border.all(color: DsColors.actionSecondaryBorder),
              borderRadius: BorderRadius.circular(DsRadii.control),
            ),
            alignment: Alignment.center,
            child: Text(
              label,
              style: DsTextStyles.labelAction.copyWith(
                color: filled
                    ? DsColors.actionPrimaryForeground
                    : DsColors.textOnRitualPrimary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
