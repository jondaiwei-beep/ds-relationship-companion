import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../domain_client/api_client.dart';
import '../../../domain_client/models/boundary.dart';
import '../../../domain_client/models/starter_rhythm_view.dart';

/// What a person wants more of. Asked before role or configuration, because
/// `REQ-ACT-001` says the outcome comes first — a product that asks "are you
/// dominant or submissive" before "what do you want" has already framed the
/// relationship for them.
enum DesiredOutcome { closer, structure, service, accountability, explore }

/// How much structure to begin with. Light / Steady / Defined, per the
/// approved SCR-08 candidate.
enum StructureLevel { light, steady, defined }

/// How someone describes their own role, as a starting point.
///
/// **Never an authorization level.** The server keeps this separate from
/// `role_context` for exactly this reason, and it is nullable throughout:
/// a couple that does not want to name it must not be blocked.
enum RolePreset { dominant, submissive, switchRole, custom }

extension on DesiredOutcome {
  String get wire => switch (this) {
        DesiredOutcome.closer => 'CLOSER',
        DesiredOutcome.structure => 'STRUCTURE',
        DesiredOutcome.service => 'SERVICE',
        DesiredOutcome.accountability => 'ACCOUNTABILITY',
        DesiredOutcome.explore => 'EXPLORE',
      };
}

extension on StructureLevel {
  String get wire => switch (this) {
        StructureLevel.light => 'LIGHT',
        StructureLevel.steady => 'STEADY',
        StructureLevel.defined => 'DEFINED',
      };
}

extension on RolePreset {
  String get wire => switch (this) {
        RolePreset.dominant => 'DOMINANT',
        RolePreset.submissive => 'SUBMISSIVE',
        RolePreset.switchRole => 'SWITCH',
        RolePreset.custom => 'CUSTOM',
      };
}

/// Everything the four activation screens collect, before any of it is sent.
///
/// One value object rather than four screens each posting their own piece,
/// because the server takes it as one command. Holding it here also means a
/// person can go back a step without the earlier answers being written
/// anywhere — nothing exists until they finish.
class ActivationDraft {
  const ActivationDraft({
    this.outcome,
    this.solo = false,
    this.rolePreset,
    this.structure = StructureLevel.steady,
    this.longDistance = false,
    this.timezone,
    this.boundaries = const [],
  });

  final DesiredOutcome? outcome;

  /// Solo mode. Permitted, but it must not turn the product into a personal
  /// habit tracker — the couple is the value unit.
  final bool solo;

  final RolePreset? rolePreset;

  /// Steady by default, as the approved candidate shows selected.
  final StructureLevel structure;

  final bool longDistance;

  /// IANA name, detected from the device. Never a bare UTC offset: a fixed
  /// offset silently moves someone's relationship day across a DST boundary.
  final String? timezone;

  /// Limits named during setup — REQ-ACT-002 "boundaries lite".
  ///
  /// Held here like every other answer so backing out of the step writes
  /// nothing, then posted once the Dynamic exists (they key on its id). Each
  /// is the author's own; the server takes the author from the session, so
  /// nothing in this list can name anyone else.
  final List<DraftBoundary> boundaries;

  bool get isComplete => outcome != null && timezone != null;

  ActivationDraft copyWith({
    DesiredOutcome? outcome,
    bool? solo,
    RolePreset? rolePreset,
    bool clearRolePreset = false,
    StructureLevel? structure,
    bool? longDistance,
    String? timezone,
    List<DraftBoundary>? boundaries,
  }) =>
      ActivationDraft(
        outcome: outcome ?? this.outcome,
        solo: solo ?? this.solo,
        rolePreset: clearRolePreset ? null : (rolePreset ?? this.rolePreset),
        structure: structure ?? this.structure,
        longDistance: longDistance ?? this.longDistance,
        timezone: timezone ?? this.timezone,
        boundaries: boundaries ?? this.boundaries,
      );
}

/// One limit as it exists before anything is written.
class DraftBoundary {
  const DraftBoundary(this.label, this.stance, {this.note});

  final String label;
  final BoundaryStance stance;
  final String? note;
}

sealed class ActivationOutcome {
  const ActivationOutcome();
}

class DynamicCreated extends ActivationOutcome {
  const DynamicCreated(this.dynamicId, {this.boundariesSaved = true});

  final String dynamicId;

  /// False when the Dynamic was created but a named limit did not save.
  /// Activation still succeeded; the surface says what to do about it.
  final bool boundariesSaved;
}

/// Why an activation attempt did not land, in terms the UI can translate.
///
/// The reason travels rather than the sentence: this layer has no
/// `BuildContext`, and a screen that shows English to a Chinese reader has
/// failed the person as surely as a wrong error.
enum ActivationFailureReason {
  /// The wizard let a draft through without an outcome. Not a person's fault
  /// to fix, but it must not be sent.
  outcomeMissing,

  /// The device offered something that is not an IANA zone name.
  timezoneUnreadable,

  offline,

  /// The client sent something the server does not accept.
  invalidRequest,

  unknown,
}

class ActivationFailed extends ActivationOutcome {
  const ActivationFailed(this.reason, this.message);

  final ActivationFailureReason reason;

  /// The English sentence, kept for logs, QA surfaces and tests. Screens
  /// render `reason` through the localisations instead.
  final String message;
}

/// Creating a Dynamic and starting its first rhythm.
class ActivationActions {
  ActivationActions(this._ref);

  final Ref _ref;

  /// One key per distinct request, not per attempt.
  ///
  /// A single key held across attempts is wrong in both directions. The
  /// server scopes a key to the exact request body: retrying an *edited*
  /// draft under the same key is a conflict, and clearing the key on success
  /// means a back-navigation and resubmit creates a second Dynamic.
  ///
  /// Keying by the request itself gets both right. The same draft always
  /// retries as the same attempt — including after a success whose response
  /// was lost — and an edited draft is honestly a different request.
  final Map<String, String> _createKeys = {};

  Future<ActivationOutcome> createDynamic(ActivationDraft draft) async {
    final outcome = draft.outcome;
    final timezone = draft.timezone;
    if (outcome == null || timezone == null) {
      // The wizard should not have allowed this; failing loudly beats
      // sending a half-formed command.
      return const ActivationFailed(
        ActivationFailureReason.outcomeMissing,
        'Choose what you want more of first.',
      );
    }
    if (!_looksLikeIanaZone(timezone)) {
      // REQ-TIME-001. A bare offset survives every type check and then moves
      // someone's relationship day when the clocks change — the failure
      // arrives months later and looks like a bug in scheduling.
      return const ActivationFailed(
        ActivationFailureReason.timezoneUnreadable,
        "We couldn't read this device's timezone. Try again.",
      );
    }

    final key = _createKeys.putIfAbsent(
      _fingerprint(draft, outcome, timezone),
      ApiClient.newIdempotencyKey,
    );
    try {
      final id = await _ref.read(dynamicRepositoryProvider).create(
            mode: draft.solo ? 'SOLO' : 'COUPLE',
            desiredOutcome: outcome.wire,
            structureLevel: draft.structure.wire,
            referenceTimezone: timezone,
            rolePreset: draft.rolePreset?.wire,
            longDistance: draft.longDistance,
            idempotencyKey: key,
          );
      // Limits are written only once the Dynamic they belong to exists.
      //
      // A failure here does not fail activation. Someone who has just named
      // what is off the table should not be dropped back into a wizard —
      // the Dynamic is real, and Settings offers the same list to finish.
      // Silence would be wrong the other way round, so what did not save is
      // reported by `boundariesSaved` rather than swallowed.
      final saved = await _writeBoundaries(id, draft.boundaries);

      // Not cleared: a success whose response was lost is exactly the case a
      // retry has to survive, and the server replays rather than duplicating.
      return DynamicCreated(id, boundariesSaved: saved);
    } on DioException catch (e) {
      // The key is kept: the next attempt is the same attempt.
      return _failure(e);
    }
  }

  /// Returns false if any limit did not reach the server.
  Future<bool> _writeBoundaries(
    String dynamicId,
    List<DraftBoundary> drafts,
  ) async {
    if (drafts.isEmpty) return true;
    final repo = _ref.read(boundaryRepositoryProvider);
    var ok = true;
    for (final b in drafts) {
      try {
        await repo.add(dynamicId, label: b.label, stance: b.stance, note: b.note);
      } on DioException {
        ok = false;
      }
    }
    return ok;
  }

  /// What the server suggests to begin with. Writes nothing.
  Future<StarterRhythmProposal> proposeRhythm(String dynamicId) =>
      _ref.read(starterRhythmRepositoryProvider).propose(dynamicId);

  /// Commit the rhythm. This is the first thing that becomes real.
  Future<ActivationOutcome> startRhythm(
    String dynamicId, {
    required String assigneeUserId,
    String? ritualTitle,
    String? expectationTitle,
  }) async {
    // Keyed by the request, not just the Dynamic: editing a title after a
    // failure and retrying under the same key would be a conflict.
    final key = _rhythmKeys.putIfAbsent(
      [dynamicId, assigneeUserId, ritualTitle ?? '-', expectationTitle ?? '-']
          .join('|'),
      ApiClient.newIdempotencyKey,
    );
    try {
      await _ref.read(starterRhythmRepositoryProvider).start(
            dynamicId,
            assigneeUserId: assigneeUserId,
            ritualTitle: ritualTitle,
            expectationTitle: expectationTitle,
            idempotencyKey: key,
          );
      // Kept, not cleared: a rhythm that started but whose response was lost
      // must replay rather than start a second one.
      return DynamicCreated(dynamicId);
    } on DioException catch (e) {
      return _failure(e);
    }
  }

  final Map<String, String> _rhythmKeys = {};

  /// Everything the request is made of, so an edited draft is a new request.
  static String _fingerprint(
    ActivationDraft draft,
    DesiredOutcome outcome,
    String timezone,
  ) =>
      [
        draft.solo ? 'SOLO' : 'COUPLE',
        outcome.wire,
        draft.structure.wire,
        timezone,
        draft.rolePreset?.wire ?? '-',
      ].join('|');

  /// An IANA zone name, not an offset.
  ///
  /// Deliberately shape-only: the client has no zone database to check
  /// membership against, and the point is to reject `+02:00` and `UTC+2`,
  /// which are the forms a device actually offers by mistake.
  static bool _looksLikeIanaZone(String value) =>
      RegExp(r'^[A-Za-z_]+(/[A-Za-z0-9_+-]+){1,2}$').hasMatch(value) ||
      value == 'UTC';

  static ActivationFailed _failure(DioException e) {
    if (_isOffline(e)) {
      return const ActivationFailed(
        ActivationFailureReason.offline,
        "You're offline. Connect to the internet, then try again.",
      );
    }
    final data = e.response?.data;
    final code = data is Map ? data['code'] as String? : null;
    return switch (code) {
      // The client sent something the server does not accept. A person cannot
      // fix this, so it does not pretend they can.
      'INVALID_REQUEST' => const ActivationFailed(
          ActivationFailureReason.invalidRequest,
          'Something went wrong setting that up. Try again.',
        ),
      _ => const ActivationFailed(
          ActivationFailureReason.unknown,
          "We couldn't set that up right now. Try again.",
        ),
    };
  }

  static bool _isOffline(DioException e) => switch (e.type) {
        DioExceptionType.connectionError ||
        DioExceptionType.connectionTimeout =>
          true,
        _ => false,
      };
}

final activationActionsProvider =
    Provider<ActivationActions>(ActivationActions.new);
