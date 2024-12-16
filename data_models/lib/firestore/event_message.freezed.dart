// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'event_message.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

EventMessage _$EventMessageFromJson(Map<String, dynamic> json) {
  return _EventMessage.fromJson(json);
}

/// @nodoc
mixin _$EventMessage {
  String get creatorId => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  String? get docId =>
      throw _privateConstructorUsedError; //TODO(aurimas): Does not make sense to have it nullable, because it's never nullable
  @JsonKey(fromJson: dateTimeFromTimestamp, toJson: timestampFromDateTime)
  DateTime? get createdAt => throw _privateConstructorUsedError;
  int? get createdAtMillis => throw _privateConstructorUsedError;
  String get message => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $EventMessageCopyWith<EventMessage> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $EventMessageCopyWith<$Res> {
  factory $EventMessageCopyWith(
          EventMessage value, $Res Function(EventMessage) then) =
      _$EventMessageCopyWithImpl<$Res, EventMessage>;
  @useResult
  $Res call(
      {String creatorId,
      @JsonKey(ignore: true) String? docId,
      @JsonKey(fromJson: dateTimeFromTimestamp, toJson: timestampFromDateTime)
      DateTime? createdAt,
      int? createdAtMillis,
      String message});
}

/// @nodoc
class _$EventMessageCopyWithImpl<$Res, $Val extends EventMessage>
    implements $EventMessageCopyWith<$Res> {
  _$EventMessageCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? creatorId = null,
    Object? docId = freezed,
    Object? createdAt = freezed,
    Object? createdAtMillis = freezed,
    Object? message = null,
  }) {
    return _then(_value.copyWith(
      creatorId: null == creatorId
          ? _value.creatorId
          : creatorId // ignore: cast_nullable_to_non_nullable
              as String,
      docId: freezed == docId
          ? _value.docId
          : docId // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      createdAtMillis: freezed == createdAtMillis
          ? _value.createdAtMillis
          : createdAtMillis // ignore: cast_nullable_to_non_nullable
              as int?,
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_EventMessageCopyWith<$Res>
    implements $EventMessageCopyWith<$Res> {
  factory _$$_EventMessageCopyWith(
          _$_EventMessage value, $Res Function(_$_EventMessage) then) =
      __$$_EventMessageCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String creatorId,
      @JsonKey(ignore: true) String? docId,
      @JsonKey(fromJson: dateTimeFromTimestamp, toJson: timestampFromDateTime)
      DateTime? createdAt,
      int? createdAtMillis,
      String message});
}

/// @nodoc
class __$$_EventMessageCopyWithImpl<$Res>
    extends _$EventMessageCopyWithImpl<$Res, _$_EventMessage>
    implements _$$_EventMessageCopyWith<$Res> {
  __$$_EventMessageCopyWithImpl(
      _$_EventMessage _value, $Res Function(_$_EventMessage) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? creatorId = null,
    Object? docId = freezed,
    Object? createdAt = freezed,
    Object? createdAtMillis = freezed,
    Object? message = null,
  }) {
    return _then(_$_EventMessage(
      creatorId: null == creatorId
          ? _value.creatorId
          : creatorId // ignore: cast_nullable_to_non_nullable
              as String,
      docId: freezed == docId
          ? _value.docId
          : docId // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      createdAtMillis: freezed == createdAtMillis
          ? _value.createdAtMillis
          : createdAtMillis // ignore: cast_nullable_to_non_nullable
              as int?,
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_EventMessage extends _EventMessage {
  _$_EventMessage(
      {required this.creatorId,
      @JsonKey(ignore: true) this.docId,
      @JsonKey(fromJson: dateTimeFromTimestamp, toJson: timestampFromDateTime)
      required this.createdAt,
      this.createdAtMillis,
      required this.message})
      : super._();

  factory _$_EventMessage.fromJson(Map<String, dynamic> json) =>
      _$$_EventMessageFromJson(json);

  @override
  final String creatorId;
  @override
  @JsonKey(ignore: true)
  final String? docId;
//TODO(aurimas): Does not make sense to have it nullable, because it's never nullable
  @override
  @JsonKey(fromJson: dateTimeFromTimestamp, toJson: timestampFromDateTime)
  final DateTime? createdAt;
  @override
  final int? createdAtMillis;
  @override
  final String message;

  @override
  String toString() {
    return 'EventMessage(creatorId: $creatorId, docId: $docId, createdAt: $createdAt, createdAtMillis: $createdAtMillis, message: $message)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_EventMessage &&
            (identical(other.creatorId, creatorId) ||
                other.creatorId == creatorId) &&
            (identical(other.docId, docId) || other.docId == docId) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.createdAtMillis, createdAtMillis) ||
                other.createdAtMillis == createdAtMillis) &&
            (identical(other.message, message) || other.message == message));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType, creatorId, docId, createdAt, createdAtMillis, message);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_EventMessageCopyWith<_$_EventMessage> get copyWith =>
      __$$_EventMessageCopyWithImpl<_$_EventMessage>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_EventMessageToJson(
      this,
    );
  }
}

abstract class _EventMessage extends EventMessage {
  factory _EventMessage(
      {required final String creatorId,
      @JsonKey(ignore: true) final String? docId,
      @JsonKey(fromJson: dateTimeFromTimestamp, toJson: timestampFromDateTime)
      required final DateTime? createdAt,
      final int? createdAtMillis,
      required final String message}) = _$_EventMessage;
  _EventMessage._() : super._();

  factory _EventMessage.fromJson(Map<String, dynamic> json) =
      _$_EventMessage.fromJson;

  @override
  String get creatorId;
  @override
  @JsonKey(ignore: true)
  String? get docId;
  @override //TODO(aurimas): Does not make sense to have it nullable, because it's never nullable
  @JsonKey(fromJson: dateTimeFromTimestamp, toJson: timestampFromDateTime)
  DateTime? get createdAt;
  @override
  int? get createdAtMillis;
  @override
  String get message;
  @override
  @JsonKey(ignore: true)
  _$$_EventMessageCopyWith<_$_EventMessage> get copyWith =>
      throw _privateConstructorUsedError;
}
