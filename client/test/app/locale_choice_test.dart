
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dsapp/app/locale_controller.dart';
import 'package:dsapp/l10n/app_localizations.dart';
import 'package:dsapp/platform/storage/locale_store.dart';

class _MemoryStore implements LocaleStore {
  _MemoryStore([this.tag]);

  String? tag;
  int writes = 0;

  @override
  Future<String?> load() async => tag;

  @override
  Future<void> save(String? value) async {
    writes++;
    tag = value;
  }
}

/// A store that cannot write, standing in for a locked keystore or a browser
/// with site data disabled.
class _FailingStore implements LocaleStore {
  @override
  Future<String?> load() async => null;

  @override
  Future<void> save(String? value) async => throw Exception('no storage');
}

Future<ProviderContainer> _pump(
  WidgetTester tester,
  LocaleStore store, {
  Locale deviceLocale = const Locale('en'),
}) async {
  final container = ProviderContainer(
    overrides: [localeStoreProvider.overrideWithValue(store)],
  );
  addTearDown(container.dispose);

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: Consumer(
        builder: (context, ref, _) => MaterialApp(
          locale: switch (ref.watch(localeProvider)) {
            AsyncData(:final value) => value,
            _ => null,
          },
          localizationsDelegates: L.localizationsDelegates,
          supportedLocales: L.supportedLocales,
          home: Builder(
            // The device language, as MaterialApp resolves it when `locale`
            // is null.
            builder: (context) => Text(L.of(context).navToday),
          ),
        ),
      ),
    ),
  );
  tester.platformDispatcher.localesTestValue = [deviceLocale];
  await tester.pumpAndSettle();
  return container;
}

void main() {
  testWidgets('with no choice saved, the phone decides', (tester) async {
    // Following the device is the default and stays a distinct answer from
    // picking English: someone following their phone should keep following it
    // when they change their phone's language.
    await _pump(tester, _MemoryStore(), deviceLocale: const Locale('zh'));
    expect(find.text('今天'), findsOneWidget);
  });

  testWidgets('a saved choice wins over the phone', (tester) async {
    await _pump(
      tester,
      _MemoryStore('en'),
      deviceLocale: const Locale('zh'),
    );
    expect(find.text('Today'), findsOneWidget);
    expect(find.text('今天'), findsNothing);
  });

  testWidgets('choosing changes the language on the tap', (tester) async {
    // Not after a round trip to storage: the screen you are looking at should
    // change immediately, and the write is what happens afterwards.
    final store = _MemoryStore();
    final container = await _pump(tester, store);
    expect(find.text('Today'), findsOneWidget);

    await container.read(localeProvider.notifier).choose(const Locale('zh'));
    await tester.pumpAndSettle();

    expect(find.text('今天'), findsOneWidget);
    expect(store.tag, 'zh', reason: 'and it is remembered');
  });

  testWidgets('going back to following the phone clears the choice', (
    tester,
  ) async {
    final store = _MemoryStore('en');
    final container = await _pump(
      tester,
      store,
      deviceLocale: const Locale('zh'),
    );
    expect(find.text('Today'), findsOneWidget);

    await container.read(localeProvider.notifier).choose(null);
    await tester.pumpAndSettle();

    expect(find.text('今天'), findsOneWidget, reason: 'the phone decides again');
    expect(store.tag, isNull, reason: 'null is stored as "no choice"');
  });

  testWidgets('a language choice never fails loudly', (tester) async {
    // Storage can refuse — a locked keystore, private browsing. The choice
    // still applies to this session; only persistence is lost. An error
    // dialog about a language setting would be worse than forgetting it.
    final container = await _pump(tester, _FailingStore());

    await container.read(localeProvider.notifier).choose(const Locale('zh'));
    await tester.pumpAndSettle();

    expect(find.text('今天'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
