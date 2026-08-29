// The whole two-person loop, through the real command layers, against a
// running server.
//
//   flutter run -d chrome --target lib/qa_walking_skeleton.dart \
//     --dart-define=API_BASE_URL=http://localhost:8082
//
// Why this exists, and what it is not:
//
// Nine of the eleven screens in the vertical slice are gated, and a gate is
// the design owner's to open. But the risk in Sprint 4 is not how the invite
// screen looks — it is whether two people on two devices can actually reach
// a shared moment. That risk is answerable now, and answering it late is how
// a handshake turns out to be wrong after eleven screens are built on it.
//
// So this walks the loop end to end using the same `AuthActions`,
// `InviteActions` and repositories the screens will use, and reports each
// step. It is deliberately unstyled: it must never be mistaken for a screen,
// and nothing in the product imports it.
//
// What it proves, in order:
//   register → create a Dynamic → invite → resolve anonymously →
//   second person registers → joins → an expectation appears → completes →
//   the first person acknowledges → both see it.
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/providers.dart';
import 'domain_client/api_client.dart';
import 'domain_client/repositories/adjustment_repository.dart';
import 'features/activation/application/activation_actions.dart';
import 'features/entrance/application/auth_actions.dart';
import 'features/invite/application/invite_actions.dart';
import 'platform/session/session.dart';
import 'platform/session/session_controller.dart';

void main() => runApp(const ProviderScope(child: _Skeleton()));

/// One step of the loop, and how it went.
class Step {
  Step(this.name, {this.detail, this.ok = true});

  final String name;
  final String? detail;
  final bool ok;
}

class _Skeleton extends StatelessWidget {
  const _Skeleton();

  @override
  Widget build(BuildContext context) => const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: _Runner(),
      );
}

class _Runner extends ConsumerStatefulWidget {
  const _Runner();

  @override
  ConsumerState<_Runner> createState() => _RunnerState();
}

class _RunnerState extends ConsumerState<_Runner> {
  final _steps = <Step>[];
  bool _running = false;

  @override
  void initState() {
    super.initState();
    // Runs on load so a headless browser can read the result without having
    // to find and press anything.
    WidgetsBinding.instance.addPostFrameCallback((_) => _run());
  }

  void _log(String name, {String? detail, bool ok = true}) {
    // Also to the console: the result must be readable from a headless
    // browser without scraping a canvas.
    debugPrint('SKELETON ${ok ? "ok  " : "FAIL"} $name${detail == null ? "" : "  — $detail"}');
    setState(() => _steps.add(Step(name, detail: detail, ok: ok)));
  }

  /// Each person gets their own container, because each has their own session.
  ///
  /// Two `ProviderContainer`s is not a test convenience — it is the actual
  /// shape of the product. One device holds one session, and the whole point
  /// of this loop is that the second response comes from somebody else.
  ProviderContainer _person() => ProviderContainer(
        overrides: [
          apiClientProvider.overrideWithValue(ApiClient(baseUrl: kApiBaseUrl)),
          autoRefreshProvider.overrideWithValue(false),
        ],
      );

  Future<void> _run() async {
    setState(() {
      _steps.clear();
      _running = true;
    });

    final creator = _person();
    final partner = _person();
    final stamp = DateTime.now().millisecondsSinceEpoch;

    try {
      // ---- the person who gives direction ----
      final creatorAuth = creator.read(authActionsProvider);
      final r1 = await creatorAuth.register(
        email: 'creator-$stamp@test.local',
        password: 'a quiet evening',
        ageConfirmed: true,
      );
      if (r1 is! AuthSucceeded) {
        return _log('creator registers', detail: _describe(r1), ok: false);
      }
      _log('creator registers');

      // Through the activation layer the wizard will use, not the repository
      // underneath it: the point is that the four screens' one command works.
      const draft = ActivationDraft(
        outcome: DesiredOutcome.accountability,
        structure: StructureLevel.steady,
        timezone: 'Europe/Berlin',
        // Deliberately unnamed. A couple that declines to name a role must
        // not be blocked, and the loop has to prove that rather than assert
        // it.
      );
      final created = await creator.read(activationActionsProvider)
          .createDynamic(draft);
      if (created is! DynamicCreated) {
        return _log('creates a Dynamic',
            detail: (created as ActivationFailed).message, ok: false);
      }
      final dynamicId = created.dynamicId;
      _log('creates a Dynamic, with no role named', detail: dynamicId);

      // The outcome chooses the starter content, so this is not the same
      // suggestion every couple gets.
      final proposal = await creator.read(activationActionsProvider)
          .proposeRhythm(dynamicId);
      _log('a starting rhythm is proposed, and writes nothing',
          detail: '${proposal.ritualTitle} · ${proposal.expectationTitle}');

      final invite = await creator.read(inviteActionsProvider).create(dynamicId);
      if (invite is! InviteLinkReady) {
        return _log('creates an invitation',
            detail: invite.runtimeType.toString(), ok: false);
      }
      _log('creates an invitation', detail: invite.url);

      // One live invitation per Dynamic. A second attempt is not a failure.
      final again = await creator.read(inviteActionsProvider).create(dynamicId);
      _log('a second invitation is refused, not broken',
          detail: again.runtimeType.toString(),
          ok: again is InviteAlreadyExists);

      final token = invite.url.split('/invite/').last;

      // ---- the person who was invited ----
      // Resolving happens before any session exists: they have to see what
      // they are being asked to join before signing in.
      final view = await partner.read(inviteActionsProvider).resolve(token);
      _log('the invitation reads, anonymously',
          detail: 'state=${view.state.name} from=${view.inviterDisplayName}');

      final r2 = await partner.read(authActionsProvider).register(
            email: 'partner-$stamp@test.local',
            password: 'a quiet evening',
            ageConfirmed: true,
          );
      if (r2 is! AuthSucceeded) {
        return _log('partner registers', detail: _describe(r2), ok: false);
      }
      _log('partner registers');

      final joined = await partner.read(inviteActionsProvider).join(token);
      if (joined is! Joined) {
        return _log('partner joins',
            detail: joined.runtimeType.toString(), ok: false);
      }
      _log('partner joins');

      // A retry of the same act must replay, not report a dead invitation.
      final rejoin = await partner.read(inviteActionsProvider).join(token);
      _log('a retried join replays instead of failing',
          detail: rejoin.runtimeType.toString(), ok: rejoin is Joined);

      // ---- the loop itself ----
      final partnerId = _subjectOf(partner);
      final occurrenceId = await creator
          .read(expectationRepositoryProvider)
          .create(
            dynamicId,
            title: 'Tea before the day starts',
            assigneeUserId: partnerId,
            idempotencyKey: ApiClient.newIdempotencyKey(),
          );
      _log('an expectation is set', detail: occurrenceId);

      final today = await partner.read(todayRepositoryProvider).forDynamic(dynamicId);
      _log('it appears on the other person\'s Today',
          detail: '${today.priorityItems.length} priority item(s)',
          ok: today.priorityItems.isNotEmpty);

      final target = today.priorityItems.isNotEmpty
          ? today.priorityItems.first.occurrenceId
          : occurrenceId;

      await partner.read(occurrenceRepositoryProvider).complete(
            target,
            idempotencyKey: ApiClient.newIdempotencyKey(),
          );
      _log('they complete it');

      final attention =
          await creator.read(attentionRepositoryProvider).forDynamic(dynamicId);
      _log('it reaches the other person as work to respond to',
          detail: '${attention.items.length} item(s) waiting',
          ok: attention.items.isNotEmpty);

      // The central red line: only this explicit human send creates an
      // acknowledgement. Completion did not, and could not.
      //
      // Sent with no words, which is the path REQ-ACK-001 requires — "basic
      // acknowledgement is at most two taps" — and which the API made
      // impossible until today. What makes this a human response is the send,
      // not the presence of text.
      await creator.read(occurrenceRepositoryProvider).acknowledge(
            target,
            type: 'ACKNOWLEDGE',
            idempotencyKey: ApiClient.newIdempotencyKey(),
          );
      _log('a human acknowledges it — in two taps, no words');

      final after = await partner.read(todayRepositoryProvider).forDynamic(dynamicId);
      _log('the response comes back to them',
          detail: after.recentResponse == null
              ? 'no response on Today'
              : 'a response is present',
          ok: after.recentResponse != null);

      _log('the loop is closed');

      // ---- adjustment: the other normal path ----
      //
      // Not an error branch. "Adjustment is a normal path, not a failure" is
      // a product red line, and a skeleton that only walks the happy path
      // would let the two drift apart until a screen makes it obvious.
      final second = await creator.read(expectationRepositoryProvider).create(
            dynamicId,
            title: 'A walk after dinner',
            assigneeUserId: partnerId,
            idempotencyKey: ApiClient.newIdempotencyKey(),
          );
      _log('a second expectation is set', detail: second);

      final laterToday =
          await partner.read(todayRepositoryProvider).forDynamic(dynamicId);
      final adjustable = laterToday.priorityItems
          .where((i) => i.occurrenceId != target)
          .map((i) => i.occurrenceId)
          .firstOrNull;
      if (adjustable == null) {
        return _log('the second expectation is actionable', ok: false);
      }

      await partner.read(adjustmentRepositoryProvider).request(
            adjustable,
            type: AdjustmentType.cantDo,
            note: 'Not tonight.',
            idempotencyKey: ApiClient.newIdempotencyKey(),
          );
      _log("they say they can't do it");

      final needing =
          await creator.read(attentionRepositoryProvider).forDynamic(dynamicId);
      _log('it reaches the other person as something to answer',
          detail: '${needing.items.length} item(s)',
          ok: needing.items.isNotEmpty);

      await creator.read(adjustmentRepositoryProvider).resolve(
            adjustable,
            resolution: AdjustmentResolution.excuse,
            idempotencyKey: ApiClient.newIdempotencyKey(),
          );
      _log('the partner answers — excused, not marked missed');

      _log('adjustment closes too');
    } catch (e) {
      _log('failed', detail: e.toString(), ok: false);
    } finally {
      creator.dispose();
      partner.dispose();
      setState(() => _running = false);
    }
  }

  /// The user id the server issued, read from the access token's subject.
  String _subjectOf(ProviderContainer person) {
    final session = person.read(sessionProvider);
    final token = session is Authenticated ? session.accessToken : '';
    final payload = token.split('.')[1];
    final normalised = payload.padRight((payload.length + 3) ~/ 4 * 4, '=');
    final json = String.fromCharCodes(base64Url.decode(normalised));
    return (jsonDecode(json) as Map<String, dynamic>)['sub'] as String;
  }

  static String _describe(AuthOutcome o) => switch (o) {
        AuthFailed(:final message) => message,
        AuthUncertain(:final message) => message,
        _ => o.runtimeType.toString(),
      };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Walking skeleton'),
        actions: [
          TextButton(
            onPressed: _running ? null : _run,
            child: Text(_running ? 'running…' : 'run'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('API: $kApiBaseUrl'),
          const Divider(),
          for (final (i, step) in _steps.indexed)
            ListTile(
              dense: true,
              leading: Text('${i + 1}'),
              title: Text(step.name),
              subtitle: step.detail == null ? null : Text(step.detail!),
              trailing: Text(step.ok ? 'ok' : 'FAILED'),
            ),
        ],
      ),
    );
  }
}
