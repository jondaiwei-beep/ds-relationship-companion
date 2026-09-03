import 'package:freezed_annotation/freezed_annotation.dart';

part 'redemption.freezed.dart';
part 'redemption.g.dart';

/// One ask for a reward (product/03-domain.md · Redemption).
///
/// `requested → approved | denied`, then `approved → fulfilled`. Points move
/// only at `approved`, and only by the D's hand.
@freezed
abstract class RedemptionView with _$RedemptionView {
  const RedemptionView._();

  const factory RedemptionView({
    required String id,
    required String rewardId,
    String? rewardTitle,
    required String subjectUserId,
    /// `requested | approved | denied | fulfilled`.
    required String status,
    String? note,
    String? decidedBy,
    DateTime? decidedAt,
    DateTime? createdAt,
  }) = _RedemptionView;

  factory RedemptionView.fromJson(Map<String, dynamic> json) =>
      _$RedemptionViewFromJson(json);

  bool get isRequested => status == 'requested';
  bool get isApproved => status == 'approved';
}
