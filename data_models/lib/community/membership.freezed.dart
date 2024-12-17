// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'membership.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

Membership _$MembershipFromJson(Map<String, dynamic> json) {
  return _Membership.fromJson(json);
}

/// @nodoc
mixin _$Membership {
  String get userId => throw _privateConstructorUsedError;
  String get communityId => throw _privateConstructorUsedError;
  @JsonKey(unknownEnumValue: null)
  MembershipStatus? get status => throw _privateConstructorUsedError;
  @JsonKey(fromJson: dateTimeFromTimestamp, toJson: serverTimestamp)
  DateTime? get firstJoined => throw _privateConstructorUsedError;
  bool get invisible => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $MembershipCopyWith<Membership> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MembershipCopyWith<$Res> {
  factory $MembershipCopyWith(
          Membership value, $Res Function(Membership) then) =
      _$MembershipCopyWithImpl<$Res, Membership>;
  @useResult
  $Res call(
      {String userId,
      String communityId,
      @JsonKey(unknownEnumValue: null) MembershipStatus? status,
      @JsonKey(fromJson: dateTimeFromTimestamp, toJson: serverTimestamp)
      DateTime? firstJoined,
      bool invisible});
}

/// @nodoc
class _$MembershipCopyWithImpl<$Res, $Val extends Membership>
    implements $MembershipCopyWith<$Res> {
  _$MembershipCopyWithImpl(this._value, this._then);

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
    Object? firstJoined = freezed,
    Object? invisible = null,
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
              as MembershipStatus?,
      firstJoined: freezed == firstJoined
          ? _value.firstJoined
          : firstJoined // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      invisible: null == invisible
          ? _value.invisible
          : invisible // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_MembershipCopyWith<$Res>
    implements $MembershipCopyWith<$Res> {
  factory _$$_MembershipCopyWith(
          _$_Membership value, $Res Function(_$_Membership) then) =
      __$$_MembershipCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String userId,
      String communityId,
      @JsonKey(unknownEnumValue: null) MembershipStatus? status,
      @JsonKey(fromJson: dateTimeFromTimestamp, toJson: serverTimestamp)
      DateTime? firstJoined,
      bool invisible});
}

/// @nodoc
class __$$_MembershipCopyWithImpl<$Res>
    extends _$MembershipCopyWithImpl<$Res, _$_Membership>
    implements _$$_MembershipCopyWith<$Res> {
  __$$_MembershipCopyWithImpl(
      _$_Membership _value, $Res Function(_$_Membership) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? communityId = null,
    Object? status = freezed,
    Object? firstJoined = freezed,
    Object? invisible = null,
  }) {
    return _then(_$_Membership(
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
              as MembershipStatus?,
      firstJoined: freezed == firstJoined
          ? _value.firstJoined
          : firstJoined // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      invisible: null == invisible
          ? _value.invisible
          : invisible // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_Membership extends _Membership {
  _$_Membership(
      {required this.userId,
      required this.communityId,
      @JsonKey(unknownEnumValue: null) this.status,
      @JsonKey(fromJson: dateTimeFromTimestamp, toJson: serverTimestamp)
      this.firstJoined,
      this.invisible = false})
      : super._();

  factory _$_Membership.fromJson(Map<String, dynamic> json) =>
      _$$_MembershipFromJson(json);

  @override
  final String userId;
  @override
  final String communityId;
  @override
  @JsonKey(unknownEnumValue: null)
  final MembershipStatus? status;
  @override
  @JsonKey(fromJson: dateTimeFromTimestamp, toJson: serverTimestamp)
  final DateTime? firstJoined;
  @override
  @JsonKey()
  final bool invisible;

  @override
  String toString() {
    return 'Membership(userId: $userId, communityId: $communityId, status: $status, firstJoined: $firstJoined, invisible: $invisible)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_Membership &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.communityId, communityId) ||
                other.communityId == communityId) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.firstJoined, firstJoined) ||
                other.firstJoined == firstJoined) &&
            (identical(other.invisible, invisible) ||
                other.invisible == invisible));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType, userId, communityId, status, firstJoined, invisible);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_MembershipCopyWith<_$_Membership> get copyWith =>
      __$$_MembershipCopyWithImpl<_$_Membership>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_MembershipToJson(
      this,
    );
  }
}

abstract class _Membership extends Membership {
  factory _Membership(
      {required final String userId,
      required final String communityId,
      @JsonKey(unknownEnumValue: null) final MembershipStatus? status,
      @JsonKey(fromJson: dateTimeFromTimestamp, toJson: serverTimestamp)
      final DateTime? firstJoined,
      final bool invisible}) = _$_Membership;
  _Membership._() : super._();

  factory _Membership.fromJson(Map<String, dynamic> json) =
      _$_Membership.fromJson;

  @override
  String get userId;
  @override
  String get communityId;
  @override
  @JsonKey(unknownEnumValue: null)
  MembershipStatus? get status;
  @override
  @JsonKey(fromJson: dateTimeFromTimestamp, toJson: serverTimestamp)
  DateTime? get firstJoined;
  @override
  bool get invisible;
  @override
  @JsonKey(ignore: true)
  _$$_MembershipCopyWith<_$_Membership> get copyWith =>
      throw _privateConstructorUsedError;
}
