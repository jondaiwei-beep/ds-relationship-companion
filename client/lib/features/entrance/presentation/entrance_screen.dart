import 'package:ds_relationship_companion/ds_design_system.dart';
import 'package:flutter/material.dart';

import '../../../app/shell/ds_primary_button.dart';
import '../../../l10n/app_localizations.dart';
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
              // `IntrinsicHeight` so the Column can be BOTH exactly the
              // viewport when the content fits and taller when it does not.
              // A bare min-height constraint leaves the incoming height
              // unbounded, and a `Spacer` in an unbounded Column is a layout
              // error — which is what the device reported.
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
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
      ),
    );
  }
}

/// What the session says, when it says anything.
///
/// Deliberately not an error type: an ended session is not a failure, and the
/// entrance never accuses. Each carries the exact line the design specifies.
enum EntranceNotice {
  checking,
  sessionEnded,
  offline,
  unreachable;

  /// The sentence, in the reader's language. The enum names the situation and
  /// the locale supplies the words, so the entrance speaks the language of the
  /// person who reached it rather than the one it was written in.
  String line(BuildContext context) {
    final l = L.of(context);
    return switch (this) {
      EntranceNotice.checking => l.entranceNoticeChecking,
      EntranceNotice.sessionEnded => l.entranceNoticeSessionEnded,
      EntranceNotice.offline => l.entranceNoticeOffline,
      EntranceNotice.unreachable => l.entranceNoticeUnreachable,
    };
  }

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
    // The absolute spacings below come from `render-entrance.cjs`, which
    // composes at a fixed canvas height. On an iPhone 17 they overflowed by
    // 101dp and put the legal footer below the fold with no cue it was there.
    // The page scrolls, so nothing overflowed and no test failed; it was found
    // by looking at a simulator.
    //
    // Only the breathing room yields — never type, targets or the mark.

    final l = L.of(context);
    return Container(
      constraints: BoxConstraints(minHeight: minHeight),
      padding: const EdgeInsets.symmetric(horizontal: DsSpacing.space6),
      // A Column that fills its box, so the breathing room is real space
      // handed to flex children rather than a number guessed in advance. A
      // hardcoded "fixed content" constant was wrong on the device by 122dp:
      // measured in a widget test, it did not survive the platform's own text
      // metrics. Flex asks the layout instead of predicting it.
      child: Column(
        mainAxisSize: MainAxisSize.max,
        // The gap between the statement and the actions is where the
        // composition's calm comes from, and the design fixes it at 112dp
        // rather than letting it collapse. A `Spacer` cannot do this inside a
        // scroll view — a flex child has no finite space to divide.
        children: [
          // Spacing follows `render-entrance.cjs`, which places every element
          // at an absolute y. Rounding these to the 4dp scale moved the whole
          // composition 46dp up against the design — measured, not guessed.
          const Spacer(flex: 26),
          Text(
            l.entranceWordmark,
            style: DsTextStyles.labelRitual.copyWith(
              color: DsColors.textOnRitualMuted,
            ),
          ),
          const Spacer(flex: 62),
          const DsSvg(
            asset: DsAssets.markAuthority,
            tone: DsAssetTone.primary,
            width: 64,
            height: 64,
          ),
          // The thread starts 6dp below the mark and runs to its point of
          // light; the headline sits 46dp further down.
          const SizedBox(height: 6),
          const DescendingThread(height: 130),
          const Spacer(flex: 32),
          Text(
            l.entranceHeadline,
            textAlign: TextAlign.center,
            style: DsTextStyles.displayRitual.copyWith(
              color: DsColors.textOnRitualPrimary,
            ),
          ),
          const Spacer(flex: 26),
          Text(
            l.entranceTagline,
            style: DsTextStyles.labelRitual.copyWith(
              color: DsColors.textOnRitualMuted,
              letterSpacing: 2.6,
            ),
          ),
          const Spacer(flex: 92),
          if (notice case final notice?) ...[
            _Notice(notice),
            const SizedBox(height: DsSpacing.space5),
          ],
          DsPrimaryButton(
            label: l.entranceContinue,
            busyLabel: l.entranceContinueBusy,
            busy: busy,
            onPressed: onContinue,
          ),
          const SizedBox(height: DsSpacing.space2),
          TextButton(
            onPressed: busy ? null : onSignIn,
            child: Text(
              l.entranceHaveAccount,
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
        notice.line(context),
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
