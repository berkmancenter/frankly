// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'membership.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_Membership _$$_MembershipFromJson(Map<String, dynamic> json) =>
    _$_Membership(
      userId: json['userId'] as String,
      communityId: json['communityId'] as String,
      status: $enumDecodeNullable(_$MembershipStatusEnumMap, json['status']),
      firstJoined: dateTimeFromTimestamp(json['firstJoined']),
      invisible: json['invisible'] as bool? ?? false,
    );

Map<String, dynamic> _$$_MembershipToJson(_$_Membership instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'communityId': instance.communityId,
      'status': _$MembershipStatusEnumMap[instance.status],
      'firstJoined': serverTimestamp(instance.firstJoined),
      'invisible': instance.invisible,
    };

const _$MembershipStatusEnumMap = {
  MembershipStatus.banned: 'banned',
  MembershipStatus.nonmember: 'nonmember',
  MembershipStatus.attendee: 'attendee',
  MembershipStatus.member: 'member',
  MembershipStatus.facilitator: 'facilitator',
  MembershipStatus.mod: 'mod',
  MembershipStatus.admin: 'admin',
  MembershipStatus.owner: 'owner',
};
