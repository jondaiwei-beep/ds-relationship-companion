import 'package:dio/dio.dart';
import 'package:ds_relationship_companion/ds_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../app/shell/bottom_navigation.dart';
import '../../../domain_client/models/us_view.dart';
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
  });

  final String dynamicId;
  final VoidCallback? onSignIn;
  final void Function(NavSurface surface)? onSelectTab;

  /// Opens SCR-23 — the "one light D7 card" the alignment work asks for.
  final VoidCallback? onWeekly;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                  loading: () => const RecoveryScaffold(
                    context_: 'Confirming context',
                    title: 'Us',
                    children: [
                      SizedBox(height: DsSpacing.space8),
                      RecoveryMessage('Reading what has happened so far.'),
                    ],
                  ),
                  error: (error, _) => _isAuthLoss(error)
                      ? _AuthorizationLost(onSignIn: onSignIn)
                      : RecoveryScaffold(
                          context_: 'Not confirmed',
                          title: 'Us',
                          children: [
                            const SizedBox(height: DsSpacing.space8),
                            const RecoveryMessage(
                              'This could not be loaded. Nothing is missing '
                              'from your history.',
                              prominent: true,
                            ),
                            const SizedBox(height: DsSpacing.space6),
                            Padding(
                              padding: todayInset,
                              child: SecondaryButton(
                                label: 'Try again',
                                onTap: reload,
                              ),
                            ),
                          ],
                        ),
                  data: (view) => _Loaded(view: view, onWeekly: onWeekly),
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
  const _Loaded({required this.view, this.onWeekly});

  final UsView view;
  final VoidCallback? onWeekly;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        const TodayHeader(title: 'Us', context_: 'So far'),

        Padding(
          padding: todayInset,
          child: Text(
            _connected(view.connectedDays),
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
            'Days you both did something. Nothing the app did on its own is '
            'counted here.',
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
            child: SecondaryButton(label: 'This week', onTap: onWeekly!),
          ),
        ],

        const SizedBox(height: DsSpacing.space10),

        if (view.moments.isEmpty)
          const Padding(
            padding: todayInset,
            child: Text(
              'Nothing has happened here yet. It fills up as you use it — '
              'there is nothing to catch up on.',
              style: TextStyle(color: DsColors.textOnRitualMuted),
            ),
          )
        else ...[
          Padding(
            padding: todayInset.add(
              const EdgeInsets.only(bottom: DsSpacing.space4),
            ),
            child: Text(
              'RECENTLY',
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

/// A count of days, never a rate. "4 of 7" would turn a record into a target
/// and make an ordinary week read as a shortfall.
String _connected(int days) => switch (days) {
  0 => 'Nothing has landed on the same day yet.',
  1 => 'One day you both showed up.',
  final n => '$n days you both showed up.',
};

class _Moment extends StatelessWidget {
  const _Moment({required this.moment});

  final RelationshipMoment moment;

  @override
  Widget build(BuildContext context) {
    final who = moment.actorDisplayName;
    final line = _describe(moment.eventType, who);

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
String _describe(String eventType, String? who) {
  final name = who ?? 'Someone';
  return switch (eventType) {
    'completion_submitted' => '$name did something that was asked',
    'acknowledgement_sent' => '$name answered',
    'adjustment_requested' => '$name asked to change something',
    'adjustment_resolved' => 'You worked something out',
    'checkin_created' => '$name shared how they were',
    'member_joined' => '$name joined',
    _ => 'Something happened',
  };
}

class _AuthorizationLost extends StatelessWidget {
  const _AuthorizationLost({this.onSignIn});

  final VoidCallback? onSignIn;

  @override
  Widget build(BuildContext context) {
    return RecoveryScaffold(
      context_: 'Confirming context',
      title: 'Us',
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
                'Your history together has been hidden.\n'
                'Sign in again to confirm current access.',
                textAlign: TextAlign.center,
                style: DsTextStyles.bodySecondary.copyWith(
                  color: DsColors.textOnRitualMuted,
                ),
              ),
              const SizedBox(height: DsSpacing.space8),
              SecondaryButton(
                label: 'Sign in again',
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
