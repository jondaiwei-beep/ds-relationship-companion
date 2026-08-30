import 'package:ds_relationship_companion/ds_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/shell/ds_primary_button.dart';
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
  String? _failure;

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
      case InviteCreateFailed(:final message):
        setState(() {
          _failure = message;
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
      case InviteCreateFailed(:final message):
        setState(() {
          _failure = message;
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
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: DsSpacing.space5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _Header(
                  status: _statusWord,
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
      ),
    );
  }

  String? get _statusWord {
    if (_busy && _link == null) return 'CHECKING';
    if (_link != null) return 'PENDING';
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

class _Header extends StatelessWidget {
  const _Header({required this.status, required this.onBack});

  final String? status;
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
              icon: const Icon(
                Icons.arrow_back_ios_new,
                color: DsColors.textOnRitualSecondary,
              ),
            ),
          ),
          Text(
            'Private invitation',
            style: DsTextStyles.bodyPrimary.copyWith(
              color: DsColors.textOnRitualPrimary,
            ),
          ),
          if (status case final status?)
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                status,
                style: DsTextStyles.labelRitual.copyWith(
                  color: status == 'PENDING'
                      ? DsPrimitiveColors.terracotta
                      : DsColors.textOnRitualMuted,
                ),
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
    return Column(
      children: [
        const SizedBox(height: DsSpacing.space10),
        Text(
          'Preparing a private link…',
          style: DsTextStyles.bodyPrimary.copyWith(
            color: DsColors.textOnRitualSecondary,
          ),
        ),
        const SizedBox(height: DsSpacing.space4),
        Text(
          'Nothing is sent until you share it.',
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
  final String? failure;
  final VoidCallback onRevoke;

  /// The token, shown as something a person can read out. It is the same
  /// secret as the URL, so it is treated with the same care — never logged,
  /// never sent anywhere but the clipboard or the share sheet.
  String get _code => invite.invite.token.toUpperCase();

  @override
  Widget build(BuildContext context) {
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
          'A private space\nis ready to share.',
          style: DsTextStyles.displayRitual.copyWith(
            color: DsColors.textOnRitualPrimary,
          ),
        ),
        const SizedBox(height: DsSpacing.space6),
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: DsPrimitiveColors.terracotta,
              ),
            ),
            const SizedBox(width: DsSpacing.space3),
            Expanded(
              child: Text(
                'Waiting for them to join',
                style: DsTextStyles.bodySecondary.copyWith(
                  color: DsPrimitiveColors.terracotta,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: DsSpacing.space2),
        Padding(
          padding: const EdgeInsets.only(left: 20),
          child: Text(
            'Nothing begins until both of you agree.',
            style: DsTextStyles.bodySecondary.copyWith(
              color: DsColors.textOnRitualMuted,
              fontSize: 12,
            ),
          ),
        ),
        const SizedBox(height: DsSpacing.space8),

        Text(
          'PRIVATE LINK / CODE',
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
          _expiry,
          style: DsTextStyles.bodySecondary.copyWith(
            color: DsColors.textOnRitualMuted,
            fontSize: 13,
          ),
        ),
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

        // The design's primary action is a native share sheet. That needs a
        // platform plugin this app does not carry yet, and copying works on
        // every platform including Web — where this screen is also reachable.
        // Recorded as a follow-up rather than pulling in a dependency for one
        // control; the link is equally shareable either way.
        DsPrimaryButton(
          label: 'Copy invitation link',
          busy: busy,
          onPressed: () => _copy(context, invite.url),
        ),
        const SizedBox(height: DsSpacing.space5),
        _Row(
          asset: DsAssets.iconCopy,
          label: 'Copy code only',
          onTap: busy ? null : () => _copy(context, _code),
        ),
        _Row(
          asset: DsAssets.iconRevoke,
          label: 'Revoke invitation',
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
        content: const Text('Copied'),
        backgroundColor: DsColors.surfaceRitualRaised,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// Stated from the server's `expiresAt`, in the coarse terms a person uses.
  /// Never invented: the design's "expires in 6 days" was a fixed string, and
  /// it was wrong for six of the seven days it described.
  String get _expiry {
    final left = invite.invite.expiresAt.difference(DateTime.now());
    if (left.isNegative) return 'This link has expired.';
    if (left.inHours < 1) return 'Expires within the hour';
    if (left.inHours < 24) return 'Expires in ${left.inHours} hours';
    return 'Expires in ${left.inDays} days';
  }
}

/// A live invitation already exists and its token cannot be shown again.
class _AlreadyLive extends StatelessWidget {
  const _AlreadyLive({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: DsSpacing.space6),
        Text(
          'An invitation is\nalready waiting.',
          style: DsTextStyles.displayRitual.copyWith(
            color: DsColors.textOnRitualPrimary,
          ),
        ),
        const SizedBox(height: DsSpacing.space6),
        Text(
          'Only one link can be live at a time, and a link is shown only once '
          'when it is made.',
          style: DsTextStyles.bodySecondary.copyWith(
            color: DsColors.textOnRitualSecondary,
          ),
        ),
        const SizedBox(height: DsSpacing.space4),
        Text(
          'Withdraw the existing one from your Dynamic to make a new link.',
          style: DsTextStyles.bodySecondary.copyWith(
            color: DsColors.textOnRitualMuted,
          ),
        ),
        const SizedBox(height: DsSpacing.space8),
        DsPrimaryButton(label: 'Back to your Dynamic', onPressed: onBack),
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

  final String? failure;
  final bool busy;
  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: DsSpacing.space6),
        Text(
          failure == null
              ? 'This invitation\nis closed.'
              : "We couldn't make\na private link.",
          style: DsTextStyles.displayRitual.copyWith(
            color: DsColors.textOnRitualPrimary,
          ),
        ),
        const SizedBox(height: DsSpacing.space6),
        Text(
          failure ??
              'The old link can no longer open your Dynamic. '
                  'Nobody joined through it.',
          style: DsTextStyles.bodySecondary.copyWith(
            color: failure == null
                ? DsColors.textOnRitualSecondary
                : DsColors.stateError,
          ),
        ),
        const SizedBox(height: DsSpacing.space8),
        DsPrimaryButton(
          label: 'Create a new invitation',
          busy: busy,
          onPressed: onCreate,
        ),
        const SizedBox(height: DsSpacing.space5),
        Center(
          child: Text(
            'Creating a new invitation makes a new private link.',
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
      tooltip: 'Copy link',
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
                Icon(
                  Icons.arrow_forward_ios,
                  size: 14,
                  color: DsColors.textOnRitualSecondary,
                ),
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
