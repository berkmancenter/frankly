// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'community_tag_definition.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

CommunityTagDefinition _$CommunityTagDefinitionFromJson(
    Map<String, dynamic> json) {
  return _CommunityTagDefinition.fromJson(json);
}

/// @nodoc
mixin _$CommunityTagDefinition {
  String get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String? get searchKey => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $CommunityTagDefinitionCopyWith<CommunityTagDefinition> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CommunityTagDefinitionCopyWith<$Res> {
  factory $CommunityTagDefinitionCopyWith(CommunityTagDefinition value,
          $Res Function(CommunityTagDefinition) then) =
      _$CommunityTagDefinitionCopyWithImpl<$Res, CommunityTagDefinition>;
  @useResult
  $Res call({String id, String title, String? searchKey});
}

/// @nodoc
class _$CommunityTagDefinitionCopyWithImpl<$Res,
        $Val extends CommunityTagDefinition>
    implements $CommunityTagDefinitionCopyWith<$Res> {
  _$CommunityTagDefinitionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? searchKey = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      searchKey: freezed == searchKey
          ? _value.searchKey
          : searchKey // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_CommunityTagDefinitionCopyWith<$Res>
    implements $CommunityTagDefinitionCopyWith<$Res> {
  factory _$$_CommunityTagDefinitionCopyWith(_$_CommunityTagDefinition value,
          $Res Function(_$_CommunityTagDefinition) then) =
      __$$_CommunityTagDefinitionCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String id, String title, String? searchKey});
}

/// @nodoc
class __$$_CommunityTagDefinitionCopyWithImpl<$Res>
    extends _$CommunityTagDefinitionCopyWithImpl<$Res,
        _$_CommunityTagDefinition>
    implements _$$_CommunityTagDefinitionCopyWith<$Res> {
  __$$_CommunityTagDefinitionCopyWithImpl(_$_CommunityTagDefinition _value,
      $Res Function(_$_CommunityTagDefinition) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? searchKey = freezed,
  }) {
    return _then(_$_CommunityTagDefinition(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      searchKey: freezed == searchKey
          ? _value.searchKey
          : searchKey // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_CommunityTagDefinition implements _CommunityTagDefinition {
  _$_CommunityTagDefinition(
      {required this.id, required this.title, this.searchKey});

  factory _$_CommunityTagDefinition.fromJson(Map<String, dynamic> json) =>
      _$$_CommunityTagDefinitionFromJson(json);

  @override
  final String id;
  @override
  final String title;
  @override
  final String? searchKey;

  @override
  String toString() {
    return 'CommunityTagDefinition(id: $id, title: $title, searchKey: $searchKey)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_CommunityTagDefinition &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.searchKey, searchKey) ||
                other.searchKey == searchKey));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, title, searchKey);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_CommunityTagDefinitionCopyWith<_$_CommunityTagDefinition> get copyWith =>
      __$$_CommunityTagDefinitionCopyWithImpl<_$_CommunityTagDefinition>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_CommunityTagDefinitionToJson(
      this,
    );
  }
}

abstract class _CommunityTagDefinition implements CommunityTagDefinition {
  factory _CommunityTagDefinition(
      {required final String id,
      required final String title,
      final String? searchKey}) = _$_CommunityTagDefinition;

  factory _CommunityTagDefinition.fromJson(Map<String, dynamic> json) =
      _$_CommunityTagDefinition.fromJson;

  @override
  String get id;
  @override
  String get title;
  @override
  String? get searchKey;
  @override
  @JsonKey(ignore: true)
  _$$_CommunityTagDefinitionCopyWith<_$_CommunityTagDefinition> get copyWith =>
      throw _privateConstructorUsedError;
}
