import '../api_client.dart';
import '../models/today_view.dart';

class TodayRepository {
  TodayRepository(this._api);

  final ApiClient _api;

  /// Server decides what belongs on Today and in what order (Journey B).
  Future<TodayView> forDynamic(String dynamicId) async =>
      TodayView.fromJson(await _api.get('/v1/dynamics/$dynamicId/today'));
}
