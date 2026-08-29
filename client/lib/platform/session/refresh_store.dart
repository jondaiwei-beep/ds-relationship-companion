import 'refresh_store_io.dart'
    if (dart.library.js_interop) 'refresh_store_web.dart';

/// Where the long-lived refresh credential lives between app launches.
///
/// The platform difference is not a detail to smooth over — it decides who
/// holds the credential:
///
/// - **Web**: the server sets `__Host-refresh` as an httpOnly cookie. This
///   client cannot read it, and must not try to keep a second copy. Every
///   method here is a no-op on Web; the browser is the store.
/// - **Android**: the token arrives in the response body and nothing else
///   will remember it. Without persistence, closing the app signs the person
///   out, which for a companion opened in spare minutes is the difference
///   between a habit and an obstacle.
///
/// The access token is never stored by either — it lives in memory only.
abstract interface class RefreshStore {
  Future<String?> read();
  Future<void> write(String token);
  Future<void> clear();

  factory RefreshStore() = RefreshStoreImpl;
}
