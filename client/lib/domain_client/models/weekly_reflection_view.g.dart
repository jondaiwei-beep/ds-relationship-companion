// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'weekly_reflection_view.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_WeeklyMoment _$WeeklyMomentFromJson(Map<String, dynamic> json) =>
    _WeeklyMoment(
      title: json['title'] as String?,
      text: json['text'] as String?,
      fromDisplayName: json['fromDisplayName'] as String?,
      occurredAt: DateTime.parse(json['occurredAt'] as String),
    );

Map<String, dynamic> _$WeeklyMomentToJson(_WeeklyMoment instance) =>
    <String, dynamic>{
      'title': instance.title,
      'text': instance.text,
      'fromDisplayName': instance.fromDisplayName,
      'occurredAt': instance.occurredAt.toIso8601String(),
    };

_WeeklyReflectionView _$WeeklyReflectionViewFromJson(
  Map<String, dynamic> json,
) => _WeeklyReflectionView(
  connectedDays: (json['connectedDays'] as num?)?.toInt() ?? 0,
  answeredMoments:
      (json['answeredMoments'] as List<dynamic>?)
          ?.map((e) => WeeklyMoment.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <WeeklyMoment>[],
  adjustmentsResolved: (json['adjustmentsResolved'] as num?)?.toInt() ?? 0,
  hasEnoughHistory: json['hasEnoughHistory'] as bool? ?? false,
);

Map<String, dynamic> _$WeeklyReflectionViewToJson(
  _WeeklyReflectionView instance,
) => <String, dynamic>{
  'connectedDays': instance.connectedDays,
  'answeredMoments': instance.answeredMoments,
  'adjustmentsResolved': instance.adjustmentsResolved,
  'hasEnoughHistory': instance.hasEnoughHistory,
};
