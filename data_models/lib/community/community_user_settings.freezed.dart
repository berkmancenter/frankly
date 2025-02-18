// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'community_user_settings.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

CommunityUserSettings _$CommunityUserSettingsFromJson(
    Map<String, dynamic> json) {
  return _CommunityUserSettings.fromJson(json);
}

/// @nodoc
mixin _$CommunityUserSettings {
  String? get userId => throw _privateConstructorUsedError;
  String? get communityId => throw _privateConstructorUsedError;
  @JsonKey(unknownEnumValue: null)
  NotificationEmailType? get notifyEvents => throw _privateConstructorUsedError;
  @JsonKey(unknownEnumValue: null)
  NotificationEmailType? get notifyAnnouncements =>
      throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $CommunityUserSettingsCopyWith<CommunityUserSettings> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CommunityUserSettingsCopyWith<$Res> {
  factory $CommunityUserSettingsCopyWith(CommunityUserSettings value,
          $Res Function(CommunityUserSettings) then) =
      _$CommunityUserSettingsCopyWithImpl<$Res, CommunityUserSettings>;
  @useResult
  $Res call(
      {String? userId,
      String? communityId,
      @JsonKey(unknownEnumValue: null) NotificationEmailType? notifyEvents,
      @JsonKey(unknownEnumValue: null)
      NotificationEmailType? notifyAnnouncements});
}

/// @nodoc
class _$CommunityUserSettingsCopyWithImpl<$Res,
        $Val extends CommunityUserSettings>
    implements $CommunityUserSettingsCopyWith<$Res> {
  _$CommunityUserSettingsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = freezed,
    Object? communityId = freezed,
    Object? notifyEvents = freezed,
    Object? notifyAnnouncements = freezed,
  }) {
    return _then(_value.copyWith(
      userId: freezed == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String?,
      communityId: freezed == communityId
          ? _value.communityId
          : communityId // ignore: cast_nullable_to_non_nullable
              as String?,
      notifyEvents: freezed == notifyEvents
          ? _value.notifyEvents
          : notifyEvents // ignore: cast_nullable_to_non_nullable
              as NotificationEmailType?,
      notifyAnnouncements: freezed == notifyAnnouncements
          ? _value.notifyAnnouncements
          : notifyAnnouncements // ignore: cast_nullable_to_non_nullable
              as NotificationEmailType?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_CommunityUserSettingsCopyWith<$Res>
    implements $CommunityUserSettingsCopyWith<$Res> {
  factory _$$_CommunityUserSettingsCopyWith(_$_CommunityUserSettings value,
          $Res Function(_$_CommunityUserSettings) then) =
      __$$_CommunityUserSettingsCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String? userId,
      String? communityId,
      @JsonKey(unknownEnumValue: null) NotificationEmailType? notifyEvents,
      @JsonKey(unknownEnumValue: null)
      NotificationEmailType? notifyAnnouncements});
}

/// @nodoc
class __$$_CommunityUserSettingsCopyWithImpl<$Res>
    extends _$CommunityUserSettingsCopyWithImpl<$Res, _$_CommunityUserSettings>
    implements _$$_CommunityUserSettingsCopyWith<$Res> {
  __$$_CommunityUserSettingsCopyWithImpl(_$_CommunityUserSettings _value,
      $Res Function(_$_CommunityUserSettings) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = freezed,
    Object? communityId = freezed,
    Object? notifyEvents = freezed,
    Object? notifyAnnouncements = freezed,
  }) {
    return _then(_$_CommunityUserSettings(
      userId: freezed == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String?,
      communityId: freezed == communityId
          ? _value.communityId
          : communityId // ignore: cast_nullable_to_non_nullable
              as String?,
      notifyEvents: freezed == notifyEvents
          ? _value.notifyEvents
          : notifyEvents // ignore: cast_nullable_to_non_nullable
              as NotificationEmailType?,
      notifyAnnouncements: freezed == notifyAnnouncements
          ? _value.notifyAnnouncements
          : notifyAnnouncements // ignore: cast_nullable_to_non_nullable
              as NotificationEmailType?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_CommunityUserSettings implements _CommunityUserSettings {
  _$_CommunityUserSettings(
      {this.userId,
      this.communityId,
      @JsonKey(unknownEnumValue: null) this.notifyEvents,
      @JsonKey(unknownEnumValue: null) this.notifyAnnouncements});

  factory _$_CommunityUserSettings.fromJson(Map<String, dynamic> json) =>
      _$$_CommunityUserSettingsFromJson(json);

  @override
  final String? userId;
  @override
  final String? communityId;
  @override
  @JsonKey(unknownEnumValue: null)
  final NotificationEmailType? notifyEvents;
  @override
  @JsonKey(unknownEnumValue: null)
  final NotificationEmailType? notifyAnnouncements;

  @override
  String toString() {
    return 'CommunityUserSettings(userId: $userId, communityId: $communityId, notifyEvents: $notifyEvents, notifyAnnouncements: $notifyAnnouncements)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_CommunityUserSettings &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.communityId, communityId) ||
                other.communityId == communityId) &&
            (identical(other.notifyEvents, notifyEvents) ||
                other.notifyEvents == notifyEvents) &&
            (identical(other.notifyAnnouncements, notifyAnnouncements) ||
                other.notifyAnnouncements == notifyAnnouncements));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType, userId, communityId, notifyEvents, notifyAnnouncements);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_CommunityUserSettingsCopyWith<_$_CommunityUserSettings> get copyWith =>
      __$$_CommunityUserSettingsCopyWithImpl<_$_CommunityUserSettings>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_CommunityUserSettingsToJson(
      this,
    );
  }
}

abstract class _CommunityUserSettings implements CommunityUserSettings {
  factory _CommunityUserSettings(
          {final String? userId,
          final String? communityId,
          @JsonKey(unknownEnumValue: null)
          final NotificationEmailType? notifyEvents,
          @JsonKey(unknownEnumValue: null)
          final NotificationEmailType? notifyAnnouncements}) =
      _$_CommunityUserSettings;

  factory _CommunityUserSettings.fromJson(Map<String, dynamic> json) =
      _$_CommunityUserSettings.fromJson;

  @override
  String? get userId;
  @override
  String? get communityId;
  @override
  @JsonKey(unknownEnumValue: null)
  NotificationEmailType? get notifyEvents;
  @override
  @JsonKey(unknownEnumValue: null)
  NotificationEmailType? get notifyAnnouncements;
  @override
  @JsonKey(ignore: true)
  _$$_CommunityUserSettingsCopyWith<_$_CommunityUserSettings> get copyWith =>
      throw _privateConstructorUsedError;
}
