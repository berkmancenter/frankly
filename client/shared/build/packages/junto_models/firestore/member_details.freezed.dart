// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'member_details.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

MemberDetails _$MemberDetailsFromJson(Map<String, dynamic> json) {
  return _MemberDetails.fromJson(json);
}

/// @nodoc
mixin _$MemberDetails {
  String get id => throw _privateConstructorUsedError;
  String? get email => throw _privateConstructorUsedError;
  String? get displayName => throw _privateConstructorUsedError;
  Membership? get membership => throw _privateConstructorUsedError;
  MemberDiscussionData? get memberDiscussion =>
      throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $MemberDetailsCopyWith<MemberDetails> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MemberDetailsCopyWith<$Res> {
  factory $MemberDetailsCopyWith(
          MemberDetails value, $Res Function(MemberDetails) then) =
      _$MemberDetailsCopyWithImpl<$Res, MemberDetails>;
  @useResult
  $Res call(
      {String id,
      String? email,
      String? displayName,
      Membership? membership,
      MemberDiscussionData? memberDiscussion});

  $MembershipCopyWith<$Res>? get membership;
  $MemberDiscussionDataCopyWith<$Res>? get memberDiscussion;
}

/// @nodoc
class _$MemberDetailsCopyWithImpl<$Res, $Val extends MemberDetails>
    implements $MemberDetailsCopyWith<$Res> {
  _$MemberDetailsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? email = freezed,
    Object? displayName = freezed,
    Object? membership = freezed,
    Object? memberDiscussion = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      email: freezed == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String?,
      displayName: freezed == displayName
          ? _value.displayName
          : displayName // ignore: cast_nullable_to_non_nullable
              as String?,
      membership: freezed == membership
          ? _value.membership
          : membership // ignore: cast_nullable_to_non_nullable
              as Membership?,
      memberDiscussion: freezed == memberDiscussion
          ? _value.memberDiscussion
          : memberDiscussion // ignore: cast_nullable_to_non_nullable
              as MemberDiscussionData?,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $MembershipCopyWith<$Res>? get membership {
    if (_value.membership == null) {
      return null;
    }

    return $MembershipCopyWith<$Res>(_value.membership!, (value) {
      return _then(_value.copyWith(membership: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $MemberDiscussionDataCopyWith<$Res>? get memberDiscussion {
    if (_value.memberDiscussion == null) {
      return null;
    }

    return $MemberDiscussionDataCopyWith<$Res>(_value.memberDiscussion!,
        (value) {
      return _then(_value.copyWith(memberDiscussion: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$_MemberDetailsCopyWith<$Res>
    implements $MemberDetailsCopyWith<$Res> {
  factory _$$_MemberDetailsCopyWith(
          _$_MemberDetails value, $Res Function(_$_MemberDetails) then) =
      __$$_MemberDetailsCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String? email,
      String? displayName,
      Membership? membership,
      MemberDiscussionData? memberDiscussion});

  @override
  $MembershipCopyWith<$Res>? get membership;
  @override
  $MemberDiscussionDataCopyWith<$Res>? get memberDiscussion;
}

/// @nodoc
class __$$_MemberDetailsCopyWithImpl<$Res>
    extends _$MemberDetailsCopyWithImpl<$Res, _$_MemberDetails>
    implements _$$_MemberDetailsCopyWith<$Res> {
  __$$_MemberDetailsCopyWithImpl(
      _$_MemberDetails _value, $Res Function(_$_MemberDetails) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? email = freezed,
    Object? displayName = freezed,
    Object? membership = freezed,
    Object? memberDiscussion = freezed,
  }) {
    return _then(_$_MemberDetails(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      email: freezed == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String?,
      displayName: freezed == displayName
          ? _value.displayName
          : displayName // ignore: cast_nullable_to_non_nullable
              as String?,
      membership: freezed == membership
          ? _value.membership
          : membership // ignore: cast_nullable_to_non_nullable
              as Membership?,
      memberDiscussion: freezed == memberDiscussion
          ? _value.memberDiscussion
          : memberDiscussion // ignore: cast_nullable_to_non_nullable
              as MemberDiscussionData?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_MemberDetails implements _MemberDetails {
  _$_MemberDetails(
      {required this.id,
      this.email,
      this.displayName,
      this.membership,
      this.memberDiscussion});

  factory _$_MemberDetails.fromJson(Map<String, dynamic> json) =>
      _$$_MemberDetailsFromJson(json);

  @override
  final String id;
  @override
  final String? email;
  @override
  final String? displayName;
  @override
  final Membership? membership;
  @override
  final MemberDiscussionData? memberDiscussion;

  @override
  String toString() {
    return 'MemberDetails(id: $id, email: $email, displayName: $displayName, membership: $membership, memberDiscussion: $memberDiscussion)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_MemberDetails &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.displayName, displayName) ||
                other.displayName == displayName) &&
            (identical(other.membership, membership) ||
                other.membership == membership) &&
            (identical(other.memberDiscussion, memberDiscussion) ||
                other.memberDiscussion == memberDiscussion));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType, id, email, displayName, membership, memberDiscussion);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_MemberDetailsCopyWith<_$_MemberDetails> get copyWith =>
      __$$_MemberDetailsCopyWithImpl<_$_MemberDetails>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_MemberDetailsToJson(
      this,
    );
  }
}

abstract class _MemberDetails implements MemberDetails {
  factory _MemberDetails(
      {required final String id,
      final String? email,
      final String? displayName,
      final Membership? membership,
      final MemberDiscussionData? memberDiscussion}) = _$_MemberDetails;

  factory _MemberDetails.fromJson(Map<String, dynamic> json) =
      _$_MemberDetails.fromJson;

  @override
  String get id;
  @override
  String? get email;
  @override
  String? get displayName;
  @override
  Membership? get membership;
  @override
  MemberDiscussionData? get memberDiscussion;
  @override
  @JsonKey(ignore: true)
  _$$_MemberDetailsCopyWith<_$_MemberDetails> get copyWith =>
      throw _privateConstructorUsedError;
}

MemberDiscussionData _$MemberDiscussionDataFromJson(Map<String, dynamic> json) {
  return _MemberDiscussionData.fromJson(json);
}

/// @nodoc
mixin _$MemberDiscussionData {
  String? get topicId => throw _privateConstructorUsedError;
  String? get discussionId => throw _privateConstructorUsedError;
  Participant? get participant => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $MemberDiscussionDataCopyWith<MemberDiscussionData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MemberDiscussionDataCopyWith<$Res> {
  factory $MemberDiscussionDataCopyWith(MemberDiscussionData value,
          $Res Function(MemberDiscussionData) then) =
      _$MemberDiscussionDataCopyWithImpl<$Res, MemberDiscussionData>;
  @useResult
  $Res call({String? topicId, String? discussionId, Participant? participant});

  $ParticipantCopyWith<$Res>? get participant;
}

/// @nodoc
class _$MemberDiscussionDataCopyWithImpl<$Res,
        $Val extends MemberDiscussionData>
    implements $MemberDiscussionDataCopyWith<$Res> {
  _$MemberDiscussionDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? topicId = freezed,
    Object? discussionId = freezed,
    Object? participant = freezed,
  }) {
    return _then(_value.copyWith(
      topicId: freezed == topicId
          ? _value.topicId
          : topicId // ignore: cast_nullable_to_non_nullable
              as String?,
      discussionId: freezed == discussionId
          ? _value.discussionId
          : discussionId // ignore: cast_nullable_to_non_nullable
              as String?,
      participant: freezed == participant
          ? _value.participant
          : participant // ignore: cast_nullable_to_non_nullable
              as Participant?,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $ParticipantCopyWith<$Res>? get participant {
    if (_value.participant == null) {
      return null;
    }

    return $ParticipantCopyWith<$Res>(_value.participant!, (value) {
      return _then(_value.copyWith(participant: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$_MemberDiscussionDataCopyWith<$Res>
    implements $MemberDiscussionDataCopyWith<$Res> {
  factory _$$_MemberDiscussionDataCopyWith(_$_MemberDiscussionData value,
          $Res Function(_$_MemberDiscussionData) then) =
      __$$_MemberDiscussionDataCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String? topicId, String? discussionId, Participant? participant});

  @override
  $ParticipantCopyWith<$Res>? get participant;
}

/// @nodoc
class __$$_MemberDiscussionDataCopyWithImpl<$Res>
    extends _$MemberDiscussionDataCopyWithImpl<$Res, _$_MemberDiscussionData>
    implements _$$_MemberDiscussionDataCopyWith<$Res> {
  __$$_MemberDiscussionDataCopyWithImpl(_$_MemberDiscussionData _value,
      $Res Function(_$_MemberDiscussionData) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? topicId = freezed,
    Object? discussionId = freezed,
    Object? participant = freezed,
  }) {
    return _then(_$_MemberDiscussionData(
      topicId: freezed == topicId
          ? _value.topicId
          : topicId // ignore: cast_nullable_to_non_nullable
              as String?,
      discussionId: freezed == discussionId
          ? _value.discussionId
          : discussionId // ignore: cast_nullable_to_non_nullable
              as String?,
      participant: freezed == participant
          ? _value.participant
          : participant // ignore: cast_nullable_to_non_nullable
              as Participant?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_MemberDiscussionData implements _MemberDiscussionData {
  _$_MemberDiscussionData({this.topicId, this.discussionId, this.participant});

  factory _$_MemberDiscussionData.fromJson(Map<String, dynamic> json) =>
      _$$_MemberDiscussionDataFromJson(json);

  @override
  final String? topicId;
  @override
  final String? discussionId;
  @override
  final Participant? participant;

  @override
  String toString() {
    return 'MemberDiscussionData(topicId: $topicId, discussionId: $discussionId, participant: $participant)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_MemberDiscussionData &&
            (identical(other.topicId, topicId) || other.topicId == topicId) &&
            (identical(other.discussionId, discussionId) ||
                other.discussionId == discussionId) &&
            (identical(other.participant, participant) ||
                other.participant == participant));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode =>
      Object.hash(runtimeType, topicId, discussionId, participant);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_MemberDiscussionDataCopyWith<_$_MemberDiscussionData> get copyWith =>
      __$$_MemberDiscussionDataCopyWithImpl<_$_MemberDiscussionData>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_MemberDiscussionDataToJson(
      this,
    );
  }
}

abstract class _MemberDiscussionData implements MemberDiscussionData {
  factory _MemberDiscussionData(
      {final String? topicId,
      final String? discussionId,
      final Participant? participant}) = _$_MemberDiscussionData;

  factory _MemberDiscussionData.fromJson(Map<String, dynamic> json) =
      _$_MemberDiscussionData.fromJson;

  @override
  String? get topicId;
  @override
  String? get discussionId;
  @override
  Participant? get participant;
  @override
  @JsonKey(ignore: true)
  _$$_MemberDiscussionDataCopyWith<_$_MemberDiscussionData> get copyWith =>
      throw _privateConstructorUsedError;
}
