// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'announcement.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

Announcement _$AnnouncementFromJson(Map<String, dynamic> json) {
  return _Announcement.fromJson(json);
}

/// @nodoc
mixin _$Announcement {
  String? get id => throw _privateConstructorUsedError;
  @JsonKey(
      defaultValue: AnnouncementStatus.active,
      unknownEnumValue: AnnouncementStatus.active)
  AnnouncementStatus get announcementStatus =>
      throw _privateConstructorUsedError;
  String? get creatorId => throw _privateConstructorUsedError;
  String? get creatorDisplayName => throw _privateConstructorUsedError;
  @JsonKey(fromJson: dateTimeFromTimestamp, toJson: serverTimestamp)
  DateTime? get createdDate => throw _privateConstructorUsedError;
  String? get title => throw _privateConstructorUsedError;
  String? get message => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $AnnouncementCopyWith<Announcement> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AnnouncementCopyWith<$Res> {
  factory $AnnouncementCopyWith(
          Announcement value, $Res Function(Announcement) then) =
      _$AnnouncementCopyWithImpl<$Res, Announcement>;
  @useResult
  $Res call(
      {String? id,
      @JsonKey(
          defaultValue: AnnouncementStatus.active,
          unknownEnumValue: AnnouncementStatus.active)
      AnnouncementStatus announcementStatus,
      String? creatorId,
      String? creatorDisplayName,
      @JsonKey(fromJson: dateTimeFromTimestamp, toJson: serverTimestamp)
      DateTime? createdDate,
      String? title,
      String? message});
}

/// @nodoc
class _$AnnouncementCopyWithImpl<$Res, $Val extends Announcement>
    implements $AnnouncementCopyWith<$Res> {
  _$AnnouncementCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? announcementStatus = null,
    Object? creatorId = freezed,
    Object? creatorDisplayName = freezed,
    Object? createdDate = freezed,
    Object? title = freezed,
    Object? message = freezed,
  }) {
    return _then(_value.copyWith(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      announcementStatus: null == announcementStatus
          ? _value.announcementStatus
          : announcementStatus // ignore: cast_nullable_to_non_nullable
              as AnnouncementStatus,
      creatorId: freezed == creatorId
          ? _value.creatorId
          : creatorId // ignore: cast_nullable_to_non_nullable
              as String?,
      creatorDisplayName: freezed == creatorDisplayName
          ? _value.creatorDisplayName
          : creatorDisplayName // ignore: cast_nullable_to_non_nullable
              as String?,
      createdDate: freezed == createdDate
          ? _value.createdDate
          : createdDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      title: freezed == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String?,
      message: freezed == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_AnnouncementCopyWith<$Res>
    implements $AnnouncementCopyWith<$Res> {
  factory _$$_AnnouncementCopyWith(
          _$_Announcement value, $Res Function(_$_Announcement) then) =
      __$$_AnnouncementCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String? id,
      @JsonKey(
          defaultValue: AnnouncementStatus.active,
          unknownEnumValue: AnnouncementStatus.active)
      AnnouncementStatus announcementStatus,
      String? creatorId,
      String? creatorDisplayName,
      @JsonKey(fromJson: dateTimeFromTimestamp, toJson: serverTimestamp)
      DateTime? createdDate,
      String? title,
      String? message});
}

/// @nodoc
class __$$_AnnouncementCopyWithImpl<$Res>
    extends _$AnnouncementCopyWithImpl<$Res, _$_Announcement>
    implements _$$_AnnouncementCopyWith<$Res> {
  __$$_AnnouncementCopyWithImpl(
      _$_Announcement _value, $Res Function(_$_Announcement) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? announcementStatus = null,
    Object? creatorId = freezed,
    Object? creatorDisplayName = freezed,
    Object? createdDate = freezed,
    Object? title = freezed,
    Object? message = freezed,
  }) {
    return _then(_$_Announcement(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      announcementStatus: null == announcementStatus
          ? _value.announcementStatus
          : announcementStatus // ignore: cast_nullable_to_non_nullable
              as AnnouncementStatus,
      creatorId: freezed == creatorId
          ? _value.creatorId
          : creatorId // ignore: cast_nullable_to_non_nullable
              as String?,
      creatorDisplayName: freezed == creatorDisplayName
          ? _value.creatorDisplayName
          : creatorDisplayName // ignore: cast_nullable_to_non_nullable
              as String?,
      createdDate: freezed == createdDate
          ? _value.createdDate
          : createdDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      title: freezed == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String?,
      message: freezed == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_Announcement implements _Announcement {
  _$_Announcement(
      {this.id,
      @JsonKey(
          defaultValue: AnnouncementStatus.active,
          unknownEnumValue: AnnouncementStatus.active)
      this.announcementStatus = AnnouncementStatus.active,
      this.creatorId,
      this.creatorDisplayName,
      @JsonKey(fromJson: dateTimeFromTimestamp, toJson: serverTimestamp)
      this.createdDate,
      this.title,
      this.message});

  factory _$_Announcement.fromJson(Map<String, dynamic> json) =>
      _$$_AnnouncementFromJson(json);

  @override
  final String? id;
  @override
  @JsonKey(
      defaultValue: AnnouncementStatus.active,
      unknownEnumValue: AnnouncementStatus.active)
  final AnnouncementStatus announcementStatus;
  @override
  final String? creatorId;
  @override
  final String? creatorDisplayName;
  @override
  @JsonKey(fromJson: dateTimeFromTimestamp, toJson: serverTimestamp)
  final DateTime? createdDate;
  @override
  final String? title;
  @override
  final String? message;

  @override
  String toString() {
    return 'Announcement(id: $id, announcementStatus: $announcementStatus, creatorId: $creatorId, creatorDisplayName: $creatorDisplayName, createdDate: $createdDate, title: $title, message: $message)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_Announcement &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.announcementStatus, announcementStatus) ||
                other.announcementStatus == announcementStatus) &&
            (identical(other.creatorId, creatorId) ||
                other.creatorId == creatorId) &&
            (identical(other.creatorDisplayName, creatorDisplayName) ||
                other.creatorDisplayName == creatorDisplayName) &&
            (identical(other.createdDate, createdDate) ||
                other.createdDate == createdDate) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.message, message) || other.message == message));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, announcementStatus,
      creatorId, creatorDisplayName, createdDate, title, message);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_AnnouncementCopyWith<_$_Announcement> get copyWith =>
      __$$_AnnouncementCopyWithImpl<_$_Announcement>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_AnnouncementToJson(
      this,
    );
  }
}

abstract class _Announcement implements Announcement {
  factory _Announcement(
      {final String? id,
      @JsonKey(
          defaultValue: AnnouncementStatus.active,
          unknownEnumValue: AnnouncementStatus.active)
      final AnnouncementStatus announcementStatus,
      final String? creatorId,
      final String? creatorDisplayName,
      @JsonKey(fromJson: dateTimeFromTimestamp, toJson: serverTimestamp)
      final DateTime? createdDate,
      final String? title,
      final String? message}) = _$_Announcement;

  factory _Announcement.fromJson(Map<String, dynamic> json) =
      _$_Announcement.fromJson;

  @override
  String? get id;
  @override
  @JsonKey(
      defaultValue: AnnouncementStatus.active,
      unknownEnumValue: AnnouncementStatus.active)
  AnnouncementStatus get announcementStatus;
  @override
  String? get creatorId;
  @override
  String? get creatorDisplayName;
  @override
  @JsonKey(fromJson: dateTimeFromTimestamp, toJson: serverTimestamp)
  DateTime? get createdDate;
  @override
  String? get title;
  @override
  String? get message;
  @override
  @JsonKey(ignore: true)
  _$$_AnnouncementCopyWith<_$_Announcement> get copyWith =>
      throw _privateConstructorUsedError;
}
