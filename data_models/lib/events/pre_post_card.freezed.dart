// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'pre_post_card.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

PrePostCard _$PrePostCardFromJson(Map<String, dynamic> json) {
  return _PrePostCard.fromJson(json);
}

/// @nodoc
mixin _$PrePostCard {
  String get headline => throw _privateConstructorUsedError;
  String get message => throw _privateConstructorUsedError;
  PrePostCardType get type => throw _privateConstructorUsedError;
  List<PrePostUrlParams> get prePostUrls => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $PrePostCardCopyWith<PrePostCard> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PrePostCardCopyWith<$Res> {
  factory $PrePostCardCopyWith(
          PrePostCard value, $Res Function(PrePostCard) then) =
      _$PrePostCardCopyWithImpl<$Res, PrePostCard>;
  @useResult
  $Res call(
      {String headline,
      String message,
      PrePostCardType type,
      List<PrePostUrlParams> prePostUrls});
}

/// @nodoc
class _$PrePostCardCopyWithImpl<$Res, $Val extends PrePostCard>
    implements $PrePostCardCopyWith<$Res> {
  _$PrePostCardCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? headline = null,
    Object? message = null,
    Object? type = null,
    Object? prePostUrls = null,
  }) {
    return _then(_value.copyWith(
      headline: null == headline
          ? _value.headline
          : headline // ignore: cast_nullable_to_non_nullable
              as String,
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as PrePostCardType,
      prePostUrls: null == prePostUrls
          ? _value.prePostUrls
          : prePostUrls // ignore: cast_nullable_to_non_nullable
              as List<PrePostUrlParams>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_PrePostCardCopyWith<$Res>
    implements $PrePostCardCopyWith<$Res> {
  factory _$$_PrePostCardCopyWith(
          _$_PrePostCard value, $Res Function(_$_PrePostCard) then) =
      __$$_PrePostCardCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String headline,
      String message,
      PrePostCardType type,
      List<PrePostUrlParams> prePostUrls});
}

/// @nodoc
class __$$_PrePostCardCopyWithImpl<$Res>
    extends _$PrePostCardCopyWithImpl<$Res, _$_PrePostCard>
    implements _$$_PrePostCardCopyWith<$Res> {
  __$$_PrePostCardCopyWithImpl(
      _$_PrePostCard _value, $Res Function(_$_PrePostCard) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? headline = null,
    Object? message = null,
    Object? type = null,
    Object? prePostUrls = null,
  }) {
    return _then(_$_PrePostCard(
      headline: null == headline
          ? _value.headline
          : headline // ignore: cast_nullable_to_non_nullable
              as String,
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as PrePostCardType,
      prePostUrls: null == prePostUrls
          ? _value.prePostUrls
          : prePostUrls // ignore: cast_nullable_to_non_nullable
              as List<PrePostUrlParams>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_PrePostCard extends _PrePostCard {
  _$_PrePostCard(
      {required this.headline,
      required this.message,
      required this.type,
      this.prePostUrls = const []})
      : super._();

  factory _$_PrePostCard.fromJson(Map<String, dynamic> json) =>
      _$$_PrePostCardFromJson(json);

  @override
  final String headline;
  @override
  final String message;
  @override
  final PrePostCardType type;
  @override
  @JsonKey()
  final List<PrePostUrlParams> prePostUrls;

  @override
  String toString() {
    return 'PrePostCard(headline: $headline, message: $message, type: $type, prePostUrls: $prePostUrls)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_PrePostCard &&
            (identical(other.headline, headline) ||
                other.headline == headline) &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.type, type) || other.type == type) &&
            const DeepCollectionEquality()
                .equals(other.prePostUrls, prePostUrls));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, headline, message, type,
      const DeepCollectionEquality().hash(prePostUrls));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_PrePostCardCopyWith<_$_PrePostCard> get copyWith =>
      __$$_PrePostCardCopyWithImpl<_$_PrePostCard>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_PrePostCardToJson(
      this,
    );
  }
}

abstract class _PrePostCard extends PrePostCard {
  factory _PrePostCard(
      {required final String headline,
      required final String message,
      required final PrePostCardType type,
      final List<PrePostUrlParams> prePostUrls}) = _$_PrePostCard;
  _PrePostCard._() : super._();

  factory _PrePostCard.fromJson(Map<String, dynamic> json) =
      _$_PrePostCard.fromJson;

  @override
  String get headline;
  @override
  String get message;
  @override
  PrePostCardType get type;
  @override
  List<PrePostUrlParams> get prePostUrls;
  @override
  @JsonKey(ignore: true)
  _$$_PrePostCardCopyWith<_$_PrePostCard> get copyWith =>
      throw _privateConstructorUsedError;
}
