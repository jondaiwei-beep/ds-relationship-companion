import 'package:dio/dio.dart';
import 'package:ds_relationship_companion/ds_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../app/shell/ds_primary_button.dart';
import '../../../app/shell/ds_text_field.dart';
import '../../../domain_client/models/occurrence.dart';
import '../../../domain_client/models/occurrence_view.dart';
import '../../today/application/today_actions.dart';
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
    final occurrence = ref.watch(occurrenceProvider(widget.occurrenceId));

    return Scaffold(
      backgroundColor: DsColors.canvasRitual,
      body: DsRitualSurface(
        child: SafeArea(
          child: occurrence.when(
            skipLoadingOnReload: true,
            loading: () => _Frame(
              onClose: widget.onClose,
              children: const [
                SizedBox(height: DsSpacing.space10),
                _Quiet('Confirming this with the server.'),
              ],
            ),
            error: (error, _) => _Frame(
              onClose: widget.onClose,
              children: [
                const SizedBox(height: DsSpacing.space10),
                _Quiet(
                  _isAuthLoss(error)
                      ? 'Your private session needs to be restored. Nothing '
                            'about this is shown until it is.'
                      : 'This could not be loaded. Nothing was changed.',
                  prominent: true,
                ),
                const SizedBox(height: DsSpacing.space6),
                if (!_isAuthLoss(error))
                  Padding(
                    padding: todayInset,
                    child: SecondaryButton(
                      label: 'Try again',
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
          _Label('DUE'),
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
                    'Set by ${view.partnerDisplayName}',
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
          _Label('INTENTION'),
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
          _Label('PRIVATE NOTE · ONLY YOU'),
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
          _Label('COMPLETION NOTE (OPTIONAL)'),
          Padding(
            padding: todayInset,
            child: DsTextField(
              label: '',
              controller: _note,
              hint: 'What did you attend to?',
              enabled: _busy == null,
            ),
          ),
          const SizedBox(height: DsSpacing.space6),
          Padding(
            padding: todayInset,
            child: DsPrimaryButton(
              label: 'Mark complete',
              busy: _busy == TodayAction.complete,
              busyLabel: 'Completing…',
              onPressed: _busy != null
                  ? null
                  : () => _run(TodayAction.complete),
            ),
          ),
          if (view.partnerDisplayName != null) ...[
            const SizedBox(height: DsSpacing.space3),
            _Quiet('${view.partnerDisplayName} will see this.'),
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
                        _busy == a ? '…' : _adjustmentLabel(a),
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
          _Quiet(_nothingToDo(view.state), prominent: true),
          const SizedBox(height: DsSpacing.space5),
          Padding(
            padding: todayInset,
            child: SecondaryButton(
              label: _busy == TodayAction.withdraw
                  ? 'Taking it back…'
                  : 'Never mind, take it back',
              onTap: _busy != null
                  ? () {}
                  : () => _run(TodayAction.withdraw),
            ),
          ),
          const SizedBox(height: DsSpacing.space3),
          const _Quiet(
            'It goes back to how it was. Nothing is recorded as agreed or '
            'refused.',
          ),
        ] else if (!canComplete && adjustments.isEmpty) ...[
          _Quiet(_nothingToDo(view.state), prominent: true),
        ],

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
String _nothingToDo(OccurrenceState state) => switch (state) {
  OccurrenceState.waitingAck => 'Done, and waiting for a human response.',
  OccurrenceState.acknowledged => 'Answered. Nothing more is needed here.',
  OccurrenceState.needToDiscuss => 'You asked to talk about this.',
  OccurrenceState.rescheduleRequested => 'You asked for another time.',
  OccurrenceState.excuseRequested => 'You said you could not do this.',
  OccurrenceState.cancelled => 'This was cancelled.',
  _ => 'Nothing is waiting on you here.',
};

String _adjustmentLabel(TodayAction a) => switch (a) {
  TodayAction.discuss => 'Discuss',
  TodayAction.requestNewTime => 'New time',
  TodayAction.cantDo => "Can't do",
  TodayAction.complete => 'Complete',
  // Never rendered in the adjustment row: withdrawing is offered on its own,
  // because it is the only thing available when it is available at all.
  TodayAction.withdraw => 'Take it back',
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
                child: Icon(
                  Icons.close,
                  size: 22,
                  color: DsColors.textOnRitualMuted,
                  semanticLabel: 'Close',
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
/// the app says. Red line #1: the system never speaks in a partner's voice,
/// so their words must never be mistakable for the app's.
class _Acknowledgement extends StatelessWidget {
  const _Acknowledgement({required this.value});

  final AcknowledgementView value;

  @override
  Widget build(BuildContext context) {
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
                  ? 'THEIR WORDS'
                  : '${value.senderDisplayName!.toUpperCase()} WROTE',
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
