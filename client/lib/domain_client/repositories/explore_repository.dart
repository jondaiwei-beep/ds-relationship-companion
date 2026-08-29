import '../api_client.dart';
import '../models/explore_view.dart';

class ExploreRepository {
  ExploreRepository(this._api);

  final ApiClient _api;

  /// The reviewed library. Identical for everyone and carries nothing
  /// private, so it is readable before a partner exists — which is the
  /// point: a person has to be able to judge the product's taste before
  /// deciding to share it with someone they know.
  Future<ExploreLibraryView> library() async =>
      ExploreLibraryView.fromJson(await _api.get('/v1/explore'));
}
