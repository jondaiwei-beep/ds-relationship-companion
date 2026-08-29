import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../design_system/components/ds_button.dart';
import '../../../design_system/components/ds_page.dart';
import '../../../design_system/components/ds_text.dart';
import '../../../design_system/tokens/colors.dart';
import '../../../design_system/tokens/spacing.dart';
import '../../../design_system/tokens/typography.dart';

/// The Creator's way to bring the other person in — Journey A4.
///
/// Without this the product is unreachable for a Creator: they cannot be
/// handed an invite link, because they are the one who makes it.
///
/// The link is shown and copied rather than sent by us. Who this person is,
/// and through which channel it is safe to reach them, is theirs to decide —
/// the app never learns a partner's address.
class ShareInviteScreen extends ConsumerStatefulWidget {
  const ShareInviteScreen({
    super.key,
    required this.dynamicId,
    this.onDone,
    this.onBack,
  });

  final String dynamicId;
  final VoidCallback? onDone;
  final VoidCallback? onBack;

  @override
  ConsumerState<ShareInviteScreen> createState() => _ShareInviteState();
}

class _ShareInviteState extends ConsumerState<ShareInviteScreen> {
  String? _link;
  var _busy = false;
  var _copied = false;
  String? _error;
  late String _key = UniqueKey().toString();

  @override
  void initState() {
    super.initState();
    _make();
  }

  Future<void> _make() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final token = await ref
          .read(inviteRepositoryProvider)
          .create(widget.dynamicId, idempotencyKey: _key);
      if (mounted) {
        setState(() => _link = '${webBaseUrl()}/invite/$token');
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _error = "We couldn't make a link just now.";
          _key = UniqueKey().toString();
        });
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DsColors.canvas,
      body: DsPage(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: DsSpacing.sm),
            const DsAccentRule(),
            const SizedBox(height: DsSpacing.sm),
            Text('Invite them', style: DsType.h1),
            const SizedBox(height: DsSpacing.lg),
            Text(
              'Send this link however you already talk. '
              'They open it in a browser — nothing to install.',
              style: DsType.body.copyWith(color: DsColors.muted),
            ),

            const SizedBox(height: DsSpacing.xxl),
            if (_link != null) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(15, 14, 15, 14),
                decoration: BoxDecoration(
                  color: DsColors.stone,
                  borderRadius: BorderRadius.circular(DsSpacing.cardRadius),
                ),
                child: SelectableText(
                  _link!,
                  style: DsType.fine.copyWith(color: DsColors.ink),
                ),
              ),
              const SizedBox(height: DsSpacing.xl),
              DsButton(
                label: _copied ? 'Copied' : 'Copy link',
                onPressed: () async {
                  await Clipboard.setData(ClipboardData(text: _link!));
                  if (mounted) setState(() => _copied = true);
                },
              ),
              const SizedBox(height: DsSpacing.lg),
              Text(
                // Says what the link is worth, so nobody treats it casually.
                'The link works once and expires in a week. '
                'Only send it to the person it is for.',
                style: DsType.fine.copyWith(color: DsColors.muted),
              ),
            ] else if (_error != null) ...[
              Text(_error!,
                  style: DsType.fine.copyWith(color: DsColors.critical)),
              const SizedBox(height: DsSpacing.xl),
              DsButton(label: 'Try again', outline: true, onPressed: _make),
            ] else
              Text(_busy ? 'Making a link…' : '',
                  style: DsType.body.copyWith(color: DsColors.muted)),

            const SizedBox(height: DsSpacing.xxl),
            if (widget.onDone != null)
              DsButton(
                // Not "skip": nothing is lost by inviting later, and saying
                // so keeps the moment from feeling like a checkpoint.
                label: 'Later',
                outline: true,
                onPressed: widget.onDone,
              ),
            const SizedBox(height: DsSpacing.xxl),
          ],
        ),
      ),
    );
  }
}
