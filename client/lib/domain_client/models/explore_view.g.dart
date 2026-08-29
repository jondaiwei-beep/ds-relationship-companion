// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'explore_view.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ExploreIdea _$ExploreIdeaFromJson(Map<String, dynamic> json) => _ExploreIdea(
  id: json['id'] as String,
  kind: json['kind'] as String,
  title: json['title'] as String,
  purpose: json['purpose'] as String,
  detail: json['detail'] as String,
  collectionId: json['collectionId'] as String,
);

Map<String, dynamic> _$ExploreIdeaToJson(_ExploreIdea instance) =>
    <String, dynamic>{
      'id': instance.id,
      'kind': instance.kind,
      'title': instance.title,
      'purpose': instance.purpose,
      'detail': instance.detail,
      'collectionId': instance.collectionId,
    };

_ExploreCollection _$ExploreCollectionFromJson(Map<String, dynamic> json) =>
    _ExploreCollection(
      id: json['id'] as String,
      title: json['title'] as String,
      blurb: json['blurb'] as String,
    );

Map<String, dynamic> _$ExploreCollectionToJson(_ExploreCollection instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'blurb': instance.blurb,
    };

_ExploreLibraryView _$ExploreLibraryViewFromJson(Map<String, dynamic> json) =>
    _ExploreLibraryView(
      collections:
          (json['collections'] as List<dynamic>?)
              ?.map(
                (e) => ExploreCollection.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          const <ExploreCollection>[],
      ideas:
          (json['ideas'] as List<dynamic>?)
              ?.map((e) => ExploreIdea.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <ExploreIdea>[],
    );

Map<String, dynamic> _$ExploreLibraryViewToJson(_ExploreLibraryView instance) =>
    <String, dynamic>{
      'collections': instance.collections,
      'ideas': instance.ideas,
    };
