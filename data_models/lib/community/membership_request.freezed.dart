// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'membership_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

MembershipRequest _$MembershipRequestFromJson(Map<String, dynamic> json) {
  return _MembershipRequest.fromJson(json);
}

/// @nodoc
mixin _$MembershipRequest {
  String get userId => throw _privateConstructorUsedError;
  String get communityId => throw _privateConstructorUsedError;
  @JsonKey(unknownEnumValue: MembershipRequestStatus.requested)
  MembershipRequestStatus? get status => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $MembershipRequestCopyWith<MembershipRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MembershipRequestCopyWith<$Res> {
  factory $MembershipRequestCopyWith(
          MembershipRequest value, $Res Function(MembershipRequest) then) =
      _$MembershipRequestCopyWithImpl<$Res, MembershipRequest>;
  @useResult
  $Res call(
      {String userId,
      String communityId,
      @JsonKey(unknownEnumValue: MembershipRequestStatus.requested)
      MembershipRequestStatus? status});
}

/// @nodoc
class _$MembershipRequestCopyWithImpl<$Res, $Val extends MembershipRequest>
    implements $MembershipRequestCopyWith<$Res> {
  _$MembershipRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? communityId = null,
    Object? status = freezed,
  }) {
    return _then(_value.copyWith(
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      communityId: null == communityId
          ? _value.communityId
          : communityId // ignore: cast_nullable_to_non_nullable
              as String,
      status: freezed == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as MembershipRequestStatus?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_MembershipRequestCopyWith<$Res>
    implements $MembershipRequestCopyWith<$Res> {
  factory _$$_MembershipRequestCopyWith(_$_MembershipRequest value,
          $Res Function(_$_MembershipRequest) then) =
      __$$_MembershipRequestCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String userId,
      String communityId,
      @JsonKey(unknownEnumValue: MembershipRequestStatus.requested)
      MembershipRequestStatus? status});
}

/// @nodoc
class __$$_MembershipRequestCopyWithImpl<$Res>
    extends _$MembershipRequestCopyWithImpl<$Res, _$_MembershipRequest>
    implements _$$_MembershipRequestCopyWith<$Res> {
  __$$_MembershipRequestCopyWithImpl(
      _$_MembershipRequest _value, $Res Function(_$_MembershipRequest) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? communityId = null,
    Object? status = freezed,
  }) {
    return _then(_$_MembershipRequest(
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      communityId: null == communityId
          ? _value.communityId
          : communityId // ignore: cast_nullable_to_non_nullable
              as String,
      status: freezed == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as MembershipRequestStatus?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_MembershipRequest implements _MembershipRequest {
  _$_MembershipRequest(
      {required this.userId,
      required this.communityId,
      @JsonKey(unknownEnumValue: MembershipRequestStatus.requested)
      this.status = MembershipRequestStatus.requested});

  factory _$_MembershipRequest.fromJson(Map<String, dynamic> json) =>
      _$$_MembershipRequestFromJson(json);

  @override
  final String userId;
  @override
  final String communityId;
  @override
  @JsonKey(unknownEnumValue: MembershipRequestStatus.requested)
  final MembershipRequestStatus? status;

  @override
  String toString() {
    return 'MembershipRequest(userId: $userId, communityId: $communityId, status: $status)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_MembershipRequest &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.communityId, communityId) ||
                other.communityId == communityId) &&
            (identical(other.status, status) || other.status == status));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, userId, communityId, status);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_MembershipRequestCopyWith<_$_MembershipRequest> get copyWith =>
      __$$_MembershipRequestCopyWithImpl<_$_MembershipRequest>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_MembershipRequestToJson(
      this,
    );
  }
}

abstract class _MembershipRequest implements MembershipRequest {
  factory _MembershipRequest(
      {required final String userId,
      required final String communityId,
      @JsonKey(unknownEnumValue: MembershipRequestStatus.requested)
      final MembershipRequestStatus? status}) = _$_MembershipRequest;

  factory _MembershipRequest.fromJson(Map<String, dynamic> json) =
      _$_MembershipRequest.fromJson;

  @override
  String get userId;
  @override
  String get communityId;
  @override
  @JsonKey(unknownEnumValue: MembershipRequestStatus.requested)
  MembershipRequestStatus? get status;
  @override
  @JsonKey(ignore: true)
  _$$_MembershipRequestCopyWith<_$_MembershipRequest> get copyWith =>
      throw _privateConstructorUsedError;
}
