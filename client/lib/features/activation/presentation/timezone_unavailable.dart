import 'package:ds_relationship_companion/ds_design_system.dart';
import 'package:flutter/material.dart';

import '../../../app/shell/ds_primary_button.dart';
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
                  "We could not read\nyour time zone.",
                  textAlign: TextAlign.center,
                  style: DsTextStyles.displayRitual.copyWith(
                    color: DsColors.textOnRitualPrimary,
                  ),
                ),
                const SizedBox(height: DsSpacing.space6),
                Text(
                  _retried
                      ? 'Still nothing. Choosing it yourself works just as '
                          'well — your day is measured in the zone you pick.'
                      : 'Your day has to be measured somewhere, and guessing '
                          'would move it later without saying so.',
                  textAlign: TextAlign.center,
                  style: DsTextStyles.bodySecondary.copyWith(
                    color: DsColors.textOnRitualSecondary,
                  ),
                ),
                const SizedBox(height: DsSpacing.space10),
                if (!_retried)
                  DsPrimaryButton(label: 'Try again', onPressed: _retry),
                if (_retried)
                  DsPrimaryButton(
                    label: 'Choose it myself',
                    onPressed: () => _pick(context),
                  ),
                const SizedBox(height: DsSpacing.space4),
                // The other way forward, whichever one the primary is not.
                TextButton(
                  onPressed: _retried ? _retry : () => _pick(context),
                  child: Text(
                    _retried ? 'Try reading it again' : 'Choose it myself',
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

  static const _zones = [
    ('Asia/Shanghai', 'China'),
    ('Asia/Tokyo', 'Japan'),
    ('Asia/Singapore', 'Singapore'),
    ('Asia/Kolkata', 'India'),
    ('Europe/London', 'United Kingdom'),
    ('Europe/Paris', 'Central Europe'),
    ('America/New_York', 'US Eastern'),
    ('America/Chicago', 'US Central'),
    ('America/Denver', 'US Mountain'),
    ('America/Los_Angeles', 'US Pacific'),
    ('Australia/Sydney', 'Eastern Australia'),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        shrinkWrap: true,
        children: [
          Padding(
            padding: const EdgeInsets.all(DsSpacing.space6),
            child: Text(
              'WHERE YOUR DAY IS MEASURED',
              style: DsTextStyles.labelRitual.copyWith(
                color: DsColors.textOnRitualMuted,
              ),
            ),
          ),
          for (final (id, name) in _zones)
            ListTile(
              title: Text(
                name,
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
