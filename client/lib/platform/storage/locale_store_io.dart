import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'locale_store.dart';

/// Android, iOS and desktop.
///
/// Uses the secure storage the app already depends on rather than adding a
/// package for one string. A language tag does not need protecting, so this is
/// a heavier store than the value warrants — but a new dependency for
/// `en`/`zh` is the worse trade, and the read happens once at startup.
class LocaleStoreImpl implements LocaleStore {
  LocaleStoreImpl({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  @override
  Future<String?> load() async {
    try {
      return await _storage.read(key: localeStorageKey);
    } on Object {
      // A language preference is never worth failing to start over. Falling
      // back to the device language is the same as never having chosen.
      return null;
    }
  }

  @override
  Future<void> save(String? tag) async {
    try {
      if (tag == null) {
        await _storage.delete(key: localeStorageKey);
      } else {
        await _storage.write(key: localeStorageKey, value: tag);
      }
    } on Object {
      // The choice still applies to this session; it just will not survive a
      // restart. Better than an error dialog about a language setting.
    }
  }
}
