import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../design_system/components/ds_button.dart';
import '../../../design_system/components/ds_card.dart';
import '../../../design_system/components/ds_page.dart';
import '../../../design_system/components/ds_text.dart';
import '../../../design_system/tokens/colors.dart';
import '../../../design_system/tokens/spacing.dart';
import '../../../design_system/tokens/typography.dart';
import '../../../domain_client/api_client.dart';
import '../../../domain_client/models/starter_rhythm_view.dart';

final starterRhythmProvider =
    FutureProvider.autoDispose.family<StarterRhythmProposal, String>((ref, id) async {
  return ref.watch(starterRhythmRepositoryProvider).propose(id);
});

/// Starter Rhythm — Journey A3.
///
/// The screen answers "does this feel right enough to start?", not "configure
/// your relationship". Notion 05 §3 fixes the copy: *Here's a starting rhythm.
/// Keep what feels right. Replace anything that doesn't.*
///
/// The default is deliberately three small things. A second Expectation is
/// offered below the fold as an opt-in, never included by default: the first
/// day must not arrive already full.
class StarterRhythmScreen extends ConsumerStatefulWidget {
  const StarterRhythmScreen({
    super.key,
    required this.dynamicId,
    required this.assigneeUserId,
    this.onStarted,
  });

  final String dynamicId;
  final String assigneeUserId;
  final VoidCallback? onStarted;

  @override
  ConsumerState<StarterRhythmScreen> createState() => _StarterRhythmScreenState();
}

class _StarterRhythmScreenState extends ConsumerState<StarterRhythmScreen> {
  var _includeSecond = false;
  var _busy = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DsColors.canvas,
      body: ref.watch(starterRhythmProvider(widget.dynamicId)).when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, _) => DsPage(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: DsSpacing.xxxl),
                  Text("We couldn't load a starting rhythm.", style: DsType.h2),
                ],
              ),
            ),
            data: (p) => DsPage(child: _body(p)),
          ),
    );
  }

  Widget _body(StarterRhythmProposal p) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: DsSpacing.sm),
          const DsAccentRule(),
          const SizedBox(height: DsSpacing.sm),
          Text("Here's a starting\nrhythm.", style: DsType.h1),
          const SizedBox(height: DsSpacing.lg),
          Text(
            "Keep what feels right. Replace anything that doesn't.",
            style: DsType.body.copyWith(color: DsColors.muted),
          ),
          const SizedBox(height: DsSpacing.xxxl),

          _Item(
            eyebrow: 'A steady ritual',
            title: p.ritualTitle,
            purpose: p.ritualPurpose,
          ),
          const SizedBox(height: DsSpacing.md),
          _Item(
            eyebrow: 'One expectation',
            title: p.expectationTitle,
            purpose: p.expectationPurpose,
          ),
          const SizedBox(height: DsSpacing.md),
          _Item(
            eyebrow: 'A simple check-in',
            title: p.checkInFraming,
            purpose: 'A place to say how the day actually is.',
          ),

          const SizedBox(height: DsSpacing.xxl),
          // Offered, not included. Framed as "if you want more" rather than
          // "you're missing something".
          CheckboxListTile(
            value: _includeSecond,
            onChanged: _busy ? null : (v) => setState(() => _includeSecond = v ?? false),
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.leading,
            activeColor: DsColors.response,
            title: Text('Add one more expectation', style: DsType.body),
            subtitle: Text(p.optionalSecondTitle, style: DsType.fine),
          ),

          const SizedBox(height: DsSpacing.xxl),
          DsButton(
            label: _busy ? 'Starting…' : 'Start this rhythm',
            onPressed: _busy ? null : _start,
          ),
          const SizedBox(height: DsSpacing.lg),
          Center(
            child: Text(
              'You can change any of this later.',
              style: DsType.fine,
            ),
          ),
        ],
      );

  Future<void> _start() async {
    setState(() => _busy = true);
    try {
      await ref.read(starterRhythmRepositoryProvider).start(
            widget.dynamicId,
            assigneeUserId: widget.assigneeUserId,
            includeSecondExpectation: _includeSecond,
            idempotencyKey: ApiClient.newIdempotencyKey(),
          );
      widget.onStarted?.call();
    } catch (_) {
      if (mounted) {
        setState(() => _busy = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("That didn't go through. Please try again.")),
        );
      }
    }
  }
}

class _Item extends StatelessWidget {
  const _Item({required this.eyebrow, required this.title, required this.purpose});

  final String eyebrow;
  final String title;
  final String purpose;

  @override
  Widget build(BuildContext context) => DsCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DsEyebrow(eyebrow, terra: true),
            const SizedBox(height: DsSpacing.sm),
            Text(title, style: DsType.cardTitle),
            const SizedBox(height: DsSpacing.xs),
            Text(purpose, style: DsType.fine),
          ],
        ),
      );
}
