import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../design_system/components/ds_button.dart';
import '../../../design_system/components/ds_page.dart';
import '../../../design_system/tokens/colors.dart';
import '../../../design_system/tokens/spacing.dart';
import '../../../design_system/tokens/typography.dart';

/// `/auth/callback` — completes the magic-link round trip.
///
/// The token arrives in the URL FRAGMENT (`#ml=…&flow=…`) so it is never sent
/// to the web server, never lands in access logs, and never leaks via Referer
/// (Notion 04 §2).
class AuthCallbackScreen extends ConsumerStatefulWidget {
  const AuthCallbackScreen({super.key, required this.token, required this.flowId});

  final String token;
  final String flowId;

  @override
  ConsumerState<AuthCallbackScreen> createState() => _AuthCallbackScreenState();
}

class _AuthCallbackScreenState extends ConsumerState<AuthCallbackScreen> {
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _consume());
  }

  Future<void> _consume() async {
    final store = ref.read(authFlowStoreProvider);
    final flow = await store.load(widget.flowId);

    if (flow == null) {
      // The verifier is missing: this browser did not start the flow. Do NOT
      // weaken the check — that is exactly the attack PKCE prevents.
      setState(() => _error =
          'This sign-in link was started somewhere else. '
          'Request a new link in this browser.');
      return;
    }

    try {
      final result = await ref.read(authRepositoryProvider).consume(
            token: widget.token,
            flow: flow,
            clientType: kIsWeb ? 'WEB' : 'ANDROID',
          );
      ref.read(authSessionProvider.notifier).signedIn(result.accessToken);

      if (!mounted) return;
      // Replace, so browser Back never returns to a live magic-token URL.
      context.go(flow.returnTo ?? '/today');
    } catch (_) {
      if (mounted) {
        setState(() => _error =
            'This sign-in link is no longer valid. Links work once and expire quickly.');
      }
    } finally {
      // Clear on EVERY outcome — success, failure, or expiry. The magic link
      // is single-use server-side, so the verifier has no further purpose and
      // must not linger in Web localStorage as a stale credential.
      await store.clear(widget.flowId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DsColors.canvas,
      body: DsPage(
        child: _error == null
            ? const Padding(
                padding: EdgeInsets.only(top: 120),
                child: Center(child: CircularProgressIndicator()),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: DsSpacing.xxxl),
                  Text('Sign-in link problem', style: DsType.h1),
                  const SizedBox(height: DsSpacing.lg),
                  Text(_error!, style: DsType.body.copyWith(color: DsColors.muted)),
                  const SizedBox(height: DsSpacing.xxxl),
                  DsButton(
                    label: 'Start again',
                    onPressed: () => context.go('/sign-in'),
                  ),
                ],
              ),
      ),
    );
  }
}
