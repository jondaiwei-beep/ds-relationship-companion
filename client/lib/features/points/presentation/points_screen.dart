import 'package:ds_relationship_companion/ds_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../app/shell/ds_glyph.dart';
import '../../../app/shell/ds_refreshable.dart';
import '../../../app/shell/ds_text_field.dart';
import '../../../domain_client/models/points.dart';
import '../../../l10n/app_localizations.dart';
import '../../today/presentation/widgets/today_layout.dart';

/// Points, rewards and what the couple agreed.
///
/// See `product/design/points-with-authority-and-warmth.md`. Three rules from
/// that document are load-bearing here and should not be relaxed without
/// reopening it:
///
/// 1. **The balance is an inventory, never a verdict.** It reads "3 points to
///    spend", it floors at zero, and it never appears beside a person's name
///    or face — a number next to a face is a rating of that face. Obedience
///    shows `♥ -152`, which tells someone their affection account is
///    overdrawn.
/// 2. **Every entry names a person.** "Alex noticed", not "+1 COMPLETION".
///    Even the automatic award is attributable, because Alex configured it.
/// 3. **Giving is first-class.** A reward can be handed over outright, with
///    no cost and no balance check. None of the three competitors can do this,
///    and it is the whole answer to "warmer": in their model the receiving
///    partner must earn everything and the giving partner is an accountant.
class PointsScreen extends ConsumerWidget {
  const PointsScreen({
    super.key,
    required this.dynamicId,
    required this.onBack,
    this.partnerName,
    this.partnerUserId,
  });

  final String dynamicId;
  final VoidCallback onBack;
  final String? partnerName;

  /// Needed to give or award. Null before anyone has joined.
  final String? partnerUserId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = L.of(context);
    final summary = ref.watch(pointsProvider(dynamicId));
    final rewards = ref.watch(rewardsProvider(dynamicId));
    final agreements = ref.watch(agreementsProvider(dynamicId));

    return Scaffold(
      backgroundColor: DsColors.canvasRitual,
      body: SafeArea(
        child: DsRefreshable(
          onRefresh: () async {
            ref.invalidate(pointsProvider(dynamicId));
            ref.invalidate(rewardsProvider(dynamicId));
            ref.invalidate(agreementsProvider(dynamicId));
            await ref.read(pointsProvider(dynamicId).future);
          },
          child: ListView(
            children: [
              _Header(title: l.pointsTitle, onBack: onBack),

              // The number, alone, as an inventory of what is available.
              switch (summary) {
                AsyncData(:final value) => _Balance(value.balance),
                _ => const SizedBox(height: 88),
              },

              const SizedBox(height: DsSpacing.space8),
              _SectionLabel(l.rewardsTitle.toUpperCase()),
              const SizedBox(height: DsSpacing.space4),
              switch (rewards) {
                AsyncData(:final value) when value.isEmpty =>
                  _Muted(l.rewardsEmpty),
                AsyncData(:final value) => Column(
                  children: [
                    for (final r in value)
                      _RewardRow(
                        reward: r,
                        dynamicId: dynamicId,
                        partnerUserId: partnerUserId,
                      ),
                  ],
                ),
                AsyncError() => _Muted(l.rewardsEmpty),
                _ => const SizedBox(height: 60),
              },

              _AddReward(dynamicId: dynamicId),

              const SizedBox(height: DsSpacing.space10),
              _SectionLabel(l.agreementsTitle.toUpperCase()),
              const SizedBox(height: DsSpacing.space3),
              _Muted(l.agreementsIntro),
              const SizedBox(height: DsSpacing.space4),
              switch (agreements) {
                AsyncData(:final value) when value.isEmpty =>
                  _Muted(l.agreementsEmpty),
                AsyncData(:final value) => Column(
                  children: [
                    for (final a in value)
                      _AgreementRow(agreement: a, dynamicId: dynamicId),
                    const SizedBox(height: DsSpacing.space2),
                    _Muted(l.agreementsEitherCanEnd),
                  ],
                ),
                AsyncError() => _Muted(l.agreementsEmpty),
                _ => const SizedBox(height: 40),
              },
              const SizedBox(height: DsSpacing.space4),
              _AddAgreement(dynamicId: dynamicId),

              const SizedBox(height: DsSpacing.space10),
              _SectionLabel(l.pointsHistory),
              const SizedBox(height: DsSpacing.space4),
              switch (summary) {
                AsyncData(:final value) when value.entries.isEmpty =>
                  _Muted(l.pointsNoneYet),
                AsyncData(:final value) => Column(
                  children: [
                    for (final e in value.entries)
                      _EntryRow(entry: e, partnerName: partnerName),
                  ],
                ),
                _ => const SizedBox.shrink(),
              },
              const SizedBox(height: DsSpacing.space10),
            ],
          ),
        ),
      ),
    );
  }
}

/// What is available to spend.
///
/// Deliberately not a "score" and deliberately alone on its line: the whole
/// sentence is about what the number lets you do, not about the person.
class _Balance extends StatelessWidget {
  const _Balance(this.balance);

  final int balance;

  @override
  Widget build(BuildContext context) => Padding(
    padding: todayInset,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // The sentence is the headline, not the digit.
        //
        // A 44pt numeral rendered as the largest thing on the screen — which
        // is what the first draft did — is the "number as verdict" this design
        // exists to avoid, whatever the label beneath it says. Obedience puts
        // a big number next to a heart; the size is most of why it reads as a
        // judgement. Here the number is set at body scale inside the phrase
        // that says what it is for.
        Text(
          L.of(context).pointsToSpend(balance),
          style: DsTextStyles.displayRitual.copyWith(
            color: DsColors.textOnRitualPrimary,
            fontSize: 22,
          ),
        ),
      ],
    ),
  );
}

class _RewardRow extends ConsumerStatefulWidget {
  const _RewardRow({
    required this.reward,
    required this.dynamicId,
    required this.partnerUserId,
  });

  final Reward reward;
  final String dynamicId;
  final String? partnerUserId;

  @override
  ConsumerState<_RewardRow> createState() => _RewardRowState();
}

class _RewardRowState extends ConsumerState<_RewardRow> {
  bool _busy = false;

  Future<void> _run(Future<void> Function() action) async {
    setState(() => _busy = true);
    try {
      await action();
      ref.invalidate(pointsProvider(widget.dynamicId));
      ref.invalidate(rewardsProvider(widget.dynamicId));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    final r = widget.reward;
    final repo = ref.read(pointsRepositoryProvider);

    return Padding(
      padding: todayInset.add(
        const EdgeInsets.only(bottom: DsSpacing.space4),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // flex 3/2 rather than Expanded + min-size actions: giving the
          // action row its natural width starved the title, which stacked
          // one word per line. The title is the content; the actions are
          // controls and can be the narrower half.
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  r.title,
                  style: DsTextStyles.bodyPrimary.copyWith(
                    color: DsColors.textOnRitualPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  r.cost == 0 ? l.rewardsCost(0) : l.rewardsCost(r.cost),
                  style: DsTextStyles.bodySecondary.copyWith(
                    color: DsColors.textOnRitualMuted,
                    fontSize: 11,
                  ),
                ),
                if (r.detail != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    r.detail!,
                    style: DsTextStyles.bodySecondary.copyWith(
                      color: DsColors.textOnRitualMuted,
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: DsSpacing.space3),

          // Two doors on one line. Stacked, they read as a menu belonging to
          // nothing in particular; side by side they clearly belong to the
          // reward on their left. Giving is first and is the emphasised one:
          // it is the warmest action in the product and costs the receiver
          // nothing.
          // Wrap, not Row: two labels plus "10 more to go" do not fit beside
          // a title on a 390pt screen, and a Row overflows rather than
          // reflowing. Wrap drops the second action onto its own line at the
          // widths where that is genuinely necessary, and keeps them side by
          // side everywhere else.
          Expanded(
            flex: 2,
            child: Wrap(
            alignment: WrapAlignment.end,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: DsSpacing.space1,
            children: [
              if (widget.partnerUserId != null)
                _Action(
                  label: l.rewardsGive,
                  emphasis: true,
                  onTap: _busy
                      ? null
                      : () => _run(
                          () => repo.gift(
                            widget.dynamicId,
                            r.id,
                            subjectUserId: widget.partnerUserId!,
                          ),
                        ),
                ),
              if (r.affordable)
                _Action(
                  label: l.rewardsTake,
                  onTap: _busy
                      ? null
                      : () => _run(() => repo.redeem(widget.dynamicId, r.id)),
                )
              else
                Padding(
                  padding: const EdgeInsets.only(left: DsSpacing.space2),
                  child: Text(
                    l.rewardsNotYet(r.cost),
                    textAlign: TextAlign.end,
                    style: DsTextStyles.bodySecondary.copyWith(
                      color: DsColors.textOnRitualMuted,
                      fontSize: 11,
                    ),
                  ),
                ),
              // Taking it off the list. Withdrawn, not deleted: history that
              // names it still reads.
              IconButton(
                onPressed: _busy
                    ? null
                    : () => _run(
                        () => repo.retireReward(widget.dynamicId, r.id),
                      ),
                icon: const DsGlyphIcon(DsGlyph.close, size: 16),
                tooltip: l.rewardsRemove(r.title),
                constraints: const BoxConstraints(),
                padding: const EdgeInsets.all(DsSpacing.space2),
              ),
            ],
            ),
          ),
        ],
      ),
    );
  }
}

/// One movement, written as something that happened between two people.
class _EntryRow extends StatelessWidget {
  const _EntryRow({required this.entry, required this.partnerName});

  final PointEntry entry;
  final String? partnerName;

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    final who = partnerName ?? l.askYourPartnerFallback;

    final sentence = switch (entry.reason) {
      PointReason.completion => l.pointsEntryNoticed(who),
      PointReason.manualAward => l.pointsEntryGave(who, entry.amount.abs()),
      PointReason.manualDeduct => l.pointsEntryHeld(who),
      PointReason.rewardPurchase => l.pointsEntryTook,
      PointReason.consequence => l.pointsEntryHeld(who),
    };

    return Padding(
      padding: todayInset.add(
        const EdgeInsets.only(bottom: DsSpacing.space3),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  sentence,
                  style: DsTextStyles.bodyPrimary.copyWith(
                    color: DsColors.textOnRitualPrimary,
                    fontSize: 14,
                  ),
                ),
                if (entry.note != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    entry.note!,
                    style: DsTextStyles.bodySecondary.copyWith(
                      color: DsColors.textOnRitualMuted,
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Text(
            entry.amount > 0 ? '+${entry.amount}' : '${entry.amount}',
            style: DsTextStyles.bodySecondary.copyWith(
              color: entry.amount > 0
                  ? DsPrimitiveColors.terracotta
                  : DsColors.textOnRitualMuted,
            ),
          ),
        ],
      ),
    );
  }
}

class _Action extends StatelessWidget {
  const _Action({
    required this.label,
    required this.onTap,
    this.emphasis = false,
  });

  final String label;
  final VoidCallback? onTap;

  /// Giving is the warmest action in the product and is not styled as the
  /// lesser of the two.
  final bool emphasis;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    child: Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: DsSpacing.space3,
        vertical: DsSpacing.space2,
      ),
      child: Text(
        label,
        style: DsTextStyles.labelRitual.copyWith(
          color: onTap == null
              ? DsColors.textOnRitualMuted
              : (emphasis
                    ? DsPrimitiveColors.terracotta
                    : DsColors.textOnRitualSecondary),
          fontSize: 12,
        ),
      ),
    ),
  );
}

/// Putting something on offer.
class _AddReward extends ConsumerStatefulWidget {
  const _AddReward({required this.dynamicId});

  final String dynamicId;

  @override
  ConsumerState<_AddReward> createState() => _AddRewardState();
}

class _AddRewardState extends ConsumerState<_AddReward> {
  final _title = TextEditingController();
  final _detail = TextEditingController();
  final _cost = TextEditingController(text: '1');
  bool _needsTitle = false;
  bool _busy = false;

  @override
  void dispose() {
    _title.dispose();
    _detail.dispose();
    _cost.dispose();
    super.dispose();
  }

  Future<void> _add() async {
    final t = _title.text.trim();
    if (t.isEmpty) {
      setState(() => _needsTitle = true);
      return;
    }
    setState(() => _busy = true);
    try {
      await ref.read(pointsRepositoryProvider).addReward(
        widget.dynamicId,
        title: t,
        detail: _detail.text.trim().isEmpty ? null : _detail.text.trim(),
        // A malformed cost is zero — on offer for nothing — rather than a
        // validation error. Nothing here is worth blocking someone over.
        cost: int.tryParse(_cost.text.trim()) ?? 0,
      );
      _title.clear();
      _detail.clear();
      ref.invalidate(rewardsProvider(widget.dynamicId));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    return Padding(
      padding: todayInset,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DsTextField(
            label: '',
            controller: _title,
            hint: l.rewardsAddHint,
            enabled: !_busy,
            error: _needsTitle ? l.rewardsNeedsTitle : null,
          ),
          const SizedBox(height: DsSpacing.space3),
          DsTextField(
            label: '',
            controller: _detail,
            hint: l.rewardsAddDetail,
            enabled: !_busy,
          ),
          const SizedBox(height: DsSpacing.space3),
          Row(
            children: [
              Expanded(
                child: Text(
                  l.rewardsAddCost,
                  style: DsTextStyles.bodySecondary.copyWith(
                    color: DsColors.textOnRitualMuted,
                    fontSize: 12,
                  ),
                ),
              ),
              SizedBox(
                width: 64,
                child: DsTextField(
                  label: '',
                  controller: _cost,
                  hint: '1',
                  enabled: !_busy,
                ),
              ),
            ],
          ),
          const SizedBox(height: DsSpacing.space3),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              onPressed: _busy ? null : _add,
              child: Text(
                l.rewardsAdd,
                style: DsTextStyles.labelRitual.copyWith(
                  color: DsPrimitiveColors.terracotta,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Writing down what the couple agreed happens.
///
/// Two fields, "when this happens" and "then", because an agreement that
/// names only the consequence is the vague kind their own writing says
/// "breeds resentment".
class _AddAgreement extends ConsumerStatefulWidget {
  const _AddAgreement({required this.dynamicId});

  final String dynamicId;

  @override
  ConsumerState<_AddAgreement> createState() => _AddAgreementState();
}

class _AddAgreementState extends ConsumerState<_AddAgreement> {
  final _when = TextEditingController();
  final _then = TextEditingController();
  final _cost = TextEditingController(text: '0');
  bool _incomplete = false;
  bool _busy = false;

  @override
  void dispose() {
    _when.dispose();
    _then.dispose();
    _cost.dispose();
    super.dispose();
  }

  Future<void> _add() async {
    final w = _when.text.trim();
    final t = _then.text.trim();
    if (w.isEmpty || t.isEmpty) {
      setState(() => _incomplete = true);
      return;
    }
    setState(() => _busy = true);
    try {
      await ref.read(pointsRepositoryProvider).addAgreement(
        widget.dynamicId,
        label: w,
        consequence: t,
        pointCost: int.tryParse(_cost.text.trim()) ?? 0,
      );
      _when.clear();
      _then.clear();
      ref.invalidate(agreementsProvider(widget.dynamicId));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    return Padding(
      padding: todayInset,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l.agreementsWhen,
            style: DsTextStyles.bodySecondary.copyWith(
              color: DsColors.textOnRitualMuted,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: DsSpacing.space2),
          DsTextField(
            label: '',
            controller: _when,
            hint: l.agreementsWhenHint,
            enabled: !_busy,
            error: _incomplete ? l.agreementsNeedsBoth : null,
          ),
          const SizedBox(height: DsSpacing.space4),
          Text(
            l.agreementsThen,
            style: DsTextStyles.bodySecondary.copyWith(
              color: DsColors.textOnRitualMuted,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: DsSpacing.space2),
          DsTextField(
            label: '',
            controller: _then,
            hint: l.agreementsThenHint,
            enabled: !_busy,
          ),
          const SizedBox(height: DsSpacing.space3),
          Row(
            children: [
              Expanded(
                child: Text(
                  l.agreementsCost,
                  style: DsTextStyles.bodySecondary.copyWith(
                    color: DsColors.textOnRitualMuted,
                    fontSize: 12,
                  ),
                ),
              ),
              SizedBox(
                width: 64,
                child: DsTextField(
                  label: '',
                  controller: _cost,
                  hint: '0',
                  enabled: !_busy,
                ),
              ),
            ],
          ),
          const SizedBox(height: DsSpacing.space3),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              onPressed: _busy ? null : _add,
              child: Text(
                l.agreementsAdd,
                style: DsTextStyles.labelRitual.copyWith(
                  color: DsPrimitiveColors.terracotta,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// One agreement, with the way out beside it.
class _AgreementRow extends ConsumerWidget {
  const _AgreementRow({required this.agreement, required this.dynamicId});

  final ConsequenceAgreement agreement;
  final String dynamicId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = L.of(context);
    return Padding(
      padding: todayInset.add(
        const EdgeInsets.only(bottom: DsSpacing.space4),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  agreement.label,
                  style: DsTextStyles.bodySecondary.copyWith(
                    color: DsColors.textOnRitualMuted,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  agreement.consequence,
                  style: DsTextStyles.bodyPrimary.copyWith(
                    color: DsColors.textOnRitualPrimary,
                  ),
                ),
              ],
            ),
          ),
          // Either of them, alone. An agreement you cannot leave is not one.
          IconButton(
            onPressed: () async {
              await ref
                  .read(pointsRepositoryProvider)
                  .endAgreement(dynamicId, agreement.id);
              ref.invalidate(agreementsProvider(dynamicId));
            },
            icon: const DsGlyphIcon(DsGlyph.close, size: 18),
            tooltip: l.agreementsEnd(agreement.label),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.title, required this.onBack});

  final String title;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) => Padding(
    padding: todayInset,
    child: Row(
      children: [
        IconButton(
          onPressed: onBack,
          icon: DsGlyphIcon(
            DsGlyph.back,
            semanticLabel: L.of(context).shellBack,
          ),
        ),
        const SizedBox(width: DsSpacing.space2),
        Text(
          title.toUpperCase(),
          style: DsTextStyles.labelRitual.copyWith(
            color: DsColors.textOnRitualPrimary,
          ),
        ),
      ],
    ),
  );
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: todayInset,
    child: Text(
      text,
      style: DsTextStyles.labelRitual.copyWith(
        color: DsColors.textOnRitualMuted,
        fontSize: 10,
        letterSpacing: 1.9,
      ),
    ),
  );
}

class _Muted extends StatelessWidget {
  const _Muted(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: todayInset,
    child: Text(
      text,
      style: DsTextStyles.bodySecondary.copyWith(
        color: DsColors.textOnRitualMuted,
      ),
    ),
  );
}
