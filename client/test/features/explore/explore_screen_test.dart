import 'package:ds_relationship_companion/ds_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dsapp/app/providers.dart';
import 'package:dsapp/domain_client/models/explore_view.dart';
import 'package:dsapp/domain_client/repositories/explore_repository.dart';
import 'package:dsapp/features/explore/presentation/explore_screen.dart';
import 'package:dsapp/l10n/app_localizations.dart';

class _FakeExplore implements ExploreRepository {
  _FakeExplore(this.result);
  final ExploreLibraryView result;

  @override
  Future<ExploreLibraryView> library() async => result;

  @override
  dynamic noSuchMethod(Invocation i) => throw UnimplementedError();
}

const _library = ExploreLibraryView(
  collections: [
    ExploreCollection(
      id: 'presence',
      title: 'Being present',
      blurb: 'Small ways to be reachable to each other.',
    ),
    ExploreCollection(
      id: 'empty',
      title: 'Nothing here',
      blurb: 'A collection the server sent no ideas for.',
    ),
  ],
  ideas: [
    ExploreIdea(
      id: 'one-message',
      kind: 'EXPECTATION',
      title: "Send one message that isn't logistics",
      purpose: 'Something that is only about the two of you.',
      detail: 'No plans, no groceries, no scheduling.',
      collectionId: 'presence',
    ),
    ExploreIdea(
      id: 'evening',
      kind: 'RITUAL',
      title: 'Evening check-in',
      purpose: 'A regular place to say how the day went.',
      detail: 'Same time, most days.',
      collectionId: 'presence',
    ),
  ],
);

Future<List<ExploreIdea>> _pump(
  WidgetTester tester, {
  ExploreLibraryView library = _library,
}) async {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  final used = <ExploreIdea>[];
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        exploreRepositoryProvider.overrideWithValue(_FakeExplore(library)),
      ],
      child: MaterialApp(
          localizationsDelegates: L.localizationsDelegates,
          supportedLocales: L.supportedLocales,
        theme: DsTheme.ritual(),
        home: ExploreScreen(dynamicId: 'dyn-1', onUse: used.add),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return used;
}

void main() {
  testWidgets('ideas are shown, and are not about you', (tester) async {
    // The full Explore is Public MVP. What Core Beta permits is a restrained
    // library — no personalisation, no recommendation, nothing implying the
    // app has an opinion about this particular pair.
    await _pump(tester);
    expect(find.text('Being present'), findsOneWidget);
    expect(find.text("Send one message that isn't logistics"), findsOneWidget);
    expect(
      find.textContaining('Nothing here is a suggestion about you'),
      findsOneWidget,
    );
  });

  testWidgets('a collection with no ideas is not shown', (tester) async {
    // An empty heading reads as something having failed to load.
    await _pump(tester);
    expect(find.text('Nothing here'), findsNothing);
  });

  testWidgets('only an expectation can be asked for', (tester) async {
    // A ritual is something you do, not something to ask of someone; sending
    // one to the Ask screen would put it somewhere that cannot hold it.
    final used = await _pump(tester);

    await tester.tap(find.text('Evening check-in'));
    await tester.pumpAndSettle();
    expect(find.text('Ask for this'), findsNothing);

    await tester.tap(find.text("Send one message that isn't logistics"));
    await tester.pumpAndSettle();
    expect(find.text('Ask for this'), findsOneWidget);

    await tester.tap(find.text('Ask for this'));
    await tester.pumpAndSettle();
    expect(used.single.id, 'one-message');
  });

  testWidgets('detail is behind a tap, not stacked sixteen deep', (
    tester,
  ) async {
    await _pump(tester);
    expect(find.text('No plans, no groceries, no scheduling.'), findsNothing);

    await tester.tap(find.text("Send one message that isn't logistics"));
    await tester.pumpAndSettle();
    expect(find.text('No plans, no groceries, no scheduling.'), findsOneWidget);
  });

  testWidgets('an unknown kind never shows its enum', (tester) async {
    await _pump(
      tester,
      library: const ExploreLibraryView(
        collections: [
          ExploreCollection(id: 'c', title: 'C', blurb: 'b'),
        ],
        ideas: [
          ExploreIdea(
            id: 'x',
            kind: 'SOME_NEW_KIND',
            title: 'A new sort of thing',
            purpose: 'p',
            detail: 'd',
            collectionId: 'c',
          ),
        ],
      ),
    );
    expect(find.text('AN IDEA'), findsOneWidget);
    expect(find.textContaining('SOME_NEW_KIND'), findsNothing);
  });

  testWidgets('an empty library says nothing is missing from the day', (
    tester,
  ) async {
    await _pump(tester, library: const ExploreLibraryView());
    expect(
      find.textContaining('Today holds everything that is waiting'),
      findsOneWidget,
    );
  });
}
