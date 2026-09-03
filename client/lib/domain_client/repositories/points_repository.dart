import '../api_client.dart';
import '../models/points.dart';
import '../models/redemption.dart';

class PointsRepository {
  PointsRepository(this._api);

  final ApiClient _api;

  Future<PointsSummary> summary(String dynamicId, {String? subjectUserId}) async {
    final q = subjectUserId == null ? '' : '?subjectUserId=$subjectUserId';
    return PointsSummary.fromJson(
      await _api.get('/v1/dynamics/$dynamicId/points$q'),
    );
  }

  /// A deduction takes what is there and no more; the server floors at zero.
  Future<void> adjust(
    String dynamicId, {
    required String subjectUserId,
    required int amount,
    String? note,
  }) =>
      _api.post(
        '/v1/dynamics/$dynamicId/points',
        body: {'subjectUserId': subjectUserId, 'amount': amount, 'note': note},
      );

  Future<List<Reward>> rewards(String dynamicId, {String? subjectUserId}) async {
    final q = subjectUserId == null ? '' : '?subjectUserId=$subjectUserId';
    final r = await _api.get('/v1/dynamics/$dynamicId/rewards$q');
    return ((r['rewards'] as List?) ?? const [])
        .cast<Map<String, dynamic>>()
        .map(Reward.fromJson)
        .toList(growable: false);
  }

  /// Null [cost] is「D 决定」— priced when the D approves.
  Future<void> addReward(
    String dynamicId, {
    required String title,
    String? detail,
    int? cost,
  }) =>
      _api.post(
        '/v1/dynamics/$dynamicId/rewards',
        body: {'title': title, 'detail': detail, 'cost': cost},
      );

  Future<void> retireReward(String dynamicId, String rewardId) =>
      _api.delete('/v1/dynamics/$dynamicId/rewards/$rewardId');

  /// Spend points on it at once. Only a free reward goes this way; anything
  /// with a price is asked for and the D decides.
  Future<void> redeem(String dynamicId, String rewardId, {String? idempotencyKey}) =>
      _api.post('/v1/dynamics/$dynamicId/rewards/$rewardId/redeem', idempotencyKey: idempotencyKey);

  /// s asks. Nothing moves until the D decides.
  Future<void> request(String dynamicId, String rewardId, {String? note, String? idempotencyKey}) =>
      _api.post(
        '/v1/dynamics/$dynamicId/rewards/$rewardId/request',
        body: {'note': note},
        idempotencyKey: idempotencyKey,
      );

  Future<List<RedemptionView>> redemptions(String dynamicId, {String? status}) async {
    final q = status == null ? '' : '?status=$status';
    final r = await _api.get('/v1/dynamics/$dynamicId/redemptions$q');
    return ((r['redemptions'] as List?) ?? const [])
        .cast<Map<String, dynamic>>()
        .map(RedemptionView.fromJson)
        .toList(growable: false);
  }

  /// D decides. [costOverride] is required by the server for a「D 决定」
  /// reward and ignored otherwise.
  Future<void> decide(
    String dynamicId,
    String redemptionId, {
    required bool approve,
    String? note,
    int? costOverride,
    String? idempotencyKey,
  }) =>
      _api.post(
        '/v1/dynamics/$dynamicId/redemptions/$redemptionId/decide',
        body: {'approve': approve, 'note': note, 'costOverride': costOverride},
        idempotencyKey: idempotencyKey,
      );

  /// Either side says it was handed over.
  Future<void> fulfill(String dynamicId, String redemptionId, {String? idempotencyKey}) =>
      _api.post('/v1/dynamics/$dynamicId/redemptions/$redemptionId/fulfill', idempotencyKey: idempotencyKey);

  Future<List<PointsRule>> pointsRules(String dynamicId) async {
    final r = await _api.get('/v1/dynamics/$dynamicId/points/rules');
    return ((r['rules'] as List?) ?? const [])
        .cast<Map<String, dynamic>>()
        .map(PointsRule.fromJson)
        .toList(growable: false);
  }

  /// Give it outright — no cost to them, no balance check. The warm half.
  Future<void> gift(
    String dynamicId,
    String rewardId, {
    required String subjectUserId,
  }) =>
      _api.post(
        '/v1/dynamics/$dynamicId/rewards/$rewardId/gift',
        body: {'subjectUserId': subjectUserId},
      );

  Future<List<ConsequenceAgreement>> agreements(String dynamicId) async {
    final r = await _api.get('/v1/dynamics/$dynamicId/agreements');
    return ((r['agreements'] as List?) ?? const [])
        .cast<Map<String, dynamic>>()
        .map(ConsequenceAgreement.fromJson)
        .toList(growable: false);
  }

  Future<void> addAgreement(
    String dynamicId, {
    required String label,
    required String consequence,
    int pointCost = 0,
  }) =>
      _api.post(
        '/v1/dynamics/$dynamicId/agreements',
        body: {
          'label': label,
          'consequence': consequence,
          'pointCost': pointCost,
        },
      );

  Future<void> endAgreement(String dynamicId, String agreementId) =>
      _api.delete('/v1/dynamics/$dynamicId/agreements/$agreementId');
}
