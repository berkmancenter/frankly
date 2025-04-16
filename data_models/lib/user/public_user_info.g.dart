// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'public_user_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_PublicUserInfo _$$_PublicUserInfoFromJson(Map<String, dynamic> json) =>
    _$_PublicUserInfo(
      id: json['id'] as String,
      agoraId: json['agoraId'] as int,
      displayName: json['displayName'] as String?,
      imageUrl: json['imageUrl'] as String?,
      about: json['about'] as String? ?? '',
      socialMediaItems: (json['socialMediaItems'] as List<dynamic>?)
              ?.map((e) => SocialMediaItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      appRole: $enumDecodeNullable(_$AppRoleEnumMap, json['appRole']) ??
          AppRole.user,
    );

Map<String, dynamic> _$$_PublicUserInfoToJson(_$_PublicUserInfo instance) =>
    <String, dynamic>{
      'id': instance.id,
      'agoraId': instance.agoraId,
      'displayName': instance.displayName,
      'imageUrl': instance.imageUrl,
      'about': instance.about,
      'socialMediaItems':
          instance.socialMediaItems.map((e) => e.toJson()).toList(),
      'appRole': _$AppRoleEnumMap[instance.appRole],
    };

const _$AppRoleEnumMap = {
  AppRole.owner: 'owner',
  AppRole.user: 'user',
};

_$_SocialMediaItem _$$_SocialMediaItemFromJson(Map<String, dynamic> json) =>
    _$_SocialMediaItem(
      url: json['url'] as String?,
      socialMediaKey:
          $enumDecodeNullable(_$SocialMediaKeyEnumMap, json['socialMediaKey']),
    );

Map<String, dynamic> _$$_SocialMediaItemToJson(_$_SocialMediaItem instance) =>
    <String, dynamic>{
      'url': instance.url,
      'socialMediaKey': _$SocialMediaKeyEnumMap[instance.socialMediaKey],
    };

const _$SocialMediaKeyEnumMap = {
  SocialMediaKey.instagram: 'instagram',
  SocialMediaKey.twitter: 'twitter',
  SocialMediaKey.facebook: 'facebook',
  SocialMediaKey.linkedin: 'linkedin',
};
