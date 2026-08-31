import 'package:ds_relationship_companion/ds_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/shell/ds_primary_button.dart';
import '../../../app/shell/ds_text_field.dart';
import '../application/auth_actions.dart';
import 'widgets/descending_thread.dart';
import 'widgets/entrance_header.dart';
import 'widgets/trust_footer.dart';

/// SCR-06 — create an account.
///
/// Built against `design/screens/SCR-06-create-account/candidates/rev-2`.
///
/// Still pre-authentication, so it discloses no more than the entrance does:
/// "Create an account", "Begin privately.", and two fields. Creating an account
/// grants no membership and no relationship — that comes later, and nothing
/// here implies otherwise.
class CreateAccountScreen extends ConsumerStatefulWidget {
  const CreateAccountScreen({
    super.key,
    required this.onCreated,
    required this.onSignIn,
    required this.onBack,
  });

  final VoidCallback onCreated;
  final VoidCallback onSignIn;
  final VoidCallback onBack;

  @override
  ConsumerState<CreateAccountScreen> createState() =>
      _CreateAccountScreenState();
}

class _CreateAccountScreenState extends ConsumerState<CreateAccountScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();

  bool _ageConfirmed = false;
  bool _busy = false;
  bool _reveal = false;

  /// Where the last failure belongs, so it is shown beside the thing that is
  /// wrong rather than as a banner about the whole form.
  AuthField? _failedField;
  String? _message;

  /// A result the server could not confirm. Distinct from a failure: the
  /// account may exist, so the honest advice is to try signing in first.
  bool _uncertain = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _message = null;
      _failedField = null;
      _uncertain = false;
    });

    final outcome = await ref.read(authActionsProvider).register(
          email: _email.text.trim(),
          password: _password.text,
          ageConfirmed: _ageConfirmed,
        );

    if (!mounted) return;
    setState(() => _busy = false);

    switch (outcome) {
      case AuthSucceeded():
        widget.onCreated();
      case AuthUncertain(:final message):
        setState(() {
          _uncertain = true;
          _message = message;
        });
      case AuthFailed(:final message, :final field):
        setState(() {
          _message = message;
          _failedField = field;
        });
      case AuthLinkSent():
        // Registration never sends a link; treating it as success would sign
        // someone in who has not been authenticated.
        setState(() => _message = 'Something unexpected happened. Try again.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final fieldError = _failedField;
    // On a short screen the ornament is what pushes the form below the fold.
    // The fields and the button keep their sizes; the decoration around them
    // gives way, because a person came here to make an account.
    final compact = EntranceHeader.isCompact(context);
    final gap = compact ? DsSpacing.space3 : DsSpacing.space5;
    return Scaffold(
      backgroundColor: DsColors.canvasRitual,
      body: DsRitualSurface(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: DsSpacing.space6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                EntranceHeader(
                  onBack: _busy ? null : widget.onBack,
                  eyebrow: 'Create an account',
                  headline: 'Begin privately.',
                ),
                Center(child: DescendingThread(height: compact ? 40 : 82)),
                SizedBox(height: gap),

                if (_uncertain) ...[
                  _Notice(
                    _message ??
                        "We couldn't confirm whether the account was created. "
                            'Try signing in before creating it again.',
                  ),
                  const SizedBox(height: DsSpacing.space5),
                ] else if (_message != null && fieldError == null) ...[
                  _Notice(_message!, failure: true),
                  const SizedBox(height: DsSpacing.space5),
                ],

                DsTextField(
                  label: 'EMAIL',
                  controller: _email,
                  hint: 'you@example.com',
                  enabled: !_busy,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.email],
                  error: fieldError == AuthField.email ? _message : null,
                ),
                SizedBox(height: gap),
                DsTextField(
                  label: 'CREATE PASSWORD',
                  controller: _password,
                  // The server's real bound, not a rounded-down "at least 8".
                  // A field that understates the rule makes the person
                  // discover it by being refused.
                  hint: '10–256 characters',
                  obscure: !_reveal,
                  onToggleObscure: () => setState(() => _reveal = !_reveal),
                  enabled: !_busy,
                  textInputAction: TextInputAction.done,
                  autofillHints: const [AutofillHints.newPassword],
                  error: fieldError == AuthField.password ? _message : null,
                  onSubmitted: (_) => _submit(),
                ),
                SizedBox(height: gap),

                _AgeConfirmation(
                  checked: _ageConfirmed,
                  enabled: !_busy,
                  error: fieldError == AuthField.ageConfirmation ? _message : null,
                  onChanged: (v) => setState(() => _ageConfirmed = v),
                ),
                SizedBox(height: gap),

                // Never disabled while unconfirmed. Pressing it explains what
                // is missing; a silently dead control is unreachable for a
                // screen-reader user and tells a sighted one nothing either.
                DsPrimaryButton(
                  label: 'Create account',
                  busyLabel: 'Creating account',
                  busy: _busy,
                  onPressed: _submit,
                ),
                const SizedBox(height: DsSpacing.space5),
                Opacity(
                  opacity: 0.8,
                  child: Text(
                    'By creating an account, you agree to the Terms\n'
                    'and acknowledge the Privacy Policy.',
                    textAlign: TextAlign.center,
                    style: DsTextStyles.navLabel.copyWith(
                      color: DsColors.textOnRitualMuted,
                      fontSize: 11,
                      height: 16 / 11,
                    ),
                  ),
                ),
                const SizedBox(height: DsSpacing.space5),
                TextButton(
                  onPressed: _busy ? null : widget.onSignIn,
                  child: Text(
                    'Already have an account? Sign in',
                    style: DsTextStyles.bodySecondary.copyWith(
                      color: DsColors.textOnRitualSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                SizedBox(height: gap),
                // The trust footer is required reading, not decoration
                // (REQ-TRUST-001), so it stays — but it does not need to
                // repeat what the line above it already said on a small
                // screen.
                const TrustFooter(),
                SizedBox(height: gap),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// The 18+ confirmation.
///
/// A real checkbox rather than a toggle, and unchecked by default: consent to
/// a legal statement is never pre-given, and `REQ-TRUST-001` requires the
/// entrance to state it neutrally rather than bury it in the button.
class _AgeConfirmation extends StatelessWidget {
  const _AgeConfirmation({
    required this.checked,
    required this.enabled,
    required this.error,
    required this.onChanged,
  });

  final bool checked;
  final bool enabled;
  final String? error;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final failed = error != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Semantics(
          checked: checked,
          child: InkWell(
            onTap: enabled ? () => onChanged(!checked) : null,
            child: Padding(
              // The whole row is the target, not the 22dp box: a legal
              // confirmation should not need precision to give.
              padding: const EdgeInsets.symmetric(vertical: DsSpacing.space3),
              child: Row(
                children: [
                  Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(DsRadii.small),
                      border: Border.all(
                        color: failed
                            ? DsColors.stateError
                            : DsColors.borderOnRitualHairline,
                        width: DsBorderWidths.hairline,
                      ),
                      // The canvas, not `transparent`: the surface behind is
                      // the ritual ground, and naming it keeps the box the
                      // same colour if this ever sits on a raised surface.
                      color: checked
                          ? DsColors.actionPrimaryBackground
                          : DsColors.canvasRitual,
                    ),
                    child: checked
                        ? const Icon(
                            Icons.check,
                            size: 15,
                            color: DsColors.actionPrimaryForeground,
                          )
                        : null,
                  ),
                  const SizedBox(width: DsSpacing.space3),
                  Expanded(
                    child: Text(
                      'I confirm that I am 18 or older.',
                      style: DsTextStyles.bodySecondary.copyWith(
                        color: DsColors.textOnRitualSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (error case final error?)
          Padding(
            padding: const EdgeInsets.only(top: DsSpacing.space1),
            child: Text(
              error,
              style: DsTextStyles.bodySecondary.copyWith(
                color: DsColors.stateError,
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }
}

class _Notice extends StatelessWidget {
  const _Notice(this.line, {this.failure = false});

  final String line;
  final bool failure;

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
          color: failure ? DsColors.stateError : DsColors.textOnRitualSecondary,
        ),
      ),
    );
  }
}
