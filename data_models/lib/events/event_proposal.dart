import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:data_models/utils/firestore_utils.dart';

part 'event_proposal.freezed.dart';
part 'event_proposal.g.dart';

enum EventProposalType {
  kick,
}

enum EventProposalStatus {
  open,
  accepted,
  rejected,
}

@Freezed(makeCollectionsUnmodifiable: false)
class EventProposalVote with _$EventProposalVote {
  factory EventProposalVote({
    String? voterUserId,
    bool? inFavor,
    String? reason,
  }) = _EventProposalVote;

  factory EventProposalVote.fromJson(Map<String, dynamic> json) =>
      _$EventProposalVoteFromJson(json);
}

@Freezed(makeCollectionsUnmodifiable: false)
class EventProposal with _$EventProposal {
  static const String kFieldStatus = 'status';
  static const String kFieldVotes = 'votes';
  static const String kFieldClosedAt = 'closedAt';
  static const String kFieldType = 'type';
  static const String kFieldTargetUserId = 'targetUserId';

  factory EventProposal({
    String? id,
    @Default(EventProposalType.kick)
    @JsonKey(defaultValue: EventProposalType.kick, unknownEnumValue: null)
    EventProposalType type,
    @Default(EventProposalStatus.open)
    @JsonKey(defaultValue: EventProposalStatus.open, unknownEnumValue: null)
    EventProposalStatus status,
    String? initiatingUserId,
    String? targetUserId,
    List<EventProposalVote>? votes,
    @JsonKey(fromJson: dateTimeFromTimestamp, toJson: timestampFromDateTime)
    DateTime? createdAt,
    @JsonKey(fromJson: dateTimeFromTimestamp, toJson: timestampFromDateTime)
    DateTime? closedAt,
  }) = _EventProposal;

  factory EventProposal.fromJson(Map<String, dynamic> json) =>
      _$EventProposalFromJson(json);
}
