import 'package:ds_relationship_companion/ds_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/shell/ds_primary_button.dart';
import '../../../app/shell/ds_text_field.dart';
import '../../../l10n/app_localizations.dart';
import '../application/auth_actions.dart';
import 'widgets/descending_thread.dart';
import 'widgets/entrance_header.dart';
import 'widgets/trust_footer.dart';

/// SCR-05 — sign in.
///
/// Built against `design/screens/SCR-05-sign-in/candidates/rev-2`.
///
/// Two ways in, and the second is not a lesser one. There is no
/// password-reset endpoint in this product; the email link *is* the recovery
/// path, and it is the only path for accounts made before password sign-in
/// existed. It is offered as a peer, never as "forgot?".
class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({
    super.key,
    required this.onSignedIn,
    required this.onCreateAccount,
    required this.onBack,
    this.notice,
  });

  final VoidCallback onSignedIn;
  final VoidCallback onCreateAccount;
  final VoidCallback onBack;

  /// Why this screen is being shown, when it is not simply chosen.
  final SignInNotice? notice;

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

/// How the person got here.
enum SignInNotice {
  /// A protected destination sent them. Stated as a request, not a refusal.
  authorizationLost,
  offline;

  /// The sentence, in the reader's language.
  String line(BuildContext context) {
    final l = L.of(context);
    return switch (this) {
      SignInNotice.authorizationLost =>
        l.entranceSignInNoticeAuthorizationLost,
      SignInNotice.offline => l.entranceSignInNoticeOffline,
    };
  }
}

enum _Mode { password, link, linkSent }

class _SignInScreenState extends ConsumerState<SignInScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();

  _Mode _mode = _Mode.password;
  bool _busy = false;
  bool _reveal = false;
  AuthField? _failedField;

  /// The sentence the last outcome named, held as a key so it re-resolves
  /// against the current locale rather than freezing English into state.
  AuthMessage? _message;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _clearFailure() {
    _message = null;
    _failedField = null;
  }

  /// The email survives a failure; the password never does.
  ///
  /// `entrance-state-family.md`: *"Error / retry: 保留 email，清空密码"*, and
  /// *"密码不得…在离开流程后保留"*. Retyping an email after a typo is friction;
  /// a password left in a field is a credential sitting on a screen someone
  /// else may be holding — which on this product is the likely case.
  void _forgetPassword() {
    _password.clear();
    _reveal = false;
  }

  Future<void> _submitPassword() async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _clearFailure();
    });

    final outcome = await ref.read(authActionsProvider).signIn(
          email: _email.text.trim(),
          password: _password.text,
        );

    if (!mounted) return;
    setState(() => _busy = false);

    switch (outcome) {
      case AuthSucceeded():
        widget.onSignedIn();
      case AuthFailed(:final key, :final field):
        setState(() {
          _message = key;
          _failedField = field;
          _forgetPassword();
        });
      case AuthUncertain(:final key):
        setState(() {
          _message = key;
          _forgetPassword();
        });
      case AuthLinkSent():
        // A password sign-in never sends a link.
        setState(() {
          _message = AuthMessage.unexpected;
          _forgetPassword();
        });
    }
  }

  Future<void> _requestLink() async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _clearFailure();
    });

    final outcome = await ref
        .read(authActionsProvider)
        .requestSignInLink(email: _email.text.trim());

    if (!mounted) return;
    setState(() => _busy = false);

    switch (outcome) {
      case AuthLinkSent():
        // Always, whether or not the address has an account. Saying "no such
        // account" here would let anyone test who has one.
        setState(() => _mode = _Mode.linkSent);
      case AuthFailed(:final key, :final field):
        setState(() {
          _message = key;
          _failedField = field;
        });
      case AuthUncertain():
        // A timeout may still have sent the email. Saying "try again" would
        // invite a second link for a message already in someone's inbox, so
        // it lands in the same conditional confirmation as a success.
        setState(() => _mode = _Mode.linkSent);
      case AuthSucceeded():
        // Not reachable: requesting a link never authenticates.
        setState(() => _message = AuthMessage.unexpected);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DsColors.canvasRitual,
      body: DsRitualSurface(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: DsSpacing.space6),
            child: switch (_mode) {
              _Mode.linkSent => _LinkSent(
                busy: _busy,
                onResend: _requestLink,
                onDifferentEmail: () => setState(() {
                  _email.clear();
                  _mode = _Mode.link;
                }),
                onUsePassword: () => setState(() {
                  _forgetPassword();
                  _mode = _Mode.password;
                }),
                onBack: _busy ? null : widget.onBack,
              ),
              _ => _Form(
                mode: _mode,
                email: _email,
                password: _password,
                busy: _busy,
                reveal: _reveal,
                notice: widget.notice,
                message: _message,
                failedField: _failedField,
                onToggleReveal: () => setState(() => _reveal = !_reveal),
                onSubmit: _mode == _Mode.link ? _requestLink : _submitPassword,
                onSwitchMode: () => setState(() {
                  _mode = _mode == _Mode.link ? _Mode.password : _Mode.link;
                  _clearFailure();
                  _forgetPassword();
                }),
                onCreateAccount: widget.onCreateAccount,
                onBack: _busy ? null : widget.onBack,
              ),
            },
          ),
        ),
      ),
    );
  }
}

class _Form extends StatelessWidget {
  const _Form({
    required this.mode,
    required this.email,
    required this.password,
    required this.busy,
    required this.reveal,
    required this.notice,
    required this.message,
    required this.failedField,
    required this.onToggleReveal,
    required this.onSubmit,
    required this.onSwitchMode,
    required this.onCreateAccount,
    required this.onBack,
  });

  final _Mode mode;
  final TextEditingController email;
  final TextEditingController password;
  final bool busy;
  final bool reveal;
  final SignInNotice? notice;
  final AuthMessage? message;
  final AuthField? failedField;
  final VoidCallback onToggleReveal;
  final VoidCallback onSubmit;
  final VoidCallback onSwitchMode;
  final VoidCallback onCreateAccount;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    final linkMode = mode == _Mode.link;
    final error = message == null ? null : entranceMessage(l, message!);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        EntranceHeader(
          onBack: onBack,
          // 40dp, not the 32dp default: the entrance renderer draws SCR-05's
          // mark one frozen step larger than SCR-06's.
          markSize: EntranceHeader.markMedium,
          // The eyebrow is dropped when a notice explains the visit instead:
          // "Welcome back" above "Please sign in to continue" says the same
          // thing twice, and the second one is the true one.
          eyebrow: notice == null ? l.entranceSignInEyebrow : '',
          headline: l.entranceSignInHeadline,
        ),
        if (notice case final notice?) ...[
          _Notice(notice.line(context)),
          const SizedBox(height: DsSpacing.space4),
        ],
        const Center(child: DescendingThread(height: 96)),
        const SizedBox(height: DsSpacing.space6),

        DsTextField(
          label: l.entranceFieldEmail,
          controller: email,
          hint: l.entranceFieldEmailHint,
          enabled: !busy,
          keyboardType: TextInputType.emailAddress,
          textInputAction: linkMode ? TextInputAction.done : TextInputAction.next,
          autofillHints: const [AutofillHints.email],
          error: failedField == AuthField.email ? error : null,
          onSubmitted: linkMode ? (_) => onSubmit() : null,
        ),

        if (linkMode) ...[
          const SizedBox(height: DsSpacing.space5),
          Text(
            l.entranceLinkModeExplainer,
            style: DsTextStyles.bodySecondary.copyWith(
              color: DsColors.textOnRitualMuted,
            ),
          ),
        ] else ...[
          const SizedBox(height: DsSpacing.space6),
          DsTextField(
            label: l.entranceFieldPassword,
            controller: password,
            obscure: !reveal,
            onToggleObscure: onToggleReveal,
            enabled: !busy,
            textInputAction: TextInputAction.done,
            autofillHints: const [AutofillHints.password],
            error: failedField == AuthField.password ? error : null,
            onSubmitted: (_) => onSubmit(),
          ),
        ],

        // A refusal that belongs to neither field: the pair was not accepted,
        // and the screen never says which half was wrong.
        if (error != null && failedField == null) ...[
          const SizedBox(height: DsSpacing.space4),
          Text(
            error,
            style: DsTextStyles.bodySecondary.copyWith(
              color: DsColors.stateError,
            ),
          ),
        ],

        const SizedBox(height: DsSpacing.space6),
        DsPrimaryButton(
          label: linkMode ? l.entranceSendLink : l.entranceSignIn,
          busyLabel: linkMode ? l.entranceSendLinkBusy : l.entranceSignInBusy,
          busy: busy,
          onPressed: onSubmit,
        ),
        const SizedBox(height: DsSpacing.space4),

        // Not "Forgot password?" — there is no password reset in this product.
        // The link is a way in, not an admission of failure (decision D8).
        _TextLink(
          linkMode ? l.entranceUsePasswordInstead : l.entranceUseEmailLink,
          onPressed: busy ? null : onSwitchMode,
        ),
        if (!linkMode)
          _TextLink(
            l.entranceCreateAccountLink,
            onPressed: busy ? null : onCreateAccount,
          ),

        const SizedBox(height: DsSpacing.space5),
        const TrustFooter(),
        const SizedBox(height: DsSpacing.space5),
      ],
    );
  }
}

/// After a link is requested — whether or not an account exists.
class _LinkSent extends StatelessWidget {
  const _LinkSent({
    required this.busy,
    required this.onResend,
    required this.onDifferentEmail,
    required this.onUsePassword,
    required this.onBack,
  });

  final bool busy;
  final VoidCallback onResend;
  final VoidCallback onDifferentEmail;
  final VoidCallback onUsePassword;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        EntranceHeader(
          onBack: onBack,
          markSize: EntranceHeader.markMedium,
          eyebrow: l.entranceLinkSentEyebrow,
          headline: l.entranceLinkSentHeadline,
        ),
        // No glow: the light arrives when the link does, not now.
        const Center(child: DescendingThread(height: 78, glow: false)),
        const SizedBox(height: DsSpacing.space8),
        Text(
          // Conditional on purpose. Confirming that an address has an account
          // would let anyone check who is a member of this product, which on
          // this product is a disclosure about someone's private life.
          l.entranceLinkSentBody,
          textAlign: TextAlign.center,
          style: DsTextStyles.bodySecondary.copyWith(
            color: DsColors.textOnRitualSecondary,
            fontSize: 14,
            height: 22 / 14,
          ),
        ),
        const SizedBox(height: DsSpacing.space10),
        DsPrimaryButton(
          label: l.entranceResendLink,
          busyLabel: l.entranceSendLinkBusy,
          busy: busy,
          onPressed: onResend,
        ),
        const SizedBox(height: DsSpacing.space4),
        _TextLink(
          l.entranceUseDifferentEmail,
          onPressed: busy ? null : onDifferentEmail,
        ),
        _TextLink(
          l.entranceUsePasswordInstead,
          onPressed: busy ? null : onUsePassword,
        ),
        const SizedBox(height: DsSpacing.space5),
        const TrustFooter(),
        const SizedBox(height: DsSpacing.space5),
      ],
    );
  }
}

class _TextLink extends StatelessWidget {
  const _TextLink(this.label, {required this.onPressed});

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      child: Text(
        label,
        style: DsTextStyles.bodySecondary.copyWith(
          color: DsColors.textOnRitualSecondary,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _Notice extends StatelessWidget {
  const _Notice(this.line);

  final String line;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: DsSpacing.space4,
        vertical: DsSpacing.space3,
      ),
      decoration: BoxDecoration(
        color: DsColors.actionPrimaryDisabledBackground,
        borderRadius: BorderRadius.circular(DsRadii.medium),
      ),
      child: Text(
        line,
        textAlign: TextAlign.center,
        style: DsTextStyles.bodySecondary.copyWith(
          color: DsColors.textOnRitualSecondary,
        ),
      ),
    );
  }
}
