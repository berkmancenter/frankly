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
      memberDiscussion: json['memberDiscussion'] == null
          ? null
          : MemberDiscussionData.fromJson(
              json['memberDiscussion'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$_MemberDetailsToJson(_$_MemberDetails instance) =>
    <String, dynamic>{
      'id': instance.id,
      'email': instance.email,
      'displayName': instance.displayName,
      'membership': instance.membership?.toJson(),
      'memberDiscussion': instance.memberDiscussion?.toJson(),
    };

_$_MemberDiscussionData _$$_MemberDiscussionDataFromJson(
        Map<String, dynamic> json) =>
    _$_MemberDiscussionData(
      topicId: json['topicId'] as String?,
      discussionId: json['discussionId'] as String?,
      participant: json['participant'] == null
          ? null
          : Participant.fromJson(json['participant'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$_MemberDiscussionDataToJson(
        _$_MemberDiscussionData instance) =>
    <String, dynamic>{
      'topicId': instance.topicId,
      'discussionId': instance.discussionId,
      'participant': instance.participant?.toJson(),
    };
