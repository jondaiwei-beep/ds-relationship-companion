import 'package:ds_relationship_companion/ds_design_system.dart';
import 'package:flutter/material.dart';

import '../../../app/shell/ds_primary_button.dart';
import '../../../domain_client/models/occurrence_view.dart';

/// SCR-02 and SCR-03 — the two ends of one moment.
///
/// Completing is not being answered. `REQ-COMPLETE-001` makes that a separate
/// state rather than a detail of the same screen, and the two-node progress
/// says it before any copy does: the first node fills on completion, the
/// second only when a human responds.
///
/// So this one widget renders both ends. They are the same moment seen twice —
/// once while it is open, once when it has closed — and building them apart is
/// how "completed" starts quietly meaning "done".
class WaitingScreen extends StatelessWidget {
  const WaitingScreen({
    super.key,
    required this.occurrence,
    required this.onClose,
  });

  final OccurrenceView occurrence;

  /// Back to Today. Never "dismiss" — nothing here is being dismissed.
  final VoidCallback onClose;

  bool get _answered => occurrence.acknowledgement != null;

  @override
  Widget build(BuildContext context) {
    final partner = occurrence.partnerDisplayName ?? 'your partner';
    return Scaffold(
      backgroundColor: DsColors.canvasRitual,
      body: DsRitualSurface(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: DsSpacing.space5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _Header(
                  title: _answered ? 'Acknowledgement' : occurrence.title,
                  // Present tense, not a promise. "$partner will respond"
                  // commits another human to an action they have not taken,
                  // which is the app speaking for them.
                  presence: _answered
                      ? '$partner is present'
                      : 'Waiting for $partner',
                ),
                const SizedBox(height: DsSpacing.space6),
                const Center(
                  child: DsSvg(
                    asset: DsAssets.emblemRitualEvening,
                    tone: DsAssetTone.muted,
                    width: 40,
                    height: 40,
                  ),
                ),
                const SizedBox(height: DsSpacing.space4),
                Center(
                  child: Text(
                    occurrence.title.toUpperCase(),
                    style: DsTextStyles.labelRitual.copyWith(
                      color: DsColors.textOnRitualMuted,
                      fontSize: 10,
                      letterSpacing: 1.8,
                    ),
                  ),
                ),
                const SizedBox(height: DsSpacing.space8),
                if (_answered)
                  _Answered(acknowledgement: occurrence.acknowledgement!)
                else
                  _Waiting(
                    completedAt: occurrence.completedAt,
                    privateNote: occurrence.privateNote,
                    partner: partner,
                  ),
                const SizedBox(height: DsSpacing.space10),
                DsPrimaryButton(
                  label: _answered ? 'Close ritual' : 'Return to Today',
                  onPressed: onClose,
                ),
                const SizedBox(height: DsSpacing.space6),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Completed, and waiting. The whole point of `REQ-COMPLETE-001`.
class _Waiting extends StatelessWidget {
  const _Waiting({
    required this.completedAt,
    required this.privateNote,
    required this.partner,
  });

  final DateTime? completedAt;
  final String? privateNote;
  final String partner;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: Text(
            'Your service\nis recorded.',
            textAlign: TextAlign.center,
            style: DsTextStyles.displayRitual.copyWith(
              color: DsColors.textOnRitualPrimary,
            ),
          ),
        ),
        if (completedAt case final at?) ...[
          const SizedBox(height: DsSpacing.space4),
          Center(
            child: Text(
              'COMPLETED AT ${_clock(at.toLocal())}',
              style: DsTextStyles.labelRitual.copyWith(
                color: DsColors.textOnRitualMuted,
                fontSize: 10,
                letterSpacing: 1.6,
              ),
            ),
          ),
        ],
        const SizedBox(height: DsSpacing.space8),
        _Progress(partner: partner),
        const SizedBox(height: DsSpacing.space8),
        Center(
          child: Text(
            // Says the moment is unfinished, and says who finishes it. Never
            // "done", never a tick, never anything that reads as closure.
            'Your part is complete.\n'
            "$partner has not responded yet.",
            textAlign: TextAlign.center,
            style: DsTextStyles.bodySecondary.copyWith(
              color: DsColors.textOnRitualSecondary,
              height: 22 / 14,
            ),
          ),
        ),
        if (privateNote case final note?) ...[
          const SizedBox(height: DsSpacing.space8),
          _PrivateNote(note),
        ],
      ],
    );
  }
}

/// Two nodes. The second fills only when a person answers.
///
/// This is the difference between this product and a checklist, drawn rather
/// than argued: completion is one node, and it is not the last one.
class _Progress extends StatelessWidget {
  const _Progress({required this.partner});

  final String partner;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 20,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 60),
                child: Container(
                  height: DsBorderWidths.hairline,
                  color: DsColors.borderOnRitualHairline,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 50),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    _Node(filled: true, tone: DsColors.stateCompleted),
                    _Node(filled: false, tone: DsColors.stateWaiting),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: DsSpacing.space3),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(
                'COMPLETED',
                style: DsTextStyles.labelRitual.copyWith(
                  color: DsColors.textOnRitualMuted,
                  fontSize: 10,
                  letterSpacing: 1.4,
                ),
              ),
            ),
            Flexible(
              child: Text(
                'WAITING FOR ${partner.toUpperCase()}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.right,
                style: DsTextStyles.labelRitual.copyWith(
                  color: DsColors.stateWaiting,
                  fontSize: 10,
                  letterSpacing: 1.4,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _Node extends StatelessWidget {
  const _Node({required this.filled, required this.tone});

  final bool filled;
  final Color tone;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 18,
      height: 18,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: DsColors.canvasRitual,
        border: Border.all(color: tone, width: 1.5),
      ),
      child: filled
          ? Center(
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(shape: BoxShape.circle, color: tone),
              ),
            )
          : null,
    );
  }
}

/// The answer arrived. SCR-03.
class _Answered extends StatelessWidget {
  const _Answered({required this.acknowledgement});

  final AcknowledgementView acknowledgement;

  @override
  Widget build(BuildContext context) {
    final words = acknowledgement.text.trim();
    // The sender on the acknowledgement itself, not whoever the occurrence
    // calls the partner. `ui-invariants.md`: "received screen attributes the
    // words to the real sender." On a Dynamic those are the same person today
    // — but attributing by role rather than by record is how a screen ends up
    // naming the wrong human the first time they are not.
    final sender = acknowledgement.senderDisplayName;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: Text(
            'You are seen.',
            style: DsTextStyles.displayRitual.copyWith(
              color: DsColors.textOnRitualPrimary,
            ),
          ),
        ),
        const SizedBox(height: DsSpacing.space8),
        if (words.isEmpty)
          // A wordless acknowledgement is a real human response, and the
          // screen must not fill the silence. It reports what happened and
          // attributes it — it does not invent a sentence Morgan did not say.
          Column(
            children: [
              const DsSvg(
                asset: DsAssets.stateAcknowledged,
                tone: DsAssetTone.relationship,
                width: 32,
                height: 32,
              ),
              const SizedBox(height: DsSpacing.space5),
              Text(
                sender == null
                    ? 'This was acknowledged.'
                    : '$sender acknowledged this.',
                textAlign: TextAlign.center,
                style: DsTextStyles.bodyPrimary.copyWith(
                  color: DsColors.textOnRitualSecondary,
                ),
              ),
            ],
          )
        else
          // Their words, in Terracotta Cormorant: visually distinct from every
          // system line on the screen (REQ-ACK-001), and above the 24sp floor
          // the token freeze sets for Terracotta text.
          Text(
            words,
            textAlign: TextAlign.center,
            style: DsTextStyles.displayPartner.copyWith(
              color: DsColors.textOnRitualRelationshipLarge,
            ),
          ),
        const SizedBox(height: DsSpacing.space8),
        Center(
          child: Text(
            'RECEIVED AT ${_clock(acknowledgement.sentAt.toLocal())}',
            style: DsTextStyles.labelRitual.copyWith(
              color: DsColors.textOnRitualMuted,
              fontSize: 10,
              letterSpacing: 1.6,
            ),
          ),
        ),
      ],
    );
  }
}

/// What this person wrote for themselves. The server returns it only to its
/// author, so the label is true of everyone who can see it.
class _PrivateNote extends StatelessWidget {
  const _PrivateNote(this.note);

  final String note;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'PRIVATE NOTE · ONLY YOU',
          style: DsTextStyles.labelRitual.copyWith(
            color: DsColors.textOnRitualMuted,
            fontSize: 10,
            letterSpacing: 1.6,
          ),
        ),
        const SizedBox(height: DsSpacing.space3),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(DsSpacing.space4),
          decoration: BoxDecoration(
            color: DsColors.surfaceRitualRaised,
            borderRadius: BorderRadius.circular(DsRadii.medium),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const DsSvg(
                asset: DsAssets.motifBotanicalNoteSprig,
                tone: DsAssetTone.decorative,
                width: 20,
                height: 20,
              ),
              const SizedBox(width: DsSpacing.space3),
              Expanded(
                child: Text(
                  note,
                  style: DsTextStyles.bodyPrimary.copyWith(
                    color: DsColors.textOnRitualSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.title, required this.presence});

  final String title;
  final String presence;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: DsSpacing.space5),
      child: Row(
        children: [
          Flexible(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: DsTextStyles.titlePage.copyWith(
                color: DsColors.textOnRitualPrimary,
              ),
            ),
          ),
          const Spacer(),
          const DsSvg(
            asset: DsAssets.markPresence,
            tone: DsAssetTone.relationship,
            width: 20,
            height: 20,
          ),
          const SizedBox(width: DsSpacing.space3),
          Flexible(
            child: Text(
              presence,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: DsTextStyles.bodySecondary.copyWith(
                color: DsColors.textOnRitualRelationshipLarge,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

String _clock(DateTime t) {
  final hour = t.hour % 12 == 0 ? 12 : t.hour % 12;
  return '$hour:${t.minute.toString().padLeft(2, '0')} '
      '${t.hour < 12 ? 'AM' : 'PM'}';
}
