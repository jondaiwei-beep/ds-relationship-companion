import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../design_system/components/ds_button.dart';
import '../../../design_system/components/ds_page.dart';
import '../../../design_system/components/ds_text.dart';
import '../../../design_system/tokens/colors.dart';
import '../../../design_system/tokens/spacing.dart';
import '../../../design_system/tokens/typography.dart';
import '../../../domain_client/repositories/auth_repository.dart';

/// Passwordless sign-in.
///
/// [returnTo] carries the continuation in the URL so it survives a Web refresh
/// and a magic-link callback opened in a new tab (Notion 04 §2).
class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key, this.returnTo});

  final String? returnTo;

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

/// Staging has no email sender, so a tester on a phone cannot receive the
/// link. With this flag the app completes the round trip itself: it requests
/// a link exactly as it always does, then asks the staging-only endpoint for
/// it and consumes it — so the tester sees the product rather than the
/// plumbing.
///
/// OFF unless explicitly compiled in, and it must stay off in production:
/// the endpoint it depends on is itself an authentication bypass and only
/// exists under the `staging` Spring profile.
///
/// PKCE is untouched — the link is still only completable with the verifier
/// this device generated.
const kStagingQuickSignIn = bool.fromEnvironment('STAGING_QUICK_SIGN_IN');

class _SignInScreenState extends ConsumerState<SignInScreen> {
  final _email = TextEditingController();
  var _sent = false;
  var _busy = false;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  /// If the user is signing in from an invite, pass the token so the server can
  /// record the continuation and return them to that invite afterwards.
  String? get _inviteToken {
    final r = widget.returnTo;
    if (r == null || !r.startsWith('/invite/')) return null;
    return r.substring('/invite/'.length);
  }

  /// Staging only: request a link and hand it straight to the normal
  /// callback route.
  ///
  /// This is the ordinary flow with the inbox step automated — same request,
  /// same PKCE verifier, same `/auth/callback` screen doing the consuming.
  /// Nothing about authentication is skipped, faked or duplicated here.
  Future<void> _quickSignIn() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    final typed = _email.text.trim();
    final email = typed.isEmpty ? 'you@staging.test' : typed;
    try {
      final flow = AuthFlow.start(returnTo: widget.returnTo);
      await ref.read(authFlowStoreProvider).save(flow);
      final auth = ref.read(authRepositoryProvider);
      await auth.requestMagicLink(
        email: email,
        flow: flow,
        inviteToken: _inviteToken,
      );

      final url = await auth.stagingLastLink(email);
      final parts = Uri.splitQueryString(Uri.parse(url).fragment);
      final token = parts['ml'];
      if (token == null) throw StateError('no token in the issued link');

      if (!mounted) return;
      // The same route a tapped link lands on — the verifier check, the
      // consume call and the redirect all stay in one place.
      context.go('/auth/callback#ml=$token&flow=${flow.flowId}');
    } catch (_) {
      if (mounted) {
        setState(() => _error = "Couldn't sign in. Is staging reachable?");
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _send() async {
    final email = _email.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      setState(() => _error = 'Enter the email address you want the link sent to.');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });

    final flow = AuthFlow.start(returnTo: widget.returnTo);
    try {
      // Save the verifier BEFORE requesting, so a fast callback cannot race it.
      await ref.read(authFlowStoreProvider).save(flow);
      await ref.read(authRepositoryProvider).requestMagicLink(
            email: email,
            flow: flow,
            inviteToken: _inviteToken,
          );
      if (mounted) setState(() => _sent = true);
    } catch (_) {
      if (mounted) {
        setState(() => _error = "We couldn't send that link. Please try again.");
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DsColors.canvas,
      body: DsPage(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: DsSpacing.xxxl),
            const DsAccentRule(),
            const SizedBox(height: DsSpacing.sm),
            Text(
              _sent ? 'Check your email.' : 'Build a dynamic\nthat stays present.',
              style: DsType.h1,
            ),
            const SizedBox(height: DsSpacing.lg),
            Text(
              _sent
                  ? 'We sent a sign-in link to ${_email.text.trim()}. '
                      'It works once and expires shortly.'
                  : "We'll email you a link. No password to remember.",
              style: DsType.body.copyWith(color: DsColors.muted),
            ),
            const SizedBox(height: DsSpacing.xxxl),
            if (!_sent) ...[
              TextField(
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                autocorrect: false,
                enabled: !_busy,
                style: DsType.body,
                onSubmitted: (_) => _send(),
                decoration: InputDecoration(
                  hintText: 'you@example.com',
                  hintStyle: DsType.body.copyWith(color: DsColors.muted),
                  enabledBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: DsColors.line),
                  ),
                ),
              ),
              if (_error != null) ...[
                const SizedBox(height: DsSpacing.lg),
                Text(
                  _error!,
                  style: DsType.fine.copyWith(color: DsColors.critical),
                ),
              ],
              const SizedBox(height: DsSpacing.xxl),
              DsButton(
                label: _busy ? 'Sending…' : 'Send sign-in link',
                onPressed: _busy ? null : _send,
              ),
              if (kStagingQuickSignIn) ...[
                const SizedBox(height: DsSpacing.lg),
                DsButton(
                  label: _busy ? 'Signing in…' : 'Staging: sign in now',
                  outline: true,
                  onPressed: _busy ? null : _quickSignIn,
                ),
              ],
            ] else
              DsButton(
                label: 'Use a different address',
                outline: true,
                onPressed: () => setState(() => _sent = false),
              ),
          ],
        ),
      ),
    );
  }
}
