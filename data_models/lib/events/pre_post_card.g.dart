// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pre_post_card.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_PrePostCard _$$_PrePostCardFromJson(Map<String, dynamic> json) =>
    _$_PrePostCard(
      headline: json['headline'] as String,
      message: json['message'] as String,
      type: $enumDecode(_$PrePostCardTypeEnumMap, json['type']),
      prePostUrls: (json['prePostUrls'] as List<dynamic>?)
              ?.map((e) => PrePostUrlParams.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$_PrePostCardToJson(_$_PrePostCard instance) =>
    <String, dynamic>{
      'headline': instance.headline,
      'message': instance.message,
      'type': _$PrePostCardTypeEnumMap[instance.type]!,
      'prePostUrls': instance.prePostUrls.map((e) => e.toJson()).toList(),
    };

const _$PrePostCardTypeEnumMap = {
  PrePostCardType.preEvent: 'preEvent',
  PrePostCardType.postEvent: 'postEvent',
};
