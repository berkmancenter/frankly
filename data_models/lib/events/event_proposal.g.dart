// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event_proposal.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_EventProposalVote _$$_EventProposalVoteFromJson(Map<String, dynamic> json) =>
    _$_EventProposalVote(
      voterUserId: json['voterUserId'] as String?,
      inFavor: json['inFavor'] as bool?,
      reason: json['reason'] as String?,
    );

Map<String, dynamic> _$$_EventProposalVoteToJson(
        _$_EventProposalVote instance) =>
    <String, dynamic>{
      'voterUserId': instance.voterUserId,
      'inFavor': instance.inFavor,
      'reason': instance.reason,
    };

_$_EventProposal _$$_EventProposalFromJson(Map<String, dynamic> json) =>
    _$_EventProposal(
      id: json['id'] as String?,
      type: $enumDecodeNullable(_$EventProposalTypeEnumMap, json['type']) ??
          EventProposalType.kick,
      status:
          $enumDecodeNullable(_$EventProposalStatusEnumMap, json['status']) ??
              EventProposalStatus.open,
      initiatingUserId: json['initiatingUserId'] as String?,
      targetUserId: json['targetUserId'] as String?,
      votes: (json['votes'] as List<dynamic>?)
          ?.map((e) => EventProposalVote.fromJson(e as Map<String, dynamic>))
          .toList(),
      createdAt: dateTimeFromTimestamp(json['createdAt']),
      closedAt: dateTimeFromTimestamp(json['closedAt']),
    );

Map<String, dynamic> _$$_EventProposalToJson(_$_EventProposal instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': _$EventProposalTypeEnumMap[instance.type]!,
      'status': _$EventProposalStatusEnumMap[instance.status]!,
      'initiatingUserId': instance.initiatingUserId,
      'targetUserId': instance.targetUserId,
      'votes': instance.votes?.map((e) => e.toJson()).toList(),
      'createdAt': timestampFromDateTime(instance.createdAt),
      'closedAt': timestampFromDateTime(instance.closedAt),
    };

const _$EventProposalTypeEnumMap = {
  EventProposalType.kick: 'kick',
};

const _$EventProposalStatusEnumMap = {
  EventProposalStatus.open: 'open',
  EventProposalStatus.accepted: 'accepted',
  EventProposalStatus.rejected: 'rejected',
};
