import 'package:dio/dio.dart';
import 'package:ds_relationship_companion/ds_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../app/shell/bottom_navigation.dart';
import '../../../app/shell/ds_refreshable.dart';
import '../../../app/shell/ds_skeleton.dart';
import '../../../domain_client/models/explore_view.dart';
import '../../../l10n/app_localizations.dart';
import '../../today/presentation/widgets/recovery_scaffold.dart';
import '../../today/presentation/widgets/secondary_button.dart';
import '../../today/presentation/widgets/today_header.dart';
import '../../today/presentation/widgets/today_layout.dart';

/// Kept alive across tab switches: `autoDispose` meant leaving this surface
/// destroyed its data, so coming back always refetched. Four tabs each
/// reloading on every visit made the app feel like it kept forgetting where
/// you were, for no reason but navigation.
///
/// Fetching is now something a person asks for — pull to refresh — or
/// something a command causes, because the server decides what changed.
final exploreProvider = FutureProvider<ExploreLibraryView>(
  (ref) => ref.watch(exploreRepositoryProvider).library(),
);

/// SCR-18 Explore — the restrained Core Beta version.
///
/// The full screen is Public MVP and stays out of scope. What the contract
/// permits here is narrower and worth having: "Core Beta may use a restrained
/// placeholder/starter suggestions but not this full content surface."
///
/// This was a placeholder saying "Not open yet" while `GET /v1/explore` had
/// been live all along, returning five reviewed collections and sixteen
/// ideas. Nothing was waiting on Public MVP work — the tab was simply never
/// wired to content that already existed.
///
/// So it is a reading surface, not a feed. No search, no personalisation, no
/// recommendation, no counts: those are the "full content surface" the
/// contract holds back, and every one of them would need behaviour the server
/// does not model. An idea can be taken to the Ask screen, because an idea you
/// cannot act on is a magazine.
class ExploreScreen extends ConsumerWidget {
  const ExploreScreen({
    super.key,
    required this.dynamicId,
    this.onSignIn,
    this.onSelectTab,
    this.onUse,
  });

  final String dynamicId;
  final VoidCallback? onSignIn;
  final void Function(NavSurface surface)? onSelectTab;

  /// Opens SCR-20 carrying this idea's title and purpose. Null while there is
  /// no route to it — the ideas still read fine without one.
  final void Function(ExploreIdea idea)? onUse;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = L.of(context);
    final library = ref.watch(exploreProvider);

    // Pull to ask again. Wraps `when` rather than only the loaded state so a
    // failed load can be retried by the same gesture.
    Future<void> refresh() => ref.refresh(exploreProvider.future);

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
                  child: library.when(
                    skipLoadingOnReload: true,
                    skipLoadingOnRefresh: true,
                    loading: () => RecoveryScaffold(
                      context_: l.exploreContextReading,
                      title: l.exploreTitle,
                      children: const [
                        DsSkeletonPulse(
                          child: Column(
                            children: [
                              Padding(
                                padding: todayInset,
                                child: DsSkeletonBar(
                                  widthFactor: 0.5,
                                  height: 18,
                                  emphasis: true,
                                ),
                              ),
                              SizedBox(height: DsSpacing.space3),
                              Padding(
                                padding: todayInset,
                                child: DsSkeletonBar(widthFactor: 0.8),
                              ),
                              SizedBox(height: DsSpacing.space6),
                              Padding(
                                padding: todayInset,
                                child: DsSkeletonCard(lines: [0.3, 0.85, 0.6]),
                              ),
                              SizedBox(height: DsSpacing.space3),
                              Padding(
                                padding: todayInset,
                                child: DsSkeletonCard(lines: [0.32, 0.7, 0.55]),
                              ),
                              SizedBox(height: DsSpacing.space3),
                              Padding(
                                padding: todayInset,
                                child: DsSkeletonCard(lines: [0.28, 0.78, 0.5]),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    error: (error, _) => _isAuthLoss(error)
                        ? RecoveryScaffold(
                            context_: l.exploreContextConfirming,
                            title: l.exploreTitle,
                            children: [
                              const SizedBox(height: DsSpacing.space8),
                              RecoveryMessage(
                                l.exploreSessionLost,
                                prominent: true,
                              ),
                              const SizedBox(height: DsSpacing.space6),
                              Padding(
                                padding: todayInset,
                                child: SecondaryButton(
                                  label: l.exploreSignInAgain,
                                  onTap: onSignIn ?? () {},
                                  filled: true,
                                ),
                              ),
                            ],
                          )
                        : RecoveryScaffold(
                            context_: l.exploreContextNotLoaded,
                            title: l.exploreTitle,
                            children: [
                              const SizedBox(height: DsSpacing.space8),
                              RecoveryMessage(
                                l.exploreLoadFailed,
                                prominent: true,
                              ),
                              const SizedBox(height: DsSpacing.space6),
                              Padding(
                                padding: todayInset,
                                child: SecondaryButton(
                                  label: l.exploreTryAgain,
                                  onTap: () => ref.invalidate(exploreProvider),
                                ),
                              ),
                            ],
                          ),
                    data: (view) => _Library(view: view, onUse: onUse),
                  ),
                ),
              ),
              DsBottomNavigation(
                current: NavSurface.rules,
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

class _Library extends StatelessWidget {
  const _Library({required this.view, this.onUse});

  final ExploreLibraryView view;
  final void Function(ExploreIdea idea)? onUse;

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    // Collections the server actually sent ideas for. An empty heading would
    // read as something having failed to load.
    final populated = view.collections
        .where((c) => view.ideas.any((i) => i.collectionId == c.id))
        .toList();

    if (populated.isEmpty) {
      return RecoveryScaffold(
        context_: l.exploreContextNothingYet,
        title: l.exploreTitle,
        children: [
          const SizedBox(height: DsSpacing.space8),
          RecoveryMessage(l.exploreEmpty, prominent: true),
        ],
      );
    }

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        TodayHeader(title: l.exploreTitle, context_: l.exploreContextIdeas),
        Padding(
          padding: todayInset,
          child: Text(
            // Never a recommendation about these two people: the library is
            // what others found worth asking for, stated as such.
            l.exploreIntro,
            style: DsTextStyles.bodySecondary.copyWith(
              color: DsColors.textOnRitualMuted,
              fontSize: todaySupportSize,
              height: todaySupportHeight,
            ),
          ),
        ),
        const SizedBox(height: DsSpacing.space8),
        for (final collection in populated)
          _Collection(
            collection: collection,
            ideas: view.ideas
                .where((i) => i.collectionId == collection.id)
                .toList(),
            onUse: onUse,
          ),
        const SizedBox(height: DsSpacing.space10),
      ],
    );
  }
}

class _Collection extends StatelessWidget {
  const _Collection({
    required this.collection,
    required this.ideas,
    this.onUse,
  });

  final ExploreCollection collection;
  final List<ExploreIdea> ideas;
  final void Function(ExploreIdea idea)? onUse;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: todayInset,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                collection.title,
                style: DsTextStyles.displayRitual.copyWith(
                  color: DsColors.textOnRitualPrimary,
                  fontSize: 22,
                  height: 27 / 22,
                ),
              ),
              const SizedBox(height: DsSpacing.space2),
              Text(
                collection.blurb,
                style: DsTextStyles.bodySecondary.copyWith(
                  color: DsColors.textOnRitualMuted,
                  fontSize: todaySupportSize,
                  height: todaySupportHeight,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: DsSpacing.space4),
        for (final idea in ideas) _Idea(idea: idea, onUse: onUse),
        const SizedBox(height: DsSpacing.space8),
      ],
    );
  }
}

class _Idea extends StatefulWidget {
  const _Idea({required this.idea, this.onUse});

  final ExploreIdea idea;
  final void Function(ExploreIdea idea)? onUse;

  @override
  State<_Idea> createState() => _IdeaState();
}

class _IdeaState extends State<_Idea> {
  /// Collapsed by default. Sixteen ideas fully expanded is a wall of text, and
  /// the title alone is enough to decide whether to read further.
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    final idea = widget.idea;

    return Container(
      margin: todayInset.add(const EdgeInsets.only(bottom: DsSpacing.space3)),
      decoration: BoxDecoration(
        color: DsColors.surfaceRitualRaised,
        borderRadius: BorderRadius.circular(DsRadii.card),
      ),
      child: Material(
        color: DsPrimitiveColors.transparent,
        borderRadius: BorderRadius.circular(DsRadii.card),
        child: InkWell(
          borderRadius: BorderRadius.circular(DsRadii.card),
          onTap: () => setState(() => _open = !_open),
          child: Padding(
            padding: const EdgeInsets.all(DsSpacing.space4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _kindLabel(l, idea.kind),
                  style: DsTextStyles.labelRitual.copyWith(
                    color: DsColors.textOnRitualMuted,
                  ),
                ),
                const SizedBox(height: DsSpacing.space2),
                Text(
                  idea.title,
                  style: DsTextStyles.displayRitual.copyWith(
                    color: DsColors.textOnRitualPrimary,
                    fontSize: 19,
                    height: 25 / 19,
                  ),
                ),
                const SizedBox(height: DsSpacing.space2),
                Text(
                  idea.purpose,
                  style: DsTextStyles.bodySecondary.copyWith(
                    color: DsColors.textOnRitualSecondary,
                    fontSize: todaySupportSize,
                    height: todaySupportHeight,
                  ),
                ),
                if (_open) ...[
                  const SizedBox(height: DsSpacing.space3),
                  Text(
                    idea.detail,
                    style: DsTextStyles.bodySecondary.copyWith(
                      color: DsColors.textOnRitualMuted,
                      fontSize: todaySupportSize,
                      height: todaySupportHeight,
                    ),
                  ),
                  // Only an expectation can be asked for. A ritual or a
                  // check-in is something you do, and offering "ask for this"
                  // on one would send it somewhere that cannot hold it.
                  if (widget.onUse != null && idea.kind == 'EXPECTATION') ...[
                    const SizedBox(height: DsSpacing.space4),
                    SecondaryButton(
                      label: l.exploreAskForThis,
                      onTap: () => widget.onUse!(idea),
                    ),
                  ],
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

String _kindLabel(L l, String kind) => switch (kind) {
  'EXPECTATION' => l.exploreKindExpectation,
  'RITUAL' => l.exploreKindRitual,
  'CHECK_IN' => l.exploreKindCheckIn,
  // A new server kind must not put its enum in front of a person.
  _ => l.exploreKindOther,
};
