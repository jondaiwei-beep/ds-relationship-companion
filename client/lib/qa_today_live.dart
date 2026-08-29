// Renders SCR-01 against a running backend, so the screen can be checked
// against real server truth rather than fixtures.
//
//   flutter build web --target lib/qa_today_live.dart \
//     --dart-define=email=... --dart-define=password=... \
//     --dart-define=dynamicId=...
//
// Signs in, then hands the screen the real repositories. Nothing in the
// product imports this file.
import 'package:ds_relationship_companion/ds_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/providers.dart';
import 'features/today/presentation/today_screen.dart';

const _email = String.fromEnvironment('email');
const _password = String.fromEnvironment('password');
const _dynamicId = String.fromEnvironment('dynamicId');

void main() => runApp(const ProviderScope(child: _Live()));

class _Live extends ConsumerStatefulWidget {
  const _Live();

  @override
  ConsumerState<_Live> createState() => _LiveState();
}

class _LiveState extends ConsumerState<_Live> {
  late final Future<void> _signedIn = _signIn();

  Future<void> _signIn() async {
    final session = await ref
        .read(authRepositoryProvider)
        .signInWithPassword(email: _email, password: _password);
    ref.read(apiClientProvider).accessToken = session.accessToken;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: DsTheme.ritual(),
      home: FutureBuilder<void>(
        future: _signedIn,
        builder: (context, snapshot) => switch (snapshot.connectionState) {
          ConnectionState.done when snapshot.hasError => _Failed(
            '${snapshot.error}',
          ),
          ConnectionState.done => const TodayScreen(dynamicId: _dynamicId),
          _ => const ColoredBox(color: DsColors.canvasRitual),
        },
      ),
    );
  }
}

class _Failed extends StatelessWidget {
  const _Failed(this.message);

  final String message;

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: DsColors.canvasRitual,
    body: Center(
      child: Padding(
        padding: const EdgeInsets.all(DsSpacing.space6),
        child: Text(
          'Harness could not sign in.\n$message',
          textAlign: TextAlign.center,
          style: DsTextStyles.bodySecondary.copyWith(
            color: DsColors.textOnRitualMuted,
          ),
        ),
      ),
    ),
  );
}
