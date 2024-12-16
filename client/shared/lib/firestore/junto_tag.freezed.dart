// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'junto_tag.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

JuntoTag _$JuntoTagFromJson(Map<String, dynamic> json) {
  return _JuntoTag.fromJson(json);
}

/// @nodoc
mixin _$JuntoTag {
  @JsonKey(unknownEnumValue: null)
  TaggedItemType? get taggedItemType => throw _privateConstructorUsedError;
  String get definitionId => throw _privateConstructorUsedError;
  String? get juntoId => throw _privateConstructorUsedError;
  String get taggedItemId => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $JuntoTagCopyWith<JuntoTag> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $JuntoTagCopyWith<$Res> {
  factory $JuntoTagCopyWith(JuntoTag value, $Res Function(JuntoTag) then) =
      _$JuntoTagCopyWithImpl<$Res, JuntoTag>;
  @useResult
  $Res call(
      {@JsonKey(unknownEnumValue: null) TaggedItemType? taggedItemType,
      String definitionId,
      String? juntoId,
      String taggedItemId});
}

/// @nodoc
class _$JuntoTagCopyWithImpl<$Res, $Val extends JuntoTag>
    implements $JuntoTagCopyWith<$Res> {
  _$JuntoTagCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? taggedItemType = freezed,
    Object? definitionId = null,
    Object? juntoId = freezed,
    Object? taggedItemId = null,
  }) {
    return _then(_value.copyWith(
      taggedItemType: freezed == taggedItemType
          ? _value.taggedItemType
          : taggedItemType // ignore: cast_nullable_to_non_nullable
              as TaggedItemType?,
      definitionId: null == definitionId
          ? _value.definitionId
          : definitionId // ignore: cast_nullable_to_non_nullable
              as String,
      juntoId: freezed == juntoId
          ? _value.juntoId
          : juntoId // ignore: cast_nullable_to_non_nullable
              as String?,
      taggedItemId: null == taggedItemId
          ? _value.taggedItemId
          : taggedItemId // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_JuntoTagCopyWith<$Res> implements $JuntoTagCopyWith<$Res> {
  factory _$$_JuntoTagCopyWith(
          _$_JuntoTag value, $Res Function(_$_JuntoTag) then) =
      __$$_JuntoTagCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(unknownEnumValue: null) TaggedItemType? taggedItemType,
      String definitionId,
      String? juntoId,
      String taggedItemId});
}

/// @nodoc
class __$$_JuntoTagCopyWithImpl<$Res>
    extends _$JuntoTagCopyWithImpl<$Res, _$_JuntoTag>
    implements _$$_JuntoTagCopyWith<$Res> {
  __$$_JuntoTagCopyWithImpl(
      _$_JuntoTag _value, $Res Function(_$_JuntoTag) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? taggedItemType = freezed,
    Object? definitionId = null,
    Object? juntoId = freezed,
    Object? taggedItemId = null,
  }) {
    return _then(_$_JuntoTag(
      taggedItemType: freezed == taggedItemType
          ? _value.taggedItemType
          : taggedItemType // ignore: cast_nullable_to_non_nullable
              as TaggedItemType?,
      definitionId: null == definitionId
          ? _value.definitionId
          : definitionId // ignore: cast_nullable_to_non_nullable
              as String,
      juntoId: freezed == juntoId
          ? _value.juntoId
          : juntoId // ignore: cast_nullable_to_non_nullable
              as String?,
      taggedItemId: null == taggedItemId
          ? _value.taggedItemId
          : taggedItemId // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_JuntoTag implements _JuntoTag {
  _$_JuntoTag(
      {@JsonKey(unknownEnumValue: null) required this.taggedItemType,
      required this.definitionId,
      this.juntoId,
      required this.taggedItemId});

  factory _$_JuntoTag.fromJson(Map<String, dynamic> json) =>
      _$$_JuntoTagFromJson(json);

  @override
  @JsonKey(unknownEnumValue: null)
  final TaggedItemType? taggedItemType;
  @override
  final String definitionId;
  @override
  final String? juntoId;
  @override
  final String taggedItemId;

  @override
  String toString() {
    return 'JuntoTag(taggedItemType: $taggedItemType, definitionId: $definitionId, juntoId: $juntoId, taggedItemId: $taggedItemId)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_JuntoTag &&
            (identical(other.taggedItemType, taggedItemType) ||
                other.taggedItemType == taggedItemType) &&
            (identical(other.definitionId, definitionId) ||
                other.definitionId == definitionId) &&
            (identical(other.juntoId, juntoId) || other.juntoId == juntoId) &&
            (identical(other.taggedItemId, taggedItemId) ||
                other.taggedItemId == taggedItemId));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType, taggedItemType, definitionId, juntoId, taggedItemId);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_JuntoTagCopyWith<_$_JuntoTag> get copyWith =>
      __$$_JuntoTagCopyWithImpl<_$_JuntoTag>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_JuntoTagToJson(
      this,
    );
  }
}

abstract class _JuntoTag implements JuntoTag {
  factory _JuntoTag(
      {@JsonKey(unknownEnumValue: null)
      required final TaggedItemType? taggedItemType,
      required final String definitionId,
      final String? juntoId,
      required final String taggedItemId}) = _$_JuntoTag;

  factory _JuntoTag.fromJson(Map<String, dynamic> json) = _$_JuntoTag.fromJson;

  @override
  @JsonKey(unknownEnumValue: null)
  TaggedItemType? get taggedItemType;
  @override
  String get definitionId;
  @override
  String? get juntoId;
  @override
  String get taggedItemId;
  @override
  @JsonKey(ignore: true)
  _$$_JuntoTagCopyWith<_$_JuntoTag> get copyWith =>
      throw _privateConstructorUsedError;
}
