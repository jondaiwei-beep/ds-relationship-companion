import 'package:dio/dio.dart';
import 'package:dsapp/app/providers.dart';
import 'package:dsapp/domain_client/models/invite_view.dart';
import 'package:dsapp/domain_client/repositories/invite_repository.dart';
import 'package:dsapp/features/invite/presentation/join_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeInvites implements InviteRepository {
  _FakeInvites({this.view, this.resolveThrows, this.joinThrows});

  final InviteView? view;
  final Object? resolveThrows;
  final DioException? joinThrows;
  var joinCalls = 0;

  @override
  Future<InviteView> resolve(String token) async {
    if (resolveThrows case final e?) throw e;
    return view!;
  }

  @override
  Future<String> join(String token, {required String idempotencyKey}) async {
    joinCalls++;
    if (joinThrows case final e?) throw e;
    return 'membership-1';
  }

  @override
  Object noSuchMethod(Invocation i) => throw UnimplementedError('${i.memberName}');
}

DioException _status(int code) => DioException(
      requestOptions: RequestOptions(path: '/v1/invites/join'),
      response: Response(
        requestOptions: RequestOptions(path: '/v1/invites/join'),
        statusCode: code,
      ),
      type: DioExceptionType.badResponse,
    );

InviteView _view(InviteState state, {String? inviter = 'Morgan'}) => InviteView(
      state: state,
      inviteId: 'inv-1',
      dynamicId: 'dyn-1',
      inviterDisplayName: inviter,
    );

void main() {
  Future<({List<String> joined, List<int> signIn, _FakeInvites repo})> pump(
    WidgetTester tester, {
    InviteView? view,
    Object? resolveThrows,
    DioException? joinThrows,
  }) async {
    final repo = _FakeInvites(
      view: view,
      resolveThrows: resolveThrows,
      joinThrows: joinThrows,
    );
    final container = ProviderContainer(
      overrides: [inviteRepositoryProvider.overrideWithValue(repo)],
    );
    addTearDown(container.dispose);
    final joined = <String>[];
    final signIn = <int>[];
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          home: JoinScreen(
            token: 'tok-1',
            onJoined: joined.add,
            onDecline: () {},
            onSignIn: () => signIn.add(1),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    return (joined: joined, signIn: signIn, repo: repo);
  }

  group('opening a link is not joining', () {
    testWidgets('resolving alone never calls join', (tester) async {
      final r = await pump(tester, view: _view(InviteState.pending));

      // Mail scanners and link previews issue requests. Only an explicit
      // human action joins.
      expect(r.repo.joinCalls, 0);
      expect(find.text('Review and join'), findsOneWidget);
    });
  });

  group('a dead link explains itself, never 404s', () {
    testWidgets('expired says so, and that nothing was joined', (tester) async {
      await pump(tester, view: _view(InviteState.expired));

      expect(find.textContaining('has expired'), findsOneWidget);
      expect(find.text('You have not joined anything.'), findsOneWidget);
      // REQ-INVITE-001: no Dynamic content leaks through a dead link.
      expect(find.textContaining('Morgan'), findsNothing);
    });

    testWidgets('revoked and not-found are indistinguishable', (tester) async {
      await pump(tester, view: _view(InviteState.revoked));
      final revoked = find.textContaining('no longer available');
      expect(revoked, findsOneWidget);

      await pump(tester, view: _view(InviteState.notFound, inviter: null));
      expect(find.textContaining('no longer available'), findsOneWidget);

      // Telling them apart would say whether an invitation ever existed —
      // a fact about someone's private life, to whoever holds the URL.
      expect(find.textContaining('revoked'), findsNothing);
      expect(find.textContaining('not found'), findsNothing);
    });
  });

  group('the inviter is named, and nothing else is', () {
    testWidgets('a pending invite shows who, and the boundary', (tester) async {
      await pump(tester, view: _view(InviteState.pending));

      expect(find.text('Morgan'), findsOneWidget);
      expect(find.text('SHARED TOGETHER'), findsOneWidget);
      expect(find.text('STAYS YOURS'), findsOneWidget);
      // Merged from SCR-11, whose contract says not to build it separately.
      expect(
        find.textContaining('not consent to future expectations'),
        findsOneWidget,
      );
    });

    testWidgets('an invite with no name does not invent a relationship', (
      tester,
    ) async {
      await pump(tester, view: _view(InviteState.pending, inviter: null));

      // Never "your partner": this person is not yet anyone's partner, and
      // the app does not name a relationship nobody has agreed to.
      expect(find.textContaining('partner'), findsNothing);
      expect(find.text('Someone'), findsOneWidget);
    });
  });

  group('unreachable is not the same as dead', () {
    testWidgets('a failed resolve says the status is unknown', (tester) async {
      await pump(tester, resolveThrows: _status(500));

      // Saying "expired" here would tell someone their partner revoked
      // something when the truth is their train went into a tunnel.
      expect(find.textContaining("couldn't check"), findsOneWidget);
      // Not "not expired" — that asserts something we do not know either.
      expect(find.textContaining('No join was attempted'), findsOneWidget);
      expect(find.textContaining('expired'), findsNothing);
      expect(find.text('Try again'), findsOneWidget);
    });
  });

  group('joining', () {
    testWidgets('a 401 sends them to sign in rather than reporting a fault', (
      tester,
    ) async {
      final r = await pump(
        tester,
        view: _view(InviteState.pending),
        joinThrows: _status(401),
      );
      await tester.tap(find.text('Review and join'));
      await tester.pumpAndSettle();

      // This page is public on purpose, so arriving without a session is the
      // expected path, not an error.
      expect(
        r.signIn,
        hasLength(1),
        reason: 'a 401 here is the expected path, not a fault to report',
      );
      expect(find.textContaining("couldn't complete"), findsNothing);
    });

    testWidgets('success reports the Dynamic from the resolve', (tester) async {
      final r = await pump(tester, view: _view(InviteState.pending));
      await tester.tap(find.text('Review and join'));
      await tester.pumpAndSettle();

      expect(r.repo.joinCalls, 1);
      expect(r.joined, ['dyn-1']);
    });

    testWidgets('a terminal refusal re-asks the server', (tester) async {
      final r = await pump(
        tester,
        view: _view(InviteState.pending),
        joinThrows: _status(409),
      );
      await tester.tap(find.text('Review and join'));
      await tester.pumpAndSettle();

      // The invitation changed under them while the page was open, so the
      // screen re-resolves rather than guessing which ending it reached.
      expect(r.repo.joinCalls, 1);
    });
  });

  testWidgets('every state fits 390x844', (tester) async {
    for (final state in InviteState.values) {
      await pump(tester, view: _view(state));
      expect(tester.takeException(), isNull, reason: '${state.name} overflowed');
    }
    await pump(tester, resolveThrows: _status(500));
    expect(tester.takeException(), isNull);
  });
}
