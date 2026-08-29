import 'package:dsapp/app/providers.dart';
import 'package:dsapp/domain_client/repositories/auth_repository.dart';
import 'package:dsapp/features/activation/presentation/sign_in_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';

class _Auth extends Mock implements AuthRepository {}

void main() {
  setUpAll(() => registerFallbackValue(AuthFlow.start()));

  testWidgets('quick sign-in requests a real link and routes to the '
      'normal callback', (tester) async {
    final auth = _Auth();
    AuthFlow? started;

    when(() => auth.requestMagicLink(
          email: any(named: 'email'),
          flow: any(named: 'flow'),
          inviteToken: any(named: 'inviteToken'),
        )).thenAnswer((i) async {
      started = i.namedArguments[#flow] as AuthFlow;
    });
    when(() => auth.stagingLastLink(any())).thenAnswer((_) async =>
        'https://staging.test/auth/callback#ml=ml1.TOKEN&flow=${started!.flowId}');

    var landedOn = '';
    final router = GoRouter(
      initialLocation: '/sign-in',
      routes: [
        GoRoute(path: '/sign-in', builder: (_, _) => const SignInScreen()),
        GoRoute(
          path: '/auth/callback',
          builder: (_, s) {
            landedOn = s.uri.toString();
            return const SizedBox.shrink();
          },
        ),
      ],
    );

    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(ProviderScope(
      overrides: [authRepositoryProvider.overrideWithValue(auth)],
      child: MaterialApp.router(routerConfig: router),
    ));
    await tester.pumpAndSettle();

    // The button only exists because this test binary was compiled with the
    // flag; a production build has no such control.
    if (!kStagingQuickSignIn) return;

    await tester.tap(find.text('Staging: sign in now'));
    await tester.pumpAndSettle();

    // A real link was requested — nothing is faked or bypassed client-side.
    verify(() => auth.requestMagicLink(
          email: any(named: 'email'),
          flow: any(named: 'flow'),
          inviteToken: any(named: 'inviteToken'),
        )).called(1);

    // It hands off to the SAME route a tapped link lands on, so the verifier
    // check and consume call stay in one place rather than being duplicated.
    expect(landedOn, contains('/auth/callback'));
    expect(landedOn, contains('ml=ml1.TOKEN'));
    expect(landedOn, contains('flow=${started!.flowId}'));

    // The screen must never consume the token itself.
    verifyNever(() => auth.consume(
        token: any(named: 'token'),
        flow: any(named: 'flow'),
        clientType: any(named: 'clientType')));
  });
}
