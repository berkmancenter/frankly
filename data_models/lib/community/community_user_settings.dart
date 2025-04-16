import 'package:freezed_annotation/freezed_annotation.dart';

part 'community_user_settings.freezed.dart';
part 'community_user_settings.g.dart';

enum NotificationEmailType {
  none,
  immediate,
}

@Freezed(makeCollectionsUnmodifiable: false)
class CommunityUserSettings with _$CommunityUserSettings {
  static const String kFieldUserId = 'userId';
  static const String kFieldCommunityId = 'communityId';
  static const String kFieldNotifyAnnouncements = 'notifyAnnouncements';
  static const String kFieldNotifyEvents = 'notifyEvents';

  factory CommunityUserSettings({
    String? userId,
    String? communityId,
    @JsonKey(unknownEnumValue: null) NotificationEmailType? notifyEvents,
    @JsonKey(unknownEnumValue: null) NotificationEmailType? notifyAnnouncements,
  }) = _CommunityUserSettings;

  factory CommunityUserSettings.fromJson(Map<String, dynamic> json) =>
      _$CommunityUserSettingsFromJson(json);
}
