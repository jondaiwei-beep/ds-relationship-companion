import 'package:ds_relationship_companion/ds_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../app/shell/bottom_navigation.dart';
import '../../../app/shell/ds_glyph.dart';
import '../../../app/shell/ds_refreshable.dart';
import '../../../app/shell/ds_text_field.dart';
import '../../../domain_client/models/points.dart';
import '../../../l10n/app_localizations.dart';
import '../../today/presentation/widgets/secondary_button.dart';
import '../../today/presentation/widgets/section_label.dart';
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
/// 2. **Every entry names a person.** "Alex noticed", not "+1 task_earn".
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
    this.onSelectTab,
  });

  final String dynamicId;
  final VoidCallback onBack;
  final String? partnerName;

  /// Needed to give or award. Null before anyone has joined.
  final String? partnerUserId;

  /// Set when this is a tab root, so the bar is shown and works.
  final void Function(NavSurface surface)? onSelectTab;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = L.of(context);
    final summary = ref.watch(pointsProvider(dynamicId));
    final rewards = ref.watch(rewardsProvider(dynamicId));
    final agreements = ref.watch(agreementsProvider(dynamicId));

    return Scaffold(
      backgroundColor: DsColors.canvasRitual,
      bottomNavigationBar: onSelectTab == null
          ? null
          : DsBottomNavigation(
              current: NavSurface.points,
              onSelect: onSelectTab,
            ),
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
                AsyncData(:final value) => _Balance(
                  balance: value.balance,
                  daysTogether: value.daysTogether,
                ),
                _ => const SizedBox(height: 88),
              },

              const SizedBox(height: DsSpacing.space10),
              SectionLabel(l.rewardsTitle.toUpperCase()),
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

              const SizedBox(height: DsSpacing.space5),
              _AddReward(dynamicId: dynamicId),

              const SizedBox(height: DsSpacing.space10),
              SectionLabel(l.agreementsTitle.toUpperCase()),
              _Muted(l.agreementsIntro),
              const SizedBox(height: DsSpacing.space5),
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
              const SizedBox(height: DsSpacing.space5),
              _AddAgreement(dynamicId: dynamicId),

              const SizedBox(height: DsSpacing.space10),
              SectionLabel(l.pointsHistory),
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
/// What is available, and how long this has been going.
///
/// Given the vertical authority rule the rest of the product uses for a block
/// that matters, rather than three grey lines stacked at equal weight. The
/// first draft of this screen had no hierarchy at all: everything was the
/// same size at the same interval, so nothing read as more important than
/// anything else.
class _Balance extends StatelessWidget {
  const _Balance({required this.balance, required this.daysTogether});

  final int balance;

  /// One line, not a second counter. Kneel puts BALANCE and STREAK side by
  /// side and the screen opens with two numbers competing for one glance.
  final int daysTogether;

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    return Padding(
      padding: const EdgeInsets.only(left: DsSpacing.space5),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: DsBorderWidths.selected,
              color: DsPrimitiveColors.terracotta,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  DsSpacing.space5,
                  DsSpacing.space2,
                  DsSpacing.space5,
                  DsSpacing.space2,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l.pointsSpendable,
                      style: DsTextStyles.labelRitual.copyWith(
                        color: DsColors.textOnRitualMuted,
                        fontSize: 10,
                        letterSpacing: 1.9,
                      ),
                    ),
                    const SizedBox(height: DsSpacing.space2),
                    Text(
                      l.pointsToSpend(balance),
                      style: DsTextStyles.displayRitual.copyWith(
                        color: DsColors.textOnRitualPrimary,
                        fontSize: 26,
                      ),
                    ),
                    const SizedBox(height: DsSpacing.space4),
                    Text(
                      l.pointsDaysTogether(daysTogether),
                      style: DsTextStyles.bodyPrimary.copyWith(
                        color: DsColors.textOnRitualSecondary,
                      ),
                    ),
                    const SizedBox(height: DsSpacing.space1),
                    // Said out loud, because every other app in this category
                    // has taught people a number like this can be lost.
                    Text(
                      l.pointsDaysNeverResets,
                      style: DsTextStyles.bodySecondary.copyWith(
                        color: DsColors.textOnRitualMuted,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
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
      PointReason.taskEarn => l.pointsEntryNoticed(who),
      PointReason.dAward => l.pointsEntryGave(who, entry.amount.abs()),
      PointReason.dDeduct => l.pointsEntryHeld(who),
      PointReason.redemption => l.pointsEntryTook,
      PointReason.redemptionRefund => l.pointsEntryRefunded,
      PointReason.unknown => l.pointsEntryMoved(entry.amount),
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
///
/// Collapsed until asked for. The first version rendered the form open,
/// always, directly beneath the words "Nothing on offer yet" — an empty state
/// and an editing form competing in the same block, so neither read as
/// anything. Bare hint text with no labels and no grouping made it look like
/// a debug screen rather than a product.
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
  bool _open = false;
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
      if (mounted) setState(() => _open = false);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);

    if (!_open) {
      return Padding(
        padding: todayInset,
        child: SecondaryButton(
          label: l.rewardsAddOpen,
          onTap: () => setState(() => _open = true),
        ),
      );
    }

    return _Sheet(
      children: [
        _Field(
          label: l.rewardsAddTitle,
          controller: _title,
          hint: l.rewardsAddHint,
          enabled: !_busy,
          error: _needsTitle ? l.rewardsNeedsTitle : null,
        ),
        const SizedBox(height: DsSpacing.space5),
        _Field(
          label: l.rewardsAddDetail,
          controller: _detail,
          hint: '',
          enabled: !_busy,
        ),
        const SizedBox(height: DsSpacing.space5),
        _CostField(
          label: l.rewardsAddCost,
          controller: _cost,
          enabled: !_busy,
        ),
        const SizedBox(height: DsSpacing.space6),
        _SheetActions(
          busy: _busy,
          saveLabel: l.rewardsAddSave,
          cancelLabel: l.rewardsAddCancel,
          onSave: _add,
          onCancel: () => setState(() {
            _open = false;
            _needsTitle = false;
          }),
        ),
      ],
    );
  }
}

/// Writing down what the couple agreed happens.
///
/// Collapsed until asked for, like the reward form. Two fields, "when this
/// happens" and "then", because an agreement naming only the consequence is
/// the vague kind their own writing says breeds resentment.
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
  bool _open = false;
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
      if (mounted) setState(() => _open = false);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);

    if (!_open) {
      return Padding(
        padding: todayInset,
        child: SecondaryButton(
          label: l.agreementsAddOpen,
          onTap: () => setState(() => _open = true),
        ),
      );
    }

    return _Sheet(
      children: [
        _Field(
          label: l.agreementsWhen,
          controller: _when,
          hint: l.agreementsWhenHint,
          enabled: !_busy,
          error: _incomplete ? l.agreementsNeedsBoth : null,
        ),
        const SizedBox(height: DsSpacing.space5),
        _Field(
          label: l.agreementsThen,
          controller: _then,
          hint: l.agreementsThenHint,
          enabled: !_busy,
        ),
        const SizedBox(height: DsSpacing.space5),
        _CostField(
          label: l.agreementsCost,
          controller: _cost,
          enabled: !_busy,
        ),
        const SizedBox(height: DsSpacing.space6),
        _SheetActions(
          busy: _busy,
          saveLabel: l.agreementsAddSave,
          cancelLabel: l.agreementsAddCancel,
          onSave: _add,
          onCancel: () => setState(() {
            _open = false;
            _incomplete = false;
          }),
        ),
      ],
    );
  }
}

/// The shared shell for an open form: inset, raised, and set apart from the
/// list it belongs to so it reads as a thing you are doing rather than more
/// rows.
class _Sheet extends StatelessWidget {
  const _Sheet({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Padding(
    padding: todayInset,
    child: Container(
      padding: const EdgeInsets.all(DsSpacing.space5),
      decoration: BoxDecoration(
        color: DsColors.surfaceRitualRaised,
        border: Border.all(
          color: DsColors.textOnRitualMuted.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    ),
  );
}

/// A labelled field. The first version had none — just hint text floating in
/// the dark, so an empty form said nothing about what it wanted.
class _Field extends StatelessWidget {
  const _Field({
    required this.label,
    required this.controller,
    required this.hint,
    required this.enabled,
    this.error,
  });

  final String label;
  final TextEditingController controller;
  final String hint;
  final bool enabled;
  final String? error;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label.toUpperCase(),
        style: DsTextStyles.labelRitual.copyWith(
          color: DsColors.textOnRitualMuted,
          fontSize: 10,
          letterSpacing: 1.6,
        ),
      ),
      const SizedBox(height: DsSpacing.space2),
      DsTextField(
        label: '',
        controller: controller,
        hint: hint,
        enabled: enabled,
        error: error,
      ),
    ],
  );
}

/// The number, kept beside its own label rather than stranded on a lonely
/// underline half a screen away from what it means.
class _CostField extends StatelessWidget {
  const _CostField({
    required this.label,
    required this.controller,
    required this.enabled,
  });

  final String label;
  final TextEditingController controller;
  final bool enabled;

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.end,
    children: [
      Expanded(
        child: Text(
          label,
          style: DsTextStyles.bodySecondary.copyWith(
            color: DsColors.textOnRitualSecondary,
          ),
        ),
      ),
      const SizedBox(width: DsSpacing.space4),
      SizedBox(
        width: 56,
        child: DsTextField(
          label: '',
          controller: controller,
          hint: '0',
          enabled: enabled,
        ),
      ),
    ],
  );
}

/// Save and cancel, as buttons rather than as letter-spaced text that reads
/// like a heading.
class _SheetActions extends StatelessWidget {
  const _SheetActions({
    required this.busy,
    required this.saveLabel,
    required this.cancelLabel,
    required this.onSave,
    required this.onCancel,
  });

  final bool busy;
  final String saveLabel;
  final String cancelLabel;
  final VoidCallback onSave;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: SecondaryButton(
          label: cancelLabel,
          onTap: busy ? () {} : onCancel,
        ),
      ),
      const SizedBox(width: DsSpacing.space3),
      Expanded(
        child: SecondaryButton(
          label: saveLabel,
          filled: true,
          onTap: busy ? () {} : onSave,
        ),
      ),
    ],
  );
}

/// One agreement, with the way out beside it./// One agreement, with the way out beside it.
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
