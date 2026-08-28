// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'membership_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_MembershipRequest _$$_MembershipRequestFromJson(Map<String, dynamic> json) =>
    _$_MembershipRequest(
      userId: json['userId'] as String,
      communityId: json['communityId'] as String,
      status: $enumDecodeNullable(
              _$MembershipRequestStatusEnumMap, json['status']) ??
          MembershipRequestStatus.requested,
      role: $enumDecodeNullable(_$MembershipStatusEnumMap, json['role']),
    );

Map<String, dynamic> _$$_MembershipRequestToJson(
        _$_MembershipRequest instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'communityId': instance.communityId,
      'status': _$MembershipRequestStatusEnumMap[instance.status],
      'role': _$MembershipStatusEnumMap[instance.role],
    };

const _$MembershipRequestStatusEnumMap = {
  MembershipRequestStatus.requested: 'requested',
  MembershipRequestStatus.approved: 'approved',
  MembershipRequestStatus.denied: 'denied',
};

const _$MembershipStatusEnumMap = {
  MembershipStatus.owner: 'owner',
  MembershipStatus.admin: 'admin',
  MembershipStatus.moderator: 'moderator',
  MembershipStatus.facilitator: 'facilitator',
  MembershipStatus.member: 'member',
  MembershipStatus.banned: 'banned',
  MembershipStatus.nonmember: 'nonmember',
  MembershipStatus.attendee: 'attendee',
};
