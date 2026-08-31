import 'package:ds_relationship_companion/ds_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/data/latest.dart' as tz;

import 'app/router.dart';
import 'platform/session/session_controller.dart';
import 'platform/time/device_timezone.dart';

/// The product entry point.
///
/// Point it at a backend with `--dart-define`; the defaults are local:
///
/// ```
/// flutter build apk --release \
///   --dart-define=API_BASE_URL=https://ds-api.beforeweplay.com \
///   --dart-define=WEB_BASE_URL=https://ds-staging.beforeweplay.com
/// ```
///
/// `main_preview.dart` is still the way to see every approved state of one
/// screen without a server behind it.
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
    // A device picked up hours later still says Authenticated while its
    // access token has quietly expired; the scheduled refresh does not fire
    // while the process is suspended.
    session.watchLifecycle();
    session.restore();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Companion',
      debugShowCheckedModeBanner: false,
      theme: DsTheme.ritual(),
      routerConfig: ref.watch(routerProvider),
    );
  }
}
