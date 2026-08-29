import 'refresh_store.dart';

/// Web: the browser already holds the refresh credential, in an httpOnly
/// `__Host-refresh` cookie this code cannot read.
///
/// Every method is intentionally a no-op. Keeping a second copy in
/// `localStorage` would take a credential the browser deliberately hides from
/// script and hand it to any XSS on the origin — strictly worse than the
/// cookie the server already set.
class RefreshStoreImpl implements RefreshStore {
  @override
  Future<String?> read() async => null;

  /// True because there is nothing to do and nothing failed: the browser is
  /// already holding the credential in a cookie this code cannot touch.
  @override
  Future<bool> write(String token) async => true;

  @override
  Future<void> clear() async {}
}
