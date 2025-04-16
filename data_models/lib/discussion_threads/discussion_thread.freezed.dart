// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'discussion_thread.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

DiscussionThread _$DiscussionThreadFromJson(Map<String, dynamic> json) {
  return _DiscussionThread.fromJson(json);
}

/// @nodoc
mixin _$DiscussionThread {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(fromJson: dateTimeFromTimestamp, toJson: serverTimestamp)
  DateTime? get createdAt => throw _privateConstructorUsedError;
  String get creatorId => throw _privateConstructorUsedError;
  List<String> get likedByIds => throw _privateConstructorUsedError;
  List<String> get dislikedByIds => throw _privateConstructorUsedError;
  List<Emotion> get emotions => throw _privateConstructorUsedError;
  String get content => throw _privateConstructorUsedError;
  String? get imageUrl => throw _privateConstructorUsedError;
  bool get isDeleted => throw _privateConstructorUsedError;
  int get commentCount => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $DiscussionThreadCopyWith<DiscussionThread> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DiscussionThreadCopyWith<$Res> {
  factory $DiscussionThreadCopyWith(
          DiscussionThread value, $Res Function(DiscussionThread) then) =
      _$DiscussionThreadCopyWithImpl<$Res, DiscussionThread>;
  @useResult
  $Res call(
      {String id,
      @JsonKey(fromJson: dateTimeFromTimestamp, toJson: serverTimestamp)
      DateTime? createdAt,
      String creatorId,
      List<String> likedByIds,
      List<String> dislikedByIds,
      List<Emotion> emotions,
      String content,
      String? imageUrl,
      bool isDeleted,
      int commentCount});
}

/// @nodoc
class _$DiscussionThreadCopyWithImpl<$Res, $Val extends DiscussionThread>
    implements $DiscussionThreadCopyWith<$Res> {
  _$DiscussionThreadCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? createdAt = freezed,
    Object? creatorId = null,
    Object? likedByIds = null,
    Object? dislikedByIds = null,
    Object? emotions = null,
    Object? content = null,
    Object? imageUrl = freezed,
    Object? isDeleted = null,
    Object? commentCount = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      creatorId: null == creatorId
          ? _value.creatorId
          : creatorId // ignore: cast_nullable_to_non_nullable
              as String,
      likedByIds: null == likedByIds
          ? _value.likedByIds
          : likedByIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
      dislikedByIds: null == dislikedByIds
          ? _value.dislikedByIds
          : dislikedByIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
      emotions: null == emotions
          ? _value.emotions
          : emotions // ignore: cast_nullable_to_non_nullable
              as List<Emotion>,
      content: null == content
          ? _value.content
          : content // ignore: cast_nullable_to_non_nullable
              as String,
      imageUrl: freezed == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      isDeleted: null == isDeleted
          ? _value.isDeleted
          : isDeleted // ignore: cast_nullable_to_non_nullable
              as bool,
      commentCount: null == commentCount
          ? _value.commentCount
          : commentCount // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_DiscussionThreadCopyWith<$Res>
    implements $DiscussionThreadCopyWith<$Res> {
  factory _$$_DiscussionThreadCopyWith(
          _$_DiscussionThread value, $Res Function(_$_DiscussionThread) then) =
      __$$_DiscussionThreadCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      @JsonKey(fromJson: dateTimeFromTimestamp, toJson: serverTimestamp)
      DateTime? createdAt,
      String creatorId,
      List<String> likedByIds,
      List<String> dislikedByIds,
      List<Emotion> emotions,
      String content,
      String? imageUrl,
      bool isDeleted,
      int commentCount});
}

/// @nodoc
class __$$_DiscussionThreadCopyWithImpl<$Res>
    extends _$DiscussionThreadCopyWithImpl<$Res, _$_DiscussionThread>
    implements _$$_DiscussionThreadCopyWith<$Res> {
  __$$_DiscussionThreadCopyWithImpl(
      _$_DiscussionThread _value, $Res Function(_$_DiscussionThread) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? createdAt = freezed,
    Object? creatorId = null,
    Object? likedByIds = null,
    Object? dislikedByIds = null,
    Object? emotions = null,
    Object? content = null,
    Object? imageUrl = freezed,
    Object? isDeleted = null,
    Object? commentCount = null,
  }) {
    return _then(_$_DiscussionThread(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      creatorId: null == creatorId
          ? _value.creatorId
          : creatorId // ignore: cast_nullable_to_non_nullable
              as String,
      likedByIds: null == likedByIds
          ? _value.likedByIds
          : likedByIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
      dislikedByIds: null == dislikedByIds
          ? _value.dislikedByIds
          : dislikedByIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
      emotions: null == emotions
          ? _value.emotions
          : emotions // ignore: cast_nullable_to_non_nullable
              as List<Emotion>,
      content: null == content
          ? _value.content
          : content // ignore: cast_nullable_to_non_nullable
              as String,
      imageUrl: freezed == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      isDeleted: null == isDeleted
          ? _value.isDeleted
          : isDeleted // ignore: cast_nullable_to_non_nullable
              as bool,
      commentCount: null == commentCount
          ? _value.commentCount
          : commentCount // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_DiscussionThread extends _DiscussionThread {
  _$_DiscussionThread(
      {required this.id,
      @JsonKey(fromJson: dateTimeFromTimestamp, toJson: serverTimestamp)
      this.createdAt,
      required this.creatorId,
      this.likedByIds = const [],
      this.dislikedByIds = const [],
      this.emotions = const [],
      required this.content,
      this.imageUrl,
      this.isDeleted = false,
      this.commentCount = 0})
      : super._();

  factory _$_DiscussionThread.fromJson(Map<String, dynamic> json) =>
      _$$_DiscussionThreadFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(fromJson: dateTimeFromTimestamp, toJson: serverTimestamp)
  final DateTime? createdAt;
  @override
  final String creatorId;
  @override
  @JsonKey()
  final List<String> likedByIds;
  @override
  @JsonKey()
  final List<String> dislikedByIds;
  @override
  @JsonKey()
  final List<Emotion> emotions;
  @override
  final String content;
  @override
  final String? imageUrl;
  @override
  @JsonKey()
  final bool isDeleted;
  @override
  @JsonKey()
  final int commentCount;

  @override
  String toString() {
    return 'DiscussionThread(id: $id, createdAt: $createdAt, creatorId: $creatorId, likedByIds: $likedByIds, dislikedByIds: $dislikedByIds, emotions: $emotions, content: $content, imageUrl: $imageUrl, isDeleted: $isDeleted, commentCount: $commentCount)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_DiscussionThread &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.creatorId, creatorId) ||
                other.creatorId == creatorId) &&
            const DeepCollectionEquality()
                .equals(other.likedByIds, likedByIds) &&
            const DeepCollectionEquality()
                .equals(other.dislikedByIds, dislikedByIds) &&
            const DeepCollectionEquality().equals(other.emotions, emotions) &&
            (identical(other.content, content) || other.content == content) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl) &&
            (identical(other.isDeleted, isDeleted) ||
                other.isDeleted == isDeleted) &&
            (identical(other.commentCount, commentCount) ||
                other.commentCount == commentCount));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      createdAt,
      creatorId,
      const DeepCollectionEquality().hash(likedByIds),
      const DeepCollectionEquality().hash(dislikedByIds),
      const DeepCollectionEquality().hash(emotions),
      content,
      imageUrl,
      isDeleted,
      commentCount);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_DiscussionThreadCopyWith<_$_DiscussionThread> get copyWith =>
      __$$_DiscussionThreadCopyWithImpl<_$_DiscussionThread>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_DiscussionThreadToJson(
      this,
    );
  }
}

abstract class _DiscussionThread extends DiscussionThread {
  factory _DiscussionThread(
      {required final String id,
      @JsonKey(fromJson: dateTimeFromTimestamp, toJson: serverTimestamp)
      final DateTime? createdAt,
      required final String creatorId,
      final List<String> likedByIds,
      final List<String> dislikedByIds,
      final List<Emotion> emotions,
      required final String content,
      final String? imageUrl,
      final bool isDeleted,
      final int commentCount}) = _$_DiscussionThread;
  _DiscussionThread._() : super._();

  factory _DiscussionThread.fromJson(Map<String, dynamic> json) =
      _$_DiscussionThread.fromJson;

  @override
  String get id;
  @override
  @JsonKey(fromJson: dateTimeFromTimestamp, toJson: serverTimestamp)
  DateTime? get createdAt;
  @override
  String get creatorId;
  @override
  List<String> get likedByIds;
  @override
  List<String> get dislikedByIds;
  @override
  List<Emotion> get emotions;
  @override
  String get content;
  @override
  String? get imageUrl;
  @override
  bool get isDeleted;
  @override
  int get commentCount;
  @override
  @JsonKey(ignore: true)
  _$$_DiscussionThreadCopyWith<_$_DiscussionThread> get copyWith =>
      throw _privateConstructorUsedError;
}
