import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../design_system/components/ds_app_bar.dart';
import '../../../design_system/components/ds_button.dart';
import '../../../design_system/components/ds_text.dart';
import '../../../design_system/tokens/colors.dart';
import '../../../design_system/tokens/spacing.dart';
import '../../../design_system/tokens/typography.dart';
import '../../../domain_client/api_client.dart';
import '../../../domain_client/models/occurrence.dart';
import '../../../domain_client/models/occurrence_view.dart';
import '../../attention/presentation/adjustment_sheet.dart';
import '../../attention/presentation/resolve_adjustment_sheet.dart';
import '../../attention/presentation/respond_screen.dart';
import 'acknowledgement_received_screen.dart';
import 'waiting_screen.dart';

/// Always fetches server truth. A stale push or deep link must resolve current
/// state before anything renders (Notion 06 §8).
final occurrenceProvider =
    FutureProvider.autoDispose.family<OccurrenceView, String>((ref, id) async {
  return ref.watch(occurrenceRepositoryProvider).get(id);
});

/// Routes one occurrence to the right screen for its CURRENT server state.
///
/// The client never infers which screen to show from local history — the
/// server's state field decides (Notion 03 §8).
class OccurrenceScreen extends ConsumerWidget {
  const OccurrenceScreen({super.key, required this.occurrenceId, this.onBack});

  final String occurrenceId;

  /// Sub-screens need a visible way back: the Android system button does
  /// not exist on iOS Safari or the web build.
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(occurrenceProvider(occurrenceId));

    return Scaffold(
      backgroundColor: DsColors.canvas,
      appBar: DsAppBar(title: 'Expectation', onBack: onBack),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => _Recoverable(
          onRetry: () => ref.invalidate(occurrenceProvider(occurrenceId)),
        ),
        data: (o) => _forState(context, ref, o),
      ),
    );
  }

  Widget _forState(BuildContext context, WidgetRef ref, OccurrenceView o) {
    void refresh() => ref.invalidate(occurrenceProvider(occurrenceId));

    // ORDER MATTERS. allowedActions is the server's view of what THIS actor
    // may do, so it must be consulted BEFORE falling back on state alone:
    // in WAITING_ACK the receiving side sees Waiting, but the direction-giving
    // side must see Respond. Matching on state first showed the creator the
    // receiving side's screen and made acknowledging unreachable.
    return switch (o.state) {
      _ when o.allowedActions.contains('acknowledge') => RespondScreen(
          occurrence: o,
          partnerName: o.partnerDisplayName,
          onSend: (type, text) async {
            await ref.read(occurrenceRepositoryProvider).acknowledge(
                  o.id,
                  type: type,
                  text: text,
                  idempotencyKey: ApiClient.newIdempotencyKey(),
                );
            refresh();
          },
        ),
      // An open adjustment takes priority: someone is waiting for an answer.
      _ when o.allowedActions.contains('continue') => _AwaitingResolution(
          occurrence: o,
          onOpen: () => ResolveAdjustmentSheet.show(
            context,
            requesterName: 'Your partner',
            requestType: o.state.name,
            onResolve: (resolution, note) async {
              await ref.read(adjustmentRepositoryProvider).resolve(
                    o.id,
                    resolution: resolution,
                    note: note,
                    idempotencyKey: ApiClient.newIdempotencyKey(),
                  );
              refresh();
            },
          ),
        ),
      OccurrenceState.waitingAck => WaitingScreen(
          occurrence: o,
          partnerName: o.partnerDisplayName,
          onBack: refresh,
        ),
      OccurrenceState.acknowledged =>
        AcknowledgementReceivedScreen(occurrence: o, onReturn: refresh),
      _ => _ActiveExpectation(
          occurrence: o,
          partnerName: o.partnerDisplayName,
          onAdjust: () => AdjustmentSheet.show(context, (type, note) async {
            await ref.read(adjustmentRepositoryProvider).request(
                  o.id,
                  type: type,
                  note: note,
                  idempotencyKey: ApiClient.newIdempotencyKey(),
                );
            refresh();
          }),
          onComplete: () async {
            await ref.read(occurrenceRepositoryProvider).complete(
                  o.id,
                  idempotencyKey: ApiClient.newIdempotencyKey(),
                );
            refresh();
          },
        ),
    };
  }
}

/// Expectation Detail — Warm Authority V5 screen 2.
class _ActiveExpectation extends StatelessWidget {
  const _ActiveExpectation({
    required this.occurrence,
    required this.onComplete,
    this.onAdjust,
    this.partnerName,
  });

  final OccurrenceView occurrence;
  final Future<void> Function() onComplete;
  final VoidCallback? onAdjust;

  /// Who asked. A task has a title; a request has a person behind it.
  final String? partnerName;

  @override
  Widget build(BuildContext context) {
    final canComplete = occurrence.allowedActions.contains('complete');
    final canAdjust =
        occurrence.allowedActions.contains('discuss') && onAdjust != null;

    return SafeArea(
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(DsSpacing.screenPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Who asked. Without this the screen described a task
                  // rather than something one person asked of another.
                  if (partnerName != null) ...[
                    DsEyebrow('From $partnerName', terra: true),
                    const SizedBox(height: DsSpacing.md),
                  ],
                  Text(occurrence.title, style: DsType.h1),
                  if (occurrence.purpose != null) ...[
                    const SizedBox(height: DsSpacing.md),
                    // Why it matters, in the serif reserved for what a
                    // person says — it is their reason, not metadata.
                    Text(occurrence.purpose!,
                        style: DsType.cardTitle.copyWith(
                            fontSize: 17, height: 1.4)),
                  ],
                  if (occurrence.dueAt != null) ...[
                    const SizedBox(height: DsSpacing.xl),
                    const Divider(color: DsColors.line, height: 1),
                    const SizedBox(height: DsSpacing.lg),
                    // The data was there and never shown, so the screen
                    // could not answer "by when".
                    Text(_due(occurrence.dueAt!),
                        style: DsType.fine.copyWith(color: DsColors.muted)),
                  ],
                ],
              ),
            ),
          ),

          // A dock, not buttons floating in the middle of empty page space.
          // Both paths sit side by side because completing and asking to
          // adjust are equally legitimate (red line #3) — the adjustment
          // path is never a menu item and never smaller.
          Padding(
            padding: const EdgeInsets.fromLTRB(
                DsSpacing.screenPadding, DsSpacing.md,
                DsSpacing.screenPadding, DsSpacing.xl),
            child: Row(
              children: [
                if (canComplete)
                  Expanded(
                    flex: 57,
                    child: DsButton(label: 'Complete', onPressed: onComplete),
                  ),
                if (canComplete && canAdjust)
                  const SizedBox(width: DsSpacing.md),
                if (canAdjust)
                  Expanded(
                    flex: 43,
                    child: DsButton(
                      label: 'Adjust',
                      outline: true,
                      onPressed: onAdjust,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _due(DateTime at) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final day = DateTime(at.year, at.month, at.day);
    final h = at.hour % 12 == 0 ? 12 : at.hour % 12;
    final mm = at.minute.toString().padLeft(2, '0');
    final time = '$h:$mm ${at.hour < 12 ? 'AM' : 'PM'}';
    final diff = day.difference(today).inDays;
    if (diff == 0) return 'By $time today';
    if (diff == 1) return 'By $time tomorrow';
    // Never "overdue": past due is Needs review, not a verdict.
    if (diff < 0) return 'Was due at $time';
    return 'In $diff days, at $time';
  }
}

class _Recoverable extends StatelessWidget {
  const _Recoverable({required this.onRetry});
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(DsSpacing.screenPadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("We couldn't load this right now.", style: DsType.h2),
            const SizedBox(height: DsSpacing.lg),
            Text(
              'Your partner still sees the same thing you do — nothing was lost.',
              style: DsType.body.copyWith(color: DsColors.muted),
            ),
            const SizedBox(height: DsSpacing.xxl),
            DsButton(label: 'Try again', onPressed: onRetry),
          ],
        ),
      );
}

/// Something was asked and the other person has not answered yet.
///
/// Shown to whoever must respond. Deliberately calm: an open adjustment is a
/// conversation in progress, not an overdue approval task.
class _AwaitingResolution extends StatelessWidget {
  const _AwaitingResolution({required this.occurrence, required this.onOpen});

  final OccurrenceView occurrence;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(DsSpacing.screenPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: DsSpacing.xl),
              const DsEyebrow('Waiting on you', terra: true),
              const SizedBox(height: DsSpacing.md),
              Text(occurrence.title, style: DsType.h1),
              const SizedBox(height: DsSpacing.lg),
              Text(
                'Your partner asked to adjust this. Nothing is late and '
                'nothing was missed.',
                style: DsType.body.copyWith(color: DsColors.muted),
              ),
              const SizedBox(height: DsSpacing.xxl),
              DsButton(label: 'Answer', onPressed: onOpen),
            ],
          ),
        ),
      );
}
