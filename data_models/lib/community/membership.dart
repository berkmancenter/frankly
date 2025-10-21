import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:data_models/cloud_functions/requests.dart';
import 'package:data_models/utils/firestore_utils.dart';

part 'membership.freezed.dart';
part 'membership.g.dart';

enum MembershipStatus {

  /// Person who created this space. Cannot be removed from the space.
  owner,

  /// Has elevated permissions to create/edit space content, and promote other members.
  admin,

  /// User that has elevated permissions to run meetings and
  /// create/edit content, cant promote other members.
  mod,

  /// No elevated permissions. When breakouts are created,
  /// facilitators are distributed between breakout rooms.
  facilitator,

  /// A user who has opted to join the community
  member,

  banned,

  /// A user who has not yet joined a community or attended an event or attended
  nonmember,

  /// User that joins the event and they are not members of that space
  attendee,
}

extension MembershipStatusExtension on MembershipStatus {
  bool get isNotBanned => this != MembershipStatus.banned;

  bool get isAttendee => [MembershipStatus.attendee].contains(this) || isMember;

  bool get isMember =>
      [MembershipStatus.member].contains(this) || isFacilitator;

  bool get isFacilitator =>
      [MembershipStatus.facilitator].contains(this) || isMod;

  bool get isMod => [MembershipStatus.mod].contains(this) || isAdmin;

  bool get isAdmin => [MembershipStatus.admin].contains(this) || isOwner;

  bool get isOwner => this == MembershipStatus.owner;
}

@Freezed(makeCollectionsUnmodifiable: false)
class Membership with _$Membership implements SerializeableRequest {
  static const String kFieldStatus = 'status';
  static const String kFieldUserId = 'userId';
  static const String kFieldCommunityId = 'communityId';
  static const String kFieldFirstJoined = 'firstJoined';
  static const String kFieldInvisible = 'invisible';

  factory Membership({
    required String userId,
    required String communityId,
    @JsonKey(unknownEnumValue: null) MembershipStatus? status,
    @JsonKey(fromJson: dateTimeFromTimestamp, toJson: serverTimestamp)
    DateTime? firstJoined,
    @Default(false) bool invisible,
  }) = _Membership;

  // Necessary to have the custom getters below
  Membership._();

  factory Membership.fromJson(Map<String, dynamic> json) =>
      _$MembershipFromJson(json);

  bool get isAttendee => status?.isAttendee ?? false;

  bool get isMember => status?.isMember ?? false;

  bool get isFacilitator => status?.isFacilitator ?? false;

  bool get isMod => status?.isMod ?? false;

  bool get isAdmin => status?.isAdmin ?? false;
}
