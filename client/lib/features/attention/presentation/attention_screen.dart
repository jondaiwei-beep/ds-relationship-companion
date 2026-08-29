import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../design_system/components/ds_app_bar.dart';
import '../../../design_system/components/ds_button.dart';
import '../../../design_system/components/ds_page.dart';
import '../../../design_system/components/ds_text.dart';
import '../../../design_system/tokens/colors.dart';
import '../../../design_system/tokens/spacing.dart';
import '../../../design_system/tokens/typography.dart';
import '../../../domain_client/api_client.dart';
import '../../../domain_client/models/attention_view.dart';

final attentionProvider = FutureProvider.autoDispose
    .family<AttentionView, String>((ref, dynamicId) async {
  return ref.watch(attentionRepositoryProvider).forDynamic(dynamicId);
});

/// The three bands of work, in the order a relationship needs them.
///
/// Priority is made *spatial* rather than left hidden inside the server's
/// sort order: a request to change course is handled before routine praise,
/// because it is the one that actually needs the person.
enum _Band { talkAbout, waitingForWords, needsReview }

_Band _bandOf(String state) => switch (state) {
      'NEED_TO_DISCUSS' ||
      'RESCHEDULE_REQUESTED' ||
      'EXCUSE_REQUESTED' =>
        _Band.talkAbout,
      'WAITING_ACK' => _Band.waitingForWords,
      _ => _Band.needsReview,
    };

String _bandLabel(_Band b) => switch (b) {
      _Band.talkAbout => 'Talk about',
      _Band.waitingForWords => 'Waiting for your words',
      // Backend state names never reach the user (Notion 05 §12).
      _Band.needsReview => 'Needs review',
    };

/// Attention — Journey C.
///
/// Answers the direction-giving side's only question: what actually needs my
/// response right now.
///
/// This is a list of rows with an inline composer, not a stack of cards.
/// Cards made every pending item visually expensive and forced a detour
/// through a detail page to say one sentence — which is how keeping a
/// rhythm turns into admin work, and how people stop.
///
/// Settled items never appear: this is an inbox of human responsibility,
/// not a history.
class AttentionScreen extends ConsumerStatefulWidget {
  const AttentionScreen({
    super.key,
    required this.dynamicId,
    this.onOpen,
    this.onBack,
  });

  final String dynamicId;
  final void Function(String occurrenceId)? onOpen;

  /// Reached from Today, so it needs a way back — the Android system button
  /// does not exist on iOS Safari or the web build.
  final VoidCallback? onBack;

  @override
  ConsumerState<AttentionScreen> createState() => _AttentionScreenState();
}

class _AttentionScreenState extends ConsumerState<AttentionScreen> {
  /// Only one composer is open at a time: two half-written messages to two
  /// different people is a way to send the wrong one.
  String? _openId;

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(attentionProvider(widget.dynamicId));

    return Scaffold(
      backgroundColor: DsColors.canvas,
      appBar: DsAppBar(title: 'Needs you', onBack: widget.onBack),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => DsPage(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: DsSpacing.xxxl),
              Text("We couldn't load this right now.", style: DsType.h2),
              const SizedBox(height: DsSpacing.lg),
              Text(
                'Nothing was lost. Your partner sees the same thing you do.',
                style: DsType.body.copyWith(color: DsColors.muted),
              ),
            ],
          ),
        ),
        data: (a) => DsPage(child: _body(a)),
      ),
    );
  }

  Widget _body(AttentionView a) {
    if (a.items.isEmpty) {
      // An empty Attention is a GOOD state, not a void to fill. Saying so
      // protects the promise that this screen only ever holds real work.
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: DsSpacing.xxxl),
          Text('Nothing needs you\nright now.', style: DsType.h1),
          const SizedBox(height: DsSpacing.lg),
          Text(
            "You're up to date. We'll bring things here when they need "
            'your response.',
            style: DsType.body.copyWith(color: DsColors.muted),
          ),
        ],
      );
    }

    // Server order stays authoritative within each band; the bands only make
    // that order visible.
    final bands = <_Band, List<AttentionItem>>{};
    for (final item in a.items) {
      bands.putIfAbsent(_bandOf(item.state), () => []).add(item);
    }

    final n = a.items.length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: DsSpacing.md),
        // A quiet line, not a headline: the app bar already says why you are
        // here, and a large count reads like a score to clear.
        Text(
          n == 1
              ? '1 moment needs a response · usually under a minute'
              : '$n moments need a response · usually under a minute',
          style: DsType.fine.copyWith(color: DsColors.muted),
        ),
        const SizedBox(height: DsSpacing.xl),

        for (final band in _Band.values)
          if (bands[band] != null) ...[
            const SizedBox(height: DsSpacing.md),
            DsEyebrow(_bandLabel(band)),
            const SizedBox(height: DsSpacing.sm),
            for (final item in bands[band]!)
              _Row(
                item: item,
                band: band,
                expanded: _openId == item.occurrenceId,
                onToggle: () => setState(() {
                  _openId =
                      _openId == item.occurrenceId ? null : item.occurrenceId;
                }),
                onOpen: widget.onOpen,
                onSent: () {
                  setState(() => _openId = null);
                  ref.invalidate(attentionProvider(widget.dynamicId));
                },
              ),
          ],
        const SizedBox(height: DsSpacing.xxl),
      ],
    );
  }
}

class _Row extends ConsumerWidget {
  const _Row({
    required this.item,
    required this.band,
    required this.expanded,
    required this.onToggle,
    required this.onSent,
    this.onOpen,
  });

  final AttentionItem item;
  final _Band band;
  final bool expanded;
  final VoidCallback onToggle;
  final VoidCallback onSent;
  final void Function(String occurrenceId)? onOpen;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Only a waiting item is answered with words. A request to change course
    // is a conversation, and pushing it through an acknowledgement composer
    // would answer the wrong question.
    final inlineAnswerable = band == _Band.waitingForWords;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: const BoxDecoration(
            border: Border(top: BorderSide(color: DsColors.line)),
          ),
          padding: const EdgeInsets.symmetric(vertical: DsSpacing.lg),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: onOpen == null
                      ? null
                      : () => onOpen!(item.occurrenceId),
                  behavior: HitTestBehavior.opaque,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_who(item), style: DsType.fine.copyWith(
                          color: DsColors.muted)),
                      const SizedBox(height: DsSpacing.xs),
                      Text(item.title, style: DsType.cardTitle),
                      if (item.occurredAt != null) ...[
                        const SizedBox(height: DsSpacing.xs),
                        Text(_time(item.occurredAt!),
                            style: DsType.fine.copyWith(
                                color: DsColors.muted)),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(width: DsSpacing.md),
              // Olive text over a short terracotta rule, not a filled button:
              // the accent stays scarce and the row stays cheap to scan.
              _Action(
                label: inlineAnswerable
                    ? (expanded ? 'Close' : 'Respond')
                    : 'Open',
                onTap: inlineAnswerable
                    ? onToggle
                    : (onOpen == null
                        ? null
                        : () => onOpen!(item.occurrenceId)),
              ),
            ],
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOut,
          alignment: Alignment.topCenter,
          child: expanded
              ? _InlineComposer(
                  occurrenceId: item.occurrenceId,
                  partnerName: item.actorDisplayName,
                  onSent: onSent,
                  onDiscuss: onOpen == null
                      ? null
                      : () => onOpen!(item.occurrenceId),
                )
              : const SizedBox(width: double.infinity),
        ),
      ],
    );
  }

  String _who(AttentionItem item) {
    final who = item.actorDisplayName ?? 'Someone';
    return switch (item.state) {
      'WAITING_ACK' => '$who completed',
      'NEED_TO_DISCUSS' => '$who wants to talk about this',
      'RESCHEDULE_REQUESTED' => '$who asked for a new time',
      'EXCUSE_REQUESTED' => "$who can't do this right now",
      _ => 'Needs review',
    };
  }

  String _time(DateTime t) {
    final h = t.hour % 12 == 0 ? 12 : t.hour % 12;
    final mm = t.minute.toString().padLeft(2, '0');
    return '$h:$mm ${t.hour < 12 ? 'AM' : 'PM'}';
  }
}

class _Action extends StatelessWidget {
  const _Action({required this.label, required this.onTap});

  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      // 48dp minimum target even though the mark itself is small.
      child: SizedBox(
        height: 48,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              label,
              style: DsType.fine.copyWith(
                color: DsColors.response,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 3),
            Container(width: 22, height: 2, color: DsColors.accent),
          ],
        ),
      ),
    );
  }
}

/// Answering without leaving the list.
///
/// The ethical guard lives here rather than being duplicated: the field
/// starts empty, a suggestion only fills it, and Send stays disabled until
/// the person has written something that is not the untouched suggestion.
/// Sending words nobody wrote would put a sentence in a partner's mouth.
class _InlineComposer extends ConsumerStatefulWidget {
  const _InlineComposer({
    required this.occurrenceId,
    required this.onSent,
    this.partnerName,
    this.onDiscuss,
  });

  final String occurrenceId;
  final VoidCallback onSent;
  final String? partnerName;
  final VoidCallback? onDiscuss;

  @override
  ConsumerState<_InlineComposer> createState() => _InlineComposerState();
}

class _InlineComposerState extends ConsumerState<_InlineComposer> {
  final _controller = TextEditingController();
  String? _untouchedSuggestion;
  var _showSuggestions = false;
  var _busy = false;
  String? _error;
  late String _key = ApiClient.newIdempotencyKey();

  static const _suggestions = <String>[
    'I noticed the care you put into this.',
    'Thank you. That mattered.',
    'I saw it. Well done.',
  ];

  @override
  void initState() {
    super.initState();
    _controller.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _canSend {
    final text = _controller.text.trim();
    if (text.isEmpty) return false;
    // Filling the field is not authorship.
    return text != _untouchedSuggestion;
  }

  Future<void> _send() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref.read(occurrenceRepositoryProvider).acknowledge(
            widget.occurrenceId,
            type: 'ACKNOWLEDGE',
            text: _controller.text.trim(),
            idempotencyKey: _key,
          );
      widget.onSent();
    } catch (_) {
      if (mounted) {
        setState(() {
          _error = "That didn't send. Please try again.";
          _key = ApiClient.newIdempotencyKey();
        });
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: DsSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // The human surface is the largest thing here. Automation is a
          // single collapsed line beneath it.
          Container(
            decoration: BoxDecoration(
              color: DsColors.surface,
              border: Border.all(color: DsColors.line),
              borderRadius: BorderRadius.circular(DsSpacing.cardRadius),
            ),
            padding: const EdgeInsets.symmetric(
                horizontal: DsSpacing.lg, vertical: DsSpacing.sm),
            child: TextField(
              controller: _controller,
              autofocus: true,
              enabled: !_busy,
              minLines: 3,
              maxLines: 5,
              style: DsType.cardTitle.copyWith(fontSize: 16, height: 1.4),
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: widget.partnerName == null
                    ? 'Say something back'
                    : 'Say something back to ${widget.partnerName}',
                hintStyle: DsType.body.copyWith(color: DsColors.muted),
              ),
            ),
          ),

          const SizedBox(height: DsSpacing.sm),
          if (!_showSuggestions)
            GestureDetector(
              onTap: () => setState(() => _showSuggestions = true),
              behavior: HitTestBehavior.opaque,
              child: SizedBox(
                height: 32,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Need a starting point?',
                      style: DsType.fine.copyWith(color: DsColors.muted)),
                ),
              ),
            )
          else ...[
            Text('Wording suggestion — your partner should still hear from you',
                style: DsType.fine.copyWith(color: DsColors.muted)),
            const SizedBox(height: DsSpacing.sm),
            Wrap(
              spacing: DsSpacing.sm,
              runSpacing: DsSpacing.sm,
              children: [
                for (final s in _suggestions)
                  ActionChip(
                    label: Text(s, style: DsType.fine),
                    backgroundColor: DsColors.surface,
                    side: const BorderSide(color: DsColors.line),
                    onPressed: () {
                      setState(() {
                        _controller.text = s;
                        _untouchedSuggestion = s;
                      });
                      _controller.selection =
                          TextSelection.collapsed(offset: s.length);
                    },
                  ),
              ],
            ),
          ],

          if (_error != null) ...[
            const SizedBox(height: DsSpacing.sm),
            Text(_error!,
                style: DsType.fine.copyWith(color: DsColors.critical)),
          ],

          const SizedBox(height: DsSpacing.lg),
          Row(
            children: [
              Expanded(
                child: DsButton(
                  label: _busy ? 'Sending...' : 'Send',
                  onPressed: (_busy || !_canSend) ? null : _send,
                ),
              ),
              if (widget.onDiscuss != null) ...[
                const SizedBox(width: DsSpacing.md),
                Expanded(
                  child: DsButton(
                    label: 'Discuss instead',
                    outline: true,
                    onPressed: _busy ? null : widget.onDiscuss,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
