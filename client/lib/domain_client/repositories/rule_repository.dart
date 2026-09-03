import '../api_client.dart';
import '../models/rule.dart';

class RuleRepository {
  RuleRepository(this._api);

  final ApiClient _api;

  String _base(String dynamicId) => '/v1/dynamics/$dynamicId/rules';

  Future<List<RuleView>> list(String dynamicId, {bool includeArchived = false}) async {
    final r = await _api.get('${_base(dynamicId)}?includeArchived=$includeArchived');
    return ((r['rules'] as List?) ?? const [])
        .cast<Map<String, dynamic>>()
        .map(RuleView.fromJson)
        .toList(growable: false);
  }

  /// A D's lands `active`; an s's lands `proposed` (decision D-24).
  Future<RuleView> create(String dynamicId, NewRule rule, {required String idempotencyKey}) async =>
      RuleView.fromJson(
        await _api.post(_base(dynamicId), body: rule.toJson(), idempotencyKey: idempotencyKey),
      );

  Future<RuleView> update(String dynamicId, String ruleId, RuleEdit edit) async =>
      RuleView.fromJson(await _api.patch('${_base(dynamicId)}/$ruleId', body: edit.toJson()));

  /// D archives any rule; an s may only withdraw their own proposal.
  Future<void> archive(String dynamicId, String ruleId, {required String idempotencyKey}) =>
      _api.post('${_base(dynamicId)}/$ruleId/archive', idempotencyKey: idempotencyKey);

  Future<RuleView> accept(String dynamicId, String ruleId, {required String idempotencyKey}) async =>
      RuleView.fromJson(
        await _api.post('${_base(dynamicId)}/$ruleId/accept', idempotencyKey: idempotencyKey),
      );
}
