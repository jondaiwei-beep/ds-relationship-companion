import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../design_system/components/ds_button.dart';
import '../../../design_system/components/ds_page.dart';
import '../../../design_system/components/ds_text.dart';
import '../../../design_system/tokens/colors.dart';
import '../../../design_system/tokens/spacing.dart';
import '../../../design_system/tokens/typography.dart';
import '../../../domain_client/models/dynamic_summary.dart';

final myDynamicsProvider =
    FutureProvider.autoDispose<List<DynamicSummary>>((ref) async {
  return ref.watch(dynamicRepositoryProvider).mine();
});

/// Where a signed-in member lands.
///
/// Every real screen is addressed by a dynamic id, and sign-in cannot know
/// one. Without this step a member who did not arrive through an invite link
/// reached a page with nothing on it and no way forward — a dead end, which
/// Notion 02 §11 forbids.
///
/// One dynamic (the Core Beta case) routes straight through, so this is
/// invisible in normal use.
class HomeResolver extends ConsumerWidget {
  const HomeResolver({super.key, required this.onOpen, this.onCreate});

  final void Function(String dynamicId) onOpen;
  final VoidCallback? onCreate;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: DsColors.canvas,
      body: ref.watch(myDynamicsProvider).when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, _) => DsPage(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: DsSpacing.xxxl),
                  Text("We couldn't reach your dynamic.", style: DsType.h2),
                  const SizedBox(height: DsSpacing.lg),
                  Text(
                    'Nothing was lost. Check your connection and try again.',
                    style: DsType.body.copyWith(color: DsColors.muted),
                  ),
                  const SizedBox(height: DsSpacing.xxl),
                  DsButton(
                    label: 'Try again',
                    outline: true,
                    onPressed: () => ref.invalidate(myDynamicsProvider),
                  ),
                ],
              ),
            ),
            data: (list) {
              if (list.length == 1) {
                // Route through without a flash of chooser.
                WidgetsBinding.instance.addPostFrameCallback(
                  (_) => onOpen(list.first.dynamicId),
                );
                // Deliberately NOT a spinner: if the hand-off never happens,
                // a spinner turns forever and says nothing. A quiet ground
                // is honest for the frame this is visible.
                return const SizedBox.shrink();
              }
              return DsPage(
                child: list.isEmpty ? _empty(context) : _chooser(list),
              );
            },
          ),
    );
  }

  Widget _empty(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: DsSpacing.xxl),
        const DsAccentRule(),
        const SizedBox(height: DsSpacing.sm),
        Text('Nothing here yet.', style: DsType.h1),
        const SizedBox(height: DsSpacing.lg),
        Text(
          // Says what this is for and what happens next. An empty screen
          // that only greets you is a dead end.
          'A dynamic is the space between you and one other person. '
          'Start one and you can invite them by link — they join in a '
          'browser, with nothing to install.',
          style: DsType.body.copyWith(color: DsColors.muted),
        ),
        const SizedBox(height: DsSpacing.xxl),
        if (onCreate != null)
          DsButton(label: 'Start a dynamic', onPressed: onCreate),
        const SizedBox(height: DsSpacing.xl),
        Text(
          'If someone has already invited you, open their link instead.',
          style: DsType.fine.copyWith(color: DsColors.muted),
        ),
      ],
    );
  }

  Widget _chooser(List<DynamicSummary> list) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: DsSpacing.sm),
        Text('Which one?', style: DsType.h1),
        const SizedBox(height: DsSpacing.xxl),
        for (final d in list) ...[
          _DynamicRow(summary: d, onOpen: () => onOpen(d.dynamicId)),
          const SizedBox(height: DsSpacing.md),
        ],
      ],
    );
  }
}

class _DynamicRow extends StatelessWidget {
  const _DynamicRow({required this.summary, required this.onOpen});

  final DynamicSummary summary;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onOpen,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(15, 14, 15, 14),
        decoration: BoxDecoration(
          color: DsColors.surface,
          border: Border.all(color: DsColors.line),
          borderRadius: BorderRadius.circular(DsSpacing.cardRadius),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              // Named by the person, never by an id.
              summary.partnerDisplayName == null
                  ? 'Waiting for someone to join'
                  : 'With ${summary.partnerDisplayName}',
              style: DsType.cardTitle,
            ),
            if (summary.state == 'PAUSED') ...[
              const SizedBox(height: DsSpacing.xs),
              Text('Paused', style: DsType.fine.copyWith(color: DsColors.muted)),
            ],
          ],
        ),
      ),
    );
  }
}
