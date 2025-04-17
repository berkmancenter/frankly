// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'platform_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

PlatformItem _$PlatformItemFromJson(Map<String, dynamic> json) {
  return _PlatformItem.fromJson(json);
}

/// @nodoc
mixin _$PlatformItem {
  String? get title => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  String? get logoUrl => throw _privateConstructorUsedError;
  String? get url => throw _privateConstructorUsedError;
  @JsonKey(unknownEnumValue: null)
  PlatformKey? get platformKey => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $PlatformItemCopyWith<PlatformItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PlatformItemCopyWith<$Res> {
  factory $PlatformItemCopyWith(
          PlatformItem value, $Res Function(PlatformItem) then) =
      _$PlatformItemCopyWithImpl<$Res, PlatformItem>;
  @useResult
  $Res call(
      {String? title,
      String? description,
      String? logoUrl,
      String? url,
      @JsonKey(unknownEnumValue: null) PlatformKey? platformKey});
}

/// @nodoc
class _$PlatformItemCopyWithImpl<$Res, $Val extends PlatformItem>
    implements $PlatformItemCopyWith<$Res> {
  _$PlatformItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? title = freezed,
    Object? description = freezed,
    Object? logoUrl = freezed,
    Object? url = freezed,
    Object? platformKey = freezed,
  }) {
    return _then(_value.copyWith(
      title: freezed == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String?,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      logoUrl: freezed == logoUrl
          ? _value.logoUrl
          : logoUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      url: freezed == url
          ? _value.url
          : url // ignore: cast_nullable_to_non_nullable
              as String?,
      platformKey: freezed == platformKey
          ? _value.platformKey
          : platformKey // ignore: cast_nullable_to_non_nullable
              as PlatformKey?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PlatformItemImplCopyWith<$Res>
    implements $PlatformItemCopyWith<$Res> {
  factory _$$PlatformItemImplCopyWith(
          _$PlatformItemImpl value, $Res Function(_$PlatformItemImpl) then) =
      __$$PlatformItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String? title,
      String? description,
      String? logoUrl,
      String? url,
      @JsonKey(unknownEnumValue: null) PlatformKey? platformKey});
}

/// @nodoc
class __$$PlatformItemImplCopyWithImpl<$Res>
    extends _$PlatformItemCopyWithImpl<$Res, _$PlatformItemImpl>
    implements _$$PlatformItemImplCopyWith<$Res> {
  __$$PlatformItemImplCopyWithImpl(
      _$PlatformItemImpl _value, $Res Function(_$PlatformItemImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? title = freezed,
    Object? description = freezed,
    Object? logoUrl = freezed,
    Object? url = freezed,
    Object? platformKey = freezed,
  }) {
    return _then(_$PlatformItemImpl(
      title: freezed == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String?,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      logoUrl: freezed == logoUrl
          ? _value.logoUrl
          : logoUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      url: freezed == url
          ? _value.url
          : url // ignore: cast_nullable_to_non_nullable
              as String?,
      platformKey: freezed == platformKey
          ? _value.platformKey
          : platformKey // ignore: cast_nullable_to_non_nullable
              as PlatformKey?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PlatformItemImpl implements _PlatformItem {
  _$PlatformItemImpl(
      {this.title,
      this.description,
      this.logoUrl,
      this.url,
      @JsonKey(unknownEnumValue: null) this.platformKey});

  factory _$PlatformItemImpl.fromJson(Map<String, dynamic> json) =>
      _$$PlatformItemImplFromJson(json);

  @override
  final String? title;
  @override
  final String? description;
  @override
  final String? logoUrl;
  @override
  final String? url;
  @override
  @JsonKey(unknownEnumValue: null)
  final PlatformKey? platformKey;

  @override
  String toString() {
    return 'PlatformItem(title: $title, description: $description, logoUrl: $logoUrl, url: $url, platformKey: $platformKey)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PlatformItemImpl &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.logoUrl, logoUrl) || other.logoUrl == logoUrl) &&
            (identical(other.url, url) || other.url == url) &&
            (identical(other.platformKey, platformKey) ||
                other.platformKey == platformKey));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode =>
      Object.hash(runtimeType, title, description, logoUrl, url, platformKey);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$PlatformItemImplCopyWith<_$PlatformItemImpl> get copyWith =>
      __$$PlatformItemImplCopyWithImpl<_$PlatformItemImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PlatformItemImplToJson(
      this,
    );
  }
}

abstract class _PlatformItem implements PlatformItem {
  factory _PlatformItem(
          {final String? title,
          final String? description,
          final String? logoUrl,
          final String? url,
          @JsonKey(unknownEnumValue: null) final PlatformKey? platformKey}) =
      _$PlatformItemImpl;

  factory _PlatformItem.fromJson(Map<String, dynamic> json) =
      _$PlatformItemImpl.fromJson;

  @override
  String? get title;
  @override
  String? get description;
  @override
  String? get logoUrl;
  @override
  String? get url;
  @override
  @JsonKey(unknownEnumValue: null)
  PlatformKey? get platformKey;
  @override
  @JsonKey(ignore: true)
  _$$PlatformItemImplCopyWith<_$PlatformItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
