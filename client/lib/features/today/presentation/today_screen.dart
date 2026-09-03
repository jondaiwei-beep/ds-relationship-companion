import 'package:dio/dio.dart';
import 'package:ds_relationship_companion/ds_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/shell/bottom_navigation.dart';
import '../../../app/shell/ds_refreshable.dart';
import '../../../app/shell/ds_skeleton.dart';
import '../../../l10n/app_localizations.dart';
import '../application/today_providers.dart';
import 'd_today_screen.dart';
import 's_today_screen.dart';
import 'widgets/recovery_scaffold.dart';
import 'widgets/secondary_button.dart';
import 'widgets/today_layout.dart';

/// Tab 1 · 今天 (product/02-surfaces.md).
///
/// One route, two faces. The server says which side the caller is on
/// (`TodayView.side`), and this widget shows the s face or the D face
/// accordingly. It owns the frame — loading, failure, pull to refresh, the
/// tab bar — so the two faces only render a loaded day.
class TodayScreen extends ConsumerWidget {
  const TodayScreen({
    super.key,
    required this.dynamicId,
    this.onSignIn,
    this.onSelectTab,
    this.onSettings,
  });

  final String dynamicId;
  final VoidCallback? onSignIn;
  final void Function(NavSurface surface)? onSelectTab;
  final VoidCallback? onSettings;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final today = ref.watch(todayProvider(dynamicId));
    void reload() => ref.invalidate(todayProvider(dynamicId));

    Future<void> refresh() async {
      final view = today.value;
      final futures = <Future<void>>[ref.refresh(todayProvider(dynamicId).future)];
      if (view?.isD ?? false) {
        futures.add(ref.refresh(needsMeProvider(dynamicId).future));
        futures.add(ref.refresh(dNotesProvider(dynamicId).future));
      }
      await Future.wait(futures);
    }

    return Scaffold(
      backgroundColor: DsColors.canvasRitual,
      body: DsRitualSurface(
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              Expanded(
                child: DsRefreshable(
                  onRefresh: refresh,
                  child: today.when(
                    skipLoadingOnReload: true,
                    skipLoadingOnRefresh: true,
                    loading: () => const TodayLoading(),
                    error: (error, _) => switch (classifyFailure(error)) {
                      TodayFailure.authorizationLost =>
                        _AuthorizationLost(onSignIn: onSignIn),
                      TodayFailure.offline => _Offline(onRetry: reload),
                      TodayFailure.unknown => _Unavailable(onRetry: reload),
                    },
                    data: (view) => view.isD
                        ? DTodayScreen(
                            view: view,
                            dynamicId: dynamicId,
                            onSettings: onSettings,
                          )
                        : STodayScreen(
                            view: view,
                            dynamicId: dynamicId,
                            onSettings: onSettings,
                          ),
                  ),
                ),
              ),
              DsBottomNavigation(current: NavSurface.today, onSelect: onSelectTab),
            ],
          ),
        ),
      ),
    );
  }
}

/// How a failed load must be presented — each is a different fact about the
/// person's access.
enum TodayFailure { offline, authorizationLost, unknown }

TodayFailure classifyFailure(Object error) {
  if (error is! DioException) return TodayFailure.unknown;
  final status = error.response?.statusCode;
  if (status == 401 || status == 403) return TodayFailure.authorizationLost;
  return switch (error.type) {
    DioExceptionType.connectionError ||
    DioExceptionType.connectionTimeout ||
    DioExceptionType.receiveTimeout ||
    DioExceptionType.sendTimeout => TodayFailure.offline,
    _ => TodayFailure.unknown,
  };
}

/// Skeleton shaped like a day, with no verdict in it.
class TodayLoading extends StatelessWidget {
  const TodayLoading({super.key});

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(20, 28, 20, 24),
          child: DsSkeletonBar(width: 96, height: 22, emphasis: true),
        ),
        // The approved state explains the blankness rather than narrating a wait.
        Padding(
          padding: todayInset,
          child: Text(
            l.todayPrivateByDefault,
            style: DsTextStyles.labelRitual.copyWith(color: DsColors.textOnRitualMuted),
          ),
        ),
        const SizedBox(height: DsSpacing.space2),
        Padding(
          padding: todayInset,
          child: Text(
            l.todayPrivateByDefaultBody,
            style: DsTextStyles.bodySecondary.copyWith(color: DsColors.textOnRitualMuted),
          ),
        ),
        const SizedBox(height: DsSpacing.space8),
        const Padding(padding: todayInset, child: DsSkeletonCard(lines: [0.8, 0.5], emphasis: true)),
        const SizedBox(height: DsSpacing.space4),
        const Padding(padding: todayInset, child: DsSkeletonCard(lines: [0.7, 0.4])),
        const SizedBox(height: DsSpacing.space4),
        const Padding(padding: todayInset, child: DsSkeletonCard(lines: [0.7, 0.4])),
      ],
    );
  }
}

class _Offline extends StatelessWidget {
  const _Offline({required this.onRetry});
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    return RecoveryScaffold(
      context_: l.recoveryOffline,
      children: [
        const SizedBox(height: DsSpacing.space8),
        RecoveryMessage(l.todayActionsPaused, prominent: true),
        const SizedBox(height: DsSpacing.space3),
        RecoveryMessage(l.todayActionsReturn),
        const SizedBox(height: DsSpacing.space6),
        Padding(
          padding: todayInset,
          child: SecondaryButton(label: l.recoveryTryToReconnect, onTap: onRetry),
        ),
      ],
    );
  }
}

class _Unavailable extends StatelessWidget {
  const _Unavailable({required this.onRetry});
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    return RecoveryScaffold(
      context_: l.recoveryNotConfirmed,
      children: [
        const SizedBox(height: DsSpacing.space8),
        RecoveryMessage(l.todayCouldNotLoad, prominent: true),
        const SizedBox(height: DsSpacing.space6),
        Padding(
          padding: todayInset,
          child: SecondaryButton(label: l.recoveryTryAgain, onTap: onRetry),
        ),
      ],
    );
  }
}

/// Every piece of protected content is removed; recovery is offered without
/// implying the relationship itself has changed.
class _AuthorizationLost extends StatelessWidget {
  const _AuthorizationLost({this.onSignIn});
  final VoidCallback? onSignIn;

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    return RecoveryScaffold(
      context_: l.recoveryConfirmingContext,
      children: [
        const SizedBox(height: DsSpacing.space16),
        const Center(
          child: DsSvg(
            asset: DsAssets.stateLocked,
            tone: DsAssetTone.primary,
            width: 44,
            height: 44,
          ),
        ),
        const SizedBox(height: DsSpacing.space8),
        RecoveryMessage(l.recoverySessionRestore, prominent: true),
        const SizedBox(height: DsSpacing.space3),
        RecoveryMessage(l.todayHiddenDetails),
        const SizedBox(height: DsSpacing.space8),
        Padding(
          padding: todayInset,
          child: SecondaryButton(
            label: l.recoverySignInAgain,
            onTap: onSignIn ?? () {},
            filled: true,
          ),
        ),
      ],
    );
  }
}
