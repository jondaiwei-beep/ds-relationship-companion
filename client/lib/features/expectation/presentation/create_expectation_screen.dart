import 'package:ds_relationship_companion/ds_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/shell/ds_primary_button.dart';
import '../../../app/shell/ds_text_field.dart';
import '../../../l10n/app_localizations.dart';
import '../../../domain_client/models/dynamic_view.dart';
import '../../dynamic/presentation/dynamic_screen.dart';
import '../../today/presentation/widgets/today_layout.dart';
import '../application/create_expectation_actions.dart';

import 'widgets/numbered_step.dart';
import 'widgets/when_row.dart';

/// SCR-20 Create Task — asking one thing of the other person.
///
/// The approved composition has four numbered steps. Two of them are not
/// built, and both omissions come from the package's own alignment work
/// rather than from taste:
///
/// - **Completion mode** (Short note / Simple confirmation / Photo). The
///   alignment work says "remove Proof/photo option from Core Beta" and the
///   contract says "no Proof/points/punishment". The server has no field for
///   it either — `POST /expectations` takes title, purpose, assignee and
///   dueAt, and nothing else.
///
/// - **The boundary toggle** ("They may pause or decline"). There is no
///   server field behind it, so the switch would change nothing. Rendering a
///   promise about someone's agency that the system does not actually keep is
///   worse than not offering the control: the answer is already yes, always,
///   and Today gives them Discuss, New Time and Can't Do to act on it.
///
/// What remains is the part the server can honour: who it is for, what is
/// being asked, when, and why it matters.
class CreateExpectationScreen extends ConsumerStatefulWidget {
  const CreateExpectationScreen({
    super.key,
    required this.dynamicId,
    this.onDone,
    this.onCancel,
    this.initialTitle,
    this.initialPurpose,
  });

  final String dynamicId;

  /// Prefilled when arriving from Explore. Editable, and nothing is sent
  /// until Send: an idea is a starting point, not a script.
  final String? initialTitle;
  final String? initialPurpose;

  /// Where to go once it is sent. The screen does not decide.
  final void Function(String occurrenceId)? onDone;
  final VoidCallback? onCancel;

  @override
  ConsumerState<CreateExpectationScreen> createState() =>
      _CreateExpectationScreenState();
}

class _CreateExpectationScreenState
    extends ConsumerState<CreateExpectationScreen> {
  final _title = TextEditingController();
  final _purpose = TextEditingController();

  DateTime? _dueAt;
  bool _busy = false;
  String? _failure;

  /// Shown under the field it belongs to, only after Send has been pressed.
  /// A form that turns red while someone is still typing is scolding them.
  bool _submitted = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialTitle != null) _title.text = widget.initialTitle!;
    if (widget.initialPurpose != null) _purpose.text = widget.initialPurpose!;
    // The action's availability follows the title, so the button has to
    // rebuild as it is typed.
    _title.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _title.dispose();
    _purpose.dispose();
    super.dispose();
  }

  bool get _ready => _title.text.trim().isNotEmpty;

  Future<void> _send(MemberView assignee) async {
    setState(() {
      _submitted = true;
      _failure = null;
    });
    if (!_ready) return;

    setState(() => _busy = true);
    final outcome = await ref
        .read(createExpectationActionsProvider)
        .send(
          dynamicId: widget.dynamicId,
          title: _title.text.trim(),
          purpose: _purpose.text.trim().isEmpty ? null : _purpose.text.trim(),
          assigneeUserId: assignee.userId,
          dueAt: _dueAt,
        );

    if (!mounted) return;
    setState(() => _busy = false);

    switch (outcome) {
      case CreateSucceeded(:final occurrenceId):
        widget.onDone?.call(occurrenceId);
      case CreateFailed(:final message):
        setState(() => _failure = message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final detail = ref.watch(dynamicDetailProvider(widget.dynamicId));

    return Scaffold(
      backgroundColor: DsColors.canvasRitual,
      body: DsRitualSurface(
        child: SafeArea(
          child: detail.when(
            loading: () => const Center(
              child: SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 1.5),
              ),
            ),
            error: (_, _) => _Unavailable(onCancel: widget.onCancel),
            data: (view) {
              final assignee = _assigneeIn(view);
              if (assignee == null) {
                return _NoOneToAsk(onCancel: widget.onCancel);
              }
              return _form(view, assignee);
            },
          ),
        ),
      ),
    );
  }

  /// Who this is for. In a paired Dynamic there is exactly one other person,
  /// so the screen states it rather than asking — the preview names them in
  /// the header, not in a picker.
  MemberView? _assigneeIn(DynamicDetail view) {
    final me = ref.read(dynamicViewerIdProvider);
    if (me == null) return null;
    for (final m in view.members) {
      if (m.userId != me) return m;
    }
    return null;
  }

  Widget _form(DynamicDetail view, MemberView assignee) {
    final l = L.of(context);
    return Column(
      children: [
        _TopBar(onCancel: widget.onCancel),
        Expanded(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              _ForWhom(assignee: assignee),
              const SizedBox(height: DsSpacing.space8),

              NumberedStep(
                index: 1,
                label: l.askWhatStep,
                child: DsTextField(
                  label: '',
                  controller: _title,
                  hint: l.askWhatHint,
                  enabled: !_busy,
                  error: _submitted && !_ready
                      ? l.askWhatMissing
                      : null,
                ),
              ),

              NumberedStep(
                index: 2,
                label: l.askWhenStep,
                child: WhenRow(
                  value: _dueAt,
                  zone: view.referenceTimezone,
                  enabled: !_busy,
                  onChanged: (v) => setState(() => _dueAt = v),
                ),
              ),

              NumberedStep(
                index: 3,
                label: l.askWhyStep,
                last: true,
                child: DsTextField(
                  label: '',
                  controller: _purpose,
                  hint: l.askWhyHint,
                  enabled: !_busy,
                ),
              ),

              if (_failure != null) ...[
                const SizedBox(height: DsSpacing.space5),
                Padding(
                  padding: todayInset,
                  child: Text(
                    _failure!,
                    style: DsTextStyles.bodySecondary.copyWith(
                      color: DsColors.textOnRitualPrimary,
                    ),
                  ),
                ),
              ],

              const SizedBox(height: DsSpacing.space8),
              Padding(
                padding: todayInset,
                child: DsPrimaryButton(
                  label: l.askSend,
                  busy: _busy,
                  busyLabel: l.askSending,
                  onPressed: _busy ? null : () => _send(assignee),
                ),
              ),
              const SizedBox(height: DsSpacing.space4),

              // Agency, stated as the fact it is rather than offered as a
              // switch the server cannot honour.
              Padding(
                padding: todayInset,
                child: Text(
                  l.askAgencyNote(
                    assignee.displayName ?? l.askYourPartnerFallback,
                  ),
                  style: DsTextStyles.bodySecondary.copyWith(
                    color: DsColors.textOnRitualMuted,
                    fontSize: todaySupportSize,
                    height: todaySupportHeight,
                  ),
                ),
              ),
              const SizedBox(height: DsSpacing.space10),
            ],
          ),
        ),
      ],
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({this.onCancel});

  final VoidCallback? onCancel;

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    return Padding(
      padding: todayInset.add(
        const EdgeInsets.symmetric(vertical: DsSpacing.space4),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: onCancel,
            child: Text(
              l.askCancel,
              style: DsTextStyles.bodySecondary.copyWith(
                color: DsColors.textOnRitualMuted,
              ),
            ),
          ),
          Expanded(
            child: Text(
              l.askTitle,
              textAlign: TextAlign.center,
              style: DsTextStyles.bodyPrimary.copyWith(
                color: DsColors.textOnRitualPrimary,
              ),
            ),
          ),
          // Balances the row so the title stays centred. The preview's
          // "Preview" action has no product rule behind it yet.
          const SizedBox(width: 48),
        ],
      ),
    );
  }
}

class _ForWhom extends StatelessWidget {
  const _ForWhom({required this.assignee});

  final MemberView assignee;

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    return Padding(
      padding: todayInset,
      child: Row(
        children: [
          const DsSvg(
            asset: DsAssets.markPresence,
            tone: DsAssetTone.relationship,
            width: 26,
            height: 26,
          ),
          const SizedBox(width: DsSpacing.space3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l.askForWhom(
                    assignee.displayName ?? l.askYourPartnerFallback,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: DsTextStyles.bodyPrimary.copyWith(
                    color: DsColors.textOnRitualRelationshipLarge,
                  ),
                ),
                if (assignee.rolePreset != null)
                  Text(
                    _role(l, assignee.rolePreset!),
                    style: DsTextStyles.bodySecondary.copyWith(
                      color: DsColors.textOnRitualMuted,
                      fontSize: todaySupportSize,
                      height: todaySupportHeight,
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

String _role(L l, String preset) => switch (preset) {
  'DOMINANT' => l.rolePresetDominant,
  'SUBMISSIVE' => l.rolePresetSubmissive,
  'SWITCH' => l.rolePresetSwitch,
  'CUSTOM' => l.rolePresetCustom,
  _ => preset,
};

/// Solo, or the partner has not joined. Asking is a two-person act.
class _NoOneToAsk extends StatelessWidget {
  const _NoOneToAsk({this.onCancel});

  final VoidCallback? onCancel;

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    return Column(
      children: [
        _TopBar(onCancel: onCancel),
        const SizedBox(height: DsSpacing.space16),
        Padding(
          padding: todayInset,
          child: Text(
            l.askNoOneYet,
            style: DsTextStyles.bodyPrimary.copyWith(
              color: DsColors.textOnRitualPrimary,
            ),
          ),
        ),
        const SizedBox(height: DsSpacing.space3),
        Padding(
          padding: todayInset,
          child: Text(
            l.askNoOneYetBody,
            style: DsTextStyles.bodySecondary.copyWith(
              color: DsColors.textOnRitualMuted,
            ),
          ),
        ),
      ],
    );
  }
}

class _Unavailable extends StatelessWidget {
  const _Unavailable({this.onCancel});

  final VoidCallback? onCancel;

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    return Column(
      children: [
        _TopBar(onCancel: onCancel),
        const SizedBox(height: DsSpacing.space16),
        Padding(
          padding: todayInset,
          child: Text(
            l.askCouldNotOpen,
            style: DsTextStyles.bodyPrimary.copyWith(
              color: DsColors.textOnRitualPrimary,
            ),
          ),
        ),
      ],
    );
  }
}
