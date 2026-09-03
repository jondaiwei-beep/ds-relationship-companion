import 'package:ds_relationship_companion/ds_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/shell/ds_glyph.dart';
import '../../../app/shell/ds_primary_button.dart';
import '../../../app/shell/ds_skeleton.dart';
import '../../../l10n/app_localizations.dart';
import '../../today/presentation/widgets/secondary_button.dart';
import '../../today/presentation/widgets/today_layout.dart';
import '../../today/presentation/widgets/word_button.dart';
import '../application/dynamic_actions.dart';
import '../application/dynamic_providers.dart';

/// SCR-24 Pause and return.
///
/// Pause was already one tap on Dynamic. This adds what the contract asks for
/// and that tap could not carry: a moment to say what pausing does, and a
/// choice about what returning means.
///
/// The confirmation is not a warning and must never read as one. Pausing is a
/// normal use of this product — "inviolable agency" in Notion 04 §4 — and a
/// screen that asks "are you sure?" makes an ordinary act feel like a failure.
/// It states what happens, and the primary action does it.
///
/// Returning offers same or lighter, and lighter is the default. Journey E is
/// explicit that being handed the load you paused under is how people leave
/// for good, and the person most likely to be reading this is the one who
/// needed to stop.
class PauseScreen extends ConsumerStatefulWidget {
  const PauseScreen({super.key, required this.dynamicId, this.onDone});

  final String dynamicId;
  final VoidCallback? onDone;

  @override
  ConsumerState<PauseScreen> createState() => _PauseScreenState();
}

class _PauseScreenState extends ConsumerState<PauseScreen> {
  bool _busy = false;
  String? _failure;
  bool _lighter = true;

  Future<void> _run(DynamicAction action) async {
    setState(() {
      _busy = true;
      _failure = null;
    });

    final outcome = await ref
        .read(dynamicActionsProvider)
        .run(widget.dynamicId, action, lighter: _lighter);

    if (!mounted) return;
    setState(() => _busy = false);

    switch (outcome) {
      case DynamicSucceeded():
        widget.onDone?.call();
      case DynamicFailed(:final reason):
        setState(
          () => _failure = switch (reason) {
            DynamicFailureReason.pause => L.of(context).pauseFailed,
            DynamicFailureReason.resume => L.of(context).resumeFailed,
          },
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    final detail = ref.watch(dynamicDetailProvider(widget.dynamicId));

    // Which half of this screen to show is a server fact, so it waits for one
    // rather than assuming. Treating "not loaded yet" as "not paused" offered
    // Pause to someone already paused — a state the client had invented, and
    // an action the server would have refused (REQ-STATE-001).
    final children = switch (detail) {
      AsyncData(:final value)
          when value.pausedAt != null || value.state == 'PAUSED' =>
        _resume(context),
      AsyncData() => _pause(context),
      AsyncError() => _unavailable(l),
      _ => _confirming(l),
    };

    return Scaffold(
      backgroundColor: DsColors.canvasRitual,
      body: DsRitualSurface(
        child: SafeArea(
          child: Column(
            children: [
              _TopBar(onCancel: widget.onDone),
              Expanded(
                child: ListView(padding: EdgeInsets.zero, children: children),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Neither half is safe to draw yet: the skeleton stands in for whichever
  /// one arrives, so the page does not rearrange under a tap.
  List<Widget> _confirming(L l) => [
    const SizedBox(height: DsSpacing.space8),
    DsSkeletonPulse(
      child: Column(
        children: [
          Padding(
            padding: todayInset,
            child: DsSkeletonBar(widthFactor: 0.55, height: 20, emphasis: true),
          ),
          const SizedBox(height: DsSpacing.space6),
          const Padding(
            padding: todayInset,
            child: DsSkeletonCard(lines: [0.9, 0.75, 0.85, 0.6]),
          ),
        ],
      ),
    ),
    const SizedBox(height: DsSpacing.space6),
    _Quiet(l.pauseConfirming),
  ];

  List<Widget> _unavailable(L l) => [
    const SizedBox(height: DsSpacing.space10),
    _Quiet(l.pauseCouldNotConfirm),
    const SizedBox(height: DsSpacing.space4),
    Padding(
      padding: todayInset,
      child: Align(
        alignment: Alignment.centerLeft,
        child: WordButton(
          label: l.recoveryTryAgain,
          filled: true,
          onTap: () => ref.invalidate(dynamicDetailProvider(widget.dynamicId)),
        ),
      ),
    ),
  ];

  List<Widget> _pause(BuildContext context) {
    final l = L.of(context);
    return [
    Padding(
      padding: todayInset,
      child: Text(
        l.pauseTitle,
        style: DsTextStyles.displayRitual.copyWith(
          color: DsColors.textOnRitualPrimary,
          fontSize: 28,
          height: 34 / 28,
        ),
      ),
    ),
    const SizedBox(height: DsSpacing.space6),
    _Fact(l.pauseFactNothingExpected),
    _Fact(l.pauseFactNothingDeleted),
    _Fact(l.pauseFactNoBacklog),
    _Fact(l.pauseFactEitherCan),
    const SizedBox(height: DsSpacing.space8),
    if (_failure != null) ...[
      Padding(
        padding: todayInset,
        child: Text(
          _failure!,
          style: DsTextStyles.bodyPrimary.copyWith(
            color: DsColors.textOnRitualPrimary,
          ),
        ),
      ),
      const SizedBox(height: DsSpacing.space5),
    ],
    Padding(
      padding: todayInset,
      child: DsPrimaryButton(
        label: l.pauseAction,
        busy: _busy,
        busyLabel: l.pauseBusy,
        onPressed: _busy ? null : () => _run(DynamicAction.pause),
      ),
    ),
    const SizedBox(height: DsSpacing.space4),
    Padding(
      padding: todayInset,
      child: SecondaryButton(
        label: l.pauseNotNow,
        onTap: _busy ? () {} : (widget.onDone ?? () {}),
      ),
    ),
    const SizedBox(height: DsSpacing.space10),
    ];
  }

  List<Widget> _resume(BuildContext context) {
    final l = L.of(context);
    return [
    Padding(
      padding: todayInset,
      child: Text(
        l.resumeTitle,
        style: DsTextStyles.displayRitual.copyWith(
          color: DsColors.textOnRitualPrimary,
          fontSize: 28,
          height: 34 / 28,
        ),
      ),
    ),
    const SizedBox(height: DsSpacing.space3),
    _Quiet(
      l.resumeNothingWaiting,
    ),
    const SizedBox(height: DsSpacing.space8),
    Padding(
      padding: todayInset.add(
        const EdgeInsets.only(bottom: DsSpacing.space4),
      ),
      child: Text(
        l.resumeHowMuch,
        style: DsTextStyles.labelRitual.copyWith(
          color: DsColors.textOnRitualMuted,
        ),
      ),
    ),
    _Option(
      label: l.resumeLighter,
      support: l.resumeLighterSupport,
      selected: _lighter,
      onTap: _busy ? null : () => setState(() => _lighter = true),
    ),
    _Option(
      label: l.resumeSame,
      support: l.resumeSameSupport,
      selected: !_lighter,
      onTap: _busy ? null : () => setState(() => _lighter = false),
    ),
    const SizedBox(height: DsSpacing.space8),
    if (_failure != null) ...[
      Padding(
        padding: todayInset,
        child: Text(
          _failure!,
          style: DsTextStyles.bodyPrimary.copyWith(
            color: DsColors.textOnRitualPrimary,
          ),
        ),
      ),
      const SizedBox(height: DsSpacing.space5),
    ],
    Padding(
      padding: todayInset,
      child: DsPrimaryButton(
        label: l.resumeAction,
        busy: _busy,
        busyLabel: l.resumeBusy,
        onPressed: _busy ? null : () => _run(DynamicAction.resume),
      ),
    ),
    const SizedBox(height: DsSpacing.space4),
    Padding(
      padding: todayInset,
      child: SecondaryButton(
        label: l.resumeStayPaused,
        onTap: _busy ? () {} : (widget.onDone ?? () {}),
      ),
    ),
    const SizedBox(height: DsSpacing.space10),
    ];
  }
}

/// One plain statement about what pausing does. Not a warning: pausing is a
/// normal act, and a list of consequences styled as risk would make it read
/// like one.
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

class _Option extends StatelessWidget {
  const _Option({
    required this.label,
    required this.support,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final String support;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: todayInset.add(
        const EdgeInsets.only(bottom: DsSpacing.space3),
      ),
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.all(DsSpacing.space4),
          decoration: BoxDecoration(
            color: selected ? DsColors.surfaceRitualAction : null,
            borderRadius: BorderRadius.circular(DsRadii.card),
            border: Border.all(
              color: selected
                  ? DsColors.borderOnRitualStrong
                  : DsColors.borderOnRitualHairline,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: DsTextStyles.bodyPrimary.copyWith(
                  color: selected
                      ? DsColors.textOnRitualPrimary
                      : DsColors.textOnRitualSecondary,
                ),
              ),
              const SizedBox(height: DsSpacing.space1),
              Text(
                support,
                style: DsTextStyles.bodySecondary.copyWith(
                  color: DsColors.textOnRitualMuted,
                  fontSize: todaySupportSize,
                  height: todaySupportHeight,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Quiet extends StatelessWidget {
  const _Quiet(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: todayInset,
      child: Text(
        text,
        style: DsTextStyles.bodySecondary.copyWith(
          color: DsColors.textOnRitualMuted,
          fontSize: todaySupportSize,
          height: todaySupportHeight,
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({this.onCancel});

  final VoidCallback? onCancel;

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
            onTap: onCancel,
            behavior: HitTestBehavior.opaque,
            child: DsGlyphIcon(DsGlyph.close, semanticLabel: L.of(context).detailClose),
          ),
        ],
      ),
    );
  }
}
