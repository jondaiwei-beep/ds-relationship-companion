import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../platform/storage/locale_store.dart';

final localeStoreProvider = Provider<LocaleStore>((ref) => LocaleStore());

/// The language the app is showing, and whether a person chose it.
///
/// `null` means follow the device. It is the default, and it stays a distinct
/// answer from picking English or Chinese: someone following their phone
/// should keep following it when they change their phone's language, which a
/// resolved value could not express.
class LocaleController extends AsyncNotifier<Locale?> {
  @override
  Future<Locale?> build() async {
    try {
      final tag = await ref.watch(localeStoreProvider).load();
      return tag == null ? null : Locale(tag);
    } on Object {
      // Never fail to start over a language preference. Following the device
      // is the same outcome as never having chosen.
      return null;
    }
  }

  /// Choose a language, or pass null to go back to following the device.
  ///
  /// The new value is published before the write finishes: the language of the
  /// screen you are looking at should change on the tap, not after a round
  /// trip to storage that can fail.
  Future<void> choose(Locale? locale) async {
    state = AsyncData(locale);
    try {
      await ref.read(localeStoreProvider).save(locale?.languageCode);
    } on Object {
      // Storage can refuse — a locked keystore, a browser with site data
      // disabled. The choice still applies to this session; only persistence
      // is lost, and an error dialog about a language setting would be worse
      // than quietly forgetting it. The adapters swallow this too; the guard
      // is here as well so the controller is safe with any store.
    }
  }
}

final localeProvider = AsyncNotifierProvider<LocaleController, Locale?>(
  LocaleController.new,
);
