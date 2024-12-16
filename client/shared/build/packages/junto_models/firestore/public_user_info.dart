import 'package:freezed_annotation/freezed_annotation.dart';

part 'public_user_info.freezed.dart';
part 'public_user_info.g.dart';

@Freezed(makeCollectionsUnmodifiable: false)
class PublicUserInfo with _$PublicUserInfo {
  static const String kFieldAgoraId = 'agoraId';

  factory PublicUserInfo({
    required String id,
    required int agoraId,
    String? displayName,
    String? imageUrl,
    @Default('') String? about,
    @Default([]) List<SocialMediaItem> socialMediaItems,
  }) = _PublicUserInfo;

  factory PublicUserInfo.fromJson(Map<String, dynamic> json) => _$PublicUserInfoFromJson(json);
}

enum SocialMediaKey { instagram, twitter, facebook, linkedin }

@Freezed(makeCollectionsUnmodifiable: false)
class SocialMediaItem with _$SocialMediaItem {
  factory SocialMediaItem({
    String? url,
    @JsonKey(unknownEnumValue: null) SocialMediaKey? socialMediaKey,
  }) = _SocialMediaItem;

  factory SocialMediaItem.fromJson(Map<String, dynamic> json) => _$SocialMediaItemFromJson(json);
}
