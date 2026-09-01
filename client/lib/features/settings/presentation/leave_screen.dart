import 'package:ds_relationship_companion/ds_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../app/shell/ds_primary_button.dart';
import '../../../domain_client/api_client.dart';
import '../../../domain_client/models/dynamic_view.dart';
import '../../../l10n/app_localizations.dart';
import '../../dynamic/presentation/dynamic_screen.dart';
import '../../today/presentation/widgets/secondary_button.dart';
import '../../today/presentation/widgets/today_layout.dart';

/// SCR-30 Leaving and blocking.
///
/// Both end the Dynamic for both people, immediately and on the server:
/// membership access changes, the Dynamic stops producing shared action, and
/// queued deliveries are cancelled. Neither can be undone from the app.
///
/// So the screen is built around one rule — nothing happens until a second,
/// explicit confirmation — and around saying plainly what each one does. It
/// never asks anyone to justify the choice: leaving needs no partner approval
/// (Notion 04 §4), and a screen that argued back would be doing exactly what
/// this product exists not to do.
///
/// Blocking is offered separately rather than as a checkbox on leaving. They
/// differ in a way that matters: both end the pairing, but blocking also stops
/// the other person contacting you again, and someone reaching for it is
/// usually not in a state to read a subtitle.
class LeaveScreen extends ConsumerStatefulWidget {
  const LeaveScreen({super.key, required this.dynamicId, this.onDone});

  final String dynamicId;

  /// Where to go once the pairing has ended, or the person changed their mind.
  final VoidCallback? onDone;

  @override
  ConsumerState<LeaveScreen> createState() => _LeaveScreenState();
}

enum _Intent { none, leave, block }

class _LeaveScreenState extends ConsumerState<LeaveScreen> {
  _Intent _confirming = _Intent.none;
  bool _busy = false;
  String? _failure;
  String? _key;

  Future<void> _run(_Intent intent, MemberView? partner) async {
    setState(() {
      _busy = true;
      _failure = null;
    });

    final repo = ref.read(dynamicRepositoryProvider);
    final key = _key ??= ApiClient.newIdempotencyKey();

    try {
      if (intent == _Intent.leave) {
        await repo.leave(widget.dynamicId, idempotencyKey: key);
      } else {
        // The server rejects blocking yourself, and there is nobody to block
        // in a Dynamic of one.
        if (partner == null) {
          setState(() {
            _busy = false;
            _failure = L.of(context).settingsNoOneToBlock;
          });
          return;
        }
        await repo.block(
          widget.dynamicId,
          targetUserId: partner.userId,
          idempotencyKey: key,
        );
      }
      _key = null;
      if (!mounted) return;
      setState(() => _busy = false);
      widget.onDone?.call();
    } on Object {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _failure = L.of(context).settingsLeaveFailed;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    final detail = ref.watch(dynamicDetailProvider(widget.dynamicId));
    final viewer = ref.watch(dynamicViewerIdProvider);
    MemberView? partner;
    if (detail.hasValue && viewer != null) {
      for (final m in detail.value!.members) {
        if (m.userId != viewer) partner = m;
      }
    }

    return Scaffold(
      backgroundColor: DsColors.canvasRitual,
      body: DsRitualSurface(
        child: SafeArea(
          child: Column(
            children: [
              _TopBar(onClose: _busy ? null : widget.onDone),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: switch (_confirming) {
                    _Intent.none => _choices(l, partner),
                    _Intent.leave => _confirm(
                      title: l.settingsLeaveConfirmTitle,
                      facts: [
                        l.settingsLeaveFactEndsForBoth,
                        l.settingsLeaveFactNothingAskedAgain,
                        l.settingsLeaveFactNoAgreementNeeded,
                        l.settingsLeaveFactCannotUndo,
                      ],
                      action: l.settingsLeaveAction,
                      busyLabel: l.settingsLeaveBusy,
                      onConfirm: () => _run(_Intent.leave, partner),
                    ),
                    _Intent.block => _confirm(
                      title: partner == null
                          ? l.settingsBlockConfirmTitle
                          : l.settingsBlockConfirmTitleNamed(
                              partner.displayName ??
                                  l.settingsBlockPartnerFallbackName,
                            ),
                      facts: [
                        l.settingsBlockFactEndsForBoth,
                        l.settingsBlockFactNoContact,
                        l.settingsBlockFactNoHistory,
                        l.settingsBlockFactNotTold,
                        l.settingsBlockFactCannotUndo,
                      ],
                      action: l.settingsBlockAction,
                      busyLabel: l.settingsBlockBusy,
                      onConfirm: () => _run(_Intent.block, partner),
                    ),
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _choices(L l, MemberView? partner) => [
    Padding(
      padding: todayInset,
      child: Text(
        l.settingsLeaveHeadline,
        style: DsTextStyles.displayRitual.copyWith(
          color: DsColors.textOnRitualPrimary,
          fontSize: 28,
          height: 34 / 28,
        ),
      ),
    ),
    const SizedBox(height: DsSpacing.space3),
    _Quiet(l.settingsLeaveIntro),
    const SizedBox(height: DsSpacing.space8),
    Padding(
      padding: todayInset,
      child: SecondaryButton(
        label: l.settingsLeaveAction,
        onTap: () => setState(() => _confirming = _Intent.leave),
      ),
    ),
    const SizedBox(height: DsSpacing.space3),
    _Quiet(l.settingsLeaveActionSupport),
    const SizedBox(height: DsSpacing.space6),
    Padding(
      padding: todayInset,
      child: SecondaryButton(
        label: l.settingsBlockAction,
        onTap: partner == null
            ? () {}
            : () => setState(() => _confirming = _Intent.block),
      ),
    ),
    const SizedBox(height: DsSpacing.space3),
    _Quiet(
      partner == null
          ? l.settingsBlockActionSupportNoPartner
          : l.settingsBlockActionSupport,
    ),
    if (_failure != null) ...[
      const SizedBox(height: DsSpacing.space6),
      _Quiet(_failure!, prominent: true),
    ],
    const SizedBox(height: DsSpacing.space10),
  ];

  List<Widget> _confirm({
    required String title,
    required List<String> facts,
    required String action,
    required String busyLabel,
    required VoidCallback onConfirm,
  }) => [
    Padding(
      padding: todayInset,
      child: Text(
        title,
        style: DsTextStyles.displayRitual.copyWith(
          color: DsColors.textOnRitualPrimary,
          fontSize: 28,
          height: 34 / 28,
        ),
      ),
    ),
    const SizedBox(height: DsSpacing.space6),
    for (final fact in facts) _Fact(fact),
    const SizedBox(height: DsSpacing.space6),
    if (_failure != null) ...[
      _Quiet(_failure!, prominent: true),
      const SizedBox(height: DsSpacing.space5),
    ],
    Padding(
      padding: todayInset,
      child: DsPrimaryButton(
        label: action,
        busy: _busy,
        busyLabel: busyLabel,
        onPressed: _busy ? null : onConfirm,
      ),
    ),
    const SizedBox(height: DsSpacing.space4),
    Padding(
      padding: todayInset,
      child: SecondaryButton(
        label: L.of(context).settingsGoBack,
        onTap: _busy ? () {} : () => setState(() => _confirming = _Intent.none),
      ),
    ),
    const SizedBox(height: DsSpacing.space10),
  ];
}

class _Fact extends StatelessWidget {
  const _Fact(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: todayInset.add(
        const EdgeInsets.only(bottom: DsSpacing.space4),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 4,
            height: 4,
            margin: const EdgeInsets.only(top: 9, right: DsSpacing.space3),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: DsColors.textOnRitualMuted,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: DsTextStyles.bodySecondary.copyWith(
                color: DsColors.textOnRitualSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Quiet extends StatelessWidget {
  const _Quiet(this.text, {this.prominent = false});

  final String text;
  final bool prominent;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: todayInset,
      child: Text(
        text,
        style: prominent
            ? DsTextStyles.bodyPrimary.copyWith(
                color: DsColors.textOnRitualPrimary,
              )
            : DsTextStyles.bodySecondary.copyWith(
                color: DsColors.textOnRitualMuted,
                fontSize: todaySupportSize,
                height: todaySupportHeight,
              ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({this.onClose});

  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: todayInset.add(
        const EdgeInsets.symmetric(vertical: DsSpacing.space4),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          GestureDetector(
            onTap: onClose,
            behavior: HitTestBehavior.opaque,
            child: Icon(
              Icons.close,
              size: 22,
              color: DsColors.textOnRitualMuted,
              semanticLabel: L.of(context).settingsClose,
            ),
          ),
        ],
      ),
    );
  }
}
