import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../design_system/components/ds_app_bar.dart';
import '../../../design_system/components/ds_button.dart';
import '../../../design_system/components/ds_card.dart';
import '../../../design_system/components/ds_page.dart';
import '../../../design_system/components/ds_text.dart';
import '../../../design_system/tokens/colors.dart';
import '../../../design_system/tokens/spacing.dart';
import '../../../design_system/tokens/typography.dart';
import '../../../domain_client/models/notification_settings.dart';

final notificationSettingsProvider =
    FutureProvider.autoDispose<NotificationSettings>((ref) async {
  return ref.watch(settingsRepositoryProvider).notifications();
});

/// Quiet hours and lockscreen privacy — Notion 04 §5.
///
/// These are the member's own, not the dynamic's. Nothing here is visible to
/// a partner and nothing here can be set by one: a role that could reach into
/// when you are reachable, or into what shows on your lockscreen, would be a
/// role that owns your phone.
class QuietHoursScreen extends ConsumerStatefulWidget {
  const QuietHoursScreen({super.key, this.onDone});

  final VoidCallback? onDone;

  @override
  ConsumerState<QuietHoursScreen> createState() => _QuietHoursScreenState();
}

class _QuietHoursScreenState extends ConsumerState<QuietHoursScreen> {
  bool? _on;
  TimeOfDay? _start;
  TimeOfDay? _end;
  String? _preview;
  var _seeded = false;

  // Offered when quiet hours have never been set. Not a recommendation —
  // just a sane place to start editing from.
  static const _defaultStart = TimeOfDay(hour: 22, minute: 0);
  static const _defaultEnd = TimeOfDay(hour: 7, minute: 0);

  /// Seed the editable fields from what is actually saved, once.
  ///
  /// Without this the screen shows its own defaults over a saved window, and
  /// saving would silently overwrite whatever the member had chosen.
  void _seed(NotificationSettings s) {
    if (_seeded) return;
    _seeded = true;
    final start = s.quietHoursStartMin;
    final end = s.quietHoursEndMin;
    _start = start == null
        ? _defaultStart
        : TimeOfDay(hour: start ~/ 60, minute: start % 60);
    _end = end == null
        ? _defaultEnd
        : TimeOfDay(hour: end ~/ 60, minute: end % 60);
  }
  var _busy = false;
  String? _error;

  int _min(TimeOfDay t) => t.hour * 60 + t.minute;

  Future<void> _pick(bool isStart) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: (isStart ? _start : _end) ?? _defaultStart,
    );
    if (picked == null) return;
    setState(() {
      if (isStart) {
        _start = picked;
      } else {
        _end = picked;
      }
    });
  }

  Future<void> _signOut() async {
    setState(() => _busy = true);
    try {
      await ref.read(authRepositoryProvider).logout();
    } catch (_) {
      // Even if the server call fails, the local session must end: a person
      // handing back a phone cannot be left signed in by a network error.
    } finally {
      ref.read(authSessionProvider.notifier).signedOut();
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _save(NotificationSettings current) async {
    final on = _on ?? current.quietHoursOn;
    final start = _start ?? _defaultStart;
    final end = _end ?? _defaultEnd;
    if (on && _min(start) == _min(end)) {
      // Ambiguous: it reads as both "never quiet" and "always quiet".
      setState(() => _error =
          'Choose a start and end that differ, so the window is unambiguous.');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref.read(settingsRepositoryProvider).update(
            notificationPreview: _preview ?? current.notificationPreview,
            quietHoursStartMin: on ? _min(start) : null,
            quietHoursEndMin: on ? _min(end) : null,
          );
      ref.invalidate(notificationSettingsProvider);
      if (mounted) widget.onDone?.call();
    } catch (_) {
      if (mounted) {
        setState(() => _error = "That didn't save. Please try again.");
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DsColors.canvas,
      appBar: DsAppBar(title: 'Notifications', onBack: widget.onDone),
      body: ref.watch(notificationSettingsProvider).when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, _) => DsPage(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: DsSpacing.xxxl),
                  Text("We couldn't load your settings.", style: DsType.h2),
                  const SizedBox(height: DsSpacing.lg),
                  Text('Nothing was changed.',
                      style: DsType.body.copyWith(color: DsColors.muted)),
                ],
              ),
            ),
            data: (s) => DsPage(child: _body(s)),
          ),
    );
  }

  Widget _body(NotificationSettings s) {
    _seed(s);
    final on = _on ?? s.quietHoursOn;
    final preview = _preview ?? s.notificationPreview;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: DsSpacing.sm),
          Text(
            'Only you can see or change this.',
            style: DsType.body.copyWith(color: DsColors.muted),
          ),
          const SizedBox(height: DsSpacing.xxl),

          const DsEyebrow('Quiet hours'),
          const SizedBox(height: DsSpacing.md),
          DsCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text('Hold notifications overnight',
                          style: DsType.cardTitle),
                    ),
                    Switch(
                      value: on,
                      activeThumbColor: DsColors.response,
                      onChanged: (v) => setState(() => _on = v),
                    ),
                  ],
                ),
                const SizedBox(height: DsSpacing.sm),
                Text(
                  // Nothing is lost — the distinction matters, because a
                  // person must not fear that going quiet costs them a
                  // partner's response.
                  'Anything that arrives while you are quiet waits for you. '
                  'Nothing is dropped.',
                  style: DsType.fine.copyWith(color: DsColors.muted),
                ),
                if (on) ...[
                  const SizedBox(height: DsSpacing.xl),
                  Row(
                    children: [
                      Expanded(
                        child: _TimeField(
                          label: 'From',
                          value: _start ?? _defaultStart,
                          onTap: () => _pick(true),
                        ),
                      ),
                      const SizedBox(width: DsSpacing.lg),
                      Expanded(
                        child: _TimeField(
                          label: 'Until',
                          value: _end ?? _defaultEnd,
                          onTap: () => _pick(false),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: DsSpacing.md),
                  Text(
                    'In your own timezone (${s.timezone}).',
                    style: DsType.fine.copyWith(color: DsColors.muted),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: DsSpacing.xxl),
          const DsEyebrow('On your lockscreen'),
          const SizedBox(height: DsSpacing.md),
          _PreviewChoice(
            title: 'Keep it neutral',
            body: 'Notifications say only that something is waiting.',
            selected: preview == 'NEUTRAL',
            onTap: () => setState(() => _preview = 'NEUTRAL'),
          ),
          const SizedBox(height: DsSpacing.md),
          _PreviewChoice(
            title: 'Show more',
            body: 'Names and titles can appear on your lockscreen.',
            selected: preview == 'RICH',
            onTap: () => setState(() => _preview = 'RICH'),
          ),

          if (_error != null) ...[
            const SizedBox(height: DsSpacing.xl),
            Text(_error!,
                style: DsType.fine.copyWith(color: DsColors.critical)),
          ],
          const SizedBox(height: DsSpacing.xxl),
          DsButton(
            label: _busy ? 'Saving…' : 'Save',
            onPressed: _busy ? null : () => _save(s),
          ),

          const SizedBox(height: DsSpacing.xxxl),
          const DsEyebrow('This device'),
          const SizedBox(height: DsSpacing.md),
          // A private app is often opened on a borrowed or shared phone, so
          // signing out is a safety control rather than a settings nicety
          // (Notion 04 Section 11). It stays reachable and plainly worded.
          DsButton(
            label: 'Sign out',
            outline: true,
            onPressed: _busy ? null : _signOut,
          ),
          const SizedBox(height: DsSpacing.md),
          Text(
            'Your history stays. Signing out only ends this session on '
            'this device.',
            style: DsType.fine.copyWith(color: DsColors.muted),
          ),
          const SizedBox(height: DsSpacing.xxl),
        ],
      ),
    );
  }
}

class _TimeField extends StatelessWidget {
  const _TimeField({
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String label;
  final TimeOfDay value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final h = value.hour.toString().padLeft(2, '0');
    final m = value.minute.toString().padLeft(2, '0');
    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: DsType.fine.copyWith(color: DsColors.muted)),
          const SizedBox(height: DsSpacing.xs),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
                vertical: DsSpacing.lg, horizontal: DsSpacing.lg),
            decoration: BoxDecoration(
              border: Border.all(color: DsColors.lineStrong),
              borderRadius: BorderRadius.circular(DsSpacing.buttonRadius),
            ),
            child: Text('$h:$m', style: DsType.cardTitle),
          ),
        ],
      ),
    );
  }
}

class _PreviewChoice extends StatelessWidget {
  const _PreviewChoice({
    required this.title,
    required this.body,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final String body;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(15, 14, 15, 14),
        decoration: BoxDecoration(
          color: selected ? DsColors.stone : DsColors.surface,
          border: Border.all(
            color: selected ? DsColors.ink : DsColors.line,
          ),
          borderRadius: BorderRadius.circular(DsSpacing.cardRadius),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: DsType.cardTitle),
            const SizedBox(height: DsSpacing.xs),
            Text(body, style: DsType.fine.copyWith(color: DsColors.muted)),
          ],
        ),
      ),
    );
  }
}
