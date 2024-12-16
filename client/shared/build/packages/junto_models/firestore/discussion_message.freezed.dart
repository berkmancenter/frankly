// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'discussion_message.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

DiscussionMessage _$DiscussionMessageFromJson(Map<String, dynamic> json) {
  return _DiscussionMessage.fromJson(json);
}

/// @nodoc
mixin _$DiscussionMessage {
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
  $DiscussionMessageCopyWith<DiscussionMessage> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DiscussionMessageCopyWith<$Res> {
  factory $DiscussionMessageCopyWith(
          DiscussionMessage value, $Res Function(DiscussionMessage) then) =
      _$DiscussionMessageCopyWithImpl<$Res, DiscussionMessage>;
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
class _$DiscussionMessageCopyWithImpl<$Res, $Val extends DiscussionMessage>
    implements $DiscussionMessageCopyWith<$Res> {
  _$DiscussionMessageCopyWithImpl(this._value, this._then);

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
abstract class _$$_DiscussionMessageCopyWith<$Res>
    implements $DiscussionMessageCopyWith<$Res> {
  factory _$$_DiscussionMessageCopyWith(_$_DiscussionMessage value,
          $Res Function(_$_DiscussionMessage) then) =
      __$$_DiscussionMessageCopyWithImpl<$Res>;
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
class __$$_DiscussionMessageCopyWithImpl<$Res>
    extends _$DiscussionMessageCopyWithImpl<$Res, _$_DiscussionMessage>
    implements _$$_DiscussionMessageCopyWith<$Res> {
  __$$_DiscussionMessageCopyWithImpl(
      _$_DiscussionMessage _value, $Res Function(_$_DiscussionMessage) _then)
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
    return _then(_$_DiscussionMessage(
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
class _$_DiscussionMessage extends _DiscussionMessage {
  _$_DiscussionMessage(
      {required this.creatorId,
      @JsonKey(ignore: true) this.docId,
      @JsonKey(fromJson: dateTimeFromTimestamp, toJson: timestampFromDateTime)
      required this.createdAt,
      this.createdAtMillis,
      required this.message})
      : super._();

  factory _$_DiscussionMessage.fromJson(Map<String, dynamic> json) =>
      _$$_DiscussionMessageFromJson(json);

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
    return 'DiscussionMessage(creatorId: $creatorId, docId: $docId, createdAt: $createdAt, createdAtMillis: $createdAtMillis, message: $message)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_DiscussionMessage &&
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
  _$$_DiscussionMessageCopyWith<_$_DiscussionMessage> get copyWith =>
      __$$_DiscussionMessageCopyWithImpl<_$_DiscussionMessage>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_DiscussionMessageToJson(
      this,
    );
  }
}

abstract class _DiscussionMessage extends DiscussionMessage {
  factory _DiscussionMessage(
      {required final String creatorId,
      @JsonKey(ignore: true) final String? docId,
      @JsonKey(fromJson: dateTimeFromTimestamp, toJson: timestampFromDateTime)
      required final DateTime? createdAt,
      final int? createdAtMillis,
      required final String message}) = _$_DiscussionMessage;
  _DiscussionMessage._() : super._();

  factory _DiscussionMessage.fromJson(Map<String, dynamic> json) =
      _$_DiscussionMessage.fromJson;

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
  _$$_DiscussionMessageCopyWith<_$_DiscussionMessage> get copyWith =>
      throw _privateConstructorUsedError;
}
