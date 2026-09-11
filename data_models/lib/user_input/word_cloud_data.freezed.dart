// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'word_cloud_data.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

WordCloudData _$WordCloudDataFromJson(Map<String, dynamic> json) {
  return _WordCloudData.fromJson(json);
}

/// @nodoc
mixin _$WordCloudData {
  String get userId => throw _privateConstructorUsedError;
  String get agendaItemId => throw _privateConstructorUsedError;
  String get roomId => throw _privateConstructorUsedError;
  String get prompt => throw _privateConstructorUsedError;
  String get message => throw _privateConstructorUsedError;
  DateTime? get createdDate =>
      throw _privateConstructorUsedError; // Word clouds currently have no voting mechanism.
  int get upvotes => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $WordCloudDataCopyWith<WordCloudData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WordCloudDataCopyWith<$Res> {
  factory $WordCloudDataCopyWith(
          WordCloudData value, $Res Function(WordCloudData) then) =
      _$WordCloudDataCopyWithImpl<$Res, WordCloudData>;
  @useResult
  $Res call(
      {String userId,
      String agendaItemId,
      String roomId,
      String prompt,
      String message,
      DateTime? createdDate,
      int upvotes});
}

/// @nodoc
class _$WordCloudDataCopyWithImpl<$Res, $Val extends WordCloudData>
    implements $WordCloudDataCopyWith<$Res> {
  _$WordCloudDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? agendaItemId = null,
    Object? roomId = null,
    Object? prompt = null,
    Object? message = null,
    Object? createdDate = freezed,
    Object? upvotes = null,
  }) {
    return _then(_value.copyWith(
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      agendaItemId: null == agendaItemId
          ? _value.agendaItemId
          : agendaItemId // ignore: cast_nullable_to_non_nullable
              as String,
      roomId: null == roomId
          ? _value.roomId
          : roomId // ignore: cast_nullable_to_non_nullable
              as String,
      prompt: null == prompt
          ? _value.prompt
          : prompt // ignore: cast_nullable_to_non_nullable
              as String,
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
      createdDate: freezed == createdDate
          ? _value.createdDate
          : createdDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      upvotes: null == upvotes
          ? _value.upvotes
          : upvotes // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_WordCloudDataCopyWith<$Res>
    implements $WordCloudDataCopyWith<$Res> {
  factory _$$_WordCloudDataCopyWith(
          _$_WordCloudData value, $Res Function(_$_WordCloudData) then) =
      __$$_WordCloudDataCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String userId,
      String agendaItemId,
      String roomId,
      String prompt,
      String message,
      DateTime? createdDate,
      int upvotes});
}

/// @nodoc
class __$$_WordCloudDataCopyWithImpl<$Res>
    extends _$WordCloudDataCopyWithImpl<$Res, _$_WordCloudData>
    implements _$$_WordCloudDataCopyWith<$Res> {
  __$$_WordCloudDataCopyWithImpl(
      _$_WordCloudData _value, $Res Function(_$_WordCloudData) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? agendaItemId = null,
    Object? roomId = null,
    Object? prompt = null,
    Object? message = null,
    Object? createdDate = freezed,
    Object? upvotes = null,
  }) {
    return _then(_$_WordCloudData(
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      agendaItemId: null == agendaItemId
          ? _value.agendaItemId
          : agendaItemId // ignore: cast_nullable_to_non_nullable
              as String,
      roomId: null == roomId
          ? _value.roomId
          : roomId // ignore: cast_nullable_to_non_nullable
              as String,
      prompt: null == prompt
          ? _value.prompt
          : prompt // ignore: cast_nullable_to_non_nullable
              as String,
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
      createdDate: freezed == createdDate
          ? _value.createdDate
          : createdDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      upvotes: null == upvotes
          ? _value.upvotes
          : upvotes // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_WordCloudData implements _WordCloudData {
  const _$_WordCloudData(
      {required this.userId,
      required this.agendaItemId,
      required this.roomId,
      required this.prompt,
      required this.message,
      this.createdDate,
      this.upvotes = 0});

  factory _$_WordCloudData.fromJson(Map<String, dynamic> json) =>
      _$$_WordCloudDataFromJson(json);

  @override
  final String userId;
  @override
  final String agendaItemId;
  @override
  final String roomId;
  @override
  final String prompt;
  @override
  final String message;
  @override
  final DateTime? createdDate;
// Word clouds currently have no voting mechanism.
  @override
  @JsonKey()
  final int upvotes;

  @override
  String toString() {
    return 'WordCloudData(userId: $userId, agendaItemId: $agendaItemId, roomId: $roomId, prompt: $prompt, message: $message, createdDate: $createdDate, upvotes: $upvotes)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_WordCloudData &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.agendaItemId, agendaItemId) ||
                other.agendaItemId == agendaItemId) &&
            (identical(other.roomId, roomId) || other.roomId == roomId) &&
            (identical(other.prompt, prompt) || other.prompt == prompt) &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.createdDate, createdDate) ||
                other.createdDate == createdDate) &&
            (identical(other.upvotes, upvotes) || other.upvotes == upvotes));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, userId, agendaItemId, roomId,
      prompt, message, createdDate, upvotes);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_WordCloudDataCopyWith<_$_WordCloudData> get copyWith =>
      __$$_WordCloudDataCopyWithImpl<_$_WordCloudData>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_WordCloudDataToJson(
      this,
    );
  }
}

abstract class _WordCloudData implements WordCloudData {
  const factory _WordCloudData(
      {required final String userId,
      required final String agendaItemId,
      required final String roomId,
      required final String prompt,
      required final String message,
      final DateTime? createdDate,
      final int upvotes}) = _$_WordCloudData;

  factory _WordCloudData.fromJson(Map<String, dynamic> json) =
      _$_WordCloudData.fromJson;

  @override
  String get userId;
  @override
  String get agendaItemId;
  @override
  String get roomId;
  @override
  String get prompt;
  @override
  String get message;
  @override
  DateTime? get createdDate;
  @override // Word clouds currently have no voting mechanism.
  int get upvotes;
  @override
  @JsonKey(ignore: true)
  _$$_WordCloudDataCopyWith<_$_WordCloudData> get copyWith =>
      throw _privateConstructorUsedError;
}
