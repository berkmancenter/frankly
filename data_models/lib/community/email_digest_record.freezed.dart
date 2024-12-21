// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'email_digest_record.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

EmailDigestRecord _$EmailDigestRecordFromJson(Map<String, dynamic> json) {
  return _EmailDigestRecord.fromJson(json);
}

/// @nodoc
mixin _$EmailDigestRecord {
  String? get id => throw _privateConstructorUsedError;
  String? get userId => throw _privateConstructorUsedError;
  String? get communityId => throw _privateConstructorUsedError;
  @JsonKey(defaultValue: DigestType.weekly, unknownEnumValue: DigestType.weekly)
  DigestType get type => throw _privateConstructorUsedError;
  @JsonKey(fromJson: dateTimeFromTimestamp, toJson: serverTimestamp)
  DateTime? get sentAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $EmailDigestRecordCopyWith<EmailDigestRecord> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $EmailDigestRecordCopyWith<$Res> {
  factory $EmailDigestRecordCopyWith(
          EmailDigestRecord value, $Res Function(EmailDigestRecord) then) =
      _$EmailDigestRecordCopyWithImpl<$Res, EmailDigestRecord>;
  @useResult
  $Res call(
      {String? id,
      String? userId,
      String? communityId,
      @JsonKey(
          defaultValue: DigestType.weekly, unknownEnumValue: DigestType.weekly)
      DigestType type,
      @JsonKey(fromJson: dateTimeFromTimestamp, toJson: serverTimestamp)
      DateTime? sentAt});
}

/// @nodoc
class _$EmailDigestRecordCopyWithImpl<$Res, $Val extends EmailDigestRecord>
    implements $EmailDigestRecordCopyWith<$Res> {
  _$EmailDigestRecordCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? userId = freezed,
    Object? communityId = freezed,
    Object? type = null,
    Object? sentAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      userId: freezed == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String?,
      communityId: freezed == communityId
          ? _value.communityId
          : communityId // ignore: cast_nullable_to_non_nullable
              as String?,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as DigestType,
      sentAt: freezed == sentAt
          ? _value.sentAt
          : sentAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_EmailDigestRecordCopyWith<$Res>
    implements $EmailDigestRecordCopyWith<$Res> {
  factory _$$_EmailDigestRecordCopyWith(_$_EmailDigestRecord value,
          $Res Function(_$_EmailDigestRecord) then) =
      __$$_EmailDigestRecordCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String? id,
      String? userId,
      String? communityId,
      @JsonKey(
          defaultValue: DigestType.weekly, unknownEnumValue: DigestType.weekly)
      DigestType type,
      @JsonKey(fromJson: dateTimeFromTimestamp, toJson: serverTimestamp)
      DateTime? sentAt});
}

/// @nodoc
class __$$_EmailDigestRecordCopyWithImpl<$Res>
    extends _$EmailDigestRecordCopyWithImpl<$Res, _$_EmailDigestRecord>
    implements _$$_EmailDigestRecordCopyWith<$Res> {
  __$$_EmailDigestRecordCopyWithImpl(
      _$_EmailDigestRecord _value, $Res Function(_$_EmailDigestRecord) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? userId = freezed,
    Object? communityId = freezed,
    Object? type = null,
    Object? sentAt = freezed,
  }) {
    return _then(_$_EmailDigestRecord(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      userId: freezed == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String?,
      communityId: freezed == communityId
          ? _value.communityId
          : communityId // ignore: cast_nullable_to_non_nullable
              as String?,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as DigestType,
      sentAt: freezed == sentAt
          ? _value.sentAt
          : sentAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_EmailDigestRecord implements _EmailDigestRecord {
  _$_EmailDigestRecord(
      {this.id,
      this.userId,
      this.communityId,
      @JsonKey(
          defaultValue: DigestType.weekly, unknownEnumValue: DigestType.weekly)
      this.type = DigestType.weekly,
      @JsonKey(fromJson: dateTimeFromTimestamp, toJson: serverTimestamp)
      this.sentAt});

  factory _$_EmailDigestRecord.fromJson(Map<String, dynamic> json) =>
      _$$_EmailDigestRecordFromJson(json);

  @override
  final String? id;
  @override
  final String? userId;
  @override
  final String? communityId;
  @override
  @JsonKey(defaultValue: DigestType.weekly, unknownEnumValue: DigestType.weekly)
  final DigestType type;
  @override
  @JsonKey(fromJson: dateTimeFromTimestamp, toJson: serverTimestamp)
  final DateTime? sentAt;

  @override
  String toString() {
    return 'EmailDigestRecord(id: $id, userId: $userId, communityId: $communityId, type: $type, sentAt: $sentAt)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_EmailDigestRecord &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.communityId, communityId) ||
                other.communityId == communityId) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.sentAt, sentAt) || other.sentAt == sentAt));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, userId, communityId, type, sentAt);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_EmailDigestRecordCopyWith<_$_EmailDigestRecord> get copyWith =>
      __$$_EmailDigestRecordCopyWithImpl<_$_EmailDigestRecord>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_EmailDigestRecordToJson(
      this,
    );
  }
}

abstract class _EmailDigestRecord implements EmailDigestRecord {
  factory _EmailDigestRecord(
      {final String? id,
      final String? userId,
      final String? communityId,
      @JsonKey(
          defaultValue: DigestType.weekly, unknownEnumValue: DigestType.weekly)
      final DigestType type,
      @JsonKey(fromJson: dateTimeFromTimestamp, toJson: serverTimestamp)
      final DateTime? sentAt}) = _$_EmailDigestRecord;

  factory _EmailDigestRecord.fromJson(Map<String, dynamic> json) =
      _$_EmailDigestRecord.fromJson;

  @override
  String? get id;
  @override
  String? get userId;
  @override
  String? get communityId;
  @override
  @JsonKey(defaultValue: DigestType.weekly, unknownEnumValue: DigestType.weekly)
  DigestType get type;
  @override
  @JsonKey(fromJson: dateTimeFromTimestamp, toJson: serverTimestamp)
  DateTime? get sentAt;
  @override
  @JsonKey(ignore: true)
  _$$_EmailDigestRecordCopyWith<_$_EmailDigestRecord> get copyWith =>
      throw _privateConstructorUsedError;
}
