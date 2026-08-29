// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'invite_view.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_InviteView _$InviteViewFromJson(Map<String, dynamic> json) => _InviteView(
  state: $enumDecode(_$InviteStateEnumMap, json['state']),
  inviteId: json['inviteId'] as String?,
  dynamicId: json['dynamicId'] as String?,
  intendedRoleContext: json['intendedRoleContext'] as String?,
  inviterDisplayName: json['inviterDisplayName'] as String?,
);

Map<String, dynamic> _$InviteViewToJson(_InviteView instance) =>
    <String, dynamic>{
      'state': _$InviteStateEnumMap[instance.state]!,
      'inviteId': instance.inviteId,
      'dynamicId': instance.dynamicId,
      'intendedRoleContext': instance.intendedRoleContext,
      'inviterDisplayName': instance.inviterDisplayName,
    };

const _$InviteStateEnumMap = {
  InviteState.pending: 'PENDING',
  InviteState.accepted: 'ACCEPTED',
  InviteState.expired: 'EXPIRED',
  InviteState.revoked: 'REVOKED',
  InviteState.notFound: 'NOT_FOUND',
};
