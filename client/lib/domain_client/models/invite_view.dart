import 'package:freezed_annotation/freezed_annotation.dart';

part 'invite_view.freezed.dart';
part 'invite_view.g.dart';

/// Invite states. Every terminal state is explicit — the join page must be able
/// to explain itself rather than dead-end (Notion 02 §A4).
@JsonEnum(fieldRename: FieldRename.screamingSnake)
enum InviteState { pending, accepted, expired, revoked, notFound }

@freezed
abstract class InviteView with _$InviteView {
  const factory InviteView({
    required InviteState state,
    String? inviteId,
    String? dynamicId,
    String? intendedRoleContext,
    /// Shown before authentication so the invitee knows who invited them.
    String? inviterDisplayName,
  }) = _InviteView;

  factory InviteView.fromJson(Map<String, dynamic> json) =>
      _$InviteViewFromJson(json);
}
