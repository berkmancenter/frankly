// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pre_post_url_params.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_PrePostUrlParams _$$_PrePostUrlParamsFromJson(Map<String, dynamic> json) =>
    _$_PrePostUrlParams(
      buttonText: json['buttonText'] as String?,
      surveyUrl: json['surveyUrl'] as String?,
      attributes: (json['attributes'] as List<dynamic>?)
              ?.map((e) =>
                  PrePostCardAttribute.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$_PrePostUrlParamsToJson(_$_PrePostUrlParams instance) =>
    <String, dynamic>{
      'buttonText': instance.buttonText,
      'surveyUrl': instance.surveyUrl,
      'attributes': instance.attributes.map((e) => e.toJson()).toList(),
    };
