import 'package:freezed_annotation/freezed_annotation.dart';

part 'external_partners.freezed.dart';
part 'external_partners.g.dart';

@Freezed(makeCollectionsUnmodifiable: false)
class MeetingOfAmerica with _$MeetingOfAmerica {
  static const docId = 'meetingofamerica';

  const MeetingOfAmerica._();

  factory MeetingOfAmerica({
    @Default([]) List<String> pilotPartners,
  }) = _MeetingOfAmerica;

  factory MeetingOfAmerica.fromJson(Map<String, dynamic> json) => _$MeetingOfAmericaFromJson(json);
}

@Freezed(makeCollectionsUnmodifiable: false)
class UnifyAmerica with _$UnifyAmerica {
  static const docId = 'unify-america';

  const UnifyAmerica._();

  factory UnifyAmerica({
    String? automaticRecordingUploadDriveFolderId,
  }) = _UnifyAmerica;

  factory UnifyAmerica.fromJson(Map<String, dynamic> json) => _$UnifyAmericaFromJson(json);
}
