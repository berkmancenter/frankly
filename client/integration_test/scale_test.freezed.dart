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
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

ScaleTest _$ScaleTestFromJson(Map<String, dynamic> json) {
  return _ScaleTest.fromJson(json);
}

/// @nodoc
mixin _$ScaleTest {
  String get communityId => throw _privateConstructorUsedError;
  String get templateId => throw _privateConstructorUsedError;
  String get eventId => throw _privateConstructorUsedError;

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
  $Res call({String communityId, String templateId, String eventId});
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
    Object? communityId = null,
    Object? templateId = null,
    Object? eventId = null,
  }) {
    return _then(_value.copyWith(
      communityId: null == communityId
          ? _value.communityId
          : communityId // ignore: cast_nullable_to_non_nullable
              as String,
      templateId: null == templateId
          ? _value.templateId
          : templateId // ignore: cast_nullable_to_non_nullable
              as String,
      eventId: null == eventId
          ? _value.eventId
          : eventId // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ScaleTestImplCopyWith<$Res>
    implements $ScaleTestCopyWith<$Res> {
  factory _$$ScaleTestImplCopyWith(
          _$ScaleTestImpl value, $Res Function(_$ScaleTestImpl) then) =
      __$$ScaleTestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String communityId, String templateId, String eventId});
}

/// @nodoc
class __$$ScaleTestImplCopyWithImpl<$Res>
    extends _$ScaleTestCopyWithImpl<$Res, _$ScaleTestImpl>
    implements _$$ScaleTestImplCopyWith<$Res> {
  __$$ScaleTestImplCopyWithImpl(
      _$ScaleTestImpl _value, $Res Function(_$ScaleTestImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? communityId = null,
    Object? templateId = null,
    Object? eventId = null,
  }) {
    return _then(_$ScaleTestImpl(
      communityId: null == communityId
          ? _value.communityId
          : communityId // ignore: cast_nullable_to_non_nullable
              as String,
      templateId: null == templateId
          ? _value.templateId
          : templateId // ignore: cast_nullable_to_non_nullable
              as String,
      eventId: null == eventId
          ? _value.eventId
          : eventId // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ScaleTestImpl implements _ScaleTest {
  _$ScaleTestImpl(
      {required this.communityId,
      required this.templateId,
      required this.eventId});

  factory _$ScaleTestImpl.fromJson(Map<String, dynamic> json) =>
      _$$ScaleTestImplFromJson(json);

  @override
  final String communityId;
  @override
  final String templateId;
  @override
  final String eventId;

  @override
  String toString() {
    return 'ScaleTest(communityId: $communityId, templateId: $templateId, eventId: $eventId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ScaleTestImpl &&
            (identical(other.communityId, communityId) ||
                other.communityId == communityId) &&
            (identical(other.templateId, templateId) ||
                other.templateId == templateId) &&
            (identical(other.eventId, eventId) || other.eventId == eventId));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode =>
      Object.hash(runtimeType, communityId, templateId, eventId);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ScaleTestImplCopyWith<_$ScaleTestImpl> get copyWith =>
      __$$ScaleTestImplCopyWithImpl<_$ScaleTestImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ScaleTestImplToJson(
      this,
    );
  }
}

abstract class _ScaleTest implements ScaleTest {
  factory _ScaleTest(
      {required final String communityId,
      required final String templateId,
      required final String eventId}) = _$ScaleTestImpl;

  factory _ScaleTest.fromJson(Map<String, dynamic> json) =
      _$ScaleTestImpl.fromJson;

  @override
  String get communityId;
  @override
  String get templateId;
  @override
  String get eventId;
  @override
  @JsonKey(ignore: true)
  _$$ScaleTestImplCopyWith<_$ScaleTestImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
