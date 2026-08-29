// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'attention_view.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AttentionItem _$AttentionItemFromJson(Map<String, dynamic> json) =>
    _AttentionItem(
      occurrenceId: json['occurrenceId'] as String,
      title: json['title'] as String,
      state: json['state'] as String,
      actorDisplayName: json['actorDisplayName'] as String?,
      occurredAt: json['occurredAt'] == null
          ? null
          : DateTime.parse(json['occurredAt'] as String),
      priority: (json['priority'] as num).toInt(),
    );

Map<String, dynamic> _$AttentionItemToJson(_AttentionItem instance) =>
    <String, dynamic>{
      'occurrenceId': instance.occurrenceId,
      'title': instance.title,
      'state': instance.state,
      'actorDisplayName': instance.actorDisplayName,
      'occurredAt': instance.occurredAt?.toIso8601String(),
      'priority': instance.priority,
    };

_AttentionView _$AttentionViewFromJson(Map<String, dynamic> json) =>
    _AttentionView(
      items:
          (json['items'] as List<dynamic>?)
              ?.map((e) => AttentionItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <AttentionItem>[],
      needsResponseCount: (json['needsResponseCount'] as num?)?.toInt() ?? 0,
      needsReviewCount: (json['needsReviewCount'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$AttentionViewToJson(_AttentionView instance) =>
    <String, dynamic>{
      'items': instance.items,
      'needsResponseCount': instance.needsResponseCount,
      'needsReviewCount': instance.needsReviewCount,
    };
