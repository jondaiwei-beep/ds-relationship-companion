import 'dart:convert';

import 'package:ds_relationship_companion/ds_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dsapp/l10n/app_localizations.dart';

import 'package:dsapp/app/providers.dart';
import 'package:dsapp/domain_client/models/dynamic_view.dart';
import 'package:dsapp/domain_client/models/notification_settings.dart';
import 'package:dsapp/domain_client/repositories/dynamic_repository.dart';
import 'package:dsapp/domain_client/repositories/settings_repository.dart';
import 'package:dsapp/features/settings/presentation/leave_screen.dart';
import 'package:dsapp/features/settings/presentation/settings_screen.dart';
import 'package:dsapp/platform/session/session.dart';
import 'package:dsapp/platform/session/session_controller.dart';

class _FakeSettings implements SettingsRepository {
  _FakeSettings(this.value);

  NotificationSettings value;
  int updates = 0;
  String? lastPreview;
  int? lastStart;
  int? lastEnd;

  @override
  Future<NotificationSettings> notifications() async => value;

  @override
  Future<NotificationSettings> update({
    String? notificationPreview,
    int? quietHoursStartMin,
    int? quietHoursEndMin,
  }) async {
    updates++;
    lastPreview = notificationPreview;
    lastStart = quietHoursStartMin;
    lastEnd = quietHoursEndMin;
    value = NotificationSettings(
      notificationPreview: notificationPreview ?? 'NEUTRAL',
      quietHoursStartMin: quietHoursStartMin,
      quietHoursEndMin: quietHoursEndMin,
    );
    return value;
  }

  @override
  dynamic noSuchMethod(Invocation i) => throw UnimplementedError();
}

class _FakeDynamic implements DynamicRepository {
  int leaves = 0;
  int blocks = 0;
  String? blockedUser;
  bool fail = false;

  @override
  Future<DynamicDetail> detail(String id) async => const DynamicDetail(
    dynamicId: 'dyn-1',
    state: 'ACTIVE',
    desiredOutcome: 'SERVICE',
    structureLevel: 'STEADY',
    referenceTimezone: 'Asia/Shanghai',
    dayBoundaryMinutes: 240,
    members: [
      MemberView(
        userId: 'u-creator',
        displayName: 'Alex',
        roleContext: 'CREATOR',
        accessState: 'ACTIVE',
      ),
      MemberView(
        userId: 'u-partner',
        displayName: 'Morgan',
        roleContext: 'PARTNER',
        accessState: 'ACTIVE',
      ),
    ],
  );

  @override
  Future<void> leave(
    String id, {
    String? reason,
    required String idempotencyKey,
  }) async {
    if (fail) throw Exception('network');
    leaves++;
  }

  @override
  Future<void> block(
    String id, {
    required String targetUserId,
    String? reason,
    required String idempotencyKey,
  }) async {
    blocks++;
    blockedUser = targetUserId;
  }

  @override
  dynamic noSuchMethod(Invocation i) => throw UnimplementedError();
}

String _tokenFor(String userId) {
  String seg(String s) => base64Url.encode(utf8.encode(s)).replaceAll('=', '');
  return '${seg('{"alg":"none"}')}.${seg('{"sub":"$userId"}')}.x';
}

class _FixedSession extends SessionController {
  @override
  Session build() => Authenticated(accessToken: _tokenFor('u-creator'));
}

Future<(_FakeSettings, _FakeDynamic)> _pumpSettings(
  WidgetTester tester, {
  NotificationSettings initial = const NotificationSettings(),
}) async {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  final settings = _FakeSettings(initial);
  final dynamic_ = _FakeDynamic();
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        settingsRepositoryProvider.overrideWithValue(settings),
        dynamicRepositoryProvider.overrideWithValue(dynamic_),
        sessionProvider.overrideWith(_FixedSession.new),
      ],
      child: MaterialApp(
        localizationsDelegates: L.localizationsDelegates,
        supportedLocales: L.supportedLocales,
        theme: DsTheme.ritual(),
        home: SettingsScreen(
          dynamicId: 'dyn-1',
          onSignOut: () {},
          onLeave: () {},
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return (settings, dynamic_);
}

Future<_FakeDynamic> _pumpLeave(WidgetTester tester) async {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  final repo = _FakeDynamic();
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        dynamicRepositoryProvider.overrideWithValue(repo),
        sessionProvider.overrideWith(_FixedSession.new),
      ],
      child: MaterialApp(
        localizationsDelegates: L.localizationsDelegates,
        supportedLocales: L.supportedLocales,
        theme: DsTheme.ritual(),
        home: const LeaveScreen(dynamicId: 'dyn-1'),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return repo;
}

void main() {
  group('SCR-28/29/34 settings', () {
    testWidgets('a neutral lockscreen is the default, and says why', (
      tester,
    ) async {
      await _pumpSettings(tester);
      expect(
        find.textContaining('anyone holding your phone can read them'),
        findsOneWidget,
        reason: 'the cost of RICH is stated before it is chosen',
      );
    });

    testWidgets('quiet hours travel as a pair', (tester) async {
      // Half a window would suppress nothing while looking set.
      final (settings, _) = await _pumpSettings(tester);
      // The language section sits above these now, so they start below the
      // fold; ensureVisible scrolls them fully in rather than just far enough
      // to be found.
      await tester.ensureVisible(find.text('10:00 PM — 7:00 AM'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('10:00 PM — 7:00 AM'));
      await tester.pumpAndSettle();

      expect(settings.lastStart, 22 * 60);
      expect(settings.lastEnd, 7 * 60);
    });

    testWidgets('turning quiet hours off clears both bounds', (tester) async {
      final (settings, _) = await _pumpSettings(
        tester,
        initial: const NotificationSettings(
          quietHoursStartMin: 1320,
          quietHoursEndMin: 420,
        ),
      );
      await tester.tap(find.text('Off'));
      await tester.pumpAndSettle();

      expect(settings.lastStart, isNull);
      expect(settings.lastEnd, isNull);
    });

    testWidgets('changing one setting does not clear the other', (
      tester,
    ) async {
      // The endpoint replaces the whole set, so a partial send would silently
      // turn quiet hours off while the person was changing the preview.
      final (settings, _) = await _pumpSettings(
        tester,
        initial: const NotificationSettings(
          quietHoursStartMin: 1320,
          quietHoursEndMin: 420,
        ),
      );
      await tester.tap(find.text('Show the detail'));
      await tester.pumpAndSettle();

      expect(settings.lastPreview, 'RICH');
      expect(settings.lastStart, 1320, reason: 'quiet hours survive');
      expect(settings.lastEnd, 420);
    });

    testWidgets('the shared day is stated in its own timezone', (tester) async {
      await _pumpSettings(tester);
      // The list is lazy, so the row does not exist until scrolled to — hence
      // scrollUntilVisible rather than ensureVisible, which needs the element
      // to already be built.
      await tester.scrollUntilVisible(
        find.text('Asia/Shanghai'),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('Asia/Shanghai'), findsOneWidget);
      // The clock is formatted through intl for the reader's locale, so the
      // assertion is on the sentence around it rather than a hardcoded render.
      expect(find.textContaining('day ends at 4:00'), findsOneWidget);
      // 一天从几点开始, read-only until the server can change it.
      expect(find.textContaining('The day starts at 04:00'), findsOneWidget);
      expect(
        find.textContaining('not in whichever one your phone is in'),
        findsOneWidget,
      );
    });
  });

  group('SCR-30 leaving and blocking', () {
    testWidgets('nothing happens on the first tap', (tester) async {
      // Both actions are irreversible and end the Dynamic for both people.
      final repo = await _pumpLeave(tester);
      await tester.tap(find.text('Leave'));
      await tester.pumpAndSettle();

      expect(repo.leaves, 0, reason: 'the first tap only asks');
      expect(find.text('Leave this Dynamic'), findsOneWidget);
      expect(find.textContaining('cannot be undone'), findsOneWidget);
    });

    testWidgets('confirming leaves, and never asks the partner', (
      tester,
    ) async {
      final repo = await _pumpLeave(tester);
      await tester.tap(find.text('Leave'));
      await tester.pumpAndSettle();
      expect(
        find.textContaining('is not asked to agree'),
        findsOneWidget,
      );

      await tester.tap(find.widgetWithText(InkWell, 'Leave').last);
      await tester.pumpAndSettle();
      expect(repo.leaves, 1);
    });

    testWidgets('going back from the confirmation changes nothing', (
      tester,
    ) async {
      final repo = await _pumpLeave(tester);
      await tester.tap(find.text('Block'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Go back'));
      await tester.pumpAndSettle();

      expect(repo.blocks, 0);
      expect(find.text('Ending this'), findsOneWidget);
    });

    testWidgets('blocking names the person and hides who did it', (
      tester,
    ) async {
      final repo = await _pumpLeave(tester);
      await tester.tap(find.text('Block'));
      await tester.pumpAndSettle();

      expect(find.text('Block Morgan'), findsOneWidget);
      expect(find.textContaining('not told who did it'), findsOneWidget);

      await tester.tap(find.widgetWithText(InkWell, 'Block').last);
      await tester.pumpAndSettle();
      expect(repo.blocks, 1);
      expect(repo.blockedUser, 'u-partner', reason: 'never yourself');
    });

    testWidgets('a failure says nothing changed', (tester) async {
      final repo = await _pumpLeave(tester);
      repo.fail = true;
      await tester.tap(find.text('Leave'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(InkWell, 'Leave').last);
      await tester.pumpAndSettle();

      expect(find.textContaining('Nothing has changed'), findsOneWidget);
    });
  });
}
