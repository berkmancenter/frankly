// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'chat_suggestion_data.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

ChatSuggestionData _$ChatSuggestionDataFromJson(Map<String, dynamic> json) {
  return _ChatSuggestionData.fromJson(json);
}

/// @nodoc
mixin _$ChatSuggestionData {
  String? get id => throw _privateConstructorUsedError;
  String? get creatorId => throw _privateConstructorUsedError;
  String? get creatorEmail => throw _privateConstructorUsedError;
  String? get creatorName => throw _privateConstructorUsedError;
  DateTime? get createdDate => throw _privateConstructorUsedError;
  String? get message => throw _privateConstructorUsedError;
  EmotionType? get emotionType => throw _privateConstructorUsedError;
  int? get upvotes => throw _privateConstructorUsedError;
  int? get downvotes => throw _privateConstructorUsedError;
  @JsonKey(unknownEnumValue: ChatSuggestionType.chat)
  ChatSuggestionType get type => throw _privateConstructorUsedError;
  String? get roomId => throw _privateConstructorUsedError;
  String? get agendaItemId => throw _privateConstructorUsedError;
  bool? get deleted => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ChatSuggestionDataCopyWith<ChatSuggestionData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ChatSuggestionDataCopyWith<$Res> {
  factory $ChatSuggestionDataCopyWith(
          ChatSuggestionData value, $Res Function(ChatSuggestionData) then) =
      _$ChatSuggestionDataCopyWithImpl<$Res, ChatSuggestionData>;
  @useResult
  $Res call(
      {String? id,
      String? creatorId,
      String? creatorEmail,
      String? creatorName,
      DateTime? createdDate,
      String? message,
      EmotionType? emotionType,
      int? upvotes,
      int? downvotes,
      @JsonKey(unknownEnumValue: ChatSuggestionType.chat)
      ChatSuggestionType type,
      String? roomId,
      String? agendaItemId,
      bool? deleted});
}

/// @nodoc
class _$ChatSuggestionDataCopyWithImpl<$Res, $Val extends ChatSuggestionData>
    implements $ChatSuggestionDataCopyWith<$Res> {
  _$ChatSuggestionDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? creatorId = freezed,
    Object? creatorEmail = freezed,
    Object? creatorName = freezed,
    Object? createdDate = freezed,
    Object? message = freezed,
    Object? emotionType = freezed,
    Object? upvotes = freezed,
    Object? downvotes = freezed,
    Object? type = null,
    Object? roomId = freezed,
    Object? agendaItemId = freezed,
    Object? deleted = freezed,
  }) {
    return _then(_value.copyWith(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      creatorId: freezed == creatorId
          ? _value.creatorId
          : creatorId // ignore: cast_nullable_to_non_nullable
              as String?,
      creatorEmail: freezed == creatorEmail
          ? _value.creatorEmail
          : creatorEmail // ignore: cast_nullable_to_non_nullable
              as String?,
      creatorName: freezed == creatorName
          ? _value.creatorName
          : creatorName // ignore: cast_nullable_to_non_nullable
              as String?,
      createdDate: freezed == createdDate
          ? _value.createdDate
          : createdDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      message: freezed == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String?,
      emotionType: freezed == emotionType
          ? _value.emotionType
          : emotionType // ignore: cast_nullable_to_non_nullable
              as EmotionType?,
      upvotes: freezed == upvotes
          ? _value.upvotes
          : upvotes // ignore: cast_nullable_to_non_nullable
              as int?,
      downvotes: freezed == downvotes
          ? _value.downvotes
          : downvotes // ignore: cast_nullable_to_non_nullable
              as int?,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as ChatSuggestionType,
      roomId: freezed == roomId
          ? _value.roomId
          : roomId // ignore: cast_nullable_to_non_nullable
              as String?,
      agendaItemId: freezed == agendaItemId
          ? _value.agendaItemId
          : agendaItemId // ignore: cast_nullable_to_non_nullable
              as String?,
      deleted: freezed == deleted
          ? _value.deleted
          : deleted // ignore: cast_nullable_to_non_nullable
              as bool?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_ChatSuggestionDataCopyWith<$Res>
    implements $ChatSuggestionDataCopyWith<$Res> {
  factory _$$_ChatSuggestionDataCopyWith(_$_ChatSuggestionData value,
          $Res Function(_$_ChatSuggestionData) then) =
      __$$_ChatSuggestionDataCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String? id,
      String? creatorId,
      String? creatorEmail,
      String? creatorName,
      DateTime? createdDate,
      String? message,
      EmotionType? emotionType,
      int? upvotes,
      int? downvotes,
      @JsonKey(unknownEnumValue: ChatSuggestionType.chat)
      ChatSuggestionType type,
      String? roomId,
      String? agendaItemId,
      bool? deleted});
}

/// @nodoc
class __$$_ChatSuggestionDataCopyWithImpl<$Res>
    extends _$ChatSuggestionDataCopyWithImpl<$Res, _$_ChatSuggestionData>
    implements _$$_ChatSuggestionDataCopyWith<$Res> {
  __$$_ChatSuggestionDataCopyWithImpl(
      _$_ChatSuggestionData _value, $Res Function(_$_ChatSuggestionData) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? creatorId = freezed,
    Object? creatorEmail = freezed,
    Object? creatorName = freezed,
    Object? createdDate = freezed,
    Object? message = freezed,
    Object? emotionType = freezed,
    Object? upvotes = freezed,
    Object? downvotes = freezed,
    Object? type = null,
    Object? roomId = freezed,
    Object? agendaItemId = freezed,
    Object? deleted = freezed,
  }) {
    return _then(_$_ChatSuggestionData(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      creatorId: freezed == creatorId
          ? _value.creatorId
          : creatorId // ignore: cast_nullable_to_non_nullable
              as String?,
      creatorEmail: freezed == creatorEmail
          ? _value.creatorEmail
          : creatorEmail // ignore: cast_nullable_to_non_nullable
              as String?,
      creatorName: freezed == creatorName
          ? _value.creatorName
          : creatorName // ignore: cast_nullable_to_non_nullable
              as String?,
      createdDate: freezed == createdDate
          ? _value.createdDate
          : createdDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      message: freezed == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String?,
      emotionType: freezed == emotionType
          ? _value.emotionType
          : emotionType // ignore: cast_nullable_to_non_nullable
              as EmotionType?,
      upvotes: freezed == upvotes
          ? _value.upvotes
          : upvotes // ignore: cast_nullable_to_non_nullable
              as int?,
      downvotes: freezed == downvotes
          ? _value.downvotes
          : downvotes // ignore: cast_nullable_to_non_nullable
              as int?,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as ChatSuggestionType,
      roomId: freezed == roomId
          ? _value.roomId
          : roomId // ignore: cast_nullable_to_non_nullable
              as String?,
      agendaItemId: freezed == agendaItemId
          ? _value.agendaItemId
          : agendaItemId // ignore: cast_nullable_to_non_nullable
              as String?,
      deleted: freezed == deleted
          ? _value.deleted
          : deleted // ignore: cast_nullable_to_non_nullable
              as bool?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_ChatSuggestionData implements _ChatSuggestionData {
  _$_ChatSuggestionData(
      {this.id,
      this.creatorId,
      this.creatorEmail,
      this.creatorName,
      this.createdDate,
      this.message,
      this.emotionType,
      this.upvotes,
      this.downvotes,
      @JsonKey(unknownEnumValue: ChatSuggestionType.chat)
      this.type = ChatSuggestionType.chat,
      this.roomId,
      this.agendaItemId,
      this.deleted});

  factory _$_ChatSuggestionData.fromJson(Map<String, dynamic> json) =>
      _$$_ChatSuggestionDataFromJson(json);

  @override
  final String? id;
  @override
  final String? creatorId;
  @override
  final String? creatorEmail;
  @override
  final String? creatorName;
  @override
  final DateTime? createdDate;
  @override
  final String? message;
  @override
  final EmotionType? emotionType;
  @override
  final int? upvotes;
  @override
  final int? downvotes;
  @override
  @JsonKey(unknownEnumValue: ChatSuggestionType.chat)
  final ChatSuggestionType type;
  @override
  final String? roomId;
  @override
  final String? agendaItemId;
  @override
  final bool? deleted;

  @override
  String toString() {
    return 'ChatSuggestionData(id: $id, creatorId: $creatorId, creatorEmail: $creatorEmail, creatorName: $creatorName, createdDate: $createdDate, message: $message, emotionType: $emotionType, upvotes: $upvotes, downvotes: $downvotes, type: $type, roomId: $roomId, agendaItemId: $agendaItemId, deleted: $deleted)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_ChatSuggestionData &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.creatorId, creatorId) ||
                other.creatorId == creatorId) &&
            (identical(other.creatorEmail, creatorEmail) ||
                other.creatorEmail == creatorEmail) &&
            (identical(other.creatorName, creatorName) ||
                other.creatorName == creatorName) &&
            (identical(other.createdDate, createdDate) ||
                other.createdDate == createdDate) &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.emotionType, emotionType) ||
                other.emotionType == emotionType) &&
            (identical(other.upvotes, upvotes) || other.upvotes == upvotes) &&
            (identical(other.downvotes, downvotes) ||
                other.downvotes == downvotes) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.roomId, roomId) || other.roomId == roomId) &&
            (identical(other.agendaItemId, agendaItemId) ||
                other.agendaItemId == agendaItemId) &&
            (identical(other.deleted, deleted) || other.deleted == deleted));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      creatorId,
      creatorEmail,
      creatorName,
      createdDate,
      message,
      emotionType,
      upvotes,
      downvotes,
      type,
      roomId,
      agendaItemId,
      deleted);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_ChatSuggestionDataCopyWith<_$_ChatSuggestionData> get copyWith =>
      __$$_ChatSuggestionDataCopyWithImpl<_$_ChatSuggestionData>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_ChatSuggestionDataToJson(
      this,
    );
  }
}

abstract class _ChatSuggestionData implements ChatSuggestionData {
  factory _ChatSuggestionData(
      {final String? id,
      final String? creatorId,
      final String? creatorEmail,
      final String? creatorName,
      final DateTime? createdDate,
      final String? message,
      final EmotionType? emotionType,
      final int? upvotes,
      final int? downvotes,
      @JsonKey(unknownEnumValue: ChatSuggestionType.chat)
      final ChatSuggestionType type,
      final String? roomId,
      final String? agendaItemId,
      final bool? deleted}) = _$_ChatSuggestionData;

  factory _ChatSuggestionData.fromJson(Map<String, dynamic> json) =
      _$_ChatSuggestionData.fromJson;

  @override
  String? get id;
  @override
  String? get creatorId;
  @override
  String? get creatorEmail;
  @override
  String? get creatorName;
  @override
  DateTime? get createdDate;
  @override
  String? get message;
  @override
  EmotionType? get emotionType;
  @override
  int? get upvotes;
  @override
  int? get downvotes;
  @override
  @JsonKey(unknownEnumValue: ChatSuggestionType.chat)
  ChatSuggestionType get type;
  @override
  String? get roomId;
  @override
  String? get agendaItemId;
  @override
  bool? get deleted;
  @override
  @JsonKey(ignore: true)
  _$$_ChatSuggestionDataCopyWith<_$_ChatSuggestionData> get copyWith =>
      throw _privateConstructorUsedError;
}
