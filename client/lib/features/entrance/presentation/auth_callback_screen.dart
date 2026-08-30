import 'package:ds_relationship_companion/ds_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/shell/ds_primary_button.dart';
import '../../../platform/deeplink/callback_params.dart';
import '../application/auth_actions.dart';
import 'widgets/descending_thread.dart';
import 'widgets/trust_footer.dart';

/// The magic-link callback. Completes a sign-in the person started elsewhere.
///
/// This screen exists because SCR-05 promises a working link. It runs one
/// command and then leaves: there is nothing here to decide, and a person who
/// clicked a link in their inbox is not expecting a form.
///
/// The verifier never left the device that asked for the link, so a link
/// forwarded to someone else — or read out of an inbox — cannot authenticate
/// in a browser that did not start the flow. When the flow is unknown here,
/// that is exactly what happened, and it is refused without a request.
class AuthCallbackScreen extends ConsumerStatefulWidget {
  const AuthCallbackScreen({
    super.key,
    required this.onSignedIn,
    required this.onRequestNewLink,
    this.params,
  });

  final VoidCallback onSignedIn;
  final VoidCallback onRequestNewLink;

  /// Injected in tests and by the Android deep-link handler. On Web it is read
  /// from the browser URL, because the token travels in the fragment and
  /// `go_router` never sees it.
  final CallbackParams? params;

  @override
  ConsumerState<AuthCallbackScreen> createState() => _AuthCallbackScreenState();
}

class _AuthCallbackScreenState extends ConsumerState<AuthCallbackScreen> {
  String? _failure;
  bool _done = false;

  @override
  void initState() {
    super.initState();
    // After the first frame: `onSignedIn` navigates, and navigating during
    // build is a framework error.
    WidgetsBinding.instance.addPostFrameCallback((_) => _complete());
  }

  Future<void> _complete() async {
    final params = widget.params ?? CallbackParams.current();
    if (params == null) {
      // A callback with no token is a link that was truncated, rewritten by a
      // mail client, or opened from history after the fragment was dropped.
      setState(() {
        _failure = 'That link is incomplete. Request a new one.';
        _done = true;
      });
      return;
    }

    final outcome = await ref.read(authActionsProvider).completeSignInLink(
          token: params.token,
          flowId: params.flowId,
        );

    if (!mounted) return;
    switch (outcome) {
      case AuthSucceeded():
        setState(() => _done = true);
        widget.onSignedIn();
      case AuthFailed(:final message) || AuthUncertain(:final message):
        setState(() {
          _failure = message;
          _done = true;
        });
      case AuthLinkSent():
        setState(() {
          _failure = "We couldn't complete that sign-in. Request a new link.";
          _done = true;
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DsColors.canvasRitual,
      body: DsRitualSurface(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: DsSpacing.space6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 62),
                const DsSvg(
                  asset: DsAssets.markAuthority,
                  tone: DsAssetTone.primary,
                  width: 40,
                  height: 40,
                ),
                const SizedBox(height: DsSpacing.space5),
                Text(
                  _failure == null ? 'Signing you in' : 'Sign in',
                  textAlign: TextAlign.center,
                  style: DsTextStyles.labelRitual.copyWith(
                    color: DsColors.textOnRitualMuted,
                  ),
                ),
                const SizedBox(height: DsSpacing.space5),
                Text(
                  _failure == null
                      ? 'One moment.'
                      : 'This link is finished.',
                  textAlign: TextAlign.center,
                  style: DsTextStyles.displayRitual.copyWith(
                    color: DsColors.textOnRitualPrimary,
                  ),
                ),
                const SizedBox(height: DsSpacing.space5),
                Center(
                  child: DescendingThread(height: 96, glow: _done),
                ),
                const SizedBox(height: DsSpacing.space8),

                if (_failure case final failure?) ...[
                  Text(
                    failure,
                    textAlign: TextAlign.center,
                    style: DsTextStyles.bodySecondary.copyWith(
                      color: DsColors.textOnRitualSecondary,
                      height: 22 / 14,
                    ),
                  ),
                  const SizedBox(height: DsSpacing.space8),
                  DsPrimaryButton(
                    label: 'Request a new link',
                    onPressed: widget.onRequestNewLink,
                  ),
                ],

                const Spacer(),
                const TrustFooter(),
                const SizedBox(height: DsSpacing.space5),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
