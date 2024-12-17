// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'link_preview_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

LinkPreviewResponse _$LinkPreviewResponseFromJson(Map<String, dynamic> json) {
  return _LinkPreviewResponse.fromJson(json);
}

/// @nodoc
mixin _$LinkPreviewResponse {
  String? get title => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  String? get image => throw _privateConstructorUsedError;
  String? get url => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $LinkPreviewResponseCopyWith<LinkPreviewResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LinkPreviewResponseCopyWith<$Res> {
  factory $LinkPreviewResponseCopyWith(
          LinkPreviewResponse value, $Res Function(LinkPreviewResponse) then) =
      _$LinkPreviewResponseCopyWithImpl<$Res, LinkPreviewResponse>;
  @useResult
  $Res call({String? title, String? description, String? image, String? url});
}

/// @nodoc
class _$LinkPreviewResponseCopyWithImpl<$Res, $Val extends LinkPreviewResponse>
    implements $LinkPreviewResponseCopyWith<$Res> {
  _$LinkPreviewResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? title = freezed,
    Object? description = freezed,
    Object? image = freezed,
    Object? url = freezed,
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
      image: freezed == image
          ? _value.image
          : image // ignore: cast_nullable_to_non_nullable
              as String?,
      url: freezed == url
          ? _value.url
          : url // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_LinkPreviewResponseCopyWith<$Res>
    implements $LinkPreviewResponseCopyWith<$Res> {
  factory _$$_LinkPreviewResponseCopyWith(_$_LinkPreviewResponse value,
          $Res Function(_$_LinkPreviewResponse) then) =
      __$$_LinkPreviewResponseCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String? title, String? description, String? image, String? url});
}

/// @nodoc
class __$$_LinkPreviewResponseCopyWithImpl<$Res>
    extends _$LinkPreviewResponseCopyWithImpl<$Res, _$_LinkPreviewResponse>
    implements _$$_LinkPreviewResponseCopyWith<$Res> {
  __$$_LinkPreviewResponseCopyWithImpl(_$_LinkPreviewResponse _value,
      $Res Function(_$_LinkPreviewResponse) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? title = freezed,
    Object? description = freezed,
    Object? image = freezed,
    Object? url = freezed,
  }) {
    return _then(_$_LinkPreviewResponse(
      title: freezed == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String?,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      image: freezed == image
          ? _value.image
          : image // ignore: cast_nullable_to_non_nullable
              as String?,
      url: freezed == url
          ? _value.url
          : url // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_LinkPreviewResponse implements _LinkPreviewResponse {
  _$_LinkPreviewResponse({this.title, this.description, this.image, this.url});

  factory _$_LinkPreviewResponse.fromJson(Map<String, dynamic> json) =>
      _$$_LinkPreviewResponseFromJson(json);

  @override
  final String? title;
  @override
  final String? description;
  @override
  final String? image;
  @override
  final String? url;

  @override
  String toString() {
    return 'LinkPreviewResponse(title: $title, description: $description, image: $image, url: $url)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_LinkPreviewResponse &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.image, image) || other.image == image) &&
            (identical(other.url, url) || other.url == url));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, title, description, image, url);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_LinkPreviewResponseCopyWith<_$_LinkPreviewResponse> get copyWith =>
      __$$_LinkPreviewResponseCopyWithImpl<_$_LinkPreviewResponse>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_LinkPreviewResponseToJson(
      this,
    );
  }
}

abstract class _LinkPreviewResponse implements LinkPreviewResponse {
  factory _LinkPreviewResponse(
      {final String? title,
      final String? description,
      final String? image,
      final String? url}) = _$_LinkPreviewResponse;

  factory _LinkPreviewResponse.fromJson(Map<String, dynamic> json) =
      _$_LinkPreviewResponse.fromJson;

  @override
  String? get title;
  @override
  String? get description;
  @override
  String? get image;
  @override
  String? get url;
  @override
  @JsonKey(ignore: true)
  _$$_LinkPreviewResponseCopyWith<_$_LinkPreviewResponse> get copyWith =>
      throw _privateConstructorUsedError;
}
