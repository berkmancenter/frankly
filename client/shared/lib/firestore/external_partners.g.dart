// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'external_partners.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_MeetingOfAmerica _$$_MeetingOfAmericaFromJson(Map<String, dynamic> json) =>
    _$_MeetingOfAmerica(
      pilotPartners: (json['pilotPartners'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$_MeetingOfAmericaToJson(_$_MeetingOfAmerica instance) =>
    <String, dynamic>{
      'pilotPartners': instance.pilotPartners,
    };

_$_UnifyAmerica _$$_UnifyAmericaFromJson(Map<String, dynamic> json) =>
    _$_UnifyAmerica(
      automaticRecordingUploadDriveFolderId:
          json['automaticRecordingUploadDriveFolderId'] as String?,
    );

Map<String, dynamic> _$$_UnifyAmericaToJson(_$_UnifyAmerica instance) =>
    <String, dynamic>{
      'automaticRecordingUploadDriveFolderId':
          instance.automaticRecordingUploadDriveFolderId,
    };
