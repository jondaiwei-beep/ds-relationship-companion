import 'package:dio/dio.dart';
import 'package:ds_relationship_companion/ds_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../app/shell/bottom_navigation.dart';
import '../../../l10n/app_localizations.dart';
import '../../../app/shell/ds_glyph.dart';
import '../../../app/shell/ds_refreshable.dart';
import '../../../app/shell/ds_skeleton.dart';
import '../../../domain_client/models/today_view.dart';
import '../application/today_actions.dart';

import 'widgets/compact_row.dart';
import 'widgets/day_boundary.dart';
import 'widgets/later_row.dart';
import 'widgets/partner_response.dart';
import 'widgets/primary_expectation.dart';
import 'widgets/recovery_scaffold.dart';
import 'widgets/secondary_button.dart';
import 'widgets/section_label.dart';
import 'widgets/today_header.dart';
import 'widgets/today_layout.dart';

/// Kept alive across tab switches: `autoDispose` meant leaving this surface
/// destroyed its data, so coming back always refetched. Four tabs each
/// reloading on every visit made the app feel like it kept forgetting where
/// you were, for no reason but navigation.
///
/// Fetching is now something a person asks for — pull to refresh — or
/// something a command causes, because the server decides what changed.
final todayProvider = FutureProvider.family<TodayView, String>((
  ref,
  dynamicId,
) async {
  return ref.watch(todayRepositoryProvider).forDynamic(dynamicId);
});

/// SCR-01 Today — revision 2.
///
/// Behaviour is governed by
/// `design/screens/SCR-01-today/candidates/rev-2/today-b3-spec.json`, which is
/// authoritative over the raster preview. The server composes the order; this
/// screen renders it and never re-sorts, re-ranks, or derives the relationship
/// day from the device clock.
class TodayScreen extends ConsumerWidget {
  const TodayScreen({
    super.key,
    required this.dynamicId,
    this.onSignIn,
    this.onSelectTab,
    this.onOpenOccurrence,
    this.onOpenPoints,
    this.onCheckIn,
  });

  final String dynamicId;

  /// Supplied once SCR-05 Sign In exists. Until then the recovery action is
  /// visibly inert rather than routed somewhere wrong.
  final VoidCallback? onSignIn;

  /// Supplied once the other three surfaces exist.
  final void Function(NavSurface surface)? onSelectTab;

  /// Opens SCR-14 for one item.
  final void Function(String occurrenceId)? onOpenOccurrence;

  /// Opens points, rewards and agreements.
  final VoidCallback? onOpenPoints;

  /// Opens SCR-22. Journey B puts the check-in last, after what is expected:
  /// saying how you are is offered, never required first.
  final VoidCallback? onCheckIn;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final today = ref.watch(todayProvider(dynamicId));
    void reload() => ref.invalidate(todayProvider(dynamicId));

    // Pull to ask again. Wrapping `when` rather than only the loaded state so
    // a failed load can be retried by the same gesture — otherwise the one
    // case where a person most wants to retry is the one without the gesture.
    Future<void> refresh() => ref.refresh(todayProvider(dynamicId).future);

    return Scaffold(
      backgroundColor: DsColors.canvasRitual,
      body: DsRitualSurface(
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              Expanded(
                child: DsRefreshable(
                  onRefresh: refresh,
                  child: today.when(
                    // An AsyncValue can be loading *and* carry the error from a
                    // previous attempt. Without this the screen shows a spinner
                    // forever after a failed refresh instead of saying what went
                    // wrong.
                    skipLoadingOnReload: true,
                    skipLoadingOnRefresh: true,
                    loading: () => const _Loading(),
                    error: (error, _) => switch (_classify(error)) {
                      _Failure.authorizationLost => _AuthorizationLost(
                        onSignIn: onSignIn,
                      ),
                      _Failure.offline => _Offline(onRetry: reload),
                      _Failure.unknown => _Unavailable(onRetry: reload),
                    },
                    data: (view) => _Loaded(
                      view: view,
                      dynamicId: dynamicId,
                      onOpenOccurrence: onOpenOccurrence,
                      onCheckIn: onCheckIn,
                      onOpenPoints: onOpenPoints,
                    ),
                  ),
                ),
              ),
              DsBottomNavigation(
                current: NavSurface.today,
                onSelect: onSelectTab,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// How a failed load must be presented. The design gives each its own state
/// because they are different facts about the person's access.
enum _Failure { offline, authorizationLost, unknown }

_Failure _classify(Object error) {
  if (error is! DioException) return _Failure.unknown;
  final status = error.response?.statusCode;
  if (status == 401 || status == 403) return _Failure.authorizationLost;
  return switch (error.type) {
    DioExceptionType.connectionError ||
    DioExceptionType.connectionTimeout ||
    DioExceptionType.receiveTimeout ||
    DioExceptionType.sendTimeout => _Failure.offline,
    _ => _Failure.unknown,
  };
}

/// The server-confirmed list.
class _Loaded extends ConsumerStatefulWidget {
  const _Loaded({
    required this.view,
    required this.dynamicId,
    this.onOpenOccurrence,
    this.onCheckIn,
    this.onOpenPoints,
  });

  final TodayView view;
  final String dynamicId;
  final void Function(String occurrenceId)? onOpenOccurrence;
  final VoidCallback? onCheckIn;

  /// Opens points, rewards and agreements.
  final VoidCallback? onOpenPoints;

  @override
  ConsumerState<_Loaded> createState() => _LoadedState();
}

class _LoadedState extends ConsumerState<_Loaded> {
  /// Disclosure and in-flight attempts are the only state this screen owns.
  /// Everything else is server truth.
  bool _laterExpanded = false;
  String? _busyOccurrenceId;

  /// Runs one command and reports the outcome. Success needs no message: the
  /// list re-reads from the server and the change is the confirmation.
  Future<void> _run(String occurrenceId, TodayAction action) async {
    setState(() => _busyOccurrenceId = occurrenceId);
    final outcome = await ref
        .read(todayActionsProvider)
        .run(
          dynamicId: widget.dynamicId,
          occurrenceId: occurrenceId,
          action: action,
        );
    if (!mounted) return;
    setState(() => _busyOccurrenceId = null);

    if (outcome case ActionFailed(:final message)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message, style: DsTextStyles.bodySecondary),
          backgroundColor: DsColors.surfaceRitualRaised,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    final view = widget.view;
    final priority = view.priorityItems;
    final later = view.laterItems;
    final response = view.recentResponse;

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        TodayHeader(title: l.todayTitle, partnerName: _partnerName(view)),
        if (priority.isEmpty && later.isEmpty)
          const _NothingExpected()
        else ...[
          SectionLabel(
            priority.isEmpty
                ? l.todayPriorityHeadingNone
                : l.todayPriorityHeading(priority.length),
          ),
          for (final (index, item) in priority.indexed)
            if (index == 0)
              PrimaryExpectation(
                zone: view.referenceTimezone,
                item: item,
                busy: _busyOccurrenceId == item.occurrenceId,
                onAction: (action) => _run(item.occurrenceId, action),
                onOpen: widget.onOpenOccurrence == null
                    ? null
                    : () => widget.onOpenOccurrence!(item.occurrenceId),
              )
            else
              CompactRow(
                zone: view.referenceTimezone,
                index: index + 1,
                item: item,
                lastInGroup: index == priority.length - 1,
              ),
        ],
        if (response != null) PartnerResponse(response: response),

        // Points, on the surface a person opens every day.
        //
        // This lived only behind Settings, under notification preferences and
        // quiet hours — a place nobody looks for something they use daily,
        // and the owner reported the whole feature as missing from a build
        // that in fact contained it. All three competitors give this a
        // bottom-tab; a row on Today is the smallest honest equivalent that
        // does not add a fifth tab to a four-tab shell.
        if (widget.onOpenPoints != null)
          _PointsRow(dynamicId: widget.dynamicId, onTap: widget.onOpenPoints!),
        if (later.isNotEmpty)
          LaterRow(
            count: later.length,
            expanded: _laterExpanded,
            onToggle: () => setState(() => _laterExpanded = !_laterExpanded),
          ),
        if (_laterExpanded)
          for (final (index, item) in later.indexed)
            CompactRow(
              zone: view.referenceTimezone,
              index: priority.length + index + 1,
              item: item,
              lastInGroup: index == later.length - 1,
            ),
        // Journey B puts the check-in last: it is offered after what is
        // expected, never asked for before it. Present even when the day is
        // empty — "nothing is expected" is a day worth saying something about.
        if (widget.onCheckIn != null) ...[
          const SizedBox(height: DsSpacing.space8),
          Padding(
            padding: todayInset,
            child: SecondaryButton(
              label: l.todayCheckIn,
              onTap: widget.onCheckIn!,
            ),
          ),
        ],
        // Omitted rather than guessed when the server did not state it.
        if (view.dayBoundaryMinutes case final minutes?)
          DayBoundary(boundaryMinutes: minutes),
      ],
    );
  }

  /// Direction comes from a person. When the server names them, say so.
  String? _partnerName(TodayView view) {
    for (final item in [...view.priorityItems, ...view.laterItems]) {
      if (item.fromDisplayName != null) return item.fromDisplayName;
    }
    return view.recentResponse?.senderDisplayName;
  }
}

/// Nothing actionable for the relationship day. No invented urgency, and the
/// optional check-in stays optional.
/// The way in to points, rewards and what the couple agreed.
///
/// Deliberately does NOT read the balance. Today is the surface that must
/// always render, and making it depend on a second network call means a
/// points outage — or an unrelated provider failure — takes the day's
/// expectations down with it. The number is one tap away on the page this
/// opens, which is where it belongs anyway: a balance on Today would be a
/// score sitting above someone's expectations.
class _PointsRow extends StatelessWidget {
  const _PointsRow({required this.dynamicId, required this.onTap});

  final String dynamicId;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) =>
      _PointsLabel(label: L.of(context).settingsPointsOpen, onTap: onTap);
}

/// The row's plain form, used before the balance is known and when it cannot
/// be read at all.
class _PointsLabel extends StatelessWidget {
  const _PointsLabel({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    child: Padding(
      padding: todayInset.add(
        const EdgeInsets.symmetric(vertical: DsSpacing.space4),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: DsTextStyles.bodyPrimary.copyWith(
                color: DsColors.textOnRitualPrimary,
              ),
            ),
          ),
          const DsGlyphIcon(DsGlyph.forward, size: 18),
        ],
      ),
    ),
  );
}

class _NothingExpected extends StatelessWidget {
  const _NothingExpected();

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    return Padding(
      padding: todayInset.add(const EdgeInsets.only(top: DsSpacing.space8)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l.todayNothingExpected,
            style: DsTextStyles.bodyPrimary.copyWith(
              color: DsColors.textOnRitualPrimary,
            ),
          ),
          const SizedBox(height: DsSpacing.space3),
          Text(
            l.todayCheckInOffer,
            style: DsTextStyles.bodySecondary.copyWith(
              color: DsColors.textOnRitualMuted,
              fontSize: todaySupportSize,
              height: todaySupportHeight,
            ),
          ),
        ],
      ),
    );
  }
}

/// Authorization, membership and the read model resolve before any content
/// appears. Stale partner content must never show while confirming.
///
/// The shape of the day, not a sentence about waiting. The approved rev-2
/// loading state draws one prominent card and two compact rows in the
/// proportions of the real list, so the page does not rearrange itself when
/// the content lands — and says plainly why it is blank, which "loading…"
/// never does.
class _Loading extends StatelessWidget {
  const _Loading();

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    return RecoveryScaffold(
      context_: l.recoveryConfirmingContext,
      children: [
        SectionLabel(l.todayResolving),
        Padding(
          padding: todayInset,
          child: Text(
            l.todayConfirmingPrivate,
            style: DsTextStyles.bodyPrimary.copyWith(
              color: DsColors.textOnRitualPrimary,
            ),
          ),
        ),
        const SizedBox(height: DsSpacing.space6),
        const DsSkeletonPulse(
          child: Column(
            children: [
              Padding(
                padding: todayInset,
                child: DsSkeletonCard(
                  lines: [0.35, 0.92, 0.7, 0.28],
                  emphasis: true,
                ),
              ),
              SizedBox(height: DsSpacing.space3),
              Padding(
                padding: todayInset,
                child: DsSkeletonCard(lines: [0.6, 0.38]),
              ),
              SizedBox(height: DsSpacing.space3),
              Padding(
                padding: todayInset,
                child: DsSkeletonCard(lines: [0.55, 0.34]),
              ),
            ],
          ),
        ),
        const SizedBox(height: DsSpacing.space8),
        SectionLabel(l.todayPrivateByDefault),
        RecoveryMessage(l.todayPrivateByDefaultBody),
      ],
    );
  }
}

/// Only the last confirmed list, labelled with when it was confirmed. Every
/// mutation is withdrawn: cached content is never treated as a new state.
class _Offline extends StatelessWidget {
  const _Offline({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    return RecoveryScaffold(
      context_: l.recoveryOffline,
      children: [
        Padding(
          padding: todayInset,
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
                  l.todayOffline,
                  style: DsTextStyles.labelRitual.copyWith(
                    color: DsColors.textOnRitualMuted,
                  ),
                ),
                const SizedBox(height: DsSpacing.space2),
                Text(
                  l.todayOfflineReadOnly,
                  style: DsTextStyles.bodySecondary.copyWith(
                    color: DsColors.textOnRitualSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: DsSpacing.space8),
        RecoveryMessage(l.todayActionsPaused, prominent: true),
        const SizedBox(height: DsSpacing.space3),
        RecoveryMessage(l.todayActionsReturn),
        const SizedBox(height: DsSpacing.space6),
        Padding(
          padding: todayInset,
          child: SecondaryButton(
            label: l.recoveryTryToReconnect,
            onTap: onRetry,
          ),
        ),
        const SizedBox(height: DsSpacing.space6),
        RecoveryMessage(l.todayCachedNeverNew),
      ],
    );
  }
}

/// Current truth cannot be loaded and there is no safe confirmed cache.
class _Unavailable extends StatelessWidget {
  const _Unavailable({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    return RecoveryScaffold(
      context_: l.recoveryNotConfirmed,
      children: [
        const SizedBox(height: DsSpacing.space8),
        RecoveryMessage(l.todayCouldNotLoad, prominent: true),
        const SizedBox(height: DsSpacing.space6),
        Padding(
          padding: todayInset,
          child: SecondaryButton(label: l.recoveryTryAgain, onTap: onRetry),
        ),
      ],
    );
  }
}

/// Every piece of protected content is removed, and recovery is offered
/// without implying the relationship itself has changed.
class _AuthorizationLost extends StatelessWidget {
  const _AuthorizationLost({this.onSignIn});

  /// Supplied once SCR-05 exists.
  final VoidCallback? onSignIn;

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    return RecoveryScaffold(
      context_: l.recoveryConfirmingContext,
      children: [
        Padding(
          padding: todayInset,
          child: Text(
            l.recoverySessionEnded,
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
          padding: todayInset,
          child: Column(
            children: [
              Text(
                l.recoverySessionRestore,
                textAlign: TextAlign.center,
                style: DsTextStyles.displayRitual.copyWith(
                  color: DsColors.textOnRitualPrimary,
                  fontSize: 28,
                  height: 31 / 28,
                ),
              ),
              const SizedBox(height: DsSpacing.space5),
              Text(
                l.todayHiddenDetails,
                textAlign: TextAlign.center,
                style: DsTextStyles.bodySecondary.copyWith(
                  color: DsColors.textOnRitualMuted,
                ),
              ),
              const SizedBox(height: DsSpacing.space8),
              SecondaryButton(
                label: l.recoverySignInAgain,
                // Routes to SCR-05 Sign In, whose gate is still closed. Left
                // deliberately inert rather than wired to a placeholder: a
                // button that goes somewhere wrong is worse than one that
                // visibly does nothing yet.
                onTap: onSignIn ?? () {},
                filled: true,
              ),
            ],
          ),
        ),
        const SizedBox(height: DsSpacing.space6),
        RecoveryMessage(l.recoveryNoProtectedContent),
      ],
    );
  }
}
