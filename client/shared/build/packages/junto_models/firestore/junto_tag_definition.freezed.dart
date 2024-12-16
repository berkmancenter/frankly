// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'junto_tag_definition.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

JuntoTagDefinition _$JuntoTagDefinitionFromJson(Map<String, dynamic> json) {
  return _JuntoTagDefinition.fromJson(json);
}

/// @nodoc
mixin _$JuntoTagDefinition {
  String get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String? get searchKey => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $JuntoTagDefinitionCopyWith<JuntoTagDefinition> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $JuntoTagDefinitionCopyWith<$Res> {
  factory $JuntoTagDefinitionCopyWith(
          JuntoTagDefinition value, $Res Function(JuntoTagDefinition) then) =
      _$JuntoTagDefinitionCopyWithImpl<$Res, JuntoTagDefinition>;
  @useResult
  $Res call({String id, String title, String? searchKey});
}

/// @nodoc
class _$JuntoTagDefinitionCopyWithImpl<$Res, $Val extends JuntoTagDefinition>
    implements $JuntoTagDefinitionCopyWith<$Res> {
  _$JuntoTagDefinitionCopyWithImpl(this._value, this._then);

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
abstract class _$$_JuntoTagDefinitionCopyWith<$Res>
    implements $JuntoTagDefinitionCopyWith<$Res> {
  factory _$$_JuntoTagDefinitionCopyWith(_$_JuntoTagDefinition value,
          $Res Function(_$_JuntoTagDefinition) then) =
      __$$_JuntoTagDefinitionCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String id, String title, String? searchKey});
}

/// @nodoc
class __$$_JuntoTagDefinitionCopyWithImpl<$Res>
    extends _$JuntoTagDefinitionCopyWithImpl<$Res, _$_JuntoTagDefinition>
    implements _$$_JuntoTagDefinitionCopyWith<$Res> {
  __$$_JuntoTagDefinitionCopyWithImpl(
      _$_JuntoTagDefinition _value, $Res Function(_$_JuntoTagDefinition) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? searchKey = freezed,
  }) {
    return _then(_$_JuntoTagDefinition(
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
class _$_JuntoTagDefinition implements _JuntoTagDefinition {
  _$_JuntoTagDefinition(
      {required this.id, required this.title, this.searchKey});

  factory _$_JuntoTagDefinition.fromJson(Map<String, dynamic> json) =>
      _$$_JuntoTagDefinitionFromJson(json);

  @override
  final String id;
  @override
  final String title;
  @override
  final String? searchKey;

  @override
  String toString() {
    return 'JuntoTagDefinition(id: $id, title: $title, searchKey: $searchKey)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_JuntoTagDefinition &&
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
  _$$_JuntoTagDefinitionCopyWith<_$_JuntoTagDefinition> get copyWith =>
      __$$_JuntoTagDefinitionCopyWithImpl<_$_JuntoTagDefinition>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_JuntoTagDefinitionToJson(
      this,
    );
  }
}

abstract class _JuntoTagDefinition implements JuntoTagDefinition {
  factory _JuntoTagDefinition(
      {required final String id,
      required final String title,
      final String? searchKey}) = _$_JuntoTagDefinition;

  factory _JuntoTagDefinition.fromJson(Map<String, dynamic> json) =
      _$_JuntoTagDefinition.fromJson;

  @override
  String get id;
  @override
  String get title;
  @override
  String? get searchKey;
  @override
  @JsonKey(ignore: true)
  _$$_JuntoTagDefinitionCopyWith<_$_JuntoTagDefinition> get copyWith =>
      throw _privateConstructorUsedError;
}
