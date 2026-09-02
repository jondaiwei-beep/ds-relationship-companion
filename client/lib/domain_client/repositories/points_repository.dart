import '../api_client.dart';
import '../models/points.dart';

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

  Future<void> addReward(
    String dynamicId, {
    required String title,
    String? detail,
    required int cost,
  }) =>
      _api.post(
        '/v1/dynamics/$dynamicId/rewards',
        body: {'title': title, 'detail': detail, 'cost': cost},
      );

  Future<void> retireReward(String dynamicId, String rewardId) =>
      _api.delete('/v1/dynamics/$dynamicId/rewards/$rewardId');

  /// Spend points on it.
  Future<void> redeem(String dynamicId, String rewardId) =>
      _api.post('/v1/dynamics/$dynamicId/rewards/$rewardId/redeem');

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

  /// Issue or waive. The issuer is always the caller — there is no field for
  /// claiming it came from someone else.
  Future<void> issueConsequence(
    String dynamicId, {
    required String subjectUserId,
    String? agreementId,
    String? occurrenceId,
    required bool waived,
    String? note,
    /// Let chance pick WHICH agreed consequence. Never whether.
    bool byChance = false,
  }) =>
      _api.post(
        '/v1/dynamics/$dynamicId/consequences',
        body: {
          'subjectUserId': subjectUserId,
          'agreementId': agreementId,
          'occurrenceId': occurrenceId,
          'waived': waived,
          'note': note,
          'byChance': byChance,
        },
      );
}
