import 'package:dio/dio.dart';
import 'package:dsapp/domain_client/models/d_note.dart';
import 'package:dsapp/domain_client/models/task.dart';
import 'package:dsapp/domain_client/models/today_view.dart';
import 'package:dsapp/domain_client/repositories/d_note_repository.dart';
import 'package:dsapp/domain_client/repositories/task_repository.dart';
import 'package:dsapp/domain_client/repositories/today_repository.dart';

/// A 409 the way the server sends one: `{code}` in the body.
DioException conflict(String code) {
  final req = RequestOptions(path: '/v1/occurrences/x/outcome');
  return DioException(
    requestOptions: req,
    type: DioExceptionType.badResponse,
    response: Response(requestOptions: req, statusCode: 409, data: {'code': code}),
  );
}

OccurrenceView occ({
  required String id,
  required String title,
  String kind = 'recurring',
  String proof = 'check',
  int pointsEarn = 0,
  String day = '2026-09-01',
  DateTime? dueAt,
  Outcome outcome = Outcome.open,
  DateTime? outcomeAt,
  String? outcomeNote,
  DateTime? proposedTime,
  Disposition disposition = Disposition.none,
  DateTime? dispositionAt,
  String? dispositionNote,
  ConsequenceView? consequence,
  String? makeUpDay,
  DateTime? seenAt,
  double? value,
  String? unit,
}) =>
    OccurrenceView(
      id: id,
      value: value,
      unit: unit,
      taskId: 't-$id',
      title: title,
      kind: kind,
      proof: proof,
      pointsEarn: pointsEarn,
      day: day,
      dueAt: dueAt,
      outcome: outcome,
      outcomeAt: outcomeAt,
      outcomeNote: outcomeNote,
      proposedTime: proposedTime,
      disposition: disposition,
      dispositionAt: dispositionAt,
      dispositionNote: dispositionNote,
      consequence: consequence,
      makeUpDay: makeUpDay,
      seenAt: seenAt,
    );

TodayView sView({
  List<OccurrenceView> items = const [],
  List<OpenTaskView> openTasks = const [],
  String? partner = 'Mara',
  DateTime? dAwayUntil,
}) =>
    TodayView(
      dynamicId: 'dyn-1',
      day: '2026-09-01',
      timezone: 'Asia/Shanghai',
      dayBoundaryMinutes: 240,
      side: 'S',
      items: items,
      openTasks: openTasks,
      balance: 12,
      daysTogether: 40,
      partnerDisplayName: partner,
      dAwayUntil: dAwayUntil,
    );

TodayView dView({
  List<OccurrenceView> items = const [],
  int needsMe = 0,
  String? partner = 'Nia',
}) =>
    TodayView(
      dynamicId: 'dyn-1',
      day: '2026-09-01',
      timezone: 'Asia/Shanghai',
      dayBoundaryMinutes: 240,
      side: 'D',
      items: items,
      balance: 12,
      daysTogether: 40,
      needsMe: needsMe,
      partnerDisplayName: partner,
    );

/// Records every write and answers reads from what it was given. Reads are
/// counted so tests can say when the server was asked.
class FakeTodayRepository implements TodayRepository {
  FakeTodayRepository({required this.view, this.needsMeRows = const []});

  TodayView view;
  List<OccurrenceView> needsMeRows;
  int reads = 0;
  int needsMeReads = 0;
  final outcomes = <(String, OutcomeChange)>[];
  final dispositions = <(String, DispositionChange)>[];
  final seen = <String>[];

  /// When set, the next write throws this.
  Object? nextError;

  /// How long a write takes; a frame can be drawn in between when non-zero.
  Duration latency = Duration.zero;

  /// Applied to [view] after a successful outcome write, so the re-read shows it.
  TodayView Function(TodayView, String, OutcomeChange)? onOutcome;

  @override
  Future<TodayView> today(String dynamicId, {String? day}) async {
    reads++;
    return view;
  }

  @override
  Future<List<OccurrenceView>> needsMe(String dynamicId, {int limit = 50}) async {
    needsMeReads++;
    return needsMeRows;
  }

  @override
  Future<OccurrenceView> occurrence(String occurrenceId) async =>
      view.items.firstWhere((o) => o.id == occurrenceId);

  Future<void> _maybeThrow() async {
    if (latency > Duration.zero) await Future<void>.delayed(latency);
    final e = nextError;
    if (e != null) {
      nextError = null;
      throw e;
    }
  }

  @override
  Future<OutcomeResult> setOutcome(
    String occurrenceId,
    OutcomeChange change, {
    required String idempotencyKey,
  }) async {
    await _maybeThrow();
    outcomes.add((occurrenceId, change));
    final apply = onOutcome;
    if (apply != null) view = apply(view, occurrenceId, change);
    return OutcomeResult(
      occurrenceId: occurrenceId,
      outcome: change.outcome,
      outcomeAt: DateTime.utc(2026, 9, 1, 4),
      version: 2,
    );
  }

  @override
  Future<DispositionResult> setDisposition(
    String occurrenceId,
    DispositionChange change, {
    required String idempotencyKey,
  }) async {
    await _maybeThrow();
    dispositions.add((occurrenceId, change));
    needsMeRows = needsMeRows.where((o) => o.id != occurrenceId).toList();
    return DispositionResult(
      occurrenceId: occurrenceId,
      disposition: change.disposition,
      dispositionAt: DateTime.utc(2026, 9, 1, 5),
      version: 3,
    );
  }

  @override
  Future<DateTime?> markSeen(String occurrenceId) async {
    seen.add(occurrenceId);
    return DateTime.utc(2026, 9, 1, 4, 40);
  }
}

class FakeTaskRepository implements TaskRepository {
  final created = <NewTask>[];
  final delivered = <String>[];
  Object? nextError;

  @override
  Future<TaskView> create(String dynamicId, NewTask task, {required String idempotencyKey}) async {
    final e = nextError;
    if (e != null) {
      nextError = null;
      throw e;
    }
    created.add(task);
    return TaskView(
      id: 'task-${created.length}',
      title: task.title,
      kind: task.kind,
      proof: task.proof,
      createdBy: 'u-d',
      status: 'active',
    );
  }

  @override
  Future<OutcomeResult> deliverOpen(
    String dynamicId,
    String taskId, {
    String? note,
    String? proofKind,
    String? proofRef,
    required String idempotencyKey,
  }) async {
    delivered.add(taskId);
    return OutcomeResult(
      occurrenceId: 'occ-$taskId',
      outcome: Outcome.delivered,
      outcomeAt: DateTime.utc(2026, 9, 1, 4),
      version: 1,
    );
  }

  @override
  dynamic noSuchMethod(Invocation i) => throw UnimplementedError('${i.memberName}');
}

class FakeDNoteRepository implements DNoteRepository {
  FakeDNoteRepository({List<DNote> notes = const []}) : notes = List.of(notes);
  List<DNote> notes;
  final marked = <String>[];
  final deleted = <String>[];

  @override
  Future<List<DNote>> list(String dynamicId, {bool includeDone = false}) async => notes;

  @override
  Future<DNote> create(
    String dynamicId, {
    required String body,
    DateTime? remindAt,
    required String idempotencyKey,
  }) async {
    final n = DNote(
      id: 'n-${notes.length + 1}',
      body: body,
      remindAt: remindAt,
      createdAt: DateTime.utc(2026, 9, 1),
    );
    notes = [...notes, n];
    return n;
  }

  @override
  Future<DNote> done(String noteId) async {
    marked.add(noteId);
    notes = notes.where((n) => n.id != noteId).toList();
    return DNote(id: noteId, body: '', createdAt: DateTime.utc(2026, 9, 1), doneAt: DateTime.utc(2026, 9, 1));
  }

  @override
  Future<void> delete(String noteId) async {
    deleted.add(noteId);
    notes = notes.where((n) => n.id != noteId).toList();
  }
}
