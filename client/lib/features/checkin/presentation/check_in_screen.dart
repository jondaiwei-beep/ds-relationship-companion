import 'package:ds_relationship_companion/ds_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../app/shell/ds_primary_button.dart';
import '../../../app/shell/ds_text_field.dart';
import '../../../domain_client/api_client.dart';
import '../../../domain_client/models/check_in_view.dart';
import '../../../domain_client/models/dynamic_view.dart';
import '../../../l10n/app_localizations.dart';
import '../../dynamic/presentation/dynamic_screen.dart';
import '../../today/presentation/widgets/today_layout.dart';

/// SCR-22 Check-in — mood, energy, need, and who may see it.
///
/// Built to the contract rather than to the preview, which they disagree on.
/// The preview is the essay-first design: a large open question and a body of
/// prose. The contract says in as many words to "replace essay-first advanced
/// reflection with mood/energy/need, optional note and explicit Private/Shared
/// choice", and its acceptance criterion is that a check-in is completable
/// quickly. An essay is not quick, and on a bad day it is the thing a person
/// least wants to be asked for.
///
/// The three prompts are optional and independent. Someone who only wants to
/// say "tired" should be able to save that and put the phone down.
///
/// Visibility is chosen explicitly every time and defaults to Private, which
/// is the only safe default for something written before you know how it will
/// read. The preview's "You can change visibility later" is not shown: the
/// server has no endpoint to change it, and a promise the system cannot keep
/// about who can see your words is the worst kind to make.
class CheckInScreen extends ConsumerStatefulWidget {
  const CheckInScreen({super.key, required this.dynamicId, this.onClose});

  final String dynamicId;
  final VoidCallback? onClose;

  @override
  ConsumerState<CheckInScreen> createState() => _CheckInScreenState();
}

class _CheckInScreenState extends ConsumerState<CheckInScreen> {
  final _note = TextEditingController();

  String? _mood;
  String? _energy;
  String? _need;
  CheckInVisibility _visibility = CheckInVisibility.private;

  bool _busy = false;
  String? _failure;
  String? _key;

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  /// The chip that is lit, from the stored domain value. The value in state
  /// is always the wire constant, so switching language relights the same
  /// chip rather than losing the answer.
  String? _energyLabel(L l) {
    for (final e in _energies(l)) {
      if (e.value == _energy) return e.label;
    }
    return null;
  }

  bool get _hasAnything =>
      _mood != null ||
      _energy != null ||
      _need != null ||
      _note.text.trim().isNotEmpty;

  Future<void> _save() async {
    setState(() {
      _busy = true;
      _failure = null;
    });

    // One key per composed check-in, kept across retries so a flaky network
    // cannot write the same day twice.
    final key = _key ??= ApiClient.newIdempotencyKey();

    try {
      await ref
          .read(checkInRepositoryProvider)
          .create(
            widget.dynamicId,
            mood: _mood,
            energy: _energy,
            need: _need,
            note: _note.text.trim().isEmpty ? null : _note.text.trim(),
            visibility: _visibility,
            idempotencyKey: key,
          );
      _key = null;
      if (!mounted) return;
      // Stop showing work that has finished before handing over. Leaving
      // `_busy` set meant a saved check-in sat on "Saving…" forever whenever
      // there was nowhere to close to.
      setState(() => _busy = false);
      widget.onClose?.call();
    } on Object {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _failure = L.of(context).checkInSaveFailed;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // The partner is only needed to name the share option. A check-in must
    // stay writable while the Dynamic detail is still loading or failed —
    // being unable to say "I am running low" because a name did not resolve
    // would be the wrong failure entirely.
    final l = L.of(context);
    final detail = ref.watch(dynamicDetailProvider(widget.dynamicId));
    final partner = detail.hasValue ? _partnerIn(detail.value!) : null;

    return Scaffold(
      backgroundColor: DsColors.canvasRitual,
      body: DsRitualSurface(
        child: SafeArea(
          child: Column(
            children: [
              _TopBar(onCancel: widget.onClose),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    Padding(
                      padding: todayInset,
                      child: Text(
                        l.checkInHeadline,
                        style: DsTextStyles.displayRitual.copyWith(
                          color: DsColors.textOnRitualPrimary,
                          fontSize: 28,
                          height: 34 / 28,
                        ),
                      ),
                    ),
                    const SizedBox(height: DsSpacing.space3),
                    Padding(
                      padding: todayInset,
                      child: Text(
                        l.checkInSupport,
                        style: DsTextStyles.bodySecondary.copyWith(
                          color: DsColors.textOnRitualMuted,
                          fontSize: todaySupportSize,
                          height: todaySupportHeight,
                        ),
                      ),
                    ),
                    const SizedBox(height: DsSpacing.space8),

                    _Choice(
                      label: l.checkInMoodSection,
                      options: _moods(l),
                      value: _mood,
                      enabled: !_busy,
                      onChanged: (v) => setState(() => _mood = v),
                    ),
                    _Choice(
                      label: l.checkInEnergySection,
                      options: [for (final e in _energies(l)) e.label],
                      value: _energyLabel(l),
                      enabled: !_busy,
                      onChanged: (v) => setState(() {
                        _energy = v == null
                            ? null
                            : _energies(l)
                                  .firstWhere((e) => e.label == v)
                                  .value;
                      }),
                    ),
                    _Choice(
                      label: l.checkInNeedSection,
                      options: _needs(l),
                      value: _need,
                      enabled: !_busy,
                      onChanged: (v) => setState(() => _need = v),
                    ),

                    const SizedBox(height: DsSpacing.space4),
                    Padding(
                      padding: todayInset,
                      child: Text(
                        l.checkInNoteSection,
                        style: DsTextStyles.labelRitual.copyWith(
                          color: DsColors.textOnRitualMuted,
                        ),
                      ),
                    ),
                    const SizedBox(height: DsSpacing.space2),
                    Padding(
                      padding: todayInset,
                      child: DsTextField(
                        label: '',
                        controller: _note,
                        hint: l.checkInNoteHint,
                        enabled: !_busy,
                      ),
                    ),

                    const SizedBox(height: DsSpacing.space6),
                  ],
                ),
              ),

              // Visibility and Save stay out of the scroller.
              //
              // At 390x844 they sat below the fold, which made the privacy
              // choice invisible until someone scrolled for it — and this is
              // the one control on the screen a person must not miss. Whoever
              // is deciding whether to share how they feel should be able to
              // see the decision without hunting for it.
              _Visibility(
                value: _visibility,
                partnerName: partner?.displayName,
                enabled: !_busy,
                onChanged: (v) => setState(() => _visibility = v),
              ),

              if (_failure != null)
                Padding(
                  padding: todayInset.add(
                    const EdgeInsets.only(top: DsSpacing.space4),
                  ),
                  child: Text(
                    _failure!,
                    style: DsTextStyles.bodyPrimary.copyWith(
                      color: DsColors.textOnRitualPrimary,
                    ),
                  ),
                ),

              Padding(
                padding: todayInset.add(
                  const EdgeInsets.only(
                    top: DsSpacing.space5,
                    bottom: DsSpacing.space6,
                  ),
                ),
                child: DsPrimaryButton(
                  label: l.checkInSave,
                  busy: _busy,
                  busyLabel: l.checkInSaving,
                  onPressed: (!_hasAnything || _busy) ? null : _save,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  MemberView? _partnerIn(DynamicDetail view) {
    final me = ref.read(dynamicViewerIdProvider);
    if (me == null) return null;
    for (final m in view.members) {
      if (m.userId != me) return m;
    }
    return null;
  }
}

// Plain words a person would actually use about themselves. Deliberately not
// a 1-5 scale: a number invites comparison between days and between people,
// and this is a check-in, not a measurement.
//
// Mood and need are free text on the server. Energy is not — the column has a
// CHECK constraint of LOW/STEADY/HIGH, so anything else is a 500 at save
// time, which is what "Full"/"Running low"/"Empty" produced against staging.
// The label is what a person reads; the value is what the domain allows, and
// only the label is translated.
List<String> _moods(L l) => [
  l.checkInMoodGood,
  l.checkInMoodSteady,
  l.checkInMoodLow,
  l.checkInMoodTender,
  l.checkInMoodRaw,
];

List<String> _needs(L l) => [
  l.checkInNeedNothing,
  l.checkInNeedCloseness,
  l.checkInNeedSpace,
  l.checkInNeedStructure,
  l.checkInNeedToBeAsked,
];

List<({String label, String value})> _energies(L l) => [
  (label: l.checkInEnergyHigh, value: 'HIGH'),
  (label: l.checkInEnergySteady, value: 'STEADY'),
  (label: l.checkInEnergyLow, value: 'LOW'),
];

class _Choice extends StatelessWidget {
  const _Choice({
    required this.label,
    required this.options,
    required this.value,
    required this.onChanged,
    this.enabled = true,
  });

  final String label;
  final List<String> options;
  final String? value;

  /// Null clears the answer. Every prompt is optional, and choosing then
  /// unchoosing must be possible — otherwise the first tap is a commitment.
  final ValueChanged<String?> onChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: todayInset.add(
        const EdgeInsets.only(bottom: DsSpacing.space6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: DsTextStyles.labelRitual.copyWith(
              color: DsColors.textOnRitualMuted,
            ),
          ),
          const SizedBox(height: DsSpacing.space3),
          Wrap(
            spacing: DsSpacing.space2,
            runSpacing: DsSpacing.space2,
            children: [
              for (final option in options)
                GestureDetector(
                  onTap: enabled
                      ? () => onChanged(value == option ? null : option)
                      : null,
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: DsSpacing.space4,
                      vertical: DsSpacing.space3,
                    ),
                    decoration: BoxDecoration(
                      color: value == option
                          ? DsColors.surfaceRitualAction
                          : null,
                      borderRadius: BorderRadius.circular(DsRadii.control),
                      border: Border.all(
                        color: value == option
                            ? DsColors.borderOnRitualStrong
                            : DsColors.borderOnRitualHairline,
                      ),
                    ),
                    child: Text(
                      option,
                      style: DsTextStyles.bodySecondary.copyWith(
                        color: value == option
                            ? DsColors.textOnRitualPrimary
                            : DsColors.textOnRitualSecondary,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Who may see it. Private is the default and never changes on its own —
/// Notion 04 §3: visibility is explicit, and a Solo check-in does not become
/// shared because someone later joined.
class _Visibility extends StatelessWidget {
  const _Visibility({
    required this.value,
    required this.onChanged,
    this.partnerName,
    this.enabled = true,
  });

  final CheckInVisibility value;
  final ValueChanged<CheckInVisibility> onChanged;
  final String? partnerName;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    final shareLabel = partnerName == null
        ? l.checkInVisibilityShare
        : l.checkInVisibilityShareWith(partnerName!);

    return Padding(
      padding: todayInset,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l.checkInVisibilitySection,
            style: DsTextStyles.labelRitual.copyWith(
              color: DsColors.textOnRitualMuted,
            ),
          ),
          const SizedBox(height: DsSpacing.space3),
          // Wraps rather than overflows: a display name is arbitrary text, so
          // the two options together can exceed 390dp — "Share with Morgan"
          // already did, by 60px.
          Wrap(
            spacing: DsSpacing.space5,
            runSpacing: DsSpacing.space3,
            children: [
              _Option(
                label: l.checkInVisibilityPrivate,
                selected: value == CheckInVisibility.private,
                onTap: enabled
                    ? () => onChanged(CheckInVisibility.private)
                    : null,
              ),
              _Option(
                label: shareLabel,
                selected: value == CheckInVisibility.shared,
                relational: true,
                onTap: enabled && partnerName != null
                    ? () => onChanged(CheckInVisibility.shared)
                    : null,
              ),
            ],
          ),
          const SizedBox(height: DsSpacing.space3),
          Text(
            value == CheckInVisibility.private
                ? l.checkInVisibilityPrivateSupport
                : partnerName == null
                ? l.checkInVisibilityNoPartnerSupport
                : l.checkInVisibilitySharedSupport(partnerName!),
            style: DsTextStyles.bodySecondary.copyWith(
              color: DsColors.textOnRitualMuted,
              fontSize: todaySupportSize,
              height: todaySupportHeight,
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
    required this.selected,
    required this.onTap,
    this.relational = false,
  });

  final String label;
  final bool selected;
  final VoidCallback? onTap;
  final bool relational;

  @override
  Widget build(BuildContext context) {
    final color = onTap == null
        ? DsColors.textOnRitualMuted
        : selected && relational
        ? DsColors.textOnRitualRelationshipLarge
        : selected
        ? DsColors.textOnRitualPrimary
        : DsColors.textOnRitualSecondary;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.only(bottom: DsSpacing.space2),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: selected ? color : DsPrimitiveColors.transparent,
            ),
          ),
        ),
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: DsTextStyles.bodyPrimary.copyWith(color: color),
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
        children: [
          GestureDetector(
            onTap: onCancel,
            behavior: HitTestBehavior.opaque,
            child: Text(
              L.of(context).checkInCancel,
              style: DsTextStyles.bodySecondary.copyWith(
                color: DsColors.textOnRitualMuted,
              ),
            ),
          ),
          Expanded(
            child: Text(
              L.of(context).checkInTitle,
              textAlign: TextAlign.center,
              style: DsTextStyles.bodyPrimary.copyWith(
                color: DsColors.textOnRitualPrimary,
              ),
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }
}
