// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'word_cloud_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_WordCloudData _$$_WordCloudDataFromJson(Map<String, dynamic> json) =>
    _$_WordCloudData(
      userId: json['userId'] as String,
      agendaItemId: json['agendaItemId'] as String,
      roomId: json['roomId'] as String,
      prompt: json['prompt'] as String,
      message: json['message'] as String,
      createdDate: json['createdDate'] == null
          ? null
          : DateTime.parse(json['createdDate'] as String),
      upvotes: json['upvotes'] as int? ?? 0,
    );

Map<String, dynamic> _$$_WordCloudDataToJson(_$_WordCloudData instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'agendaItemId': instance.agendaItemId,
      'roomId': instance.roomId,
      'prompt': instance.prompt,
      'message': instance.message,
      'createdDate': instance.createdDate?.toIso8601String(),
      'upvotes': instance.upvotes,
    };
