// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'discussion_proposal.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

DiscussionProposalVote _$DiscussionProposalVoteFromJson(
    Map<String, dynamic> json) {
  return _DiscussionProposalVote.fromJson(json);
}

/// @nodoc
mixin _$DiscussionProposalVote {
  String? get voterUserId => throw _privateConstructorUsedError;
  bool? get inFavor => throw _privateConstructorUsedError;
  String? get reason => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $DiscussionProposalVoteCopyWith<DiscussionProposalVote> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DiscussionProposalVoteCopyWith<$Res> {
  factory $DiscussionProposalVoteCopyWith(DiscussionProposalVote value,
          $Res Function(DiscussionProposalVote) then) =
      _$DiscussionProposalVoteCopyWithImpl<$Res, DiscussionProposalVote>;
  @useResult
  $Res call({String? voterUserId, bool? inFavor, String? reason});
}

/// @nodoc
class _$DiscussionProposalVoteCopyWithImpl<$Res,
        $Val extends DiscussionProposalVote>
    implements $DiscussionProposalVoteCopyWith<$Res> {
  _$DiscussionProposalVoteCopyWithImpl(this._value, this._then);

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
abstract class _$$_DiscussionProposalVoteCopyWith<$Res>
    implements $DiscussionProposalVoteCopyWith<$Res> {
  factory _$$_DiscussionProposalVoteCopyWith(_$_DiscussionProposalVote value,
          $Res Function(_$_DiscussionProposalVote) then) =
      __$$_DiscussionProposalVoteCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String? voterUserId, bool? inFavor, String? reason});
}

/// @nodoc
class __$$_DiscussionProposalVoteCopyWithImpl<$Res>
    extends _$DiscussionProposalVoteCopyWithImpl<$Res,
        _$_DiscussionProposalVote>
    implements _$$_DiscussionProposalVoteCopyWith<$Res> {
  __$$_DiscussionProposalVoteCopyWithImpl(_$_DiscussionProposalVote _value,
      $Res Function(_$_DiscussionProposalVote) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? voterUserId = freezed,
    Object? inFavor = freezed,
    Object? reason = freezed,
  }) {
    return _then(_$_DiscussionProposalVote(
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
class _$_DiscussionProposalVote implements _DiscussionProposalVote {
  _$_DiscussionProposalVote({this.voterUserId, this.inFavor, this.reason});

  factory _$_DiscussionProposalVote.fromJson(Map<String, dynamic> json) =>
      _$$_DiscussionProposalVoteFromJson(json);

  @override
  final String? voterUserId;
  @override
  final bool? inFavor;
  @override
  final String? reason;

  @override
  String toString() {
    return 'DiscussionProposalVote(voterUserId: $voterUserId, inFavor: $inFavor, reason: $reason)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_DiscussionProposalVote &&
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
  _$$_DiscussionProposalVoteCopyWith<_$_DiscussionProposalVote> get copyWith =>
      __$$_DiscussionProposalVoteCopyWithImpl<_$_DiscussionProposalVote>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_DiscussionProposalVoteToJson(
      this,
    );
  }
}

abstract class _DiscussionProposalVote implements DiscussionProposalVote {
  factory _DiscussionProposalVote(
      {final String? voterUserId,
      final bool? inFavor,
      final String? reason}) = _$_DiscussionProposalVote;

  factory _DiscussionProposalVote.fromJson(Map<String, dynamic> json) =
      _$_DiscussionProposalVote.fromJson;

  @override
  String? get voterUserId;
  @override
  bool? get inFavor;
  @override
  String? get reason;
  @override
  @JsonKey(ignore: true)
  _$$_DiscussionProposalVoteCopyWith<_$_DiscussionProposalVote> get copyWith =>
      throw _privateConstructorUsedError;
}

DiscussionProposal _$DiscussionProposalFromJson(Map<String, dynamic> json) {
  return _DiscussionProposal.fromJson(json);
}

/// @nodoc
mixin _$DiscussionProposal {
  String? get id => throw _privateConstructorUsedError;
  @JsonKey(defaultValue: DiscussionProposalType.kick, unknownEnumValue: null)
  DiscussionProposalType get type => throw _privateConstructorUsedError;
  @JsonKey(defaultValue: DiscussionProposalStatus.open, unknownEnumValue: null)
  DiscussionProposalStatus get status => throw _privateConstructorUsedError;
  String? get initiatingUserId => throw _privateConstructorUsedError;
  String? get targetUserId => throw _privateConstructorUsedError;
  List<DiscussionProposalVote>? get votes => throw _privateConstructorUsedError;
  @JsonKey(fromJson: dateTimeFromTimestamp, toJson: timestampFromDateTime)
  DateTime? get createdAt => throw _privateConstructorUsedError;
  @JsonKey(fromJson: dateTimeFromTimestamp, toJson: timestampFromDateTime)
  DateTime? get closedAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $DiscussionProposalCopyWith<DiscussionProposal> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DiscussionProposalCopyWith<$Res> {
  factory $DiscussionProposalCopyWith(
          DiscussionProposal value, $Res Function(DiscussionProposal) then) =
      _$DiscussionProposalCopyWithImpl<$Res, DiscussionProposal>;
  @useResult
  $Res call(
      {String? id,
      @JsonKey(
          defaultValue: DiscussionProposalType.kick, unknownEnumValue: null)
      DiscussionProposalType type,
      @JsonKey(
          defaultValue: DiscussionProposalStatus.open, unknownEnumValue: null)
      DiscussionProposalStatus status,
      String? initiatingUserId,
      String? targetUserId,
      List<DiscussionProposalVote>? votes,
      @JsonKey(fromJson: dateTimeFromTimestamp, toJson: timestampFromDateTime)
      DateTime? createdAt,
      @JsonKey(fromJson: dateTimeFromTimestamp, toJson: timestampFromDateTime)
      DateTime? closedAt});
}

/// @nodoc
class _$DiscussionProposalCopyWithImpl<$Res, $Val extends DiscussionProposal>
    implements $DiscussionProposalCopyWith<$Res> {
  _$DiscussionProposalCopyWithImpl(this._value, this._then);

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
              as DiscussionProposalType,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as DiscussionProposalStatus,
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
              as List<DiscussionProposalVote>?,
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
abstract class _$$_DiscussionProposalCopyWith<$Res>
    implements $DiscussionProposalCopyWith<$Res> {
  factory _$$_DiscussionProposalCopyWith(_$_DiscussionProposal value,
          $Res Function(_$_DiscussionProposal) then) =
      __$$_DiscussionProposalCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String? id,
      @JsonKey(
          defaultValue: DiscussionProposalType.kick, unknownEnumValue: null)
      DiscussionProposalType type,
      @JsonKey(
          defaultValue: DiscussionProposalStatus.open, unknownEnumValue: null)
      DiscussionProposalStatus status,
      String? initiatingUserId,
      String? targetUserId,
      List<DiscussionProposalVote>? votes,
      @JsonKey(fromJson: dateTimeFromTimestamp, toJson: timestampFromDateTime)
      DateTime? createdAt,
      @JsonKey(fromJson: dateTimeFromTimestamp, toJson: timestampFromDateTime)
      DateTime? closedAt});
}

/// @nodoc
class __$$_DiscussionProposalCopyWithImpl<$Res>
    extends _$DiscussionProposalCopyWithImpl<$Res, _$_DiscussionProposal>
    implements _$$_DiscussionProposalCopyWith<$Res> {
  __$$_DiscussionProposalCopyWithImpl(
      _$_DiscussionProposal _value, $Res Function(_$_DiscussionProposal) _then)
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
    return _then(_$_DiscussionProposal(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as DiscussionProposalType,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as DiscussionProposalStatus,
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
              as List<DiscussionProposalVote>?,
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
class _$_DiscussionProposal implements _DiscussionProposal {
  _$_DiscussionProposal(
      {this.id,
      @JsonKey(
          defaultValue: DiscussionProposalType.kick, unknownEnumValue: null)
      this.type = DiscussionProposalType.kick,
      @JsonKey(
          defaultValue: DiscussionProposalStatus.open, unknownEnumValue: null)
      this.status = DiscussionProposalStatus.open,
      this.initiatingUserId,
      this.targetUserId,
      this.votes,
      @JsonKey(fromJson: dateTimeFromTimestamp, toJson: timestampFromDateTime)
      this.createdAt,
      @JsonKey(fromJson: dateTimeFromTimestamp, toJson: timestampFromDateTime)
      this.closedAt});

  factory _$_DiscussionProposal.fromJson(Map<String, dynamic> json) =>
      _$$_DiscussionProposalFromJson(json);

  @override
  final String? id;
  @override
  @JsonKey(defaultValue: DiscussionProposalType.kick, unknownEnumValue: null)
  final DiscussionProposalType type;
  @override
  @JsonKey(defaultValue: DiscussionProposalStatus.open, unknownEnumValue: null)
  final DiscussionProposalStatus status;
  @override
  final String? initiatingUserId;
  @override
  final String? targetUserId;
  @override
  final List<DiscussionProposalVote>? votes;
  @override
  @JsonKey(fromJson: dateTimeFromTimestamp, toJson: timestampFromDateTime)
  final DateTime? createdAt;
  @override
  @JsonKey(fromJson: dateTimeFromTimestamp, toJson: timestampFromDateTime)
  final DateTime? closedAt;

  @override
  String toString() {
    return 'DiscussionProposal(id: $id, type: $type, status: $status, initiatingUserId: $initiatingUserId, targetUserId: $targetUserId, votes: $votes, createdAt: $createdAt, closedAt: $closedAt)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_DiscussionProposal &&
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
  _$$_DiscussionProposalCopyWith<_$_DiscussionProposal> get copyWith =>
      __$$_DiscussionProposalCopyWithImpl<_$_DiscussionProposal>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_DiscussionProposalToJson(
      this,
    );
  }
}

abstract class _DiscussionProposal implements DiscussionProposal {
  factory _DiscussionProposal(
      {final String? id,
      @JsonKey(
          defaultValue: DiscussionProposalType.kick, unknownEnumValue: null)
      final DiscussionProposalType type,
      @JsonKey(
          defaultValue: DiscussionProposalStatus.open, unknownEnumValue: null)
      final DiscussionProposalStatus status,
      final String? initiatingUserId,
      final String? targetUserId,
      final List<DiscussionProposalVote>? votes,
      @JsonKey(fromJson: dateTimeFromTimestamp, toJson: timestampFromDateTime)
      final DateTime? createdAt,
      @JsonKey(fromJson: dateTimeFromTimestamp, toJson: timestampFromDateTime)
      final DateTime? closedAt}) = _$_DiscussionProposal;

  factory _DiscussionProposal.fromJson(Map<String, dynamic> json) =
      _$_DiscussionProposal.fromJson;

  @override
  String? get id;
  @override
  @JsonKey(defaultValue: DiscussionProposalType.kick, unknownEnumValue: null)
  DiscussionProposalType get type;
  @override
  @JsonKey(defaultValue: DiscussionProposalStatus.open, unknownEnumValue: null)
  DiscussionProposalStatus get status;
  @override
  String? get initiatingUserId;
  @override
  String? get targetUserId;
  @override
  List<DiscussionProposalVote>? get votes;
  @override
  @JsonKey(fromJson: dateTimeFromTimestamp, toJson: timestampFromDateTime)
  DateTime? get createdAt;
  @override
  @JsonKey(fromJson: dateTimeFromTimestamp, toJson: timestampFromDateTime)
  DateTime? get closedAt;
  @override
  @JsonKey(ignore: true)
  _$$_DiscussionProposalCopyWith<_$_DiscussionProposal> get copyWith =>
      throw _privateConstructorUsedError;
}
