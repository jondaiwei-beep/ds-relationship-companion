import 'dart:async';

import 'package:ds_relationship_companion/ds_design_system.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

import 'app/locale_controller.dart';
import 'l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/data/latest.dart' as tz;

import 'app/router.dart';
import 'app/user_data_reset.dart';
import 'platform/deeplink/callback_params.dart';
import 'platform/push/background_sync.dart';
import 'platform/push/local_notifier.dart';
import 'platform/push/notification_sync.dart';
import 'platform/push/sync_store.dart';
import 'platform/session/session_controller.dart';
import 'platform/time/device_timezone.dart';
import 'features/device_lock/presentation/lock_screen.dart';

/// The product entry point.
///
/// Point it at a backend with `--dart-define`; the defaults are local:
///
/// ```
/// flutter build apk --release \
///   --dart-define=API_BASE_URL=https://ds-api.beforeweplay.com \
///   --dart-define=WEB_BASE_URL=https://ds-staging.beforeweplay.com
/// ```
Future<void> main() async {
  // The plugin that reads the device zone speaks over a platform channel, so
  // the bindings have to exist before it is called.
  WidgetsFlutterBinding.ensureInitialized();

  // REQ-TIME-001: due times are rendered in the Dynamic's zone, not the
  // device's. The bundled database loads synchronously and works on both Web
  // and Android.
  tz.initializeTimeZones();

  // Resolve the device's own zone before the first frame. Activation needs it
  // synchronously and will not invent one, so a screen asking before this
  // completes would see null and dead-end.
  await primeDeviceTimezone();

  // And the link this launch came from, if any. Android only reports it
  // asynchronously, while the screen that consumes it asks during build.
  await CallbackParams.prime();

  // Device notifications: the tray plugin, and on Android a periodic fetch
  // that runs while the app is closed. No push service is involved.
  if (!kIsWeb) {
    await registerBackgroundNotificationSync();
  }

  runApp(const ProviderScope(child: CompanionApp()));
}

class CompanionApp extends ConsumerStatefulWidget {
  const CompanionApp({super.key});

  @override
  ConsumerState<CompanionApp> createState() => _CompanionAppState();
}

class _CompanionAppState extends ConsumerState<CompanionApp> {
  @override
  void initState() {
    super.initState();
    // Restore before the first frame that could show protected content. Until
    // this resolves the session is `SessionUnknown` and the router's guard
    // holds the door rather than guessing.
    final session = ref.read(sessionProvider.notifier);
    // One phone, two people: whatever the last person loaded is forgotten
    // the moment the identity changes.
    watchIdentityForReset(ref);
    // A device picked up hours later still says Authenticated while its
    // access token has quietly expired; the scheduled refresh does not fire
    // while the process is suspended.
    session.watchLifecycle();
    session.restore();

    // Links that arrive while the app is already running. A cold-start read
    // alone misses the common case: tapping an invite while the app sits in
    // the background hands the URI to the live process.
    _links = CallbackParams.incoming().listen(_open);

    // The background fetch stands down while the app is on screen; the bell
    // is polling then, and two isolates must not refresh one session.
    _foreground = AppLifecycleListener(
      onResume: () => _syncStore.setForeground(true),
      onInactive: () => _syncStore.setForeground(false),
      onHide: () => _syncStore.setForeground(false),
    );
    _syncStore.setForeground(true);

    final notifier = ref.read(localNotifierProvider);
    notifier.init().then((_) => notifier.requestPermission());
    _tray = notifier.opened.listen(_openFromTray);
  }

  StreamSubscription<Uri>? _links;
  StreamSubscription<String>? _tray;
  AppLifecycleListener? _foreground;
  final _syncStore = NotificationSyncStore();

  void _openFromTray(String payload) {
    final parsed = parseTrayPayload(payload);
    if (parsed == null) return;
    ref.read(routerProvider).go(routeForDeepLink(parsed.$2, parsed.$1));
  }

  /// Route an incoming link the way the browser would route the same URL.
  ///
  /// The path is the contract — `/invite/<token>` and `/auth/callback` — so
  /// this hands go_router the path and lets the guard decide, rather than
  /// deciding here what a signed-out person may see.
  void _open(Uri uri) {
    // Before navigating: the callback screen reads the token synchronously,
    // and go_router drops the fragment the token travels in.
    CallbackParams.remember(uri);
    final path = uri.fragment.isEmpty
        ? uri.path
        : '${uri.path}#${uri.fragment}';
    if (path.isEmpty) return;
    ref.read(routerProvider).go(path);
  }

  @override
  void dispose() {
    _links?.cancel();
    _tray?.cancel();
    _foreground?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Companion',
      debugShowCheckedModeBanner: false,
      theme: DsTheme.ritual(),
      // A chosen language wins; otherwise the phone decides. Null while the
      // stored choice is still being read, which is also what MaterialApp
      // wants for "follow the device" — so the first frame is never wrong,
      // it just starts out following the phone.
      //
      // This product's vocabulary is its meaning: a person reading
      // "expectation" or "acknowledgement" in a second language is guessing
      // at the product rather than using it, which is why the choice exists
      // at all.
      locale: switch (ref.watch(localeProvider)) {
        AsyncData(:final value) => value,
        _ => null,
      },
      localizationsDelegates: L.localizationsDelegates,
      supportedLocales: L.supportedLocales,
      routerConfig: ref.watch(routerProvider),
      // The device lock stands in front of every route, including the entrance.
      builder: (context, child) => DeviceLockShell(child: child ?? const SizedBox.shrink()),
    );
  }
}
