import 'package:ds_relationship_companion/ds_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dsapp/app/providers.dart';
import 'package:dsapp/features/today/application/today_providers.dart';
import 'package:dsapp/features/today/presentation/today_screen.dart';
import 'package:dsapp/l10n/app_localizations.dart';

import '../support/phase3_fakes.dart';
import '../support/today_fakes.dart';

/// Counts how many times the server was actually asked.
FakeTodayRepository _countingRepository() => FakeTodayRepository(
      view: sView(items: [occ(id: 'o1', title: 'Prepare the bedroom')]),
    );

Future<(ProviderContainer, FakeTodayRepository)> _pump(
  WidgetTester tester,
) async {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  final repo = _countingRepository();
  final container = ProviderContainer(
    overrides: [
      todayRepositoryProvider.overrideWithValue(repo),
      dynamicRepositoryProvider.overrideWithValue(FakeDynamicRepository()),
    ],
  );
  addTearDown(container.dispose);

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        theme: DsTheme.ritual(),
        localizationsDelegates: L.localizationsDelegates,
        supportedLocales: L.supportedLocales,
        home: const TodayScreen(dynamicId: 'dyn-1'),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return (container, repo);
}

void main() {
  // Reported from a device: every tap on the bottom bar refetched, so moving
  // between four tabs meant four loads of an app that already had the data.

  testWidgets('leaving a surface and coming back does not refetch', (
    tester,
  ) async {
    final (container, repo) = await _pump(tester);
    expect(repo.reads, 1, reason: 'the first open reads once');

    // What a tab switch does: the screen unmounts, and something else mounts.
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: DsTheme.ritual(),
          localizationsDelegates: L.localizationsDelegates,
          supportedLocales: L.supportedLocales,
          home: const SizedBox.shrink(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // And back.
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: DsTheme.ritual(),
          localizationsDelegates: L.localizationsDelegates,
          supportedLocales: L.supportedLocales,
          home: const TodayScreen(dynamicId: 'dyn-1'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      repo.reads,
      1,
      reason: 'the data was still there; nothing needed asking again',
    );
    expect(find.text('Prepare the bedroom'), findsOneWidget);
  });

  testWidgets('coming back shows the content immediately, with no spinner', (
    tester,
  ) async {
    // The visible half of the same fact: an autoDispose provider would have
    // rebuilt into its loading state before the data returned.
    final (container, _) = await _pump(tester);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: DsTheme.ritual(),
          localizationsDelegates: L.localizationsDelegates,
          supportedLocales: L.supportedLocales,
          home: const TodayScreen(dynamicId: 'dyn-1'),
        ),
      ),
    );
    // One frame only — no settle, so a loading state would still be on screen.
    await tester.pump();

    expect(find.text('Prepare the bedroom'), findsOneWidget);
    expect(find.text('RESOLVING TODAY'), findsNothing);
  });

  testWidgets('pulling down asks the server again', (tester) async {
    final (_, repo) = await _pump(tester);
    expect(repo.reads, 1);

    await tester.fling(find.byType(ListView), const Offset(0, 320), 1000);
    await tester.pumpAndSettle();

    expect(repo.reads, 2, reason: 'refreshing is how a person asks');
  });

  testWidgets('a command still re-reads, because the server decides', (
    tester,
  ) async {
    // Keeping data is not the same as trusting it forever. After a mutation
    // the client must not guess what changed.
    final (container, repo) = await _pump(tester);
    expect(repo.reads, 1);

    container.invalidate(todayProvider('dyn-1'));
    await tester.pumpAndSettle();

    expect(repo.reads, 2);
  });
}
