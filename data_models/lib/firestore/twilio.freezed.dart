// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'twilio.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

TwilioParticipant _$TwilioParticipantFromJson(Map<String, dynamic> json) {
  return _TwilioParticipant.fromJson(json);
}

/// @nodoc
mixin _$TwilioParticipant {
  String? get roomId => throw _privateConstructorUsedError;
  String? get roomName => throw _privateConstructorUsedError;
  String? get participantSid => throw _privateConstructorUsedError;
  String? get participantIdentity => throw _privateConstructorUsedError;
  @JsonKey(fromJson: dateTimeFromTimestamp, toJson: timestampFromDateTime)
  DateTime? get joinTime => throw _privateConstructorUsedError;
  @JsonKey(fromJson: dateTimeFromTimestamp, toJson: timestampFromDateTime)
  DateTime? get leaveTime => throw _privateConstructorUsedError;
  int? get duration => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $TwilioParticipantCopyWith<TwilioParticipant> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TwilioParticipantCopyWith<$Res> {
  factory $TwilioParticipantCopyWith(
          TwilioParticipant value, $Res Function(TwilioParticipant) then) =
      _$TwilioParticipantCopyWithImpl<$Res, TwilioParticipant>;
  @useResult
  $Res call(
      {String? roomId,
      String? roomName,
      String? participantSid,
      String? participantIdentity,
      @JsonKey(fromJson: dateTimeFromTimestamp, toJson: timestampFromDateTime)
      DateTime? joinTime,
      @JsonKey(fromJson: dateTimeFromTimestamp, toJson: timestampFromDateTime)
      DateTime? leaveTime,
      int? duration});
}

/// @nodoc
class _$TwilioParticipantCopyWithImpl<$Res, $Val extends TwilioParticipant>
    implements $TwilioParticipantCopyWith<$Res> {
  _$TwilioParticipantCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? roomId = freezed,
    Object? roomName = freezed,
    Object? participantSid = freezed,
    Object? participantIdentity = freezed,
    Object? joinTime = freezed,
    Object? leaveTime = freezed,
    Object? duration = freezed,
  }) {
    return _then(_value.copyWith(
      roomId: freezed == roomId
          ? _value.roomId
          : roomId // ignore: cast_nullable_to_non_nullable
              as String?,
      roomName: freezed == roomName
          ? _value.roomName
          : roomName // ignore: cast_nullable_to_non_nullable
              as String?,
      participantSid: freezed == participantSid
          ? _value.participantSid
          : participantSid // ignore: cast_nullable_to_non_nullable
              as String?,
      participantIdentity: freezed == participantIdentity
          ? _value.participantIdentity
          : participantIdentity // ignore: cast_nullable_to_non_nullable
              as String?,
      joinTime: freezed == joinTime
          ? _value.joinTime
          : joinTime // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      leaveTime: freezed == leaveTime
          ? _value.leaveTime
          : leaveTime // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      duration: freezed == duration
          ? _value.duration
          : duration // ignore: cast_nullable_to_non_nullable
              as int?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_TwilioParticipantCopyWith<$Res>
    implements $TwilioParticipantCopyWith<$Res> {
  factory _$$_TwilioParticipantCopyWith(_$_TwilioParticipant value,
          $Res Function(_$_TwilioParticipant) then) =
      __$$_TwilioParticipantCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String? roomId,
      String? roomName,
      String? participantSid,
      String? participantIdentity,
      @JsonKey(fromJson: dateTimeFromTimestamp, toJson: timestampFromDateTime)
      DateTime? joinTime,
      @JsonKey(fromJson: dateTimeFromTimestamp, toJson: timestampFromDateTime)
      DateTime? leaveTime,
      int? duration});
}

/// @nodoc
class __$$_TwilioParticipantCopyWithImpl<$Res>
    extends _$TwilioParticipantCopyWithImpl<$Res, _$_TwilioParticipant>
    implements _$$_TwilioParticipantCopyWith<$Res> {
  __$$_TwilioParticipantCopyWithImpl(
      _$_TwilioParticipant _value, $Res Function(_$_TwilioParticipant) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? roomId = freezed,
    Object? roomName = freezed,
    Object? participantSid = freezed,
    Object? participantIdentity = freezed,
    Object? joinTime = freezed,
    Object? leaveTime = freezed,
    Object? duration = freezed,
  }) {
    return _then(_$_TwilioParticipant(
      roomId: freezed == roomId
          ? _value.roomId
          : roomId // ignore: cast_nullable_to_non_nullable
              as String?,
      roomName: freezed == roomName
          ? _value.roomName
          : roomName // ignore: cast_nullable_to_non_nullable
              as String?,
      participantSid: freezed == participantSid
          ? _value.participantSid
          : participantSid // ignore: cast_nullable_to_non_nullable
              as String?,
      participantIdentity: freezed == participantIdentity
          ? _value.participantIdentity
          : participantIdentity // ignore: cast_nullable_to_non_nullable
              as String?,
      joinTime: freezed == joinTime
          ? _value.joinTime
          : joinTime // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      leaveTime: freezed == leaveTime
          ? _value.leaveTime
          : leaveTime // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      duration: freezed == duration
          ? _value.duration
          : duration // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_TwilioParticipant implements _TwilioParticipant {
  _$_TwilioParticipant(
      {this.roomId,
      this.roomName,
      this.participantSid,
      this.participantIdentity,
      @JsonKey(fromJson: dateTimeFromTimestamp, toJson: timestampFromDateTime)
      this.joinTime,
      @JsonKey(fromJson: dateTimeFromTimestamp, toJson: timestampFromDateTime)
      this.leaveTime,
      this.duration});

  factory _$_TwilioParticipant.fromJson(Map<String, dynamic> json) =>
      _$$_TwilioParticipantFromJson(json);

  @override
  final String? roomId;
  @override
  final String? roomName;
  @override
  final String? participantSid;
  @override
  final String? participantIdentity;
  @override
  @JsonKey(fromJson: dateTimeFromTimestamp, toJson: timestampFromDateTime)
  final DateTime? joinTime;
  @override
  @JsonKey(fromJson: dateTimeFromTimestamp, toJson: timestampFromDateTime)
  final DateTime? leaveTime;
  @override
  final int? duration;

  @override
  String toString() {
    return 'TwilioParticipant(roomId: $roomId, roomName: $roomName, participantSid: $participantSid, participantIdentity: $participantIdentity, joinTime: $joinTime, leaveTime: $leaveTime, duration: $duration)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_TwilioParticipant &&
            (identical(other.roomId, roomId) || other.roomId == roomId) &&
            (identical(other.roomName, roomName) ||
                other.roomName == roomName) &&
            (identical(other.participantSid, participantSid) ||
                other.participantSid == participantSid) &&
            (identical(other.participantIdentity, participantIdentity) ||
                other.participantIdentity == participantIdentity) &&
            (identical(other.joinTime, joinTime) ||
                other.joinTime == joinTime) &&
            (identical(other.leaveTime, leaveTime) ||
                other.leaveTime == leaveTime) &&
            (identical(other.duration, duration) ||
                other.duration == duration));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, roomId, roomName, participantSid,
      participantIdentity, joinTime, leaveTime, duration);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_TwilioParticipantCopyWith<_$_TwilioParticipant> get copyWith =>
      __$$_TwilioParticipantCopyWithImpl<_$_TwilioParticipant>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_TwilioParticipantToJson(
      this,
    );
  }
}

abstract class _TwilioParticipant implements TwilioParticipant {
  factory _TwilioParticipant(
      {final String? roomId,
      final String? roomName,
      final String? participantSid,
      final String? participantIdentity,
      @JsonKey(fromJson: dateTimeFromTimestamp, toJson: timestampFromDateTime)
      final DateTime? joinTime,
      @JsonKey(fromJson: dateTimeFromTimestamp, toJson: timestampFromDateTime)
      final DateTime? leaveTime,
      final int? duration}) = _$_TwilioParticipant;

  factory _TwilioParticipant.fromJson(Map<String, dynamic> json) =
      _$_TwilioParticipant.fromJson;

  @override
  String? get roomId;
  @override
  String? get roomName;
  @override
  String? get participantSid;
  @override
  String? get participantIdentity;
  @override
  @JsonKey(fromJson: dateTimeFromTimestamp, toJson: timestampFromDateTime)
  DateTime? get joinTime;
  @override
  @JsonKey(fromJson: dateTimeFromTimestamp, toJson: timestampFromDateTime)
  DateTime? get leaveTime;
  @override
  int? get duration;
  @override
  @JsonKey(ignore: true)
  _$$_TwilioParticipantCopyWith<_$_TwilioParticipant> get copyWith =>
      throw _privateConstructorUsedError;
}
