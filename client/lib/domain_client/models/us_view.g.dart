// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'us_view.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_RelationshipMoment _$RelationshipMomentFromJson(Map<String, dynamic> json) =>
    _RelationshipMoment(
      eventType: json['eventType'] as String,
      actorDisplayName: json['actorDisplayName'] as String?,
      occurredAt: DateTime.parse(json['occurredAt'] as String),
      title: json['title'] as String?,
      text: json['text'] as String?,
    );

Map<String, dynamic> _$RelationshipMomentToJson(_RelationshipMoment instance) =>
    <String, dynamic>{
      'eventType': instance.eventType,
      'actorDisplayName': instance.actorDisplayName,
      'occurredAt': instance.occurredAt.toIso8601String(),
      'title': instance.title,
      'text': instance.text,
    };

_UsView _$UsViewFromJson(Map<String, dynamic> json) => _UsView(
  moments:
      (json['moments'] as List<dynamic>?)
          ?.map((e) => RelationshipMoment.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <RelationshipMoment>[],
  connectedDays: (json['connectedDays'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$UsViewToJson(_UsView instance) => <String, dynamic>{
  'moments': instance.moments,
  'connectedDays': instance.connectedDays,
};
