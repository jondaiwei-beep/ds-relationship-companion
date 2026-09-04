import 'package:ds_relationship_companion/ds_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../app/shell/bottom_navigation.dart';
import '../../../app/shell/ds_refreshable.dart';
import '../../../domain_client/api_client.dart';
import '../../../domain_client/models/consequence.dart';
import '../../../domain_client/models/points.dart';
import '../../../domain_client/models/redemption.dart';
import '../../../domain_client/models/today_view.dart' show TodayView;
import '../../../l10n/app_localizations.dart';
import '../../dynamic/application/dynamic_providers.dart';
import '../../record/application/record_providers.dart';
import '../../rules/presentation/widgets/rules_sheets.dart';
import '../../today/application/today_providers.dart';
import '../../today/presentation/today_screen.dart';
import '../../today/presentation/widgets/line_sheet.dart';
import '../../today/presentation/widgets/quiet_line.dart';
import '../../today/presentation/widgets/recovery_scaffold.dart';
import '../../today/presentation/widgets/section_label.dart';
import '../../today/presentation/widgets/secondary_button.dart';
import '../../today/presentation/widgets/today_header.dart';
import '../../today/presentation/widgets/today_layout.dart';
import '../../today/presentation/widgets/word_button.dart';
import '../application/points_providers.dart';

/// Tab 4 · 分 (product/02-surfaces.md): the s's balance, what it can buy,
/// the asks in flight, the ledger, which tasks pay, and the consequences the
/// D issued. The number is the s's on both faces; the D gives and takes by
/// hand. Nothing here is automatic, nothing is on a clock.
class PointsScreen extends ConsumerStatefulWidget {
  const PointsScreen({
    super.key,
    required this.dynamicId,
    this.onSignIn,
    this.onSelectTab,
  });

  final String dynamicId;
  final VoidCallback? onSignIn;
  final void Function(NavSurface surface)? onSelectTab;

  @override
  ConsumerState<PointsScreen> createState() => _PointsScreenState();
}

class _PointsScreenState extends ConsumerState<PointsScreen> {
  String? _notice;
  bool _busy = false;

  String get _id => widget.dynamicId;

  void _reloadAll() {
    ref.invalidate(todayProvider(_id));
    ref.invalidate(pointsProvider(_id));
    ref.invalidate(rewardsProvider(_id));
    ref.invalidate(redemptionsProvider(_id));
    ref.invalidate(consequencesProvider(_id));
    ref.invalidate(recordSummaryProvider(_id));
  }

  Future<void> _refresh() async {
    _reloadAll();
    ref.invalidate(pointsRulesProvider(_id));
    await ref.read(todayProvider(_id).future);
  }

  Future<void> _run(Future<void> Function() send) async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _notice = null;
    });
    try {
      await send();
      _reloadAll();
    } on Object {
      if (mounted) setState(() => _notice = L.of(context).ptsActionFailed);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  String _dName(L l, TodayView v) => v.isD ? l.rulesYou : (v.partnerDisplayName ?? l.rulesTheD);
  String _sName(L l, TodayView v) => v.isD ? (v.partnerDisplayName ?? l.rulesTheS) : l.rulesYou;

  // ── writes ───────────────────────────────────────────────────────────────

  Future<void> _adjust(TodayView v, {required bool give}) async {
    final l = L.of(context);
    final sName = _sName(l, v);
    final r = await showNumberNoteSheet(
      context,
      title: give ? l.ptsGiveTitle(sName) : l.ptsDeductTitle(sName),
      amountLabel: l.ptsAmountLabel,
      noteLabel: l.ptsWhyLabel,
      primaryLabel: give ? l.ptsGive : l.ptsDeduct,
    );
    if (r == null || r.amount == null) return;
    final subject = await ref.read(sUserIdProvider(_id).future);
    if (subject == null) return;
    await _run(() => ref.read(pointsRepositoryProvider).adjust(
          _id,
          subjectUserId: subject,
          amount: give ? r.amount! : -r.amount!,
          note: r.note,
        ));
  }

  Future<void> _redeem(Reward reward) async {
    final l = L.of(context);
    final repo = ref.read(pointsRepositoryProvider);
    if (reward.isFree) {
      await _run(() => repo.redeem(_id, reward.id, idempotencyKey: ApiClient.newIdempotencyKey()));
      return;
    }
    final note = await showLineSheet(
      context,
      title: l.ptsRequestTitle(reward.title),
      label: l.ptsRequestNote,
      sendLabel: l.ptsRequestSend,
    );
    if (note == null) return;
    await _run(() => repo.request(
          _id,
          reward.id,
          note: note.isEmpty ? null : note,
          idempotencyKey: ApiClient.newIdempotencyKey(),
        ));
  }

  Future<void> _decide(RedemptionView r, List<Reward> rewards, {required bool approve}) async {
    final l = L.of(context);
    final reward = rewards.where((x) => x.id == r.rewardId).firstOrNull;
    final needsCost = approve && (reward == null || reward.dDecides);
    String? note;
    int? cost;
    if (needsCost) {
      final n = await showNumberNoteSheet(
        context,
        title: r.rewardTitle ?? l.ptsApprove,
        amountLabel: l.ptsDecideCost,
        noteLabel: l.ptsDecideNote,
        primaryLabel: l.ptsApprove,
      );
      if (n == null) return;
      note = n.note;
      cost = n.amount;
    } else {
      final n = await showLineSheet(
        context,
        title: r.rewardTitle ?? (approve ? l.ptsApprove : l.ptsDeny),
        label: l.ptsDecideNote,
        sendLabel: approve ? l.ptsApprove : l.ptsDeny,
      );
      if (n == null) return;
      note = n.isEmpty ? null : n;
    }
    await _run(() => ref.read(pointsRepositoryProvider).decide(
          _id,
          r.id,
          approve: approve,
          note: note,
          costOverride: cost,
          idempotencyKey: ApiClient.newIdempotencyKey(),
        ));
  }

  Future<void> _fulfill(RedemptionView r) => _run(() => ref
      .read(pointsRepositoryProvider)
      .fulfill(_id, r.id, idempotencyKey: ApiClient.newIdempotencyKey()));

  Future<void> _consequence(
    ConsequenceView c,
    Future<ConsequenceView> Function(String id, {required String idempotencyKey}) send,
  ) =>
      _run(() => send(c.id, idempotencyKey: ApiClient.newIdempotencyKey()));

  // ── build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    final today = ref.watch(todayProvider(_id));
    void reload() => ref.invalidate(todayProvider(_id));

    return Scaffold(
      backgroundColor: DsColors.canvasRitual,
      body: DsRitualSurface(
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              Expanded(
                child: DsRefreshable(
                  onRefresh: _refresh,
                  child: today.when(
                    skipLoadingOnReload: true,
                    skipLoadingOnRefresh: true,
                    loading: () => const TodayLoading(),
                    error: (error, _) => switch (classifyFailure(error)) {
                      TodayFailure.authorizationLost => RecoveryScaffold(
                          context_: l.recoveryConfirmingContext,
                          children: [
                            const SizedBox(height: DsSpacing.space8),
                            RecoveryMessage(l.recoverySessionRestore, prominent: true),
                            const SizedBox(height: DsSpacing.space6),
                            Padding(
                              padding: todayInset,
                              child: SecondaryButton(
                                label: l.recoverySignInAgain,
                                onTap: widget.onSignIn ?? () {},
                                filled: true,
                              ),
                            ),
                          ],
                        ),
                      _ => RecoveryScaffold(
                          context_: l.recoveryNotConfirmed,
                          children: [
                            const SizedBox(height: DsSpacing.space8),
                            RecoveryMessage(l.ptsCouldNotLoad, prominent: true),
                            const SizedBox(height: DsSpacing.space6),
                            Padding(
                              padding: todayInset,
                              child: SecondaryButton(label: l.recoveryTryAgain, onTap: reload),
                            ),
                          ],
                        ),
                    },
                    data: (view) => _body(view, l),
                  ),
                ),
              ),
              DsBottomNavigation(current: NavSurface.points, onSelect: widget.onSelectTab),
            ],
          ),
        ),
      ),
    );
  }

  Widget _body(TodayView v, L l) {
    final points = ref.watch(pointsProvider(_id));
    final rewards = ref.watch(rewardsProvider(_id));
    final redemptions = ref.watch(redemptionsProvider(_id));
    final rules = ref.watch(pointsRulesProvider(_id));
    final consequences = ref.watch(consequencesProvider(_id));
    final summary = ref.watch(recordSummaryProvider(_id));
    final dName = _dName(l, v);
    final sName = _sName(l, v);
    final balance = points.asData?.value.balance ?? v.balance;
    final rewardList = rewards.asData?.value ?? const <Reward>[];

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        TodayHeader(title: l.pointsTitle, partnerName: v.partnerDisplayName),
        const SizedBox(height: DsSpacing.space6),

        // ── balance
        Padding(
          padding: todayInset,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // The figure alone in the display face; whose it is goes in the
              // caption. "the s has 0" set in Cormorant read as "the s has o".
              Text(
                l.ptsBalanceMine(balance),
                key: const ValueKey('points-balance'),
                // Cormorant's default figures are old-style: its 0 sits at
                // x-height and reads as an o. Lining figures for a number.
                style: DsTextStyles.displayRitual.copyWith(
                  color: DsColors.textOnRitualPrimary,
                  fontSize: 44,
                  fontFeatures: const [FontFeature.liningFigures(), FontFeature.tabularFigures()],
                ),
              ),
              const SizedBox(height: DsSpacing.space1),
              Text(
                v.isD ? l.ptsBalanceOf(sName, balance) : l.todayBalance(balance),
                style: DsTextStyles.bodySecondary.copyWith(color: DsColors.textOnRitualSecondary),
              ),
              const SizedBox(height: DsSpacing.space1),
              switch (summary) {
                AsyncData(:final value) => Text(
                    l.recordTogether(value.daysTogether, value.currentStreak),
                    style: DsTextStyles.bodySecondary.copyWith(color: DsColors.textOnRitualSecondary),
                  ),
                _ => const SizedBox(height: 18),
              },
            ],
          ),
        ),
        if (v.isD) ...[
          const SizedBox(height: DsSpacing.space4),
          Padding(
            padding: todayInset,
            child: Row(
              children: [
                WordButton(label: l.ptsGive, onTap: () => _adjust(v, give: true), filled: true),
                const SizedBox(width: DsSpacing.space3),
                WordButton(label: l.ptsDeduct, onTap: () => _adjust(v, give: false)),
              ],
            ),
          ),
        ],
        if (_notice != null) ...[
          const SizedBox(height: DsSpacing.space3),
          Padding(padding: todayInset, child: RecoveryMessage(_notice!)),
        ],

        // ── 可兑换
        const SizedBox(height: DsSpacing.space8),
        SectionLabel(l.ptsRedeemableTitle),
        switch (rewards) {
          AsyncData(:final value) => value.isEmpty
              ? QuietLine(l.ptsRedeemableEmpty)
              : Column(
                  children: [
                    for (final r in value)
                      _RewardRow(
                        reward: r,
                        balance: balance,
                        dName: dName,
                        canRedeem: !v.isD && !_busy && r.affordable,
                        onRedeem: () => _redeem(r),
                      ),
                  ],
                ),
          AsyncError() => QuietLine(l.ptsCouldNotLoad),
          _ => const SizedBox(height: 40),
        },

        // ── 兑换申请
        const SizedBox(height: DsSpacing.space8),
        SectionLabel(l.ptsRequestsTitle),
        switch (redemptions) {
          AsyncData(:final value) => value.isEmpty
              ? QuietLine(l.ptsRequestsEmpty)
              : Column(
                  children: [
                    for (final r in value)
                      _RedemptionRow(
                        redemption: r,
                        isD: v.isD,
                        dName: dName,
                        busy: _busy,
                        onApprove: () => _decide(r, rewardList, approve: true),
                        onDeny: () => _decide(r, rewardList, approve: false),
                        onFulfill: () => _fulfill(r),
                      ),
                  ],
                ),
          AsyncError() => QuietLine(l.ptsCouldNotLoad),
          _ => const SizedBox(height: 40),
        },

        // ── 罚
        const SizedBox(height: DsSpacing.space8),
        SectionLabel(l.ptsConsequencesTitle),
        switch (consequences) {
          AsyncData(:final value) => value.isEmpty
              ? QuietLine(l.ptsConsequencesEmpty)
              : Column(
                  children: [
                    for (final c in value)
                      _ConsequenceRow(
                        consequence: c,
                        isD: v.isD,
                        dName: dName,
                        busy: _busy,
                        onDone: () => _consequence(c, ref.read(consequenceRepositoryProvider).done),
                        onConfirm: () => _consequence(c, ref.read(consequenceRepositoryProvider).confirm),
                        onWaive: () => _consequence(c, ref.read(consequenceRepositoryProvider).waive),
                      ),
                  ],
                ),
          AsyncError() => QuietLine(l.ptsCouldNotLoad),
          _ => const SizedBox(height: 40),
        },

        // ── 流水
        const SizedBox(height: DsSpacing.space8),
        SectionLabel(l.ptsLedgerTitle),
        switch (points) {
          AsyncData(:final value) => value.entries.isEmpty
              ? QuietLine(l.ptsLedgerEmpty)
              : Column(
                  children: [for (final e in value.entries) _LedgerRow(entry: e, dName: dName)],
                ),
          AsyncError() => QuietLine(l.ptsCouldNotLoad),
          _ => const SizedBox(height: 40),
        },

        // ── 规则可见
        const SizedBox(height: DsSpacing.space8),
        SectionLabel(l.ptsRulesTitle),
        switch (rules) {
          AsyncData(:final value) => Column(
              children: [
                if (value.isEmpty) QuietLine(l.ptsRulesEmpty),
                for (final r in value) _Line(left: r.title, right: l.rulesPoints(r.pointsEarn)),
                QuietLine(l.ptsRulesBase),
              ],
            ),
          AsyncError() => QuietLine(l.ptsCouldNotLoad),
          _ => const SizedBox(height: 40),
        },
        const SizedBox(height: DsSpacing.space10),
      ],
    );
  }
}

/// Reason words for the ledger. The wire says `d_award`; the screen says
/// 「{D} 给」. Exposed for tests.
String ledgerReason(L l, PointReason reason, String dName) => switch (reason) {
      PointReason.taskEarn => l.ptsReasonTaskEarn,
      PointReason.dAward => l.ptsReasonAward(dName),
      PointReason.dDeduct => l.ptsReasonDeduct(dName),
      PointReason.redemption => l.ptsReasonRedemption,
      PointReason.redemptionRefund => l.ptsReasonRefund,
      PointReason.unknown => l.ptsReasonOther,
    };

class _Line extends StatelessWidget {
  const _Line({required this.left, this.right, this.sub, this.dim = false, this.trailing});
  final String left;
  final String? right;
  final String? sub;
  final bool dim;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final color = dim ? DsColors.textOnRitualSecondary : DsColors.textOnRitualPrimary;
    return Padding(
      padding: todayInset.add(const EdgeInsets.symmetric(vertical: DsSpacing.space3)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(left, style: DsTextStyles.bodyPrimary.copyWith(color: color)),
                if (sub != null) ...[
                  const SizedBox(height: DsSpacing.space1),
                  Text(sub!, style: DsTextStyles.bodySecondary.copyWith(color: DsColors.textOnRitualSecondary)),
                ],
              ],
            ),
          ),
          if (right != null) ...[
            const SizedBox(width: DsSpacing.space3),
            Text(right!, style: DsTextStyles.bodySecondary.copyWith(color: color)),
          ],
          if (trailing != null) ...[const SizedBox(width: DsSpacing.space3), trailing!],
        ],
      ),
    );
  }
}

class _RewardRow extends StatelessWidget {
  const _RewardRow({
    required this.reward,
    required this.balance,
    required this.dName,
    required this.canRedeem,
    required this.onRedeem,
  });
  final Reward reward;
  final int balance;
  final String dName;
  final bool canRedeem;
  final VoidCallback onRedeem;

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    final cost = reward.cost;
    final right = cost == null
        ? l.rulesRewardDDecidesName(dName)
        : reward.affordable
            ? l.rulesPoints(cost)
            : l.ptsShort(cost - balance);
    return _Line(
      left: reward.title,
      sub: reward.detail,
      right: right,
      dim: !reward.affordable,
      trailing: canRedeem ? WordButton(label: l.rulesGoRedeem, onTap: onRedeem) : null,
    );
  }
}

class _RedemptionRow extends StatelessWidget {
  const _RedemptionRow({
    required this.redemption,
    required this.isD,
    required this.dName,
    required this.busy,
    required this.onApprove,
    required this.onDeny,
    required this.onFulfill,
  });
  final RedemptionView redemption;
  final bool isD;
  final String dName;
  final bool busy;
  final VoidCallback onApprove;
  final VoidCallback onDeny;
  final VoidCallback onFulfill;

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    final r = redemption;
    final status = switch (r.status) {
      'requested' => l.ptsStatusRequested(dName),
      'approved' => l.ptsStatusApproved(dName),
      'denied' => l.ptsStatusDenied(dName),
      'fulfilled' => l.ptsStatusFulfilled,
      _ => r.status,
    };
    Widget? trailing;
    if (!busy) {
      if (r.isRequested && isD) {
        trailing = Row(mainAxisSize: MainAxisSize.min, children: [
          WordButton(label: l.ptsApprove, onTap: onApprove, filled: true),
          const SizedBox(width: DsSpacing.space2),
          WordButton(label: l.ptsDeny, onTap: onDeny),
        ]);
      } else if (r.isApproved) {
        trailing = WordButton(label: l.ptsFulfill, onTap: onFulfill);
      }
    }
    return _Line(
      left: r.rewardTitle ?? '',
      sub: [status, if (r.note != null && r.note!.isNotEmpty) r.note!].join(' · '),
      dim: r.status == 'denied' || r.status == 'fulfilled',
      trailing: trailing,
    );
  }
}

class _ConsequenceRow extends StatelessWidget {
  const _ConsequenceRow({
    required this.consequence,
    required this.isD,
    required this.dName,
    required this.busy,
    required this.onDone,
    required this.onConfirm,
    required this.onWaive,
  });
  final ConsequenceView consequence;
  final bool isD;
  final String dName;
  final bool busy;
  final VoidCallback onDone;
  final VoidCallback onConfirm;
  final VoidCallback onWaive;

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    final c = consequence;
    final status = switch (c.status) {
      'issued' => l.ptsConsStatusIssued,
      'done_by_s' => l.ptsConsStatusDoneByS(dName),
      'confirmed' => l.ptsConsStatusConfirmed(dName),
      'waived' => l.ptsConsStatusWaived(dName),
      _ => c.status,
    };
    Widget? trailing;
    if (!busy) {
      if (c.isIssued && !isD) {
        trailing = WordButton(label: l.ptsConsequenceDone, onTap: onDone, filled: true);
      } else if (isD && c.isOpen) {
        trailing = Row(mainAxisSize: MainAxisSize.min, children: [
          WordButton(label: l.ptsConsequenceConfirm, onTap: onConfirm, filled: c.isDoneByS),
          const SizedBox(width: DsSpacing.space2),
          WordButton(label: l.ptsConsequenceWaive, onTap: onWaive),
        ]);
      }
    }
    return _Line(
      left: c.title,
      sub: [status, if (c.detail != null && c.detail!.isNotEmpty) c.detail!].join(' · '),
      dim: !c.isOpen,
      trailing: trailing,
    );
  }
}

class _LedgerRow extends StatelessWidget {
  const _LedgerRow({required this.entry, required this.dName});
  final PointEntry entry;
  final String dName;

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    final sign = entry.amount > 0 ? '+' : '';
    return _Line(
      left: ledgerReason(l, entry.reason, dName),
      sub: entry.note,
      right: '$sign${entry.amount}',
    );
  }
}
