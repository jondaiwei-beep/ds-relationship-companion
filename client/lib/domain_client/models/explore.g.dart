// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'explore.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PreferenceItem _$PreferenceItemFromJson(Map<String, dynamic> json) =>
    _PreferenceItem(
      id: json['id'] as String,
      group: json['group'] as String,
      titleZh: json['titleZh'] as String,
      titleEn: json['titleEn'] as String,
      detailZh: json['detailZh'] as String?,
      detailEn: json['detailEn'] as String?,
      custom: json['custom'] as bool? ?? false,
      myAnswer: json['myAnswer'] as String?,
    );

Map<String, dynamic> _$PreferenceItemToJson(_PreferenceItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'group': instance.group,
      'titleZh': instance.titleZh,
      'titleEn': instance.titleEn,
      'detailZh': instance.detailZh,
      'detailEn': instance.detailEn,
      'custom': instance.custom,
      'myAnswer': instance.myAnswer,
    };

_CompareItem _$CompareItemFromJson(Map<String, dynamic> json) => _CompareItem(
  itemId: json['itemId'] as String,
  title: json['title'] as String,
  wantSide: json['wantSide'] as String?,
);

Map<String, dynamic> _$CompareItemToJson(_CompareItem instance) =>
    <String, dynamic>{
      'itemId': instance.itemId,
      'title': instance.title,
      'wantSide': instance.wantSide,
    };

_CompareView _$CompareViewFromJson(Map<String, dynamic> json) => _CompareView(
  partnerAnswered: json['partnerAnswered'] as bool? ?? false,
  bothWant:
      (json['bothWant'] as List<dynamic>?)
          ?.map((e) => CompareItem.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <CompareItem>[],
  wantAndOk:
      (json['wantAndOk'] as List<dynamic>?)
          ?.map((e) => CompareItem.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <CompareItem>[],
  someoneTalks:
      (json['someoneTalks'] as List<dynamic>?)
          ?.map((e) => CompareItem.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <CompareItem>[],
  notDoing:
      (json['notDoing'] as List<dynamic>?)
          ?.map((e) => CompareItem.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <CompareItem>[],
);

Map<String, dynamic> _$CompareViewToJson(_CompareView instance) =>
    <String, dynamic>{
      'partnerAnswered': instance.partnerAnswered,
      'bothWant': instance.bothWant,
      'wantAndOk': instance.wantAndOk,
      'someoneTalks': instance.someoneTalks,
      'notDoing': instance.notDoing,
    };

_IdeaCard _$IdeaCardFromJson(Map<String, dynamic> json) => _IdeaCard(
  id: json['id'] as String,
  audience: json['audience'] as String,
  titleZh: json['titleZh'] as String,
  titleEn: json['titleEn'] as String,
  howZh: json['howZh'] as String,
  howEn: json['howEn'] as String,
  needsZh: json['needsZh'] as String?,
  needsEn: json['needsEn'] as String?,
  intensity: (json['intensity'] as num?)?.toInt() ?? 1,
  tags:
      (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const <String>[],
  relatedItemIds:
      (json['relatedItemIds'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const <String>[],
  state: json['state'] as String?,
);

Map<String, dynamic> _$IdeaCardToJson(_IdeaCard instance) => <String, dynamic>{
  'id': instance.id,
  'audience': instance.audience,
  'titleZh': instance.titleZh,
  'titleEn': instance.titleEn,
  'howZh': instance.howZh,
  'howEn': instance.howEn,
  'needsZh': instance.needsZh,
  'needsEn': instance.needsEn,
  'intensity': instance.intensity,
  'tags': instance.tags,
  'relatedItemIds': instance.relatedItemIds,
  'state': instance.state,
};

_IdeaCardActResult _$IdeaCardActResultFromJson(Map<String, dynamic> json) =>
    _IdeaCardActResult(
      taskId: json['taskId'] as String?,
      ruleId: json['ruleId'] as String?,
      noteId: json['noteId'] as String?,
      state: json['state'] as String?,
    );

Map<String, dynamic> _$IdeaCardActResultToJson(_IdeaCardActResult instance) =>
    <String, dynamic>{
      'taskId': instance.taskId,
      'ruleId': instance.ruleId,
      'noteId': instance.noteId,
      'state': instance.state,
    };

_StarterPackTask _$StarterPackTaskFromJson(Map<String, dynamic> json) =>
    _StarterPackTask(
      titleZh: json['titleZh'] as String,
      titleEn: json['titleEn'] as String,
      kind: json['kind'] as String? ?? 'checkin',
      schedule: json['schedule'] as Map<String, dynamic>?,
      dueTime: json['dueTime'] as String?,
      proof: json['proof'] as String? ?? 'check',
      pointsEarn: (json['pointsEarn'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$StarterPackTaskToJson(_StarterPackTask instance) =>
    <String, dynamic>{
      'titleZh': instance.titleZh,
      'titleEn': instance.titleEn,
      'kind': instance.kind,
      'schedule': instance.schedule,
      'dueTime': instance.dueTime,
      'proof': instance.proof,
      'pointsEarn': instance.pointsEarn,
    };

_StarterPackRule _$StarterPackRuleFromJson(Map<String, dynamic> json) =>
    _StarterPackRule(
      titleZh: json['titleZh'] as String,
      titleEn: json['titleEn'] as String,
      bodyZh: json['bodyZh'] as String?,
      bodyEn: json['bodyEn'] as String?,
      group: json['group'] as String? ?? 'other',
    );

Map<String, dynamic> _$StarterPackRuleToJson(_StarterPackRule instance) =>
    <String, dynamic>{
      'titleZh': instance.titleZh,
      'titleEn': instance.titleEn,
      'bodyZh': instance.bodyZh,
      'bodyEn': instance.bodyEn,
      'group': instance.group,
    };

_StarterPackReward _$StarterPackRewardFromJson(Map<String, dynamic> json) =>
    _StarterPackReward(
      titleZh: json['titleZh'] as String,
      titleEn: json['titleEn'] as String,
      cost: (json['cost'] as num?)?.toInt(),
    );

Map<String, dynamic> _$StarterPackRewardToJson(_StarterPackReward instance) =>
    <String, dynamic>{
      'titleZh': instance.titleZh,
      'titleEn': instance.titleEn,
      'cost': instance.cost,
    };

_StarterPack _$StarterPackFromJson(Map<String, dynamic> json) => _StarterPack(
  id: json['id'] as String,
  titleZh: json['titleZh'] as String,
  titleEn: json['titleEn'] as String,
  tasks:
      (json['tasks'] as List<dynamic>?)
          ?.map((e) => StarterPackTask.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <StarterPackTask>[],
  rules:
      (json['rules'] as List<dynamic>?)
          ?.map((e) => StarterPackRule.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <StarterPackRule>[],
  rewards:
      (json['rewards'] as List<dynamic>?)
          ?.map((e) => StarterPackReward.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <StarterPackReward>[],
);

Map<String, dynamic> _$StarterPackToJson(_StarterPack instance) =>
    <String, dynamic>{
      'id': instance.id,
      'titleZh': instance.titleZh,
      'titleEn': instance.titleEn,
      'tasks': instance.tasks,
      'rules': instance.rules,
      'rewards': instance.rewards,
    };

_DraftTask _$DraftTaskFromJson(Map<String, dynamic> json) => _DraftTask(
  title: json['title'] as String,
  detail: json['detail'] as String?,
  kind: json['kind'] as String? ?? 'checkin',
  schedule: json['schedule'] as Map<String, dynamic>?,
  dueTime: json['dueTime'] as String?,
  proof: json['proof'] as String? ?? 'check',
  pointsEarn: (json['pointsEarn'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$DraftTaskToJson(_DraftTask instance) =>
    <String, dynamic>{
      'title': instance.title,
      'detail': instance.detail,
      'kind': instance.kind,
      'schedule': instance.schedule,
      'dueTime': instance.dueTime,
      'proof': instance.proof,
      'pointsEarn': instance.pointsEarn,
    };

_DraftRule _$DraftRuleFromJson(Map<String, dynamic> json) => _DraftRule(
  title: json['title'] as String,
  body: json['body'] as String?,
  group: json['group'] as String? ?? 'other',
);

Map<String, dynamic> _$DraftRuleToJson(_DraftRule instance) =>
    <String, dynamic>{
      'title': instance.title,
      'body': instance.body,
      'group': instance.group,
    };

_DraftReward _$DraftRewardFromJson(Map<String, dynamic> json) => _DraftReward(
  title: json['title'] as String,
  detail: json['detail'] as String?,
  cost: (json['cost'] as num?)?.toInt(),
);

Map<String, dynamic> _$DraftRewardToJson(_DraftReward instance) =>
    <String, dynamic>{
      'title': instance.title,
      'detail': instance.detail,
      'cost': instance.cost,
    };

_PackDraft _$PackDraftFromJson(Map<String, dynamic> json) => _PackDraft(
  tasks:
      (json['tasks'] as List<dynamic>?)
          ?.map((e) => DraftTask.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <DraftTask>[],
  rules:
      (json['rules'] as List<dynamic>?)
          ?.map((e) => DraftRule.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <DraftRule>[],
  rewards:
      (json['rewards'] as List<dynamic>?)
          ?.map((e) => DraftReward.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <DraftReward>[],
);

Map<String, dynamic> _$PackDraftToJson(_PackDraft instance) =>
    <String, dynamic>{
      'tasks': instance.tasks,
      'rules': instance.rules,
      'rewards': instance.rewards,
    };

_PackApplyResult _$PackApplyResultFromJson(
  Map<String, dynamic> json,
) => _PackApplyResult(
  taskIds:
      (json['taskIds'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const <String>[],
  ruleIds:
      (json['ruleIds'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const <String>[],
  rewardIds:
      (json['rewardIds'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const <String>[],
);

Map<String, dynamic> _$PackApplyResultToJson(_PackApplyResult instance) =>
    <String, dynamic>{
      'taskIds': instance.taskIds,
      'ruleIds': instance.ruleIds,
      'rewardIds': instance.rewardIds,
    };
