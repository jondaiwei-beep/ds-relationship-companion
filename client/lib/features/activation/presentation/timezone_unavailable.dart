import 'package:ds_relationship_companion/ds_design_system.dart';
import 'package:flutter/material.dart';

import '../../../app/shell/ds_primary_button.dart';
import '../../../l10n/app_localizations.dart';
import '../../../platform/time/device_timezone.dart';

/// What activation does when the device will not say which zone it is in.
///
/// REQ-TIME-001 will not accept a guess: a Dynamic created in the wrong zone
/// moves someone's relationship day, months later, with nothing on screen to
/// explain it. So this asks rather than assumes.
///
/// It replaces a `NotBuiltYet` placeholder that read "this route is reserved,
/// its build gate is closed" — a dead end, in language about the build rather
/// than about the person's day. Reaching a screen you cannot leave is worse
/// than any wording on it.
class TimezoneUnavailable extends StatefulWidget {
  const TimezoneUnavailable({super.key, required this.onResolved});

  /// A zone was obtained. Activation can continue.
  ///
  /// There is deliberately no "leave" beside it. An account with no Dynamic
  /// has nowhere else to be: sending them to Today would resolve to no
  /// Dynamic and route straight back here, which a journey test caught as an
  /// endless bounce. Two ways forward and no false exit.
  final void Function(String timezone) onResolved;

  @override
  State<TimezoneUnavailable> createState() => _TimezoneUnavailableState();
}

class _TimezoneUnavailableState extends State<TimezoneUnavailable> {
  bool _retried = false;

  Future<void> _retry() async {
    await primeDeviceTimezone();
    if (!mounted) return;
    final zone = deviceTimezone();
    if (zone != null) {
      widget.onResolved(zone);
      return;
    }
    setState(() => _retried = true);
  }

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    return Scaffold(
      backgroundColor: DsColors.canvasRitual,
      body: DsRitualSurface(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: DsSpacing.space6,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  l.activationTimezoneTitle,
                  textAlign: TextAlign.center,
                  style: DsTextStyles.displayRitual.copyWith(
                    color: DsColors.textOnRitualPrimary,
                  ),
                ),
                const SizedBox(height: DsSpacing.space6),
                Text(
                  _retried
                      ? l.activationTimezoneWhyRetried
                      : l.activationTimezoneWhyFirst,
                  textAlign: TextAlign.center,
                  style: DsTextStyles.bodySecondary.copyWith(
                    color: DsColors.textOnRitualSecondary,
                  ),
                ),
                const SizedBox(height: DsSpacing.space10),
                if (!_retried)
                  DsPrimaryButton(
                    label: l.activationTimezoneTryAgain,
                    onPressed: _retry,
                  ),
                if (_retried)
                  DsPrimaryButton(
                    label: l.activationTimezoneChooseMyself,
                    onPressed: () => _pick(context),
                  ),
                const SizedBox(height: DsSpacing.space4),
                // The other way forward, whichever one the primary is not.
                TextButton(
                  onPressed: _retried ? _retry : () => _pick(context),
                  child: Text(
                    _retried
                        ? l.activationTimezoneTryReadingAgain
                        : l.activationTimezoneChooseMyself,
                    style: DsTextStyles.bodySecondary.copyWith(
                      color: DsColors.textOnRitualMuted,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pick(BuildContext context) async {
    final chosen = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: DsColors.canvasRitual,
      isScrollControlled: true,
      builder: (context) => const _ZonePicker(),
    );
    if (chosen != null) widget.onResolved(chosen);
  }
}

/// A short list, not all 400-odd IANA names.
///
/// Someone who has landed here has a device that will not report its zone at
/// all; a searchable list of every zone on earth is a worse answer than the
/// handful that cover most people, each named the way a person would say it.
class _ZonePicker extends StatelessWidget {
  const _ZonePicker();

  /// IANA identifiers only. The name a person reads comes from the
  /// localisations — the identifier itself is the value that travels.
  static const _zones = [
    'Asia/Shanghai',
    'Asia/Tokyo',
    'Asia/Singapore',
    'Asia/Kolkata',
    'Europe/London',
    'Europe/Paris',
    'America/New_York',
    'America/Chicago',
    'America/Denver',
    'America/Los_Angeles',
    'Australia/Sydney',
  ];

  static String _zoneName(L l, String id) => switch (id) {
        'Asia/Shanghai' => l.activationZoneChina,
        'Asia/Tokyo' => l.activationZoneJapan,
        'Asia/Singapore' => l.activationZoneSingapore,
        'Asia/Kolkata' => l.activationZoneIndia,
        'Europe/London' => l.activationZoneUnitedKingdom,
        'Europe/Paris' => l.activationZoneCentralEurope,
        'America/New_York' => l.activationZoneUsEastern,
        'America/Chicago' => l.activationZoneUsCentral,
        'America/Denver' => l.activationZoneUsMountain,
        'America/Los_Angeles' => l.activationZoneUsPacific,
        'Australia/Sydney' => l.activationZoneEasternAustralia,
        // Every id in `_zones` is named above; the identifier is a truthful
        // last resort rather than an empty row.
        _ => id,
      };

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    return SafeArea(
      child: ListView(
        shrinkWrap: true,
        children: [
          Padding(
            padding: const EdgeInsets.all(DsSpacing.space6),
            child: Text(
              l.activationTimezonePickerTitle,
              style: DsTextStyles.labelRitual.copyWith(
                color: DsColors.textOnRitualMuted,
              ),
            ),
          ),
          for (final id in _zones)
            ListTile(
              title: Text(
                _zoneName(l, id),
                style: DsTextStyles.bodyPrimary.copyWith(
                  color: DsColors.textOnRitualPrimary,
                ),
              ),
              subtitle: Text(
                id,
                style: DsTextStyles.bodySecondary.copyWith(
                  color: DsColors.textOnRitualMuted,
                ),
              ),
              onTap: () => Navigator.of(context).pop(id),
            ),
        ],
      ),
    );
  }
}
