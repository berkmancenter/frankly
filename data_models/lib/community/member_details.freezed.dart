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
  MemberEventData? get memberEvent => throw _privateConstructorUsedError;

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
      MemberEventData? memberEvent});

  $MembershipCopyWith<$Res>? get membership;
  $MemberEventDataCopyWith<$Res>? get memberEvent;
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
    Object? memberEvent = freezed,
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
      memberEvent: freezed == memberEvent
          ? _value.memberEvent
          : memberEvent // ignore: cast_nullable_to_non_nullable
              as MemberEventData?,
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
  $MemberEventDataCopyWith<$Res>? get memberEvent {
    if (_value.memberEvent == null) {
      return null;
    }

    return $MemberEventDataCopyWith<$Res>(_value.memberEvent!, (value) {
      return _then(_value.copyWith(memberEvent: value) as $Val);
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
      MemberEventData? memberEvent});

  @override
  $MembershipCopyWith<$Res>? get membership;
  @override
  $MemberEventDataCopyWith<$Res>? get memberEvent;
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
    Object? memberEvent = freezed,
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
      memberEvent: freezed == memberEvent
          ? _value.memberEvent
          : memberEvent // ignore: cast_nullable_to_non_nullable
              as MemberEventData?,
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
      this.memberEvent});

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
  final MemberEventData? memberEvent;

  @override
  String toString() {
    return 'MemberDetails(id: $id, email: $email, displayName: $displayName, membership: $membership, memberEvent: $memberEvent)';
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
            (identical(other.memberEvent, memberEvent) ||
                other.memberEvent == memberEvent));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, email, displayName, membership, memberEvent);

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
      final MemberEventData? memberEvent}) = _$_MemberDetails;

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
  MemberEventData? get memberEvent;
  @override
  @JsonKey(ignore: true)
  _$$_MemberDetailsCopyWith<_$_MemberDetails> get copyWith =>
      throw _privateConstructorUsedError;
}

MemberEventData _$MemberEventDataFromJson(Map<String, dynamic> json) {
  return _MemberEventData.fromJson(json);
}

/// @nodoc
mixin _$MemberEventData {
  String? get templateId => throw _privateConstructorUsedError;
  String? get eventId => throw _privateConstructorUsedError;
  Participant? get participant => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $MemberEventDataCopyWith<MemberEventData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MemberEventDataCopyWith<$Res> {
  factory $MemberEventDataCopyWith(
          MemberEventData value, $Res Function(MemberEventData) then) =
      _$MemberEventDataCopyWithImpl<$Res, MemberEventData>;
  @useResult
  $Res call({String? templateId, String? eventId, Participant? participant});

  $ParticipantCopyWith<$Res>? get participant;
}

/// @nodoc
class _$MemberEventDataCopyWithImpl<$Res, $Val extends MemberEventData>
    implements $MemberEventDataCopyWith<$Res> {
  _$MemberEventDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? templateId = freezed,
    Object? eventId = freezed,
    Object? participant = freezed,
  }) {
    return _then(_value.copyWith(
      templateId: freezed == templateId
          ? _value.templateId
          : templateId // ignore: cast_nullable_to_non_nullable
              as String?,
      eventId: freezed == eventId
          ? _value.eventId
          : eventId // ignore: cast_nullable_to_non_nullable
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
abstract class _$$_MemberEventDataCopyWith<$Res>
    implements $MemberEventDataCopyWith<$Res> {
  factory _$$_MemberEventDataCopyWith(
          _$_MemberEventData value, $Res Function(_$_MemberEventData) then) =
      __$$_MemberEventDataCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String? templateId, String? eventId, Participant? participant});

  @override
  $ParticipantCopyWith<$Res>? get participant;
}

/// @nodoc
class __$$_MemberEventDataCopyWithImpl<$Res>
    extends _$MemberEventDataCopyWithImpl<$Res, _$_MemberEventData>
    implements _$$_MemberEventDataCopyWith<$Res> {
  __$$_MemberEventDataCopyWithImpl(
      _$_MemberEventData _value, $Res Function(_$_MemberEventData) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? templateId = freezed,
    Object? eventId = freezed,
    Object? participant = freezed,
  }) {
    return _then(_$_MemberEventData(
      templateId: freezed == templateId
          ? _value.templateId
          : templateId // ignore: cast_nullable_to_non_nullable
              as String?,
      eventId: freezed == eventId
          ? _value.eventId
          : eventId // ignore: cast_nullable_to_non_nullable
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
class _$_MemberEventData implements _MemberEventData {
  _$_MemberEventData({this.templateId, this.eventId, this.participant});

  factory _$_MemberEventData.fromJson(Map<String, dynamic> json) =>
      _$$_MemberEventDataFromJson(json);

  @override
  final String? templateId;
  @override
  final String? eventId;
  @override
  final Participant? participant;

  @override
  String toString() {
    return 'MemberEventData(templateId: $templateId, eventId: $eventId, participant: $participant)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_MemberEventData &&
            (identical(other.templateId, templateId) ||
                other.templateId == templateId) &&
            (identical(other.eventId, eventId) || other.eventId == eventId) &&
            (identical(other.participant, participant) ||
                other.participant == participant));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode =>
      Object.hash(runtimeType, templateId, eventId, participant);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_MemberEventDataCopyWith<_$_MemberEventData> get copyWith =>
      __$$_MemberEventDataCopyWithImpl<_$_MemberEventData>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_MemberEventDataToJson(
      this,
    );
  }
}

abstract class _MemberEventData implements MemberEventData {
  factory _MemberEventData(
      {final String? templateId,
      final String? eventId,
      final Participant? participant}) = _$_MemberEventData;

  factory _MemberEventData.fromJson(Map<String, dynamic> json) =
      _$_MemberEventData.fromJson;

  @override
  String? get templateId;
  @override
  String? get eventId;
  @override
  Participant? get participant;
  @override
  @JsonKey(ignore: true)
  _$$_MemberEventDataCopyWith<_$_MemberEventData> get copyWith =>
      throw _privateConstructorUsedError;
}
