// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'emotion.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

Emotion _$EmotionFromJson(Map<String, dynamic> json) {
  return _Emotion.fromJson(json);
}

/// @nodoc
mixin _$Emotion {
  String get creatorId => throw _privateConstructorUsedError;
  EmotionType get emotionType => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $EmotionCopyWith<Emotion> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $EmotionCopyWith<$Res> {
  factory $EmotionCopyWith(Emotion value, $Res Function(Emotion) then) =
      _$EmotionCopyWithImpl<$Res, Emotion>;
  @useResult
  $Res call({String creatorId, EmotionType emotionType});
}

/// @nodoc
class _$EmotionCopyWithImpl<$Res, $Val extends Emotion>
    implements $EmotionCopyWith<$Res> {
  _$EmotionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? creatorId = null,
    Object? emotionType = null,
  }) {
    return _then(_value.copyWith(
      creatorId: null == creatorId
          ? _value.creatorId
          : creatorId // ignore: cast_nullable_to_non_nullable
              as String,
      emotionType: null == emotionType
          ? _value.emotionType
          : emotionType // ignore: cast_nullable_to_non_nullable
              as EmotionType,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_EmotionCopyWith<$Res> implements $EmotionCopyWith<$Res> {
  factory _$$_EmotionCopyWith(
          _$_Emotion value, $Res Function(_$_Emotion) then) =
      __$$_EmotionCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String creatorId, EmotionType emotionType});
}

/// @nodoc
class __$$_EmotionCopyWithImpl<$Res>
    extends _$EmotionCopyWithImpl<$Res, _$_Emotion>
    implements _$$_EmotionCopyWith<$Res> {
  __$$_EmotionCopyWithImpl(_$_Emotion _value, $Res Function(_$_Emotion) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? creatorId = null,
    Object? emotionType = null,
  }) {
    return _then(_$_Emotion(
      creatorId: null == creatorId
          ? _value.creatorId
          : creatorId // ignore: cast_nullable_to_non_nullable
              as String,
      emotionType: null == emotionType
          ? _value.emotionType
          : emotionType // ignore: cast_nullable_to_non_nullable
              as EmotionType,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_Emotion extends _Emotion {
  _$_Emotion({required this.creatorId, required this.emotionType}) : super._();

  factory _$_Emotion.fromJson(Map<String, dynamic> json) =>
      _$$_EmotionFromJson(json);

  @override
  final String creatorId;
  @override
  final EmotionType emotionType;

  @override
  String toString() {
    return 'Emotion(creatorId: $creatorId, emotionType: $emotionType)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_Emotion &&
            (identical(other.creatorId, creatorId) ||
                other.creatorId == creatorId) &&
            (identical(other.emotionType, emotionType) ||
                other.emotionType == emotionType));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, creatorId, emotionType);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_EmotionCopyWith<_$_Emotion> get copyWith =>
      __$$_EmotionCopyWithImpl<_$_Emotion>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_EmotionToJson(
      this,
    );
  }
}

abstract class _Emotion extends Emotion {
  factory _Emotion(
      {required final String creatorId,
      required final EmotionType emotionType}) = _$_Emotion;
  _Emotion._() : super._();

  factory _Emotion.fromJson(Map<String, dynamic> json) = _$_Emotion.fromJson;

  @override
  String get creatorId;
  @override
  EmotionType get emotionType;
  @override
  @JsonKey(ignore: true)
  _$$_EmotionCopyWith<_$_Emotion> get copyWith =>
      throw _privateConstructorUsedError;
}
