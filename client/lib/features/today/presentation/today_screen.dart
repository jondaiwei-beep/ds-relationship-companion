import 'package:dio/dio.dart';
import 'package:ds_relationship_companion/ds_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../app/shell/bottom_navigation.dart';
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

final todayProvider = FutureProvider.autoDispose.family<TodayView, String>((
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
  });

  final String dynamicId;

  /// Supplied once SCR-05 Sign In exists. Until then the recovery action is
  /// visibly inert rather than routed somewhere wrong.
  final VoidCallback? onSignIn;

  /// Supplied once the other three surfaces exist.
  final void Function(NavSurface surface)? onSelectTab;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final today = ref.watch(todayProvider(dynamicId));
    void reload() => ref.invalidate(todayProvider(dynamicId));

    return Scaffold(
      backgroundColor: DsColors.canvasRitual,
      body: DsRitualSurface(
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              Expanded(
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
                  data: (view) => _Loaded(view: view, dynamicId: dynamicId),
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
  const _Loaded({required this.view, required this.dynamicId});

  final TodayView view;
  final String dynamicId;

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
    final view = widget.view;
    final priority = view.priorityItems;
    final later = view.laterItems;
    final response = view.recentResponse;

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        TodayHeader(partnerName: _partnerName(view)),
        if (priority.isEmpty && later.isEmpty)
          const _NothingExpected()
        else ...[
          SectionLabel(_priorityHeading(priority.length)),
          for (final (index, item) in priority.indexed)
            if (index == 0)
              PrimaryExpectation(
                item: item,
                busy: _busyOccurrenceId == item.occurrenceId,
                onAction: (action) => _run(item.occurrenceId, action),
              )
            else
              CompactRow(
                index: index + 1,
                item: item,
                lastInGroup: index == priority.length - 1,
              ),
        ],
        if (response != null) PartnerResponse(response: response),
        if (later.isNotEmpty)
          LaterRow(
            count: later.length,
            expanded: _laterExpanded,
            onToggle: () => setState(() => _laterExpanded = !_laterExpanded),
          ),
        if (_laterExpanded)
          for (final (index, item) in later.indexed)
            CompactRow(
              index: priority.length + index + 1,
              item: item,
              lastInGroup: index == later.length - 1,
            ),
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

  static String _priorityHeading(int count) {
    const words = ['NO', 'ONE', 'TWO', 'THREE'];
    final word = count < words.length ? words[count] : '$count';
    return count == 1 ? '$word THING MATTERS' : '$word THINGS MATTER';
  }
}

/// Nothing actionable for the relationship day. No invented urgency, and the
/// optional check-in stays optional.
class _NothingExpected extends StatelessWidget {
  const _NothingExpected();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: todayInset.add(const EdgeInsets.only(top: DsSpacing.space8)),
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
class _Loading extends StatelessWidget {
  const _Loading();

  @override
  Widget build(BuildContext context) {
    return const RecoveryScaffold(
      context_: 'Confirming context',
      children: [
        SizedBox(height: DsSpacing.space8),
        RecoveryMessage('Confirming today with the server.'),
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
    return RecoveryScaffold(
      context_: 'Offline',
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
        const SizedBox(height: DsSpacing.space8),
        const RecoveryMessage('Actions are paused offline', prominent: true),
        const SizedBox(height: DsSpacing.space3),
        const RecoveryMessage(
          "Complete, Discuss, New Time and Can't Do will return after current "
          'truth is confirmed.',
        ),
        const SizedBox(height: DsSpacing.space6),
        Padding(
          padding: todayInset,
          child: SecondaryButton(label: 'Try to reconnect', onTap: onRetry),
        ),
        const SizedBox(height: DsSpacing.space6),
        const RecoveryMessage(
          'Cached content is never treated as a new state.',
        ),
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
    return RecoveryScaffold(
      context_: 'Not confirmed',
      children: [
        const SizedBox(height: DsSpacing.space8),
        const RecoveryMessage(
          'Today could not be loaded. Nothing was lost.',
          prominent: true,
        ),
        const SizedBox(height: DsSpacing.space6),
        Padding(
          padding: todayInset,
          child: SecondaryButton(label: 'Try again', onTap: onRetry),
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
    return RecoveryScaffold(
      context_: 'Confirming context',
      children: [
        Padding(
          padding: todayInset,
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
          padding: todayInset,
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
              SecondaryButton(
                label: 'Sign in again',
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
        const RecoveryMessage('No protected content remains on this screen.'),
      ],
    );
  }
}
