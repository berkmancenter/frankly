// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'junto_user_settings.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

JuntoUserSettings _$JuntoUserSettingsFromJson(Map<String, dynamic> json) {
  return _JuntoUserSettings.fromJson(json);
}

/// @nodoc
mixin _$JuntoUserSettings {
  String? get userId => throw _privateConstructorUsedError;
  String? get juntoId => throw _privateConstructorUsedError;
  @JsonKey(unknownEnumValue: null)
  NotificationEmailType? get notifyEvents => throw _privateConstructorUsedError;
  @JsonKey(unknownEnumValue: null)
  NotificationEmailType? get notifyAnnouncements =>
      throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $JuntoUserSettingsCopyWith<JuntoUserSettings> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $JuntoUserSettingsCopyWith<$Res> {
  factory $JuntoUserSettingsCopyWith(
          JuntoUserSettings value, $Res Function(JuntoUserSettings) then) =
      _$JuntoUserSettingsCopyWithImpl<$Res, JuntoUserSettings>;
  @useResult
  $Res call(
      {String? userId,
      String? juntoId,
      @JsonKey(unknownEnumValue: null) NotificationEmailType? notifyEvents,
      @JsonKey(unknownEnumValue: null)
      NotificationEmailType? notifyAnnouncements});
}

/// @nodoc
class _$JuntoUserSettingsCopyWithImpl<$Res, $Val extends JuntoUserSettings>
    implements $JuntoUserSettingsCopyWith<$Res> {
  _$JuntoUserSettingsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = freezed,
    Object? juntoId = freezed,
    Object? notifyEvents = freezed,
    Object? notifyAnnouncements = freezed,
  }) {
    return _then(_value.copyWith(
      userId: freezed == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String?,
      juntoId: freezed == juntoId
          ? _value.juntoId
          : juntoId // ignore: cast_nullable_to_non_nullable
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
abstract class _$$_JuntoUserSettingsCopyWith<$Res>
    implements $JuntoUserSettingsCopyWith<$Res> {
  factory _$$_JuntoUserSettingsCopyWith(_$_JuntoUserSettings value,
          $Res Function(_$_JuntoUserSettings) then) =
      __$$_JuntoUserSettingsCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String? userId,
      String? juntoId,
      @JsonKey(unknownEnumValue: null) NotificationEmailType? notifyEvents,
      @JsonKey(unknownEnumValue: null)
      NotificationEmailType? notifyAnnouncements});
}

/// @nodoc
class __$$_JuntoUserSettingsCopyWithImpl<$Res>
    extends _$JuntoUserSettingsCopyWithImpl<$Res, _$_JuntoUserSettings>
    implements _$$_JuntoUserSettingsCopyWith<$Res> {
  __$$_JuntoUserSettingsCopyWithImpl(
      _$_JuntoUserSettings _value, $Res Function(_$_JuntoUserSettings) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = freezed,
    Object? juntoId = freezed,
    Object? notifyEvents = freezed,
    Object? notifyAnnouncements = freezed,
  }) {
    return _then(_$_JuntoUserSettings(
      userId: freezed == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String?,
      juntoId: freezed == juntoId
          ? _value.juntoId
          : juntoId // ignore: cast_nullable_to_non_nullable
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
class _$_JuntoUserSettings implements _JuntoUserSettings {
  _$_JuntoUserSettings(
      {this.userId,
      this.juntoId,
      @JsonKey(unknownEnumValue: null) this.notifyEvents,
      @JsonKey(unknownEnumValue: null) this.notifyAnnouncements});

  factory _$_JuntoUserSettings.fromJson(Map<String, dynamic> json) =>
      _$$_JuntoUserSettingsFromJson(json);

  @override
  final String? userId;
  @override
  final String? juntoId;
  @override
  @JsonKey(unknownEnumValue: null)
  final NotificationEmailType? notifyEvents;
  @override
  @JsonKey(unknownEnumValue: null)
  final NotificationEmailType? notifyAnnouncements;

  @override
  String toString() {
    return 'JuntoUserSettings(userId: $userId, juntoId: $juntoId, notifyEvents: $notifyEvents, notifyAnnouncements: $notifyAnnouncements)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_JuntoUserSettings &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.juntoId, juntoId) || other.juntoId == juntoId) &&
            (identical(other.notifyEvents, notifyEvents) ||
                other.notifyEvents == notifyEvents) &&
            (identical(other.notifyAnnouncements, notifyAnnouncements) ||
                other.notifyAnnouncements == notifyAnnouncements));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType, userId, juntoId, notifyEvents, notifyAnnouncements);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_JuntoUserSettingsCopyWith<_$_JuntoUserSettings> get copyWith =>
      __$$_JuntoUserSettingsCopyWithImpl<_$_JuntoUserSettings>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_JuntoUserSettingsToJson(
      this,
    );
  }
}

abstract class _JuntoUserSettings implements JuntoUserSettings {
  factory _JuntoUserSettings(
      {final String? userId,
      final String? juntoId,
      @JsonKey(unknownEnumValue: null)
      final NotificationEmailType? notifyEvents,
      @JsonKey(unknownEnumValue: null)
      final NotificationEmailType? notifyAnnouncements}) = _$_JuntoUserSettings;

  factory _JuntoUserSettings.fromJson(Map<String, dynamic> json) =
      _$_JuntoUserSettings.fromJson;

  @override
  String? get userId;
  @override
  String? get juntoId;
  @override
  @JsonKey(unknownEnumValue: null)
  NotificationEmailType? get notifyEvents;
  @override
  @JsonKey(unknownEnumValue: null)
  NotificationEmailType? get notifyAnnouncements;
  @override
  @JsonKey(ignore: true)
  _$$_JuntoUserSettingsCopyWith<_$_JuntoUserSettings> get copyWith =>
      throw _privateConstructorUsedError;
}
