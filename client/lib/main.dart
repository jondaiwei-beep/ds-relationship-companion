import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

import 'app/router.dart';
import 'design_system/ds_theme.dart';

void main() {
  // Path URLs (no /#/) so /invite/{token} is a real, shareable, refreshable
  // URL. Requires the host to rewrite unknown paths to index.html — see
  // ops/nginx-dsapp.conf (Notion 04 §13).
  usePathUrlStrategy();
  runApp(const ProviderScope(child: DsApp()));
}

class DsApp extends ConsumerWidget {
  const DsApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      // Notion 04 §5: the browser title must stay neutral. It appears in tab
      // lists, history and screen shares.
      title: 'Companion',
      debugShowCheckedModeBanner: false,
      routerConfig: ref.watch(routerProvider),
      theme: dsTheme(),
    );
  }
}
