import 'package:ds_relationship_companion/ds_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../app/shell/bottom_navigation.dart';
import '../../../app/shell/ds_refreshable.dart';
import '../../../app/shell/page_hero.dart';
import '../../../domain_client/api_client.dart';
import '../../../domain_client/models/consequence.dart';
import '../../../domain_client/models/points.dart';
import '../../../domain_client/models/redemption.dart';
import '../../../domain_client/models/today_view.dart' show TodayView;
import '../../../l10n/app_localizations.dart';
import '../../dynamic/application/dynamic_providers.dart';
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
import '../../today/presentation/widgets/today_notice.dart';
import '../../today/presentation/widgets/word_button.dart';
import '../application/points_providers.dart';

/// Tab 4 · 分 (product/02-surfaces.md; design/system/redesign-2026-09.md §7).
///
/// The balance is the page's one anchor. Under it: the last movement or why
/// there is none, Give/Deduct for the D, what the s can redeem, the asks and
/// consequences in flight (only when there are any), and the ledger. The
/// number is the s's on both faces; the D gives and takes by hand. Nothing
/// here is automatic, nothing is on a clock.
class PointsScreen extends ConsumerStatefulWidget {
  const PointsScreen({
    super.key,
    required this.dynamicId,
    this.onSignIn,
    this.onSelectTab,
    this.onRules,
  });

  final String dynamicId;
  final VoidCallback? onSignIn;
  final void Function(NavSurface surface)? onSelectTab;

  /// Opens 规矩, where rewards are set. Null hides the way there.
  final VoidCallback? onRules;

  @override
  ConsumerState<PointsScreen> createState() => _PointsScreenState();
}

class _PointsScreenState extends ConsumerState<PointsScreen> {
  String? _notice;
  bool _busy = false;

  /// The ledger opens on its last three lines; this shows the rest in place.
  bool _ledgerExpanded = false;

  /// How many ledger lines show before "All entries".
  static const _ledgerPreview = 3;

  String get _id => widget.dynamicId;

  void _reloadAll() {
    ref.invalidate(todayProvider(_id));
    ref.invalidate(pointsProvider(_id));
    ref.invalidate(rewardsProvider(_id));
    ref.invalidate(redemptionsProvider(_id));
    ref.invalidate(consequencesProvider(_id));
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

  String _dName(L l, TodayView v) => v.isD ? l.rulesYou : (v.partnerDisplayName ?? l.todayPartnerFallback);
  String _sName(L l, TodayView v) => v.isD ? (v.partnerDisplayName ?? l.todayPartnerFallback) : l.rulesYou;

  /// The line under the number: the most recent movement, written the way a
  /// ledger row reads ("+3 · {D} gave · washed the car"), or — when there is
  /// none — where points come from. Never a zero dressed up as news.
  String? _support(L l, AsyncValue<PointsSummary> points, String dName) {
    return switch (points) {
      AsyncData(:final value) when value.entries.isNotEmpty => _ledgerLine(l, value.entries.first, dName),
      AsyncData() => l.ptsHeroEmpty(dName),
      // Still loading or failed: the ledger section below says which.
      _ => null,
    };
  }

  String _ledgerLine(L l, PointEntry e, String dName) {
    final sign = e.amount > 0 ? '+' : '';
    return [
      '$sign${e.amount}',
      ledgerReason(l, e.reason, dName),
      if (e.note case final note? when note.isNotEmpty) note,
    ].join(' · ');
  }

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
    final consequences = ref.watch(consequencesProvider(_id));
    final rules = ref.watch(pointsRulesProvider(_id));
    // Stage before data (redesign §3): a partner who has not joined cannot be
    // given to. Null detail (still loading) is treated as joined, as Today does.
    final alone = TodayNotice.isAlone(ref.watch(dynamicDetailProvider(_id)).value);
    final dName = _dName(l, v);
    final sName = _sName(l, v);
    final balance = points.asData?.value.balance ?? v.balance;
    final rewardList = rewards.asData?.value ?? const <Reward>[];
    final muted = DsTextStyles.bodySecondary.copyWith(color: DsColors.textOnRitualMuted);

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        // No small title: the number below is the page's name.
        TodayHeader(partnerName: v.partnerDisplayName),

        // ── the anchor
        PageHero(
          eyebrow: v.isD ? l.ptsHeroEyebrowD(sName) : l.ptsHeroEyebrowMine,
          hero: l.ptsBalanceMine(balance),
          heroKey: const ValueKey('points-balance'),
          // Alone, one sentence says it all; three lines about a zero did not.
          support: alone ? l.todayStartsWhenJoined : _support(l, points, dName),
        ),
        const SizedBox(height: DsSpacing.space6),

        // ── give / deduct — the D's, and only once there is someone to give to
        if (v.isD && !alone)
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
        if (_notice != null) ...[
          const SizedBox(height: DsSpacing.space3),
          Padding(padding: todayInset, child: RecoveryMessage(_notice!)),
        ],

        // ── 可兑换
        const SizedBox(height: DsSpacing.space10),
        SectionLabel(l.ptsRedeemableTitle),
        switch (rewards) {
          AsyncData(:final value) when value.isEmpty => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                QuietLine(l.ptsRedeemableEmpty),
                if (widget.onRules case final rules?)
                  Padding(
                    padding: todayInset,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: WordButton(label: l.ptsRedeemableSetInRules, quiet: true, onTap: rules),
                    ),
                  ),
              ],
            ),
          AsyncData(:final value) => Column(
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

        // ── 兑换申请 — only when there are any (redesign §4)
        if (redemptions case AsyncData(:final value) when value.isNotEmpty) ...[
          const SizedBox(height: DsSpacing.space8),
          SectionLabel(l.ptsRequestsTitle),
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

        // ── 罚 — only when there are any
        if (consequences case AsyncData(:final value) when value.isNotEmpty) ...[
          const SizedBox(height: DsSpacing.space8),
          SectionLabel(l.ptsConsequencesTitle),
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

        // ── 流水 — the last three, the rest on request
        const SizedBox(height: DsSpacing.space8),
        SectionLabel(l.ptsLedgerTitle),
        switch (points) {
          AsyncData(:final value) when value.entries.isEmpty => QuietLine(l.ptsLedgerEmpty),
          AsyncData(:final value) => Column(
              children: [
                for (final e in _ledgerExpanded ? value.entries : value.entries.take(_ledgerPreview))
                  _LedgerRow(entry: e, dName: dName),
                if (!_ledgerExpanded && value.entries.length > _ledgerPreview)
                  Padding(
                    padding: todayInset,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: WordButton(
                        key: const ValueKey('points-ledger-all'),
                        label: l.ptsLedgerAll,
                        quiet: true,
                        onTap: () => setState(() => _ledgerExpanded = true),
                      ),
                    ),
                  ),
              ],
            ),
          AsyncError() => QuietLine(l.ptsCouldNotLoad),
          _ => const SizedBox(height: 40),
        },

        // ── 哪些任务给分 — which tasks pay (D-05); only when any do
        if (rules case AsyncData(:final value) when value.isNotEmpty) ...[
          const SizedBox(height: DsSpacing.space8),
          SectionLabel(l.ptsRulesTitle),
          for (final r in value)
            Padding(
              padding: todayInset.add(const EdgeInsets.symmetric(vertical: DsSpacing.space2)),
              child: Row(
                children: [
                  Expanded(child: Text(r.title, style: muted)),
                  const SizedBox(width: DsSpacing.space3),
                  Text(l.rulesPoints(r.pointsEarn), style: muted),
                ],
              ),
            ),
          QuietLine(l.ptsRulesBase),
        ],
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
