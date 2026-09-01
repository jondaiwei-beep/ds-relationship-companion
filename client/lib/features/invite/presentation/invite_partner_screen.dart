import 'package:ds_relationship_companion/ds_design_system.dart';
import 'package:flutter/material.dart';

import '../../../app/shell/ds_glyph.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/shell/ds_primary_button.dart';
import '../../../l10n/app_localizations.dart';
import '../application/invite_actions.dart';
import 'widgets/lifecycle_track.dart';

/// SCR-09 — invite a partner. The sending half of the handshake.
///
/// Its counterpart, SCR-10, is opened by someone with no account and no
/// context. This one is the opposite: an authenticated owner, inside their own
/// Dynamic, holding a link that only they have.
///
/// So it withholds nothing from them and everything from the link. The code is
/// on screen because they need to read it aloud or paste it; the invitation can
/// be withdrawn at any time because a link sent to the wrong address has to
/// have a way back.
class InvitePartnerScreen extends ConsumerStatefulWidget {
  const InvitePartnerScreen({
    super.key,
    required this.dynamicId,
    required this.onDone,
    required this.onBack,
  });

  final String dynamicId;

  /// The partner joined. Nothing on this screen learns that on its own —
  /// it is the caller's job to watch for it.
  final VoidCallback onDone;

  final VoidCallback onBack;

  @override
  ConsumerState<InvitePartnerScreen> createState() =>
      _InvitePartnerScreenState();
}

class _InvitePartnerScreenState extends ConsumerState<InvitePartnerScreen> {
  InviteLinkReady? _link;
  bool _busy = true;
  bool _alreadyLive = false;

  /// Which sentence the last failure named. A key, not a string, so it speaks
  /// the reader's language rather than the one this file was written in.
  InviteMessage? _failure;

  @override
  void initState() {
    super.initState();
    _create();
  }

  Future<void> _create() async {
    setState(() {
      _busy = true;
      _failure = null;
      _alreadyLive = false;
    });

    final outcome = await ref.read(inviteActionsProvider).create(widget.dynamicId);
    if (!mounted) return;

    switch (outcome) {
      case InviteLinkReady():
        setState(() {
          _link = outcome;
          _busy = false;
        });
      case InviteAlreadyExists():
        // One live invitation per Dynamic. The token is returned exactly once
        // and only its hash is kept, so an existing link cannot be shown
        // again — withdrawing it and making a new one is the only way back,
        // and that is what the screen offers.
        setState(() {
          _alreadyLive = true;
          _busy = false;
        });
      case InviteCreateFailed(:final key):
        setState(() {
          _failure = key;
          _busy = false;
        });
      case InviteRevoked():
        setState(() => _busy = false);
    }
  }

  Future<void> _revoke() async {
    final link = _link;
    if (link == null || _busy) return;
    setState(() {
      _busy = true;
      _failure = null;
    });

    final outcome = await ref
        .read(inviteActionsProvider)
        .revoke(widget.dynamicId, link.invite.inviteId);
    if (!mounted) return;

    switch (outcome) {
      case InviteRevoked():
        setState(() {
          _link = null;
          _busy = false;
        });
      case InviteCreateFailed(:final key):
        setState(() {
          _failure = key;
          _busy = false;
        });
      case InviteLinkReady() || InviteAlreadyExists():
        setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DsColors.canvasRitual,
      body: DsRitualSurface(
        // `motif.botanical.invite-branch` is approved, frozen at 160/220dp,
        // and registered `used_by: ["SCR-09"]` — and nothing painted it, so
        // the right edge of this screen was empty where the reference has the
        // branch. Behind the content and clipped to the page: it is framing,
        // never something to reach for.
        child: Stack(
          children: [
            // Anchored where the reference has it: entering beside the
            // headline and running off the bottom edge, with its stem past the
            // right margin so the page frames the branch rather than
            // containing it.
            const Positioned(
              right: -DsSpacing.space16,
              // Level with the headline, so the branch enters beside the words
              // rather than beside the mark above them.
              top: DsSpacing.space24 + DsSpacing.space24 + DsSpacing.space12,
              child: _InviteBranch(),
            ),
            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: DsSpacing.space5,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _Header(
                      status: _statusLabel(L.of(context)),
                      onBack: _busy ? null : widget.onBack,
                    ),
                    const SizedBox(height: DsSpacing.space8),
                    _body(),
                    const SizedBox(height: DsSpacing.space8),
                    LifecycleTrack(current: _link != null ? 0 : null),
                    const SizedBox(height: DsSpacing.space6),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// The word in the header's right corner, and whether it is the live one.
  ///
  /// `pending` is emphasised and `checking` is not, so the pair travels
  /// together — reading the emphasis off the translated string would break
  /// the moment the string is translated.
  ({String text, bool live})? _statusLabel(L l) {
    if (_busy && _link == null) {
      return (text: l.inviteStatusChecking, live: false);
    }
    if (_link != null) return (text: l.inviteStatusPending, live: true);
    return null;
  }

  Widget _body() {
    if (_busy && _link == null) return const _Preparing();
    if (_alreadyLive) return _AlreadyLive(onBack: widget.onBack);

    final link = _link;
    if (link == null) {
      return _NoLink(failure: _failure, busy: _busy, onCreate: _create);
    }

    return _Live(
      invite: link,
      busy: _busy,
      failure: _failure,
      onRevoke: _revoke,
    );
  }
}

/// The editorial branch the contract calls "low-contrast editorial branch
/// framing the invitation lifecycle".
///
/// 220dp is one of the two sizes the freeze licenses, and `decorative` is the
/// only tone it licenses. `opacity.botanical` was frozen at 0.18 for exactly
/// this and had never been read by any code — at full strength Warm Gray on
/// the ritual canvas is 9.78:1, which would make a background motif louder
/// than the copy in front of it.
class _InviteBranch extends StatelessWidget {
  const _InviteBranch();

  @override
  Widget build(BuildContext context) => const IgnorePointer(
        child: ExcludeSemantics(
          child: Opacity(
            opacity: DsOpacity.botanical,
            // The artwork's viewBox is 220 × 520. Height follows that ratio so
            // the branch is drawn at its frozen 220dp width rather than
            // letterboxed inside a square and silently shrunk.
            child: DsSvg(
              asset: DsAssets.motifBotanicalInviteBranch,
              tone: DsAssetTone.decorative,
              width: 220,
              height: 220 * 520 / 220,
            ),
          ),
        ),
      );
}

class _Header extends StatelessWidget {
  const _Header({required this.status, required this.onBack});

  final ({String text, bool live})? status;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: DsLayoutSizes.touchTarget,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              onPressed: onBack,
              iconSize: 18,
              icon: DsGlyphIcon(
                DsGlyph.back,
                color: DsColors.textOnRitualSecondary,
                semanticLabel: L.of(context).shellBack,
              ),
            ),
          ),
          Text(
            L.of(context).inviteTitle,
            style: DsTextStyles.bodyPrimary.copyWith(
              color: DsColors.textOnRitualPrimary,
            ),
          ),
          if (status case final status?)
            Align(
              alignment: Alignment.centerRight,
              // A Terracotta dot beside Stone text, not Terracotta text.
              // `label.ritual` is 12px and Terracotta is 4.02:1 on this
              // canvas — B-2 §2 allows it only at 24sp regular or 19sp bold,
              // and §3 says small partner-status labels take Stone with a
              // Terracotta presence mark. State is never carried by colour
              // alone, so the live invitation gets a mark the word can be
              // read without.
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (status.live) ...[
                    Container(
                      width: DsSpacing.space2,
                      height: DsSpacing.space2,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: DsColors.relationshipPresence,
                      ),
                    ),
                    const SizedBox(width: DsSpacing.space2),
                  ],
                  Flexible(
                    child: Text(
                      status.text,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: DsTextStyles.labelRitual.copyWith(
                        color: status.live
                            ? DsColors.textOnRitualSecondary
                            : DsColors.textOnRitualMuted,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// Making the link. The bond mark is withheld: it carries relationship state,
/// and there is no relationship until someone joins.
class _Preparing extends StatelessWidget {
  const _Preparing();

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    return Column(
      children: [
        const SizedBox(height: DsSpacing.space10),
        Text(
          l.invitePreparing,
          style: DsTextStyles.bodyPrimary.copyWith(
            color: DsColors.textOnRitualSecondary,
          ),
        ),
        const SizedBox(height: DsSpacing.space4),
        Text(
          l.invitePreparingNote,
          style: DsTextStyles.bodySecondary.copyWith(
            color: DsColors.textOnRitualMuted,
          ),
        ),
      ],
    );
  }
}

/// A live invitation: the whole point of the screen.
class _Live extends StatelessWidget {
  const _Live({
    required this.invite,
    required this.busy,
    required this.failure,
    required this.onRevoke,
  });

  final InviteLinkReady invite;
  final bool busy;
  final InviteMessage? failure;
  final VoidCallback onRevoke;

  /// The token, shown as something a person can read out. It is the same
  /// secret as the URL, so it is treated with the same care — never logged,
  /// never sent anywhere but the clipboard or the share sheet.
  String get _code => invite.invite.token.toUpperCase();

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Center(
          child: DsSvg(
            asset: DsAssets.markPartnerBond,
            tone: DsAssetTone.primary,
            width: 80,
            height: 80,
          ),
        ),
        const SizedBox(height: DsSpacing.space8),
        Text(
          l.inviteReadyHeadline,
          style: DsTextStyles.displayRitual.copyWith(
            color: DsColors.textOnRitualPrimary,
          ),
        ),
        const SizedBox(height: DsSpacing.space6),
        Row(
          children: [
            // The dot carries the Terracotta; the sentence does not.
            // `body.secondary` is 14px and Terracotta is 4.02:1 on the ritual
            // canvas — B-2 §2 permits Terracotta text only at 24sp regular or
            // 19sp bold. The presence mark beside Stone copy is the treatment
            // §3 names for exactly this, and it keeps the state legible
            // without relying on colour.
            Container(
              width: DsSpacing.space2,
              height: DsSpacing.space2,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: DsColors.relationshipPresence,
              ),
            ),
            const SizedBox(width: DsSpacing.space3),
            Expanded(
              child: Text(
                l.inviteWaitingForThem,
                style: DsTextStyles.bodySecondary.copyWith(
                  color: DsColors.textOnRitualSecondary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: DsSpacing.space2),
        Padding(
          padding: const EdgeInsets.only(left: 20),
          child: Text(
            l.inviteNothingBeginsYet,
            style: DsTextStyles.bodySecondary.copyWith(
              color: DsColors.textOnRitualMuted,
              fontSize: 12,
            ),
          ),
        ),
        const SizedBox(height: DsSpacing.space8),

        Text(
          l.inviteLinkLabel,
          style: DsTextStyles.labelRitual.copyWith(
            color: DsColors.textOnRitualMuted,
            fontSize: 11,
          ),
        ),
        const SizedBox(height: DsSpacing.space4),
        Row(
          children: [
            Expanded(
              child: Text(
                _code,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: DsTextStyles.displayRitual.copyWith(
                  color: DsColors.textOnRitualPrimary,
                  fontSize: 26,
                  letterSpacing: 3,
                ),
              ),
            ),
            _CopyButton(value: invite.url),
          ],
        ),
        const SizedBox(height: DsSpacing.space3),
        Text(
          _expiry(l),
          style: DsTextStyles.bodySecondary.copyWith(
            color: DsColors.textOnRitualMuted,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: DsSpacing.space6),

        if (failure case final failure?) ...[
          Text(
            inviteMessage(l, failure),
            style: DsTextStyles.bodySecondary.copyWith(
              color: DsColors.stateError,
            ),
          ),
          const SizedBox(height: DsSpacing.space5),
        ],

        // The design's primary action is a native share sheet. That needs a
        // platform plugin this app does not carry yet, and copying works on
        // every platform including Web — where this screen is also reachable.
        // Recorded as a follow-up rather than pulling in a dependency for one
        // control; the link is equally shareable either way.
        DsPrimaryButton(
          label: l.inviteCopyLink,
          // The design puts a mark inside this button. `icon.share` is the one
          // it draws, and it is registered to this screen — but the action
          // here is a copy, not a share, so the mark follows the action rather
          // than the picture. `icon.share` becomes correct when the share
          // sheet does.
          icon: DsAssets.iconCopy,
          busy: busy,
          onPressed: () => _copy(context, invite.url),
        ),
        const SizedBox(height: DsSpacing.space5),
        _Row(
          asset: DsAssets.iconCopy,
          label: l.inviteCopyCodeOnly,
          onTap: busy ? null : () => _copy(context, _code),
        ),
        _Row(
          asset: DsAssets.iconRevoke,
          label: l.inviteRevoke,
          onTap: busy ? null : onRevoke,
        ),
      ],
    );
  }

  /// Confirms in place. A copy with no feedback leaves someone tapping again
  /// to find out whether it worked, and this is the one screen where they
  /// cannot check by opening the thing they copied.
  void _copy(BuildContext context, String value) {
    Clipboard.setData(ClipboardData(text: value));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(L.of(context).inviteCopied),
        backgroundColor: DsColors.surfaceRitualRaised,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// Stated from the server's `expiresAt`, in the coarse terms a person uses.
  /// Never invented: the design's "expires in 6 days" was a fixed string, and
  /// it was wrong for six of the seven days it described.
  String _expiry(L l) {
    final left = invite.invite.expiresAt.difference(DateTime.now());
    if (left.isNegative) return l.inviteExpired;
    if (left.inHours < 1) return l.inviteExpiresWithinHour;
    if (left.inHours < 24) return l.inviteExpiresInHours(left.inHours);
    return l.inviteExpiresInDays(left.inDays);
  }
}

/// A live invitation already exists and its token cannot be shown again.
class _AlreadyLive extends StatelessWidget {
  const _AlreadyLive({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: DsSpacing.space6),
        Text(
          l.inviteAlreadyLiveHeadline,
          style: DsTextStyles.displayRitual.copyWith(
            color: DsColors.textOnRitualPrimary,
          ),
        ),
        const SizedBox(height: DsSpacing.space6),
        Text(
          l.inviteAlreadyLiveDetail,
          style: DsTextStyles.bodySecondary.copyWith(
            color: DsColors.textOnRitualSecondary,
          ),
        ),
        const SizedBox(height: DsSpacing.space4),
        Text(
          l.inviteAlreadyLiveGuidance,
          style: DsTextStyles.bodySecondary.copyWith(
            color: DsColors.textOnRitualMuted,
          ),
        ),
        const SizedBox(height: DsSpacing.space8),
        DsPrimaryButton(label: l.inviteBackToDynamic, onPressed: onBack),
      ],
    );
  }
}

/// No live link — either it was just withdrawn, or making one failed.
class _NoLink extends StatelessWidget {
  const _NoLink({
    required this.failure,
    required this.busy,
    required this.onCreate,
  });

  final InviteMessage? failure;
  final bool busy;
  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    final failure = this.failure;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: DsSpacing.space6),
        Text(
          failure == null
              ? l.inviteClosedHeadline
              : l.inviteCreateFailedHeadline,
          style: DsTextStyles.displayRitual.copyWith(
            color: DsColors.textOnRitualPrimary,
          ),
        ),
        const SizedBox(height: DsSpacing.space6),
        Text(
          failure == null
              ? l.inviteClosedDetail
              : inviteMessage(l, failure),
          style: DsTextStyles.bodySecondary.copyWith(
            color: failure == null
                ? DsColors.textOnRitualSecondary
                : DsColors.stateError,
          ),
        ),
        const SizedBox(height: DsSpacing.space8),
        DsPrimaryButton(
          label: l.inviteCreateNew,
          busy: busy,
          onPressed: onCreate,
        ),
        const SizedBox(height: DsSpacing.space5),
        Center(
          child: Text(
            l.inviteCreateNewNote,
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

class _CopyButton extends StatelessWidget {
  const _CopyButton({required this.value});

  final String value;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () => Clipboard.setData(ClipboardData(text: value)),
      icon: const DsSvg(
        asset: DsAssets.iconCopy,
        tone: DsAssetTone.muted,
        width: 24,
        height: 24,
      ),
      tooltip: L.of(context).inviteCopyLinkTooltip,
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.asset, required this.label, required this.onTap});

  final DsAssetId asset;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          SizedBox(
            height: 64,
            child: Row(
              children: [
                DsSvg(
                  asset: asset,
                  tone: DsAssetTone.muted,
                  width: 20,
                  height: 20,
                ),
                const SizedBox(width: DsSpacing.space4),
                Expanded(
                  child: Text(
                    label,
                    style: DsTextStyles.bodyPrimary.copyWith(
                      color: enabled
                          ? DsColors.textOnRitualPrimary
                          : DsColors.textOnRitualMuted,
                    ),
                  ),
                ),
                DsGlyphIcon(DsGlyph.forward, color: DsColors.textOnRitualMuted),
              ],
            ),
          ),
          Container(
            height: DsBorderWidths.hairline,
            color: DsColors.borderOnRitualHairline,
          ),
        ],
      ),
    );
  }
}
