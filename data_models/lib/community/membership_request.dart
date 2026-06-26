import 'package:data_models/community/membership.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'membership_request.freezed.dart';
part 'membership_request.g.dart';

enum MembershipRequestStatus { requested, approved, denied }

@Freezed(makeCollectionsUnmodifiable: false)
class MembershipRequest with _$MembershipRequest {
  factory MembershipRequest({
    required String userId,
    required String communityId,
    @Default(MembershipRequestStatus.requested)
    @JsonKey(unknownEnumValue: MembershipRequestStatus.requested)
    MembershipRequestStatus? status,
    @JsonKey(unknownEnumValue: MembershipStatus.member)
    MembershipStatus? role,
  }) = _MembershipRequest;

  factory MembershipRequest.fromJson(Map<String, dynamic> json) =>
      _$MembershipRequestFromJson(json);
}
