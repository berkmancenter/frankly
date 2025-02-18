// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'media_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

MediaItem _$MediaItemFromJson(Map<String, dynamic> json) {
  return _MediaItem.fromJson(json);
}

/// @nodoc
mixin _$MediaItem {
  String get url => throw _privateConstructorUsedError;
  MediaType get type => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $MediaItemCopyWith<MediaItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MediaItemCopyWith<$Res> {
  factory $MediaItemCopyWith(MediaItem value, $Res Function(MediaItem) then) =
      _$MediaItemCopyWithImpl<$Res, MediaItem>;
  @useResult
  $Res call({String url, MediaType type});
}

/// @nodoc
class _$MediaItemCopyWithImpl<$Res, $Val extends MediaItem>
    implements $MediaItemCopyWith<$Res> {
  _$MediaItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? url = null,
    Object? type = null,
  }) {
    return _then(_value.copyWith(
      url: null == url
          ? _value.url
          : url // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as MediaType,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_MediaItemCopyWith<$Res> implements $MediaItemCopyWith<$Res> {
  factory _$$_MediaItemCopyWith(
          _$_MediaItem value, $Res Function(_$_MediaItem) then) =
      __$$_MediaItemCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String url, MediaType type});
}

/// @nodoc
class __$$_MediaItemCopyWithImpl<$Res>
    extends _$MediaItemCopyWithImpl<$Res, _$_MediaItem>
    implements _$$_MediaItemCopyWith<$Res> {
  __$$_MediaItemCopyWithImpl(
      _$_MediaItem _value, $Res Function(_$_MediaItem) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? url = null,
    Object? type = null,
  }) {
    return _then(_$_MediaItem(
      url: null == url
          ? _value.url
          : url // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as MediaType,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_MediaItem extends _MediaItem {
  _$_MediaItem({required this.url, required this.type}) : super._();

  factory _$_MediaItem.fromJson(Map<String, dynamic> json) =>
      _$$_MediaItemFromJson(json);

  @override
  final String url;
  @override
  final MediaType type;

  @override
  String toString() {
    return 'MediaItem(url: $url, type: $type)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_MediaItem &&
            (identical(other.url, url) || other.url == url) &&
            (identical(other.type, type) || other.type == type));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, url, type);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_MediaItemCopyWith<_$_MediaItem> get copyWith =>
      __$$_MediaItemCopyWithImpl<_$_MediaItem>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_MediaItemToJson(
      this,
    );
  }
}

abstract class _MediaItem extends MediaItem {
  factory _MediaItem(
      {required final String url,
      required final MediaType type}) = _$_MediaItem;
  _MediaItem._() : super._();

  factory _MediaItem.fromJson(Map<String, dynamic> json) =
      _$_MediaItem.fromJson;

  @override
  String get url;
  @override
  MediaType get type;
  @override
  @JsonKey(ignore: true)
  _$$_MediaItemCopyWith<_$_MediaItem> get copyWith =>
      throw _privateConstructorUsedError;
}
