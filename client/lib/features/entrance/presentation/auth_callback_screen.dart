import 'package:ds_relationship_companion/ds_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/shell/ds_primary_button.dart';
import '../../../l10n/app_localizations.dart';
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
  /// The sentence to show, named rather than written: this screen may be the
  /// first thing a person sees, opened from a mail client in whatever locale
  /// their device is set to.
  AuthMessage? _failure;

  bool _done = false;

  @override
  void initState() {
    super.initState();
    // After the first frame: `onSignedIn` navigates, and navigating during
    // build is a framework error.
    WidgetsBinding.instance.addPostFrameCallback((_) => _complete());
  }

  Future<void> _complete() async {
    if (_failure != null) setState(() => _failure = null);
    final params = widget.params ?? CallbackParams.current();
    if (params == null) {
      // A callback with no token is a link that was truncated, rewritten by a
      // mail client, or opened from history after the fragment was dropped.
      setState(() {
        _failure = AuthMessage.incompleteLink;
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
      case AuthFailed(:final key) || AuthUncertain(:final key):
        setState(() {
          _failure = key;
          _done = true;
        });
      case AuthLinkSent():
        setState(() {
          _failure = AuthMessage.unexpectedLinkSent;
          _done = true;
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    final failure = _failure == null ? null : entranceMessage(l, _failure!);
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
                  failure == null
                      ? l.entranceCallbackEyebrowBusy
                      : l.entranceCallbackEyebrowDone,
                  textAlign: TextAlign.center,
                  style: DsTextStyles.labelRitual.copyWith(
                    color: DsColors.textOnRitualMuted,
                  ),
                ),
                const SizedBox(height: DsSpacing.space5),
                Text(
                  failure == null
                      ? l.entranceCallbackHeadlineBusy
                      : l.entranceCallbackHeadlineDone,
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

                if (failure != null) ...[
                  Text(
                    failure,
                    textAlign: TextAlign.center,
                    style: DsTextStyles.bodySecondary.copyWith(
                      color: DsColors.textOnRitualSecondary,
                      height: 22 / 14,
                    ),
                  ),
                  const SizedBox(height: DsSpacing.space8),
                  // Offline is the one failure the same link survives: the
                  // token was never seen by the server, so trying again is
                  // the honest offer. Every other ending needs a new link.
                  if (_failure == AuthMessage.offline) ...[
                    DsPrimaryButton(label: l.recoveryTryAgain, onPressed: _complete),
                    const SizedBox(height: DsSpacing.space3),
                    Center(
                      child: TextButton(
                        onPressed: widget.onRequestNewLink,
                        child: Text(
                          l.entranceRequestNewLink,
                          style: DsTextStyles.bodySecondary.copyWith(color: DsColors.textOnRitualSecondary),
                        ),
                      ),
                    ),
                  ] else
                    DsPrimaryButton(
                      label: l.entranceRequestNewLink,
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
