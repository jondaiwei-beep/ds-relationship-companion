import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../design_system/components/ds_page.dart';
import '../../../design_system/tokens/colors.dart';
import '../../../design_system/tokens/spacing.dart';
import '../../../design_system/tokens/typography.dart';
import '../../../domain_client/models/explore_view.dart';

final exploreProvider =
    FutureProvider.autoDispose<ExploreLibraryView>((ref) async {
  return ref.watch(exploreRepositoryProvider).library();
});

/// Ideas worth borrowing.
///
/// This tab used to say "Nothing here yet." It was the third empty surface a
/// new person met, and it arrived just before the app asked them to send a
/// private link about an intimate subject to somebody they know. There was
/// nothing to be convinced by.
///
/// Distribution depends on one person deciding this is good enough to share.
/// That decision needs evidence, and this is where the product's judgement
/// is visible before any partner exists.
///
/// Flat divided rows rather than cards: a list of ideas is a list, and
/// wrapping each one in a rounded container makes a catalogue out of it.
class ExploreScreen extends ConsumerWidget {
  const ExploreScreen({super.key, this.onOpen});

  final void Function(ExploreIdea idea)? onOpen;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: DsColors.canvas,
      body: ref.watch(exploreProvider).when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, _) => DsPage(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: DsSpacing.xxxl),
                  Text("We couldn't load these just now.", style: DsType.h2),
                ],
              ),
            ),
            data: (lib) => DsPage(child: _body(lib)),
          ),
    );
  }

  Widget _body(ExploreLibraryView lib) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: DsSpacing.sm),
        Text('Ideas', style: DsType.h1),
        const SizedBox(height: DsSpacing.xxl),

        for (final c in lib.collections) ...[
          Text(c.title, style: DsType.h2),
          const SizedBox(height: DsSpacing.xs),
          Text(c.blurb, style: DsType.fine.copyWith(color: DsColors.muted)),
          const SizedBox(height: DsSpacing.lg),
          for (final idea
              in lib.ideas.where((i) => i.collectionId == c.id))
            _IdeaRow(idea: idea, onOpen: onOpen),
          const SizedBox(height: DsSpacing.xxl),
        ],
      ],
    );
  }
}

class _IdeaRow extends StatelessWidget {
  const _IdeaRow({required this.idea, this.onOpen});

  final ExploreIdea idea;
  final void Function(ExploreIdea idea)? onOpen;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onOpen == null ? null : () => onOpen!(idea),
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: DsColors.line)),
        ),
        padding: const EdgeInsets.symmetric(vertical: DsSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(idea.title,
                style: DsType.cardTitle.copyWith(fontSize: 17)),
            const SizedBox(height: DsSpacing.xs),
            Text(idea.purpose,
                style: DsType.fine.copyWith(color: DsColors.muted)),
          ],
        ),
      ),
    );
  }
}
