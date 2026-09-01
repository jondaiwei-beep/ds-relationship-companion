import 'package:ds_relationship_companion/ds_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/shell/ds_primary_button.dart';
import '../../../l10n/app_localizations.dart';
import '../../../domain_client/models/invite_view.dart';
import '../application/invite_actions.dart';

/// SCR-10 — an invitation, received.
///
/// The only surface in the product that shows relationship content **before
/// authentication**, and it is usually opened in a browser from a link someone
/// was sent. That shapes everything here:
///
/// - It resolves against the server rather than trusting the link. Pending,
///   Accepted, Expired, Revoked and Not-found are five explicit answers, and
///   `REQ-INVITE-001` forbids an opaque 404 — a person holding a dead link is
///   owed an explanation, not a wall.
/// - It shows the inviter's name and nothing else about them. Enough to know
///   the link is real; not enough to expose a relationship to whoever has the
///   URL.
/// - **Opening is not joining.** Joining is a separate, explicit act on this
///   page, and the trust language merged here from SCR-11 says plainly that
///   joining is not consent to future expectations.
class JoinScreen extends ConsumerStatefulWidget {
  const JoinScreen({
    super.key,
    required this.token,
    required this.onJoined,
    required this.onDecline,
    required this.onSignIn,
  });

  final String token;
  /// The membership exists. The Dynamic id comes from the resolve, which is
  /// the only place this screen learns it — `join` answers with the
  /// membership it created.
  final void Function(String dynamicId) onJoined;
  final VoidCallback onDecline;

  /// Joining needs an account. The invite travels with them so they land back
  /// here rather than in an empty Today.
  final VoidCallback onSignIn;

  @override
  ConsumerState<JoinScreen> createState() => _JoinScreenState();
}

class _JoinScreenState extends ConsumerState<JoinScreen> {
  InviteView? _invite;
  bool _resolving = true;
  bool _joining = false;

  /// The sentence to show, named rather than written. This page is opened
  /// from a link on whatever device is nearest, so it must be able to speak
  /// the reader's language before anyone has signed in.
  InviteMessage? _failure;

  /// A locally-decided message with no server outcome behind it.
  bool _joinedWithoutDynamic = false;

  bool _offline = false;

  @override
  void initState() {
    super.initState();
    _resolve();
  }

  Future<void> _resolve() async {
    setState(() {
      _resolving = true;
      _failure = null;
      _offline = false;
    });
    try {
      final invite = await ref.read(inviteActionsProvider).resolve(widget.token);
      if (!mounted) return;
      setState(() {
        _invite = invite;
        _resolving = false;
      });
    } on Object {
      if (!mounted) return;
      // Deliberately not "invalid link": we do not know that. An unreachable
      // server and a dead invitation are different facts, and saying the
      // wrong one would tell someone their partner revoked something when the
      // truth is their train went into a tunnel.
      setState(() {
        _resolving = false;
        _offline = true;
      });
    }
  }

  Future<void> _join() async {
    if (_joining) return;
    setState(() {
      _joining = true;
      _failure = null;
      _joinedWithoutDynamic = false;
    });

    final outcome = await ref.read(inviteActionsProvider).join(widget.token);
    if (!mounted) return;
    setState(() => _joining = false);

    switch (outcome) {
      case Joined():
        final dynamicId = _invite?.dynamicId;
        if (dynamicId == null) {
          // Resolve gave no Dynamic id, which should not happen for a Pending
          // invite. The membership exists either way, so this must not read
          // as a failure to join.
          setState(() => _joinedWithoutDynamic = true);
          return;
        }
        widget.onJoined(dynamicId);
      case JoinRefused(:final key):
        // The invitation changed under them while the page was open. Re-ask
        // the server rather than guessing which ending it reached — the same
        // reason this screen never infers state from a link.
        setState(() => _failure = key);
        await _resolve();
      case JoinNeedsAccount():
        // Expected, not a fault: this page is public so a person can see what
        // they are being asked to join before signing in.
        widget.onSignIn();
      case JoinFailed(:final key):
        setState(() => _failure = key);
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
            child: _body(),
          ),
        ),
      ),
    );
  }

  Widget _body() {
    final l = L.of(context);
    if (_resolving) return const _Resolving();
    if (_offline) return _Unresolved(onRetry: _resolve);

    final invite = _invite;
    if (invite == null) return _Unresolved(onRetry: _resolve);

    return switch (invite.state) {
      InviteState.pending => _Review(
        inviter: invite.inviterDisplayName,
        busy: _joining,
        failure: _joinedWithoutDynamic
            ? l.joinAlreadyJoined
            : (_failure == null ? null : inviteMessage(l, _failure!)),
        onJoin: _join,
        onDecline: widget.onDecline,
      ),
      // Accepted by this person already, or by someone else. Either way there
      // is nothing to do here and no detail to show.
      InviteState.accepted => _Closed(
        headline: l.joinUsedHeadline,
        detail: l.joinClosedPrivacyDetail,
        onLeave: widget.onDecline,
      ),
      InviteState.expired => _Closed(
        headline: l.joinExpiredHeadline,
        detail: l.joinClosedPrivacyDetail,
        assurance: l.joinNotJoinedAnything,
        guidance: l.joinAskForNewLink,
        onLeave: widget.onDecline,
      ),
      // Revoked and Not-found say the same thing on purpose. Distinguishing
      // them would tell whoever holds the URL whether an invitation ever
      // existed, which is a fact about someone's private life.
      InviteState.revoked || InviteState.notFound => _Closed(
        headline: l.joinUnavailableHeadline,
        detail: l.joinUnavailableDetail,
        assurance: l.joinNotJoinedAnything,
        guidance: l.joinAskSharer,
        onLeave: widget.onDecline,
      ),
    };
  }
}

/// Resolving. Nothing is claimed while the answer is unknown — no inviter
/// name, no skeleton shaped like one.
class _Resolving extends StatelessWidget {
  const _Resolving();

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    return Column(
      children: [
        const _Wordmark(),
        const SizedBox(height: 120),
        Text(
          l.joinResolving,
          style: DsTextStyles.bodyPrimary.copyWith(
            color: DsColors.textOnRitualSecondary,
          ),
        ),
        const SizedBox(height: DsSpacing.space4),
        Text(
          l.joinResolvingNote,
          style: DsTextStyles.bodySecondary.copyWith(
            color: DsColors.textOnRitualMuted,
          ),
        ),
      ],
    );
  }
}

/// The server could not be reached. Explicitly not a verdict on the invite.
class _Unresolved extends StatelessWidget {
  const _Unresolved({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _Wordmark(),
        const SizedBox(height: DsSpacing.space10),
        Text(
          l.joinUnresolvedHeadline,
          textAlign: TextAlign.center,
          style: DsTextStyles.displayRitual.copyWith(
            color: DsColors.textOnRitualPrimary,
          ),
        ),
        const SizedBox(height: DsSpacing.space6),
        Text(
          l.joinUnresolvedDetail,
          textAlign: TextAlign.center,
          style: DsTextStyles.bodySecondary.copyWith(
            color: DsColors.textOnRitualSecondary,
          ),
        ),
        const SizedBox(height: DsSpacing.space10),
        DsPrimaryButton(label: l.joinTryAgain, onPressed: onRetry),
        const SizedBox(height: DsSpacing.space6),
        _PrivacyNote(l.joinUnresolvedPrivacyNote),
      ],
    );
  }
}

/// The invitation resolved as Pending: the one state with something to decide.
class _Review extends StatelessWidget {
  const _Review({
    required this.inviter,
    required this.busy,
    required this.failure,
    required this.onJoin,
    required this.onDecline,
  });

  final String? inviter;
  final bool busy;
  final String? failure;
  final VoidCallback onJoin;
  final VoidCallback onDecline;

  @override
  Widget build(BuildContext context) {
    // A name, or nothing. Never "your partner" — this person is not yet
    // anyone's partner, and the app does not name a relationship that has not
    // been agreed to.
    final l = L.of(context);
    final who = inviter ?? l.joinSomeone;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _Wordmark(),
        const SizedBox(height: DsSpacing.space6),
        Text(
          who,
          style: DsTextStyles.displayRitual.copyWith(
            color: DsColors.textOnRitualPrimary,
            fontSize: 44,
            height: 1.05,
          ),
        ),
        Text(
          l.joinInvitedYou,
          style: DsTextStyles.displayRitual.copyWith(
            color: DsColors.textOnRitualPrimary,
            fontSize: 26,
            height: 34 / 26,
          ),
        ),
        const SizedBox(height: DsSpacing.space8),
        const _Boundary(),
        const SizedBox(height: DsSpacing.space6),

        // The trust language merged here from SCR-11, whose contract says not
        // to build it separately. Both halves matter: the role is chosen, and
        // joining commits to nothing beyond joining.
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const DsSvg(
              asset: DsAssets.motifBotanicalNoteSprig,
              tone: DsAssetTone.decorative,
              width: 24,
              height: 24,
            ),
            const SizedBox(width: DsSpacing.space4),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l.joinYouChooseYourRole,
                    style: DsTextStyles.bodySecondary.copyWith(
                      color: DsColors.textOnRitualSecondary,
                    ),
                  ),
                  const SizedBox(height: DsSpacing.space1),
                  Text(
                    l.joinNotConsentToExpectations,
                    style: DsTextStyles.bodySecondary.copyWith(
                      color: DsColors.textOnRitualMuted,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        // No expiry line. The design shows "expires in 6 days" and `resolve`
        // sends no expiry at all, so the number would be invented — false for
        // six of the seven days it claims to describe. Restore it when the
        // read model carries `expiresAt`.
        const SizedBox(height: DsSpacing.space6),

        if (failure case final failure?) ...[
          Text(
            failure,
            style: DsTextStyles.bodySecondary.copyWith(
              color: DsColors.stateError,
            ),
          ),
          const SizedBox(height: DsSpacing.space5),
        ],

        DsPrimaryButton(
          label: l.joinReviewAndJoin,
          busyLabel: l.joinBusy,
          busy: busy,
          onPressed: onJoin,
        ),
        const SizedBox(height: DsSpacing.space4),
        Center(
          child: TextButton(
            onPressed: busy ? null : onDecline,
            // "Not now", not "Decline invitation". Declining would be an act
            // with a server behind it, and there is no endpoint for it — the
            // invitation stays pending either way. A control that says it
            // declined something it did not is worse than an honest one that
            // just leaves.
            child: Text(
              l.joinNotNow,
              style: DsTextStyles.bodySecondary.copyWith(
                color: DsColors.textOnRitualSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
        const SizedBox(height: DsSpacing.space4),
        _PrivacyNote(l.joinPrivacyNote),
        const SizedBox(height: DsSpacing.space6),
      ],
    );
  }
}

/// What becomes shared and what does not. Stated before joining, because
/// afterwards it is too late to have wanted to know.
class _Boundary extends StatelessWidget {
  const _Boundary();

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l.joinBoundaryIntentionLabel,
          style: DsTextStyles.labelRitual.copyWith(
            color: DsColors.textOnRitualMuted,
            fontSize: 10,
            letterSpacing: 1.9,
          ),
        ),
        const SizedBox(height: DsSpacing.space3),
        Text(
          l.joinBoundaryIntention,
          style: DsTextStyles.bodyPrimary.copyWith(
            color: DsColors.textOnRitualSecondary,
          ),
        ),
        const SizedBox(height: DsSpacing.space5),
        Container(
          height: DsBorderWidths.hairline,
          color: DsColors.borderOnRitualHairline,
        ),
        const SizedBox(height: DsSpacing.space5),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _BoundaryHalf(
                  asset: DsAssets.iconSharedSpace,
                  label: l.joinBoundarySharedLabel,
                  items: l.joinBoundarySharedItems,
                ),
              ),
              Container(
                width: DsBorderWidths.hairline,
                color: DsColors.borderOnRitualHairline,
                margin: const EdgeInsets.symmetric(
                  horizontal: DsSpacing.space5,
                ),
              ),
              Expanded(
                child: _BoundaryHalf(
                  asset: DsAssets.iconPrivateSpace,
                  label: l.joinBoundaryPrivateLabel,
                  items: l.joinBoundaryPrivateItems,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _BoundaryHalf extends StatelessWidget {
  const _BoundaryHalf({
    required this.asset,
    required this.label,
    required this.items,
  });

  final DsAssetId asset;
  final String label;
  final String items;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DsSvg(asset: asset, tone: DsAssetTone.muted, width: 24, height: 24),
        const SizedBox(height: DsSpacing.space4),
        Text(
          label,
          style: DsTextStyles.labelRitual.copyWith(
            color: DsColors.textOnRitualMuted,
            fontSize: 9,
            letterSpacing: 1.4,
          ),
        ),
        const SizedBox(height: DsSpacing.space3),
        Text(
          items,
          style: DsTextStyles.bodySecondary.copyWith(
            color: DsColors.textOnRitualSecondary,
            fontSize: 13,
            height: 20 / 13,
          ),
        ),
      ],
    );
  }
}

/// Expired, revoked, not found, already used — every ending, one shape.
///
/// They differ only in a cause the person must not be told: which of them it
/// is would say whether an invitation ever existed and what happened to it.
class _Closed extends StatelessWidget {
  const _Closed({
    required this.headline,
    required this.detail,
    required this.onLeave,
    this.assurance,
    this.guidance,
  });

  final String headline;
  final String detail;
  final String? assurance;
  final String? guidance;
  final VoidCallback onLeave;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _Wordmark(),
        const SizedBox(height: DsSpacing.space8),
        const Center(
          child: DsSvg(
            asset: DsAssets.stateInviteExpired,
            tone: DsAssetTone.muted,
            width: 32,
            height: 32,
          ),
        ),
        const SizedBox(height: DsSpacing.space8),
        Text(
          headline,
          textAlign: TextAlign.center,
          style: DsTextStyles.displayRitual.copyWith(
            color: DsColors.textOnRitualPrimary,
          ),
        ),
        const SizedBox(height: DsSpacing.space5),
        Text(
          detail,
          textAlign: TextAlign.center,
          style: DsTextStyles.bodySecondary.copyWith(
            color: DsColors.textOnRitualSecondary,
          ),
        ),
        const SizedBox(height: DsSpacing.space8),
        if (assurance case final assurance?) ...[
          Container(
            height: DsBorderWidths.hairline,
            color: DsColors.borderOnRitualHairline,
          ),
          const SizedBox(height: DsSpacing.space6),
          Text(
            assurance,
            textAlign: TextAlign.center,
            style: DsTextStyles.titlePage.copyWith(
              color: DsColors.textOnRitualPrimary,
            ),
          ),
          const SizedBox(height: DsSpacing.space4),
        ],
        if (guidance case final guidance?) ...[
          Text(
            guidance,
            textAlign: TextAlign.center,
            style: DsTextStyles.bodySecondary.copyWith(
              color: DsColors.textOnRitualMuted,
            ),
          ),
          const SizedBox(height: DsSpacing.space8),
        ],
        // A text link, as the design has it. A dead invitation offers no
        // primary action, because there is nothing here to do — making
        // "leave" the loudest control would imply otherwise.
        Center(
          child: TextButton(
            onPressed: onLeave,
            child: Text(
              L.of(context).joinReturnToEntrance,
              style: DsTextStyles.bodySecondary.copyWith(
                color: DsColors.textOnRitualSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
        const SizedBox(height: DsSpacing.space5),
        _PrivacyNote(L.of(context).joinClosedPrivacyNote),
        const SizedBox(height: DsSpacing.space6),
      ],
    );
  }
}

/// `COMPANION`, never the product's category.
///
/// This page opens from a link, on whatever device is nearest. Naming what the
/// product is would disclose it to anyone who happens to be looking.
///
/// The rev-2 artwork shows "D/s RELATIONSHIP COMPANION" here, and it predates
/// decision D8 — which renamed the wordmark precisely because the old one
/// "在任何认证之前就暴露产品类别". SCR-10 is pre-authentication and carries
/// `REQ-TRUST-001`, so the decision applies here too.
class _Wordmark extends StatelessWidget {
  const _Wordmark();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: DsSpacing.space5),
      child: Center(
        child: Text(
          L.of(context).joinWordmark,
          style: DsTextStyles.labelRitual.copyWith(
            color: DsColors.textOnRitualMuted,
          ),
        ),
      ),
    );
  }
}

class _PrivacyNote extends StatelessWidget {
  const _PrivacyNote(this.line);

  final String line;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const DsSvg(
          asset: DsAssets.iconPrivateSpace,
          tone: DsAssetTone.muted,
          width: 20,
          height: 20,
        ),
        const SizedBox(width: DsSpacing.space3),
        Flexible(
          child: Text(
            line,
            style: DsTextStyles.bodySecondary.copyWith(
              color: DsColors.textOnRitualMuted,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }
}
