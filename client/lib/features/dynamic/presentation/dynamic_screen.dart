import 'package:dio/dio.dart';
import 'package:ds_relationship_companion/ds_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../app/shell/bottom_navigation.dart';
import '../../../l10n/app_localizations.dart';
import '../../../app/shell/ds_skeleton.dart';
import '../../../platform/session/session.dart';
import '../../../platform/session/session_controller.dart';
import '../../../domain_client/models/dynamic_view.dart';
import '../../today/presentation/widgets/recovery_scaffold.dart';
import '../../today/presentation/widgets/secondary_button.dart';
import '../../today/presentation/widgets/today_header.dart';
import '../../today/presentation/widgets/today_layout.dart';

import 'widgets/member_pair.dart';
import 'widgets/orbit_figure.dart';
import 'widgets/structure_row.dart';

final dynamicDetailProvider = FutureProvider.autoDispose
    .family<DynamicDetail, String>(
      (ref, dynamicId) =>
          ref.watch(dynamicRepositoryProvider).detail(dynamicId),
    );

/// Who the viewer is, from the `sub` in their own session token.
///
/// Not from the members list's order: it comes back CREATOR-first whatever
/// the caller's role, so position says nothing about who is asking. Shared by
/// every screen that has to tell "you" from "them", because getting it wrong
/// once already showed a person their own name as their partner's.
final dynamicViewerIdProvider = Provider<String?>((ref) {
  final session = ref.watch(sessionProvider);
  return session is Authenticated ? session.userId : null;
});

/// SCR-13 Dynamic Overview.
///
/// Shows the current shape of the relationship and the adjustments that must
/// always be reachable. Three decisions worth stating, because the screen
/// package left their product rules open and the preview alone does not
/// authorize an answer:
///
/// - **Agreement is absent.** The preview carries an "OPEN AGREEMENT" row in
///   Terracotta, but the package's own alignment work says to remove Agreement
///   from Core Beta, and its acceptance criterion says this is not a
///   governance dashboard. Building the most eye-catching row on the screen
///   for a concept the tier does not have would have been the easiest thing
///   here to get wrong.
///
/// - **No "next shared check-in".** The preview shows one. The server has no
///   scheduled check-in to report — `/check-ins` returns written entries, not
///   appointments — and the acceptance criterion is that displayed state
///   matches server truth. A plausible date rendered from nothing is the one
///   failure this screen cannot recover from, so the row is not built.
///
/// - **Pause is offered to both members.** Notion 04 §4 makes it inviolable
///   agency, and `alwaysAvailable` carries it whatever the viewer's role.
class DynamicScreen extends ConsumerWidget {
  const DynamicScreen({
    super.key,
    required this.dynamicId,
    this.onSignIn,
    this.onSelectTab,
    this.onAsk,
    this.onPause,
    this.onWeekly,
  });

  final String dynamicId;
  final VoidCallback? onSignIn;
  final void Function(NavSurface surface)? onSelectTab;

  /// Opens SCR-20. Null while there is no route to it.
  final VoidCallback? onAsk;

  /// Opens SCR-24. Pausing goes through a screen that says what it does
  /// rather than happening on one tap.
  final VoidCallback? onPause;

  /// Opens SCR-23.
  final VoidCallback? onWeekly;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detail = ref.watch(dynamicDetailProvider(dynamicId));
    void reload() => ref.invalidate(dynamicDetailProvider(dynamicId));

    return Scaffold(
      backgroundColor: DsColors.canvasRitual,
      body: DsRitualSurface(
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              Expanded(
                child: detail.when(
                  // An AsyncValue can be loading *and* carry the previous
                  // error. Without this a failed refresh spins forever instead
                  // of saying what went wrong.
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
                    onAsk: onAsk,
                    onPause: onPause,
                    onWeekly: onWeekly,
                  ),
                ),
              ),
              DsBottomNavigation(
                current: NavSurface.dynamic_,
                onSelect: onSelectTab ?? (_) {},
              ),
            ],
          ),
        ),
      ),
    );
  }
}

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

class _Loaded extends ConsumerStatefulWidget {
  const _Loaded({
    required this.view,
    required this.dynamicId,
    this.onAsk,
    this.onPause,
    this.onWeekly,
  });

  final DynamicDetail view;
  final String dynamicId;
  final VoidCallback? onAsk;
  final VoidCallback? onPause;
  final VoidCallback? onWeekly;

  @override
  ConsumerState<_Loaded> createState() => _LoadedState();
}

class _LoadedState extends ConsumerState<_Loaded> {
  DynamicDetail get view => widget.view;

  bool get _paused => view.pausedAt != null || view.state == 'PAUSED';

  String? get _viewerId => ref.watch(dynamicViewerIdProvider);

  MemberView? get _me {
    final id = _viewerId;
    if (id == null) return null;
    for (final m in view.members) {
      if (m.userId == id) return m;
    }
    return null;
  }

  /// The member who is not the viewer. Null in a Solo Dynamic and while the
  /// partner has not joined — in both cases there is no presence to claim.
  ///
  /// Also null when the viewer cannot be identified: naming an arbitrary
  /// member "your partner" is worse than naming nobody.
  MemberView? get _partner {
    final id = _viewerId;
    if (id == null) return null;
    for (final m in view.members) {
      if (m.userId != id) return m;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    final partner = _partner;
    final rituals = view.structure.where((s) => s.active).toList();

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        TodayHeader(title: l.dynamicTitle, partnerName: partner?.displayName),

        MemberPair(me: _me, partner: _partner),

        // The orbit is the screen's one piece of visual weight. It carries no
        // information the rows do not also state, so it is decorative and
        // excluded from semantics rather than described to a screen reader.
        //
        // Its height is a share of the viewport rather than a constant. At a
        // fixed 300 it pushed Pause below the fold on a 390x844 screen — and
        // an agency action that has to be scrolled for is not the inviolable
        // one Notion 04 §4 describes.
        OrbitFigure(
          height: (MediaQuery.sizeOf(context).height * 0.26).clamp(140.0, 260.0),
        ),

        if (_paused) ...[
          const SizedBox(height: DsSpacing.space6),
          const _PausedNotice(),
        ],

        const SizedBox(height: DsSpacing.space6),

        StructureRow(
          asset: DsAssets.markAuthority,
          label: l.dynamicCurrentStructure,
          value: _structureLine(l, view),
        ),

        if (rituals.isNotEmpty)
          StructureRow(
            asset: DsAssets.markCheckIn,
            label: rituals.length == 1
                ? l.dynamicCurrentRhythm
                : l.dynamicCurrentRhythms,
            value: rituals.map((r) => r.title).join(' · '),
          ),

        const SizedBox(height: DsSpacing.space8),

        // Only offered when there is someone to ask and the Dynamic is running.
        // Asking during a pause would be the one thing a pause is meant to
        // stop.
        if (widget.onAsk != null && _partner != null && !_paused) ...[
          Padding(
            padding: todayInset,
            child: SecondaryButton(
              label: l.dynamicAskOneThing,
              onTap: widget.onAsk!,
              filled: true,
            ),
          ),
          const SizedBox(height: DsSpacing.space6),
        ],

        // Looking back at the week. Offered, never required — and only when
        // the Dynamic is running, since a paused week is not one to reflect on.
        if (widget.onWeekly != null && !_paused) ...[
          Padding(
            padding: todayInset,
            child: SecondaryButton(
              label: l.dynamicThisWeek,
              onTap: widget.onWeekly!,
            ),
          ),
          const SizedBox(height: DsSpacing.space6),
        ],

        // Agency, last and unmissable. Never behind a menu: a person deciding
        // to pause should not have to look for it.
        //
        // It opens SCR-24 rather than acting here. Pausing on one tap gave no
        // room to say what pausing does, and returning had no way to ask how
        // much to come back to.
        Padding(
          padding: todayInset,
          child: SecondaryButton(
            label: _paused ? l.dynamicComeBack : l.dynamicPauseThis,
            onTap: widget.onPause ?? () {},
          ),
        ),
        const SizedBox(height: DsSpacing.space4),
        RecoveryMessage(
          _paused
              ? l.dynamicNothingWaitingAfterPause
              : l.dynamicEitherMayPause,
        ),
        const SizedBox(height: DsSpacing.space10),
      ],
    );
  }
}

/// "Service-led · mutually held" in the preview. Both halves come from the
/// server: the outcome the couple chose, and how much structure they asked
/// for. Neither is inferred.
String _structureLine(L l, DynamicDetail view) {
  // An unrecognised value falls through to the server's own word rather than
  // asserting one this build does not know about.
  final outcome = switch (view.desiredOutcome) {
    'CLOSER' => l.outcomeCloser,
    'STRUCTURE' => l.outcomeStructure,
    'SERVICE' => l.outcomeService,
    'ACCOUNTABILITY' => l.outcomeAccountability,
    'EXPLORE' => l.outcomeExplore,
    _ => view.desiredOutcome,
  };
  final level = switch (view.structureLevel) {
    'LIGHT' => l.levelLight,
    'STEADY' => l.levelSteady,
    'DEFINED' => l.levelDefined,
    _ => view.structureLevel,
  };
  return l.structureLine(level, outcome);
}

/// Paused is a state to be stated plainly, never a warning. Pausing is a
/// normal use of the product, not a failure of it.
class _PausedNotice extends StatelessWidget {
  const _PausedNotice();

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    return Padding(
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
              l.dynamicPaused,
              style: DsTextStyles.labelRitual.copyWith(
                color: DsColors.textOnRitualMuted,
              ),
            ),
            const SizedBox(height: DsSpacing.space2),
            Text(
              l.dynamicPausedNothingExpected,
              style: DsTextStyles.bodySecondary.copyWith(
                color: DsColors.textOnRitualSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The shape of the screen while it resolves: the two members, the figure,
/// and the structure rows beneath. No names and no role words — those are the
/// protected content, and a skeleton that outlined them would leak their
/// lengths.
class _Loading extends StatelessWidget {
  const _Loading();

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    return RecoveryScaffold(
      context_: l.recoveryConfirmingContext,
      title: l.dynamicTitle,
      children: [
        DsSkeletonPulse(
          child: Column(
            children: [
              Padding(
                padding: todayInset,
                child: Row(
                  children: const [
                    Expanded(child: DsSkeletonBar(widthFactor: 0.5)),
                    SizedBox(width: DsSpacing.space4),
                    Expanded(child: DsSkeletonBar(widthFactor: 0.6)),
                  ],
                ),
              ),
              const SizedBox(height: DsSpacing.space5),
              // Where the orbit will be, at the height it actually renders —
              // a share of the viewport, same as the figure itself, so the
              // rows below do not move when it arrives.
              Center(
                child: Container(
                  width: 150,
                  height:
                      (MediaQuery.sizeOf(context).height * 0.26)
                          .clamp(140.0, 260.0),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: DsColors.decorativeRitualLine),
                  ),
                ),
              ),
              const SizedBox(height: DsSpacing.space6),
              const Padding(
                padding: todayInset,
                child: DsSkeletonCard(lines: [0.3, 0.75]),
              ),
              const SizedBox(height: DsSpacing.space3),
              const Padding(
                padding: todayInset,
                child: DsSkeletonCard(lines: [0.28, 0.66]),
              ),
            ],
          ),
        ),
        const SizedBox(height: DsSpacing.space8),
        RecoveryMessage(
          l.dynamicConfirmingStructure,
        ),
      ],
    );
  }
}

/// The last confirmed structure is not shown from cache: unlike a list of
/// tasks, a stale pause state would be actively misleading about whether
/// anything is expected of you right now.
class _Offline extends StatelessWidget {
  const _Offline({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    return RecoveryScaffold(
      context_: l.recoveryOffline,
      title: l.dynamicTitle,
      children: [
        const SizedBox(height: DsSpacing.space8),
        RecoveryMessage(
          l.dynamicCouldNotConfirm,
          prominent: true,
        ),
        const SizedBox(height: DsSpacing.space3),
        RecoveryMessage(
          l.dynamicPauseUnavailable,
        ),
        const SizedBox(height: DsSpacing.space6),
        Padding(
          padding: todayInset,
          child: SecondaryButton(label: l.recoveryTryToReconnect, onTap: onRetry),
        ),
      ],
    );
  }
}

class _Unavailable extends StatelessWidget {
  const _Unavailable({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    return RecoveryScaffold(
      context_: l.recoveryNotConfirmed,
      title: l.dynamicTitle,
      children: [
        const SizedBox(height: DsSpacing.space8),
        RecoveryMessage(
          l.dynamicCouldNotLoad,
          prominent: true,
        ),
        const SizedBox(height: DsSpacing.space6),
        Padding(
          padding: todayInset,
          child: SecondaryButton(label: l.recoveryTryAgain, onTap: onRetry),
        ),
      ],
    );
  }
}

/// Partner identity, role names and structure are all protected content: this
/// screen states who the other person is and how they describe their role, so
/// an unconfirmed session must show none of it.
class _AuthorizationLost extends StatelessWidget {
  const _AuthorizationLost({this.onSignIn});

  final VoidCallback? onSignIn;

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    return RecoveryScaffold(
      context_: l.recoveryConfirmingContext,
      title: l.dynamicTitle,
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
                l.dynamicHiddenDetails,
                textAlign: TextAlign.center,
                style: DsTextStyles.bodySecondary.copyWith(
                  color: DsColors.textOnRitualMuted,
                ),
              ),
              const SizedBox(height: DsSpacing.space8),
              SecondaryButton(
                label: l.recoverySignInAgain,
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
