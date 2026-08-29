import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../design_system/components/ds_app_bar.dart';
import '../../../design_system/components/ds_button.dart';
import '../../../design_system/components/ds_card.dart';
import '../../../design_system/components/ds_page.dart';
import '../../../design_system/tokens/colors.dart';
import '../../../design_system/tokens/spacing.dart';
import '../../../design_system/tokens/typography.dart';
import '../../../domain_client/api_client.dart';

/// Leave or separate — Journey F. The safety screen.
///
/// The design tension here is real: someone reaching for Block may be unsafe
/// and may be observed. Too much friction (type DELETE, a wizard) means they
/// cannot act quickly and the flow is visible over their shoulder. Too little
/// means an irreversible mistake.
///
/// Resolution, per the safety review:
/// - Both actions live together and are findable, not buried in a "danger
///   zone". Block must never depend on a role or a partner-controlled setting.
/// - Two taps each. No typed phrase, no countdown, no checkbox, no wizard.
/// - Consequences are stated plainly BEFORE confirming, including the ones
///   that cost the person acting something. Withholding an irreversible
///   consequence is not protection.
/// - The aftermath is deliberately unremarkable: no success animation, no
///   banner, nothing an observer could read.
class SeparationScreen extends ConsumerStatefulWidget {
  const SeparationScreen({
    super.key,
    required this.dynamicId,
    required this.partnerUserId,
    required this.partnerName,
    this.onDone,
  });

  final String dynamicId;
  final String partnerUserId;
  final String partnerName;
  final VoidCallback? onDone;

  @override
  ConsumerState<SeparationScreen> createState() => _SeparationScreenState();
}

class _SeparationScreenState extends ConsumerState<SeparationScreen> {
  var _busy = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DsColors.canvas,
      appBar: DsAppBar(title: 'Leave or separate', onBack: widget.onDone),
      body: DsPage(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: DsSpacing.sm),
            Text('Leave or separate', style: DsType.h1),
            const SizedBox(height: DsSpacing.lg),
            Text(
              'Both of these are always available to you.',
              style: DsType.body.copyWith(color: DsColors.muted),
            ),
            const SizedBox(height: DsSpacing.xxxl),

            _Choice(
              title: 'Leave this dynamic',
              body: 'You leave immediately. Future shared actions and '
                  'reminders stop. ${widget.partnerName} keeps access to the '
                  'history you already share.',
              actionLabel: 'Leave',
              onTap: _busy ? null : () => _confirmLeave(context),
            ),

            const SizedBox(height: DsSpacing.xl),

            _Choice(
              title: 'Block and separate',
              // The cost to the person acting is stated plainly. Withholding
              // an irreversible consequence is not protection.
              body: 'This ends the dynamic for both of you immediately and '
                  'seals the shared history — including for you. Invitations '
                  'stop working. They are not told who did this. '
                  'It cannot be undone.',
              actionLabel: 'Block',
              emphasised: true,
              onTap: _busy ? null : () => _confirmBlock(context),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmLeave(BuildContext context) async {
    final ok = await _confirm(
      context,
      title: 'Leave this dynamic?',
      body: 'You leave immediately. Future shared actions and reminders stop.',
      confirmLabel: 'Leave now',
    );
    if (ok != true) return;

    setState(() => _busy = true);
    try {
      await ref.read(dynamicRepositoryProvider).leave(
            widget.dynamicId,
            idempotencyKey: ApiClient.newIdempotencyKey(),
          );
      widget.onDone?.call();
    } catch (_) {
      _failed();
    }
  }

  Future<void> _confirmBlock(BuildContext context) async {
    final ok = await _confirm(
      context,
      title: 'Block and separate?',
      body: 'The separation takes effect immediately. Shared history is '
          'sealed for both of you, including you. This cannot be undone.',
      confirmLabel: 'Block and seal now',
    );
    if (ok != true) return;

    setState(() => _busy = true);
    try {
      await ref.read(dynamicRepositoryProvider).block(
            widget.dynamicId,
            targetUserId: widget.partnerUserId,
            idempotencyKey: ApiClient.newIdempotencyKey(),
          );
      widget.onDone?.call();
    } catch (_) {
      _failed();
    }
  }

  void _failed() {
    if (!mounted) return;
    setState(() => _busy = false);
    // No dead end: a safety action that fails must say so and stay retryable.
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("That didn't go through. Please try again.")),
    );
  }

  /// One compact confirmation. Deliberately NOT a wizard: a long flow is
  /// visible over someone's shoulder and slows an urgent action.
  Future<bool?> _confirm(
    BuildContext context, {
    required String title,
    required String body,
    required String confirmLabel,
  }) =>
      showModalBottomSheet<bool>(
        context: context,
        backgroundColor: DsColors.canvas,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        builder: (sheetContext) => Padding(
          padding: const EdgeInsets.all(DsSpacing.screenPadding),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: DsType.h2),
              const SizedBox(height: DsSpacing.lg),
              Text(body, style: DsType.body.copyWith(color: DsColors.muted)),
              const SizedBox(height: DsSpacing.xxl),
              DsButton(
                label: confirmLabel,
                onPressed: () => Navigator.of(sheetContext).pop(true),
              ),
              const SizedBox(height: DsSpacing.md),
              DsButton(
                label: 'Go back',
                outline: true,
                onPressed: () => Navigator.of(sheetContext).pop(false),
              ),
            ],
          ),
        ),
      );
}

class _Choice extends StatelessWidget {
  const _Choice({
    required this.title,
    required this.body,
    required this.actionLabel,
    required this.onTap,
    this.emphasised = false,
  });

  final String title;
  final String body;
  final String actionLabel;
  final VoidCallback? onTap;
  final bool emphasised;

  @override
  Widget build(BuildContext context) => DsCard(
        tone: DsCardTone.light,
        // A quiet terracotta rail marks the irreversible one — enough to
        // distinguish it, without the alarm styling that would make the screen
        // conspicuous to someone looking over a shoulder.
        showRail: emphasised,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: DsType.cardTitle),
            const SizedBox(height: DsSpacing.sm),
            Text(body, style: DsType.fine),
            const SizedBox(height: DsSpacing.xl),
            DsButton(label: actionLabel, outline: !emphasised, onPressed: onTap),
          ],
        ),
      );
}
