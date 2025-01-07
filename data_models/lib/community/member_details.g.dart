// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'member_details.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_MemberDetails _$$_MemberDetailsFromJson(Map<String, dynamic> json) =>
    _$_MemberDetails(
      id: json['id'] as String,
      email: json['email'] as String?,
      displayName: json['displayName'] as String?,
      membership: json['membership'] == null
          ? null
          : Membership.fromJson(json['membership'] as Map<String, dynamic>),
      memberEvent: json['memberEvent'] == null
          ? null
          : MemberEventData.fromJson(
              json['memberEvent'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$_MemberDetailsToJson(_$_MemberDetails instance) =>
    <String, dynamic>{
      'id': instance.id,
      'email': instance.email,
      'displayName': instance.displayName,
      'membership': instance.membership?.toJson(),
      'memberEvent': instance.memberEvent?.toJson(),
    };

_$_MemberEventData _$$_MemberEventDataFromJson(Map<String, dynamic> json) =>
    _$_MemberEventData(
      templateId: json['templateId'] as String?,
      eventId: json['eventId'] as String?,
      participant: json['participant'] == null
          ? null
          : Participant.fromJson(json['participant'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$_MemberEventDataToJson(_$_MemberEventData instance) =>
    <String, dynamic>{
      'templateId': instance.templateId,
      'eventId': instance.eventId,
      'participant': instance.participant?.toJson(),
    };
