import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:ds_relationship_companion/ds_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dsapp/app/providers.dart';
import 'package:dsapp/domain_client/models/dynamic_view.dart';
import 'package:dsapp/domain_client/repositories/dynamic_repository.dart';
import 'package:dsapp/features/dynamic/presentation/dynamic_screen.dart';
import 'package:dsapp/platform/session/session.dart';
import 'package:dsapp/platform/session/session_controller.dart';

class _FakeDynamicRepository implements DynamicRepository {
  _FakeDynamicRepository(this._result);

  final Object _result;
  int pauseCalls = 0;
  int resumeCalls = 0;
  bool? lastLighter;

  @override
  Future<DynamicDetail> detail(String dynamicId) async {
    if (_result is DynamicDetail) return _result;
    throw _result;
  }

  @override
  Future<void> pause(String dynamicId, {required String idempotencyKey}) async {
    pauseCalls++;
  }

  @override
  Future<void> resume(
    String dynamicId, {
    bool lighter = false,
    required String idempotencyKey,
  }) async {
    resumeCalls++;
    lastLighter = lighter;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('${invocation.memberName} is not used here');
}

DynamicDetail _detail({
  String state = 'ACTIVE',
  DateTime? pausedAt,
  List<MemberView>? members,
  List<StructureItem>? structure,
}) => DynamicDetail(
  dynamicId: 'dyn-1',
  state: state,
  desiredOutcome: 'SERVICE',
  structureLevel: 'STEADY',
  referenceTimezone: 'Asia/Shanghai',
  dayBoundaryMinutes: 240,
  pausedAt: pausedAt,
  members:
      members ??
      const [
        MemberView(
          userId: 'u-creator',
          displayName: 'Alex',
          roleContext: 'CREATOR',
          rolePreset: 'SUBMISSIVE',
          accessState: 'ACTIVE',
        ),
        MemberView(
          userId: 'u-partner',
          displayName: 'Morgan',
          roleContext: 'PARTNER',
          rolePreset: 'DOMINANT',
          accessState: 'ACTIVE',
        ),
      ],
  structure: structure ?? const [],
);

/// An access token whose `sub` is [userId]. Only the payload is read, so the
/// header and signature can be anything.
String _tokenFor(String userId) {
  String seg(String s) =>
      base64Url.encode(utf8.encode(s)).replaceAll('=', '');
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

Future<_FakeDynamicRepository> _pump(
  WidgetTester tester,
  Object result, {
  String? viewer = 'u-creator',
}) async {
  // Assert against the reference viewport, not the 800x600 test default: the
  // bug this caught — Pause below the fold — only exists at phone height.
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  final repo = _FakeDynamicRepository(result);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        dynamicRepositoryProvider.overrideWithValue(repo),
        sessionProvider.overrideWith(() => _FixedSession(viewer)),
      ],
      child: MaterialApp(
        theme: DsTheme.ritual(),
        home: const DynamicScreen(dynamicId: 'dyn-1'),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return repo;
}

void main() {
  testWidgets('the current structure is read from the server, never inferred', (
    tester,
  ) async {
    await _pump(tester, _detail());
    expect(find.text('Service-led · mutually held'), findsOneWidget);
  });

  testWidgets('Agreement is absent from Core Beta', (tester) async {
    // The approved preview carries an "OPEN AGREEMENT" row, but the screen
    // package's alignment work removes Agreement from this tier. It is the
    // most prominent row in the composition, so its absence is the thing most
    // likely to be "fixed" back in by someone working from the image alone.
    await _pump(tester, _detail());
    expect(find.textContaining('AGREEMENT'), findsNothing);
  });

  testWidgets('no check-in time is shown, because the server reports none', (
    tester,
  ) async {
    // The preview shows "NEXT SHARED CHECK-IN · Sunday 8:30 PM". Check-ins are
    // written entries, not appointments — there is no such time to report, and
    // a plausible one rendered from nothing is the failure this screen cannot
    // recover from.
    await _pump(tester, _detail());
    expect(find.textContaining('CHECK-IN'), findsNothing);
  });

  testWidgets('either member may pause, and resuming comes back lighter', (
    tester,
  ) async {
    final repo = await _pump(tester, _detail());
    // Reachable without scrolling: agency you have to hunt for is not the
    // inviolable agency Notion 04 §4 describes.
    expect(find.text('Pause this Dynamic'), findsOneWidget);
    await tester.tap(find.text('Pause this Dynamic'));
    await tester.pumpAndSettle();
    expect(repo.pauseCalls, 1);

    final paused = await _pump(
      tester,
      _detail(state: 'PAUSED', pausedAt: DateTime.utc(2026, 8, 31)),
    );
    expect(find.text('PAUSED'), findsOneWidget);
    await tester.tap(find.text('Resume, lighter'));
    await tester.pumpAndSettle();
    expect(paused.resumeCalls, 1);
    expect(paused.lastLighter, isTrue, reason: 'Journey E: half the structure');
  });

  testWidgets('an unconfirmed session shows no partner, role or structure', (
    tester,
  ) async {
    await _pump(
      tester,
      DioException(
        requestOptions: RequestOptions(path: '/v1/dynamics/dyn-1'),
        response: Response(
          requestOptions: RequestOptions(path: '/v1/dynamics/dyn-1'),
          statusCode: 401,
        ),
      ),
    );

    expect(find.textContaining('Morgan'), findsNothing);
    expect(find.textContaining('Dominant'), findsNothing);
    expect(find.textContaining('Service-led'), findsNothing);
    expect(find.text('No protected content remains on this screen.'),
        findsOneWidget);
  });

  testWidgets('offline says pause is unavailable rather than failing quietly', (
    tester,
  ) async {
    await _pump(
      tester,
      DioException(
        requestOptions: RequestOptions(path: '/v1/dynamics/dyn-1'),
        type: DioExceptionType.connectionError,
      ),
    );
    expect(find.textContaining('could not be confirmed'), findsOneWidget);
    expect(find.text('Pause this Dynamic'), findsNothing);
  });

  testWidgets('the partner sees the creator opposite, not themselves', (
    tester,
  ) async {
    // Reported from a device: signed in as the partner, the header read
    // "<myself> is present" and both halves of the pair showed the same name.
    // The members list is CREATOR-first whatever the caller's role, so reading
    // members.first as "me" made the viewer their own partner.
    await _pump(tester, _detail(), viewer: 'u-partner');

    expect(find.text('ALEX'), findsOneWidget, reason: 'the other person');
    expect(find.text('Alex is present'), findsOneWidget);
    expect(find.textContaining('MORGAN'), findsNothing,
        reason: 'the viewer is YOU, never named opposite themselves');
    expect(find.text('Dominant'), findsOneWidget, reason: "the viewer's role");
  });

  testWidgets('the creator sees the partner opposite', (tester) async {
    await _pump(tester, _detail(), viewer: 'u-creator');
    expect(find.text('MORGAN'), findsOneWidget);
    expect(find.text('Morgan is present'), findsOneWidget);
  });

  testWidgets('an unreadable session claims no presence at all', (
    tester,
  ) async {
    // The router does not route a signed-out person here, so this is the
    // degenerate case rather than a designed state. What matters is only that
    // no name is claimed: naming the wrong person as your partner is worse
    // than naming nobody, and worse than showing nothing.
    await _pump(tester, _detail(), viewer: null);
    expect(find.textContaining('is present'), findsNothing);
    expect(find.text('ALEX'), findsNothing);
    expect(find.text('MORGAN'), findsNothing);
  });

  testWidgets('a partner who has not joined is not implied to be there', (
    tester,
  ) async {
    await _pump(
      tester,
      _detail(
        members: const [
          MemberView(
            userId: 'u-creator',
            displayName: 'Alex',
            roleContext: 'CREATOR',
            accessState: 'ACTIVE',
          ),
        ],
      ),
    );
    expect(find.text('NO ONE YET'), findsOneWidget);
  });

  testWidgets('every state fits 390x844 without overflow', (tester) async {
    await _pump(
      tester,
      _detail(
        structure: const [
          StructureItem(
            definitionId: 'd1',
            kind: 'RITUAL',
            title: 'Evening check-in',
            active: true,
          ),
        ],
      ),
    );
    expect(tester.takeException(), isNull);
  });
}
