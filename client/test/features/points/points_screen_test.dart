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
  _FakePoints({
    this.balance = 0,
    this.entries = const [],
    this.rewardList = const [],
    this.days = 0,
  });

  int balance;
  int days;
  List<PointEntry> entries;
  List<Reward> rewardList;
  final gifts = <String>[];
  final redeems = <String>[];
  final added = <String>[];
  final agreementsAdded = <String>[];
  List<ConsequenceAgreement> agreementList = const [];

  @override
  Future<PointsSummary> summary(String dynamicId, {String? subjectUserId}) async =>
      PointsSummary(balance: balance, entries: entries, daysTogether: days);

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
  Future<List<ConsequenceAgreement>> agreements(String dynamicId) async =>
      agreementList;

  @override
  Future<void> addReward(String dynamicId,
      {required String title, String? detail, required int cost}) async {
    added.add('$title/$cost');
  }

  @override
  Future<void> addAgreement(String dynamicId,
      {required String label,
      required String consequence,
      int pointCost = 0}) async {
    agreementsAdded.add('$label -> $consequence');
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

/// The screen grew past one viewport once rewards, agreements and history
/// all landed on it. `scrollUntilVisible` needs a single scrollable and this
/// screen nests them, so drag the outer list instead.
Future<void> _scrollToBottom(WidgetTester tester) async {
  await tester.binding.setSurfaceSize(const Size(390, 3000));
  await tester.pumpAndSettle();
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
          PointEntry(id: 'e1', amount: 1, reason: PointReason.taskEarn),
        ],
      ),
    );

    await _scrollToBottom(tester);
    expect(find.text('Alex noticed'), findsOneWidget);
    expect(find.textContaining('task_earn'), findsNothing);
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

  testWidgets('days together are shown, and said to be safe from a gap', (
    tester,
  ) async {
    // Every other app in this category has taught people that a number like
    // this is something you can lose in one bad day.
    await _pump(tester, _FakePoints(balance: 0, days: 12));

    expect(find.text('12 days together'), findsOneWidget);
    expect(
      find.text('This only ever goes up. A quiet day takes nothing away.'),
      findsOneWidget,
    );
    // Never the word that means the opposite of what this does.
    expect(find.textContaining('streak'), findsNothing);
  });

  testWidgets('a reward can be put on offer from the app', (tester) async {
    final repo = _FakePoints();
    await _pump(tester, repo);

    // The form is collapsed until asked for: an editing form sitting open
    // under "Nothing on offer yet" was two things competing in one block.
    await tester.tap(find.text('Put something on offer'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, 'Massage');
    await tester.tap(find.text('Put it on offer'));
    await tester.pumpAndSettle();

    expect(repo.added, ['Massage/1']);
  });

  testWidgets('adding a reward with no name says what is missing', (tester) async {
    // Invariant: the control says what is missing rather than going dead.
    final repo = _FakePoints();
    await _pump(tester, repo);

    await tester.tap(find.text('Put something on offer'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Put it on offer'));
    await tester.pumpAndSettle();

    expect(find.text('Say what it is first.'), findsOneWidget);
    expect(repo.added, isEmpty);
  });

  testWidgets('an agreement needs both halves, not just the consequence', (
    tester,
  ) async {
    // Their own writing: vague punishment "breeds resentment". An agreement
    // that names only what follows, without saying when, is the vague kind.
    final repo = _FakePoints();
    await _pump(tester, repo);

    await _scrollToBottom(tester);
    await tester.tap(find.text('Write an agreement'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Agree to this'));
    await tester.pumpAndSettle();

    expect(find.text('Say what happens, and what follows.'), findsOneWidget);
    expect(repo.agreementsAdded, isEmpty);
  });

  testWidgets('either partner can end an agreement, alone', (tester) async {
    final repo = _FakePoints()
      ..agreementList = const [
        ConsequenceAgreement(
          id: 'a1',
          label: 'The evening things do not get done',
          consequence: 'Early bedtime, one hour',
          pointCost: 2,
        ),
      ];
    await _pump(tester, repo);

    await _scrollToBottom(tester);
    // One match now: with the form collapsed, its example hint is not on
    // screen competing with the real agreement.
    expect(find.text('Early bedtime, one hour'), findsOneWidget);
    expect(find.text('The evening things do not get done'), findsOneWidget);
    expect(
      find.text('Either of you can end any of these, alone.'),
      findsOneWidget,
    );
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
