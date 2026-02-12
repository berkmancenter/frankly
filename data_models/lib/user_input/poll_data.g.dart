// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'poll_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_PollData _$$_PollDataFromJson(Map<String, dynamic> json) => _$_PollData(
      id: json['id'] as String?,
      userId: json['userId'] as String?,
      userEmail: json['userEmail'] as String?,
      userName: json['userName'] as String?,
      answeredDate: json['answeredDate'] == null
          ? null
          : DateTime.parse(json['answeredDate'] as String),
      pollResponse: json['pollResponse'] as String?,
      roomId: json['roomId'] as String?,
      agendaItemId: json['agendaItemId'] as String?,
      agendaItemTitle: json['agendaItemTitle'] as String?,
      pollQuestion: json['pollQuestion'] as String?,
    );

Map<String, dynamic> _$$_PollDataToJson(_$_PollData instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'userEmail': instance.userEmail,
      'userName': instance.userName,
      'answeredDate': instance.answeredDate?.toIso8601String(),
      'pollResponse': instance.pollResponse,
      'roomId': instance.roomId,
      'agendaItemId': instance.agendaItemId,
      'agendaItemTitle': instance.agendaItemTitle,
      'pollQuestion': instance.pollQuestion,
    };
