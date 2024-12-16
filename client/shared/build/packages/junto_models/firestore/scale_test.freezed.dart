// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'scale_test.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

ScaleTest _$ScaleTestFromJson(Map<String, dynamic> json) {
  return _ScaleTest.fromJson(json);
}

/// @nodoc
mixin _$ScaleTest {
  String get juntoId => throw _privateConstructorUsedError;
  String get topicId => throw _privateConstructorUsedError;
  String get discussionId => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ScaleTestCopyWith<ScaleTest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ScaleTestCopyWith<$Res> {
  factory $ScaleTestCopyWith(ScaleTest value, $Res Function(ScaleTest) then) =
      _$ScaleTestCopyWithImpl<$Res, ScaleTest>;
  @useResult
  $Res call({String juntoId, String topicId, String discussionId});
}

/// @nodoc
class _$ScaleTestCopyWithImpl<$Res, $Val extends ScaleTest>
    implements $ScaleTestCopyWith<$Res> {
  _$ScaleTestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? juntoId = null,
    Object? topicId = null,
    Object? discussionId = null,
  }) {
    return _then(_value.copyWith(
      juntoId: null == juntoId
          ? _value.juntoId
          : juntoId // ignore: cast_nullable_to_non_nullable
              as String,
      topicId: null == topicId
          ? _value.topicId
          : topicId // ignore: cast_nullable_to_non_nullable
              as String,
      discussionId: null == discussionId
          ? _value.discussionId
          : discussionId // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_ScaleTestCopyWith<$Res> implements $ScaleTestCopyWith<$Res> {
  factory _$$_ScaleTestCopyWith(
          _$_ScaleTest value, $Res Function(_$_ScaleTest) then) =
      __$$_ScaleTestCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String juntoId, String topicId, String discussionId});
}

/// @nodoc
class __$$_ScaleTestCopyWithImpl<$Res>
    extends _$ScaleTestCopyWithImpl<$Res, _$_ScaleTest>
    implements _$$_ScaleTestCopyWith<$Res> {
  __$$_ScaleTestCopyWithImpl(
      _$_ScaleTest _value, $Res Function(_$_ScaleTest) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? juntoId = null,
    Object? topicId = null,
    Object? discussionId = null,
  }) {
    return _then(_$_ScaleTest(
      juntoId: null == juntoId
          ? _value.juntoId
          : juntoId // ignore: cast_nullable_to_non_nullable
              as String,
      topicId: null == topicId
          ? _value.topicId
          : topicId // ignore: cast_nullable_to_non_nullable
              as String,
      discussionId: null == discussionId
          ? _value.discussionId
          : discussionId // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_ScaleTest implements _ScaleTest {
  _$_ScaleTest(
      {required this.juntoId,
      required this.topicId,
      required this.discussionId});

  factory _$_ScaleTest.fromJson(Map<String, dynamic> json) =>
      _$$_ScaleTestFromJson(json);

  @override
  final String juntoId;
  @override
  final String topicId;
  @override
  final String discussionId;

  @override
  String toString() {
    return 'ScaleTest(juntoId: $juntoId, topicId: $topicId, discussionId: $discussionId)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_ScaleTest &&
            (identical(other.juntoId, juntoId) || other.juntoId == juntoId) &&
            (identical(other.topicId, topicId) || other.topicId == topicId) &&
            (identical(other.discussionId, discussionId) ||
                other.discussionId == discussionId));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, juntoId, topicId, discussionId);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_ScaleTestCopyWith<_$_ScaleTest> get copyWith =>
      __$$_ScaleTestCopyWithImpl<_$_ScaleTest>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_ScaleTestToJson(
      this,
    );
  }
}

abstract class _ScaleTest implements ScaleTest {
  factory _ScaleTest(
      {required final String juntoId,
      required final String topicId,
      required final String discussionId}) = _$_ScaleTest;

  factory _ScaleTest.fromJson(Map<String, dynamic> json) =
      _$_ScaleTest.fromJson;

  @override
  String get juntoId;
  @override
  String get topicId;
  @override
  String get discussionId;
  @override
  @JsonKey(ignore: true)
  _$$_ScaleTestCopyWith<_$_ScaleTest> get copyWith =>
      throw _privateConstructorUsedError;
}
