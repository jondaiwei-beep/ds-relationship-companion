import 'package:ds_relationship_companion/ds_design_system.dart';
import 'package:flutter/material.dart';

import '../../../app/shell/ds_glyph.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' as intl;
import 'package:timezone/timezone.dart' as tz;

import '../../../app/locale_controller.dart';
import '../../../app/providers.dart';
import '../../../app/shell/ds_refreshable.dart';
import '../../../domain_client/models/dynamic_view.dart';
import '../../../domain_client/models/notification.dart';
import '../../../domain_client/models/notification_settings.dart';
import '../../../l10n/app_localizations.dart';
import '../../device_lock/application/device_lock_controller.dart';
import '../../dynamic/application/dynamic_providers.dart';
import '../../notifications/application/notification_providers.dart';
import '../../today/application/today_providers.dart';
import '../../today/presentation/widgets/secondary_button.dart';
import '../../today/presentation/widgets/today_layout.dart';

final notificationSettingsProvider = FutureProvider<NotificationSettings>(
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
    this.onPoints,
  });

  final String dynamicId;
  final VoidCallback? onClose;
  final VoidCallback? onSignOut;

  /// Opens SCR-30. Leaving and blocking are consequential enough to deserve
  /// their own screen rather than a row that acts on one tap.
  final VoidCallback? onLeave;

  /// Points, rewards and what the couple agreed happens when something is
  /// not done (owner decision 2026-09-02).
  final VoidCallback? onPoints;

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
      setState(() => _failure = L.of(context).settingsSaveFailed);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  /// The device-side preferences: what the lockscreen may say, whether
  /// deliveries are folded, and which kinds stay quiet. Partial by design.
  Future<void> _updateMute({
    bool? neutral,
    int? digestHours,
    bool clearDigest = false,
    Set<String>? mutedTypes,
  }) async {
    setState(() {
      _busy = true;
      _failure = null;
    });
    try {
      await ref.read(notificationRepositoryProvider).updateMuteSettings(
            neutralLockscreen: neutral,
            deliverDigestHours: digestHours,
            clearDigest: clearDigest,
            mutedTypes: mutedTypes,
          );
      ref.invalidate(muteSettingsProvider);
    } on Object {
      if (!mounted) return;
      setState(() => _failure = L.of(context).settingsSaveFailed);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  /// The Dynamic's own settings — shared by both, so 今天 is re-read too.
  Future<void> _updateDynamic({
    String? timezone,
    int? dayBoundaryMinutes,
    String? honorificForD,
    String? honorificForS,
    String? safeword,
  }) async {
    setState(() {
      _busy = true;
      _failure = null;
    });
    try {
      await ref.read(dynamicRepositoryProvider).updateSettings(
            widget.dynamicId,
            timezone: timezone,
            dayBoundaryMinutes: dayBoundaryMinutes,
            honorificForD: honorificForD,
            honorificForS: honorificForS,
            safeword: safeword,
          );
      ref.invalidate(dynamicDetailProvider(widget.dynamicId));
      ref.invalidate(todayProvider(widget.dynamicId));
    } on Object {
      if (!mounted) return;
      setState(() => _failure = L.of(context).settingsSaveFailed);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  /// One answer to "what may the lockscreen say", written to both places
  /// that read it: the server's preview setting and the device's mute
  /// settings, which this app's own notifications follow.
  Future<void> _setNeutral(bool neutral) async {
    await _update(preview: neutral ? 'NEUTRAL' : 'RICH');
    await _updateMute(neutral: neutral);
  }

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    final settings = ref.watch(notificationSettingsProvider);
    final mute = ref.watch(muteSettingsProvider).value;
    final detail = ref.watch(dynamicDetailProvider(widget.dynamicId));

    return Scaffold(
      backgroundColor: DsColors.canvasRitual,
      body: DsRitualSurface(
        child: SafeArea(
          child: Column(
            children: [
              _TopBar(onClose: widget.onClose),
              Expanded(
                // Settings reads once and keeps it. Notification preferences
                // do not change behind your back, so re-reading them because
                // you opened the page again was pure cost.
                child: DsRefreshable(
                  onRefresh: () =>
                      ref.refresh(notificationSettingsProvider.future),
                  child: ListView(
                    padding: EdgeInsets.zero,
                    children: [
                      _Language(
                        chosen: switch (ref.watch(localeProvider)) {
                          AsyncData(:final value) => value,
                          _ => null,
                        },
                        onChoose: (locale) =>
                            ref.read(localeProvider.notifier).choose(locale),
                      ),
                      const SizedBox(height: DsSpacing.space10),

                      // SCR-29.
                      settings.when(
                        loading: () => _Quiet(l.settingsLoading),
                        error: (_, _) =>
                            _Quiet(l.settingsLoadFailed, prominent: true),
                        data: (value) => _Notifications(
                          value: value,
                          mute: mute,
                          busy: _busy,
                          onNeutral: _setNeutral,
                          onDigest: (h) => h == null
                              ? _updateMute(clearDigest: true)
                              : _updateMute(digestHours: h),
                          onMutedTypes: (t) => _updateMute(mutedTypes: t),
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

                      // SCR-34.
                      if (detail.hasValue)
                        _SharedDay(
                          view: detail.value!,
                          busy: _busy,
                          onTimezone: (z) => _updateDynamic(timezone: z),
                          onDayStart: (m) => _updateDynamic(dayBoundaryMinutes: m),
                          onHonorificD: (v) => _updateDynamic(honorificForD: v),
                          onHonorificS: (v) => _updateDynamic(honorificForS: v),
                          onSafeword: (v) => _updateDynamic(safeword: v),
                        ),

                      const SizedBox(height: DsSpacing.space10),
                      _Section(l.settingsPointsSection),
                      if (widget.onPoints != null)
                        Padding(
                          padding: todayInset,
                          child: SecondaryButton(
                            label: l.settingsPointsOpen,
                            onTap: widget.onPoints!,
                          ),
                        ),
                      const SizedBox(height: DsSpacing.space3),
                      _Quiet(l.settingsPointsSupport),


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
                      const _DeviceLock(),
                      const SizedBox(height: DsSpacing.space4),
                      if (widget.onSignOut != null)
                        Padding(
                          padding: todayInset,
                          child: SecondaryButton(
                            key: const ValueKey('settings-sign-out'),
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
    required this.mute,
    required this.onNeutral,
    required this.onDigest,
    required this.onMutedTypes,
    required this.onQuietHours,
    this.busy = false,
  });

  final NotificationSettings value;

  /// Null while the device-side settings have not been read; the lockscreen
  /// choice then falls back to the server's preview setting.
  final NotificationMuteSettings? mute;
  final ValueChanged<bool> onNeutral;
  final ValueChanged<int?> onDigest;
  final ValueChanged<Set<String>> onMutedTypes;

  /// A null start clears the window; both bounds always travel together.
  final void Function(int? startMin, int? endMin) onQuietHours;
  final bool busy;

  static String _typeLabel(String type, L l) => switch (type) {
        'occurrence_delivered' => l.settingsTypeDelivered,
        'occurrence_flagged' => l.settingsTypeFlagged,
        'disposition_set' => l.settingsTypeDisposition,
        'day_comment' => l.settingsTypeComment,
        'd_award' => l.settingsTypeAward,
        'redemption_requested' => l.settingsTypeRedemption,
        'd_note_reminder' => l.settingsTypeDNote,
        _ => type,
      };

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    final neutral = mute?.neutralLockscreen ?? (value.notificationPreview == 'NEUTRAL');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Section(l.settingsNotificationContentSection),
        _Choice(
          label: l.settingsPreviewNeutralLabel,
          support: l.settingsPreviewNeutralSupport,
          selected: neutral,
          onTap: busy ? null : () => onNeutral(true),
        ),
        _Choice(
          label: l.settingsPreviewRichLabel,
          support: l.settingsPreviewRichSupport,
          selected: !neutral,
          onTap: busy ? null : () => onNeutral(false),
        ),

        const SizedBox(height: DsSpacing.space8),
        _Section(l.settingsDigestSection),
        _Choice(
          label: l.settingsDigestOff,
          support: l.settingsDigestOffSupport,
          selected: mute?.deliverDigestHours == null,
          onTap: busy ? null : () => onDigest(null),
        ),
        for (final h in const [2, 4, 8])
          _Choice(
            label: l.settingsDigestEvery(h),
            selected: mute?.deliverDigestHours == h,
            onTap: busy ? null : () => onDigest(h),
          ),

        const SizedBox(height: DsSpacing.space8),
        _Section(l.settingsMutedTypesSection),
        for (final type in NotificationMuteSettings.mutableTypes)
          _Choice(
            label: _typeLabel(type, l),
            selected: !(mute?.mutedTypes.contains(type) ?? false),
            onTap: busy || mute == null
                ? null
                : () {
                    final next = {...mute!.mutedTypes};
                    if (!next.remove(type)) next.add(type);
                    onMutedTypes(next);
                  },
          ),
        const SizedBox(height: DsSpacing.space2),
        Padding(
          padding: todayInset,
          child: Text(
            l.settingsMutedTypesSupport,
            style: DsTextStyles.bodySecondary.copyWith(
              color: DsColors.textOnRitualMuted,
              fontSize: todaySupportSize,
              height: todaySupportHeight,
            ),
          ),
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
class _SharedDay extends StatelessWidget {
  const _SharedDay({
    required this.view,
    required this.busy,
    required this.onTimezone,
    required this.onDayStart,
    required this.onHonorificD,
    required this.onHonorificS,
    required this.onSafeword,
  });

  final DynamicDetail view;
  final bool busy;
  final ValueChanged<String> onTimezone;
  final ValueChanged<int> onDayStart;
  final ValueChanged<String> onHonorificD;
  final ValueChanged<String> onHonorificS;
  final ValueChanged<String> onSafeword;

  Future<void> _pickDayStart(BuildContext context) async {
    final m = view.dayBoundaryMinutes;
    final t = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: (m ~/ 60) % 24, minute: m % 60),
    );
    if (t == null) return;
    final minutes = t.hour * 60 + t.minute;
    if (minutes != m) onDayStart(minutes);
  }

  Future<void> _pickTimezone(BuildContext context) async {
    final zone = await showTimezonePicker(context, current: view.referenceTimezone);
    if (zone != null && zone != view.referenceTimezone) onTimezone(zone);
  }

  Future<void> _edit(
    BuildContext context, {
    required String title,
    required String? initial,
    required ValueChanged<String> onSave,
  }) async {
    final v = await showTextEditDialog(context, title: title, initial: initial);
    if (v != null && v != (initial ?? '')) onSave(v);
  }

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    final minutes = view.dayBoundaryMinutes;
    final clock = DateTime(2000, 1, 1, (minutes ~/ 60) % 24, minutes % 60);
    // Rendered with the reader's own clock convention: "10:00 PM" in English,
    // "下午10:00" in Chinese. Hard-coding AM/PM would leak English into a
    // sentence that is otherwise translated.
    final label = intl.DateFormat.jm(l.localeName).format(clock);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Section(l.settingsSharedDaySection),
        Padding(
          padding: todayInset.add(const EdgeInsets.only(bottom: DsSpacing.space4)),
          child: Text(
            l.settingsDayBoundaryExplain(label),
            style: DsTextStyles.bodySecondary.copyWith(
              color: DsColors.textOnRitualMuted,
              fontSize: todaySupportSize,
              height: todaySupportHeight,
            ),
          ),
        ),
        _ValueRow(
          key: const ValueKey('setting-timezone'),
          label: l.settingsTimezoneLabel,
          value: view.referenceTimezone,
          onTap: busy ? null : () => _pickTimezone(context),
        ),
        _ValueRow(
          key: const ValueKey('setting-day-start'),
          label: l.settingsDayStartLabel,
          value: intl.DateFormat.Hm(l.localeName).format(clock),
          onTap: busy ? null : () => _pickDayStart(context),
        ),
        _ValueRow(
          key: const ValueKey('setting-honorific-d'),
          label: l.settingsHonorificD,
          value: view.honorificForD,
          onTap: busy
              ? null
              : () => _edit(context, title: l.settingsHonorificD, initial: view.honorificForD, onSave: onHonorificD),
        ),
        _ValueRow(
          key: const ValueKey('setting-honorific-s'),
          label: l.settingsHonorificS,
          value: view.honorificForS,
          onTap: busy
              ? null
              : () => _edit(context, title: l.settingsHonorificS, initial: view.honorificForS, onSave: onHonorificS),
        ),
        _ValueRow(
          key: const ValueKey('setting-safeword'),
          label: l.settingsSafeword,
          value: view.safeword,
          support: l.settingsSafewordSupport,
          onTap: busy
              ? null
              : () => _edit(context, title: l.settingsSafeword, initial: view.safeword, onSave: onSafeword),
        ),
      ],
    );
  }
}

/// One editable fact: a small label, the value beneath (or "还没定"), and a
/// tap that opens whatever picker the fact needs.
class _ValueRow extends StatelessWidget {
  const _ValueRow({super.key, required this.label, required this.value, this.support, required this.onTap});

  final String label;
  final String? value;
  final String? support;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    final unset = value == null || value!.isEmpty;
    return Padding(
      padding: todayInset.add(const EdgeInsets.only(bottom: DsSpacing.space3)),
      child: Semantics(
        button: true,
        label: label,
        value: unset ? l.settingsUnset : value,
        child: GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: Container(
            padding: const EdgeInsets.all(DsSpacing.space4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(DsRadii.card),
              border: Border.all(color: DsColors.borderOnRitualHairline),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(label, style: DsTextStyles.labelRitual.copyWith(color: DsColors.textOnRitualMuted)),
                      const SizedBox(height: DsSpacing.space1),
                      Text(
                        unset ? l.settingsUnset : value!,
                        style: DsTextStyles.bodyPrimary.copyWith(
                          color: unset ? DsColors.textOnRitualMuted : DsColors.textOnRitualPrimary,
                        ),
                      ),
                      if (support != null) ...[
                        const SizedBox(height: DsSpacing.space1),
                        Text(
                          support!,
                          style: DsTextStyles.bodySecondary.copyWith(
                            color: DsColors.textOnRitualMuted,
                            fontSize: todaySupportSize,
                            height: todaySupportHeight,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: DsColors.textOnRitualMuted),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A one-line edit: title, a field, 取消 / 保存. Returns the trimmed text
/// (possibly empty, which clears) or null when dismissed.
Future<String?> showTextEditDialog(BuildContext context, {required String title, String? initial}) =>
    showDialog<String>(
      context: context,
      builder: (_) => _TextEditDialog(title: title, initial: initial),
    );

class _TextEditDialog extends StatefulWidget {
  const _TextEditDialog({required this.title, this.initial});

  final String title;
  final String? initial;

  @override
  State<_TextEditDialog> createState() => _TextEditDialogState();
}

class _TextEditDialogState extends State<_TextEditDialog> {
  late final TextEditingController _controller = TextEditingController(text: widget.initial ?? '');

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    return AlertDialog(
      title: Text(widget.title),
      content: TextField(
        key: const ValueKey('edit-field'),
        controller: _controller,
        autofocus: true,
        maxLength: 40,
        textInputAction: TextInputAction.done,
        onSubmitted: (v) => Navigator.of(context).pop(v.trim()),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(l.settingsEditCancel)),
        TextButton(
          onPressed: () => Navigator.of(context).pop(_controller.text.trim()),
          child: Text(l.settingsEditSave),
        ),
      ],
    );
  }
}

/// Every IANA zone the app knows, narrowed by typing. Returns the chosen
/// zone name or null.
Future<String?> showTimezonePicker(BuildContext context, {required String current}) {
  final all = tz.timeZoneDatabase.locations.keys.toList()..sort();
  return showDialog<String>(
    context: context,
    builder: (ctx) => _TimezoneDialog(all: all, current: current),
  );
}

class _TimezoneDialog extends StatefulWidget {
  const _TimezoneDialog({required this.all, required this.current});

  final List<String> all;
  final String current;

  @override
  State<_TimezoneDialog> createState() => _TimezoneDialogState();
}

class _TimezoneDialogState extends State<_TimezoneDialog> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    final q = _query.trim().toLowerCase().replaceAll(' ', '_');
    final shown = q.isEmpty ? widget.all : widget.all.where((z) => z.toLowerCase().contains(q)).toList();
    return Dialog(
      child: SizedBox(
        width: 360,
        height: 480,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(DsSpacing.space4),
              child: TextField(
                key: const ValueKey('timezone-search'),
                autofocus: true,
                decoration: InputDecoration(hintText: l.settingsTimezoneSearch, prefixIcon: const Icon(Icons.search)),
                onChanged: (v) => setState(() => _query = v),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: shown.length,
                itemBuilder: (_, i) {
                  final z = shown[i];
                  return ListTile(
                    title: Text(z),
                    selected: z == widget.current,
                    onTap: () => Navigator.of(context).pop(z),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The device lock: on or off, with the support line beneath. Turning it on
/// asks the device first; a device that cannot authenticate says so and
/// offers nothing.
class _DeviceLock extends ConsumerWidget {
  const _DeviceLock();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = L.of(context);
    final lock = ref.watch(deviceLockProvider);
    if (!lock.ready) return const SizedBox.shrink();
    if (!lock.available) return _Quiet(l.settingsDeviceLockUnavailable);
    return _Choice(
      label: l.settingsDeviceLock,
      support: l.settingsDeviceLockSupport,
      selected: lock.enabled,
      onTap: () => ref
          .read(deviceLockProvider.notifier)
          .setEnabled(!lock.enabled, reason: l.lockReason),
    );
  }
}

/// Choosing a language, or following the phone.
///
/// Not part of SCR-28's approved package — that screen predates the app having
/// more than one language. It belongs here because it is an account-level
/// preference like the others, and it goes first because it is the one setting
/// that decides whether the rest of the page can be read.
///
/// Each option is labelled in its own language in every locale. Someone who
/// has landed in a language they cannot read has to be able to find their way
/// out, and "English" rendered in Chinese would not help them do it.
class _Language extends StatelessWidget {
  const _Language({required this.chosen, required this.onChoose});

  /// Null means following the device, which is the default and a real choice
  /// rather than an absent one.
  final Locale? chosen;
  final ValueChanged<Locale?> onChoose;

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Section(l.settingsLanguageSection),
        _Choice(
          label: l.settingsLanguageFollowDevice,
          support: l.settingsLanguageFollowDeviceSupport,
          selected: chosen == null,
          onTap: () => onChoose(null),
        ),
        _Choice(
          label: l.settingsLanguageEnglish,
          selected: chosen?.languageCode == 'en',
          onTap: () => onChoose(const Locale('en')),
        ),
        _Choice(
          label: l.settingsLanguageChinese,
          selected: chosen?.languageCode == 'zh',
          onTap: () => onChoose(const Locale('zh')),
        ),
        const SizedBox(height: DsSpacing.space2),
        Padding(
          padding: todayInset,
          child: Text(
            l.settingsLanguageNote,
            style: DsTextStyles.bodySecondary.copyWith(
              color: DsColors.textOnRitualMuted,
              fontSize: todaySupportSize,
              height: todaySupportHeight,
            ),
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
      padding: todayInset.add(const EdgeInsets.only(bottom: DsSpacing.space4)),
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
    this.support,
    required this.selected,
    required this.onTap,
  });

  final String label;

  /// Optional: the language rows are self-explanatory, and an empty line
  /// would still reserve its height and leave a gap under each one.
  final String? support;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: todayInset.add(const EdgeInsets.only(bottom: DsSpacing.space3)),
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
              if (support case final s? when s.isNotEmpty) ...[
                const SizedBox(height: DsSpacing.space1),
                Text(
                  s,
                  style: DsTextStyles.bodySecondary.copyWith(
                    color: DsColors.textOnRitualMuted,
                    fontSize: todaySupportSize,
                    height: todaySupportHeight,
                  ),
                ),
              ],
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
            key: const ValueKey('settings-close'),
            onTap: onClose,
            behavior: HitTestBehavior.opaque,
            child: DsGlyphIcon(
              DsGlyph.close,
              semanticLabel: L.of(context).settingsClose,
            ),
          ),
        ],
      ),
    );
  }
}
