import 'package:dio/dio.dart';
import 'package:ds_relationship_companion/ds_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/app_localizations.dart';
import 'providers.dart';
import 'shell/ds_primary_button.dart';

/// Where a signed-in person actually belongs.
///
/// `/today` used to build `TodayScreen(dynamicId: 'preview')` — a literal
/// string standing in for an id nobody had yet. On a fresh account that asked
/// the server for `/v1/dynamics/preview/today`, got "Invalid UUID string:
/// preview", and showed "Today could not be loaded" to a person who had just
/// registered and done nothing wrong.
///
/// The truth is simpler than the placeholder: a new account has no Dynamic, so
/// it belongs in activation. One with a Dynamic belongs in that Dynamic's
/// Today. Only the server knows which, so this asks.
class HomeResolver extends ConsumerStatefulWidget {
  const HomeResolver({
    super.key,
    required this.onDynamic,
    required this.onNoDynamic,
    required this.onSignIn,
  });

  final void Function(String dynamicId) onDynamic;

  /// Nothing to open yet. Activation is not an error state — it is the next
  /// thing a person does.
  final VoidCallback onNoDynamic;

  final VoidCallback onSignIn;

  @override
  ConsumerState<HomeResolver> createState() => _HomeResolverState();
}

class _HomeResolverState extends ConsumerState<HomeResolver> {
  bool _resolving = true;
  bool _authorizationLost = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _resolve());
  }

  Future<void> _resolve() async {
    setState(() {
      _resolving = true;
      _authorizationLost = false;
    });

    try {
      final mine = await ref.read(dynamicRepositoryProvider).mine();
      if (!mounted) return;

      if (mine.isEmpty) {
        widget.onNoDynamic();
        return;
      }
      // The first is the one to open. Choosing between several is a Phase 2
      // screen; until it exists, opening the first beats opening none.
      widget.onDynamic(mine.first.dynamicId);
    } on Object catch (error) {
      if (!mounted) return;
      setState(() {
        _resolving = false;
        _authorizationLost = _isAuthorizationLoss(error);
      });
    }
  }

  /// Read the status, do not pattern-match the message. The first version of
  /// this asked whether `error.toString()` contained '401', which is true of
  /// any message that happens to mention the number and false for a DioError
  /// whose `toString` omits it — as the real one does.
  static bool _isAuthorizationLoss(Object error) =>
      error is DioException && error.response?.statusCode == 401;

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    return Scaffold(
      backgroundColor: DsColors.canvasRitual,
      body: DsRitualSurface(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: DsSpacing.space6),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_resolving)
                  // Nothing is claimed while the answer is unknown. No
                  // skeleton shaped like a day's expectations.
                  Text(
                    l.shellOpeningYourSpace,
                    style: DsTextStyles.bodySecondary.copyWith(
                      color: DsColors.textOnRitualMuted,
                    ),
                  )
                else ...[
                  Text(
                    _authorizationLost
                        ? l.shellSignInToContinue
                        : l.shellCouldNotOpenYourSpace,
                    textAlign: TextAlign.center,
                    style: DsTextStyles.displayRitual.copyWith(
                      color: DsColors.textOnRitualPrimary,
                    ),
                  ),
                  const SizedBox(height: DsSpacing.space6),
                  Text(
                    _authorizationLost
                        ? l.shellSessionEndedNothingLost
                        : l.shellCouldNotReachYourSpace,
                    textAlign: TextAlign.center,
                    style: DsTextStyles.bodySecondary.copyWith(
                      color: DsColors.textOnRitualSecondary,
                    ),
                  ),
                  const SizedBox(height: DsSpacing.space10),
                  DsPrimaryButton(
                    label: _authorizationLost ? l.shellSignIn : l.shellTryAgain,
                    onPressed:
                        _authorizationLost ? widget.onSignIn : _resolve,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
