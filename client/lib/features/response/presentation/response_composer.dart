import 'package:ds_relationship_companion/ds_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/shell/ds_primary_button.dart';
import '../../../l10n/app_localizations.dart';
import '../application/response_actions.dart';

/// What each way of answering is called, in the reader's language.
///
/// A label on the enum would be one English sentence the composer cannot
/// translate — and this screen, more than any other, must read as one person
/// speaking to another rather than as software with a vocabulary.
String responseTypeLabel(L l, HumanResponse type) => switch (type) {
  HumanResponse.acknowledge => l.responseTypeAcknowledge,
  HumanResponse.praise => l.responseTypePraise,
  HumanResponse.comment => l.responseTypeComment,
  HumanResponse.review => l.responseTypeReview,
};

/// SCR-33 — the acknowledgement composer.
///
/// The single most constrained screen in the product. The rule lives here:
/// **only an explicit human Send creates an Acknowledgement**, and the system
/// never speaks in the partner's voice.
///
/// That is not a styling note. It rules out every convenience a composer
/// usually has:
///
/// - The field starts **empty**. No pre-filled sentence, however gentle,
///   because a person who taps Send on words they did not write has not said
///   anything and the recipient cannot tell.
/// - Suggestions, if they are ever added, may only *fill the field* and must
///   be labelled as suggestions. An untouched suggestion is not the sender's
///   words.
/// - Nothing is sent by leaving, by completing, or by time passing.
///
/// And the floor from `REQ-ACK-001`: basic acknowledgement is **two taps** —
/// pick a type, press Send. Requiring words would mean a person with nothing
/// to add cannot answer at all, and silence would have to stand in for an
/// answer. It does not: only a send closes the loop.
class ResponseComposer extends ConsumerStatefulWidget {
  const ResponseComposer({
    super.key,
    required this.occurrenceId,
    required this.partnerName,
    required this.expectationTitle,
    required this.completedAt,
    required this.onSent,
    required this.onDismiss,
  });

  final String occurrenceId;

  /// The person being answered, by name. Never "your partner": this screen is
  /// about one human addressing another.
  final String partnerName;

  final String expectationTitle;
  final String completedAt;

  final VoidCallback onSent;

  /// Leaving without sending. Explicitly not a decision — the moment stays
  /// open and unanswered, which is the truth.
  final VoidCallback onDismiss;

  @override
  ConsumerState<ResponseComposer> createState() => _ResponseComposerState();
}

class _ResponseComposerState extends ConsumerState<ResponseComposer> {
  final _words = TextEditingController();

  HumanResponse _type = HumanResponse.acknowledge;
  bool _busy = false;
  bool _needsWords = false;
  bool _alreadyAnswered = false;
  ResponseFailureReason? _failure;

  @override
  void dispose() {
    _words.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _needsWords = false;
      _failure = null;
    });

    final outcome = await ref.read(responseActionsProvider).send(
          occurrenceId: widget.occurrenceId,
          type: _type,
          text: _words.text,
        );

    if (!mounted) return;
    setState(() => _busy = false);

    switch (outcome) {
      case ResponseSent():
        widget.onSent();
      case ResponseAlreadySent():
        setState(() => _alreadyAnswered = true);
      case ResponseNeedsWords():
        setState(() => _needsWords = true);
      case ResponseFailed(:final reason):
        setState(() => _failure = reason);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DsColors.canvasRitual,
      body: DsRitualSurface(
        child: SafeArea(
          child: SingleChildScrollView(
            child: _alreadyAnswered
                ? _AlreadyAnswered(
                    partnerName: widget.partnerName,
                    onDismiss: widget.onDismiss,
                  )
                : _Composer(
                    partnerName: widget.partnerName,
                    expectationTitle: widget.expectationTitle,
                    completedAt: widget.completedAt,
                    words: _words,
                    type: _type,
                    busy: _busy,
                    needsWords: _needsWords,
                    failure: _failure,
                    onType: (t) => setState(() {
                      _type = t;
                      _needsWords = false;
                    }),
                    onSend: _send,
                    onDismiss: widget.onDismiss,
                  ),
          ),
        ),
      ),
    );
  }
}

class _Composer extends StatelessWidget {
  const _Composer({
    required this.partnerName,
    required this.expectationTitle,
    required this.completedAt,
    required this.words,
    required this.type,
    required this.busy,
    required this.needsWords,
    required this.failure,
    required this.onType,
    required this.onSend,
    required this.onDismiss,
  });

  final String partnerName;
  final String expectationTitle;
  final String completedAt;
  final TextEditingController words;
  final HumanResponse type;
  final bool busy;
  final bool needsWords;
  final ResponseFailureReason? failure;
  final ValueChanged<HumanResponse> onType;
  final VoidCallback onSend;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _WhatHappened(
          partnerName: partnerName,
          expectationTitle: expectationTitle,
          completedAt: completedAt,
        ),
        Container(
          height: DsBorderWidths.hairline,
          color: DsColors.borderOnRitualHairline,
        ),
        Padding(
          padding: const EdgeInsets.all(DsSpacing.space5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l.responseComposerTitle(partnerName),
                style: DsTextStyles.titlePage.copyWith(
                  color: DsColors.textOnRitualPrimary,
                ),
              ),
              const SizedBox(height: DsSpacing.space5),
              Row(
                children: [
                  for (final t in HumanResponse.values)
                    Expanded(
                      child: _TypeChoice(
                        type: t,
                        selected: t == type,
                        onTap: busy ? null : () => onType(t),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: DsSpacing.space6),
              Text(
                l.responseYourWords,
                style: DsTextStyles.labelRitual.copyWith(
                  color: DsColors.textOnRitualMuted,
                  fontSize: 10,
                  letterSpacing: 1.6,
                ),
              ),
              const SizedBox(height: DsSpacing.space3),
              _WordsField(
                controller: words,
                type: type,
                enabled: !busy,
                error: needsWords,
              ),
              if (needsWords) ...[
                const SizedBox(height: DsSpacing.space3),
                Text(
                  l.responseNeedsWords(responseTypeLabel(l, type)),
                  style: DsTextStyles.bodySecondary.copyWith(
                    color: DsColors.stateError,
                    fontSize: 12,
                  ),
                ),
              ],
              if (failure case final failure?) ...[
                const SizedBox(height: DsSpacing.space4),
                Text(
                  switch (failure) {
                    ResponseFailureReason.offline => l.responseErrorOffline,
                    ResponseFailureReason.unknown => l.responseErrorGeneric,
                  },
                  style: DsTextStyles.bodySecondary.copyWith(
                    color: DsColors.stateError,
                  ),
                ),
              ],
              const SizedBox(height: DsSpacing.space8),
              // Never disabled for an empty field. Acknowledge and Praise send
              // without words by design; Comment and Review say what is
              // missing when pressed. A disabled Send would make the two-tap
              // floor look broken.
              DsPrimaryButton(
                label: l.responseSendTo(partnerName),
                busyLabel: l.responseSending,
                busy: busy,
                onPressed: onSend,
              ),
              const SizedBox(height: DsSpacing.space4),
              Center(
                child: TextButton(
                  onPressed: busy ? null : onDismiss,
                  child: Text(
                    // Not "Skip" or "Dismiss": nothing is being declined. The
                    // moment stays open and unanswered, and saying otherwise
                    // would be the app deciding on their behalf.
                    l.responseNotNow,
                    style: DsTextStyles.bodySecondary.copyWith(
                      color: DsColors.textOnRitualSecondary,
                      fontWeight: FontWeight.w500,
                    ),
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

/// What is being answered. Stated plainly, above the response, so nobody sends
/// into a moment they have lost track of.
class _WhatHappened extends StatelessWidget {
  const _WhatHappened({
    required this.partnerName,
    required this.expectationTitle,
    required this.completedAt,
  });

  final String partnerName;
  final String expectationTitle;
  final String completedAt;

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        DsSpacing.space5,
        DsSpacing.space5,
        DsSpacing.space5,
        DsSpacing.space8,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                l.responseAttention,
                style: DsTextStyles.titlePage.copyWith(
                  color: DsColors.textOnRitualPrimary,
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
                  l.responsePartnerPresent(partnerName),
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
          const SizedBox(height: DsSpacing.space6),
          const DsSvg(
            asset: DsAssets.emblemRitualEvening,
            tone: DsAssetTone.muted,
            width: 40,
            height: 40,
          ),
          const SizedBox(height: DsSpacing.space4),
          Text(
            expectationTitle.toUpperCase(),
            style: DsTextStyles.labelRitual.copyWith(
              color: DsColors.textOnRitualMuted,
              fontSize: 10,
              letterSpacing: 1.8,
            ),
          ),
          const SizedBox(height: DsSpacing.space6),
          Text(
            l.responseCompletedAtBy(partnerName, completedAt),
            textAlign: TextAlign.center,
            style: DsTextStyles.displayRitual.copyWith(
              color: DsColors.textOnRitualPrimary,
              fontSize: 26,
              height: 34 / 26,
            ),
          ),
        ],
      ),
    );
  }
}

class _TypeChoice extends StatelessWidget {
  const _TypeChoice({
    required this.type,
    required this.selected,
    required this.onTap,
  });

  final HumanResponse type;
  final bool selected;
  final VoidCallback? onTap;

  static const _assets = {
    HumanResponse.acknowledge: DsAssets.responseAcknowledge,
    HumanResponse.praise: DsAssets.responsePraise,
    HumanResponse.comment: DsAssets.responseComment,
    HumanResponse.review: DsAssets.responseReview,
  };

  @override
  Widget build(BuildContext context) {
    return Semantics(
      selected: selected,
      button: true,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: DsSpacing.space2),
          child: Column(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: selected
                        ? DsPrimitiveColors.terracotta
                        : DsColors.borderOnRitualHairline,
                    width: selected ? 1.3 : 1,
                  ),
                ),
                child: Center(
                  child: DsSvg(
                    asset: _assets[type]!,
                    tone: selected
                        ? DsAssetTone.relationship
                        : DsAssetTone.muted,
                    width: 20,
                    height: 20,
                  ),
                ),
              ),
              const SizedBox(height: DsSpacing.space3),
              Text(
                responseTypeLabel(L.of(context), type),
                textAlign: TextAlign.center,
                style: DsTextStyles.bodySecondary.copyWith(
                  fontSize: 11,
                  color: selected
                      ? DsPrimitiveColors.terracotta
                      : DsColors.textOnRitualMuted,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
              if (selected)
                Container(
                  margin: const EdgeInsets.only(top: DsSpacing.space2),
                  width: 28,
                  height: DsBorderWidths.hairline,
                  color: DsPrimitiveColors.terracotta,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Where a person writes, and nothing writes for them.
class _WordsField extends StatelessWidget {
  const _WordsField({
    required this.controller,
    required this.type,
    required this.enabled,
    required this.error,
  });

  final TextEditingController controller;
  final HumanResponse type;
  final bool enabled;
  final bool error;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: DsColors.surfaceRitualRaised,
        borderRadius: BorderRadius.circular(DsRadii.medium),
        border: Border.all(
          color: error
              ? DsColors.stateError
              : DsColors.borderOnRitualHairline,
          width: DsBorderWidths.hairline,
        ),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: DsSpacing.space4,
        vertical: DsSpacing.space3,
      ),
      child: TextField(
        controller: controller,
        enabled: enabled,
        minLines: 2,
        maxLines: 5,
        style: DsTextStyles.bodyPrimary.copyWith(
          color: DsColors.textOnRitualPrimary,
        ),
        decoration: InputDecoration(
          border: InputBorder.none,
          isDense: true,
          contentPadding: EdgeInsets.zero,
          // A prompt, not a draft. It disappears the moment anyone types, and
          // it is never sent — an empty field sends nothing but the type.
          hintText: type.wordsRequired
              ? L.of(context).responseWordsHint
              : null,
          hintStyle: DsTextStyles.bodyPrimary.copyWith(
            color: DsColors.textOnRitualMuted,
          ),
        ),
      ),
    );
  }
}

/// Someone already answered — this person on another device, or a retry whose
/// first attempt landed. Not a failure, and never framed as one.
class _AlreadyAnswered extends StatelessWidget {
  const _AlreadyAnswered({
    required this.partnerName,
    required this.onDismiss,
  });

  final String partnerName;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    return Padding(
      padding: const EdgeInsets.all(DsSpacing.space5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: DsSpacing.space10),
          const Center(
            child: DsSvg(
              asset: DsAssets.stateAcknowledged,
              tone: DsAssetTone.relationship,
              width: 32,
              height: 32,
            ),
          ),
          const SizedBox(height: DsSpacing.space8),
          Text(
            l.responseAlreadyAnsweredTitle,
            textAlign: TextAlign.center,
            style: DsTextStyles.displayRitual.copyWith(
              color: DsColors.textOnRitualPrimary,
            ),
          ),
          const SizedBox(height: DsSpacing.space6),
          Text(
            l.responseAlreadyAnsweredDetail(partnerName),
            textAlign: TextAlign.center,
            style: DsTextStyles.bodySecondary.copyWith(
              color: DsColors.textOnRitualSecondary,
            ),
          ),
          const SizedBox(height: DsSpacing.space10),
          DsPrimaryButton(label: l.responseClose, onPressed: onDismiss),
        ],
      ),
    );
  }
}
