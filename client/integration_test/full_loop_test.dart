import 'package:dsapp/app/shell/ds_primary_button.dart';
import 'package:dsapp/features/today/presentation/widgets/d_needs_me_row.dart';
import 'package:dsapp/features/today/presentation/widgets/word_button.dart';
import 'package:dsapp/l10n/app_localizations.dart';
import 'package:dsapp/main.dart' as app;
import 'package:dsapp/platform/session/session_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:integration_test/integration_test.dart';

/// The whole core loop, on a real device runtime, against the real server,
/// with two people taking turns on one device.
///
/// D registers, makes a Dynamic, gets an invitation. s registers and joins
/// through it. D applies a starter pack and adds a task; s delivers it; D
/// praises; both read the record, the points and the inbox; D sets a safeword.
///
///   flutter test integration_test/full_loop_test.dart -d `<simulator id>` \
///     --dart-define=API_BASE_URL=https://ds-api.beforeweplay.com \
///     --dart-define=WEB_BASE_URL=https://ds-staging.beforeweplay.com
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('two people run the core loop end to end', (tester) async {
    app.main();
    await tester.pumpAndSettle(const Duration(seconds: 5));

    // A previous run leaves a refresh token behind; start signed out.
    final container = ProviderScope.containerOf(
      tester.element(find.byType(MaterialApp)),
      listen: false,
    );
    await container.read(refreshStoreProvider).clear();
    await container.read(sessionProvider.notifier).signOut();
    await tester.pumpAndSettle(const Duration(seconds: 3));

    final ts = DateTime.now().millisecondsSinceEpoch;
    final dEmail = 'loop+$ts-d@example.com';
    final sEmail = 'loop+$ts-s@example.com';
    const password = 'Str0ng!Passw0rd';
    final checkTask = 'loop-check-$ts';
    final textTask = 'loop-text-$ts';
    final dayComment = 'loop-comment-$ts';
    final safeword = 'loop-safe-$ts';
    final t = _Driver(tester);

    // ── 1. D: register, create a Dynamic, read the invitation ──────────────
    await t.register(dEmail, password);
    await t.wizardToInvite();
    final code = await t.readInviteCode();
    await t.tapKey('invite-back');
    await t.waitForText(t.l.todayWaitingPartner);
    await t.signOut();

    // ── 2. s: register, join with the code, land on 今天 ──────────────────
    await t.register(sEmail, password);
    await t.waitForText(t.l.activationGoalQuestion);
    // The only way in is the private link; opening one is this navigation.
    t.router.go('/invite/$code');
    await t.tapText(t.l.joinReviewAndJoin, timeout: const Duration(seconds: 30));
    await t.waitForText(t.l.todayTitle, timeout: const Duration(seconds: 30));
    await t.waitForGone(find.text(t.l.todayWaitingPartner), reason: 's has joined; nobody is waited for');
    await t.signOut();

    // ── 3. D: starter pack, then a task of their own ───────────────────────
    await t.signIn(dEmail, password);
    await t.waitForText(t.l.todayTitle, timeout: const Duration(seconds: 30));
    await t.waitForGone(find.text(t.l.todayWaitingPartner), reason: 'the partner joined; D no longer waits');
    await t.tapKey('nav-rules');
    await t.waitForText(t.l.rulesTitle);
    await t.tapText(t.l.rulesExploreStarter);
    await t.waitForText(t.l.explorePacksIntro);
    await t.tapFirstKeyPrefix('pack-');
    await t.tapText(t.l.explorePackApply, timeout: const Duration(seconds: 15));
    await t.waitForText(t.l.rulesTitle, timeout: const Duration(seconds: 30));
    await t.waitForKeyPrefix('task-', reason: 'the pack made tasks');
    await t.waitForKeyPrefix('rule-', reason: 'the pack made rules');

    // A daily check task worth 5 points.
    await t.addTask(title: checkTask, points: '5');
    await t.waitForText(checkTask, reason: 'the new task is listed');
    // A daily text-proof task, so the required-note path is exercised.
    await t.addTask(title: textTask, points: '0', proof: t.l.rulesProofText);
    await t.waitForText(textTask);

    await t.tapKey('nav-today');
    await t.waitForText(t.l.dTodaySectionNeedsMe);
    await t.waitForText(t.l.dTodayEmpty, reason: 'nothing to dispose yet');
    await t.signOut();

    // ── 4. s: deliver ──────────────────────────────────────────────────────
    await t.signIn(sEmail, password);
    await t.waitForText(t.l.todayTitle, timeout: const Duration(seconds: 30));
    expect(await t.reveal(find.text(checkTask)), isTrue, reason: "s's 今天 lists the new task");
    await t.tapText(checkTask);
    await t.waitForTemplate(t.l.sTodayDelivered(ph1), reason: 'row shows 已交付');

    await t.tapText(textTask);
    // Text proof: the line is required, send is disabled until written.
    await t.waitForKey('line-field');
    final send = tester.widget<DsPrimaryButton>(find.byKey(const ValueKey('line-send')));
    expect(send.onPressed, isNull, reason: 'a text proof needs a note');
    await t.typeInto('line-field', 'done-$ts');
    await t.tapKey('line-send');
    await t.settle();
    expect(t.findTemplate(t.l.sTodayDelivered(ph1)), findsNWidgets(2));
    await t.signOut();

    // ── 5. D: dispose, points, record, comment ─────────────────────────────
    await t.signIn(dEmail, password);
    await t.waitForText(t.l.todayTitle, timeout: const Duration(seconds: 30));
    // The title is also listed under "{name}'s day"; the row that expands is
    // the one waiting for an answer.
    final waiting = find.descendant(of: find.byType(DNeedsMeRow), matching: find.text(checkTask));
    expect(await t.reveal(waiting), isTrue, reason: 'the delivery waits for D');
    await t.tap(waiting); // expand
    await t.tapText(t.l.dTodayActionPraise);
    await t.waitForKey('line-send');
    await t.tapKey('line-send'); // note is optional
    await t.settle();
    await t.waitForTemplate(t.l.sTodayPraised(ph1), optional: true);

    await t.tapKey('nav-points');
    await t.waitForKey('points-balance');
    expect(
      tester.widget<Text>(find.byKey(const ValueKey('points-balance'))).data,
      contains('5'),
      reason: 'the praised 5-point task is credited',
    );

    await t.tapKey('nav-record');
    await t.openToday();
    expect(await t.reveal(find.textContaining(checkTask)), isTrue,
        reason: 'the day shows the delivery; on screen: ${t.onScreen()}');
    await t.waitForTemplate(t.l.recordPraised(ph1, ph2), reason: 'and the disposition');
    await t.typeInto('comment-field', dayComment);
    await t.tapWidgetText<WordButton>(t.l.todaySend);
    expect(await t.reveal(find.text(dayComment)), isTrue, reason: 'the comment is on the day');
    await t.tapKey('day-back');
    await t.tapKey('nav-today');
    await t.signOut();

    // ── 6. s: record, points, inbox ────────────────────────────────────────
    await t.signIn(sEmail, password);
    await t.waitForText(t.l.todayTitle, timeout: const Duration(seconds: 30));
    await t.tapKey('nav-record');
    await t.openToday();
    expect(await t.reveal(find.text(dayComment)), isTrue, reason: "s sees D's comment");
    await t.tapKey('day-back');
    await t.tapKey('nav-points');
    await t.waitForKey('points-balance');
    expect(
      tester.widget<Text>(find.byKey(const ValueKey('points-balance'))).data,
      contains('5'),
    );
    await t.tapKey('nav-today');
    await t.tapKey('header-notifications');
    await t.waitForText(t.l.notificationsTitle);
    // Inbox copy is generic by design (never names a task); the praise arrives as "an answer".
    expect(await t.reveal(find.text(t.l.inboxDispositionSetTitle)), isTrue, reason: 'the disposition reached the inbox');
    t.router.pop();
    await t.settle();
    await t.signOut();

    // ── 7. D: safeword ─────────────────────────────────────────────────────
    await t.signIn(dEmail, password);
    await t.waitForText(t.l.todayTitle, timeout: const Duration(seconds: 30));
    await t.tapKey('header-settings');
    await t.tapKey('setting-safeword');
    await t.waitForKey('edit-field');
    await tester.enterText(find.byKey(const ValueKey('edit-field')), safeword);
    await t.tapText(t.l.settingsEditSave);
    await t.settle(3);
    await t.waitForText(safeword, reason: 'settings shows the saved safeword');
    await t.tapKey('settings-close');
    await t.tapKey('nav-rules');
    expect(await t.reveal(find.byKey(const ValueKey('safeword'))), isTrue,
        reason: '底线 shows the safeword; on screen: ${t.onScreen()}');
    expect(
      find.descendant(of: find.byKey(const ValueKey('safeword')), matching: find.text(safeword)),
      findsOneWidget,
    );
  }, timeout: const Timeout(Duration(minutes: 25)));
}

const ph1 = '\u0001';
const ph2 = '\u0002';

class _Driver {
  _Driver(this.tester);

  final WidgetTester tester;

  L get l => L.of(tester.element(find.byType(Navigator).first));

  GoRouter get router => GoRouter.of(tester.element(find.byType(Navigator).first));

  Future<void> settle([int seconds = 2]) async {
    await tester.pump(Duration(seconds: seconds));
    await tester.pump();
  }

  List<String> onScreen() => find
      .byType(Text)
      .evaluate()
      .map((e) => (e.widget as Text).data)
      .whereType<String>()
      .where((s) => s.trim().isNotEmpty)
      .take(14)
      .toList();

  /// A [Text] matching an l10n template whose placeholders were filled with
  /// [ph1] / [ph2]; those become wildcards.
  Finder findTemplate(String template) {
    final pattern = RegExp.escape(template)
        .replaceAll(RegExp.escape(ph1), '.+')
        .replaceAll(RegExp.escape(ph2), '.+');
    final re = RegExp(pattern);
    return find.byWidgetPredicate(
      (w) => w is Text && w.data != null && re.hasMatch(w.data!),
      description: 'Text matching /$pattern/',
    );
  }

  Future<bool> waitFor(
    Finder finder, {
    Duration timeout = const Duration(seconds: 20),
    bool optional = false,
    String? reason,
  }) async {
    final end = DateTime.now().add(timeout);
    while (DateTime.now().isBefore(end)) {
      await tester.pump(const Duration(milliseconds: 400));
      if (finder.evaluate().isNotEmpty) return true;
    }
    if (optional) return false;
    fail('timed out waiting for $finder'
        '${reason == null ? '' : ' ($reason)'}; on screen: ${onScreen()}');
  }

  Future<void> waitForGone(Finder finder, {Duration timeout = const Duration(seconds: 20), String? reason}) async {
    final end = DateTime.now().add(timeout);
    while (DateTime.now().isBefore(end)) {
      await tester.pump(const Duration(milliseconds: 400));
      if (finder.evaluate().isEmpty) return;
    }
    fail('$finder is still on screen${reason == null ? '' : ' ($reason)'}; on screen: ${onScreen()}');
  }

  // Section labels render uppercased (SectionLabel), so a lookup by the ARB
  // string must accept either casing.
  Future<void> waitForText(String text, {Duration? timeout, String? reason}) => waitFor(
        find.byWidgetPredicate((w) => w is Text && (w.data == text || w.data == text.toUpperCase())),
        timeout: timeout ?? const Duration(seconds: 20),
        reason: reason,
      );

  Future<void> waitForTemplate(String template, {bool optional = false, String? reason}) =>
      waitFor(findTemplate(template), optional: optional, reason: reason);

  Future<void> waitForKey(String key, {String? reason}) =>
      waitFor(find.byKey(ValueKey(key)), reason: reason);

  Finder keyPrefix(String prefix) => find.byWidgetPredicate(
        (w) => w.key is ValueKey<String> && (w.key as ValueKey<String>).value.startsWith(prefix),
      );

  Future<void> waitForKeyPrefix(String prefix, {String? reason}) =>
      waitFor(keyPrefix(prefix), reason: reason);

  /// Bring [finder] on screen. Lists build lazily, so an item further down
  /// does not exist until the list is scrolled; drag until it does.
  Future<bool> reveal(Finder finder, {Duration timeout = const Duration(seconds: 20)}) async {
    final end = DateTime.now().add(timeout);
    var drags = 0;
    while (DateTime.now().isBefore(end)) {
      await tester.pump(const Duration(milliseconds: 300));
      if (finder.evaluate().isNotEmpty) break;
      final scrollables = find.byType(Scrollable);
      if (scrollables.evaluate().isEmpty || drags > 30) continue;
      // Down the page first; if it is not below, it may be above.
      final dy = drags < 12 ? -350.0 : 500.0;
      await tester.drag(scrollables.first, Offset(0, dy), warnIfMissed: false);
      drags++;
    }
    if (finder.evaluate().isEmpty) return false;
    try {
      await tester.ensureVisible(finder.first);
      await tester.pump(const Duration(milliseconds: 300));
    } on Object {
      // Not inside a scrollable, or already visible.
    }
    return true;
  }

  Future<void> tap(Finder finder, {Duration? timeout, bool optional = false}) async {
    final found = await reveal(finder, timeout: timeout ?? const Duration(seconds: 20));
    if (!found) {
      if (optional) return;
      fail('could not bring $finder on screen; on screen: ${onScreen()}');
    }
    await tester.tap(finder.first, warnIfMissed: false);
    await settle(1);
  }

  Future<void> tapText(String text, {Duration? timeout, bool optional = false}) =>
      tap(find.text(text), timeout: timeout, optional: optional);

  Future<void> tapKey(String key) => tap(find.byKey(ValueKey(key)));

  Future<void> tapWidgetText<W extends Widget>(String text) => tap(find.widgetWithText(W, text));

  Future<void> tapFirstKeyPrefix(String prefix) => tap(keyPrefix(prefix));

  Future<void> typeInto(String key, String text) async {
    await waitForKey(key);
    final field = find.descendant(of: find.byKey(ValueKey(key)), matching: find.byType(TextField));
    await tester.enterText(field.evaluate().isEmpty ? find.byKey(ValueKey(key)) : field, text);
    await tester.pump(const Duration(milliseconds: 300));
  }

  // ── flows ────────────────────────────────────────────────────────────────

  Future<void> register(String email, String password) async {
    await tapText(l.entranceContinue);
    await waitFor(find.byType(TextField), reason: 'the create-account screen');
    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), email);
    await tester.enterText(fields.at(1), password);
    await tester.pump();
    await tap(find.textContaining('18'));
    await tap(find.widgetWithText(DsPrimaryButton, l.entranceCreateAccount));
    await settle(3);
  }

  Future<void> signIn(String email, String password) async {
    await tapText(l.entranceHaveAccount);
    await waitFor(find.byType(TextField), reason: 'the sign-in screen');
    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), email);
    await tester.enterText(fields.at(1), password);
    await tester.pump();
    await tap(find.widgetWithText(DsPrimaryButton, l.entranceSignIn));
    await settle(3);
  }

  Future<void> signOut() async {
    await tapKey('header-settings');
    await tapKey('settings-sign-out');
    await waitForText(l.entranceContinue, timeout: const Duration(seconds: 15), reason: 'signed out to the entrance');
    await settle(1);
  }

  Future<void> wizardToInvite() async {
    await tapText(l.activationGoalCloser);
    await tap(find.widgetWithText(DsPrimaryButton, l.activationContinue));
    await tapText(l.activationRoleWithPartner);
    await tapText(l.activationRoleDominant);
    await tap(find.widgetWithText(DsPrimaryButton, l.activationContinue));
    await tap(find.widgetWithText(DsPrimaryButton, l.activationContinue));
    await tap(find.widgetWithText(DsPrimaryButton, l.activationRhythmStart));
    await waitForText(l.inviteLinkLabel, timeout: const Duration(seconds: 30), reason: 'the invitation screen');
  }

  Future<String> readInviteCode() async {
    await waitForKey('invite-code');
    final code = tester.widget<Text>(find.byKey(const ValueKey('invite-code'))).data!;
    expect(code.trim(), isNotEmpty, reason: 'the invitation shows a code');
    return code.trim();
  }

  Future<void> addTask({required String title, required String points, String? proof}) async {
    await tapText(l.rulesAddTask);
    await typeInto('task-title', title);
    if (proof != null) await tapWidgetText<WordButton>(proof);
    await typeInto('task-points', points);
    await tapKey('sheet-primary');
    await settle(3);
  }

  Future<void> openToday() async {
    // The relationship day starts at 04:00 (D-04), so before that hour the
    // day still on the record is yesterday's — a run at 01:00 that opened
    // the device's date would find an empty day.
    var now = DateTime.now();
    if (now.hour < 4) now = now.subtract(const Duration(days: 1));
    String iso(DateTime d) =>
        '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
    final today = find.byKey(ValueKey('cell-${iso(now)}'));
    final found = await waitFor(today, optional: true);
    if (found) {
      await tap(today);
    } else {
      await tap(find.byKey(ValueKey('cell-${iso(now.subtract(const Duration(days: 1)))}')));
    }
    await settle(2);
  }
}
