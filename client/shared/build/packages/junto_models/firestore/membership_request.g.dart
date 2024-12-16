// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'membership_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_MembershipRequest _$$_MembershipRequestFromJson(Map<String, dynamic> json) =>
    _$_MembershipRequest(
      userId: json['userId'] as String,
      juntoId: json['juntoId'] as String,
      status: $enumDecodeNullable(
              _$MembershipRequestStatusEnumMap, json['status'],
              unknownValue: MembershipRequestStatus.requested) ??
          MembershipRequestStatus.requested,
    );

Map<String, dynamic> _$$_MembershipRequestToJson(
        _$_MembershipRequest instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'juntoId': instance.juntoId,
      'status': _$MembershipRequestStatusEnumMap[instance.status],
    };

const _$MembershipRequestStatusEnumMap = {
  MembershipRequestStatus.requested: 'requested',
  MembershipRequestStatus.approved: 'approved',
  MembershipRequestStatus.denied: 'denied',
};
