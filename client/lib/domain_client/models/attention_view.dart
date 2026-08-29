import 'package:freezed_annotation/freezed_annotation.dart';

part 'attention_view.freezed.dart';
part 'attention_view.g.dart';

/// One thing awaiting a human response — Journey C (Notion 02 §4).
@freezed
abstract class AttentionItem with _$AttentionItem {
  const factory AttentionItem({
    required String occurrenceId,
    required String title,
    required String state,
    /// The person who acted. A response is addressed to a person, not a task.
    String? actorDisplayName,
    DateTime? occurredAt,
    required int priority,
  }) = _AttentionItem;

  factory AttentionItem.fromJson(Map<String, dynamic> json) =>
      _$AttentionItemFromJson(json);
}

@freezed
abstract class AttentionView with _$AttentionView {
  const factory AttentionView({
    @Default(<AttentionItem>[]) List<AttentionItem> items,
    @Default(0) int needsResponseCount,
    @Default(0) int needsReviewCount,
  }) = _AttentionView;

  factory AttentionView.fromJson(Map<String, dynamic> json) =>
      _$AttentionViewFromJson(json);
}
