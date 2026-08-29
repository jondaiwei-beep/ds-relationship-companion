import 'package:freezed_annotation/freezed_annotation.dart';

part 'check_in_view.freezed.dart';
part 'check_in_view.g.dart';

/// Visibility is EXPLICIT (Notion 04 §3). There is no "in a dynamic so
/// obviously shared" default, and Solo → Couple never auto-shares.
@JsonEnum(fieldRename: FieldRename.screamingSnake)
enum CheckInVisibility { private, shared }

@freezed
abstract class CheckInView with _$CheckInView {
  const factory CheckInView({
    required String id,
    required DateTime relationshipDay,
    String? mood,
    String? energy,
    String? need,
    String? note,
    required String visibility,
    required DateTime createdAt,
    String? creatorDisplayName,
    /// True when the viewer wrote it.
    @Default(false) bool isMine,
  }) = _CheckInView;

  factory CheckInView.fromJson(Map<String, dynamic> json) =>
      _$CheckInViewFromJson(json);
}
