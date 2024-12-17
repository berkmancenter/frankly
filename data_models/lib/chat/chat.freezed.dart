// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'chat.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

ChatMessage _$ChatMessageFromJson(Map<String, dynamic> json) {
  return _ChatMessage.fromJson(json);
}

/// @nodoc
mixin _$ChatMessage {
  String? get id => throw _privateConstructorUsedError;
  String? get collectionPath => throw _privateConstructorUsedError;
  String? get message => throw _privateConstructorUsedError;
  @JsonKey(unknownEnumValue: null)
  EmotionType? get emotionType => throw _privateConstructorUsedError;
  String? get creatorId => throw _privateConstructorUsedError;
  @JsonKey(fromJson: dateTimeFromTimestamp, toJson: serverTimestamp)
  DateTime? get createdDate => throw _privateConstructorUsedError;
  @JsonKey(
      defaultValue: ChatMessageStatus.active,
      unknownEnumValue: ChatMessageStatus.active)
  ChatMessageStatus get messageStatus => throw _privateConstructorUsedError;
  @JsonKey(unknownEnumValue: null)
  MembershipStatus? get membershipStatusSnapshot =>
      throw _privateConstructorUsedError;

  /// Setting this field to true indicates it should show up in all breakout
  /// rooms and show in the floating display on screen
  bool? get broadcast => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ChatMessageCopyWith<ChatMessage> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ChatMessageCopyWith<$Res> {
  factory $ChatMessageCopyWith(
          ChatMessage value, $Res Function(ChatMessage) then) =
      _$ChatMessageCopyWithImpl<$Res, ChatMessage>;
  @useResult
  $Res call(
      {String? id,
      String? collectionPath,
      String? message,
      @JsonKey(unknownEnumValue: null) EmotionType? emotionType,
      String? creatorId,
      @JsonKey(fromJson: dateTimeFromTimestamp, toJson: serverTimestamp)
      DateTime? createdDate,
      @JsonKey(
          defaultValue: ChatMessageStatus.active,
          unknownEnumValue: ChatMessageStatus.active)
      ChatMessageStatus messageStatus,
      @JsonKey(unknownEnumValue: null)
      MembershipStatus? membershipStatusSnapshot,
      bool? broadcast});
}

/// @nodoc
class _$ChatMessageCopyWithImpl<$Res, $Val extends ChatMessage>
    implements $ChatMessageCopyWith<$Res> {
  _$ChatMessageCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? collectionPath = freezed,
    Object? message = freezed,
    Object? emotionType = freezed,
    Object? creatorId = freezed,
    Object? createdDate = freezed,
    Object? messageStatus = null,
    Object? membershipStatusSnapshot = freezed,
    Object? broadcast = freezed,
  }) {
    return _then(_value.copyWith(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      collectionPath: freezed == collectionPath
          ? _value.collectionPath
          : collectionPath // ignore: cast_nullable_to_non_nullable
              as String?,
      message: freezed == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String?,
      emotionType: freezed == emotionType
          ? _value.emotionType
          : emotionType // ignore: cast_nullable_to_non_nullable
              as EmotionType?,
      creatorId: freezed == creatorId
          ? _value.creatorId
          : creatorId // ignore: cast_nullable_to_non_nullable
              as String?,
      createdDate: freezed == createdDate
          ? _value.createdDate
          : createdDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      messageStatus: null == messageStatus
          ? _value.messageStatus
          : messageStatus // ignore: cast_nullable_to_non_nullable
              as ChatMessageStatus,
      membershipStatusSnapshot: freezed == membershipStatusSnapshot
          ? _value.membershipStatusSnapshot
          : membershipStatusSnapshot // ignore: cast_nullable_to_non_nullable
              as MembershipStatus?,
      broadcast: freezed == broadcast
          ? _value.broadcast
          : broadcast // ignore: cast_nullable_to_non_nullable
              as bool?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_ChatMessageCopyWith<$Res>
    implements $ChatMessageCopyWith<$Res> {
  factory _$$_ChatMessageCopyWith(
          _$_ChatMessage value, $Res Function(_$_ChatMessage) then) =
      __$$_ChatMessageCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String? id,
      String? collectionPath,
      String? message,
      @JsonKey(unknownEnumValue: null) EmotionType? emotionType,
      String? creatorId,
      @JsonKey(fromJson: dateTimeFromTimestamp, toJson: serverTimestamp)
      DateTime? createdDate,
      @JsonKey(
          defaultValue: ChatMessageStatus.active,
          unknownEnumValue: ChatMessageStatus.active)
      ChatMessageStatus messageStatus,
      @JsonKey(unknownEnumValue: null)
      MembershipStatus? membershipStatusSnapshot,
      bool? broadcast});
}

/// @nodoc
class __$$_ChatMessageCopyWithImpl<$Res>
    extends _$ChatMessageCopyWithImpl<$Res, _$_ChatMessage>
    implements _$$_ChatMessageCopyWith<$Res> {
  __$$_ChatMessageCopyWithImpl(
      _$_ChatMessage _value, $Res Function(_$_ChatMessage) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? collectionPath = freezed,
    Object? message = freezed,
    Object? emotionType = freezed,
    Object? creatorId = freezed,
    Object? createdDate = freezed,
    Object? messageStatus = null,
    Object? membershipStatusSnapshot = freezed,
    Object? broadcast = freezed,
  }) {
    return _then(_$_ChatMessage(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      collectionPath: freezed == collectionPath
          ? _value.collectionPath
          : collectionPath // ignore: cast_nullable_to_non_nullable
              as String?,
      message: freezed == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String?,
      emotionType: freezed == emotionType
          ? _value.emotionType
          : emotionType // ignore: cast_nullable_to_non_nullable
              as EmotionType?,
      creatorId: freezed == creatorId
          ? _value.creatorId
          : creatorId // ignore: cast_nullable_to_non_nullable
              as String?,
      createdDate: freezed == createdDate
          ? _value.createdDate
          : createdDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      messageStatus: null == messageStatus
          ? _value.messageStatus
          : messageStatus // ignore: cast_nullable_to_non_nullable
              as ChatMessageStatus,
      membershipStatusSnapshot: freezed == membershipStatusSnapshot
          ? _value.membershipStatusSnapshot
          : membershipStatusSnapshot // ignore: cast_nullable_to_non_nullable
              as MembershipStatus?,
      broadcast: freezed == broadcast
          ? _value.broadcast
          : broadcast // ignore: cast_nullable_to_non_nullable
              as bool?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_ChatMessage extends _ChatMessage {
  _$_ChatMessage(
      {this.id,
      this.collectionPath,
      this.message,
      @JsonKey(unknownEnumValue: null) this.emotionType,
      this.creatorId,
      @JsonKey(fromJson: dateTimeFromTimestamp, toJson: serverTimestamp)
      this.createdDate,
      @JsonKey(
          defaultValue: ChatMessageStatus.active,
          unknownEnumValue: ChatMessageStatus.active)
      this.messageStatus = ChatMessageStatus.active,
      @JsonKey(unknownEnumValue: null) this.membershipStatusSnapshot,
      this.broadcast = false})
      : super._();

  factory _$_ChatMessage.fromJson(Map<String, dynamic> json) =>
      _$$_ChatMessageFromJson(json);

  @override
  final String? id;
  @override
  final String? collectionPath;
  @override
  final String? message;
  @override
  @JsonKey(unknownEnumValue: null)
  final EmotionType? emotionType;
  @override
  final String? creatorId;
  @override
  @JsonKey(fromJson: dateTimeFromTimestamp, toJson: serverTimestamp)
  final DateTime? createdDate;
  @override
  @JsonKey(
      defaultValue: ChatMessageStatus.active,
      unknownEnumValue: ChatMessageStatus.active)
  final ChatMessageStatus messageStatus;
  @override
  @JsonKey(unknownEnumValue: null)
  final MembershipStatus? membershipStatusSnapshot;

  /// Setting this field to true indicates it should show up in all breakout
  /// rooms and show in the floating display on screen
  @override
  @JsonKey()
  final bool? broadcast;

  @override
  String toString() {
    return 'ChatMessage(id: $id, collectionPath: $collectionPath, message: $message, emotionType: $emotionType, creatorId: $creatorId, createdDate: $createdDate, messageStatus: $messageStatus, membershipStatusSnapshot: $membershipStatusSnapshot, broadcast: $broadcast)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_ChatMessage &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.collectionPath, collectionPath) ||
                other.collectionPath == collectionPath) &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.emotionType, emotionType) ||
                other.emotionType == emotionType) &&
            (identical(other.creatorId, creatorId) ||
                other.creatorId == creatorId) &&
            (identical(other.createdDate, createdDate) ||
                other.createdDate == createdDate) &&
            (identical(other.messageStatus, messageStatus) ||
                other.messageStatus == messageStatus) &&
            (identical(
                    other.membershipStatusSnapshot, membershipStatusSnapshot) ||
                other.membershipStatusSnapshot == membershipStatusSnapshot) &&
            (identical(other.broadcast, broadcast) ||
                other.broadcast == broadcast));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      collectionPath,
      message,
      emotionType,
      creatorId,
      createdDate,
      messageStatus,
      membershipStatusSnapshot,
      broadcast);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_ChatMessageCopyWith<_$_ChatMessage> get copyWith =>
      __$$_ChatMessageCopyWithImpl<_$_ChatMessage>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_ChatMessageToJson(
      this,
    );
  }
}

abstract class _ChatMessage extends ChatMessage {
  factory _ChatMessage(
      {final String? id,
      final String? collectionPath,
      final String? message,
      @JsonKey(unknownEnumValue: null) final EmotionType? emotionType,
      final String? creatorId,
      @JsonKey(fromJson: dateTimeFromTimestamp, toJson: serverTimestamp)
      final DateTime? createdDate,
      @JsonKey(
          defaultValue: ChatMessageStatus.active,
          unknownEnumValue: ChatMessageStatus.active)
      final ChatMessageStatus messageStatus,
      @JsonKey(unknownEnumValue: null)
      final MembershipStatus? membershipStatusSnapshot,
      final bool? broadcast}) = _$_ChatMessage;
  _ChatMessage._() : super._();

  factory _ChatMessage.fromJson(Map<String, dynamic> json) =
      _$_ChatMessage.fromJson;

  @override
  String? get id;
  @override
  String? get collectionPath;
  @override
  String? get message;
  @override
  @JsonKey(unknownEnumValue: null)
  EmotionType? get emotionType;
  @override
  String? get creatorId;
  @override
  @JsonKey(fromJson: dateTimeFromTimestamp, toJson: serverTimestamp)
  DateTime? get createdDate;
  @override
  @JsonKey(
      defaultValue: ChatMessageStatus.active,
      unknownEnumValue: ChatMessageStatus.active)
  ChatMessageStatus get messageStatus;
  @override
  @JsonKey(unknownEnumValue: null)
  MembershipStatus? get membershipStatusSnapshot;
  @override

  /// Setting this field to true indicates it should show up in all breakout
  /// rooms and show in the floating display on screen
  bool? get broadcast;
  @override
  @JsonKey(ignore: true)
  _$$_ChatMessageCopyWith<_$_ChatMessage> get copyWith =>
      throw _privateConstructorUsedError;
}
