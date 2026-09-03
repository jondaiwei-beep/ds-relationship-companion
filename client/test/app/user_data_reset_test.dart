import 'dart:convert';

import 'package:dsapp/app/providers.dart';
import 'package:dsapp/app/user_data_reset.dart';
import 'package:dsapp/features/dynamic/application/dynamic_providers.dart';
import 'package:dsapp/platform/session/session.dart';
import 'package:dsapp/platform/session/session_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/phase3_fakes.dart';

String _tokenFor(String userId) {
  String seg(String s) => base64Url.encode(utf8.encode(s)).replaceAll('=', '');
  return '${seg('{"alg":"none"}')}.${seg('{"sub":"$userId"}')}.x';
}

/// A session that can be switched from the test, the way signing out and a
/// second person signing in switches it on one phone.
class _SwitchableSession extends SessionController {
  @override
  Session build() => Authenticated(accessToken: _tokenFor('u-first'));

  void become(Session s) => state = s;
}

class _Root extends ConsumerStatefulWidget {
  const _Root();

  @override
  ConsumerState<_Root> createState() => _RootState();
}

class _RootState extends ConsumerState<_Root> {
  @override
  void initState() {
    super.initState();
    watchIdentityForReset(ref);
  }

  @override
  Widget build(BuildContext context) {
    // Keep the detail alive, the way a Today screen does.
    ref.watch(dynamicDetailProvider('dyn-1'));
    return const SizedBox();
  }
}

void main() {
  testWidgets('a different person signing in forgets what the last one loaded', (tester) async {
    final repo = FakeDynamicRepository();
    final session = _SwitchableSession();
    var fetches = 0;
    final container = ProviderContainer(
      overrides: [
        dynamicRepositoryProvider.overrideWithValue(repo),
        sessionProvider.overrideWith(() => session),
        dynamicDetailProvider.overrideWith((ref, id) async {
          fetches++;
          return repo.detail(id);
        }),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(container: container, child: const _Root()),
    );
    await tester.pump();
    expect(fetches, 1, reason: 'the first person loads the Dynamic once');

    // A token refresh for the same person changes nothing.
    session.become(Authenticated(accessToken: _tokenFor('u-first')));
    await tester.pump();
    expect(fetches, 1, reason: 'the same identity keeps its cache');

    // Sign out, then somebody else signs in.
    session.become(const SignedOut(reason: SignedOutReason.requested));
    await tester.pump();
    session.become(Authenticated(accessToken: _tokenFor('u-second')));
    await tester.pump();
    expect(fetches, greaterThanOrEqualTo(2), reason: 'a new identity re-reads everything');
  });
}
