// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'junto_resource.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

JuntoResource _$JuntoResourceFromJson(Map<String, dynamic> json) {
  return _JuntoResource.fromJson(json);
}

/// @nodoc
mixin _$JuntoResource {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(fromJson: dateTimeFromTimestamp, toJson: serverTimestamp)
  DateTime? get createdDate => throw _privateConstructorUsedError;
  String? get title => throw _privateConstructorUsedError;
  String? get url => throw _privateConstructorUsedError;
  String? get image => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $JuntoResourceCopyWith<JuntoResource> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $JuntoResourceCopyWith<$Res> {
  factory $JuntoResourceCopyWith(
          JuntoResource value, $Res Function(JuntoResource) then) =
      _$JuntoResourceCopyWithImpl<$Res, JuntoResource>;
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
class _$JuntoResourceCopyWithImpl<$Res, $Val extends JuntoResource>
    implements $JuntoResourceCopyWith<$Res> {
  _$JuntoResourceCopyWithImpl(this._value, this._then);

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
abstract class _$$_JuntoResourceCopyWith<$Res>
    implements $JuntoResourceCopyWith<$Res> {
  factory _$$_JuntoResourceCopyWith(
          _$_JuntoResource value, $Res Function(_$_JuntoResource) then) =
      __$$_JuntoResourceCopyWithImpl<$Res>;
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
class __$$_JuntoResourceCopyWithImpl<$Res>
    extends _$JuntoResourceCopyWithImpl<$Res, _$_JuntoResource>
    implements _$$_JuntoResourceCopyWith<$Res> {
  __$$_JuntoResourceCopyWithImpl(
      _$_JuntoResource _value, $Res Function(_$_JuntoResource) _then)
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
    return _then(_$_JuntoResource(
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
class _$_JuntoResource implements _JuntoResource {
  _$_JuntoResource(
      {required this.id,
      @JsonKey(fromJson: dateTimeFromTimestamp, toJson: serverTimestamp)
      this.createdDate,
      this.title,
      this.url,
      this.image});

  factory _$_JuntoResource.fromJson(Map<String, dynamic> json) =>
      _$$_JuntoResourceFromJson(json);

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
    return 'JuntoResource(id: $id, createdDate: $createdDate, title: $title, url: $url, image: $image)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_JuntoResource &&
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
  _$$_JuntoResourceCopyWith<_$_JuntoResource> get copyWith =>
      __$$_JuntoResourceCopyWithImpl<_$_JuntoResource>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_JuntoResourceToJson(
      this,
    );
  }
}

abstract class _JuntoResource implements JuntoResource {
  factory _JuntoResource(
      {required final String id,
      @JsonKey(fromJson: dateTimeFromTimestamp, toJson: serverTimestamp)
      final DateTime? createdDate,
      final String? title,
      final String? url,
      final String? image}) = _$_JuntoResource;

  factory _JuntoResource.fromJson(Map<String, dynamic> json) =
      _$_JuntoResource.fromJson;

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
  _$$_JuntoResourceCopyWith<_$_JuntoResource> get copyWith =>
      throw _privateConstructorUsedError;
}
