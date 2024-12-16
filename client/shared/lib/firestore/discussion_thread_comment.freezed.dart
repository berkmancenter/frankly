// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'discussion_thread_comment.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

DiscussionThreadComment _$DiscussionThreadCommentFromJson(
    Map<String, dynamic> json) {
  return _DiscussionThreadComment.fromJson(json);
}

/// @nodoc
mixin _$DiscussionThreadComment {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(fromJson: dateTimeFromTimestamp, toJson: serverTimestamp)
  DateTime? get createdAt => throw _privateConstructorUsedError;
  String? get replyToCommentId => throw _privateConstructorUsedError;
  String get creatorId => throw _privateConstructorUsedError;
  String get comment => throw _privateConstructorUsedError;
  bool get isDeleted => throw _privateConstructorUsedError;
  List<Emotion> get emotions => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $DiscussionThreadCommentCopyWith<DiscussionThreadComment> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DiscussionThreadCommentCopyWith<$Res> {
  factory $DiscussionThreadCommentCopyWith(DiscussionThreadComment value,
          $Res Function(DiscussionThreadComment) then) =
      _$DiscussionThreadCommentCopyWithImpl<$Res, DiscussionThreadComment>;
  @useResult
  $Res call(
      {String id,
      @JsonKey(fromJson: dateTimeFromTimestamp, toJson: serverTimestamp)
      DateTime? createdAt,
      String? replyToCommentId,
      String creatorId,
      String comment,
      bool isDeleted,
      List<Emotion> emotions});
}

/// @nodoc
class _$DiscussionThreadCommentCopyWithImpl<$Res,
        $Val extends DiscussionThreadComment>
    implements $DiscussionThreadCommentCopyWith<$Res> {
  _$DiscussionThreadCommentCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? createdAt = freezed,
    Object? replyToCommentId = freezed,
    Object? creatorId = null,
    Object? comment = null,
    Object? isDeleted = null,
    Object? emotions = null,
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
      replyToCommentId: freezed == replyToCommentId
          ? _value.replyToCommentId
          : replyToCommentId // ignore: cast_nullable_to_non_nullable
              as String?,
      creatorId: null == creatorId
          ? _value.creatorId
          : creatorId // ignore: cast_nullable_to_non_nullable
              as String,
      comment: null == comment
          ? _value.comment
          : comment // ignore: cast_nullable_to_non_nullable
              as String,
      isDeleted: null == isDeleted
          ? _value.isDeleted
          : isDeleted // ignore: cast_nullable_to_non_nullable
              as bool,
      emotions: null == emotions
          ? _value.emotions
          : emotions // ignore: cast_nullable_to_non_nullable
              as List<Emotion>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_DiscussionThreadCommentCopyWith<$Res>
    implements $DiscussionThreadCommentCopyWith<$Res> {
  factory _$$_DiscussionThreadCommentCopyWith(_$_DiscussionThreadComment value,
          $Res Function(_$_DiscussionThreadComment) then) =
      __$$_DiscussionThreadCommentCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      @JsonKey(fromJson: dateTimeFromTimestamp, toJson: serverTimestamp)
      DateTime? createdAt,
      String? replyToCommentId,
      String creatorId,
      String comment,
      bool isDeleted,
      List<Emotion> emotions});
}

/// @nodoc
class __$$_DiscussionThreadCommentCopyWithImpl<$Res>
    extends _$DiscussionThreadCommentCopyWithImpl<$Res,
        _$_DiscussionThreadComment>
    implements _$$_DiscussionThreadCommentCopyWith<$Res> {
  __$$_DiscussionThreadCommentCopyWithImpl(_$_DiscussionThreadComment _value,
      $Res Function(_$_DiscussionThreadComment) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? createdAt = freezed,
    Object? replyToCommentId = freezed,
    Object? creatorId = null,
    Object? comment = null,
    Object? isDeleted = null,
    Object? emotions = null,
  }) {
    return _then(_$_DiscussionThreadComment(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      replyToCommentId: freezed == replyToCommentId
          ? _value.replyToCommentId
          : replyToCommentId // ignore: cast_nullable_to_non_nullable
              as String?,
      creatorId: null == creatorId
          ? _value.creatorId
          : creatorId // ignore: cast_nullable_to_non_nullable
              as String,
      comment: null == comment
          ? _value.comment
          : comment // ignore: cast_nullable_to_non_nullable
              as String,
      isDeleted: null == isDeleted
          ? _value.isDeleted
          : isDeleted // ignore: cast_nullable_to_non_nullable
              as bool,
      emotions: null == emotions
          ? _value.emotions
          : emotions // ignore: cast_nullable_to_non_nullable
              as List<Emotion>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_DiscussionThreadComment extends _DiscussionThreadComment {
  _$_DiscussionThreadComment(
      {required this.id,
      @JsonKey(fromJson: dateTimeFromTimestamp, toJson: serverTimestamp)
      this.createdAt,
      this.replyToCommentId,
      required this.creatorId,
      required this.comment,
      this.isDeleted = false,
      this.emotions = const []})
      : super._();

  factory _$_DiscussionThreadComment.fromJson(Map<String, dynamic> json) =>
      _$$_DiscussionThreadCommentFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(fromJson: dateTimeFromTimestamp, toJson: serverTimestamp)
  final DateTime? createdAt;
  @override
  final String? replyToCommentId;
  @override
  final String creatorId;
  @override
  final String comment;
  @override
  @JsonKey()
  final bool isDeleted;
  @override
  @JsonKey()
  final List<Emotion> emotions;

  @override
  String toString() {
    return 'DiscussionThreadComment(id: $id, createdAt: $createdAt, replyToCommentId: $replyToCommentId, creatorId: $creatorId, comment: $comment, isDeleted: $isDeleted, emotions: $emotions)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_DiscussionThreadComment &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.replyToCommentId, replyToCommentId) ||
                other.replyToCommentId == replyToCommentId) &&
            (identical(other.creatorId, creatorId) ||
                other.creatorId == creatorId) &&
            (identical(other.comment, comment) || other.comment == comment) &&
            (identical(other.isDeleted, isDeleted) ||
                other.isDeleted == isDeleted) &&
            const DeepCollectionEquality().equals(other.emotions, emotions));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      createdAt,
      replyToCommentId,
      creatorId,
      comment,
      isDeleted,
      const DeepCollectionEquality().hash(emotions));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_DiscussionThreadCommentCopyWith<_$_DiscussionThreadComment>
      get copyWith =>
          __$$_DiscussionThreadCommentCopyWithImpl<_$_DiscussionThreadComment>(
              this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_DiscussionThreadCommentToJson(
      this,
    );
  }
}

abstract class _DiscussionThreadComment extends DiscussionThreadComment {
  factory _DiscussionThreadComment(
      {required final String id,
      @JsonKey(fromJson: dateTimeFromTimestamp, toJson: serverTimestamp)
      final DateTime? createdAt,
      final String? replyToCommentId,
      required final String creatorId,
      required final String comment,
      final bool isDeleted,
      final List<Emotion> emotions}) = _$_DiscussionThreadComment;
  _DiscussionThreadComment._() : super._();

  factory _DiscussionThreadComment.fromJson(Map<String, dynamic> json) =
      _$_DiscussionThreadComment.fromJson;

  @override
  String get id;
  @override
  @JsonKey(fromJson: dateTimeFromTimestamp, toJson: serverTimestamp)
  DateTime? get createdAt;
  @override
  String? get replyToCommentId;
  @override
  String get creatorId;
  @override
  String get comment;
  @override
  bool get isDeleted;
  @override
  List<Emotion> get emotions;
  @override
  @JsonKey(ignore: true)
  _$$_DiscussionThreadCommentCopyWith<_$_DiscussionThreadComment>
      get copyWith => throw _privateConstructorUsedError;
}
