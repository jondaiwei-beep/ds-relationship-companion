import 'package:freezed_annotation/freezed_annotation.dart';

part 'rule.freezed.dart';
part 'rule.g.dart';

/// The six groups a standing rule can sit in (product/03-domain.md · Rule).
const ruleGroups = <String>[
  'protocol',
  'ritual',
  'restriction',
  'appearance',
  'reporting',
  'other',
];

/// A standing rule (product/03-domain.md · Rule). Generates nothing; it is
/// simply what the two of them agreed and can point at.
@freezed
abstract class RuleView with _$RuleView {
  const RuleView._();

  const factory RuleView({
    required String id,
    required String title,
    String? body,
    @Default('other') String group,
    required String createdBy,
    /// `proposed | active | archived`.
    required String status,
    @Default(0) int position,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _RuleView;

  factory RuleView.fromJson(Map<String, dynamic> json) => _$RuleViewFromJson(json);

  bool get isProposed => status == 'proposed';
  bool get isActive => status == 'active';
}

/// `POST /v1/dynamics/{id}/rules` body. A D's lands `active`; an s's lands
/// `proposed` (decision D-24).
@freezed
abstract class NewRule with _$NewRule {
  const factory NewRule({
    required String title,
    String? body,
    @Default('other') String group,
  }) = _NewRule;

  factory NewRule.fromJson(Map<String, dynamic> json) => _$NewRuleFromJson(json);
}

/// `PATCH /v1/dynamics/{id}/rules/{ruleId}` body. Null fields are untouched.
@freezed
abstract class RuleEdit with _$RuleEdit {
  const factory RuleEdit({
    String? title,
    String? body,
    String? group,
    int? position,
  }) = _RuleEdit;

  factory RuleEdit.fromJson(Map<String, dynamic> json) => _$RuleEditFromJson(json);
}
