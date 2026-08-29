// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'starter_rhythm_view.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_StarterRhythmProposal _$StarterRhythmProposalFromJson(
  Map<String, dynamic> json,
) => _StarterRhythmProposal(
  ritualTitle: json['ritualTitle'] as String,
  ritualPurpose: json['ritualPurpose'] as String,
  expectationTitle: json['expectationTitle'] as String,
  expectationPurpose: json['expectationPurpose'] as String,
  checkInFraming: json['checkInFraming'] as String,
  optionalSecondTitle: json['optionalSecondTitle'] as String,
  optionalSecondPurpose: json['optionalSecondPurpose'] as String,
);

Map<String, dynamic> _$StarterRhythmProposalToJson(
  _StarterRhythmProposal instance,
) => <String, dynamic>{
  'ritualTitle': instance.ritualTitle,
  'ritualPurpose': instance.ritualPurpose,
  'expectationTitle': instance.expectationTitle,
  'expectationPurpose': instance.expectationPurpose,
  'checkInFraming': instance.checkInFraming,
  'optionalSecondTitle': instance.optionalSecondTitle,
  'optionalSecondPurpose': instance.optionalSecondPurpose,
};
