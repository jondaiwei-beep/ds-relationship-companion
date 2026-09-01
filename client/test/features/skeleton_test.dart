import 'dart:async';

import 'package:ds_relationship_companion/ds_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dsapp/app/providers.dart';
import 'package:dsapp/app/shell/ds_skeleton.dart';
import 'package:dsapp/domain_client/models/dynamic_view.dart';
import 'package:dsapp/domain_client/models/explore_view.dart';
import 'package:dsapp/domain_client/models/today_view.dart';
import 'package:dsapp/domain_client/models/us_view.dart';
import 'package:dsapp/domain_client/repositories/dynamic_repository.dart';
import 'package:dsapp/domain_client/repositories/explore_repository.dart';
import 'package:dsapp/domain_client/repositories/today_repository.dart';
import 'package:dsapp/features/dynamic/presentation/dynamic_screen.dart';
import 'package:dsapp/features/explore/presentation/explore_screen.dart';
import 'package:dsapp/features/today/presentation/today_screen.dart';
import 'package:dsapp/features/us/presentation/us_screen.dart';

/// A repository that never answers, so the loading state stays on screen.
class _Hanging implements TodayRepository, DynamicRepository, ExploreRepository {
  @override
  Future<TodayView> forDynamic(String id) => Completer<TodayView>().future;

  @override
  Future<DynamicDetail> detail(String id) => Completer<DynamicDetail>().future;

  @override
  Future<UsView> us(String id) => Completer<UsView>().future;

  @override
  Future<ExploreLibraryView> library() =>
      Completer<ExploreLibraryView>().future;

  @override
  dynamic noSuchMethod(Invocation i) => throw UnimplementedError();
}

Future<void> _pump(WidgetTester tester, Widget screen) async {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  final hanging = _Hanging();
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        todayRepositoryProvider.overrideWithValue(hanging),
        dynamicRepositoryProvider.overrideWithValue(hanging),
        exploreRepositoryProvider.overrideWithValue(hanging),
      ],
      child: MaterialApp(theme: DsTheme.ritual(), home: screen),
    ),
  );
  // One frame only: pumpAndSettle would wait for the pulse, which never ends.
  await tester.pump();
}

void main() {
  // Reported from a device: four surfaces, each showing one line of grey text
  // on an otherwise empty screen. The design system had asked for skeletons
  // from the start — every state matrix says "Skeleton/progress must preserve
  // privacy and layout stability" — and SCR-01's approved rev-2 loading state
  // renders exactly that.

  testWidgets('Today shows the shape of the day, not a sentence', (
    tester,
  ) async {
    await _pump(
      tester,
      const TodayScreen(dynamicId: 'dyn-1'),
    );
    expect(find.byType(DsSkeletonCard), findsWidgets);
    expect(find.text('Confirming today with the server.'), findsNothing);
    // The approved state explains the blankness rather than narrating a wait.
    expect(find.text('PRIVATE BY DEFAULT'), findsOneWidget);
  });

  testWidgets('Dynamic outlines the figure and rows, and no names', (
    tester,
  ) async {
    await _pump(tester, const DynamicScreen(dynamicId: 'dyn-1'));
    expect(find.byType(DsSkeletonCard), findsWidgets);
    expect(
      find.text('Confirming the current structure with the server.'),
      findsNothing,
    );
  });

  testWidgets('Us outlines the count and the moments', (tester) async {
    await _pump(tester, const UsScreen(dynamicId: 'dyn-1'));
    expect(find.byType(DsSkeletonCard), findsWidgets);
    expect(find.text('Reading what has happened so far.'), findsNothing);
  });

  testWidgets('Explore outlines the library', (tester) async {
    await _pump(tester, const ExploreScreen(dynamicId: 'dyn-1'));
    expect(find.byType(DsSkeletonCard), findsWidgets);
    expect(find.text('Fetching the library.'), findsNothing);
  });

  testWidgets('the bars are actually visible against their card', (
    tester,
  ) async {
    // The first attempt drew them in `surfaceRitualDisabled`, which is
    // byte-identical to the `surfaceRitualRaised` card behind them — every
    // bar was painted invisibly, and only the emphasis bar showed. The widget
    // tests all passed: `findsWidgets` cannot see colour. A screenshot could.
    await _pump(tester, const TodayScreen(dynamicId: 'dyn-1'));

    final card = tester.widget<Container>(
      find
          .descendant(
            of: find.byType(DsSkeletonCard).first,
            matching: find.byType(Container),
          )
          .first,
    );
    final cardColour = (card.decoration! as BoxDecoration).color;

    final bars = tester.widgetList<Container>(
      find.descendant(
        of: find.byType(DsSkeletonBar).first,
        matching: find.byType(Container),
      ),
    );
    for (final bar in bars) {
      final colour = (bar.decoration! as BoxDecoration).color;
      expect(
        colour,
        isNot(cardColour),
        reason: 'a bar the colour of its background is not a skeleton',
      );
    }
  });

  testWidgets('a skeleton is not read aloud', (tester) async {
    // It stands in for content it does not have. The surface announces its
    // own status in words; the bars must not be narrated as blanks.
    final handle = tester.ensureSemantics();
    await _pump(tester, const TodayScreen(dynamicId: 'dyn-1'));

    expect(
      find.byType(DsSkeletonBar).hitTestable(),
      findsWidgets,
      reason: 'the bars are on screen',
    );
    // Every bar sits under an ExcludeSemantics, so none of them reaches the
    // accessibility tree as an unlabelled node.
    expect(
      find.descendant(
        of: find.byType(DsSkeletonCard).first,
        matching: find.byType(ExcludeSemantics),
      ),
      findsWidgets,
    );
    handle.dispose();
  });

  testWidgets('reduce-motion still gets a legible skeleton', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        theme: DsTheme.ritual(),
        home: const MediaQuery(
          data: MediaQueryData(disableAnimations: true),
          child: Scaffold(
            body: DsSkeletonPulse(child: DsSkeletonCard(lines: [0.5, 0.8])),
          ),
        ),
      ),
    );
    await tester.pump();

    // Still rather than pulsing, and still visible. Asserted on the Opacity
    // this path renders: MaterialApp's page route brings FadeTransitions of
    // its own, so their absence is not the thing to check.
    expect(
      find.descendant(
        of: find.byType(DsSkeletonPulse),
        matching: find.byType(Opacity),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byType(DsSkeletonPulse),
        matching: find.byType(FadeTransition),
      ),
      findsNothing,
      reason: 'no pulse when the platform asks for reduced motion',
    );
    expect(find.byType(DsSkeletonCard), findsOneWidget);
  });
}
