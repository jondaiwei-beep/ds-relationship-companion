import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../design_system/components/ds_button.dart';
import '../../../design_system/components/ds_text.dart';
import '../../../design_system/tokens/colors.dart';
import '../../../design_system/tokens/spacing.dart';
import '../../../design_system/tokens/typography.dart';
import '../../../domain_client/repositories/auth_repository.dart';

/// Signing in without leaving the page you were invited to.
///
/// Routing an invited partner to the generic sign-in screen showed them a
/// headline about building a dynamic — which is not what they were invited
/// to, from someone they trust, about something intimate. The threshold
/// belongs on the invitation itself.
///
/// **Authenticating is not joining.** This only establishes who you are; the
/// person comes back to the same invitation and decides separately. Opening
/// the link, requesting a sign-in email and completing it are all
/// non-joining operations (Notion 04 §2).
class InlineSignIn extends ConsumerStatefulWidget {
  const InlineSignIn({super.key, required this.returnTo, this.inviteToken});

  final String returnTo;
  final String? inviteToken;

  @override
  ConsumerState<InlineSignIn> createState() => _InlineSignInState();
}

class _InlineSignInState extends ConsumerState<InlineSignIn> {
  final _email = TextEditingController();
  var _sent = false;
  var _busy = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _email.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final email = _email.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      setState(() => _error = 'Enter the email you want the link sent to.');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    final flow = AuthFlow.start(returnTo: widget.returnTo);
    try {
      await ref.read(authFlowStoreProvider).save(flow);
      await ref.read(authRepositoryProvider).requestMagicLink(
            email: email,
            flow: flow,
            inviteToken: widget.inviteToken,
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
    if (_sent) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const DsEyebrow('Check your email'),
          const SizedBox(height: DsSpacing.md),
          Text(
            'We sent a link to ${_email.text.trim()}. Open it and you will '
            'come back here.',
            style: DsType.body.copyWith(color: DsColors.muted),
          ),
          const SizedBox(height: DsSpacing.md),
          GestureDetector(
            onTap: () => setState(() => _sent = false),
            behavior: HitTestBehavior.opaque,
            child: SizedBox(
              height: 44,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('Use a different address',
                    style: DsType.fine.copyWith(
                      color: DsColors.response,
                      fontWeight: FontWeight.w600,
                    )),
              ),
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const DsEyebrow('Continue privately'),
        const SizedBox(height: DsSpacing.md),
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
          const SizedBox(height: DsSpacing.md),
          Text(_error!, style: DsType.fine.copyWith(color: DsColors.critical)),
        ],
        const SizedBox(height: DsSpacing.xl),
        DsButton(
          label: _busy ? 'Sending…' : 'Send me a sign-in link',
          onPressed: _busy ? null : _send,
        ),
        const SizedBox(height: DsSpacing.md),
        Text(
          // The one thing this component must never be mistaken for.
          'Signing in does not join this space. You will come back here to '
          'decide.',
          style: DsType.fine.copyWith(color: DsColors.muted),
        ),
      ],
    );
  }
}
