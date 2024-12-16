import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:junto_models/firestore/utils.dart';

part 'discussion_proposal.freezed.dart';
part 'discussion_proposal.g.dart';

enum DiscussionProposalType {
  kick,
}

enum DiscussionProposalStatus {
  open,
  accepted,
  rejected,
}

@Freezed(makeCollectionsUnmodifiable: false)
class DiscussionProposalVote with _$DiscussionProposalVote {
  factory DiscussionProposalVote({
    String? voterUserId,
    bool? inFavor,
    String? reason,
  }) = _DiscussionProposalVote;

  factory DiscussionProposalVote.fromJson(Map<String, dynamic> json) =>
      _$DiscussionProposalVoteFromJson(json);
}

@Freezed(makeCollectionsUnmodifiable: false)
class DiscussionProposal with _$DiscussionProposal {
  static const String kFieldStatus = 'status';
  static const String kFieldVotes = 'votes';
  static const String kFieldClosedAt = 'closedAt';
  static const String kFieldType = 'type';
  static const String kFieldTargetUserId = 'targetUserId';

  factory DiscussionProposal({
    String? id,
    @Default(DiscussionProposalType.kick)
    @JsonKey(defaultValue: DiscussionProposalType.kick, unknownEnumValue: null)
        DiscussionProposalType type,
    @Default(DiscussionProposalStatus.open)
    @JsonKey(defaultValue: DiscussionProposalStatus.open, unknownEnumValue: null)
        DiscussionProposalStatus status,
    String? initiatingUserId,
    String? targetUserId,
    List<DiscussionProposalVote>? votes,
    @JsonKey(fromJson: dateTimeFromTimestamp, toJson: timestampFromDateTime) DateTime? createdAt,
    @JsonKey(fromJson: dateTimeFromTimestamp, toJson: timestampFromDateTime) DateTime? closedAt,
  }) = _DiscussionProposal;

  factory DiscussionProposal.fromJson(Map<String, dynamic> json) =>
      _$DiscussionProposalFromJson(json);
}
