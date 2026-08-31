import 'package:ds_relationship_companion/ds_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../domain_client/models/weekly_reflection_view.dart';
import '../../today/presentation/widgets/secondary_button.dart';
import '../../today/presentation/widgets/today_layout.dart';

final weeklyProvider = FutureProvider.autoDispose
    .family<WeeklyReflectionView, String>(
      (ref, dynamicId) =>
          ref.watch(dynamicRepositoryProvider).weekly(dynamicId),
    );

/// SCR-23 Weekly check-in — what actually happened, and one direction.
///
/// The preview and the contract disagree, and the contract wins. The preview
/// is a four-step questionnaire built around a slider that places you against
/// your partner on a scale; the contract says "no comparative score or
/// multi-step questionnaire" and "only human/domain events support the
/// summary". Those are the same two things, forbidden by name.
///
/// The slider also has nothing behind it. The server reports connected days,
/// the moments a real person answered, and how many adjustments were worked
/// out — no ratings, per-person or otherwise. Drawing that scale would mean
/// inventing both people's positions on it and then telling them who felt
/// steadier, which is a judgement the product does not have and should not
/// make on their behalf.
///
/// Keep and Pause are offered because both are real: Keep is doing nothing,
/// and Pause has an endpoint. Adjust is named in the contract but has no way
/// to happen — structure level is fixed at creation — so it is absent rather
/// than present and inert.
class WeeklyScreen extends ConsumerWidget {
  const WeeklyScreen({
    super.key,
    required this.dynamicId,
    this.onClose,
    this.onPause,
  });

  final String dynamicId;
  final VoidCallback? onClose;
  final VoidCallback? onPause;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weekly = ref.watch(weeklyProvider(dynamicId));

    return Scaffold(
      backgroundColor: DsColors.canvasRitual,
      body: DsRitualSurface(
        child: SafeArea(
          child: Column(
            children: [
              _TopBar(onClose: onClose),
              Expanded(
                child: weekly.when(
                  skipLoadingOnReload: true,
                  loading: () => const _Message(
                    'Gathering what actually happened this week.',
                  ),
                  error: (_, _) => Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const _Message(
                        'This week could not be loaded. Nothing was changed.',
                        prominent: true,
                      ),
                      const SizedBox(height: DsSpacing.space6),
                      Padding(
                        padding: todayInset,
                        child: SecondaryButton(
                          label: 'Try again',
                          onTap: () =>
                              ref.invalidate(weeklyProvider(dynamicId)),
                        ),
                      ),
                    ],
                  ),
                  data: (view) => view.hasEnoughHistory
                      ? _Week(view: view, onPause: onPause, onClose: onClose)
                      : const _TooEarly(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A reflection offered on day two invites a judgement about a week that has
/// not happened. The server decides when there is enough; this never guesses.
class _TooEarly extends StatelessWidget {
  const _TooEarly();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.zero,
      children: const [
        SizedBox(height: DsSpacing.space10),
        _Message('There is not a week to look back on yet.', prominent: true),
        SizedBox(height: DsSpacing.space3),
        _Message(
          'This comes back once you have some days behind you. Nothing is '
          'missing in the meantime.',
        ),
      ],
    );
  }
}

class _Week extends StatelessWidget {
  const _Week({required this.view, this.onPause, this.onClose});

  final WeeklyReflectionView view;
  final VoidCallback? onPause;
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        Padding(
          padding: todayInset,
          child: Text(
            _headline(view),
            style: DsTextStyles.displayRitual.copyWith(
              color: DsColors.textOnRitualPrimary,
              fontSize: 28,
              height: 34 / 28,
            ),
          ),
        ),
        const SizedBox(height: DsSpacing.space3),
        _Message(_support(view)),

        if (view.answeredMoments.isNotEmpty) ...[
          const SizedBox(height: DsSpacing.space8),
          Padding(
            padding: todayInset.add(
              const EdgeInsets.only(bottom: DsSpacing.space4),
            ),
            child: Text(
              'WHAT WAS ANSWERED',
              style: DsTextStyles.labelRitual.copyWith(
                color: DsColors.textOnRitualMuted,
              ),
            ),
          ),
          for (final moment in view.answeredMoments) _Moment(moment: moment),
        ],

        const SizedBox(height: DsSpacing.space10),
        Padding(
          padding: todayInset.add(
            const EdgeInsets.only(bottom: DsSpacing.space4),
          ),
          child: Text(
            'NEXT WEEK',
            style: DsTextStyles.labelRitual.copyWith(
              color: DsColors.textOnRitualMuted,
            ),
          ),
        ),
        Padding(
          padding: todayInset,
          child: SecondaryButton(
            label: 'Keep the current rhythm',
            onTap: onClose ?? () {},
            filled: true,
          ),
        ),
        const SizedBox(height: DsSpacing.space4),
        if (onPause != null)
          Padding(
            padding: todayInset,
            child: SecondaryButton(label: 'Pause instead', onTap: onPause!),
          ),
        const SizedBox(height: DsSpacing.space4),
        const _Message(
          'Keeping is not a commitment. Either of you may pause at any time, '
          'from Dynamic.',
        ),
        const SizedBox(height: DsSpacing.space10),
      ],
    );
  }
}

/// Described by what happened, never scored. `connectedDays` is a count of
/// days with something real on them, not a rate or a streak — nothing here
/// should read as a target that was missed.
String _headline(WeeklyReflectionView view) => switch (view.connectedDays) {
  0 => 'A quiet week.',
  1 => 'One day had something on it.',
  final n => '$n days had something on them.',
};

String _support(WeeklyReflectionView view) {
  final answered = view.answeredMoments.length;
  final adjusted = view.adjustmentsResolved;

  final parts = <String>[
    if (answered == 1)
      'One thing was answered by a person'
    else if (answered > 1)
      '$answered things were answered by a person',
    if (adjusted == 1)
      'one adjustment was worked out together'
    else if (adjusted > 1)
      '$adjusted adjustments were worked out together',
  ];

  if (parts.isEmpty) {
    return 'Nothing was completed or answered. That is a fact about the '
        'week, not about either of you.';
  }
  return '${parts.join(', and ')}.';
}

/// One person's actual words. Never paraphrased and never summarised — the
/// system does not speak for either of them (red line #1).
class _Moment extends StatelessWidget {
  const _Moment({required this.moment});

  final WeeklyMoment moment;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: todayInset.add(
        const EdgeInsets.only(bottom: DsSpacing.space4),
      ),
      padding: const EdgeInsets.all(DsSpacing.space4),
      decoration: BoxDecoration(
        color: DsColors.surfaceRitualRaised,
        borderRadius: BorderRadius.circular(DsRadii.card),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (moment.title != null)
            Text(
              moment.title!,
              style: DsTextStyles.bodySecondary.copyWith(
                color: DsColors.textOnRitualMuted,
                fontSize: todaySupportSize,
                height: todaySupportHeight,
              ),
            ),
          if (moment.text != null) ...[
            const SizedBox(height: DsSpacing.space2),
            Text(
              moment.text!,
              style: DsTextStyles.displayRitual.copyWith(
                color: DsColors.textOnRitualPrimary,
                fontSize: 20,
                height: 27 / 20,
              ),
            ),
          ],
          if (moment.fromDisplayName != null) ...[
            const SizedBox(height: DsSpacing.space2),
            Text(
              '— ${moment.fromDisplayName}',
              style: DsTextStyles.bodySecondary.copyWith(
                color: DsColors.textOnRitualRelationshipLarge,
                fontSize: todaySupportSize,
                height: todaySupportHeight,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _Message extends StatelessWidget {
  const _Message(this.text, {this.prominent = false});

  final String text;
  final bool prominent;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: todayInset,
      child: Text(
        text,
        style: prominent
            ? DsTextStyles.bodyPrimary.copyWith(
                color: DsColors.textOnRitualPrimary,
              )
            : DsTextStyles.bodySecondary.copyWith(
                color: DsColors.textOnRitualMuted,
                fontSize: todaySupportSize,
                height: todaySupportHeight,
              ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({this.onClose});

  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: todayInset.add(
        const EdgeInsets.symmetric(vertical: DsSpacing.space4),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'THIS WEEK',
              style: DsTextStyles.labelRitual.copyWith(
                color: DsColors.textOnRitualMuted,
              ),
            ),
          ),
          GestureDetector(
            onTap: onClose,
            behavior: HitTestBehavior.opaque,
            child: Icon(
              Icons.close,
              size: 22,
              color: DsColors.textOnRitualMuted,
              semanticLabel: 'Close',
            ),
          ),
        ],
      ),
    );
  }
}
