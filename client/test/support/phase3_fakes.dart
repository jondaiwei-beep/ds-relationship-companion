import 'package:dsapp/domain_client/models/consequence.dart';
import 'package:dsapp/domain_client/models/dynamic_view.dart';
import 'package:dsapp/domain_client/models/points.dart';
import 'package:dsapp/domain_client/models/redemption.dart';
import 'package:dsapp/domain_client/models/rule.dart';
import 'package:dsapp/domain_client/models/task.dart';
import 'package:dsapp/domain_client/repositories/consequence_repository.dart';
import 'package:dsapp/domain_client/repositories/dynamic_repository.dart';
import 'package:dsapp/domain_client/repositories/points_repository.dart';
import 'package:dsapp/domain_client/repositories/rule_repository.dart';
import 'package:dsapp/domain_client/repositories/task_repository.dart';

/// The pair as the server describes it. `u-d` is the D, `u-s` is the s.
DynamicDetail pairDetail({DateTime? dAwayUntil, String? safeword}) => DynamicDetail(
      dynamicId: 'dyn-1',
      state: 'active',
      desiredOutcome: 'closer',
      structureLevel: 'light',
      referenceTimezone: 'Asia/Shanghai',
      dAwayUntil: dAwayUntil,
      safeword: safeword,
      members: const [
        MemberView(userId: 'u-d', displayName: 'Nia', roleContext: 'd', side: 'D', accessState: 'active'),
        MemberView(userId: 'u-s', displayName: 'Mara', roleContext: 's', side: 'S', accessState: 'active'),
      ],
    );

class FakeDynamicRepository implements DynamicRepository {
  FakeDynamicRepository({DynamicDetail? detail}) : _detail = detail ?? pairDetail();
  DynamicDetail _detail;
  final awayUntil = <DateTime>[];
  int backs = 0;

  @override
  Future<DynamicDetail> detail(String dynamicId) async => _detail;

  @override
  Future<DateTime?> away(String dynamicId, {required DateTime until, required String idempotencyKey}) async {
    awayUntil.add(until);
    _detail = _detail.copyWith(dAwayUntil: until);
    return until;
  }

  @override
  Future<void> back(String dynamicId, {required String idempotencyKey}) async {
    backs++;
    _detail = _detail.copyWith(dAwayUntil: null);
  }

  final settingsCalls = <Map<String, Object?>>[];

  @override
  Future<DynamicDetail> updateSettings(
    String dynamicId, {
    String? timezone,
    int? dayBoundaryMinutes,
    String? honorificForD,
    String? honorificForS,
    String? safeword,
  }) async {
    settingsCalls.add({
      'timezone': timezone,
      'dayBoundaryMinutes': dayBoundaryMinutes,
      'honorificForD': honorificForD,
      'honorificForS': honorificForS,
      'safeword': safeword,
    });
    _detail = _detail.copyWith(
      referenceTimezone: timezone ?? _detail.referenceTimezone,
      dayBoundaryMinutes: dayBoundaryMinutes ?? _detail.dayBoundaryMinutes,
      honorificForD: honorificForD ?? _detail.honorificForD,
      honorificForS: honorificForS ?? _detail.honorificForS,
      safeword: safeword ?? _detail.safeword,
    );
    return _detail;
  }

  @override
  dynamic noSuchMethod(Invocation i) => throw UnimplementedError('${i.memberName}');
}

class FakeRuleRepository implements RuleRepository {
  FakeRuleRepository({List<RuleView> rules = const []}) : rules = List.of(rules);
  List<RuleView> rules;
  final created = <NewRule>[];
  final edits = <(String, RuleEdit)>[];
  final archived = <String>[];
  final accepted = <String>[];

  @override
  Future<List<RuleView>> list(String dynamicId, {bool includeArchived = false}) async => rules;

  @override
  Future<RuleView> create(String dynamicId, NewRule rule, {required String idempotencyKey}) async {
    created.add(rule);
    return RuleView(
      id: 'rule-new-${created.length}',
      title: rule.title,
      body: rule.body,
      group: rule.group,
      createdBy: 'u-x',
      status: 'proposed',
    );
  }

  @override
  Future<RuleView> update(String dynamicId, String ruleId, RuleEdit edit) async {
    edits.add((ruleId, edit));
    return rules.firstWhere((r) => r.id == ruleId);
  }

  @override
  Future<void> archive(String dynamicId, String ruleId, {required String idempotencyKey}) async =>
      archived.add(ruleId);

  @override
  Future<RuleView> accept(String dynamicId, String ruleId, {required String idempotencyKey}) async {
    accepted.add(ruleId);
    return rules.firstWhere((r) => r.id == ruleId).copyWith(status: 'active');
  }
}

/// Definitions only: the today-side fake in today_fakes.dart covers delivery.
class FakeTaskDefinitions implements TaskRepository {
  FakeTaskDefinitions({List<TaskView> tasks = const []}) : tasks = List.of(tasks);
  List<TaskView> tasks;
  final created = <NewTask>[];
  final accepted = <String>[];
  final declined = <String>[];
  final archived = <String>[];
  final updated = <(String, NewTask)>[];
  final paused = <(String, DateTime?)>[];
  final unpaused = <String>[];

  TaskView _find(String id) => tasks.firstWhere((t) => t.id == id);

  @override
  Future<List<TaskView>> list(String dynamicId, {bool includeArchived = false}) async => tasks;

  @override
  Future<TaskView> create(String dynamicId, NewTask task, {required String idempotencyKey}) async {
    created.add(task);
    return TaskView(
      id: 'task-new-${created.length}',
      title: task.title,
      kind: task.kind,
      proof: task.proof,
      createdBy: 'u-x',
      status: 'proposed',
    );
  }

  @override
  Future<TaskView> update(String dynamicId, String taskId, NewTask task) async {
    updated.add((taskId, task));
    return _find(taskId);
  }

  @override
  Future<TaskView> accept(String dynamicId, String taskId, {required String idempotencyKey}) async {
    accepted.add(taskId);
    return _find(taskId);
  }

  @override
  Future<void> decline(String dynamicId, String taskId, {required String idempotencyKey}) async =>
      declined.add(taskId);

  @override
  Future<void> archive(String dynamicId, String taskId, {required String idempotencyKey}) async =>
      archived.add(taskId);

  @override
  Future<TaskView> pause(String dynamicId, String taskId, {DateTime? until, required String idempotencyKey}) async {
    paused.add((taskId, until));
    return _find(taskId);
  }

  @override
  Future<TaskView> unpause(String dynamicId, String taskId, {required String idempotencyKey}) async {
    unpaused.add(taskId);
    return _find(taskId);
  }

  @override
  dynamic noSuchMethod(Invocation i) => throw UnimplementedError('${i.memberName}');
}

class FakePointsRepository implements PointsRepository {
  FakePointsRepository({
    this.balance = 12,
    List<PointEntry> entries = const [],
    List<Reward> rewardList = const [],
    List<RedemptionView> redemptionList = const [],
    List<PointsRule> rules = const [],
    List<ConsequenceAgreement> agreementList = const [],
  })  : entries = List.of(entries),
        rewardList = List.of(rewardList),
        redemptionList = List.of(redemptionList),
        rules = List.of(rules),
        agreementList = List.of(agreementList);

  int balance;
  List<PointEntry> entries;
  List<Reward> rewardList;
  List<RedemptionView> redemptionList;
  List<PointsRule> rules;
  List<ConsequenceAgreement> agreementList;

  final subjects = <String?>[];
  final adjustments = <(String, int, String?)>[];
  final redeemed = <String>[];
  final requested = <(String, String?)>[];
  final decisions = <(String, bool, String?, int?)>[];
  final fulfilled = <String>[];
  final addedRewards = <(String, int?)>[];
  final retired = <String>[];
  final addedAgreements = <(String, String)>[];
  final endedAgreements = <String>[];

  @override
  Future<PointsSummary> summary(String dynamicId, {String? subjectUserId}) async {
    subjects.add(subjectUserId);
    return PointsSummary(balance: balance, entries: entries, daysTogether: 40);
  }

  @override
  Future<void> adjust(String dynamicId, {required String subjectUserId, required int amount, String? note}) async =>
      adjustments.add((subjectUserId, amount, note));

  @override
  Future<List<Reward>> rewards(String dynamicId, {String? subjectUserId}) async => rewardList;

  @override
  Future<void> addReward(String dynamicId, {required String title, String? detail, int? cost}) async =>
      addedRewards.add((title, cost));

  @override
  Future<void> retireReward(String dynamicId, String rewardId) async => retired.add(rewardId);

  @override
  Future<void> redeem(String dynamicId, String rewardId, {String? idempotencyKey}) async => redeemed.add(rewardId);

  @override
  Future<void> request(String dynamicId, String rewardId, {String? note, String? idempotencyKey}) async =>
      requested.add((rewardId, note));

  @override
  Future<List<RedemptionView>> redemptions(String dynamicId, {String? status}) async => redemptionList;

  @override
  Future<void> decide(
    String dynamicId,
    String redemptionId, {
    required bool approve,
    String? note,
    int? costOverride,
    String? idempotencyKey,
  }) async =>
      decisions.add((redemptionId, approve, note, costOverride));

  @override
  Future<void> fulfill(String dynamicId, String redemptionId, {String? idempotencyKey}) async =>
      fulfilled.add(redemptionId);

  @override
  Future<List<PointsRule>> pointsRules(String dynamicId) async => rules;

  @override
  Future<List<ConsequenceAgreement>> agreements(String dynamicId) async => agreementList;

  @override
  Future<void> addAgreement(String dynamicId, {required String label, required String consequence, int? pointCost}) async =>
      addedAgreements.add((label, consequence));

  @override
  Future<void> endAgreement(String dynamicId, String agreementId) async => endedAgreements.add(agreementId);

  @override
  dynamic noSuchMethod(Invocation i) => throw UnimplementedError('${i.memberName}');
}

class FakeConsequenceRepository implements ConsequenceRepository {
  FakeConsequenceRepository({List<ConsequenceView> items = const []}) : items = List.of(items);
  List<ConsequenceView> items;
  final doneIds = <String>[];
  final confirmedIds = <String>[];
  final waivedIds = <String>[];

  ConsequenceView _find(String id) => items.firstWhere((c) => c.id == id);

  @override
  Future<List<ConsequenceView>> list(String dynamicId, {String? status}) async => items;

  @override
  Future<ConsequenceView> done(String consequenceId, {required String idempotencyKey}) async {
    doneIds.add(consequenceId);
    return _find(consequenceId).copyWith(status: 'done_by_s');
  }

  @override
  Future<ConsequenceView> confirm(String consequenceId, {required String idempotencyKey}) async {
    confirmedIds.add(consequenceId);
    return _find(consequenceId).copyWith(status: 'confirmed');
  }

  @override
  Future<ConsequenceView> waive(String consequenceId, {required String idempotencyKey}) async {
    waivedIds.add(consequenceId);
    return _find(consequenceId).copyWith(status: 'waived');
  }
}
