import 'dart:convert';

import 'package:ds_relationship_companion/ds_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dsapp/app/providers.dart';
import 'package:dsapp/domain_client/models/dynamic_view.dart';
import 'package:dsapp/domain_client/repositories/dynamic_repository.dart';
import 'package:dsapp/domain_client/repositories/expectation_repository.dart';
import 'package:dsapp/features/expectation/presentation/create_expectation_screen.dart';
import 'package:dsapp/platform/session/session.dart';
import 'package:dsapp/platform/session/session_controller.dart';

class _FakeDynamicRepository implements DynamicRepository {
  _FakeDynamicRepository(this.detailResult);

  final DynamicDetail detailResult;

  @override
  Future<DynamicDetail> detail(String dynamicId) async => detailResult;

  @override
  dynamic noSuchMethod(Invocation i) => throw UnimplementedError();
}

class _FakeExpectationRepository implements ExpectationRepository {
  int calls = 0;
  String? lastTitle;
  String? lastPurpose;
  String? lastAssignee;
  DateTime? lastDueAt;
  final List<String> keys = [];
  bool fail = false;

  @override
  Future<String> create(
    String dynamicId, {
    required String title,
    String? purpose,
    required String assigneeUserId,
    DateTime? dueAt,
    required String idempotencyKey,
  }) async {
    calls++;
    keys.add(idempotencyKey);
    if (fail) throw Exception('network');
    lastTitle = title;
    lastPurpose = purpose;
    lastAssignee = assigneeUserId;
    lastDueAt = dueAt;
    return 'occ-1';
  }

  @override
  dynamic noSuchMethod(Invocation i) => throw UnimplementedError();
}

String _tokenFor(String userId) {
  String seg(String s) => base64Url.encode(utf8.encode(s)).replaceAll('=', '');
  return '${seg('{"alg":"none"}')}.${seg('{"sub":"$userId"}')}.x';
}

class _FixedSession extends SessionController {
  _FixedSession(this._userId);
  final String _userId;

  @override
  Session build() => Authenticated(accessToken: _tokenFor(_userId));
}

const _paired = DynamicDetail(
  dynamicId: 'dyn-1',
  state: 'ACTIVE',
  desiredOutcome: 'SERVICE',
  structureLevel: 'STEADY',
  referenceTimezone: 'Asia/Shanghai',
  members: [
    MemberView(
      userId: 'u-creator',
      displayName: 'Alex',
      roleContext: 'CREATOR',
      accessState: 'ACTIVE',
    ),
    MemberView(
      userId: 'u-partner',
      displayName: 'Morgan',
      roleContext: 'PARTNER',
      rolePreset: 'SUBMISSIVE',
      accessState: 'ACTIVE',
    ),
  ],
);

const _solo = DynamicDetail(
  dynamicId: 'dyn-1',
  state: 'ACTIVE',
  desiredOutcome: 'SERVICE',
  structureLevel: 'STEADY',
  referenceTimezone: 'Asia/Shanghai',
  members: [
    MemberView(
      userId: 'u-creator',
      displayName: 'Alex',
      roleContext: 'CREATOR',
      accessState: 'ACTIVE',
    ),
  ],
);

Future<_FakeExpectationRepository> _pump(
  WidgetTester tester, {
  DynamicDetail detail = _paired,
  String viewer = 'u-creator',
}) async {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  final expectations = _FakeExpectationRepository();
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        dynamicRepositoryProvider.overrideWithValue(
          _FakeDynamicRepository(detail),
        ),
        expectationRepositoryProvider.overrideWithValue(expectations),
        sessionProvider.overrideWith(() => _FixedSession(viewer)),
      ],
      child: MaterialApp(
        theme: DsTheme.ritual(),
        home: const CreateExpectationScreen(dynamicId: 'dyn-1'),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return expectations;
}

void main() {
  testWidgets('it is addressed to the other person, never to yourself', (
    tester,
  ) async {
    final repo = await _pump(tester, viewer: 'u-creator');
    expect(find.text('For Morgan'), findsOneWidget);

    await tester.enterText(find.byType(TextField).first, 'Prepare the room');
    await tester.tap(find.text('Send'));
    await tester.pumpAndSettle();

    expect(repo.lastAssignee, 'u-partner');
  });

  testWidgets('the partner asking addresses the creator', (tester) async {
    final repo = await _pump(tester, viewer: 'u-partner');
    expect(find.text('For Alex'), findsOneWidget);

    await tester.enterText(find.byType(TextField).first, 'Say how it went');
    await tester.tap(find.text('Send'));
    await tester.pumpAndSettle();

    expect(repo.lastAssignee, 'u-creator');
  });

  testWidgets('no proof, points or completion mode — removed from Core Beta', (
    tester,
  ) async {
    // The alignment work says "remove Proof/photo option from Core Beta", and
    // the contract says "no Proof/points/punishment". The preview still shows
    // a COMPLETION row with a Photo choice, so this is the row most likely to
    // be added back by someone working from the image.
    await _pump(tester);
    expect(find.textContaining('Photo'), findsNothing);
    expect(find.textContaining('COMPLETION'), findsNothing);
    expect(find.textContaining('Proof'), findsNothing);
  });

  testWidgets('agency is stated as a fact, not offered as a toggle', (
    tester,
  ) async {
    // The preview has a BOUNDARY switch reading "They may pause or decline".
    // No server field backs it, so the switch would change nothing — a
    // promise about someone's agency that the system does not keep.
    await _pump(tester);
    expect(find.byType(Switch), findsNothing);
    expect(find.textContaining('BOUNDARY'), findsNothing);
    expect(
      find.textContaining('Morgan can complete this'),
      findsOneWidget,
      reason: 'the same fact, stated rather than switched',
    );
  });

  testWidgets('nothing is sent without saying what is being asked', (
    tester,
  ) async {
    final repo = await _pump(tester);
    await tester.tap(find.text('Send'));
    await tester.pumpAndSettle();

    expect(repo.calls, 0);
    expect(find.text('Say what you are asking for.'), findsOneWidget);
  });

  testWidgets('a due time is optional — anytime is a real answer', (
    tester,
  ) async {
    final repo = await _pump(tester);
    expect(find.text('Anytime'), findsOneWidget);

    await tester.enterText(find.byType(TextField).first, 'Standing intention');
    await tester.tap(find.text('Send'));
    await tester.pumpAndSettle();

    expect(repo.calls, 1);
    expect(repo.lastDueAt, isNull);
  });

  testWidgets('retrying a failed send is the same attempt, not a second ask', (
    tester,
  ) async {
    final repo = await _pump(tester);
    repo.fail = true;

    await tester.enterText(find.byType(TextField).first, 'Prepare the room');
    await tester.tap(find.text('Send'));
    await tester.pumpAndSettle();
    expect(find.textContaining('did not reach the server'), findsOneWidget);

    repo.fail = false;
    await tester.tap(find.text('Send'));
    await tester.pumpAndSettle();

    expect(repo.calls, 2, reason: 'two requests');
    expect(
      repo.keys.first,
      repo.keys.last,
      reason: 'one idempotency key, so the server records one ask',
    );
  });

  testWidgets('there is no one to ask before a partner joins', (tester) async {
    await _pump(tester, detail: _solo);
    expect(find.text('There is no one to ask yet.'), findsOneWidget);
    expect(find.text('Send'), findsNothing);
  });
}
