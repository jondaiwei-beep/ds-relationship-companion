import 'package:ds_relationship_companion/ds_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dsapp/app/providers.dart';
import 'package:dsapp/domain_client/models/points.dart';
import 'package:dsapp/domain_client/repositories/points_repository.dart';
import 'package:dsapp/features/points/presentation/points_screen.dart';
import 'package:dsapp/features/points/presentation/widgets/consequence_panel.dart';
import 'package:dsapp/l10n/app_localizations.dart';

class _FakePoints implements PointsRepository {
  _FakePoints({this.balance = 0, this.entries = const [], this.rewardList = const []});

  int balance;
  List<PointEntry> entries;
  List<Reward> rewardList;
  final gifts = <String>[];
  final redeems = <String>[];

  @override
  Future<PointsSummary> summary(String dynamicId, {String? subjectUserId}) async =>
      PointsSummary(balance: balance, entries: entries);

  @override
  Future<List<Reward>> rewards(String dynamicId, {String? subjectUserId}) async =>
      rewardList;

  @override
  Future<void> gift(String dynamicId, String rewardId, {required String subjectUserId}) async {
    gifts.add(rewardId);
  }

  @override
  Future<void> redeem(String dynamicId, String rewardId) async {
    redeems.add(rewardId);
  }

  @override
  dynamic noSuchMethod(Invocation i) => throw UnimplementedError('${i.memberName}');
}

Future<ProviderContainer> _pump(WidgetTester tester, _FakePoints repo) async {
  await tester.binding.setSurfaceSize(const Size(390, 844));
  addTearDown(() => tester.binding.setSurfaceSize(null));

  final container = ProviderContainer(
    overrides: [pointsRepositoryProvider.overrideWithValue(repo)],
  );
  addTearDown(container.dispose);

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        theme: DsTheme.ritual(),
        localizationsDelegates: L.localizationsDelegates,
        supportedLocales: L.supportedLocales,
        home: PointsScreen(
          dynamicId: 'dyn-1',
          onBack: () {},
          partnerName: 'Alex',
          partnerUserId: 'u-partner',
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return container;
}

void main() {
  // These defend product/design/points-with-authority-and-warmth.md. They are
  // not testing arithmetic — the backend does that — but the three rules that
  // make this different from the competitors.

  testWidgets('the balance reads as an inventory, never as a score', (tester) async {
    await _pump(tester, _FakePoints(balance: 3));

    // The number lives inside the phrase that says what it is for. A large
    // standalone numeral is the "score" reading this design avoids, whatever
    // the label under it says.
    expect(find.text('3 points to spend'), findsOneWidget);
    expect(find.text('3'), findsNothing, reason: 'never a bare digit');
    // Obedience shows a heart with a number beside it. A number next to an
    // affection symbol is a verdict on the person holding it.
    expect(find.textContaining('score'), findsNothing);
    expect(find.textContaining('earned'), findsNothing);
  });

  testWidgets('a zero balance says nothing to spend, never a negative', (tester) async {
    // Obedience showed -152: an affection account, overdrawn, with no reward
    // reachable and no move available but climbing out of a hole.
    await _pump(tester, _FakePoints(balance: 0));

    expect(find.text('Nothing to spend yet'), findsOneWidget);
    expect(find.textContaining('-'), findsNothing);
  });

  testWidgets('a negative from the server is still not rendered as debt', (tester) async {
    // Defence in depth: the server floors at zero, and the model clamps too,
    // so a bad payload cannot put someone in debt to their partner.
    final s = PointsSummary.fromJson(const {'balance': -152, 'entries': []});
    expect(s.balance, 0);
  });

  testWidgets('every entry names a person rather than a system event', (tester) async {
    await _pump(
      tester,
      _FakePoints(
        balance: 1,
        entries: const [
          PointEntry(id: 'e1', amount: 1, reason: PointReason.completion),
        ],
      ),
    );

    expect(find.text('Alex noticed'), findsOneWidget);
    expect(find.textContaining('COMPLETION'), findsNothing);
  });

  testWidgets('a reward can be given outright, without the partner affording it', (
    tester,
  ) async {
    // The feature none of the three competitors have. Giving must not be
    // gated on the receiver's balance — that would make it a purchase.
    final repo = _FakePoints(
      balance: 0,
      rewardList: const [
        Reward(id: 'r1', title: 'Massage', cost: 10, affordable: false),
      ],
    );
    await _pump(tester, repo);

    expect(find.text('Give it'), findsOneWidget);
    expect(find.text('Take it'), findsNothing, reason: 'they cannot afford it');
    expect(find.text('10 more to go'), findsOneWidget);

    await tester.tap(find.text('Give it'));
    await tester.pumpAndSettle();
    expect(repo.gifts, ['r1']);
  });

  testWidgets('letting go is not styled as the lesser option', (tester) async {
    // The design rule: mercy is one of two equal exercises of authority, so
    // both doors must render with the same treatment.
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        theme: DsTheme.ritual(),
        localizationsDelegates: L.localizationsDelegates,
        supportedLocales: L.supportedLocales,
        home: Scaffold(
          body: ConsequencePanel(
            agreement: const ConsequenceAgreement(
              id: 'a1',
              label: 'The evening things do not get done',
              consequence: 'Early bedtime, one hour',
              pointCost: 2,
            ),
            onHold: () {},
            onLetGo: () {},
            onTalk: () {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    Size sizeOf(String label) => tester.getSize(
      find.ancestor(of: find.text(label), matching: find.byType(Container)).first,
    );

    expect(sizeOf('Hold to it').width, sizeOf('Let it go').width,
        reason: 'mercy is not the smaller door');
    expect(sizeOf('Hold to it').height, sizeOf('Let it go').height);

    // And the app says plainly that it will not act on its own.
    expect(find.text('Nothing happens until you choose.'), findsOneWidget);
    // The couple's own words, quoted, not restated as a verdict.
    expect(find.text('Early bedtime, one hour'), findsOneWidget);
  });
}
