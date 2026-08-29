import 'package:freezed_annotation/freezed_annotation.dart';

part 'us_view.freezed.dart';
part 'us_view.g.dart';

/// One thing that actually happened between two people.
///
/// Only human-authored events appear here — a scheduler firing is not
/// connection (see UsQueryService).
@freezed
abstract class RelationshipMoment with _$RelationshipMoment {
  const factory RelationshipMoment({
    required String eventType,
    String? actorDisplayName,
    required DateTime occurredAt,
    String? title,
    /// Present only for a human acknowledgement — their words, verbatim.
    String? text,
  }) = _RelationshipMoment;

  factory RelationshipMoment.fromJson(Map<String, dynamic> json) =>
      _$RelationshipMomentFromJson(json);
}

@freezed
abstract class UsView with _$UsView {
  const factory UsView({
    @Default(<RelationshipMoment>[]) List<RelationshipMoment> moments,
    /// Days on which BOTH members produced a meaningful event.
    @Default(0) int connectedDays,
  }) = _UsView;

  factory UsView.fromJson(Map<String, dynamic> json) => _$UsViewFromJson(json);
}
