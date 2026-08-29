import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../domain_client/api_client.dart';
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

  bool get isComplete => outcome != null && timezone != null;

  ActivationDraft copyWith({
    DesiredOutcome? outcome,
    bool? solo,
    RolePreset? rolePreset,
    bool clearRolePreset = false,
    StructureLevel? structure,
    bool? longDistance,
    String? timezone,
  }) =>
      ActivationDraft(
        outcome: outcome ?? this.outcome,
        solo: solo ?? this.solo,
        rolePreset: clearRolePreset ? null : (rolePreset ?? this.rolePreset),
        structure: structure ?? this.structure,
        longDistance: longDistance ?? this.longDistance,
        timezone: timezone ?? this.timezone,
      );
}

sealed class ActivationOutcome {
  const ActivationOutcome();
}

class DynamicCreated extends ActivationOutcome {
  const DynamicCreated(this.dynamicId);

  final String dynamicId;
}

class ActivationFailed extends ActivationOutcome {
  const ActivationFailed(this.message);

  final String message;
}

/// Creating a Dynamic and starting its first rhythm.
class ActivationActions {
  ActivationActions(this._ref);

  final Ref _ref;

  /// Held so a retry after a lost response does not create a second Dynamic.
  ///
  /// There is no natural key to scope this by — the draft is not yet anything
  /// the server knows about — so one key per instance, cleared only when a
  /// Dynamic actually comes back.
  String? _createKey;

  Future<ActivationOutcome> createDynamic(ActivationDraft draft) async {
    final outcome = draft.outcome;
    final timezone = draft.timezone;
    if (outcome == null || timezone == null) {
      // The wizard should not have allowed this; failing loudly beats
      // sending a half-formed command.
      return const ActivationFailed('Choose what you want more of first.');
    }

    final key = _createKey ??= ApiClient.newIdempotencyKey();
    try {
      final id = await _ref.read(dynamicRepositoryProvider).create(
            desiredOutcome: outcome.wire,
            structureLevel: draft.structure.wire,
            referenceTimezone: timezone,
            rolePreset: draft.rolePreset?.wire,
            idempotencyKey: key,
          );
      _createKey = null;
      return DynamicCreated(id);
    } on DioException catch (e) {
      // The key is kept: the next attempt is the same attempt.
      return ActivationFailed(_message(e));
    }
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
    final key = _rhythmKeys.putIfAbsent(dynamicId, ApiClient.newIdempotencyKey);
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
      return ActivationFailed(_message(e));
    }
  }

  final Map<String, String> _rhythmKeys = {};

  static String _message(DioException e) {
    if (_isOffline(e)) {
      return "You're offline. Connect to the internet, then try again.";
    }
    final data = e.response?.data;
    final code = data is Map ? data['code'] as String? : null;
    return switch (code) {
      // The client sent something the server does not accept. A person cannot
      // fix this, so it does not pretend they can.
      'INVALID_REQUEST' => 'Something went wrong setting that up. Try again.',
      _ => "We couldn't set that up right now. Try again.",
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
