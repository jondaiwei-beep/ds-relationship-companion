import 'package:dio/browser.dart';
import 'package:dio/dio.dart';

/// Web: include cookies on cross-origin API calls.
///
/// The refresh credential is an httpOnly cookie set by the API host. Browsers
/// drop cookies from cross-origin XHR unless `withCredentials` is set, and the
/// Web app is served from a different host than the API — so without this the
/// cookie is never stored, never sent to `/v1/auth/refresh` and never cleared
/// by `/v1/auth/logout`.
///
/// This requires the server to answer with an explicit
/// `Access-Control-Allow-Origin` (never `*`) and
/// `Access-Control-Allow-Credentials: true`, which it does — `allowCredentials`
/// is set in `SecurityConfig`.
void configureCredentials(Dio dio) {
  dio.httpClientAdapter = BrowserHttpClientAdapter(withCredentials: true);
}
