import 'package:dio/dio.dart';
import 'package:ds_relationship_companion/ds_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../app/shell/bottom_navigation.dart';
import '../../../app/shell/ds_skeleton.dart';
import '../../../domain_client/models/us_view.dart';
import '../../../l10n/app_localizations.dart';
import '../../today/presentation/widgets/recovery_scaffold.dart';
import '../../today/presentation/widgets/secondary_button.dart';
import '../../today/presentation/widgets/today_header.dart';
import '../../today/presentation/widgets/today_layout.dart';

final usProvider = FutureProvider.autoDispose.family<UsView, String>(
  (ref, dynamicId) => ref.watch(dynamicRepositoryProvider).us(dynamicId),
);

/// SCR-17 Us — what recently happened between two people, and one way in to
/// the week.
///
/// Two things this screen deliberately does not do, both from the contract:
///
/// - **No relationship score or profile.** "remove complex relationship
///   scoring/profile emphasis". The server offers no such number, and a
///   history is not a rating.
/// - **No system events.** The acceptance criterion is that system reminders
///   do not count as connected moments, and `UsQueryService` already excludes
///   `occurrence_activated` from its allowlist. A screen that padded this list
///   with "the app created a task" would inflate exactly the signal the
///   product exists to be honest about.
///
/// `connectedDays` counts days where *both* people did something. It is stated
/// as a count of days, never as a rate, a streak or a target: the difference
/// between "four days had something on them" and "4/7" is the difference
/// between a record and a report card.
class UsScreen extends ConsumerWidget {
  const UsScreen({
    super.key,
    required this.dynamicId,
    this.onSignIn,
    this.onSelectTab,
    this.onWeekly,
    this.onSettings,
  });

  final String dynamicId;
  final VoidCallback? onSignIn;
  final void Function(NavSurface surface)? onSelectTab;

  /// Opens SCR-23 — the "one light D7 card" the alignment work asks for.
  final VoidCallback? onWeekly;

  /// Opens SCR-28. Us is where a person looks for themselves, so their own
  /// settings hang off it rather than off a surface about the pair.
  final VoidCallback? onSettings;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = L.of(context);
    final us = ref.watch(usProvider(dynamicId));
    void reload() => ref.invalidate(usProvider(dynamicId));

    return Scaffold(
      backgroundColor: DsColors.canvasRitual,
      body: DsRitualSurface(
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              Expanded(
                child: us.when(
                  skipLoadingOnReload: true,
                  skipLoadingOnRefresh: true,
                  loading: () => RecoveryScaffold(
                    context_: l.usConfirmingContext,
                    title: l.navUs,
                    children: const [
                      DsSkeletonPulse(
                        child: Column(
                          children: [
                            Padding(
                              padding: todayInset,
                              child: DsSkeletonBar(
                                widthFactor: 0.62,
                                height: 20,
                                emphasis: true,
                              ),
                            ),
                            SizedBox(height: DsSpacing.space3),
                            Padding(
                              padding: todayInset,
                              child: DsSkeletonBar(widthFactor: 0.85),
                            ),
                            SizedBox(height: DsSpacing.space10),
                            Padding(
                              padding: todayInset,
                              child: DsSkeletonCard(lines: [0.45, 0.8]),
                            ),
                            SizedBox(height: DsSpacing.space3),
                            Padding(
                              padding: todayInset,
                              child: DsSkeletonCard(lines: [0.4, 0.72, 0.5]),
                            ),
                            SizedBox(height: DsSpacing.space3),
                            Padding(
                              padding: todayInset,
                              child: DsSkeletonCard(lines: [0.42, 0.6]),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  error: (error, _) => _isAuthLoss(error)
                      ? _AuthorizationLost(onSignIn: onSignIn)
                      : RecoveryScaffold(
                          context_: l.usNotConfirmed,
                          title: l.navUs,
                          children: [
                            const SizedBox(height: DsSpacing.space8),
                            RecoveryMessage(
                              l.usCouldNotBeLoaded,
                              prominent: true,
                            ),
                            const SizedBox(height: DsSpacing.space6),
                            Padding(
                              padding: todayInset,
                              child: SecondaryButton(
                                label: l.usTryAgain,
                                onTap: reload,
                              ),
                            ),
                          ],
                        ),
                  data: (view) => _Loaded(
                    view: view,
                    onWeekly: onWeekly,
                    onSettings: onSettings,
                  ),
                ),
              ),
              DsBottomNavigation(
                current: NavSurface.us,
                onSelect: onSelectTab ?? (_) {},
              ),
            ],
          ),
        ),
      ),
    );
  }
}

bool _isAuthLoss(Object error) =>
    error is DioException &&
    (error.response?.statusCode == 401 || error.response?.statusCode == 403);

class _Loaded extends StatelessWidget {
  const _Loaded({required this.view, this.onWeekly, this.onSettings});

  final UsView view;
  final VoidCallback? onWeekly;
  final VoidCallback? onSettings;

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        Row(
          children: [
            Expanded(
              child: TodayHeader(title: l.navUs, context_: l.usSoFar),
            ),
            if (onSettings != null)
              Padding(
                padding: const EdgeInsets.only(right: DsSpacing.space5),
                child: GestureDetector(
                  onTap: onSettings,
                  behavior: HitTestBehavior.opaque,
                  child: Icon(
                    Icons.settings_outlined,
                    size: 22,
                    color: DsColors.textOnRitualMuted,
                    semanticLabel: l.usSettings,
                  ),
                ),
              ),
          ],
        ),

        Padding(
          padding: todayInset,
          child: Text(
            l.usConnectedDays(view.connectedDays),
            style: DsTextStyles.displayRitual.copyWith(
              color: DsColors.textOnRitualPrimary,
              fontSize: 26,
              height: 32 / 26,
            ),
          ),
        ),
        const SizedBox(height: DsSpacing.space3),
        Padding(
          padding: todayInset,
          child: Text(
            l.usConnectedDaysSupport,
            style: DsTextStyles.bodySecondary.copyWith(
              color: DsColors.textOnRitualMuted,
              fontSize: todaySupportSize,
              height: todaySupportHeight,
            ),
          ),
        ),

        if (onWeekly != null) ...[
          const SizedBox(height: DsSpacing.space8),
          Padding(
            padding: todayInset,
            child: SecondaryButton(label: l.usThisWeek, onTap: onWeekly!),
          ),
        ],

        const SizedBox(height: DsSpacing.space10),

        if (view.moments.isEmpty)
          Padding(
            padding: todayInset,
            child: Text(
              l.usNothingYet,
              style: const TextStyle(color: DsColors.textOnRitualMuted),
            ),
          )
        else ...[
          Padding(
            padding: todayInset.add(
              const EdgeInsets.only(bottom: DsSpacing.space4),
            ),
            child: Text(
              l.usRecently,
              style: DsTextStyles.labelRitual.copyWith(
                color: DsColors.textOnRitualMuted,
              ),
            ),
          ),
          for (final moment in view.moments) _Moment(moment: moment),
        ],

        const SizedBox(height: DsSpacing.space10),
      ],
    );
  }
}

class _Moment extends StatelessWidget {
  const _Moment({required this.moment});

  final RelationshipMoment moment;

  @override
  Widget build(BuildContext context) {
    final line = _describe(L.of(context), moment.eventType,
        moment.actorDisplayName);

    return Container(
      margin: todayInset.add(
        const EdgeInsets.only(bottom: DsSpacing.space3),
      ),
      padding: const EdgeInsets.all(DsSpacing.space4),
      decoration: BoxDecoration(
        color: DsColors.surfaceRitualRaised,
        borderRadius: BorderRadius.circular(DsRadii.card),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            line,
            style: DsTextStyles.bodySecondary.copyWith(
              color: DsColors.textOnRitualSecondary,
            ),
          ),
          if (moment.title != null) ...[
            const SizedBox(height: DsSpacing.space2),
            Text(
              moment.title!,
              style: DsTextStyles.displayRitual.copyWith(
                color: DsColors.textOnRitualPrimary,
                fontSize: 19,
                height: 25 / 19,
              ),
            ),
          ],
          // Only an acknowledgement carries text, and it is a person's own
          // words. Quoted so it cannot be mistaken for the app talking.
          //
          // Empty is checked as well as null: `text` defaults to "" on the
          // server for an acknowledgement sent without words, and an empty
          // pair of quotation marks reads as something having gone missing.
          if (moment.text != null && moment.text!.isNotEmpty) ...[
            const SizedBox(height: DsSpacing.space3),
            Text(
              '“${moment.text}”',
              style: DsTextStyles.displayRitual.copyWith(
                color: DsColors.textOnRitualRelationshipLarge,
                fontSize: 19,
                height: 25 / 19,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// What happened, in plain words.
///
/// The six types are exactly what `UsQueryService` allows. An unrecognised one
/// is described as "something happened" rather than shown as a raw enum: a
/// person should never be shown `adjustment_resolved`, and a new server event
/// type must not be able to leak database vocabulary onto this screen.
String _describe(L l, String eventType, String? who) {
  final name = who ?? l.usSomeone;
  return switch (eventType) {
    'completion_submitted' => l.usMomentCompletion(name),
    'acknowledgement_sent' => l.usMomentAcknowledgement(name),
    'adjustment_requested' => l.usMomentAdjustmentRequested(name),
    'adjustment_resolved' => l.usMomentAdjustmentResolved,
    'checkin_created' => l.usMomentCheckin(name),
    'member_joined' => l.usMomentMemberJoined(name),
    _ => l.usMomentUnknown,
  };
}

class _AuthorizationLost extends StatelessWidget {
  const _AuthorizationLost({this.onSignIn});

  final VoidCallback? onSignIn;

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    return RecoveryScaffold(
      context_: l.usConfirmingContext,
      title: l.navUs,
      children: [
        Padding(
          padding: todayInset,
          child: Text(
            l.usPrivateSessionEnded,
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
                l.usSessionNeedsRestoring,
                textAlign: TextAlign.center,
                style: DsTextStyles.displayRitual.copyWith(
                  color: DsColors.textOnRitualPrimary,
                  fontSize: 28,
                  height: 31 / 28,
                ),
              ),
              const SizedBox(height: DsSpacing.space5),
              Text(
                l.usHistoryHidden,
                textAlign: TextAlign.center,
                style: DsTextStyles.bodySecondary.copyWith(
                  color: DsColors.textOnRitualMuted,
                ),
              ),
              const SizedBox(height: DsSpacing.space8),
              SecondaryButton(
                label: l.usSignInAgain,
                onTap: onSignIn ?? () {},
                filled: true,
              ),
            ],
          ),
        ),
        const SizedBox(height: DsSpacing.space6),
        RecoveryMessage(l.usNoProtectedContent),
      ],
    );
  }
}
