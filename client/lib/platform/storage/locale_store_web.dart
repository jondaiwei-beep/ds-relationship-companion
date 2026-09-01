import 'package:web/web.dart' as web;

import 'locale_store.dart';

/// Web: `localStorage`, so the choice survives a reload and a new tab.
///
/// `sessionStorage` would lose it on the refresh that Web sign-in already
/// makes people do, which is exactly when a person would notice the language
/// reverting under them.
class LocaleStoreImpl implements LocaleStore {
  @override
  Future<String?> load() async {
    try {
      return web.window.localStorage.getItem(localeStorageKey);
    } on Object {
      // Private browsing and some embedded webviews throw on access rather
      // than returning null. The device language is the right fallback.
      return null;
    }
  }

  @override
  Future<void> save(String? tag) async {
    try {
      if (tag == null) {
        web.window.localStorage.removeItem(localeStorageKey);
      } else {
        web.window.localStorage.setItem(localeStorageKey, tag);
      }
    } on Object {
      // Applies to this session regardless; only persistence is lost.
    }
  }
}
