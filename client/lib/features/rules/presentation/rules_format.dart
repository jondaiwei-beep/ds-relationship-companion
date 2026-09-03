import '../../../domain_client/models/task.dart';
import '../../../l10n/app_localizations.dart';

/// Words for the 规矩 surface. Every one is a fact about a definition, never a
/// judgement of how it went.
abstract final class RulesFormat {
  static String group(L l, String group) => switch (group) {
        'protocol' => l.ruleGroupProtocol,
        'ritual' => l.ruleGroupRitual,
        'restriction' => l.ruleGroupRestriction,
        'appearance' => l.ruleGroupAppearance,
        'reporting' => l.ruleGroupReporting,
        _ => l.ruleGroupOther,
      };

  static String proof(L l, String proof) => switch (proof) {
        'photo' => l.rulesProofPhoto,
        'text' => l.rulesProofText,
        'any' => l.rulesProofAny,
        _ => l.rulesProofCheck,
      };

  /// `{"type":"daily"}` · `{"type":"weekdays","days":[1,3,5]}` (ISO, Mon=1) ·
  /// `{"type":"every_n_days","n":3}` — backend today/domain/Today.kt.
  static String schedule(L l, TaskView t) {
    switch (t.kind) {
      case 'one_off':
        return l.rulesScheduleOneOff;
      case 'open':
        return l.rulesScheduleOpen;
      case 'checkin':
        return l.rulesScheduleCheckin;
      case 'measure':
        return l.rulesScheduleMeasure;
    }
    final s = t.schedule ?? const {'type': 'daily'};
    final base = switch (s['type']) {
      'weekdays' => l.rulesScheduleWeekdays(_weekdays(l, s['days'])),
      'every_n_days' => l.rulesScheduleEveryN((s['n'] as num?)?.toInt() ?? 1),
      _ => l.rulesScheduleDaily,
    };
    return t.timesPerDay > 1 ? '$base · ${l.rulesTimesPerDay(t.timesPerDay)}' : base;
  }

  static String _weekdays(L l, Object? days) {
    final names = l.rulesWeekdayNames.split(',');
    final list = (days as List?)?.map((d) => (d as num).toInt()).toList() ?? const <int>[];
    list.sort();
    return list.where((d) => d >= 1 && d <= 7).map((d) => names[d - 1]).join('·');
  }
}
