import 'dart:async';

import 'package:dio/dio.dart';
import 'package:dsapp/app/home_resolver.dart';
import 'package:dsapp/app/providers.dart';
import 'package:dsapp/domain_client/models/dynamic_summary.dart';
import 'package:dsapp/domain_client/repositories/dynamic_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// `/today` has no dynamic id and cannot invent one. It used to pass the
/// literal string 'preview', the server answered "Invalid UUID string", and a
/// person who had just registered was told their day could not be loaded.
/// These tests were each checked by breaking the resolver.
class _FakeDynamics implements DynamicRepository {
  _FakeDynamics({this.result = const [], this.throws});

  final List<DynamicSummary> result;
  final Object? throws;
  int calls = 0;

  @override
  Future<List<DynamicSummary>> mine() async {
    calls++;
    if (throws case final e?) throw e;
    return result;
  }

  @override
  Object noSuchMethod(Invocation i) =>
      throw UnimplementedError('${i.memberName}');
}

DynamicSummary _summary(String id) =>
    DynamicSummary(dynamicId: id, state: 'ACTIVE', roleContext: 'CREATOR');

DioException _status(int code) => DioException(
      requestOptions: RequestOptions(path: '/v1/dynamics'),
      response: Response(
        requestOptions: RequestOptions(path: '/v1/dynamics'),
        statusCode: code,
      ),
      type: DioExceptionType.badResponse,
    );

void main() {
  // Lists, not counters. A record captures an `int` by value at return, so a
  // callback firing after the pump — which is the whole point of the Sign in
  // and Try again taps — would increment a copy nobody reads.
  Future<
      ({
        List<String> opened,
        List<void> noDynamic,
        List<void> signIn,
        _FakeDynamics repo,
      })> pump(WidgetTester tester, _FakeDynamics repo) async {
    final opened = <String>[];
    final noDynamic = <void>[];
    final signIn = <void>[];
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      ProviderScope(
        overrides: [dynamicRepositoryProvider.overrideWithValue(repo)],
        child: MaterialApp(
          home: HomeResolver(
            onDynamic: opened.add,
            onNoDynamic: () => noDynamic.add(null),
            onSignIn: () => signIn.add(null),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    return (opened: opened, noDynamic: noDynamic, signIn: signIn, repo: repo);
  }

  testWidgets('a fresh account is sent to activation, not to an error', (
    tester,
  ) async {
    final r = await pump(tester, _FakeDynamics());

    expect(r.noDynamic, hasLength(1));
    expect(r.opened, isEmpty);
    // Having no Dynamic yet is the ordinary state of someone who registered a
    // minute ago. Nothing on the way there may read as a failure.
    expect(find.textContaining("couldn't"), findsNothing);
  });

  testWidgets('an account with a dynamic opens it by id', (tester) async {
    final r = await pump(
      tester,
      _FakeDynamics(result: [_summary('d-1'), _summary('d-2')]),
    );

    expect(r.opened, ['d-1']);
    expect(r.noDynamic, isEmpty);
  });

  testWidgets('the id is the server\'s, never a placeholder', (tester) async {
    final r = await pump(tester, _FakeDynamics(result: [_summary('d-9')]));

    // The whole bug: 'preview' is not a UUID and never was one.
    expect(r.opened.single, 'd-9');
    expect(r.opened.single, isNot('preview'));
  });

  group('when the ask fails', () {
    testWidgets('a network failure offers another try, not a sign-out', (
      tester,
    ) async {
      final r = await pump(
        tester,
        _FakeDynamics(
          throws: DioException(
            requestOptions: RequestOptions(path: '/v1/dynamics'),
            type: DioExceptionType.connectionError,
          ),
        ),
      );

      expect(find.text('Try again'), findsOneWidget);
      expect(find.text('Sign in'), findsNothing);

      await tester.tap(find.text('Try again'));
      await tester.pumpAndSettle();
      expect(r.repo.calls, 2);
    });

    testWidgets('a lost session says so and offers the door', (tester) async {
      final r = await pump(tester, _FakeDynamics(throws: _status(401)));

      expect(find.text('Sign in'), findsOneWidget);
      expect(find.textContaining('Nothing was lost'), findsOneWidget);

      await tester.tap(find.text('Sign in'));
      await tester.pumpAndSettle();
      expect(r.signIn, hasLength(1));
    });

    testWidgets('nothing about the day is claimed while resolving', (
      tester,
    ) async {
      // Deliberately never completes: this is the frame the person actually
      // sees on a slow connection.
      final never = _NeverDynamics();
      await tester.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(
        ProviderScope(
          overrides: [dynamicRepositoryProvider.overrideWithValue(never)],
          child: MaterialApp(
            home: HomeResolver(
              onDynamic: (_) {},
              onNoDynamic: () {},
              onSignIn: () {},
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.textContaining('Opening your space'), findsOneWidget);
      // No skeleton shaped like a day's expectations, and no verdict either
      // way while the answer is unknown.
      expect(find.text('Try again'), findsNothing);
      expect(find.textContaining("couldn't"), findsNothing);
    });
  });
}

class _NeverDynamics implements DynamicRepository {
  @override
  Future<List<DynamicSummary>> mine() => Completer<List<DynamicSummary>>().future;

  @override
  Object noSuchMethod(Invocation i) =>
      throw UnimplementedError('${i.memberName}');
}
