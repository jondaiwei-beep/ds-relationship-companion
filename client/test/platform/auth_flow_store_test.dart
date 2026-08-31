import 'dart:async';

import 'package:dsapp/domain_client/repositories/auth_repository.dart';
import 'package:dsapp/platform/storage/auth_flow_store.dart';
import 'package:dsapp/platform/storage/auth_flow_store_io.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

/// The Android store was a plain in-memory Map, justified by "the app process
/// survives the round trip". Completing a magic link means leaving for a mail
/// app, and Android kills a backgrounded process whenever it wants the memory
/// — taking the flow, and the person's ability to finish signing in, with it.
class _FakeKeystore extends FlutterSecureStorage {
  _FakeKeystore({this.refuse = false, this.stall = false});

  final bool refuse;

  /// A Keystore that accepts the call and never answers. Not hypothetical:
  /// this is what a widget test hit, and there it looked like a sign-in
  /// screen that spins forever.
  final bool stall;
  final Map<String, String> entries = {};

  @override
  Future<void> write({
    required String key,
    required String? value,
    // ignore: strict_raw_type
    dynamic iOptions,
    dynamic aOptions,
    dynamic lOptions,
    dynamic webOptions,
    dynamic mOptions,
    dynamic wOptions,
  }) async {
    if (refuse) throw StateError('keystore unavailable');
    if (stall) return Completer<void>().future;
    if (value != null) entries[key] = value;
  }

  @override
  Future<String?> read({
    required String key,
    dynamic iOptions,
    dynamic aOptions,
    dynamic lOptions,
    dynamic webOptions,
    dynamic mOptions,
    dynamic wOptions,
  }) async {
    if (refuse) throw StateError('keystore unavailable');
    if (stall) return Completer<String?>().future;
    return entries[key];
  }

  @override
  Future<void> delete({
    required String key,
    dynamic iOptions,
    dynamic aOptions,
    dynamic lOptions,
    dynamic webOptions,
    dynamic mOptions,
    dynamic wOptions,
  }) async {
    entries.remove(key);
  }
}

AuthFlow _flow() =>
    AuthFlow(flowId: 'f-1', verifier: 'v-secret', returnTo: '/invite/tok');

void main() {
  test('a flow outlives the process that saved it', () async {
    final keystore = _FakeKeystore();
    await AuthFlowStoreImpl(storage: keystore).save(_flow());

    // A different instance is what a restarted process gets.
    final loaded = await AuthFlowStoreImpl(storage: keystore).load('f-1');

    expect(loaded, isNotNull);
    expect(loaded!.verifier, 'v-secret');
    expect(loaded.returnTo, '/invite/tok');
  });

  test('consuming it removes it', () async {
    final keystore = _FakeKeystore();
    final store = AuthFlowStoreImpl(storage: keystore);
    await store.save(_flow());

    await store.clear('f-1');

    expect(await store.load('f-1'), isNull);
    expect(keystore.entries, isEmpty);
  });

  test('an unknown flow is absent, not an error', () async {
    final store = AuthFlowStoreImpl(storage: _FakeKeystore());

    expect(await store.load('never-saved'), isNull);
  });

  test('a refusing keystore still completes the ordinary round trip',
      () async {
    // Some devices will not accept a Keystore write at all. Losing sign-in
    // entirely there is worse than holding the flow in memory, which is what
    // every device did until now anyway.
    final store = AuthFlowStoreImpl(storage: _FakeKeystore(refuse: true));
    await store.save(_flow());

    final loaded = await store.load('f-1');
    expect(loaded?.verifier, 'v-secret');

    await store.clear('f-1');
    expect(await store.load('f-1'), isNull);
  });

  test('a stalled keystore gives up rather than hanging sign-in', () async {
    // The failure mode this replaces was not an error: it was silence. A
    // person tapping "Send sign-in link" watched a spinner with nothing to
    // tap and no way to know it would never finish.
    final store = AuthFlowStoreImpl(storage: _FakeKeystore(stall: true));

    await store.save(_flow()).timeout(
          const Duration(seconds: 10),
          onTimeout: () => fail('save never returned'),
        );
    final loaded = await store.load('f-1').timeout(
          const Duration(seconds: 10),
          onTimeout: () => fail('load never returned'),
        );

    // And the flow survived in memory, so the ordinary round trip still works.
    expect(loaded?.verifier, 'v-secret');
  });

  test('the contract is the same object either way', () {
    // Nothing outside this file may care which platform it is on.
    expect(AuthFlowStoreImpl(storage: _FakeKeystore()), isA<AuthFlowStore>());
  });
}
