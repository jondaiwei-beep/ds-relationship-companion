import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../design_system/components/ds_button.dart';
import '../../../design_system/components/ds_card.dart';
import '../../../design_system/components/ds_page.dart';
import 'inline_sign_in.dart';
import '../../../design_system/components/ds_text.dart';
import '../../../design_system/tokens/colors.dart';
import '../../../design_system/tokens/spacing.dart';
import '../../../design_system/tokens/typography.dart';
import '../../../domain_client/api_client.dart';
import '../../../domain_client/models/invite_view.dart';

/// Resolves an invite anonymously, then requires an explicit human action to join.
final inviteResolveProvider =
    FutureProvider.autoDispose.family<InviteView, String>((ref, token) async {
  return ref.watch(inviteRepositoryProvider).resolve(token);
});

/// `/invite/{token}` — Journey A5.
///
/// Opening this URL NEVER joins. Mail scanners and link previews issue GETs;
/// joining requires the person to press the button.
class InviteScreen extends ConsumerWidget {
  const InviteScreen({super.key, required this.token});

  final String token;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final invite = ref.watch(inviteResolveProvider(token));
    final signedIn = ref.watch(authSessionProvider);

    return Scaffold(
      backgroundColor: DsColors.canvas,
      body: DsPage(
        child: Builder(
          builder: (_) => invite.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            // Even a network failure must offer a way forward, not a dead end.
            error: (_, _) => _Explain(
              title: "We couldn't open this invitation.",
              body: 'Check your connection and try again.',
              action: 'Try again',
              onAction: () => ref.invalidate(inviteResolveProvider(token)),
            ),
            data: (v) => _body(context, ref, v, signedIn),
          ),
        ),
      ),
    );
  }

  Widget _body(BuildContext context, WidgetRef ref, InviteView v, bool signedIn) {
    // Every terminal state explains itself (Notion 02 §A4) — never a 404.
    switch (v.state) {
      case InviteState.accepted:
        return const _Explain(
          title: 'This invitation was already used.',
          body: 'If this was you, you already have access. Ask your partner to '
              'send a new invitation if you need one.',
        );
      case InviteState.expired:
        return const _Explain(
          title: 'This invitation has expired.',
          body: 'Invitations last 7 days. Ask your partner to send a new one.',
        );
      case InviteState.revoked:
        return const _Explain(
          title: 'This invitation was withdrawn.',
          body: 'Ask your partner if you should still join.',
        );
      case InviteState.notFound:
        return const _Explain(
          title: 'This invitation link is not valid.',
          body: 'Check that you copied the whole link.',
        );
      case InviteState.pending:
        return _JoinOffer(token: token, invite: v, signedIn: signedIn);
    }
  }
}

class _JoinOffer extends ConsumerStatefulWidget {
  const _JoinOffer({required this.token, required this.invite, required this.signedIn});

  final String token;
  final InviteView invite;
  final bool signedIn;

  @override
  ConsumerState<_JoinOffer> createState() => _JoinOfferState();
}

class _JoinOfferState extends ConsumerState<_JoinOffer> {
  var _busy = false;

  @override
  Widget build(BuildContext context) {
    final inviter = widget.invite.inviterDisplayName ?? 'Your partner';

    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const DsAccentRule(),
          const SizedBox(height: DsSpacing.sm),
          const DsEyebrow('Private invitation', terra: true),
          const SizedBox(height: DsSpacing.md),
          Text('$inviter invited you.', style: DsType.h1),
          const SizedBox(height: DsSpacing.xxl),

          // Journey A5 requires answering: what is shared, what stays mine,
          // and that leaving is always possible — BEFORE joining.
          DsCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const DsEyebrow('What joining means'),
                const SizedBox(height: DsSpacing.lg),
                _Point('You and $inviter share what happens in this dynamic.'),
                _Point('Your private notes stay private.'),
                _Point('Joining is not agreement to any future expectation.'),
                _Point('You can pause or leave at any time.'),
              ],
            ),
          ),

          const SizedBox(height: DsSpacing.xxl),
          if (widget.signedIn)
            DsButton(
              label: _busy ? 'Joining…' : 'Confirm & join',
              onPressed: _busy ? null : _join,
            )
          else
            // The threshold stays on the invitation. Sending them to the
            // generic sign-in screen showed an invited partner a headline
            // about building a dynamic — not what they were invited to.
            InlineSignIn(
              returnTo: '/invite/${widget.token}',
              inviteToken: widget.token,
            ),
        ],
    );
  }

  Future<void> _join() async {
    setState(() => _busy = true);
    try {
      await ref.read(inviteRepositoryProvider).join(
            widget.token,
            idempotencyKey: ApiClient.newIdempotencyKey(),
          );
      if (mounted) context.go('/today');
    } catch (_) {
      if (mounted) {
        setState(() => _busy = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("That didn't go through. Please try again.")),
        );
      }
    }
  }
}

class _Point extends StatelessWidget {
  const _Point(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: DsSpacing.sm),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(top: 6, right: DsSpacing.md),
              child: SizedBox(
                width: 4, height: 4,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: DsColors.lineStrong, shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
            Expanded(child: Text(text, style: DsType.body)),
          ],
        ),
      );
}

class _Explain extends StatelessWidget {
  const _Explain({required this.title, required this.body, this.action, this.onAction});

  final String title;
  final String body;
  final String? action;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: DsSpacing.xxxl),
          Text(title, style: DsType.h1),
          const SizedBox(height: DsSpacing.lg),
          Text(body, style: DsType.body.copyWith(color: DsColors.muted)),
          const SizedBox(height: DsSpacing.xxxl),
          if (action != null) DsButton(label: action!, onPressed: onAction),
        ],
      );
}
