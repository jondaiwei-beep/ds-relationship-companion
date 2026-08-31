import 'dart:convert';

import 'package:ds_relationship_companion/ds_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dsapp/app/providers.dart';
import 'package:dsapp/domain_client/models/check_in_view.dart';
import 'package:dsapp/domain_client/models/dynamic_view.dart';
import 'package:dsapp/domain_client/repositories/check_in_repository.dart';
import 'package:dsapp/domain_client/repositories/dynamic_repository.dart';
import 'package:dsapp/features/checkin/presentation/check_in_screen.dart';
import 'package:dsapp/platform/session/session.dart';
import 'package:dsapp/platform/session/session_controller.dart';

class _FakeCheckInRepository implements CheckInRepository {
  int calls = 0;
  String? mood;
  String? energy;
  String? need;
  String? note;
  CheckInVisibility? visibility;
  final List<String> keys = [];
  bool fail = false;

  @override
  Future<void> create(
    String dynamicId, {
    String? mood,
    String? energy,
    String? need,
    String? note,
    required CheckInVisibility visibility,
    required String idempotencyKey,
  }) async {
    calls++;
    keys.add(idempotencyKey);
    if (fail) throw Exception('network');
    this.mood = mood;
    this.energy = energy;
    this.need = need;
    this.note = note;
    this.visibility = visibility;
  }

  @override
  dynamic noSuchMethod(Invocation i) => throw UnimplementedError();
}

class _FakeDynamicRepository implements DynamicRepository {
  _FakeDynamicRepository(this.result);
  final DynamicDetail result;

  @override
  Future<DynamicDetail> detail(String id) async => result;

  @override
  dynamic noSuchMethod(Invocation i) => throw UnimplementedError();
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
      accessState: 'ACTIVE',
    ),
  ],
);

String _tokenFor(String userId) {
  String seg(String s) => base64Url.encode(utf8.encode(s)).replaceAll('=', '');
  return '${seg('{"alg":"none"}')}.${seg('{"sub":"$userId"}')}.x';
}

class _FixedSession extends SessionController {
  _FixedSession(this._userId);
  final String? _userId;

  @override
  Session build() => _userId == null
      ? const SignedOut()
      : Authenticated(accessToken: _tokenFor(_userId));
}

Future<_FakeCheckInRepository> _pump(
  WidgetTester tester, {
  DynamicDetail detail = _paired,
  String? viewer = 'u-creator',
}) async {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  final checkIns = _FakeCheckInRepository();
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        checkInRepositoryProvider.overrideWithValue(checkIns),
        dynamicRepositoryProvider.overrideWithValue(
          _FakeDynamicRepository(detail),
        ),
        sessionProvider.overrideWith(() => _FixedSession(viewer)),
      ],
      child: MaterialApp(
        theme: DsTheme.ritual(),
        home: const CheckInScreen(dynamicId: 'dyn-1'),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return checkIns;
}

void main() {
  testWidgets('private is the default, and never chosen for you', (
    tester,
  ) async {
    // Notion 04 §3: visibility is explicit. Private is the only safe default
    // for something written before you know how it will read.
    final repo = await _pump(tester);
    expect(find.text('Only me'), findsOneWidget);

    await tester.tap(find.text('Low'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(repo.visibility, CheckInVisibility.private);
  });

  testWidgets('sharing says plainly that it cannot be undone', (tester) async {
    // The preview promises "You can change visibility later". The server has
    // no endpoint for that, so the screen must not imply it.
    final repo = await _pump(tester);
    await tester.tap(find.text('Share with Morgan'));
    await tester.pumpAndSettle();

    expect(find.textContaining('cannot be unshared'), findsOneWidget);
    expect(find.textContaining('change visibility later'), findsNothing);

    // 'Steady' is a label under both MOOD and ENERGY, so pick an unambiguous
    // one rather than depending on which comes first.
    await tester.tap(find.text('Tender'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(repo.visibility, CheckInVisibility.shared);
    expect(repo.mood, 'Tender');
  });

  testWidgets('one word is a complete check-in', (tester) async {
    // The acceptance criterion is that this is completable quickly. Requiring
    // all three prompts would make a bad day harder to report than a good one.
    final repo = await _pump(tester);
    await tester.tap(find.text('High'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(repo.calls, 1);
    expect(repo.energy, 'HIGH');
    expect(repo.mood, isNull);
    expect(repo.need, isNull);
  });

  testWidgets('energy is sent in the domain the column allows', (
    tester,
  ) async {
    // The check_ins.energy column is constrained to LOW/STEADY/HIGH. An
    // invented vocabulary ("Full", "Running low", "Empty") passed every widget
    // test and returned 500 from staging on save — the label a person reads
    // and the value the domain accepts are not the same thing.
    final repo = await _pump(tester);
    await tester.tap(find.text('Running low'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(repo.energy, 'LOW');
  });

  testWidgets('an empty check-in cannot be saved', (tester) async {
    final repo = await _pump(tester);
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(repo.calls, 0);
  });

  testWidgets('a choice can be taken back before saving', (tester) async {
    final repo = await _pump(tester);
    await tester.tap(find.text('Good'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Good'));
    await tester.pumpAndSettle();

    // Nothing selected again, so there is nothing to save.
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(repo.calls, 0);
  });

  testWidgets('no scores — the week is not measured', (tester) async {
    // REQ-WEEKLY-001's spirit applies here too: a number invites comparison
    // between days and between people.
    await _pump(tester);
    for (final n in ['1', '2', '3', '4', '5']) {
      expect(find.text(n), findsNothing);
    }
  });

  testWidgets('sharing is not offered when the partner cannot be named', (
    tester,
  ) async {
    // Better to withhold the option than to offer sharing with someone the
    // app cannot identify. Private still saves.
    final repo = await _pump(tester, viewer: null);
    expect(find.text('Share with Morgan'), findsNothing);

    // The option is inert rather than absent — the row still shows what the
    // choice would be — and tapping it changes nothing.
    await tester.tap(find.text('Share'));
    await tester.pumpAndSettle();
    expect(find.text('Only me'), findsOneWidget);

    await tester.tap(find.text('Low'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(repo.visibility, CheckInVisibility.private);
  });

  testWidgets('retrying a failed save is the same day, not a second one', (
    tester,
  ) async {
    final repo = await _pump(tester);
    repo.fail = true;

    await tester.tap(find.text('Low'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(find.textContaining('did not reach the server'), findsOneWidget);

    repo.fail = false;
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(repo.calls, 2);
    expect(repo.keys.first, repo.keys.last);
  });
}
