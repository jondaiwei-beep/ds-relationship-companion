import 'package:dsapp/app/providers.dart';
import 'package:dsapp/domain_client/models/us_view.dart';
import 'package:dsapp/domain_client/models/weekly_reflection_view.dart';
import 'package:dsapp/domain_client/repositories/dynamic_repository.dart';
import 'package:dsapp/features/us/presentation/us_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _Repo extends Mock implements DynamicRepository {}

void main() {
  late _Repo repo;
  var adjusted = 0;
  var paused = 0;

  setUp(() {
    repo = _Repo();
    adjusted = 0;
    paused = 0;
  });

  Future<void> pump(WidgetTester tester, {required bool enoughHistory}) async {
    await tester.binding.setSurfaceSize(const Size(390, 1400));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    when(() => repo.us(any())).thenAnswer((_) async => const UsView());
    when(() => repo.weekly(any())).thenAnswer((_) async => WeeklyReflectionView(
          connectedDays: 3,
          hasEnoughHistory: enoughHistory,
        ));
    await tester.pumpWidget(ProviderScope(
      overrides: [dynamicRepositoryProvider.overrideWithValue(repo)],
      child: MaterialApp(
        home: UsScreen(
          dynamicId: 'd1',
          onAdjust: () => adjusted++,
          onPause: () => paused++,
        ),
      ),
    ));
    await tester.pumpAndSettle();
  }

  String allText(WidgetTester tester) => tester
      .widgetList<Text>(find.byType(Text))
      .map((t) => t.data ?? '')
      .join(' | ');

  group('The week ends in a real decision', () {
    testWidgets('adjust and pause are actions, not sentences', (tester) async {
      await pump(tester, enoughHistory: true);

      // Notion 06 §13.7: the user must be able to act on the reflection.
      // Naming the choice in copy while offering no control is not that.
      expect(find.text('Adjust it'), findsOneWidget);
      expect(find.text('Pause'), findsOneWidget);

      await tester.tap(find.text('Adjust it'));
      await tester.pumpAndSettle();
      expect(adjusted, 1);

      await tester.tap(find.text('Pause'));
      await tester.pumpAndSettle();
      expect(paused, 1);
    });

    testWidgets('keeping the rhythm is stated, not a button', (tester) async {
      await pump(tester, enoughHistory: true);

      // Keeping means changing nothing. A button that only dismisses would
      // be theatre, and would imply the week needs closing out.
      expect(allText(tester), contains('Keeping it as it is requires no change.'));
      expect(find.widgetWithText(ElevatedButton, 'Keep'), findsNothing);
    });

    testWidgets('no decision is offered before there is a week to reflect on',
        (tester) async {
      await pump(tester, enoughHistory: false);

      expect(find.text('Adjust it'), findsNothing);
      expect(find.text('Pause'), findsNothing);
    });

    testWidgets('an empty history does not swallow the reflection',
        (tester) async {
      // The reflection used to live inside the history branch, so an early
      // return on an empty list hid it silently. The two are computed over
      // different windows, so a week can be answered while the recent list
      // is empty.
      await pump(tester, enoughHistory: true);

      expect(find.text('Nothing here yet.'), findsOneWidget);
      expect(find.text('This past week'), findsOneWidget);
      expect(find.text('Adjust it'), findsOneWidget);
    });

    testWidgets('the decision is never framed as a verdict on the week',
        (tester) async {
      await pump(tester, enoughHistory: true);
      final text = allText(tester).toLowerCase();
      for (final banned in [
        'improve', 'better', 'worse', 'should', 'recommend', 'try harder',
        'fell short', 'on track',
      ]) {
        expect(text.contains(banned), isFalse,
            reason: 'the week is described, not graded: "$banned"');
      }
    });
  });
}
