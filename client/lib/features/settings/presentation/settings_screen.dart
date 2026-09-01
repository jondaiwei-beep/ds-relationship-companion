import 'package:ds_relationship_companion/ds_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' as intl;

import '../../../app/providers.dart';
import '../../../domain_client/models/dynamic_view.dart';
import '../../../domain_client/models/notification_settings.dart';
import '../../../l10n/app_localizations.dart';
import '../../dynamic/presentation/dynamic_screen.dart';
import '../../today/presentation/widgets/secondary_button.dart';
import '../../today/presentation/widgets/today_layout.dart';

final notificationSettingsProvider =
    FutureProvider.autoDispose<NotificationSettings>(
      (ref) => ref.watch(settingsRepositoryProvider).notifications(),
    );

/// SCR-28 Account settings, holding SCR-29 (delivery rhythm) and SCR-34
/// (timezone and day boundary).
///
/// Sprint 10 lists six screens. Two are not built, and neither is a judgement
/// about their value:
///
/// - **SCR-25 notification history.** There is no endpoint. Every row would
///   have to be invented, and a fabricated record of what the app told you is
///   worse than no record.
/// - **SCR-26 privacy boundaries.** The only visibility the server models is
///   per check-in, chosen when writing it, which SCR-22 already does. A
///   settings page of switches that control nothing would be a promise about
///   privacy the system does not keep.
///
/// SCR-34 appears here as a statement rather than a control: the reference
/// timezone and day boundary are fixed when a Dynamic is created and there is
/// no endpoint to change them. Showing them read-only answers the screen's
/// actual job — understanding which clock governs your rituals — without
/// pretending they can be edited.
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({
    super.key,
    required this.dynamicId,
    this.onClose,
    this.onSignOut,
    this.onLeave,
  });

  final String dynamicId;
  final VoidCallback? onClose;
  final VoidCallback? onSignOut;

  /// Opens SCR-30. Leaving and blocking are consequential enough to deserve
  /// their own screen rather than a row that acts on one tap.
  final VoidCallback? onLeave;

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _busy = false;
  String? _failure;

  Future<void> _update({
    String? preview,
    int? startMin,
    int? endMin,
    bool clearQuietHours = false,
  }) async {
    // Every update sends the whole set, so the current values have to be in
    // hand: sending one field alone would clear the others.
    final async = ref.read(notificationSettingsProvider);
    if (!async.hasValue) return;
    final current = async.value!;

    setState(() {
      _busy = true;
      _failure = null;
    });

    try {
      await ref
          .read(settingsRepositoryProvider)
          .update(
            notificationPreview: preview ?? current.notificationPreview,
            // Quiet hours travel as a pair or not at all: half a window would
            // suppress nothing while looking set.
            quietHoursStartMin: clearQuietHours
                ? null
                : (startMin ?? current.quietHoursStartMin),
            quietHoursEndMin: clearQuietHours
                ? null
                : (endMin ?? current.quietHoursEndMin),
          );
      ref.invalidate(notificationSettingsProvider);
    } on Object {
      if (!mounted) return;
      setState(
        () => _failure = L.of(context).settingsSaveFailed,
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    final settings = ref.watch(notificationSettingsProvider);
    final detail = ref.watch(dynamicDetailProvider(widget.dynamicId));

    return Scaffold(
      backgroundColor: DsColors.canvasRitual,
      body: DsRitualSurface(
        child: SafeArea(
          child: Column(
            children: [
              _TopBar(onClose: widget.onClose),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    // SCR-29.
                    settings.when(
                      loading: () => _Quiet(l.settingsLoading),
                      error: (_, _) => _Quiet(
                        l.settingsLoadFailed,
                        prominent: true,
                      ),
                      data: (value) => _Notifications(
                        value: value,
                        busy: _busy,
                        onPreview: (p) => _update(preview: p),
                        onQuietHours: (start, end) => start == null
                            ? _update(clearQuietHours: true)
                            : _update(startMin: start, endMin: end),
                      ),
                    ),

                    if (_failure != null) ...[
                      const SizedBox(height: DsSpacing.space4),
                      _Quiet(_failure!, prominent: true),
                    ],

                    const SizedBox(height: DsSpacing.space10),

                    // SCR-34, read-only.
                    if (detail.hasValue) _Time(view: detail.value!),

                    const SizedBox(height: DsSpacing.space10),
                    _Section(l.settingsPairingSection),
                    if (widget.onLeave != null)
                      Padding(
                        padding: todayInset,
                        child: SecondaryButton(
                          label: l.settingsLeaveOrBlock,
                          onTap: widget.onLeave!,
                        ),
                      ),
                    const SizedBox(height: DsSpacing.space3),
                    _Quiet(l.settingsLeaveNeedsNoAgreement),

                    const SizedBox(height: DsSpacing.space10),
                    _Section(l.settingsDeviceSection),
                    if (widget.onSignOut != null)
                      Padding(
                        padding: todayInset,
                        child: SecondaryButton(
                          label: l.settingsSignOut,
                          onTap: widget.onSignOut!,
                        ),
                      ),
                    const SizedBox(height: DsSpacing.space3),
                    _Quiet(l.settingsSignOutSupport),
                    const SizedBox(height: DsSpacing.space10),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// SCR-29 — how much a notification may say, and when it may arrive.
class _Notifications extends StatelessWidget {
  const _Notifications({
    required this.value,
    required this.onPreview,
    required this.onQuietHours,
    this.busy = false,
  });

  final NotificationSettings value;
  final ValueChanged<String> onPreview;

  /// A null start clears the window; both bounds always travel together.
  final void Function(int? startMin, int? endMin) onQuietHours;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Section(l.settingsNotificationContentSection),
        _Choice(
          label: l.settingsPreviewNeutralLabel,
          support: l.settingsPreviewNeutralSupport,
          selected: value.notificationPreview == 'NEUTRAL',
          onTap: busy ? null : () => onPreview('NEUTRAL'),
        ),
        _Choice(
          label: l.settingsPreviewRichLabel,
          support: l.settingsPreviewRichSupport,
          selected: value.notificationPreview == 'RICH',
          onTap: busy ? null : () => onPreview('RICH'),
        ),

        const SizedBox(height: DsSpacing.space8),
        _Section(l.settingsQuietHoursSection),
        _Choice(
          label: l.settingsQuietHoursOffLabel,
          support: l.settingsQuietHoursOffSupport,
          selected: !value.quietHoursOn,
          onTap: busy ? null : () => onQuietHours(null, null),
        ),
        // One preset rather than a picker. The window is the same shape for
        // almost everyone who wants one, and a two-field time picker for a
        // setting this ordinary is more work than it saves.
        _Choice(
          label: l.settingsQuietHoursPresetLabel,
          support: l.settingsQuietHoursPresetSupport,
          selected: value.quietHoursOn,
          onTap: busy ? null : () => onQuietHours(22 * 60, 7 * 60),
        ),
      ],
    );
  }
}

/// SCR-34 — which clock governs the relationship day. Stated, not editable:
/// both values are fixed at creation and no endpoint changes them.
class _Time extends StatelessWidget {
  const _Time({required this.view});

  final DynamicDetail view;

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    final minutes = view.dayBoundaryMinutes;
    // Rendered with the reader's own clock convention: "10:00 PM" in English,
    // "下午10:00" in Chinese. Hard-coding AM/PM would leak English into a
    // sentence that is otherwise translated.
    final label = intl.DateFormat.jm(l.localeName).format(
      DateTime(2000, 1, 1, (minutes ~/ 60) % 24, minutes % 60),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Section(l.settingsSharedDaySection),
        Padding(
          padding: todayInset,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                view.referenceTimezone,
                style: DsTextStyles.displayRitual.copyWith(
                  color: DsColors.textOnRitualPrimary,
                  fontSize: 22,
                  height: 27 / 22,
                ),
              ),
              const SizedBox(height: DsSpacing.space2),
              Text(
                l.settingsDayBoundaryExplain(label),
                style: DsTextStyles.bodySecondary.copyWith(
                  color: DsColors.textOnRitualMuted,
                  fontSize: todaySupportSize,
                  height: todaySupportHeight,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Section extends StatelessWidget {
  const _Section(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: todayInset.add(
        const EdgeInsets.only(bottom: DsSpacing.space4),
      ),
      child: Text(
        text,
        style: DsTextStyles.labelRitual.copyWith(
          color: DsColors.textOnRitualMuted,
        ),
      ),
    );
  }
}

class _Choice extends StatelessWidget {
  const _Choice({
    required this.label,
    required this.support,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final String support;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: todayInset.add(
        const EdgeInsets.only(bottom: DsSpacing.space3),
      ),
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.all(DsSpacing.space4),
          decoration: BoxDecoration(
            color: selected ? DsColors.surfaceRitualAction : null,
            borderRadius: BorderRadius.circular(DsRadii.card),
            border: Border.all(
              color: selected
                  ? DsColors.borderOnRitualStrong
                  : DsColors.borderOnRitualHairline,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: DsTextStyles.bodyPrimary.copyWith(
                  color: selected
                      ? DsColors.textOnRitualPrimary
                      : DsColors.textOnRitualSecondary,
                ),
              ),
              const SizedBox(height: DsSpacing.space1),
              Text(
                support,
                style: DsTextStyles.bodySecondary.copyWith(
                  color: DsColors.textOnRitualMuted,
                  fontSize: todaySupportSize,
                  height: todaySupportHeight,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Quiet extends StatelessWidget {
  const _Quiet(this.text, {this.prominent = false});

  final String text;
  final bool prominent;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: todayInset,
      child: Text(
        text,
        style: prominent
            ? DsTextStyles.bodyPrimary.copyWith(
                color: DsColors.textOnRitualPrimary,
              )
            : DsTextStyles.bodySecondary.copyWith(
                color: DsColors.textOnRitualMuted,
                fontSize: todaySupportSize,
                height: todaySupportHeight,
              ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({this.onClose});

  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: todayInset.add(
        const EdgeInsets.symmetric(vertical: DsSpacing.space4),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              L.of(context).settingsTitle,
              style: DsTextStyles.bodyPrimary.copyWith(
                color: DsColors.textOnRitualPrimary,
              ),
            ),
          ),
          GestureDetector(
            onTap: onClose,
            behavior: HitTestBehavior.opaque,
            child: Icon(
              Icons.close,
              size: 22,
              color: DsColors.textOnRitualMuted,
              semanticLabel: L.of(context).settingsClose,
            ),
          ),
        ],
      ),
    );
  }
}
