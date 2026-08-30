import 'package:ds_relationship_companion/ds_design_system.dart';
import 'package:flutter/material.dart';

import '../../../app/shell/ds_primary_button.dart';
import 'widgets/descending_thread.dart';
import 'widgets/trust_footer.dart';

/// SCR-04 — the private entrance. Where a signed-out person lands.
///
/// Built against `design/screens/SCR-04-private-entrance/candidates/rev-2`.
/// The renderer there is the authority on geometry and copy; this screen is a
/// port of it, not an interpretation.
///
/// Two things about this screen are product decisions, not styling:
///
/// - **It says almost nothing about what the product is.** "Companion",
///   "A private space, on your terms." No category, no relationship framing.
///   This screen can be over someone's shoulder on a train (`REQ-TRUST-001`).
/// - **Every recovery path lands here.** An expired session, an offline
///   launch, a failed session check — all of them are context on this
///   composition rather than a separate page, because replacing the entrance
///   with a "sign in again" screen sends a person to the screen they are on.
class EntranceScreen extends StatelessWidget {
  const EntranceScreen({
    super.key,
    required this.onContinue,
    required this.onSignIn,
    this.notice,
    this.busy = false,
  });

  /// Create an account. The design's word is `Continue`: a button cannot
  /// promise privacy at the device, browser, notification or network layer,
  /// so it does not claim to (decision D8).
  final VoidCallback onContinue;

  final VoidCallback onSignIn;

  /// Session context, when there is any: offline, an ended session, a failed
  /// check. Null on a first open, which is the common case.
  final EntranceNotice? notice;

  /// A registration is in flight.
  final bool busy;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DsColors.canvasRitual,
      body: DsRitualSurface(
        child: SafeArea(
          // The composition wants to breathe on a tall screen and scroll on a
          // short one, so the body fills the viewport when there is room and
          // grows past it when there is not. `IntrinsicHeight` would do this
          // too and costs a second layout pass for something a min-height
          // constraint already gives.
          child: LayoutBuilder(
            builder: (context, constraints) => SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: _EntranceBody(
                  minHeight: constraints.maxHeight,
                  onContinue: onContinue,
                  onSignIn: onSignIn,
                  notice: notice,
                  busy: busy,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// What the session says, when it says anything.
///
/// Deliberately not an error type: an ended session is not a failure, and the
/// entrance never accuses. Each carries the exact line the design specifies.
enum EntranceNotice {
  checking("Checking your session…"),
  sessionEnded('Your session ended. Enter again when you are ready.'),
  offline("You're offline. Connect to continue."),
  unreachable("We couldn't reach the server. Try again.");

  const EntranceNotice(this.line);

  final String line;

  /// Only a genuine failure is coloured as one. Offline and an ended session
  /// are facts about the world, not mistakes anyone made.
  bool get isFailure => this == EntranceNotice.unreachable;
}

class _EntranceBody extends StatelessWidget {
  const _EntranceBody({
    required this.minHeight,
    required this.onContinue,
    required this.onSignIn,
    required this.notice,
    required this.busy,
  });

  /// What the viewport guarantees. The column is given exactly this so its
  /// `Spacer` has something to divide — inside a scroll view the incoming
  /// height is unbounded, and a flex child cannot expand into infinity.
  final double minHeight;

  final VoidCallback onContinue;
  final VoidCallback onSignIn;
  final EntranceNotice? notice;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(minHeight: minHeight),
      padding: const EdgeInsets.symmetric(horizontal: DsSpacing.space6),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        // The gap between the statement and the actions is where the
        // composition's calm comes from, and the design fixes it at 112dp
        // rather than letting it collapse. A `Spacer` cannot do this inside a
        // scroll view — a flex child has no finite space to divide.
        children: [
          // Spacing follows `render-entrance.cjs`, which places every element
          // at an absolute y. Rounding these to the 4dp scale moved the whole
          // composition 46dp up against the design — measured, not guessed.
          const SizedBox(height: 26),
          Text(
            'Companion',
            style: DsTextStyles.labelRitual.copyWith(
              color: DsColors.textOnRitualMuted,
            ),
          ),
          const SizedBox(height: 62),
          const DsSvg(
            asset: DsAssets.markAuthority,
            tone: DsAssetTone.primary,
            width: 64,
            height: 64,
          ),
          // The thread starts 6dp below the mark and runs to its point of
          // light; the headline sits 46dp further down.
          const SizedBox(height: 6),
          const DescendingThread(height: 164),
          const SizedBox(height: 32),
          Text(
            'A private space,\non your terms.',
            textAlign: TextAlign.center,
            style: DsTextStyles.displayRitual.copyWith(
              color: DsColors.textOnRitualPrimary,
            ),
          ),
          const SizedBox(height: 26),
          Text(
            'Private. Considered. Yours.',
            style: DsTextStyles.labelRitual.copyWith(
              color: DsColors.textOnRitualMuted,
              letterSpacing: 2.6,
            ),
          ),
          const SizedBox(height: 92),
          if (notice case final notice?) ...[
            _Notice(notice),
            const SizedBox(height: DsSpacing.space5),
          ],
          DsPrimaryButton(
            label: 'Continue',
            busyLabel: 'Opening',
            busy: busy,
            onPressed: onContinue,
          ),
          const SizedBox(height: DsSpacing.space2),
          TextButton(
            onPressed: busy ? null : onSignIn,
            child: Text(
              'I already have an account',
              style: DsTextStyles.bodySecondary.copyWith(
                color: DsColors.textOnRitualSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: DsSpacing.space5),
          const TrustFooter(),
          const SizedBox(height: DsSpacing.space5),
        ],
      ),
    );
  }
}

class _Notice extends StatelessWidget {
  const _Notice(this.notice);

  final EntranceNotice notice;

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
        notice.line,
        textAlign: TextAlign.center,
        style: DsTextStyles.bodySecondary.copyWith(
          color: notice.isFailure
              ? DsColors.stateError
              : DsColors.textOnRitualSecondary,
        ),
      ),
    );
  }
}
