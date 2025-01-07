// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'community_resource.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

CommunityResource _$CommunityResourceFromJson(Map<String, dynamic> json) {
  return _CommunityResource.fromJson(json);
}

/// @nodoc
mixin _$CommunityResource {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(fromJson: dateTimeFromTimestamp, toJson: serverTimestamp)
  DateTime? get createdDate => throw _privateConstructorUsedError;
  String? get title => throw _privateConstructorUsedError;
  String? get url => throw _privateConstructorUsedError;
  String? get image => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $CommunityResourceCopyWith<CommunityResource> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CommunityResourceCopyWith<$Res> {
  factory $CommunityResourceCopyWith(
          CommunityResource value, $Res Function(CommunityResource) then) =
      _$CommunityResourceCopyWithImpl<$Res, CommunityResource>;
  @useResult
  $Res call(
      {String id,
      @JsonKey(fromJson: dateTimeFromTimestamp, toJson: serverTimestamp)
      DateTime? createdDate,
      String? title,
      String? url,
      String? image});
}

/// @nodoc
class _$CommunityResourceCopyWithImpl<$Res, $Val extends CommunityResource>
    implements $CommunityResourceCopyWith<$Res> {
  _$CommunityResourceCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? createdDate = freezed,
    Object? title = freezed,
    Object? url = freezed,
    Object? image = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      createdDate: freezed == createdDate
          ? _value.createdDate
          : createdDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      title: freezed == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String?,
      url: freezed == url
          ? _value.url
          : url // ignore: cast_nullable_to_non_nullable
              as String?,
      image: freezed == image
          ? _value.image
          : image // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_CommunityResourceCopyWith<$Res>
    implements $CommunityResourceCopyWith<$Res> {
  factory _$$_CommunityResourceCopyWith(_$_CommunityResource value,
          $Res Function(_$_CommunityResource) then) =
      __$$_CommunityResourceCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      @JsonKey(fromJson: dateTimeFromTimestamp, toJson: serverTimestamp)
      DateTime? createdDate,
      String? title,
      String? url,
      String? image});
}

/// @nodoc
class __$$_CommunityResourceCopyWithImpl<$Res>
    extends _$CommunityResourceCopyWithImpl<$Res, _$_CommunityResource>
    implements _$$_CommunityResourceCopyWith<$Res> {
  __$$_CommunityResourceCopyWithImpl(
      _$_CommunityResource _value, $Res Function(_$_CommunityResource) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? createdDate = freezed,
    Object? title = freezed,
    Object? url = freezed,
    Object? image = freezed,
  }) {
    return _then(_$_CommunityResource(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      createdDate: freezed == createdDate
          ? _value.createdDate
          : createdDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      title: freezed == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String?,
      url: freezed == url
          ? _value.url
          : url // ignore: cast_nullable_to_non_nullable
              as String?,
      image: freezed == image
          ? _value.image
          : image // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_CommunityResource implements _CommunityResource {
  _$_CommunityResource(
      {required this.id,
      @JsonKey(fromJson: dateTimeFromTimestamp, toJson: serverTimestamp)
      this.createdDate,
      this.title,
      this.url,
      this.image});

  factory _$_CommunityResource.fromJson(Map<String, dynamic> json) =>
      _$$_CommunityResourceFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(fromJson: dateTimeFromTimestamp, toJson: serverTimestamp)
  final DateTime? createdDate;
  @override
  final String? title;
  @override
  final String? url;
  @override
  final String? image;

  @override
  String toString() {
    return 'CommunityResource(id: $id, createdDate: $createdDate, title: $title, url: $url, image: $image)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_CommunityResource &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.createdDate, createdDate) ||
                other.createdDate == createdDate) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.url, url) || other.url == url) &&
            (identical(other.image, image) || other.image == image));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, createdDate, title, url, image);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_CommunityResourceCopyWith<_$_CommunityResource> get copyWith =>
      __$$_CommunityResourceCopyWithImpl<_$_CommunityResource>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_CommunityResourceToJson(
      this,
    );
  }
}

abstract class _CommunityResource implements CommunityResource {
  factory _CommunityResource(
      {required final String id,
      @JsonKey(fromJson: dateTimeFromTimestamp, toJson: serverTimestamp)
      final DateTime? createdDate,
      final String? title,
      final String? url,
      final String? image}) = _$_CommunityResource;

  factory _CommunityResource.fromJson(Map<String, dynamic> json) =
      _$_CommunityResource.fromJson;

  @override
  String get id;
  @override
  @JsonKey(fromJson: dateTimeFromTimestamp, toJson: serverTimestamp)
  DateTime? get createdDate;
  @override
  String? get title;
  @override
  String? get url;
  @override
  String? get image;
  @override
  @JsonKey(ignore: true)
  _$$_CommunityResourceCopyWith<_$_CommunityResource> get copyWith =>
      throw _privateConstructorUsedError;
}
