import '../api_client.dart';
import '../models/attention_view.dart';

class AttentionRepository {
  AttentionRepository(this._api);

  final ApiClient _api;

  /// Server decides both the contents and the ORDER (Journey C priority).
  /// The client must not re-sort by recency.
  Future<AttentionView> forDynamic(String dynamicId) async =>
      AttentionView.fromJson(await _api.get('/v1/dynamics/$dynamicId/attention'));
}
