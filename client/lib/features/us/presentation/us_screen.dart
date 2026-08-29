import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../design_system/components/ds_card.dart';
import '../../../design_system/components/ds_page.dart';
import '../../../design_system/components/ds_text.dart';
import '../../../design_system/tokens/colors.dart';
import '../../../design_system/tokens/spacing.dart';
import '../../../design_system/tokens/typography.dart';
import '../../../domain_client/models/us_view.dart';
import 'weekly_reflection_section.dart';

final usProvider =
    FutureProvider.autoDispose.family<UsView, String>((ref, dynamicId) async {
  return ref.watch(dynamicRepositoryProvider).us(dynamicId);
});

/// Us — what recently happened between us (Notion 02 §8).
///
/// Core Beta shows recent history only. No relationship score, no streak, no
/// 30/90-day analytics — those would turn a relationship into a dashboard,
/// which is exactly what the research warned against (Notion 01 §7).
class UsScreen extends ConsumerWidget {
  const UsScreen({
    super.key,
    required this.dynamicId,
    this.onAdjust,
    this.onPause,
  });

  final String dynamicId;

  /// What the weekly reflection's decision actually does.
  final VoidCallback? onAdjust;
  final VoidCallback? onPause;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: DsColors.canvas,
      body: ref.watch(usProvider(dynamicId)).when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, _) => DsPage(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: DsSpacing.xxxl),
                  Text("We couldn't load this just now.", style: DsType.h2),
                  const SizedBox(height: DsSpacing.lg),
                  Text('Nothing was lost.',
                      style: DsType.body.copyWith(color: DsColors.muted)),
                ],
              ),
            ),
            data: (u) => DsPage(child: _body(u)),
          ),
    );
  }

  Widget _body(UsView u) {
    // The reflection is NOT nested inside the history branch. An early
    // return on an empty history swallowed it silently — and a week can
    // genuinely have answered moments while the recent list is empty,
    // because the two are computed over different windows.
    final empty = u.moments.isEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: DsSpacing.sm),
        Text('Us', style: DsType.h1),
        if (empty) ...[
          Text('Nothing here yet.', style: DsType.h1),
          const SizedBox(height: DsSpacing.lg),
          Text(
            'This is where what happens between you will collect.',
            style: DsType.body.copyWith(color: DsColors.muted),
          ),
        ],
        const SizedBox(height: DsSpacing.xxl),
        // The week's reflection sits above the raw history: it is the frame,
        // not another entry. Absent until there is a week to reflect on.
        WeeklyReflectionSection(
          dynamicId: dynamicId,
          onAdjust: onAdjust,
          onPause: onPause,
        ),
        if (!empty) ...[
          const DsEyebrow('Recently'),
          const SizedBox(height: DsSpacing.md),
          for (final m in u.moments) ...[
            _MomentCard(moment: m),
            const SizedBox(height: DsSpacing.md),
          ],
        ],
      ],
    );
  }
}

class _MomentCard extends StatelessWidget {
  const _MomentCard({required this.moment});

  final RelationshipMoment moment;

  @override
  Widget build(BuildContext context) {
    // A human response is the emotional peak, so it gets the dark surface
    // (V5 §10). Everything else stays quiet.
    final isResponse = moment.eventType == 'acknowledgement_sent';

    return DsCard(
      tone: isResponse ? DsCardTone.dark : DsCardTone.light,
      showRail: isResponse,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DsEyebrow(_label(moment), onDark: isResponse),
          const SizedBox(height: DsSpacing.md),
          if (isResponse && moment.text != null)
            // Their words, verbatim.
            Text(moment.text!, style: DsType.cardTitle.copyWith(
              color: DsColors.surface, fontSize: 18, height: 1.35,
            ))
          else if (moment.title != null)
            Text(moment.title!, style: DsType.cardTitle),
          const SizedBox(height: DsSpacing.sm),
          Text(
            _when(moment.occurredAt),
            style: DsType.fine.copyWith(
              color: isResponse ? DsColors.onResponseMuted : DsColors.muted,
            ),
          ),
        ],
      ),
    );
  }

  /// Backend event names never reach the user (Notion 05 §12).
  String _label(RelationshipMoment m) {
    final who = m.actorDisplayName ?? 'Someone';
    return switch (m.eventType) {
      'acknowledgement_sent' => '$who responded',
      'completion_submitted' => '$who completed',
      'adjustment_requested' => '$who asked to adjust',
      'adjustment_resolved' => '$who resolved it together',
      'checkin_created' => '$who shared a check-in',
      'member_joined' => '$who joined',
      _ => who,
    };
  }

  String _when(DateTime t) {
    final now = DateTime.now();
    final days = DateTime(now.year, now.month, now.day)
        .difference(DateTime(t.year, t.month, t.day))
        .inDays;
    final h = t.hour % 12 == 0 ? 12 : t.hour % 12;
    final time = '$h:${t.minute.toString().padLeft(2, '0')} ${t.hour < 12 ? 'AM' : 'PM'}';
    return switch (days) {
      0 => 'Today · $time',
      1 => 'Yesterday · $time',
      _ => '$days days ago · $time',
    };
  }
}
