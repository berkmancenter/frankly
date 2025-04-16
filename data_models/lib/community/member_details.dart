import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:data_models/events/event.dart';
import 'package:data_models/community/membership.dart';

part 'member_details.freezed.dart';
part 'member_details.g.dart';

@Freezed(makeCollectionsUnmodifiable: false)
class MemberDetails with _$MemberDetails {
  factory MemberDetails({
    required String id,
    String? email,
    String? displayName,
    Membership? membership,
    MemberEventData? memberEvent,
  }) = _MemberDetails;

  factory MemberDetails.fromJson(Map<String, dynamic> json) =>
      _$MemberDetailsFromJson(json);
}

@Freezed(makeCollectionsUnmodifiable: false)
class MemberEventData with _$MemberEventData {
  factory MemberEventData({
    String? templateId,
    String? eventId,
    Participant? participant,
  }) = _MemberEventData;

  factory MemberEventData.fromJson(Map<String, dynamic> json) =>
      _$MemberEventDataFromJson(json);
}
