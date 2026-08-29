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
import '../../dynamic/presentation/dynamic_screen.dart';

/// Ask something of the other person.
///
/// This is the direction-giving half of `Expectation → Action → Human
/// Response`, and until now it could not be started from the app at all.
///
/// Two fields and an optional time. The purpose line exists because an
/// expectation that only says *what* reads as a chore; saying *why* is what
/// makes it come from a person. It is optional — requiring it would turn
/// asking into paperwork.
class NewExpectationScreen extends ConsumerStatefulWidget {
  const NewExpectationScreen({
    super.key,
    required this.dynamicId,
    this.onCreated,
    this.onBack,
  });

  final String dynamicId;
  final VoidCallback? onCreated;
  final VoidCallback? onBack;

  @override
  ConsumerState<NewExpectationScreen> createState() => _NewExpectationState();
}

class _NewExpectationState extends ConsumerState<NewExpectationScreen> {
  final _title = TextEditingController();
  final _purpose = TextEditingController();
  TimeOfDay? _due;
  var _busy = false;
  String? _error;
  late String _key = UniqueKey().toString();

  @override
  void initState() {
    super.initState();
    // Send stays disabled until a human has actually written something.
    _title.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _title.dispose();
    _purpose.dispose();
    super.dispose();
  }

  Future<void> _submit(String assigneeUserId) async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      DateTime? due;
      if (_due != null) {
        final now = DateTime.now();
        due = DateTime(now.year, now.month, now.day, _due!.hour, _due!.minute);
        // A time already past means tonight is gone; they mean tomorrow.
        if (due.isBefore(now)) due = due.add(const Duration(days: 1));
      }
      await ref.read(expectationRepositoryProvider).create(
            widget.dynamicId,
            title: _title.text.trim(),
            purpose: _purpose.text.trim().isEmpty ? null : _purpose.text.trim(),
            assigneeUserId: assigneeUserId,
            dueAt: due,
            idempotencyKey: _key,
          );
      if (mounted) widget.onCreated?.call();
    } catch (_) {
      if (mounted) {
        setState(() {
          _error = "That didn't send. Please try again.";
          _key = UniqueKey().toString();
        });
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final detail = ref.watch(dynamicDetailProvider(widget.dynamicId)).value;
    final me = detail?.members;
    // The other active member. Addressed to a person, never to a role.
    final partner = me == null || me.length < 2 ? null : me.last;

    return Scaffold(
      backgroundColor: DsColors.canvas,
      appBar: DsAppBar(title: 'Ask', onBack: widget.onBack),
      body: DsPage(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: DsSpacing.sm),
            Text(
              partner?.displayName == null
                  ? 'Ask for something'
                  : 'Ask ${partner!.displayName} for something',
              style: DsType.h1,
            ),
            const SizedBox(height: DsSpacing.lg),
            Text(
              'Small is better than impressive. They can always ask to '
              'discuss it or move it.',
              style: DsType.body.copyWith(color: DsColors.muted),
            ),

            const SizedBox(height: DsSpacing.xxl),
            const DsEyebrow('What'),
            const SizedBox(height: DsSpacing.sm),
            TextField(
              controller: _title,
              enabled: !_busy,
              style: DsType.body,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                hintText: 'Prepare the evening space',
                hintStyle: DsType.body.copyWith(color: DsColors.muted),
                enabledBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: DsColors.line),
                ),
              ),
            ),

            const SizedBox(height: DsSpacing.xl),
            const DsEyebrow('Why it matters (optional)'),
            const SizedBox(height: DsSpacing.sm),
            TextField(
              controller: _purpose,
              enabled: !_busy,
              maxLines: 2,
              style: DsType.body,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                hintText: 'Optional',
                hintStyle: DsType.body.copyWith(color: DsColors.muted),
                enabledBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: DsColors.line),
                ),
              ),
            ),

            const SizedBox(height: DsSpacing.xl),
            const DsEyebrow('By when (optional)'),
            const SizedBox(height: DsSpacing.sm),
            Row(
              children: [
                Expanded(
                  child: Text(
                    _due == null
                        ? 'No particular time'
                        : '${_due!.hour.toString().padLeft(2, '0')}:'
                            '${_due!.minute.toString().padLeft(2, '0')}',
                    style: DsType.body.copyWith(
                      color: _due == null ? DsColors.muted : DsColors.ink,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: _busy
                      ? null
                      : () async {
                          final t = await showTimePicker(
                            context: context,
                            initialTime: const TimeOfDay(hour: 20, minute: 30),
                          );
                          if (t != null) setState(() => _due = t);
                        },
                  child: Text(
                    _due == null ? 'Choose a time' : 'Change',
                    style: DsType.fine.copyWith(
                      color: DsColors.response,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (_due != null)
                  TextButton(
                    onPressed: _busy ? null : () => setState(() => _due = null),
                    child: Text('Clear',
                        style: DsType.fine.copyWith(color: DsColors.muted)),
                  ),
              ],
            ),

            if (_error != null) ...[
              const SizedBox(height: DsSpacing.lg),
              Text(_error!,
                  style: DsType.fine.copyWith(color: DsColors.critical)),
            ],

            const SizedBox(height: DsSpacing.xxl),
            DsButton(
              label: _busy ? 'Sending…' : 'Ask',
              onPressed: (_busy ||
                      _title.text.trim().isEmpty ||
                      partner == null)
                  ? null
                  : () => _submit(partner.userId),
            ),
            const SizedBox(height: DsSpacing.lg),
            Text(
              // Says plainly that this is a request, not an order the system
              // will enforce. Red line #3.
              'Nothing here is enforced. If it does not work for them, '
              'they can say so.',
              style: DsType.fine.copyWith(color: DsColors.muted),
            ),
            const SizedBox(height: DsSpacing.xxl),
          ],
        ),
      ),
    );
  }
}
