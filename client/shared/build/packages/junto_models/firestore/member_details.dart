import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:junto_models/firestore/discussion.dart';
import 'package:junto_models/firestore/membership.dart';

part 'member_details.freezed.dart';
part 'member_details.g.dart';

@Freezed(makeCollectionsUnmodifiable: false)
class MemberDetails with _$MemberDetails {
  factory MemberDetails({
    required String id,
    String? email,
    String? displayName,
    Membership? membership,
    MemberDiscussionData? memberDiscussion,
  }) = _MemberDetails;

  factory MemberDetails.fromJson(Map<String, dynamic> json) => _$MemberDetailsFromJson(json);
}

@Freezed(makeCollectionsUnmodifiable: false)
class MemberDiscussionData with _$MemberDiscussionData {
  factory MemberDiscussionData({
    String? topicId,
    String? discussionId,
    Participant? participant,
  }) = _MemberDiscussionData;

  factory MemberDiscussionData.fromJson(Map<String, dynamic> json) =>
      _$MemberDiscussionDataFromJson(json);
}
