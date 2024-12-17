// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'pre_post_card_attribute.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

PrePostCardAttribute _$PrePostCardAttributeFromJson(Map<String, dynamic> json) {
  return _PrePostCardAttribute.fromJson(json);
}

/// @nodoc
mixin _$PrePostCardAttribute {
  PrePostCardAttributeType get type => throw _privateConstructorUsedError;
  String get queryParam => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $PrePostCardAttributeCopyWith<PrePostCardAttribute> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PrePostCardAttributeCopyWith<$Res> {
  factory $PrePostCardAttributeCopyWith(PrePostCardAttribute value,
          $Res Function(PrePostCardAttribute) then) =
      _$PrePostCardAttributeCopyWithImpl<$Res, PrePostCardAttribute>;
  @useResult
  $Res call({PrePostCardAttributeType type, String queryParam});
}

/// @nodoc
class _$PrePostCardAttributeCopyWithImpl<$Res,
        $Val extends PrePostCardAttribute>
    implements $PrePostCardAttributeCopyWith<$Res> {
  _$PrePostCardAttributeCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? type = null,
    Object? queryParam = null,
  }) {
    return _then(_value.copyWith(
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as PrePostCardAttributeType,
      queryParam: null == queryParam
          ? _value.queryParam
          : queryParam // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_PrePostCardAttributeCopyWith<$Res>
    implements $PrePostCardAttributeCopyWith<$Res> {
  factory _$$_PrePostCardAttributeCopyWith(_$_PrePostCardAttribute value,
          $Res Function(_$_PrePostCardAttribute) then) =
      __$$_PrePostCardAttributeCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({PrePostCardAttributeType type, String queryParam});
}

/// @nodoc
class __$$_PrePostCardAttributeCopyWithImpl<$Res>
    extends _$PrePostCardAttributeCopyWithImpl<$Res, _$_PrePostCardAttribute>
    implements _$$_PrePostCardAttributeCopyWith<$Res> {
  __$$_PrePostCardAttributeCopyWithImpl(_$_PrePostCardAttribute _value,
      $Res Function(_$_PrePostCardAttribute) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? type = null,
    Object? queryParam = null,
  }) {
    return _then(_$_PrePostCardAttribute(
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as PrePostCardAttributeType,
      queryParam: null == queryParam
          ? _value.queryParam
          : queryParam // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_PrePostCardAttribute extends _PrePostCardAttribute {
  _$_PrePostCardAttribute({required this.type, required this.queryParam})
      : super._();

  factory _$_PrePostCardAttribute.fromJson(Map<String, dynamic> json) =>
      _$$_PrePostCardAttributeFromJson(json);

  @override
  final PrePostCardAttributeType type;
  @override
  final String queryParam;

  @override
  String toString() {
    return 'PrePostCardAttribute(type: $type, queryParam: $queryParam)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_PrePostCardAttribute &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.queryParam, queryParam) ||
                other.queryParam == queryParam));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, type, queryParam);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_PrePostCardAttributeCopyWith<_$_PrePostCardAttribute> get copyWith =>
      __$$_PrePostCardAttributeCopyWithImpl<_$_PrePostCardAttribute>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_PrePostCardAttributeToJson(
      this,
    );
  }
}

abstract class _PrePostCardAttribute extends PrePostCardAttribute {
  factory _PrePostCardAttribute(
      {required final PrePostCardAttributeType type,
      required final String queryParam}) = _$_PrePostCardAttribute;
  _PrePostCardAttribute._() : super._();

  factory _PrePostCardAttribute.fromJson(Map<String, dynamic> json) =
      _$_PrePostCardAttribute.fromJson;

  @override
  PrePostCardAttributeType get type;
  @override
  String get queryParam;
  @override
  @JsonKey(ignore: true)
  _$$_PrePostCardAttributeCopyWith<_$_PrePostCardAttribute> get copyWith =>
      throw _privateConstructorUsedError;
}
