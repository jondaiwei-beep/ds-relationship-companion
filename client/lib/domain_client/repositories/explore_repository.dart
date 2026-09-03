import '../api_client.dart';
import '../models/explore.dart';

/// Explore (product/04-explore.md): preferences, compare, idea cards, packs.
class ExploreRepository {
  ExploreRepository(this._api);

  final ApiClient _api;

  String _base(String dynamicId) => '/v1/dynamics/$dynamicId/explore';

  /// The library with only my answers on it.
  Future<List<PreferenceItem>> items(String dynamicId) async {
    final r = await _api.get('${_base(dynamicId)}/items');
    return ((r['items'] as List?) ?? const [])
        .cast<Map<String, dynamic>>()
        .map(PreferenceItem.fromJson)
        .toList(growable: false);
  }

  /// Autosaved on tap. PUT: answering twice lands the same answer.
  Future<PreferenceItem> answer(String dynamicId, String itemId, String answer) async =>
      PreferenceItem.fromJson(
        await _api.put('${_base(dynamicId)}/items/$itemId/answer', body: {'answer': answer}),
      );

  Future<PreferenceItem> addCustom(
    String dynamicId, {
    required String group,
    required String title,
    String? detail,
    required String idempotencyKey,
  }) async =>
      PreferenceItem.fromJson(await _api.post(
        '${_base(dynamicId)}/items',
        body: {'group': group, 'title': title, 'detail': detail},
        idempotencyKey: idempotencyKey,
      ));

  /// Only items both answered. 「不要」 arrives with no one attached.
  Future<CompareView> compare(String dynamicId) async =>
      CompareView.fromJson(await _api.get('${_base(dynamicId)}/compare'));

  Future<List<IdeaCard>> cards(String dynamicId, {String? audience}) async {
    final q = audience == null ? '' : '?audience=$audience';
    final r = await _api.get('${_base(dynamicId)}/cards$q');
    return ((r['cards'] as List?) ?? const [])
        .cast<Map<String, dynamic>>()
        .map(IdeaCard.fromJson)
        .toList(growable: false);
  }

  /// 「今晚要什么？」— D only. Drawing tells the s nothing.
  Future<IdeaCard> draw(String dynamicId, {required String idempotencyKey}) async =>
      IdeaCard.fromJson(await _api.post('${_base(dynamicId)}/cards/draw', idempotencyKey: idempotencyKey));

  Future<IdeaCardActResult> act(
    String dynamicId,
    String cardId,
    String action, {
    required String idempotencyKey,
  }) async =>
      IdeaCardActResult.fromJson(await _api.post(
        '${_base(dynamicId)}/cards/$cardId/act',
        body: {'action': action},
        idempotencyKey: idempotencyKey,
      ));

  Future<List<StarterPack>> packs() async {
    final r = await _api.get('/v1/explore/packs');
    return ((r['packs'] as List?) ?? const [])
        .cast<Map<String, dynamic>>()
        .map(StarterPack.fromJson)
        .toList(growable: false);
  }

  /// Creates exactly the lines in [draft] — what the person kept, as edited.
  Future<PackApplyResult> applyPack(
    String dynamicId,
    String packId,
    PackDraft draft, {
    required String idempotencyKey,
  }) async =>
      PackApplyResult.fromJson(await _api.post(
        '${_base(dynamicId)}/packs/$packId/apply',
        body: draft.toJson(),
        idempotencyKey: idempotencyKey,
      ));
}
