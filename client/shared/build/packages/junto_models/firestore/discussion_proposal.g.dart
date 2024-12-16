// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'discussion_proposal.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_DiscussionProposalVote _$$_DiscussionProposalVoteFromJson(
        Map<String, dynamic> json) =>
    _$_DiscussionProposalVote(
      voterUserId: json['voterUserId'] as String?,
      inFavor: json['inFavor'] as bool?,
      reason: json['reason'] as String?,
    );

Map<String, dynamic> _$$_DiscussionProposalVoteToJson(
        _$_DiscussionProposalVote instance) =>
    <String, dynamic>{
      'voterUserId': instance.voterUserId,
      'inFavor': instance.inFavor,
      'reason': instance.reason,
    };

_$_DiscussionProposal _$$_DiscussionProposalFromJson(
        Map<String, dynamic> json) =>
    _$_DiscussionProposal(
      id: json['id'] as String?,
      type:
          $enumDecodeNullable(_$DiscussionProposalTypeEnumMap, json['type']) ??
              DiscussionProposalType.kick,
      status: $enumDecodeNullable(
              _$DiscussionProposalStatusEnumMap, json['status']) ??
          DiscussionProposalStatus.open,
      initiatingUserId: json['initiatingUserId'] as String?,
      targetUserId: json['targetUserId'] as String?,
      votes: (json['votes'] as List<dynamic>?)
          ?.map(
              (e) => DiscussionProposalVote.fromJson(e as Map<String, dynamic>))
          .toList(),
      createdAt: dateTimeFromTimestamp(json['createdAt']),
      closedAt: dateTimeFromTimestamp(json['closedAt']),
    );

Map<String, dynamic> _$$_DiscussionProposalToJson(
        _$_DiscussionProposal instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': _$DiscussionProposalTypeEnumMap[instance.type]!,
      'status': _$DiscussionProposalStatusEnumMap[instance.status]!,
      'initiatingUserId': instance.initiatingUserId,
      'targetUserId': instance.targetUserId,
      'votes': instance.votes?.map((e) => e.toJson()).toList(),
      'createdAt': timestampFromDateTime(instance.createdAt),
      'closedAt': timestampFromDateTime(instance.closedAt),
    };

const _$DiscussionProposalTypeEnumMap = {
  DiscussionProposalType.kick: 'kick',
};

const _$DiscussionProposalStatusEnumMap = {
  DiscussionProposalStatus.open: 'open',
  DiscussionProposalStatus.accepted: 'accepted',
  DiscussionProposalStatus.rejected: 'rejected',
};
