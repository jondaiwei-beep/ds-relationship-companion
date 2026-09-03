import '../api_client.dart';
import '../models/task.dart';
import 'today_repository.dart' show OutcomeResult;

class TaskRepository {
  TaskRepository(this._api);

  final ApiClient _api;

  String _base(String dynamicId) => '/v1/dynamics/$dynamicId/tasks';

  Future<List<TaskView>> list(String dynamicId, {bool includeArchived = false}) async {
    final r = await _api.getList(
      '${_base(dynamicId)}?includeArchived=$includeArchived',
    );
    return r.cast<Map<String, dynamic>>().map(TaskView.fromJson).toList(growable: false);
  }

  /// A D creates it `active`; an s creates it `proposed` (decision D-24).
  Future<TaskView> create(
    String dynamicId,
    NewTask task, {
    required String idempotencyKey,
  }) async =>
      TaskView.fromJson(
        await _api.post(
          _base(dynamicId),
          body: task.toJson(),
          idempotencyKey: idempotencyKey,
        ),
      );

  /// Full edit of a definition: `PATCH /tasks/{id}` with the same body as
  /// create. Every field is sent, so a null `dueTime` really clears it.
  Future<TaskView> update(String dynamicId, String taskId, NewTask task) async =>
      TaskView.fromJson(await _api.patch('${_base(dynamicId)}/$taskId', body: task.toJson()));

  Future<TaskView> accept(String dynamicId, String taskId, {required String idempotencyKey}) async =>
      TaskView.fromJson(
        await _api.post('${_base(dynamicId)}/$taskId/accept', idempotencyKey: idempotencyKey),
      );

  /// D says no to a proposed task. It is archived, not deleted; the s can
  /// still see it was theirs.
  Future<void> decline(String dynamicId, String taskId, {required String idempotencyKey}) =>
      _api.post('${_base(dynamicId)}/$taskId/decline', idempotencyKey: idempotencyKey);

  Future<void> archive(String dynamicId, String taskId, {required String idempotencyKey}) =>
      _api.post('${_base(dynamicId)}/$taskId/archive', idempotencyKey: idempotencyKey);

  /// Null [until] pauses indefinitely.
  Future<TaskView> pause(
    String dynamicId,
    String taskId, {
    DateTime? until,
    required String idempotencyKey,
  }) async =>
      TaskView.fromJson(
        await _api.post(
          '${_base(dynamicId)}/$taskId/pause',
          body: {'until': until?.toUtc().toIso8601String()},
          idempotencyKey: idempotencyKey,
        ),
      );

  Future<TaskView> unpause(String dynamicId, String taskId, {required String idempotencyKey}) async =>
      TaskView.fromJson(
        await _api.post('${_base(dynamicId)}/$taskId/unpause', idempotencyKey: idempotencyKey),
      );

  /// An `open` task is delivered straight from the task; the occurrence is
  /// born delivered.
  Future<OutcomeResult> deliverOpen(
    String dynamicId,
    String taskId, {
    String? note,
    String? proofKind,
    String? proofRef,
    required String idempotencyKey,
  }) async =>
      OutcomeResult.fromJson(
        await _api.post(
          '${_base(dynamicId)}/$taskId/deliver',
          body: {'note': note, 'proofKind': proofKind, 'proofRef': proofRef},
          idempotencyKey: idempotencyKey,
        ),
      );
}
