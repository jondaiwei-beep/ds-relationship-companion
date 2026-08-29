import 'package:flutter/material.dart';
import '../../../design_system/components/ds_button.dart';
import '../../../design_system/components/ds_card.dart';
import '../../../design_system/components/ds_page.dart';
import '../../../design_system/components/ds_text.dart';
import '../../../design_system/tokens/colors.dart';
import '../../../design_system/tokens/spacing.dart';
import '../../../design_system/tokens/typography.dart';
import '../../../domain_client/models/occurrence_view.dart';

/// Respond — Warm Authority V5 screen 5.
///
/// PRODUCT RED LINE #1: "Automation prepares; the partner responds."
///
/// The app may offer suggested wording, but it is offered as a STARTING POINT,
/// visibly labelled as a suggestion, and fully editable. Nothing is sent
/// without the person pressing send. Sending an unedited suggestion is the
/// human's choice — silently sending one on their behalf would not be.
class RespondScreen extends StatefulWidget {
  const RespondScreen({
    super.key,
    required this.occurrence,
    this.partnerName,
    this.onSend,
    this.onDiscuss,
  });

  final OccurrenceView occurrence;
  /// Null until the server has told us who they are. Addressing a person by
  /// name is what keeps this from reading as a workflow step.
  final String? partnerName;

  String get _them => partnerName ?? 'your partner';
  final void Function(String type, String text)? onSend;
  final VoidCallback? onDiscuss;

  @override
  State<RespondScreen> createState() => _RespondScreenState();
}

class _RespondScreenState extends State<RespondScreen> {
  late final TextEditingController _controller;
  /// A neutral container type for the server. Deliberately NOT a choice.
  ///
  /// Asking someone to file their own words as Acknowledge / Praise /
  /// Comment is administrative work, and "Praise" in particular makes
  /// intimacy feel like selecting a system mode. The person writes what
  /// they mean; the system does not ask them to classify it.
  static const _type = 'ACKNOWLEDGE';
  var _showSuggestions = false;

  /// Offered, never auto-sent. Kept short and specific so it reads as a prompt
  /// rather than a finished sentiment.
  static const _suggestions = <String>[
    'I noticed the care you put into this.',
    'Thank you — this mattered to me.',
    'Well done. I saw it.',
  ];

  @override
  void initState() {
    super.initState();
    // Deliberately EMPTY. Pre-filling would make the default action "send words
    // the system wrote", which is exactly what red line #1 forbids.
    _controller = TextEditingController();
    _controller.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// The suggestion currently sitting untouched in the field, if any.
  ///
  /// Tapping a suggestion fills the field so it can be edited. It must not,
  /// by itself, make the message sendable: sending a suggestion nobody
  /// touched would put words in a partner's mouth that no person wrote —
  /// which is exactly what "automation prepares; the partner responds"
  /// forbids (red line #1).
  String? _untouchedSuggestion;

  bool get _canSend {
    final text = _controller.text.trim();
    if (text.isEmpty) return false;
    return text != _untouchedSuggestion;
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: DsColors.canvas,
      child: DsPage(
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DsEyebrow('${widget._them} completed', terra: true),
              const SizedBox(height: DsSpacing.sm),
              Text(widget.occurrence.title, style: DsType.h2),
              const SizedBox(height: DsSpacing.xl),
              const Divider(color: DsColors.line, height: 1),
              const SizedBox(height: DsSpacing.xl),

              const DsEyebrow('Your response'),
              const SizedBox(height: DsSpacing.sm),
              DsCard(
                // Explicit height: inside a scroll view a multi-line TextField
                // has no natural bound and will grow without limit.
                child: SizedBox(
                  height: 152,
                  child: TextField(
                    controller: _controller,
                    maxLines: null,
                    expands: true,
                    textAlignVertical: TextAlignVertical.top,
                    style: DsType.cardTitle,
                    decoration: InputDecoration.collapsed(
                      hintText: 'Say something in your own words…',
                      hintStyle: DsType.cardTitle.copyWith(color: DsColors.muted),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: DsSpacing.lg),
              // Automation is opt-in and collapsed. Rendered open, the
              // suggestion panel was physically larger than the writing
              // surface — the system taking up more room than the person is
              // the visual form of the thing red line #1 forbids.
              if (!_showSuggestions)
                GestureDetector(
                  onTap: () => setState(() => _showSuggestions = true),
                  behavior: HitTestBehavior.opaque,
                  child: SizedBox(
                    height: 36,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text('Need a starting point?',
                          style: DsType.fine.copyWith(color: DsColors.muted)),
                    ),
                  ),
                )
              else ...[
                // Still explicitly labelled — the single most important
                // detail on this screen.
                Text(
                  'Wording suggestion',
                  style: DsType.fine.copyWith(
                    color: DsColors.inkSoft,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: DsSpacing.xs),
                Text(
                  'Use it as a starting point — your partner should still '
                  'hear from you.',
                  style: DsType.fine.copyWith(color: DsColors.muted),
                ),
                const SizedBox(height: DsSpacing.md),
                Wrap(
                  spacing: DsSpacing.sm,
                  runSpacing: DsSpacing.sm,
                  children: [
                    for (final sug in _suggestions)
                      ActionChip(
                        label: Text(sug, style: DsType.fine),
                        backgroundColor: DsColors.surface,
                        side: const BorderSide(color: DsColors.line),
                        onPressed: () {
                          setState(() {
                            _controller.text = sug;
                            _untouchedSuggestion = sug;
                          });
                          _controller.selection =
                              TextSelection.collapsed(offset: sug.length);
                        },
                      ),
                  ],
                ),
              ],

              const SizedBox(height: DsSpacing.xxl),
              DsButton(
                // Names the person. "Send acknowledgement" is the system's
                // word for it, not something one partner says to another.
                label: 'Send to ${widget._them}',
                // Disabled until the human has actually written something.
                onPressed: _canSend
                    ? () => widget.onSend?.call(_type, _controller.text.trim())
                    : null,
              ),
              const SizedBox(height: DsSpacing.md),
              Center(
                child: TextButton(
                  onPressed: widget.onDiscuss,
                  child: Text(
                    'Discuss instead',
                    style: DsType.fine.copyWith(
                      color: DsColors.response, fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
        ),
      ),
    );
  }

}
