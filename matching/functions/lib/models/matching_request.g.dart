// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'matching_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MatchingRequest _$MatchingRequestFromJson(Map<String, dynamic> json) =>
    MatchingRequest(
      targetGroupSize: (json['targetGroupSize'] as num?)?.toInt(),
      googleSheetId: json['googleSheetId'] as String,
    );

Map<String, dynamic> _$MatchingRequestToJson(MatchingRequest instance) =>
    <String, dynamic>{
      'targetGroupSize': instance.targetGroupSize,
      'googleSheetId': instance.googleSheetId,
    };
