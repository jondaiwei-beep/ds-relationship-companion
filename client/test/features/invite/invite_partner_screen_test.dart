import 'package:dio/dio.dart';
import 'package:dsapp/app/providers.dart';
import 'package:dsapp/l10n/app_localizations.dart';
import 'package:dsapp/domain_client/repositories/invite_repository.dart';
import 'package:dsapp/features/invite/presentation/invite_partner_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeInvites implements InviteRepository {
  _FakeInvites({this.createThrows, this.revokeThrows, this.expiresIn});

  final DioException? createThrows;
  final DioException? revokeThrows;
  final Duration? expiresIn;
  var creates = 0;
  final revokedIds = <String>[];

  @override
  Future<CreatedInvite> create(
    String dynamicId, {
    required String idempotencyKey,
  }) async {
    creates++;
    if (createThrows case final e?) throw e;
    return CreatedInvite(
      inviteId: 'inv-1',
      token: 'ritual-7k4m',
      url: 'https://ds.example.com/invite/ritual-7k4m',
      expiresAt: DateTime.now().add(expiresIn ?? const Duration(days: 6)),
    );
  }

  @override
  Future<void> revoke(
    String dynamicId,
    String inviteId, {
    required String idempotencyKey,
  }) async {
    revokedIds.add(inviteId);
    if (revokeThrows case final e?) throw e;
  }

  @override
  Object noSuchMethod(Invocation i) => throw UnimplementedError('${i.memberName}');
}

DioException _conflict(String code) => DioException(
      requestOptions: RequestOptions(path: '/v1/dynamics/d/invites'),
      response: Response(
        requestOptions: RequestOptions(path: '/v1/dynamics/d/invites'),
        statusCode: 409,
        data: {'code': code},
      ),
      type: DioExceptionType.badResponse,
    );

void main() {
  Future<_FakeInvites> pump(
    WidgetTester tester, {
    DioException? createThrows,
    DioException? revokeThrows,
    Duration? expiresIn,
  }) async {
    final repo = _FakeInvites(
      createThrows: createThrows,
      revokeThrows: revokeThrows,
      expiresIn: expiresIn,
    );
    final container = ProviderContainer(
      overrides: [inviteRepositoryProvider.overrideWithValue(repo)],
    );
    addTearDown(container.dispose);
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          localizationsDelegates: L.localizationsDelegates,
          supportedLocales: L.supportedLocales,
          home: InvitePartnerScreen(
            dynamicId: 'dyn-1',
            onDone: () {},
            onBack: () {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    return repo;
  }

  group('the expiry is the server\'s, never invented', () {
    testWidgets('it counts down from the real expiresAt', (tester) async {
      await pump(tester, expiresIn: const Duration(days: 3, hours: 2));

      // The design has a fixed "Expires in 6 days", which would be false for
      // six of the seven days it claims to describe.
      expect(find.text('Expires in 3 days'), findsOneWidget);
      expect(find.textContaining('6 days'), findsNothing);
    });

    testWidgets('an imminent expiry says hours, not a rounded day', (
      tester,
    ) async {
      // Five hours minus however long the test took: `inHours` truncates, so
      // asserting the exact number would make this fail on a slow machine.
      await pump(tester, expiresIn: const Duration(hours: 5, minutes: 30));

      expect(find.textContaining('Expires in 5 hours'), findsOneWidget);
      expect(find.textContaining('days'), findsNothing);
    });
  });

  group('one live invitation at a time', () {
    testWidgets('a second is explained, not silently retried', (tester) async {
      await pump(tester, createThrows: _conflict('INVITE_ALREADY_PENDING'));

      // The token comes back exactly once and only its hash is stored, so an
      // existing link genuinely cannot be shown again. Saying so beats
      // pretending to make one.
      expect(find.textContaining('already waiting'), findsOneWidget);
      expect(find.textContaining('shown only once'), findsOneWidget);
    });
  });

  group('withdrawing', () {
    testWidgets('it uses the id the server gave, not a guess', (tester) async {
      final repo = await pump(tester);
      await tester.tap(find.text('Revoke invitation'));
      await tester.pumpAndSettle();

      expect(repo.revokedIds, ['inv-1']);
      // And the screen stops offering a link it just withdrew.
      expect(find.textContaining('is closed'), findsOneWidget);
      expect(find.text('Create a new invitation'), findsOneWidget);
    });

    testWidgets('the closed state says nobody joined', (tester) async {
      await pump(tester);
      await tester.tap(find.text('Revoke invitation'));
      await tester.pumpAndSettle();

      // Withdrawing a link is not losing a partner, and the screen should not
      // leave anyone wondering.
      expect(find.textContaining('Nobody joined through it'), findsOneWidget);
    });
  });

  testWidgets('a failure keeps the screen usable', (tester) async {
    await pump(tester, createThrows: _conflict('SOMETHING_ELSE'));

    expect(find.textContaining("couldn't make"), findsOneWidget);
    // Retryable, and it says so with a control rather than a dead end.
    expect(find.text('Create a new invitation'), findsOneWidget);
  });

  testWidgets('every state fits 390x844', (tester) async {
    await pump(tester);
    expect(tester.takeException(), isNull);

    await pump(tester, createThrows: _conflict('INVITE_ALREADY_PENDING'));
    expect(tester.takeException(), isNull);

    await pump(tester, createThrows: _conflict('X'));
    expect(tester.takeException(), isNull);
  });
}
