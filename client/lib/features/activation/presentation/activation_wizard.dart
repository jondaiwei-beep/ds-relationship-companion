import 'package:ds_relationship_companion/ds_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../platform/session/session.dart';
import '../../../platform/session/session_controller.dart';
import '../application/activation_actions.dart';
import 'widgets/wizard_frame.dart';

/// SCR-31 / 07 / 08 / 12 — activation, as one wizard.
///
/// Four screens in the design, one widget here, because they are four
/// questions about a single thing that does not exist yet. Nothing reaches the
/// server until the last step: `ActivationDraft` holds the answers so a person
/// can go back and change one without anything having been written.
///
/// The order is the product's, and it is not arbitrary (`REQ-ACT-001`): what do
/// you want, then who with, then how much structure, then the first rhythm. A
/// product that asks "are you dominant or submissive" before "what do you want"
/// has framed the relationship for them.
class ActivationWizard extends ConsumerStatefulWidget {
  const ActivationWizard({
    super.key,
    required this.onStarted,
    required this.onLeave,
    required this.timezone,
  });

  /// The dynamic exists and its first rhythm has begun.
  final void Function(String dynamicId) onStarted;

  /// Backing out of the first step.
  final VoidCallback onLeave;

  /// The device's IANA zone. Passed in rather than read here so the wizard
  /// stays testable and the platform lookup has one home.
  final String timezone;

  @override
  ConsumerState<ActivationWizard> createState() => _ActivationWizardState();
}

class _ActivationWizardState extends ConsumerState<ActivationWizard> {
  var _draft = const ActivationDraft();
  int _step = 1;

  /// True once a role has been named. Distinct from `rolePreset == null`,
  /// which is also what "I'd rather not name one" produces — the difference
  /// is whether the person has answered, not what they answered.
  bool _roleNamed = false;

  bool _busy = false;
  String? _unmet;
  String? _failure;

  void _back() {
    setState(() {
      _unmet = null;
      _failure = null;
      if (_step == 1) {
        widget.onLeave();
      } else {
        _step--;
      }
    });
  }

  void _advance({String? unmetReason, bool satisfied = true}) {
    setState(() {
      if (!satisfied) {
        _unmet = unmetReason;
        return;
      }
      _unmet = null;
      _step++;
    });
  }

  Future<void> _start() async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _failure = null;
      _unmet = null;
    });

    final draft = _draft.copyWith(timezone: widget.timezone);
    final created = await ref
        .read(activationActionsProvider)
        .createDynamic(draft);

    if (!mounted) return;
    switch (created) {
      case ActivationFailed(:final message):
        setState(() {
          _busy = false;
          _failure = message;
        });
      case DynamicCreated(:final dynamicId):
        final session = ref.read(sessionProvider);
        final me = session is Authenticated ? session.userId : null;
        if (me == null) {
          setState(() {
            _busy = false;
            _failure =
                'Your session ended. Sign in again to finish setting '
                'this up.';
          });
          return;
        }
        // The Dynamic exists; the rhythm is a second command. A failure here
        // must not read as "nothing happened", because something did.
        final started = await ref
            .read(activationActionsProvider)
            .startRhythm(dynamicId, assigneeUserId: me);
        if (!mounted) return;
        switch (started) {
          case DynamicCreated():
            setState(() => _busy = false);
            widget.onStarted(dynamicId);
          case ActivationFailed(:final message):
            setState(() {
              _busy = false;
              _failure = message;
            });
        }
    }
  }

  @override
  Widget build(BuildContext context) {
    final notice = _failure == null ? null : _Notice(_failure!);
    return switch (_step) {
      1 => _GoalStep(
        chosen: _draft.outcome,
        unmet: _unmet,
        notice: notice,
        onChoose: (o) => setState(() {
          _draft = _draft.copyWith(outcome: o);
          _unmet = null;
        }),
        onBack: _back,
        onContinue: () => _advance(
          satisfied: _draft.outcome != null,
          unmetReason: 'Choose one to continue.',
        ),
      ),
      2 => _RoleStep(
        solo: _draft.solo,
        role: _draft.rolePreset,
        named: _roleNamed,
        unmet: _unmet,
        notice: notice,
        onSolo: (v) => setState(() {
          _draft = _draft.copyWith(solo: v);
          _unmet = null;
        }),
        onRole: (r) => setState(() {
          _draft = _draft.copyWith(rolePreset: r);
          _roleNamed = true;
        }),
        onDecline: () => setState(() {
          _draft = _draft.copyWith(clearRolePreset: true);
          _roleNamed = false;
        }),
        onBack: _back,
        onContinue: () => _advance(),
      ),
      3 => _StructureStep(
        level: _draft.structure,
        longDistance: _draft.longDistance,
        timezone: widget.timezone,
        notice: notice,
        onLevel: (l) => setState(() => _draft = _draft.copyWith(structure: l)),
        onLongDistance: (v) =>
            setState(() => _draft = _draft.copyWith(longDistance: v)),
        onBack: _back,
        onContinue: () => _advance(),
      ),
      _ => _RhythmStep(
        solo: _draft.solo,
        busy: _busy,
        notice: notice,
        onBack: _back,
        onStart: _start,
      ),
    };
  }
}

// ---------------------------------------------------------------------------
// 1 · What do you want more of

const _goals = <(DesiredOutcome, String)>[
  (DesiredOutcome.closer, 'Closer'),
  (DesiredOutcome.structure, 'Structure'),
  (DesiredOutcome.service, 'Service & devotion'),
  (DesiredOutcome.accountability, 'Accountability'),
  (DesiredOutcome.explore, 'Explore together'),
];

class _GoalStep extends StatelessWidget {
  const _GoalStep({
    required this.chosen,
    required this.unmet,
    required this.notice,
    required this.onChoose,
    required this.onBack,
    required this.onContinue,
  });

  final DesiredOutcome? chosen;
  final String? unmet;
  final Widget? notice;
  final ValueChanged<DesiredOutcome> onChoose;
  final VoidCallback onBack;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    return WizardFrame(
      step: 1,
      // No back arrow: this is the first question, and leaving is a different
      // act from going back one step.
      onBack: null,
      lead: const DsSvg(
        asset: DsAssets.markAuthority,
        tone: DsAssetTone.primary,
        width: 32,
        height: 32,
      ),
      eyebrow: 'BEGIN WITH INTENTION',
      question: 'What would you\nlike more of now?',
      support:
          'Choose the feeling you want your\n'
          'dynamic to hold. You can change this later.',
      footnote: 'This shapes your starting rhythm—not your limits.',
      unmet: unmet,
      notice: notice,
      actionLabel: 'Continue',
      onAction: onContinue,
      child: Stack(
        children: [
          // Decorative only, behind the choices and clear of their targets.
          const Positioned(
            right: -8,
            top: 0,
            child: Opacity(
              opacity: 0.5,
              child: DsSvg(
                asset: DsAssets.motifBotanicalGoalBranch,
                tone: DsAssetTone.decorative,
                width: 160,
                height: 160,
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final (index, (outcome, label)) in _goals.indexed)
                _Choice(
                  label: label,
                  selected: chosen == outcome,
                  // The rule joins the choices into one question rather than
                  // five: it stops at the last, which has nothing below it.
                  connected: index < _goals.length - 1,
                  onTap: () => onChoose(outcome),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// One goal. The selected one grows into Cormorant and takes a rule beneath
/// it — the design makes the choice legible from across the room rather than
/// by a dot alone.
class _Choice extends StatelessWidget {
  const _Choice({
    required this.label,
    required this.selected,
    required this.connected,
    required this.onTap,
  });

  final String label;
  final bool selected;

  /// Draw the rule down to the next choice.
  final bool connected;

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      selected: selected,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          height: 60,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 16,
                child: Column(
                  children: [
                    const SizedBox(height: 4),
                    _Radio(selected: selected),
                    if (connected)
                      Expanded(
                        child: Container(
                          width: DsBorderWidths.hairline,
                          color: DsColors.borderOnRitualHairline,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: DsSpacing.space4),
              // Bounded: the selected label grows to 20px Cormorant, and
              // "Service & devotion" at that size overflows an unbounded row.
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: selected
                          ? DsTextStyles.displayRitual.copyWith(
                              color: DsColors.textOnRitualPrimary,
                              fontSize: 20,
                              height: 1.1,
                            )
                          : DsTextStyles.bodyPrimary.copyWith(
                              color: DsColors.textOnRitualSecondary,
                              fontSize: 15,
                            ),
                    ),
                    if (selected) ...[
                      const SizedBox(height: DsSpacing.space2),
                      Container(
                        width: 108,
                        height: DsBorderWidths.hairline,
                        color: DsPrimitiveColors.terracotta,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Radio extends StatelessWidget {
  const _Radio({required this.selected, this.size = 16});

  final bool selected;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: DsColors.canvasRitual,
        border: Border.all(
          color: selected
              ? DsPrimitiveColors.terracotta
              : DsColors.borderOnRitualHairline,
          width: 1.2,
        ),
      ),
      child: selected
          ? Center(
              child: Container(
                width: size / 2,
                height: size / 2,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: DsPrimitiveColors.terracotta,
                ),
              ),
            )
          : null,
    );
  }
}

// ---------------------------------------------------------------------------
// 2 · Who is beginning this

const _roles = <(RolePreset, String)>[
  (RolePreset.dominant, 'Dominant'),
  (RolePreset.submissive, 'submissive'),
  (RolePreset.switchRole, 'Switch'),
  (RolePreset.custom, 'Custom'),
];

class _RoleStep extends StatelessWidget {
  const _RoleStep({
    required this.solo,
    required this.role,
    required this.named,
    required this.unmet,
    required this.notice,
    required this.onSolo,
    required this.onRole,
    required this.onDecline,
    required this.onBack,
    required this.onContinue,
  });

  final bool solo;
  final RolePreset? role;
  final bool named;
  final String? unmet;
  final Widget? notice;
  final ValueChanged<bool> onSolo;
  final ValueChanged<RolePreset> onRole;
  final VoidCallback onDecline;
  final VoidCallback onBack;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    return WizardFrame(
      step: 2,
      onBack: onBack,
      eyebrow: 'BEGIN TOGETHER',
      question: 'Who is beginning\nthis with you?',
      support: 'Start privately or open this space with a partner.',
      footnote: 'A starting point, not a limit.\nYou can change this later.',
      unmet: unmet,
      notice: notice,
      actionLabel: 'Continue',
      onAction: onContinue,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Two circles rather than a switch: beginning alone is a real
          // choice, not the off position of something else.
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _Companion(
                label: 'With a partner',
                selected: !solo,
                // `mark.partner-bond` licenses only primary and relationship
                // — the freeze refusing to let the bond between two people be
                // a dimmed decoration. Unselected keeps `primary` and is
                // distinguished by its ring.
                asset: DsAssets.markPartnerBond,
                tone: solo ? DsAssetTone.primary : DsAssetTone.relationship,
                markSize: 40,
                onTap: () => onSolo(false),
              ),
              _Companion(
                label: 'For myself',
                selected: solo,
                asset: DsAssets.iconPrivateSpace,
                tone: solo ? DsAssetTone.primary : DsAssetTone.muted,
                markSize: 28,
                onTap: () => onSolo(true),
              ),
            ],
          ),
          const SizedBox(height: DsSpacing.space8),
          Text(
            'YOUR STARTING ROLE',
            style: DsTextStyles.labelRitual.copyWith(
              color: DsColors.textOnRitualMuted,
              fontSize: 10,
              letterSpacing: 1.9,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: DsSpacing.space5),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (final (preset, label) in _roles)
                Expanded(
                  child: InkWell(
                    onTap: () => onRole(preset),
                    child: Column(
                      children: [
                        _Radio(selected: named && role == preset, size: 18),
                        const SizedBox(height: DsSpacing.space3),
                        Text(
                          label,
                          textAlign: TextAlign.center,
                          style: DsTextStyles.bodySecondary.copyWith(
                            fontSize: 11,
                            color: named && role == preset
                                ? DsColors.textOnRitualPrimary
                                : DsColors.textOnRitualMuted,
                            fontWeight: named && role == preset
                                ? FontWeight.w600
                                : FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: DsSpacing.space6),
          // Not a lesser option. A couple that does not want to name a role
          // must not be blocked — the column is nullable at every layer for
          // exactly this reason (red line #4).
          InkWell(
            onTap: onDecline,
            child: Container(
              height: 44,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: named
                    ? DsColors.canvasRitual
                    : DsColors.surfaceRitualRaised,
                borderRadius: BorderRadius.circular(DsRadii.medium),
                border: Border.all(
                  color: named
                      ? DsColors.borderOnRitualHairline
                      : DsPrimitiveColors.terracotta,
                  width: DsBorderWidths.hairline,
                ),
              ),
              child: Text(
                "I'd rather not name one",
                style: DsTextStyles.bodySecondary.copyWith(
                  fontSize: 13,
                  color: named
                      ? DsColors.textOnRitualMuted
                      : DsColors.textOnRitualPrimary,
                  fontWeight: named ? FontWeight.w400 : FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Companion extends StatelessWidget {
  const _Companion({
    required this.label,
    required this.selected,
    required this.asset,
    required this.tone,
    required this.markSize,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final DsAssetId asset;
  final DsAssetTone tone;
  final double markSize;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      selected: selected,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Container(
          width: 116,
          height: 116,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: selected
                  ? DsPrimitiveColors.terracotta
                  : DsColors.borderOnRitualHairline,
              width: selected ? 1.3 : 1,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              DsSvg(
                asset: asset,
                tone: tone,
                width: markSize,
                height: markSize,
              ),
              const SizedBox(height: DsSpacing.space3),
              Text(
                label,
                style: DsTextStyles.bodySecondary.copyWith(
                  fontSize: 12,
                  color: selected
                      ? DsColors.textOnRitualPrimary
                      : DsColors.textOnRitualMuted,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 3 · How much structure

const _levels = <(StructureLevel, String, String)>[
  (StructureLevel.light, 'Light', 'A gentle rhythm with plenty of room.'),
  (StructureLevel.steady, 'Steady', 'Clear expectations with room to adjust.'),
  (StructureLevel.defined, 'Defined', 'A firm shape you both agreed to.'),
];

class _StructureStep extends StatelessWidget {
  const _StructureStep({
    required this.level,
    required this.longDistance,
    required this.timezone,
    required this.notice,
    required this.onLevel,
    required this.onLongDistance,
    required this.onBack,
    required this.onContinue,
  });

  final StructureLevel level;
  final bool longDistance;
  final String timezone;
  final Widget? notice;
  final ValueChanged<StructureLevel> onLevel;
  final ValueChanged<bool> onLongDistance;
  final VoidCallback onBack;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final current = _levels.firstWhere((l) => l.$1 == level);
    return WizardFrame(
      step: 3,
      onBack: onBack,
      eyebrow: 'YOUR STRUCTURE',
      question: 'How much structure\nfeels right?',
      support:
          "Choose a starting rhythm. Nothing here\n"
          "removes either person's voice.",
      footnote: 'You can refine this together later.',
      notice: notice,
      actionLabel: 'Continue',
      onAction: onContinue,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (final (l, _, _) in _levels)
                InkWell(
                  onTap: () => onLevel(l),
                  child: Padding(
                    padding: const EdgeInsets.all(DsSpacing.space2),
                    child: _Radio(selected: level == l, size: 18),
                  ),
                ),
            ],
          ),
          const SizedBox(height: DsSpacing.space4),
          Center(
            child: Text(
              current.$2,
              style: DsTextStyles.displayRitual.copyWith(
                color: DsColors.textOnRitualPrimary,
                fontSize: 24,
              ),
            ),
          ),
          const SizedBox(height: DsSpacing.space3),
          Center(
            child: Text(
              current.$3,
              textAlign: TextAlign.center,
              style: DsTextStyles.bodySecondary.copyWith(
                color: DsColors.textOnRitualMuted,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(height: DsSpacing.space8),
          Text(
            'YOUR CONTEXT',
            style: DsTextStyles.labelRitual.copyWith(
              color: DsColors.textOnRitualMuted,
              fontSize: 10,
              letterSpacing: 1.9,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: DsSpacing.space4),
          Row(
            children: [
              _ContextChoice(
                label: 'Long-distance',
                selected: longDistance,
                onTap: () => onLongDistance(true),
              ),
              const SizedBox(width: DsSpacing.space4),
              _ContextChoice(
                label: 'Together',
                selected: !longDistance,
                onTap: () => onLongDistance(false),
              ),
            ],
          ),
          const SizedBox(height: DsSpacing.space5),
          // Detected, not asked. REQ-TIME-001 needs an IANA zone and the
          // device already knows it; making someone pick from a list is a
          // question with one right answer.
          _ContextRow(
            title: 'Timezone',
            detail: '${timezone.replaceAll('_', ' ')} · detected',
          ),
        ],
      ),
    );
  }
}

class _ContextChoice extends StatelessWidget {
  const _ContextChoice({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Semantics(
        selected: selected,
        child: InkWell(
          onTap: onTap,
          child: Container(
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: selected
                  ? DsColors.surfaceRitualRaised
                  : DsColors.canvasRitual,
              borderRadius: BorderRadius.circular(DsRadii.medium),
              border: Border.all(
                color: selected
                    ? DsPrimitiveColors.terracotta
                    : DsColors.borderOnRitualHairline,
                width: DsBorderWidths.hairline,
              ),
            ),
            child: Text(
              label,
              style: DsTextStyles.bodySecondary.copyWith(
                fontSize: 13,
                color: selected
                    ? DsColors.textOnRitualPrimary
                    : DsColors.textOnRitualMuted,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ContextRow extends StatelessWidget {
  const _ContextRow({required this.title, required this.detail});

  final String title;
  final String detail;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: DsBorderWidths.hairline,
          color: DsColors.borderOnRitualHairline,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: DsSpacing.space4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: DsTextStyles.bodyPrimary.copyWith(
                  color: DsColors.textOnRitualPrimary,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: DsSpacing.space1),
              Text(
                detail,
                style: DsTextStyles.bodySecondary.copyWith(
                  color: DsColors.textOnRitualMuted,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        Container(
          height: DsBorderWidths.hairline,
          color: DsColors.borderOnRitualHairline,
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// 4 · The starting rhythm

class _RhythmStep extends StatelessWidget {
  const _RhythmStep({
    required this.solo,
    required this.busy,
    required this.notice,
    required this.onBack,
    required this.onStart,
  });

  final bool solo;
  final bool busy;
  final Widget? notice;
  final VoidCallback onBack;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    return WizardFrame(
      step: 4,
      onBack: onBack,
      eyebrow: 'YOUR STARTING RHYTHM',
      question: 'A small rhythm\nto begin.',
      support: "Keep what feels right. Replace anything that doesn't.",
      // Solo has nobody to adjust *together* with.
      footnote: solo
          ? 'Start light. Adjust as you go.'
          : 'Start light. Adjust together.',
      notice: notice,
      busy: busy,
      // The only step whose action writes anything.
      actionLabel: 'Start this rhythm',
      onAction: onStart,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _RhythmItem(
            index: '01',
            kind: 'RITUAL',
            title: 'Evening check-in',
            detail: 'A pause for presence before the day closes.',
            asset: DsAssets.emblemRitualEvening,
          ),
          _RhythmItem(
            index: '02',
            kind: 'EXPECTATION',
            title: 'One honest sentence',
            // Solo names it rather than shares it.
            detail: solo
                ? 'Name what you need today.'
                : 'Share what you need today.',
            asset: DsAssets.markGuidance,
          ),
          _RhythmItem(
            index: '03',
            kind: 'CHECK-IN',
            title: 'Daily check-in',
            detail: 'Mood · Energy · Need',
            asset: DsAssets.markCheckIn,
            last: true,
          ),
        ],
      ),
    );
  }
}

class _RhythmItem extends StatelessWidget {
  const _RhythmItem({
    required this.index,
    required this.kind,
    required this.title,
    required this.detail,
    required this.asset,
    this.last = false,
  });

  final String index;
  final String kind;
  final String title;
  final String detail;
  final DsAssetId asset;
  final bool last;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: last ? 0 : DsSpacing.space5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            index,
            style: DsTextStyles.displayRitual.copyWith(
              color: DsColors.textOnRitualMuted,
              fontSize: 20,
            ),
          ),
          const SizedBox(width: DsSpacing.space4),
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: _Radio(selected: true, size: 14),
          ),
          const SizedBox(width: DsSpacing.space4),
          DsSvg(
            asset: asset,
            tone: asset == DsAssets.emblemRitualEvening
                ? DsAssetTone.muted
                : DsAssetTone.primary,
            width: 32,
            height: 32,
          ),
          const SizedBox(width: DsSpacing.space4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  kind,
                  style: DsTextStyles.labelRitual.copyWith(
                    color: DsColors.textOnRitualMuted,
                    fontSize: 9,
                    letterSpacing: 1.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: DsSpacing.space2),
                Text(
                  title,
                  style: DsTextStyles.displayRitual.copyWith(
                    color: DsColors.textOnRitualPrimary,
                    fontSize: 19,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: DsSpacing.space2),
                Text(
                  detail,
                  style: DsTextStyles.bodySecondary.copyWith(
                    color: DsColors.textOnRitualMuted,
                    fontSize: 11,
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

class _Notice extends StatelessWidget {
  const _Notice(this.line);

  final String line;

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
        style: DsTextStyles.bodySecondary.copyWith(color: DsColors.stateError),
      ),
    );
  }
}
