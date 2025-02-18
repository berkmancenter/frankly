// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'payment_record.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

PaymentRecord _$PaymentRecordFromJson(Map<String, dynamic> json) {
  return _PaymentRecord.fromJson(json);
}

/// @nodoc
mixin _$PaymentRecord {
  String? get id => throw _privateConstructorUsedError;
  String? get authUid => throw _privateConstructorUsedError;
  String? get communityId => throw _privateConstructorUsedError;
  int? get amountInCents => throw _privateConstructorUsedError;
  DateTime? get createdDate => throw _privateConstructorUsedError;
  @JsonKey(unknownEnumValue: null)
  PaymentType? get type => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $PaymentRecordCopyWith<PaymentRecord> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PaymentRecordCopyWith<$Res> {
  factory $PaymentRecordCopyWith(
          PaymentRecord value, $Res Function(PaymentRecord) then) =
      _$PaymentRecordCopyWithImpl<$Res, PaymentRecord>;
  @useResult
  $Res call(
      {String? id,
      String? authUid,
      String? communityId,
      int? amountInCents,
      DateTime? createdDate,
      @JsonKey(unknownEnumValue: null) PaymentType? type});
}

/// @nodoc
class _$PaymentRecordCopyWithImpl<$Res, $Val extends PaymentRecord>
    implements $PaymentRecordCopyWith<$Res> {
  _$PaymentRecordCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? authUid = freezed,
    Object? communityId = freezed,
    Object? amountInCents = freezed,
    Object? createdDate = freezed,
    Object? type = freezed,
  }) {
    return _then(_value.copyWith(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      authUid: freezed == authUid
          ? _value.authUid
          : authUid // ignore: cast_nullable_to_non_nullable
              as String?,
      communityId: freezed == communityId
          ? _value.communityId
          : communityId // ignore: cast_nullable_to_non_nullable
              as String?,
      amountInCents: freezed == amountInCents
          ? _value.amountInCents
          : amountInCents // ignore: cast_nullable_to_non_nullable
              as int?,
      createdDate: freezed == createdDate
          ? _value.createdDate
          : createdDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      type: freezed == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as PaymentType?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_PaymentRecordCopyWith<$Res>
    implements $PaymentRecordCopyWith<$Res> {
  factory _$$_PaymentRecordCopyWith(
          _$_PaymentRecord value, $Res Function(_$_PaymentRecord) then) =
      __$$_PaymentRecordCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String? id,
      String? authUid,
      String? communityId,
      int? amountInCents,
      DateTime? createdDate,
      @JsonKey(unknownEnumValue: null) PaymentType? type});
}

/// @nodoc
class __$$_PaymentRecordCopyWithImpl<$Res>
    extends _$PaymentRecordCopyWithImpl<$Res, _$_PaymentRecord>
    implements _$$_PaymentRecordCopyWith<$Res> {
  __$$_PaymentRecordCopyWithImpl(
      _$_PaymentRecord _value, $Res Function(_$_PaymentRecord) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? authUid = freezed,
    Object? communityId = freezed,
    Object? amountInCents = freezed,
    Object? createdDate = freezed,
    Object? type = freezed,
  }) {
    return _then(_$_PaymentRecord(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      authUid: freezed == authUid
          ? _value.authUid
          : authUid // ignore: cast_nullable_to_non_nullable
              as String?,
      communityId: freezed == communityId
          ? _value.communityId
          : communityId // ignore: cast_nullable_to_non_nullable
              as String?,
      amountInCents: freezed == amountInCents
          ? _value.amountInCents
          : amountInCents // ignore: cast_nullable_to_non_nullable
              as int?,
      createdDate: freezed == createdDate
          ? _value.createdDate
          : createdDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      type: freezed == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as PaymentType?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_PaymentRecord implements _PaymentRecord {
  _$_PaymentRecord(
      {this.id,
      this.authUid,
      this.communityId,
      this.amountInCents,
      this.createdDate,
      @JsonKey(unknownEnumValue: null) this.type});

  factory _$_PaymentRecord.fromJson(Map<String, dynamic> json) =>
      _$$_PaymentRecordFromJson(json);

  @override
  final String? id;
  @override
  final String? authUid;
  @override
  final String? communityId;
  @override
  final int? amountInCents;
  @override
  final DateTime? createdDate;
  @override
  @JsonKey(unknownEnumValue: null)
  final PaymentType? type;

  @override
  String toString() {
    return 'PaymentRecord(id: $id, authUid: $authUid, communityId: $communityId, amountInCents: $amountInCents, createdDate: $createdDate, type: $type)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_PaymentRecord &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.authUid, authUid) || other.authUid == authUid) &&
            (identical(other.communityId, communityId) ||
                other.communityId == communityId) &&
            (identical(other.amountInCents, amountInCents) ||
                other.amountInCents == amountInCents) &&
            (identical(other.createdDate, createdDate) ||
                other.createdDate == createdDate) &&
            (identical(other.type, type) || other.type == type));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType, id, authUid, communityId, amountInCents, createdDate, type);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_PaymentRecordCopyWith<_$_PaymentRecord> get copyWith =>
      __$$_PaymentRecordCopyWithImpl<_$_PaymentRecord>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_PaymentRecordToJson(
      this,
    );
  }
}

abstract class _PaymentRecord implements PaymentRecord {
  factory _PaymentRecord(
          {final String? id,
          final String? authUid,
          final String? communityId,
          final int? amountInCents,
          final DateTime? createdDate,
          @JsonKey(unknownEnumValue: null) final PaymentType? type}) =
      _$_PaymentRecord;

  factory _PaymentRecord.fromJson(Map<String, dynamic> json) =
      _$_PaymentRecord.fromJson;

  @override
  String? get id;
  @override
  String? get authUid;
  @override
  String? get communityId;
  @override
  int? get amountInCents;
  @override
  DateTime? get createdDate;
  @override
  @JsonKey(unknownEnumValue: null)
  PaymentType? get type;
  @override
  @JsonKey(ignore: true)
  _$$_PaymentRecordCopyWith<_$_PaymentRecord> get copyWith =>
      throw _privateConstructorUsedError;
}
