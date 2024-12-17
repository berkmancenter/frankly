// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'community_tag.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

CommunityTag _$CommunityTagFromJson(Map<String, dynamic> json) {
  return _CommunityTag.fromJson(json);
}

/// @nodoc
mixin _$CommunityTag {
  @JsonKey(unknownEnumValue: null)
  TaggedItemType? get taggedItemType => throw _privateConstructorUsedError;
  String get definitionId => throw _privateConstructorUsedError;
  String? get communityId => throw _privateConstructorUsedError;
  String get taggedItemId => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $CommunityTagCopyWith<CommunityTag> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CommunityTagCopyWith<$Res> {
  factory $CommunityTagCopyWith(
          CommunityTag value, $Res Function(CommunityTag) then) =
      _$CommunityTagCopyWithImpl<$Res, CommunityTag>;
  @useResult
  $Res call(
      {@JsonKey(unknownEnumValue: null) TaggedItemType? taggedItemType,
      String definitionId,
      String? communityId,
      String taggedItemId});
}

/// @nodoc
class _$CommunityTagCopyWithImpl<$Res, $Val extends CommunityTag>
    implements $CommunityTagCopyWith<$Res> {
  _$CommunityTagCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? taggedItemType = freezed,
    Object? definitionId = null,
    Object? communityId = freezed,
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
      communityId: freezed == communityId
          ? _value.communityId
          : communityId // ignore: cast_nullable_to_non_nullable
              as String?,
      taggedItemId: null == taggedItemId
          ? _value.taggedItemId
          : taggedItemId // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_CommunityTagCopyWith<$Res>
    implements $CommunityTagCopyWith<$Res> {
  factory _$$_CommunityTagCopyWith(
          _$_CommunityTag value, $Res Function(_$_CommunityTag) then) =
      __$$_CommunityTagCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(unknownEnumValue: null) TaggedItemType? taggedItemType,
      String definitionId,
      String? communityId,
      String taggedItemId});
}

/// @nodoc
class __$$_CommunityTagCopyWithImpl<$Res>
    extends _$CommunityTagCopyWithImpl<$Res, _$_CommunityTag>
    implements _$$_CommunityTagCopyWith<$Res> {
  __$$_CommunityTagCopyWithImpl(
      _$_CommunityTag _value, $Res Function(_$_CommunityTag) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? taggedItemType = freezed,
    Object? definitionId = null,
    Object? communityId = freezed,
    Object? taggedItemId = null,
  }) {
    return _then(_$_CommunityTag(
      taggedItemType: freezed == taggedItemType
          ? _value.taggedItemType
          : taggedItemType // ignore: cast_nullable_to_non_nullable
              as TaggedItemType?,
      definitionId: null == definitionId
          ? _value.definitionId
          : definitionId // ignore: cast_nullable_to_non_nullable
              as String,
      communityId: freezed == communityId
          ? _value.communityId
          : communityId // ignore: cast_nullable_to_non_nullable
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
class _$_CommunityTag implements _CommunityTag {
  _$_CommunityTag(
      {@JsonKey(unknownEnumValue: null) required this.taggedItemType,
      required this.definitionId,
      this.communityId,
      required this.taggedItemId});

  factory _$_CommunityTag.fromJson(Map<String, dynamic> json) =>
      _$$_CommunityTagFromJson(json);

  @override
  @JsonKey(unknownEnumValue: null)
  final TaggedItemType? taggedItemType;
  @override
  final String definitionId;
  @override
  final String? communityId;
  @override
  final String taggedItemId;

  @override
  String toString() {
    return 'CommunityTag(taggedItemType: $taggedItemType, definitionId: $definitionId, communityId: $communityId, taggedItemId: $taggedItemId)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_CommunityTag &&
            (identical(other.taggedItemType, taggedItemType) ||
                other.taggedItemType == taggedItemType) &&
            (identical(other.definitionId, definitionId) ||
                other.definitionId == definitionId) &&
            (identical(other.communityId, communityId) ||
                other.communityId == communityId) &&
            (identical(other.taggedItemId, taggedItemId) ||
                other.taggedItemId == taggedItemId));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType, taggedItemType, definitionId, communityId, taggedItemId);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_CommunityTagCopyWith<_$_CommunityTag> get copyWith =>
      __$$_CommunityTagCopyWithImpl<_$_CommunityTag>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_CommunityTagToJson(
      this,
    );
  }
}

abstract class _CommunityTag implements CommunityTag {
  factory _CommunityTag(
      {@JsonKey(unknownEnumValue: null)
      required final TaggedItemType? taggedItemType,
      required final String definitionId,
      final String? communityId,
      required final String taggedItemId}) = _$_CommunityTag;

  factory _CommunityTag.fromJson(Map<String, dynamic> json) =
      _$_CommunityTag.fromJson;

  @override
  @JsonKey(unknownEnumValue: null)
  TaggedItemType? get taggedItemType;
  @override
  String get definitionId;
  @override
  String? get communityId;
  @override
  String get taggedItemId;
  @override
  @JsonKey(ignore: true)
  _$$_CommunityTagCopyWith<_$_CommunityTag> get copyWith =>
      throw _privateConstructorUsedError;
}
