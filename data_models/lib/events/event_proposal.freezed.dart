// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'event_proposal.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

EventProposalVote _$EventProposalVoteFromJson(Map<String, dynamic> json) {
  return _EventProposalVote.fromJson(json);
}

/// @nodoc
mixin _$EventProposalVote {
  String? get voterUserId => throw _privateConstructorUsedError;
  bool? get inFavor => throw _privateConstructorUsedError;
  String? get reason => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $EventProposalVoteCopyWith<EventProposalVote> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $EventProposalVoteCopyWith<$Res> {
  factory $EventProposalVoteCopyWith(
          EventProposalVote value, $Res Function(EventProposalVote) then) =
      _$EventProposalVoteCopyWithImpl<$Res, EventProposalVote>;
  @useResult
  $Res call({String? voterUserId, bool? inFavor, String? reason});
}

/// @nodoc
class _$EventProposalVoteCopyWithImpl<$Res, $Val extends EventProposalVote>
    implements $EventProposalVoteCopyWith<$Res> {
  _$EventProposalVoteCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? voterUserId = freezed,
    Object? inFavor = freezed,
    Object? reason = freezed,
  }) {
    return _then(_value.copyWith(
      voterUserId: freezed == voterUserId
          ? _value.voterUserId
          : voterUserId // ignore: cast_nullable_to_non_nullable
              as String?,
      inFavor: freezed == inFavor
          ? _value.inFavor
          : inFavor // ignore: cast_nullable_to_non_nullable
              as bool?,
      reason: freezed == reason
          ? _value.reason
          : reason // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_EventProposalVoteCopyWith<$Res>
    implements $EventProposalVoteCopyWith<$Res> {
  factory _$$_EventProposalVoteCopyWith(_$_EventProposalVote value,
          $Res Function(_$_EventProposalVote) then) =
      __$$_EventProposalVoteCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String? voterUserId, bool? inFavor, String? reason});
}

/// @nodoc
class __$$_EventProposalVoteCopyWithImpl<$Res>
    extends _$EventProposalVoteCopyWithImpl<$Res, _$_EventProposalVote>
    implements _$$_EventProposalVoteCopyWith<$Res> {
  __$$_EventProposalVoteCopyWithImpl(
      _$_EventProposalVote _value, $Res Function(_$_EventProposalVote) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? voterUserId = freezed,
    Object? inFavor = freezed,
    Object? reason = freezed,
  }) {
    return _then(_$_EventProposalVote(
      voterUserId: freezed == voterUserId
          ? _value.voterUserId
          : voterUserId // ignore: cast_nullable_to_non_nullable
              as String?,
      inFavor: freezed == inFavor
          ? _value.inFavor
          : inFavor // ignore: cast_nullable_to_non_nullable
              as bool?,
      reason: freezed == reason
          ? _value.reason
          : reason // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_EventProposalVote implements _EventProposalVote {
  _$_EventProposalVote({this.voterUserId, this.inFavor, this.reason});

  factory _$_EventProposalVote.fromJson(Map<String, dynamic> json) =>
      _$$_EventProposalVoteFromJson(json);

  @override
  final String? voterUserId;
  @override
  final bool? inFavor;
  @override
  final String? reason;

  @override
  String toString() {
    return 'EventProposalVote(voterUserId: $voterUserId, inFavor: $inFavor, reason: $reason)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_EventProposalVote &&
            (identical(other.voterUserId, voterUserId) ||
                other.voterUserId == voterUserId) &&
            (identical(other.inFavor, inFavor) || other.inFavor == inFavor) &&
            (identical(other.reason, reason) || other.reason == reason));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, voterUserId, inFavor, reason);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_EventProposalVoteCopyWith<_$_EventProposalVote> get copyWith =>
      __$$_EventProposalVoteCopyWithImpl<_$_EventProposalVote>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_EventProposalVoteToJson(
      this,
    );
  }
}

abstract class _EventProposalVote implements EventProposalVote {
  factory _EventProposalVote(
      {final String? voterUserId,
      final bool? inFavor,
      final String? reason}) = _$_EventProposalVote;

  factory _EventProposalVote.fromJson(Map<String, dynamic> json) =
      _$_EventProposalVote.fromJson;

  @override
  String? get voterUserId;
  @override
  bool? get inFavor;
  @override
  String? get reason;
  @override
  @JsonKey(ignore: true)
  _$$_EventProposalVoteCopyWith<_$_EventProposalVote> get copyWith =>
      throw _privateConstructorUsedError;
}

EventProposal _$EventProposalFromJson(Map<String, dynamic> json) {
  return _EventProposal.fromJson(json);
}

/// @nodoc
mixin _$EventProposal {
  String? get id => throw _privateConstructorUsedError;
  @JsonKey(defaultValue: EventProposalType.kick, unknownEnumValue: null)
  EventProposalType get type => throw _privateConstructorUsedError;
  @JsonKey(defaultValue: EventProposalStatus.open, unknownEnumValue: null)
  EventProposalStatus get status => throw _privateConstructorUsedError;
  String? get initiatingUserId => throw _privateConstructorUsedError;
  String? get targetUserId => throw _privateConstructorUsedError;
  List<EventProposalVote>? get votes => throw _privateConstructorUsedError;
  @JsonKey(fromJson: dateTimeFromTimestamp, toJson: timestampFromDateTime)
  DateTime? get createdAt => throw _privateConstructorUsedError;
  @JsonKey(fromJson: dateTimeFromTimestamp, toJson: timestampFromDateTime)
  DateTime? get closedAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $EventProposalCopyWith<EventProposal> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $EventProposalCopyWith<$Res> {
  factory $EventProposalCopyWith(
          EventProposal value, $Res Function(EventProposal) then) =
      _$EventProposalCopyWithImpl<$Res, EventProposal>;
  @useResult
  $Res call(
      {String? id,
      @JsonKey(defaultValue: EventProposalType.kick, unknownEnumValue: null)
      EventProposalType type,
      @JsonKey(defaultValue: EventProposalStatus.open, unknownEnumValue: null)
      EventProposalStatus status,
      String? initiatingUserId,
      String? targetUserId,
      List<EventProposalVote>? votes,
      @JsonKey(fromJson: dateTimeFromTimestamp, toJson: timestampFromDateTime)
      DateTime? createdAt,
      @JsonKey(fromJson: dateTimeFromTimestamp, toJson: timestampFromDateTime)
      DateTime? closedAt});
}

/// @nodoc
class _$EventProposalCopyWithImpl<$Res, $Val extends EventProposal>
    implements $EventProposalCopyWith<$Res> {
  _$EventProposalCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? type = null,
    Object? status = null,
    Object? initiatingUserId = freezed,
    Object? targetUserId = freezed,
    Object? votes = freezed,
    Object? createdAt = freezed,
    Object? closedAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as EventProposalType,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as EventProposalStatus,
      initiatingUserId: freezed == initiatingUserId
          ? _value.initiatingUserId
          : initiatingUserId // ignore: cast_nullable_to_non_nullable
              as String?,
      targetUserId: freezed == targetUserId
          ? _value.targetUserId
          : targetUserId // ignore: cast_nullable_to_non_nullable
              as String?,
      votes: freezed == votes
          ? _value.votes
          : votes // ignore: cast_nullable_to_non_nullable
              as List<EventProposalVote>?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      closedAt: freezed == closedAt
          ? _value.closedAt
          : closedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_EventProposalCopyWith<$Res>
    implements $EventProposalCopyWith<$Res> {
  factory _$$_EventProposalCopyWith(
          _$_EventProposal value, $Res Function(_$_EventProposal) then) =
      __$$_EventProposalCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String? id,
      @JsonKey(defaultValue: EventProposalType.kick, unknownEnumValue: null)
      EventProposalType type,
      @JsonKey(defaultValue: EventProposalStatus.open, unknownEnumValue: null)
      EventProposalStatus status,
      String? initiatingUserId,
      String? targetUserId,
      List<EventProposalVote>? votes,
      @JsonKey(fromJson: dateTimeFromTimestamp, toJson: timestampFromDateTime)
      DateTime? createdAt,
      @JsonKey(fromJson: dateTimeFromTimestamp, toJson: timestampFromDateTime)
      DateTime? closedAt});
}

/// @nodoc
class __$$_EventProposalCopyWithImpl<$Res>
    extends _$EventProposalCopyWithImpl<$Res, _$_EventProposal>
    implements _$$_EventProposalCopyWith<$Res> {
  __$$_EventProposalCopyWithImpl(
      _$_EventProposal _value, $Res Function(_$_EventProposal) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? type = null,
    Object? status = null,
    Object? initiatingUserId = freezed,
    Object? targetUserId = freezed,
    Object? votes = freezed,
    Object? createdAt = freezed,
    Object? closedAt = freezed,
  }) {
    return _then(_$_EventProposal(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as EventProposalType,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as EventProposalStatus,
      initiatingUserId: freezed == initiatingUserId
          ? _value.initiatingUserId
          : initiatingUserId // ignore: cast_nullable_to_non_nullable
              as String?,
      targetUserId: freezed == targetUserId
          ? _value.targetUserId
          : targetUserId // ignore: cast_nullable_to_non_nullable
              as String?,
      votes: freezed == votes
          ? _value.votes
          : votes // ignore: cast_nullable_to_non_nullable
              as List<EventProposalVote>?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      closedAt: freezed == closedAt
          ? _value.closedAt
          : closedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_EventProposal implements _EventProposal {
  _$_EventProposal(
      {this.id,
      @JsonKey(defaultValue: EventProposalType.kick, unknownEnumValue: null)
      this.type = EventProposalType.kick,
      @JsonKey(defaultValue: EventProposalStatus.open, unknownEnumValue: null)
      this.status = EventProposalStatus.open,
      this.initiatingUserId,
      this.targetUserId,
      this.votes,
      @JsonKey(fromJson: dateTimeFromTimestamp, toJson: timestampFromDateTime)
      this.createdAt,
      @JsonKey(fromJson: dateTimeFromTimestamp, toJson: timestampFromDateTime)
      this.closedAt});

  factory _$_EventProposal.fromJson(Map<String, dynamic> json) =>
      _$$_EventProposalFromJson(json);

  @override
  final String? id;
  @override
  @JsonKey(defaultValue: EventProposalType.kick, unknownEnumValue: null)
  final EventProposalType type;
  @override
  @JsonKey(defaultValue: EventProposalStatus.open, unknownEnumValue: null)
  final EventProposalStatus status;
  @override
  final String? initiatingUserId;
  @override
  final String? targetUserId;
  @override
  final List<EventProposalVote>? votes;
  @override
  @JsonKey(fromJson: dateTimeFromTimestamp, toJson: timestampFromDateTime)
  final DateTime? createdAt;
  @override
  @JsonKey(fromJson: dateTimeFromTimestamp, toJson: timestampFromDateTime)
  final DateTime? closedAt;

  @override
  String toString() {
    return 'EventProposal(id: $id, type: $type, status: $status, initiatingUserId: $initiatingUserId, targetUserId: $targetUserId, votes: $votes, createdAt: $createdAt, closedAt: $closedAt)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_EventProposal &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.initiatingUserId, initiatingUserId) ||
                other.initiatingUserId == initiatingUserId) &&
            (identical(other.targetUserId, targetUserId) ||
                other.targetUserId == targetUserId) &&
            const DeepCollectionEquality().equals(other.votes, votes) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.closedAt, closedAt) ||
                other.closedAt == closedAt));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      type,
      status,
      initiatingUserId,
      targetUserId,
      const DeepCollectionEquality().hash(votes),
      createdAt,
      closedAt);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_EventProposalCopyWith<_$_EventProposal> get copyWith =>
      __$$_EventProposalCopyWithImpl<_$_EventProposal>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_EventProposalToJson(
      this,
    );
  }
}

abstract class _EventProposal implements EventProposal {
  factory _EventProposal(
      {final String? id,
      @JsonKey(defaultValue: EventProposalType.kick, unknownEnumValue: null)
      final EventProposalType type,
      @JsonKey(defaultValue: EventProposalStatus.open, unknownEnumValue: null)
      final EventProposalStatus status,
      final String? initiatingUserId,
      final String? targetUserId,
      final List<EventProposalVote>? votes,
      @JsonKey(fromJson: dateTimeFromTimestamp, toJson: timestampFromDateTime)
      final DateTime? createdAt,
      @JsonKey(fromJson: dateTimeFromTimestamp, toJson: timestampFromDateTime)
      final DateTime? closedAt}) = _$_EventProposal;

  factory _EventProposal.fromJson(Map<String, dynamic> json) =
      _$_EventProposal.fromJson;

  @override
  String? get id;
  @override
  @JsonKey(defaultValue: EventProposalType.kick, unknownEnumValue: null)
  EventProposalType get type;
  @override
  @JsonKey(defaultValue: EventProposalStatus.open, unknownEnumValue: null)
  EventProposalStatus get status;
  @override
  String? get initiatingUserId;
  @override
  String? get targetUserId;
  @override
  List<EventProposalVote>? get votes;
  @override
  @JsonKey(fromJson: dateTimeFromTimestamp, toJson: timestampFromDateTime)
  DateTime? get createdAt;
  @override
  @JsonKey(fromJson: dateTimeFromTimestamp, toJson: timestampFromDateTime)
  DateTime? get closedAt;
  @override
  @JsonKey(ignore: true)
  _$$_EventProposalCopyWith<_$_EventProposal> get copyWith =>
      throw _privateConstructorUsedError;
}
