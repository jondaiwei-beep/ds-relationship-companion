import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../design_system/components/ds_button.dart';
import '../../../design_system/components/ds_text.dart';
import '../../../design_system/tokens/colors.dart';
import '../../../design_system/tokens/spacing.dart';
import '../../../design_system/tokens/typography.dart';
import '../../../domain_client/models/weekly_reflection_view.dart';

final weeklyReflectionProvider = FutureProvider.autoDispose
    .family<WeeklyReflectionView, String>((ref, dynamicId) async {
  return ref.watch(dynamicRepositoryProvider).weekly(dynamicId);
});

/// D7 Weekly Reflection — Notion 02 §8, 01 §6.
///
/// Three deliberate constraints, all of them product red lines:
///
/// 1. **It describes; it does not grade.** No completion rate, no score, no
///    streak. A week is recounted by what a person actually answered.
/// 2. **It never names a shortfall.** There is no "you missed 3" line. A Miss
///    is not disobedience, and the system does not get to imply it was.
/// 3. **It offers no verdict.** The Keep / Adjust / Pause decision belongs to
///    the couple. This section ends with a question, not a recommendation —
///    automation prepares; the partner responds.
///
/// It stays hidden entirely until the couple has a week behind them.
class WeeklyReflectionSection extends ConsumerWidget {
  const WeeklyReflectionSection({
    super.key,
    required this.dynamicId,
    this.onAdjust,
    this.onPause,
  });

  final String dynamicId;

  /// The week has to end in a real decision, not a sentence describing one
  /// (Notion 06 §13.7: "用户可以从 Weekly 决策回到下一周 rhythm").
  ///
  /// Keep needs no handler — keeping the rhythm means changing nothing, and
  /// a button that does nothing but dismiss would be theatre.
  final VoidCallback? onAdjust;
  final VoidCallback? onPause;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // A reflection is never worth an error state or a spinner — it is not the
    // reason anyone opened this screen. If it cannot load, it is simply absent.
    final r = ref.watch(weeklyReflectionProvider(dynamicId)).value;
    if (r == null || !r.hasEnoughHistory) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // An open section on Bone, NOT a card.
        //
        // A tinted card under a terracotta all-caps eyebrow is the visual
        // syntax of an analytics summary: it makes the reflection read as a
        // special history entry with a result in it, rather than as the
        // frame around the history below. Same width and radius as the event
        // cards was the tell.
        Text('This past week',
            style: DsType.fine.copyWith(color: DsColors.muted)),
        const SizedBox(height: DsSpacing.sm),
        const DsAccentRule(),
        const SizedBox(height: DsSpacing.lg),

        // Prose, not a headline with a number in it. Counts stay inside
        // ordinary sentences so they cannot be glanced at as a metric.
        Text(_summary(r), style: DsType.h2.copyWith(height: 1.3)),
        if (r.adjustmentsResolved > 0) ...[
          const SizedBox(height: DsSpacing.sm),
          Text(
            r.adjustmentsResolved == 1
                ? 'You worked something out together.'
                : 'You worked several things out together.',
            style: DsType.body.copyWith(color: DsColors.muted),
          ),
        ],

        // The week ends in the couple's decision, so it closes on a
        // question — but only when the decision can actually be made. A
        // question with no way to answer it is worse than no question, and
        // leaving that to the caller is how the shipped screen ended in a
        // dangling prompt.
        if (onAdjust != null || onPause != null) ...[
          const SizedBox(height: DsSpacing.xxl),
          Text('What rhythm feels right for the week ahead?',
              style: DsType.cardTitle.copyWith(fontSize: 18)),
          const SizedBox(height: DsSpacing.lg),
          // Wrap rather than Row: at large text sizes a fixed row cramps.
          Wrap(
            spacing: DsSpacing.md,
            runSpacing: DsSpacing.md,
            children: [
              if (onAdjust != null)
                SizedBox(
                  width: 152,
                  child: DsButton(
                      label: 'Adjust it', outline: true, onPressed: onAdjust),
                ),
              if (onPause != null)
                SizedBox(
                  width: 152,
                  child: DsButton(
                      label: 'Pause', outline: true, onPressed: onPause),
                ),
            ],
          ),
          const SizedBox(height: DsSpacing.md),
          Text(
            // Keeping means changing nothing, so it is stated rather than
            // offered as a third button that only dismisses.
            'Keeping it as it is requires no change.',
            style: DsType.fine.copyWith(color: DsColors.muted),
          ),
        ],
        const SizedBox(height: DsSpacing.xxxl),
      ],
    );
  }

  /// Describes the week. Never counts what did not happen.
  String _summary(WeeklyReflectionView r) {
    final answered = r.answeredMoments.length;
    if (answered == 0 && r.connectedDays == 0) {
      return 'A quiet week.';
    }
    if (answered == 0) {
      return r.connectedDays == 1
          ? 'One day this week you were both here.'
          : '${r.connectedDays} days this week you were both here.';
    }
    final moments = answered == 1 ? 'One moment' : '$answered moments';
    return r.connectedDays <= 1
        ? '$moments got a real response.'
        : '$moments got a real response, across '
            '${r.connectedDays} days you were both here.';
  }
}
