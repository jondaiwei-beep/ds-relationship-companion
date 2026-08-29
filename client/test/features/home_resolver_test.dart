import 'package:dsapp/app/providers.dart';
import 'package:dsapp/domain_client/models/dynamic_summary.dart';
import 'package:dsapp/domain_client/repositories/dynamic_repository.dart';
import 'package:dsapp/features/activation/presentation/home_resolver.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _Repo extends Mock implements DynamicRepository {}

void main() {
  late _Repo repo;
  var opened = <String>[];
  var created = 0;

  setUp(() {
    repo = _Repo();
    opened = [];
    created = 0;
  });

  Future<void> pump(WidgetTester tester, List<DynamicSummary> mine) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    when(() => repo.mine()).thenAnswer((_) async => mine);
    await tester.pumpWidget(ProviderScope(
      overrides: [dynamicRepositoryProvider.overrideWithValue(repo)],
      child: MaterialApp(
        home: HomeResolver(
          onOpen: opened.add,
          onCreate: () => created++,
        ),
      ),
    ));
    await tester.pumpAndSettle();
  }

  String allText(WidgetTester tester) => tester
      .widgetList<Text>(find.byType(Text))
      .map((t) => t.data ?? '')
      .join(' | ');

  group('Landing after sign-in', () {
    testWidgets('a member with one dynamic is taken straight there',
        (tester) async {
      await pump(tester, const [
        DynamicSummary(dynamicId: 'd1', state: 'ACTIVE',
            roleContext: 'CREATOR', partnerDisplayName: 'Jamie'),
      ]);

      // The Core Beta case must not show a chooser at all.
      expect(opened, ['d1']);
    });

    testWidgets('a member with no dynamic gets a real next step, not a '
        'blank page', (tester) async {
      await pump(tester, const []);

      // This is the bug the owner hit: signing in landed on a screen with
      // only a greeting and no way forward.
      final text = allText(tester);
      expect(text, contains('Nothing here yet.'));
      expect(text, contains('invite them by link'));
      expect(find.text('Start a dynamic'), findsOneWidget);

      await tester.tap(find.text('Start a dynamic'));
      await tester.pumpAndSettle();
      expect(created, 1);
    });

    testWidgets('it also points at the other way in', (tester) async {
      await pump(tester, const []);
      // Most partners arrive by link, not by creating anything.
      expect(allText(tester),
          contains('If someone has already invited you'));
    });

    testWidgets('several dynamics are named by person, never by id',
        (tester) async {
      await pump(tester, const [
        DynamicSummary(dynamicId: 'd1', state: 'ACTIVE',
            roleContext: 'CREATOR', partnerDisplayName: 'Jamie'),
        DynamicSummary(dynamicId: 'd2', state: 'PAUSED',
            roleContext: 'PARTNER', partnerDisplayName: 'Sam'),
      ]);

      expect(find.text('With Jamie'), findsOneWidget);
      expect(find.text('With Sam'), findsOneWidget);
      expect(find.text('Paused'), findsOneWidget);
      expect(allText(tester).contains('d1'), isFalse);

      await tester.tap(find.text('With Sam'));
      await tester.pumpAndSettle();
      expect(opened, ['d2']);
    });

    testWidgets('a dynamic nobody has joined yet says so', (tester) async {
      await pump(tester, const [
        DynamicSummary(dynamicId: 'd1', state: 'PENDING_PARTNER',
            roleContext: 'CREATOR'),
        DynamicSummary(dynamicId: 'd2', state: 'ACTIVE',
            roleContext: 'PARTNER', partnerDisplayName: 'Sam'),
      ]);
      expect(find.text('Waiting for someone to join'), findsOneWidget);
    });

    testWidgets('a failure offers a way back, not a dead end', (tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      when(() => repo.mine()).thenThrow(Exception('offline'));
      await tester.pumpWidget(ProviderScope(
        overrides: [dynamicRepositoryProvider.overrideWithValue(repo)],
        child: MaterialApp(home: HomeResolver(onOpen: opened.add)),
      ));
      await tester.pumpAndSettle();

      expect(allText(tester), contains('Nothing was lost'));
      expect(find.text('Try again'), findsOneWidget);
    });
  });
}
