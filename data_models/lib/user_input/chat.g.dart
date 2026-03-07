// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_ChatMessage _$$_ChatMessageFromJson(Map<String, dynamic> json) =>
    _$_ChatMessage(
      id: json['id'] as String?,
      collectionPath: json['collectionPath'] as String?,
      message: json['message'] as String?,
      emotionType:
          $enumDecodeNullable(_$EmotionTypeEnumMap, json['emotionType']),
      creatorId: json['creatorId'] as String?,
      createdDate: dateTimeFromTimestamp(json['createdDate']),
      messageStatus: $enumDecodeNullable(
              _$ChatMessageStatusEnumMap, json['messageStatus'],
              unknownValue: ChatMessageStatus.active) ??
          ChatMessageStatus.active,
      membershipStatusSnapshot: $enumDecodeNullable(
          _$MembershipStatusEnumMap, json['membershipStatusSnapshot']),
      broadcast: json['broadcast'] as bool? ?? false,
    );

Map<String, dynamic> _$$_ChatMessageToJson(_$_ChatMessage instance) =>
    <String, dynamic>{
      'id': instance.id,
      'collectionPath': instance.collectionPath,
      'message': instance.message,
      'emotionType': _$EmotionTypeEnumMap[instance.emotionType],
      'creatorId': instance.creatorId,
      'createdDate': serverTimestamp(instance.createdDate),
      'messageStatus': _$ChatMessageStatusEnumMap[instance.messageStatus]!,
      'membershipStatusSnapshot':
          _$MembershipStatusEnumMap[instance.membershipStatusSnapshot],
      'broadcast': instance.broadcast,
    };

const _$EmotionTypeEnumMap = {
  EmotionType.thumbsUp: 'thumbsUp',
  EmotionType.heart: 'heart',
  EmotionType.hundred: 'hundred',
  EmotionType.exclamation: 'exclamation',
  EmotionType.plusOne: 'plusOne',
  EmotionType.laughWithTears: 'laughWithTears',
  EmotionType.heartEyes: 'heartEyes',
};

const _$ChatMessageStatusEnumMap = {
  ChatMessageStatus.active: 'active',
  ChatMessageStatus.removed: 'removed',
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
