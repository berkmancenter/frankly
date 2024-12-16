import 'package:freezed_annotation/freezed_annotation.dart';

part 'junto_user_settings.freezed.dart';
part 'junto_user_settings.g.dart';

enum NotificationEmailType {
  none,
  immediate,
}

@Freezed(makeCollectionsUnmodifiable: false)
class JuntoUserSettings with _$JuntoUserSettings {
  static const String kFieldUserId = 'userId';
  static const String kFieldJuntoId = 'juntoId';
  static const String kFieldNotifyAnnouncements = 'notifyAnnouncements';
  static const String kFieldNotifyEvents = 'notifyEvents';

  factory JuntoUserSettings({
    String? userId,
    String? juntoId,
    @JsonKey(unknownEnumValue: null) NotificationEmailType? notifyEvents,
    @JsonKey(unknownEnumValue: null) NotificationEmailType? notifyAnnouncements,
  }) = _JuntoUserSettings;

  factory JuntoUserSettings.fromJson(Map<String, dynamic> json) =>
      _$JuntoUserSettingsFromJson(json);
}
