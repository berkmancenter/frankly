import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:data_models/utils/firestore_utils.dart';

part 'announcement.freezed.dart';
part 'announcement.g.dart';

enum AnnouncementStatus {
  active,
  removed,
}

@Freezed(makeCollectionsUnmodifiable: false)
class Announcement with _$Announcement {
  static const String kFieldAnnouncementStatus = 'announcementStatus';

  factory Announcement({
    String? id,
    @Default(AnnouncementStatus.active)
    @JsonKey(
        defaultValue: AnnouncementStatus.active,
        unknownEnumValue: AnnouncementStatus.active)
    AnnouncementStatus announcementStatus,
    String? creatorId,
    String? creatorDisplayName,
    @JsonKey(fromJson: dateTimeFromTimestamp, toJson: serverTimestamp)
    DateTime? createdDate,
    String? title,
    String? message,
  }) = _Announcement;

  factory Announcement.fromJson(Map<String, dynamic> json) =>
      _$AnnouncementFromJson(json);

  static Map<String, dynamic>? toJsonForCloudFunction(
      Announcement? announcement) {
    if (announcement == null) return {};

    return announcement.toJson()..remove('createdDate');
  }
}
