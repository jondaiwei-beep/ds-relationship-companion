import 'package:ds_relationship_companion/ds_design_system.dart';
import 'package:dsapp/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dsapp/app/providers.dart';
import 'package:dsapp/domain_client/models/us_view.dart';
import 'package:dsapp/domain_client/repositories/dynamic_repository.dart';
import 'package:dsapp/features/us/presentation/us_screen.dart';

class _FakeDynamicRepository implements DynamicRepository {
  _FakeDynamicRepository(this.result);
  final UsView result;

  @override
  Future<UsView> us(String id) async => result;

  @override
  dynamic noSuchMethod(Invocation i) => throw UnimplementedError();
}

Future<void> _pump(WidgetTester tester, UsView view) async {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        dynamicRepositoryProvider.overrideWithValue(
          _FakeDynamicRepository(view),
        ),
      ],
      child: MaterialApp(
        localizationsDelegates: L.localizationsDelegates,
        supportedLocales: L.supportedLocales,
        theme: DsTheme.ritual(),
        home: UsScreen(dynamicId: 'dyn-1', onWeekly: () {}),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('connected days are a count, never a rate or a target', (
    tester,
  ) async {
    // "4 of 7" turns a record into a report card, and makes an ordinary week
    // read as a shortfall.
    await _pump(tester, const UsView(connectedDays: 4));
    expect(find.text('4 days you both showed up.'), findsOneWidget);
    expect(find.textContaining('/'), findsNothing);
    expect(find.textContaining('%'), findsNothing);
  });

  testWidgets('no relationship score or profile', (tester) async {
    // "remove complex relationship scoring/profile emphasis" — and the server
    // reports no such number to render.
    await _pump(tester, const UsView(connectedDays: 3));
    expect(find.textContaining('Score'), findsNothing);
    expect(find.textContaining('score'), findsNothing);
    expect(find.byType(Slider), findsNothing);
  });

  testWidgets("an acknowledgement is shown as the person's own words", (
    tester,
  ) async {
    await _pump(
      tester,
      UsView(
        connectedDays: 1,
        moments: [
          RelationshipMoment(
            eventType: 'acknowledgement_sent',
            actorDisplayName: 'Morgan',
            occurredAt: DateTime.utc(2026, 8, 30),
            title: 'Prepare the room',
            text: 'Thank you — I noticed.',
          ),
        ],
      ),
    );
    expect(find.text('Morgan answered'), findsOneWidget);
    expect(find.text('“Thank you — I noticed.”'), findsOneWidget);
  });

  testWidgets('an unknown event type never leaks database vocabulary', (
    tester,
  ) async {
    // A new server event type must not put `some_new_event` in front of a
    // person.
    await _pump(
      tester,
      UsView(
        connectedDays: 1,
        moments: [
          RelationshipMoment(
            eventType: 'some_new_event',
            actorDisplayName: 'Morgan',
            occurredAt: DateTime.utc(2026, 8, 30),
          ),
        ],
      ),
    );
    expect(find.text('Something happened'), findsOneWidget);
    expect(find.textContaining('some_new_event'), findsNothing);
  });

  testWidgets('a wordless acknowledgement shows no empty quotation', (
    tester,
  ) async {
    // `text` defaults to "" on the server when someone acknowledges without
    // writing anything.
    await _pump(
      tester,
      UsView(
        connectedDays: 1,
        moments: [
          RelationshipMoment(
            eventType: 'acknowledgement_sent',
            actorDisplayName: 'Morgan',
            occurredAt: DateTime.utc(2026, 8, 30),
            title: 'Prepare the room',
            text: '',
          ),
        ],
      ),
    );
    expect(find.text('Morgan answered'), findsOneWidget);
    expect(find.text('“”'), findsNothing);
  });

  testWidgets('an empty history is not a failure', (tester) async {
    await _pump(tester, const UsView());
    expect(find.textContaining('nothing to catch up on'), findsOneWidget);
    expect(
      find.text('Nothing has landed on the same day yet.'),
      findsOneWidget,
    );
  });

  testWidgets('the week is reachable from here', (tester) async {
    // The alignment work asks for exactly one light D7 card.
    await _pump(tester, const UsView(connectedDays: 2));
    expect(find.text('This week'), findsOneWidget);
  });
}
