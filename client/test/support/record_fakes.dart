import 'package:dsapp/domain_client/models/record.dart';
import 'package:dsapp/domain_client/repositories/record_repository.dart';

/// Answers 记录 reads from what it was given and records every write.
class FakeRecordRepository implements RecordRepository {
  FakeRecordRepository({
    this.cells = const [],
    Map<String, DayView>? days,
    this.factsView = const FactsView(from: '2026-09-01', to: '2026-09-30'),
    this.summaryView = const SummaryView(daysTogether: 40, currentStreak: 6),
  }) : days = days ?? {};

  List<MonthCell> cells;
  Map<String, DayView> days;
  FactsView factsView;
  SummaryView summaryView;

  final monthReads = <String>[];
  final dayReads = <String>[];
  final factsReads = <(String, String)>[];
  final comments = <(String, String)>[];
  final deletedComments = <String>[];
  final notes = <(String, String)>[];

  /// When set, the next write throws this.
  Object? nextError;

  Future<void> _maybeThrow() async {
    final e = nextError;
    if (e != null) {
      nextError = null;
      throw e;
    }
  }

  @override
  Future<List<MonthCell>> month(String dynamicId, String month) async {
    monthReads.add(month);
    return cells.where((c) => c.day.startsWith(month)).toList();
  }

  @override
  Future<DayView> day(String dynamicId, String day) async {
    dayReads.add(day);
    return days[day] ?? DayView(day: day);
  }

  @override
  Future<FactsView> facts(String dynamicId, {required String from, required String to}) async {
    factsReads.add((from, to));
    return factsView.copyWith(from: from, to: to);
  }

  @override
  Future<SummaryView> summary(String dynamicId) async => summaryView;

  @override
  Future<DayComment> addComment(
    String dynamicId, {
    required String day,
    required String body,
    required String idempotencyKey,
  }) async {
    await _maybeThrow();
    comments.add((day, body));
    final id = 'c-${comments.length}';
    final existing = days[day] ?? DayView(day: day);
    final entry = CommentEntry(id: id, authorId: 'u-me', body: body);
    days[day] = existing.copyWith(
      timeline: [
        ...existing.timeline,
        TimelineEntry(at: DateTime.utc(2026, 9, 1, 14), kind: 'comment', comment: entry),
      ],
      comments: [...existing.comments, entry],
    );
    return DayComment(
      id: id,
      dynamicId: dynamicId,
      day: day,
      authorId: 'u-me',
      body: body,
      createdAt: DateTime.utc(2026, 9, 1, 14),
    );
  }

  @override
  Future<void> deleteComment(String commentId) async {
    await _maybeThrow();
    deletedComments.add(commentId);
    days = {
      for (final e in days.entries)
        e.key: e.value.copyWith(
          timeline: e.value.timeline.where((t) => t.comment?.id != commentId).toList(),
          comments: e.value.comments.where((c) => c.id != commentId).toList(),
        ),
    };
  }

  @override
  Future<String?> putPrivateNote(
    String dynamicId, {
    required String day,
    required String body,
  }) async {
    await _maybeThrow();
    notes.add((day, body));
    final existing = days[day] ?? DayView(day: day);
    days[day] = existing.copyWith(myPrivateNote: body.isEmpty ? null : body);
    return body.isEmpty ? null : body;
  }
}

TimelineEntry outcomeAt(
  DateTime at, {
  required String occ,
  required String title,
  required String to,
  String? note,
  String? proofKind,
  String? proofRef,
}) =>
    TimelineEntry(
      at: at,
      kind: 'outcome',
      outcome: OutcomeEntry(
        occurrenceId: occ,
        taskId: 't-$occ',
        taskTitle: title,
        toValue: to,
        note: note,
        proofKind: proofKind,
        proofRef: proofRef,
      ),
    );

TimelineEntry dispositionAt(
  DateTime at, {
  required String occ,
  required String title,
  required String to,
  String? note,
  String? consequenceTitle,
  String? makeUpDay,
}) =>
    TimelineEntry(
      at: at,
      kind: 'disposition',
      disposition: DispositionEntry(
        occurrenceId: occ,
        taskId: 't-$occ',
        taskTitle: title,
        toValue: to,
        note: note,
        consequenceTitle: consequenceTitle,
        makeUpDay: makeUpDay,
      ),
    );

TimelineEntry commentAt(DateTime at, {required String id, required String author, required String body}) =>
    TimelineEntry(
      at: at,
      kind: 'comment',
      comment: CommentEntry(id: id, authorId: author, body: body),
    );

TimelineEntry pointsAt(
  DateTime at, {
  required String id,
  required String reason,
  required int amount,
  String? actor,
  String? note,
}) =>
    TimelineEntry(
      at: at,
      kind: 'points',
      points: PointsEntry(id: id, reason: reason, amount: amount, actorUserId: actor, note: note),
    );

TimelineEntry redemptionAt(DateTime at, {required String id, required String title, required String subject}) =>
    TimelineEntry(
      at: at,
      kind: 'redemption',
      redemption: RedemptionEntry(
        id: id,
        rewardId: 'r-$id',
        rewardTitle: title,
        subjectUserId: subject,
      ),
    );
