import 'package:dio/dio.dart';
import 'package:ds_relationship_companion/ds_design_system.dart';
import 'package:flutter/material.dart';

import '../../../app/shell/ds_glyph.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../app/shell/ds_primary_button.dart';
import '../../../app/shell/ds_text_field.dart';
import '../../../l10n/app_localizations.dart';
import '../../../domain_client/models/occurrence.dart';
import '../../../domain_client/models/occurrence_view.dart';
import '../../today/application/today_actions.dart';
import '../../dynamic/presentation/dynamic_screen.dart';
import '../../points/presentation/widgets/consequence_panel.dart';
import '../../today/presentation/widgets/secondary_button.dart';
import '../../today/presentation/widgets/today_layout.dart';

final occurrenceProvider = FutureProvider.autoDispose
    .family<OccurrenceView, String>(
      (ref, id) => ref.watch(occurrenceRepositoryProvider).get(id),
    );

/// SCR-14 Task Detail — one occurrence, and the action its current state
/// actually allows.
///
/// The preview offers only "Mark complete". The package's alignment work adds
/// Discuss, Request New Time and Can't Do, and its acceptance criterion is
/// that no side path reads as failure — so the three are laid out as equals
/// beneath completion rather than tucked into a menu, exactly as Today does.
///
/// Two things in the preview are not built:
///
/// - **Add photo.** "remove Proof" in the alignment work, and there is no
///   server field for it.
/// - **The COMPLETION and BOUNDARY rows** ("A short note is enough", "Pause if
///   this no longer feels right"). Both are written as if the person who set
///   the task had said them, but nothing on the server carries either — they
///   would be words the app invents and attributes to a partner. The boundary
///   is real and is stated as the app's own fact instead.
///
/// Which actions appear is never decided here: `allowedActions` comes from the
/// server, and an item someone has already asked to discuss must not still
/// offer Complete.
class OccurrenceDetailScreen extends ConsumerStatefulWidget {
  const OccurrenceDetailScreen({
    super.key,
    required this.dynamicId,
    required this.occurrenceId,
    this.onClose,
  });

  final String dynamicId;
  final String occurrenceId;
  final VoidCallback? onClose;

  @override
  ConsumerState<OccurrenceDetailScreen> createState() =>
      _OccurrenceDetailScreenState();
}

class _OccurrenceDetailScreenState
    extends ConsumerState<OccurrenceDetailScreen> {
  final _note = TextEditingController();

  TodayAction? _busy;
  String? _failure;

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  Future<void> _run(TodayAction action) async {
    setState(() {
      _busy = action;
      _failure = null;
    });

    final outcome = await ref
        .read(todayActionsProvider)
        .run(
          dynamicId: widget.dynamicId,
          occurrenceId: widget.occurrenceId,
          action: action,
          note: _note.text.trim().isEmpty ? null : _note.text.trim(),
        );

    if (!mounted) return;
    setState(() {
      _busy = null;
      _failure = outcome is ActionFailed ? outcome.message : null;
    });

    if (outcome is ActionSucceeded) {
      // The list this came from is now stale in a way this screen cannot fix
      // locally, so it re-reads rather than patching, and closes.
      ref.invalidate(occurrenceProvider(widget.occurrenceId));
      widget.onClose?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    final occurrence = ref.watch(occurrenceProvider(widget.occurrenceId));

    return Scaffold(
      backgroundColor: DsColors.canvasRitual,
      body: DsRitualSurface(
        child: SafeArea(
          child: occurrence.when(
            skipLoadingOnReload: true,
            loading: () => _Frame(
              onClose: widget.onClose,
              children: [
                const SizedBox(height: DsSpacing.space10),
                _Quiet(l.detailConfirming),
              ],
            ),
            error: (error, _) => _Frame(
              onClose: widget.onClose,
              children: [
                const SizedBox(height: DsSpacing.space10),
                _Quiet(
                  _isAuthLoss(error)
                      ? l.detailSessionEnded
                      : l.detailCouldNotLoad,
                  prominent: true,
                ),
                const SizedBox(height: DsSpacing.space6),
                if (!_isAuthLoss(error))
                  Padding(
                    padding: todayInset,
                    child: SecondaryButton(
                      label: l.recoveryTryAgain,
                      onTap: () => ref.invalidate(
                        occurrenceProvider(widget.occurrenceId),
                      ),
                    ),
                  ),
              ],
            ),
            data: _loaded,
          ),
        ),
      ),
    );
  }

  Widget _loaded(OccurrenceView view) {
    final l = L.of(context);
    final actions = view.allowedActions;
    final canComplete = actions.contains('complete');
    final adjustments = [
      if (actions.contains('discuss')) TodayAction.discuss,
      if (actions.contains('reschedule')) TodayAction.requestNewTime,
      if (actions.contains('cant_do')) TodayAction.cantDo,
    ];

    // The way out of your own open request. Until this existed, an item you
    // had asked to discuss showed you no action at all: it could only end when
    // the other person answered.
    final canWithdraw = actions.contains('withdraw');

    return _Frame(
      onClose: widget.onClose,
      children: [
        if (view.dueAt != null) ...[
          _Label(l.detailDue),
          Padding(
            padding: todayInset,
            child: Text(
              _time(view.dueAt!),
              style: DsTextStyles.bodyPrimary.copyWith(
                color: DsColors.textOnRitualPrimary,
              ),
            ),
          ),
          const SizedBox(height: DsSpacing.space6),
        ],

        Padding(
          padding: todayInset,
          child: Text(
            view.title,
            style: DsTextStyles.displayRitual.copyWith(
              color: DsColors.textOnRitualPrimary,
              fontSize: 30,
              height: 36 / 30,
            ),
          ),
        ),

        if (view.partnerDisplayName != null) ...[
          const SizedBox(height: DsSpacing.space3),
          Padding(
            padding: todayInset,
            child: Row(
              children: [
                const DsSvg(
                  asset: DsAssets.markPresence,
                  tone: DsAssetTone.relationship,
                  width: 20,
                  height: 20,
                ),
                const SizedBox(width: DsSpacing.space2),
                Flexible(
                  child: Text(
                    l.detailSetBy(view.partnerDisplayName!),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: DsTextStyles.bodySecondary.copyWith(
                      color: DsColors.textOnRitualRelationshipLarge,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],

        if (view.purpose != null) ...[
          const SizedBox(height: DsSpacing.space8),
          _Label(l.detailIntention),
          Padding(
            padding: todayInset,
            child: Text(
              view.purpose!,
              style: DsTextStyles.displayRitual.copyWith(
                color: DsColors.textOnRitualSecondary,
                fontSize: 20,
                height: 27 / 20,
              ),
            ),
          ),
        ],

        // Their own words, shown back only to the person who wrote them. The
        // server withholds it from everyone else; this screen must not put it
        // anywhere the other person can see.
        if (view.privateNote != null) ...[
          const SizedBox(height: DsSpacing.space8),
          _Label(l.detailPrivateNote),
          Padding(
            padding: todayInset,
            child: Text(
              view.privateNote!,
              style: DsTextStyles.bodySecondary.copyWith(
                color: DsColors.textOnRitualSecondary,
              ),
            ),
          ),
        ],

        if (view.acknowledgement != null) ...[
          const SizedBox(height: DsSpacing.space8),
          _Acknowledgement(value: view.acknowledgement!),
        ],

        const SizedBox(height: DsSpacing.space8),

        if (canComplete) ...[
          _Label(l.detailCompletionNote),
          Padding(
            padding: todayInset,
            child: DsTextField(
              label: '',
              controller: _note,
              hint: l.detailCompletionHint,
              enabled: _busy == null,
            ),
          ),
          const SizedBox(height: DsSpacing.space6),
          Padding(
            padding: todayInset,
            child: DsPrimaryButton(
              label: l.detailMarkComplete,
              busy: _busy == TodayAction.complete,
              busyLabel: l.detailCompleting,
              onPressed: _busy != null
                  ? null
                  : () => _run(TodayAction.complete),
            ),
          ),
          if (view.partnerDisplayName != null) ...[
            const SizedBox(height: DsSpacing.space3),
            _Quiet(l.detailPartnerWillSee(view.partnerDisplayName!)),
          ],
        ],

        // Equals, not lesser paths. Completing is not more legitimate than
        // asking to discuss, and the acceptance criterion is that no side
        // path is labelled as failure.
        if (adjustments.isNotEmpty) ...[
          const SizedBox(height: DsSpacing.space6),
          Padding(
            padding: todayInset,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                for (final a in adjustments)
                  GestureDetector(
                    onTap: _busy != null ? null : () => _run(a),
                    behavior: HitTestBehavior.opaque,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: DsSpacing.space2,
                      ),
                      child: Text(
                        _busy == a ? '…' : _adjustmentLabel(l, a),
                        style: DsTextStyles.bodySecondary.copyWith(
                          color: DsColors.textOnRitualSecondary,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],

        if (canWithdraw) ...[
          _Quiet(_nothingToDo(l, view.state), prominent: true),
          const SizedBox(height: DsSpacing.space5),
          Padding(
            padding: todayInset,
            child: SecondaryButton(
              label: _busy == TodayAction.withdraw
                  ? l.detailTakingItBack
                  : l.detailTakeItBack,
              onTap: _busy != null
                  ? () {}
                  : () => _run(TodayAction.withdraw),
            ),
          ),
          const SizedBox(height: DsSpacing.space3),
          _Quiet(
            l.detailTakeItBackNote,
          ),
        ] else if (!canComplete && adjustments.isEmpty) ...[
          _Quiet(_nothingToDo(l, view.state), prominent: true),
        ],

        // Past due, and the couple wrote down what happens. Offered here
        // because this is where a person actually arrives from Today; the
        // Attention surface this was designed against exists in the codebase
        // but has no route, so nothing there is reachable.
        //
        // REQ-REVIEW-001 keeps its meaning: past due is still only a prompt
        // to look, the software still assigns nothing, and a couple with no
        // agreement sees none of this.
        if (view.state == OccurrenceState.needsReview)
          _AgreedConsequence(
            dynamicId: widget.dynamicId,
            occurrenceId: widget.occurrenceId,
            onTalk: () => _run(TodayAction.discuss),
          ),

        if (_failure != null) ...[
          const SizedBox(height: DsSpacing.space5),
          _Quiet(_failure!, prominent: true),
        ],

        const SizedBox(height: DsSpacing.space10),
      ],
    );
  }
}

/// What the state means when there is nothing for this person to do — said
/// plainly, and never as a fault.
/// What the couple agreed happens, offered as a choice and never taken.
///
/// Renders nothing unless they wrote an agreement, and nothing unless the
/// viewer is the other person: deciding a consequence about yourself is not
/// a thing this product does.
class _AgreedConsequence extends ConsumerStatefulWidget {
  const _AgreedConsequence({
    required this.dynamicId,
    required this.occurrenceId,
    required this.onTalk,
  });

  final String dynamicId;
  final String occurrenceId;

  /// The existing adjustment path. Talking is not a new mechanism.
  final VoidCallback onTalk;

  @override
  ConsumerState<_AgreedConsequence> createState() => _AgreedConsequenceState();
}

class _AgreedConsequenceState extends ConsumerState<_AgreedConsequence> {
  bool _busy = false;

  /// Hidden once decided, so the same miss is never presented twice. Nothing
  /// is recorded as pending in between — if they close the app instead of
  /// choosing, nothing has happened.
  bool _decided = false;

  Future<void> _decide(
    String agreementId,
    String subjectUserId, {
    required bool waived,
    bool byChance = false,
  }) async {
    setState(() => _busy = true);
    try {
      await ref.read(pointsRepositoryProvider).issueConsequence(
        widget.dynamicId,
        subjectUserId: subjectUserId,
        agreementId: agreementId,
        occurrenceId: widget.occurrenceId,
        waived: waived,
        byChance: byChance,
      );
      ref.invalidate(pointsProvider(widget.dynamicId));
      if (mounted) setState(() => _decided = true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_decided) return const SizedBox.shrink();

    final me = ref.watch(dynamicViewerIdProvider);
    final detail = ref.watch(dynamicDetailProvider(widget.dynamicId));
    final agreements = ref.watch(agreementsProvider(widget.dynamicId));

    final partnerId = switch (detail) {
      AsyncData(:final value) =>
        value.members.where((m) => m.userId != me).firstOrNull?.userId,
      _ => null,
    };

    if (partnerId == null) return const SizedBox.shrink();

    return switch (agreements) {
      AsyncData(:final value) when value.isNotEmpty => Padding(
        padding: todayInset.add(
          const EdgeInsets.only(top: DsSpacing.space5),
        ),
        // The first agreement is the one offered. Asking "which rule applies"
        // would turn a moment into a form.
        child: ConsequencePanel(
          agreement: value.first,
          busy: _busy,
          onHold: () => _decide(value.first.id, partnerId, waived: false),
          onLetGo: () => _decide(value.first.id, partnerId, waived: true),
          // Nothing to choose between with one agreement.
          onChance: value.length < 2
              ? null
              : () => _decide(
                  value.first.id,
                  partnerId,
                  waived: false,
                  byChance: true,
                ),
          onTalk: widget.onTalk,
        ),
      ),
      _ => const SizedBox.shrink(),
    };
  }

}

String _nothingToDo(L l, OccurrenceState state) => switch (state) {
  OccurrenceState.waitingAck => l.nothingWaitingAck,
  OccurrenceState.acknowledged => l.nothingAcknowledged,
  OccurrenceState.needToDiscuss => l.nothingDiscussing,
  OccurrenceState.rescheduleRequested => l.nothingRescheduling,
  OccurrenceState.excuseRequested => l.nothingExcusing,
  OccurrenceState.cancelled => l.nothingCancelled,
  _ => l.nothingDefault,
};

String _adjustmentLabel(L l, TodayAction a) => switch (a) {
  TodayAction.discuss => l.actionDiscuss,
  TodayAction.requestNewTime => l.actionNewTime,
  TodayAction.cantDo => l.actionCantDo,
  TodayAction.complete => l.actionComplete,
  TodayAction.receive => l.actionReceived,
  // Never rendered in the adjustment row: withdrawing is offered on its own,
  // because it is the only thing available when it is available at all.
  TodayAction.withdraw => l.actionTakeItBack,
};

bool _isAuthLoss(Object error) =>
    error is DioException &&
    (error.response?.statusCode == 401 || error.response?.statusCode == 403);

String _time(DateTime d) {
  final hh = d.hour % 12 == 0 ? 12 : d.hour % 12;
  final mm = d.minute.toString().padLeft(2, '0');
  return '$hh:$mm ${d.hour < 12 ? 'AM' : 'PM'}';
}

class _Frame extends StatelessWidget {
  const _Frame({required this.children, this.onClose});

  final List<Widget> children;
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        Padding(
          padding: todayInset.add(
            const EdgeInsets.symmetric(vertical: DsSpacing.space4),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              GestureDetector(
                onTap: onClose,
                behavior: HitTestBehavior.opaque,
                child: DsGlyphIcon(
                DsGlyph.close,
                semanticLabel: L.of(context).detailClose,
              ),
              ),
            ],
          ),
        ),
        ...children,
      ],
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: todayInset.add(
        const EdgeInsets.only(bottom: DsSpacing.space2),
      ),
      child: Text(
        text,
        style: DsTextStyles.labelRitual.copyWith(
          color: DsColors.textOnRitualMuted,
        ),
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

/// What the other person actually wrote, kept visually distinct from anything
/// the app says. Invariant: the system never speaks in a partner's voice,
/// so their words must never be mistakable for the app's.
class _Acknowledgement extends StatelessWidget {
  const _Acknowledgement({required this.value});

  final AcknowledgementView value;

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    return Padding(
      padding: todayInset,
      child: Container(
        padding: const EdgeInsets.all(DsSpacing.space4),
        decoration: BoxDecoration(
          color: DsColors.surfaceRitualRaised,
          borderRadius: BorderRadius.circular(DsRadii.card),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value.senderDisplayName == null
                  ? l.detailTheirWords
                  : l.detailPersonWrote(
                      value.senderDisplayName!.toUpperCase(),
                    ),
              style: DsTextStyles.labelRitual.copyWith(
                color: DsColors.textOnRitualRelationshipLarge,
              ),
            ),
            const SizedBox(height: DsSpacing.space3),
            Text(
              value.text,
              style: DsTextStyles.displayRitual.copyWith(
                color: DsColors.textOnRitualPrimary,
                fontSize: 20,
                height: 27 / 20,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
