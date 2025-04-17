// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'pre_post_url_params.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

PrePostUrlParams _$PrePostUrlParamsFromJson(Map<String, dynamic> json) {
  return _PrePostUrlParams.fromJson(json);
}

/// @nodoc
mixin _$PrePostUrlParams {
  String? get buttonText => throw _privateConstructorUsedError;
  String? get surveyUrl => throw _privateConstructorUsedError;
  List<PrePostCardAttribute> get attributes =>
      throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $PrePostUrlParamsCopyWith<PrePostUrlParams> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PrePostUrlParamsCopyWith<$Res> {
  factory $PrePostUrlParamsCopyWith(
          PrePostUrlParams value, $Res Function(PrePostUrlParams) then) =
      _$PrePostUrlParamsCopyWithImpl<$Res, PrePostUrlParams>;
  @useResult
  $Res call(
      {String? buttonText,
      String? surveyUrl,
      List<PrePostCardAttribute> attributes});
}

/// @nodoc
class _$PrePostUrlParamsCopyWithImpl<$Res, $Val extends PrePostUrlParams>
    implements $PrePostUrlParamsCopyWith<$Res> {
  _$PrePostUrlParamsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? buttonText = freezed,
    Object? surveyUrl = freezed,
    Object? attributes = null,
  }) {
    return _then(_value.copyWith(
      buttonText: freezed == buttonText
          ? _value.buttonText
          : buttonText // ignore: cast_nullable_to_non_nullable
              as String?,
      surveyUrl: freezed == surveyUrl
          ? _value.surveyUrl
          : surveyUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      attributes: null == attributes
          ? _value.attributes
          : attributes // ignore: cast_nullable_to_non_nullable
              as List<PrePostCardAttribute>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_PrePostUrlParamsCopyWith<$Res>
    implements $PrePostUrlParamsCopyWith<$Res> {
  factory _$$_PrePostUrlParamsCopyWith(
          _$_PrePostUrlParams value, $Res Function(_$_PrePostUrlParams) then) =
      __$$_PrePostUrlParamsCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String? buttonText,
      String? surveyUrl,
      List<PrePostCardAttribute> attributes});
}

/// @nodoc
class __$$_PrePostUrlParamsCopyWithImpl<$Res>
    extends _$PrePostUrlParamsCopyWithImpl<$Res, _$_PrePostUrlParams>
    implements _$$_PrePostUrlParamsCopyWith<$Res> {
  __$$_PrePostUrlParamsCopyWithImpl(
      _$_PrePostUrlParams _value, $Res Function(_$_PrePostUrlParams) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? buttonText = freezed,
    Object? surveyUrl = freezed,
    Object? attributes = null,
  }) {
    return _then(_$_PrePostUrlParams(
      buttonText: freezed == buttonText
          ? _value.buttonText
          : buttonText // ignore: cast_nullable_to_non_nullable
              as String?,
      surveyUrl: freezed == surveyUrl
          ? _value.surveyUrl
          : surveyUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      attributes: null == attributes
          ? _value.attributes
          : attributes // ignore: cast_nullable_to_non_nullable
              as List<PrePostCardAttribute>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_PrePostUrlParams extends _PrePostUrlParams {
  _$_PrePostUrlParams(
      {this.buttonText, this.surveyUrl, this.attributes = const []})
      : super._();

  factory _$_PrePostUrlParams.fromJson(Map<String, dynamic> json) =>
      _$$_PrePostUrlParamsFromJson(json);

  @override
  final String? buttonText;
  @override
  final String? surveyUrl;
  @override
  @JsonKey()
  final List<PrePostCardAttribute> attributes;

  @override
  String toString() {
    return 'PrePostUrlParams(buttonText: $buttonText, surveyUrl: $surveyUrl, attributes: $attributes)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_PrePostUrlParams &&
            (identical(other.buttonText, buttonText) ||
                other.buttonText == buttonText) &&
            (identical(other.surveyUrl, surveyUrl) ||
                other.surveyUrl == surveyUrl) &&
            const DeepCollectionEquality()
                .equals(other.attributes, attributes));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, buttonText, surveyUrl,
      const DeepCollectionEquality().hash(attributes));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_PrePostUrlParamsCopyWith<_$_PrePostUrlParams> get copyWith =>
      __$$_PrePostUrlParamsCopyWithImpl<_$_PrePostUrlParams>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_PrePostUrlParamsToJson(
      this,
    );
  }
}

abstract class _PrePostUrlParams extends PrePostUrlParams {
  factory _PrePostUrlParams(
      {final String? buttonText,
      final String? surveyUrl,
      final List<PrePostCardAttribute> attributes}) = _$_PrePostUrlParams;
  _PrePostUrlParams._() : super._();

  factory _PrePostUrlParams.fromJson(Map<String, dynamic> json) =
      _$_PrePostUrlParams.fromJson;

  @override
  String? get buttonText;
  @override
  String? get surveyUrl;
  @override
  List<PrePostCardAttribute> get attributes;
  @override
  @JsonKey(ignore: true)
  _$$_PrePostUrlParamsCopyWith<_$_PrePostUrlParams> get copyWith =>
      throw _privateConstructorUsedError;
}
