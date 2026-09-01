import 'package:ds_relationship_companion/ds_design_system.dart';
import '../../../../l10n/app_localizations.dart';
import 'package:flutter/material.dart';

import '../../../today/presentation/widgets/today_layout.dart';

/// When it is due, or nothing at all.
///
/// "Anytime" is the default and is a real answer, not an empty one: an
/// expectation without a deadline is a standing intention, and forcing a time
/// onto everything would turn the product into a scheduler. Clearing is
/// therefore always offered once a time is set.
class WhenRow extends StatelessWidget {
  const WhenRow({
    super.key,
    required this.value,
    required this.zone,
    required this.onChanged,
    this.enabled = true,
  });

  final DateTime? value;

  /// The Dynamic's timezone, named so the person knows whose clock this is.
  /// The relationship day is not the device's day.
  final String zone;

  final ValueChanged<DateTime?> onChanged;
  final bool enabled;

  Future<void> _pick(BuildContext context) async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: value ?? now,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: now.add(const Duration(days: 365)),
    );
    if (date == null) return;
    if (!context.mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(value ?? now),
    );
    if (time == null) return;

    onChanged(
      DateTime(date.year, date.month, date.day, time.hour, time.minute),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: enabled ? () => _pick(context) : null,
            behavior: HitTestBehavior.opaque,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value == null ? L.of(context).whenAnytime : _label(value!, L.of(context).whenToday),
                  style: DsTextStyles.displayRitual.copyWith(
                    color: value == null
                        ? DsColors.textOnRitualMuted
                        : DsColors.textOnRitualPrimary,
                    fontSize: 22,
                    height: 27 / 22,
                  ),
                ),
                const SizedBox(height: DsSpacing.space2),
                Container(height: 1, color: DsColors.borderOnRitualHairline),
                if (value != null) ...[
                  const SizedBox(height: DsSpacing.space2),
                  Text(
                    zone,
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
        if (value != null)
          GestureDetector(
            onTap: enabled ? () => onChanged(null) : null,
            child: Padding(
              padding: const EdgeInsets.only(left: DsSpacing.space4),
              child: Text(
                L.of(context).whenClear,
                style: DsTextStyles.bodySecondary.copyWith(
                  color: DsColors.textOnRitualMuted,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

String _label(DateTime d, String todayWord) {
  final now = DateTime.now();
  final sameDay = d.year == now.year && d.month == now.month && d.day == now.day;
  final hh = d.hour % 12 == 0 ? 12 : d.hour % 12;
  final mm = d.minute.toString().padLeft(2, '0');
  final ampm = d.hour < 12 ? 'AM' : 'PM';
  final when = sameDay ? todayWord : '${d.year}-${_two(d.month)}-${_two(d.day)}';
  return '$when · $hh:$mm $ampm';
}

String _two(int n) => n.toString().padLeft(2, '0');
