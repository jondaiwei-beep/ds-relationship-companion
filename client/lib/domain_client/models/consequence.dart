import 'package:freezed_annotation/freezed_annotation.dart';

part 'consequence.freezed.dart';
part 'consequence.g.dart';

/// A consequence the D issued (product/03-domain.md · Consequence).
///
/// Born only from a `punished` disposition. The system never creates one and
/// nothing here counts down: `issued → done_by_s → confirmed | waived`, each
/// step a person's.
@freezed
abstract class ConsequenceView with _$ConsequenceView {
  const ConsequenceView._();

  const factory ConsequenceView({
    required String id,
    String? dynamicId,
    /// Always a D. Never the software.
    required String issuedBy,
    required String title,
    String? detail,
    /// `issued | done_by_s | confirmed | waived`.
    required String status,
    DateTime? issuedAt,
    DateTime? doneAt,
    DateTime? decidedAt,
  }) = _ConsequenceView;

  factory ConsequenceView.fromJson(Map<String, dynamic> json) =>
      _$ConsequenceViewFromJson(json);

  bool get isIssued => status == 'issued';
  bool get isDoneByS => status == 'done_by_s';
  bool get isOpen => isIssued || isDoneByS;
}
