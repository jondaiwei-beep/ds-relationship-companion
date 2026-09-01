import 'locale_store_io.dart'
    if (dart.library.js_interop) 'locale_store_web.dart';

/// Remembers the language a person chose, if they chose one.
///
/// Deliberately not in secure storage, unlike the auth flow beside it: a
/// language preference is not a secret, and putting it behind the keystore
/// would mean a slow read on the one path that has to finish before the first
/// frame can be drawn.
///
/// Null means "follow the phone", which is the default and a real answer
/// rather than an absent one — someone who has never opened this setting and
/// someone who has explicitly chosen to follow their phone want the same
/// behaviour, including when they later change their phone's language.
abstract interface class LocaleStore {
  /// The saved language tag (`en`, `zh`), or null to follow the device.
  Future<String?> load();

  /// A null [tag] clears the choice and returns to following the device.
  Future<void> save(String? tag);

  factory LocaleStore() = LocaleStoreImpl;
}

/// The key both adapters agree on.
const localeStorageKey = 'app.locale';
