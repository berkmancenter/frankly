// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'external_integration.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

ExternalIntegration _$ExternalIntegrationFromJson(Map<String, dynamic> json) {
  return _ExternalIntegration.fromJson(json);
}

/// @nodoc
mixin _$ExternalIntegration {
  String get id => throw _privateConstructorUsedError;
  String get communityId => throw _privateConstructorUsedError;
  String get displayName => throw _privateConstructorUsedError;

  /// Image shown next to [displayName] in the UI.
  String? get logoUrl => throw _privateConstructorUsedError;

  /// Short description shown to community admins and event hosts.
  String? get description => throw _privateConstructorUsedError;

  /// Optional label for the free-text value hosts can set per event
  /// (for example "Project ID"). The value is passed through to the
  /// webhook payload untouched.
  String? get externalReferenceLabel => throw _privateConstructorUsedError;

  /// When false, no deliveries are sent and the integration is hidden from
  /// event hosts and participants.
  bool get isActive => throw _privateConstructorUsedError;

  /// Whether the integration is switched on for newly created events.
  bool get enabledForNewEvents => throw _privateConstructorUsedError;

  /// Event types this integration receives. See
  /// [ExternalIntegrationEventTypes].
  List<String> get events => throw _privateConstructorUsedError;
  @JsonKey(fromJson: dateTimeFromTimestamp, toJson: serverTimestampOrNull)
  DateTime? get createdAt => throw _privateConstructorUsedError;
  @JsonKey(fromJson: dateTimeFromTimestamp, toJson: serverTimestampOrNull)
  DateTime? get updatedAt => throw _privateConstructorUsedError;
  @JsonKey(fromJson: dateTimeFromTimestamp, toJson: serverTimestampOrNull)
  DateTime? get secretRotatedAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ExternalIntegrationCopyWith<ExternalIntegration> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ExternalIntegrationCopyWith<$Res> {
  factory $ExternalIntegrationCopyWith(
          ExternalIntegration value, $Res Function(ExternalIntegration) then) =
      _$ExternalIntegrationCopyWithImpl<$Res, ExternalIntegration>;
  @useResult
  $Res call(
      {String id,
      String communityId,
      String displayName,
      String? logoUrl,
      String? description,
      String? externalReferenceLabel,
      bool isActive,
      bool enabledForNewEvents,
      List<String> events,
      @JsonKey(fromJson: dateTimeFromTimestamp, toJson: serverTimestampOrNull)
      DateTime? createdAt,
      @JsonKey(fromJson: dateTimeFromTimestamp, toJson: serverTimestampOrNull)
      DateTime? updatedAt,
      @JsonKey(fromJson: dateTimeFromTimestamp, toJson: serverTimestampOrNull)
      DateTime? secretRotatedAt});
}

/// @nodoc
class _$ExternalIntegrationCopyWithImpl<$Res, $Val extends ExternalIntegration>
    implements $ExternalIntegrationCopyWith<$Res> {
  _$ExternalIntegrationCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? communityId = null,
    Object? displayName = null,
    Object? logoUrl = freezed,
    Object? description = freezed,
    Object? externalReferenceLabel = freezed,
    Object? isActive = null,
    Object? enabledForNewEvents = null,
    Object? events = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? secretRotatedAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      communityId: null == communityId
          ? _value.communityId
          : communityId // ignore: cast_nullable_to_non_nullable
              as String,
      displayName: null == displayName
          ? _value.displayName
          : displayName // ignore: cast_nullable_to_non_nullable
              as String,
      logoUrl: freezed == logoUrl
          ? _value.logoUrl
          : logoUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      externalReferenceLabel: freezed == externalReferenceLabel
          ? _value.externalReferenceLabel
          : externalReferenceLabel // ignore: cast_nullable_to_non_nullable
              as String?,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
      enabledForNewEvents: null == enabledForNewEvents
          ? _value.enabledForNewEvents
          : enabledForNewEvents // ignore: cast_nullable_to_non_nullable
              as bool,
      events: null == events
          ? _value.events
          : events // ignore: cast_nullable_to_non_nullable
              as List<String>,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      secretRotatedAt: freezed == secretRotatedAt
          ? _value.secretRotatedAt
          : secretRotatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_ExternalIntegrationCopyWith<$Res>
    implements $ExternalIntegrationCopyWith<$Res> {
  factory _$$_ExternalIntegrationCopyWith(_$_ExternalIntegration value,
          $Res Function(_$_ExternalIntegration) then) =
      __$$_ExternalIntegrationCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String communityId,
      String displayName,
      String? logoUrl,
      String? description,
      String? externalReferenceLabel,
      bool isActive,
      bool enabledForNewEvents,
      List<String> events,
      @JsonKey(fromJson: dateTimeFromTimestamp, toJson: serverTimestampOrNull)
      DateTime? createdAt,
      @JsonKey(fromJson: dateTimeFromTimestamp, toJson: serverTimestampOrNull)
      DateTime? updatedAt,
      @JsonKey(fromJson: dateTimeFromTimestamp, toJson: serverTimestampOrNull)
      DateTime? secretRotatedAt});
}

/// @nodoc
class __$$_ExternalIntegrationCopyWithImpl<$Res>
    extends _$ExternalIntegrationCopyWithImpl<$Res, _$_ExternalIntegration>
    implements _$$_ExternalIntegrationCopyWith<$Res> {
  __$$_ExternalIntegrationCopyWithImpl(_$_ExternalIntegration _value,
      $Res Function(_$_ExternalIntegration) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? communityId = null,
    Object? displayName = null,
    Object? logoUrl = freezed,
    Object? description = freezed,
    Object? externalReferenceLabel = freezed,
    Object? isActive = null,
    Object? enabledForNewEvents = null,
    Object? events = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? secretRotatedAt = freezed,
  }) {
    return _then(_$_ExternalIntegration(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      communityId: null == communityId
          ? _value.communityId
          : communityId // ignore: cast_nullable_to_non_nullable
              as String,
      displayName: null == displayName
          ? _value.displayName
          : displayName // ignore: cast_nullable_to_non_nullable
              as String,
      logoUrl: freezed == logoUrl
          ? _value.logoUrl
          : logoUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      externalReferenceLabel: freezed == externalReferenceLabel
          ? _value.externalReferenceLabel
          : externalReferenceLabel // ignore: cast_nullable_to_non_nullable
              as String?,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
      enabledForNewEvents: null == enabledForNewEvents
          ? _value.enabledForNewEvents
          : enabledForNewEvents // ignore: cast_nullable_to_non_nullable
              as bool,
      events: null == events
          ? _value.events
          : events // ignore: cast_nullable_to_non_nullable
              as List<String>,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      secretRotatedAt: freezed == secretRotatedAt
          ? _value.secretRotatedAt
          : secretRotatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_ExternalIntegration implements _ExternalIntegration {
  _$_ExternalIntegration(
      {required this.id,
      required this.communityId,
      required this.displayName,
      this.logoUrl,
      this.description,
      this.externalReferenceLabel,
      this.isActive = true,
      this.enabledForNewEvents = false,
      this.events = const [],
      @JsonKey(fromJson: dateTimeFromTimestamp, toJson: serverTimestampOrNull)
      this.createdAt,
      @JsonKey(fromJson: dateTimeFromTimestamp, toJson: serverTimestampOrNull)
      this.updatedAt,
      @JsonKey(fromJson: dateTimeFromTimestamp, toJson: serverTimestampOrNull)
      this.secretRotatedAt});

  factory _$_ExternalIntegration.fromJson(Map<String, dynamic> json) =>
      _$$_ExternalIntegrationFromJson(json);

  @override
  final String id;
  @override
  final String communityId;
  @override
  final String displayName;

  /// Image shown next to [displayName] in the UI.
  @override
  final String? logoUrl;

  /// Short description shown to community admins and event hosts.
  @override
  final String? description;

  /// Optional label for the free-text value hosts can set per event
  /// (for example "Project ID"). The value is passed through to the
  /// webhook payload untouched.
  @override
  final String? externalReferenceLabel;

  /// When false, no deliveries are sent and the integration is hidden from
  /// event hosts and participants.
  @override
  @JsonKey()
  final bool isActive;

  /// Whether the integration is switched on for newly created events.
  @override
  @JsonKey()
  final bool enabledForNewEvents;

  /// Event types this integration receives. See
  /// [ExternalIntegrationEventTypes].
  @override
  @JsonKey()
  final List<String> events;
  @override
  @JsonKey(fromJson: dateTimeFromTimestamp, toJson: serverTimestampOrNull)
  final DateTime? createdAt;
  @override
  @JsonKey(fromJson: dateTimeFromTimestamp, toJson: serverTimestampOrNull)
  final DateTime? updatedAt;
  @override
  @JsonKey(fromJson: dateTimeFromTimestamp, toJson: serverTimestampOrNull)
  final DateTime? secretRotatedAt;

  @override
  String toString() {
    return 'ExternalIntegration(id: $id, communityId: $communityId, displayName: $displayName, logoUrl: $logoUrl, description: $description, externalReferenceLabel: $externalReferenceLabel, isActive: $isActive, enabledForNewEvents: $enabledForNewEvents, events: $events, createdAt: $createdAt, updatedAt: $updatedAt, secretRotatedAt: $secretRotatedAt)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_ExternalIntegration &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.communityId, communityId) ||
                other.communityId == communityId) &&
            (identical(other.displayName, displayName) ||
                other.displayName == displayName) &&
            (identical(other.logoUrl, logoUrl) || other.logoUrl == logoUrl) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.externalReferenceLabel, externalReferenceLabel) ||
                other.externalReferenceLabel == externalReferenceLabel) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            (identical(other.enabledForNewEvents, enabledForNewEvents) ||
                other.enabledForNewEvents == enabledForNewEvents) &&
            const DeepCollectionEquality().equals(other.events, events) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.secretRotatedAt, secretRotatedAt) ||
                other.secretRotatedAt == secretRotatedAt));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      communityId,
      displayName,
      logoUrl,
      description,
      externalReferenceLabel,
      isActive,
      enabledForNewEvents,
      const DeepCollectionEquality().hash(events),
      createdAt,
      updatedAt,
      secretRotatedAt);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_ExternalIntegrationCopyWith<_$_ExternalIntegration> get copyWith =>
      __$$_ExternalIntegrationCopyWithImpl<_$_ExternalIntegration>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_ExternalIntegrationToJson(
      this,
    );
  }
}

abstract class _ExternalIntegration implements ExternalIntegration {
  factory _ExternalIntegration(
      {required final String id,
      required final String communityId,
      required final String displayName,
      final String? logoUrl,
      final String? description,
      final String? externalReferenceLabel,
      final bool isActive,
      final bool enabledForNewEvents,
      final List<String> events,
      @JsonKey(fromJson: dateTimeFromTimestamp, toJson: serverTimestampOrNull)
      final DateTime? createdAt,
      @JsonKey(fromJson: dateTimeFromTimestamp, toJson: serverTimestampOrNull)
      final DateTime? updatedAt,
      @JsonKey(fromJson: dateTimeFromTimestamp, toJson: serverTimestampOrNull)
      final DateTime? secretRotatedAt}) = _$_ExternalIntegration;

  factory _ExternalIntegration.fromJson(Map<String, dynamic> json) =
      _$_ExternalIntegration.fromJson;

  @override
  String get id;
  @override
  String get communityId;
  @override
  String get displayName;
  @override

  /// Image shown next to [displayName] in the UI.
  String? get logoUrl;
  @override

  /// Short description shown to community admins and event hosts.
  String? get description;
  @override

  /// Optional label for the free-text value hosts can set per event
  /// (for example "Project ID"). The value is passed through to the
  /// webhook payload untouched.
  String? get externalReferenceLabel;
  @override

  /// When false, no deliveries are sent and the integration is hidden from
  /// event hosts and participants.
  bool get isActive;
  @override

  /// Whether the integration is switched on for newly created events.
  bool get enabledForNewEvents;
  @override

  /// Event types this integration receives. See
  /// [ExternalIntegrationEventTypes].
  List<String> get events;
  @override
  @JsonKey(fromJson: dateTimeFromTimestamp, toJson: serverTimestampOrNull)
  DateTime? get createdAt;
  @override
  @JsonKey(fromJson: dateTimeFromTimestamp, toJson: serverTimestampOrNull)
  DateTime? get updatedAt;
  @override
  @JsonKey(fromJson: dateTimeFromTimestamp, toJson: serverTimestampOrNull)
  DateTime? get secretRotatedAt;
  @override
  @JsonKey(ignore: true)
  _$$_ExternalIntegrationCopyWith<_$_ExternalIntegration> get copyWith =>
      throw _privateConstructorUsedError;
}

ExternalIntegrationEndpoint _$ExternalIntegrationEndpointFromJson(
    Map<String, dynamic> json) {
  return _ExternalIntegrationEndpoint.fromJson(json);
}

/// @nodoc
mixin _$ExternalIntegrationEndpoint {
  String get integrationId => throw _privateConstructorUsedError;
  String get communityId => throw _privateConstructorUsedError;
  String get webhookUrl => throw _privateConstructorUsedError;
  @JsonKey(fromJson: dateTimeFromTimestamp, toJson: serverTimestampOrNull)
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ExternalIntegrationEndpointCopyWith<ExternalIntegrationEndpoint>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ExternalIntegrationEndpointCopyWith<$Res> {
  factory $ExternalIntegrationEndpointCopyWith(
          ExternalIntegrationEndpoint value,
          $Res Function(ExternalIntegrationEndpoint) then) =
      _$ExternalIntegrationEndpointCopyWithImpl<$Res,
          ExternalIntegrationEndpoint>;
  @useResult
  $Res call(
      {String integrationId,
      String communityId,
      String webhookUrl,
      @JsonKey(fromJson: dateTimeFromTimestamp, toJson: serverTimestampOrNull)
      DateTime? updatedAt});
}

/// @nodoc
class _$ExternalIntegrationEndpointCopyWithImpl<$Res,
        $Val extends ExternalIntegrationEndpoint>
    implements $ExternalIntegrationEndpointCopyWith<$Res> {
  _$ExternalIntegrationEndpointCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? integrationId = null,
    Object? communityId = null,
    Object? webhookUrl = null,
    Object? updatedAt = freezed,
  }) {
    return _then(_value.copyWith(
      integrationId: null == integrationId
          ? _value.integrationId
          : integrationId // ignore: cast_nullable_to_non_nullable
              as String,
      communityId: null == communityId
          ? _value.communityId
          : communityId // ignore: cast_nullable_to_non_nullable
              as String,
      webhookUrl: null == webhookUrl
          ? _value.webhookUrl
          : webhookUrl // ignore: cast_nullable_to_non_nullable
              as String,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_ExternalIntegrationEndpointCopyWith<$Res>
    implements $ExternalIntegrationEndpointCopyWith<$Res> {
  factory _$$_ExternalIntegrationEndpointCopyWith(
          _$_ExternalIntegrationEndpoint value,
          $Res Function(_$_ExternalIntegrationEndpoint) then) =
      __$$_ExternalIntegrationEndpointCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String integrationId,
      String communityId,
      String webhookUrl,
      @JsonKey(fromJson: dateTimeFromTimestamp, toJson: serverTimestampOrNull)
      DateTime? updatedAt});
}

/// @nodoc
class __$$_ExternalIntegrationEndpointCopyWithImpl<$Res>
    extends _$ExternalIntegrationEndpointCopyWithImpl<$Res,
        _$_ExternalIntegrationEndpoint>
    implements _$$_ExternalIntegrationEndpointCopyWith<$Res> {
  __$$_ExternalIntegrationEndpointCopyWithImpl(
      _$_ExternalIntegrationEndpoint _value,
      $Res Function(_$_ExternalIntegrationEndpoint) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? integrationId = null,
    Object? communityId = null,
    Object? webhookUrl = null,
    Object? updatedAt = freezed,
  }) {
    return _then(_$_ExternalIntegrationEndpoint(
      integrationId: null == integrationId
          ? _value.integrationId
          : integrationId // ignore: cast_nullable_to_non_nullable
              as String,
      communityId: null == communityId
          ? _value.communityId
          : communityId // ignore: cast_nullable_to_non_nullable
              as String,
      webhookUrl: null == webhookUrl
          ? _value.webhookUrl
          : webhookUrl // ignore: cast_nullable_to_non_nullable
              as String,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_ExternalIntegrationEndpoint implements _ExternalIntegrationEndpoint {
  _$_ExternalIntegrationEndpoint(
      {required this.integrationId,
      required this.communityId,
      required this.webhookUrl,
      @JsonKey(fromJson: dateTimeFromTimestamp, toJson: serverTimestampOrNull)
      this.updatedAt});

  factory _$_ExternalIntegrationEndpoint.fromJson(Map<String, dynamic> json) =>
      _$$_ExternalIntegrationEndpointFromJson(json);

  @override
  final String integrationId;
  @override
  final String communityId;
  @override
  final String webhookUrl;
  @override
  @JsonKey(fromJson: dateTimeFromTimestamp, toJson: serverTimestampOrNull)
  final DateTime? updatedAt;

  @override
  String toString() {
    return 'ExternalIntegrationEndpoint(integrationId: $integrationId, communityId: $communityId, webhookUrl: $webhookUrl, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_ExternalIntegrationEndpoint &&
            (identical(other.integrationId, integrationId) ||
                other.integrationId == integrationId) &&
            (identical(other.communityId, communityId) ||
                other.communityId == communityId) &&
            (identical(other.webhookUrl, webhookUrl) ||
                other.webhookUrl == webhookUrl) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType, integrationId, communityId, webhookUrl, updatedAt);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_ExternalIntegrationEndpointCopyWith<_$_ExternalIntegrationEndpoint>
      get copyWith => __$$_ExternalIntegrationEndpointCopyWithImpl<
          _$_ExternalIntegrationEndpoint>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_ExternalIntegrationEndpointToJson(
      this,
    );
  }
}

abstract class _ExternalIntegrationEndpoint
    implements ExternalIntegrationEndpoint {
  factory _ExternalIntegrationEndpoint(
      {required final String integrationId,
      required final String communityId,
      required final String webhookUrl,
      @JsonKey(fromJson: dateTimeFromTimestamp, toJson: serverTimestampOrNull)
      final DateTime? updatedAt}) = _$_ExternalIntegrationEndpoint;

  factory _ExternalIntegrationEndpoint.fromJson(Map<String, dynamic> json) =
      _$_ExternalIntegrationEndpoint.fromJson;

  @override
  String get integrationId;
  @override
  String get communityId;
  @override
  String get webhookUrl;
  @override
  @JsonKey(fromJson: dateTimeFromTimestamp, toJson: serverTimestampOrNull)
  DateTime? get updatedAt;
  @override
  @JsonKey(ignore: true)
  _$$_ExternalIntegrationEndpointCopyWith<_$_ExternalIntegrationEndpoint>
      get copyWith => throw _privateConstructorUsedError;
}

EventExternalIntegrationSettings _$EventExternalIntegrationSettingsFromJson(
    Map<String, dynamic> json) {
  return _EventExternalIntegrationSettings.fromJson(json);
}

/// @nodoc
mixin _$EventExternalIntegrationSettings {
  String get integrationId => throw _privateConstructorUsedError;
  bool get enabled => throw _privateConstructorUsedError;

  /// Free-text value passed through to the webhook payload untouched.
  String? get externalReference => throw _privateConstructorUsedError;
  String? get updatedBy => throw _privateConstructorUsedError;
  @JsonKey(fromJson: dateTimeFromTimestamp, toJson: serverTimestamp)
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $EventExternalIntegrationSettingsCopyWith<EventExternalIntegrationSettings>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $EventExternalIntegrationSettingsCopyWith<$Res> {
  factory $EventExternalIntegrationSettingsCopyWith(
          EventExternalIntegrationSettings value,
          $Res Function(EventExternalIntegrationSettings) then) =
      _$EventExternalIntegrationSettingsCopyWithImpl<$Res,
          EventExternalIntegrationSettings>;
  @useResult
  $Res call(
      {String integrationId,
      bool enabled,
      String? externalReference,
      String? updatedBy,
      @JsonKey(fromJson: dateTimeFromTimestamp, toJson: serverTimestamp)
      DateTime? updatedAt});
}

/// @nodoc
class _$EventExternalIntegrationSettingsCopyWithImpl<$Res,
        $Val extends EventExternalIntegrationSettings>
    implements $EventExternalIntegrationSettingsCopyWith<$Res> {
  _$EventExternalIntegrationSettingsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? integrationId = null,
    Object? enabled = null,
    Object? externalReference = freezed,
    Object? updatedBy = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_value.copyWith(
      integrationId: null == integrationId
          ? _value.integrationId
          : integrationId // ignore: cast_nullable_to_non_nullable
              as String,
      enabled: null == enabled
          ? _value.enabled
          : enabled // ignore: cast_nullable_to_non_nullable
              as bool,
      externalReference: freezed == externalReference
          ? _value.externalReference
          : externalReference // ignore: cast_nullable_to_non_nullable
              as String?,
      updatedBy: freezed == updatedBy
          ? _value.updatedBy
          : updatedBy // ignore: cast_nullable_to_non_nullable
              as String?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_EventExternalIntegrationSettingsCopyWith<$Res>
    implements $EventExternalIntegrationSettingsCopyWith<$Res> {
  factory _$$_EventExternalIntegrationSettingsCopyWith(
          _$_EventExternalIntegrationSettings value,
          $Res Function(_$_EventExternalIntegrationSettings) then) =
      __$$_EventExternalIntegrationSettingsCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String integrationId,
      bool enabled,
      String? externalReference,
      String? updatedBy,
      @JsonKey(fromJson: dateTimeFromTimestamp, toJson: serverTimestamp)
      DateTime? updatedAt});
}

/// @nodoc
class __$$_EventExternalIntegrationSettingsCopyWithImpl<$Res>
    extends _$EventExternalIntegrationSettingsCopyWithImpl<$Res,
        _$_EventExternalIntegrationSettings>
    implements _$$_EventExternalIntegrationSettingsCopyWith<$Res> {
  __$$_EventExternalIntegrationSettingsCopyWithImpl(
      _$_EventExternalIntegrationSettings _value,
      $Res Function(_$_EventExternalIntegrationSettings) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? integrationId = null,
    Object? enabled = null,
    Object? externalReference = freezed,
    Object? updatedBy = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_$_EventExternalIntegrationSettings(
      integrationId: null == integrationId
          ? _value.integrationId
          : integrationId // ignore: cast_nullable_to_non_nullable
              as String,
      enabled: null == enabled
          ? _value.enabled
          : enabled // ignore: cast_nullable_to_non_nullable
              as bool,
      externalReference: freezed == externalReference
          ? _value.externalReference
          : externalReference // ignore: cast_nullable_to_non_nullable
              as String?,
      updatedBy: freezed == updatedBy
          ? _value.updatedBy
          : updatedBy // ignore: cast_nullable_to_non_nullable
              as String?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_EventExternalIntegrationSettings
    implements _EventExternalIntegrationSettings {
  _$_EventExternalIntegrationSettings(
      {required this.integrationId,
      this.enabled = false,
      this.externalReference,
      this.updatedBy,
      @JsonKey(fromJson: dateTimeFromTimestamp, toJson: serverTimestamp)
      this.updatedAt});

  factory _$_EventExternalIntegrationSettings.fromJson(
          Map<String, dynamic> json) =>
      _$$_EventExternalIntegrationSettingsFromJson(json);

  @override
  final String integrationId;
  @override
  @JsonKey()
  final bool enabled;

  /// Free-text value passed through to the webhook payload untouched.
  @override
  final String? externalReference;
  @override
  final String? updatedBy;
  @override
  @JsonKey(fromJson: dateTimeFromTimestamp, toJson: serverTimestamp)
  final DateTime? updatedAt;

  @override
  String toString() {
    return 'EventExternalIntegrationSettings(integrationId: $integrationId, enabled: $enabled, externalReference: $externalReference, updatedBy: $updatedBy, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_EventExternalIntegrationSettings &&
            (identical(other.integrationId, integrationId) ||
                other.integrationId == integrationId) &&
            (identical(other.enabled, enabled) || other.enabled == enabled) &&
            (identical(other.externalReference, externalReference) ||
                other.externalReference == externalReference) &&
            (identical(other.updatedBy, updatedBy) ||
                other.updatedBy == updatedBy) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, integrationId, enabled,
      externalReference, updatedBy, updatedAt);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_EventExternalIntegrationSettingsCopyWith<
          _$_EventExternalIntegrationSettings>
      get copyWith => __$$_EventExternalIntegrationSettingsCopyWithImpl<
          _$_EventExternalIntegrationSettings>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_EventExternalIntegrationSettingsToJson(
      this,
    );
  }
}

abstract class _EventExternalIntegrationSettings
    implements EventExternalIntegrationSettings {
  factory _EventExternalIntegrationSettings(
      {required final String integrationId,
      final bool enabled,
      final String? externalReference,
      final String? updatedBy,
      @JsonKey(fromJson: dateTimeFromTimestamp, toJson: serverTimestamp)
      final DateTime? updatedAt}) = _$_EventExternalIntegrationSettings;

  factory _EventExternalIntegrationSettings.fromJson(
      Map<String, dynamic> json) = _$_EventExternalIntegrationSettings.fromJson;

  @override
  String get integrationId;
  @override
  bool get enabled;
  @override

  /// Free-text value passed through to the webhook payload untouched.
  String? get externalReference;
  @override
  String? get updatedBy;
  @override
  @JsonKey(fromJson: dateTimeFromTimestamp, toJson: serverTimestamp)
  DateTime? get updatedAt;
  @override
  @JsonKey(ignore: true)
  _$$_EventExternalIntegrationSettingsCopyWith<
          _$_EventExternalIntegrationSettings>
      get copyWith => throw _privateConstructorUsedError;
}

ExternalIntegrationDelivery _$ExternalIntegrationDeliveryFromJson(
    Map<String, dynamic> json) {
  return _ExternalIntegrationDelivery.fromJson(json);
}

/// @nodoc
mixin _$ExternalIntegrationDelivery {
  String get id => throw _privateConstructorUsedError;
  String get communityId => throw _privateConstructorUsedError;
  String get eventId => throw _privateConstructorUsedError;
  String get integrationId => throw _privateConstructorUsedError;
  String get eventType => throw _privateConstructorUsedError;
  String? get eventPath => throw _privateConstructorUsedError;
  String? get recordingSessionId => throw _privateConstructorUsedError;
  String? get artifactKey => throw _privateConstructorUsedError;
  String? get artifactPath => throw _privateConstructorUsedError;
  @JsonKey(unknownEnumValue: ExternalIntegrationDeliveryStatus.pending)
  ExternalIntegrationDeliveryStatus get status =>
      throw _privateConstructorUsedError;
  int get attempts => throw _privateConstructorUsedError;
  String? get lastError => throw _privateConstructorUsedError;
  int? get lastResponseStatus => throw _privateConstructorUsedError;
  @JsonKey(fromJson: dateTimeFromTimestamp, toJson: serverTimestampOrNull)
  DateTime? get createdAt => throw _privateConstructorUsedError;
  @JsonKey(fromJson: dateTimeFromTimestamp, toJson: serverTimestampOrNull)
  DateTime? get updatedAt => throw _privateConstructorUsedError;
  @JsonKey(fromJson: dateTimeFromTimestamp, toJson: serverTimestampOrNull)
  DateTime? get lastAttemptAt => throw _privateConstructorUsedError;
  @JsonKey(fromJson: dateTimeFromTimestamp, toJson: serverTimestampOrNull)
  DateTime? get nextAttemptAt => throw _privateConstructorUsedError;
  @JsonKey(fromJson: dateTimeFromTimestamp, toJson: serverTimestampOrNull)
  DateTime? get deliveredAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ExternalIntegrationDeliveryCopyWith<ExternalIntegrationDelivery>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ExternalIntegrationDeliveryCopyWith<$Res> {
  factory $ExternalIntegrationDeliveryCopyWith(
          ExternalIntegrationDelivery value,
          $Res Function(ExternalIntegrationDelivery) then) =
      _$ExternalIntegrationDeliveryCopyWithImpl<$Res,
          ExternalIntegrationDelivery>;
  @useResult
  $Res call(
      {String id,
      String communityId,
      String eventId,
      String integrationId,
      String eventType,
      String? eventPath,
      String? recordingSessionId,
      String? artifactKey,
      String? artifactPath,
      @JsonKey(unknownEnumValue: ExternalIntegrationDeliveryStatus.pending)
      ExternalIntegrationDeliveryStatus status,
      int attempts,
      String? lastError,
      int? lastResponseStatus,
      @JsonKey(fromJson: dateTimeFromTimestamp, toJson: serverTimestampOrNull)
      DateTime? createdAt,
      @JsonKey(fromJson: dateTimeFromTimestamp, toJson: serverTimestampOrNull)
      DateTime? updatedAt,
      @JsonKey(fromJson: dateTimeFromTimestamp, toJson: serverTimestampOrNull)
      DateTime? lastAttemptAt,
      @JsonKey(fromJson: dateTimeFromTimestamp, toJson: serverTimestampOrNull)
      DateTime? nextAttemptAt,
      @JsonKey(fromJson: dateTimeFromTimestamp, toJson: serverTimestampOrNull)
      DateTime? deliveredAt});
}

/// @nodoc
class _$ExternalIntegrationDeliveryCopyWithImpl<$Res,
        $Val extends ExternalIntegrationDelivery>
    implements $ExternalIntegrationDeliveryCopyWith<$Res> {
  _$ExternalIntegrationDeliveryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? communityId = null,
    Object? eventId = null,
    Object? integrationId = null,
    Object? eventType = null,
    Object? eventPath = freezed,
    Object? recordingSessionId = freezed,
    Object? artifactKey = freezed,
    Object? artifactPath = freezed,
    Object? status = null,
    Object? attempts = null,
    Object? lastError = freezed,
    Object? lastResponseStatus = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? lastAttemptAt = freezed,
    Object? nextAttemptAt = freezed,
    Object? deliveredAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      communityId: null == communityId
          ? _value.communityId
          : communityId // ignore: cast_nullable_to_non_nullable
              as String,
      eventId: null == eventId
          ? _value.eventId
          : eventId // ignore: cast_nullable_to_non_nullable
              as String,
      integrationId: null == integrationId
          ? _value.integrationId
          : integrationId // ignore: cast_nullable_to_non_nullable
              as String,
      eventType: null == eventType
          ? _value.eventType
          : eventType // ignore: cast_nullable_to_non_nullable
              as String,
      eventPath: freezed == eventPath
          ? _value.eventPath
          : eventPath // ignore: cast_nullable_to_non_nullable
              as String?,
      recordingSessionId: freezed == recordingSessionId
          ? _value.recordingSessionId
          : recordingSessionId // ignore: cast_nullable_to_non_nullable
              as String?,
      artifactKey: freezed == artifactKey
          ? _value.artifactKey
          : artifactKey // ignore: cast_nullable_to_non_nullable
              as String?,
      artifactPath: freezed == artifactPath
          ? _value.artifactPath
          : artifactPath // ignore: cast_nullable_to_non_nullable
              as String?,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as ExternalIntegrationDeliveryStatus,
      attempts: null == attempts
          ? _value.attempts
          : attempts // ignore: cast_nullable_to_non_nullable
              as int,
      lastError: freezed == lastError
          ? _value.lastError
          : lastError // ignore: cast_nullable_to_non_nullable
              as String?,
      lastResponseStatus: freezed == lastResponseStatus
          ? _value.lastResponseStatus
          : lastResponseStatus // ignore: cast_nullable_to_non_nullable
              as int?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      lastAttemptAt: freezed == lastAttemptAt
          ? _value.lastAttemptAt
          : lastAttemptAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      nextAttemptAt: freezed == nextAttemptAt
          ? _value.nextAttemptAt
          : nextAttemptAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      deliveredAt: freezed == deliveredAt
          ? _value.deliveredAt
          : deliveredAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_ExternalIntegrationDeliveryCopyWith<$Res>
    implements $ExternalIntegrationDeliveryCopyWith<$Res> {
  factory _$$_ExternalIntegrationDeliveryCopyWith(
          _$_ExternalIntegrationDelivery value,
          $Res Function(_$_ExternalIntegrationDelivery) then) =
      __$$_ExternalIntegrationDeliveryCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String communityId,
      String eventId,
      String integrationId,
      String eventType,
      String? eventPath,
      String? recordingSessionId,
      String? artifactKey,
      String? artifactPath,
      @JsonKey(unknownEnumValue: ExternalIntegrationDeliveryStatus.pending)
      ExternalIntegrationDeliveryStatus status,
      int attempts,
      String? lastError,
      int? lastResponseStatus,
      @JsonKey(fromJson: dateTimeFromTimestamp, toJson: serverTimestampOrNull)
      DateTime? createdAt,
      @JsonKey(fromJson: dateTimeFromTimestamp, toJson: serverTimestampOrNull)
      DateTime? updatedAt,
      @JsonKey(fromJson: dateTimeFromTimestamp, toJson: serverTimestampOrNull)
      DateTime? lastAttemptAt,
      @JsonKey(fromJson: dateTimeFromTimestamp, toJson: serverTimestampOrNull)
      DateTime? nextAttemptAt,
      @JsonKey(fromJson: dateTimeFromTimestamp, toJson: serverTimestampOrNull)
      DateTime? deliveredAt});
}

/// @nodoc
class __$$_ExternalIntegrationDeliveryCopyWithImpl<$Res>
    extends _$ExternalIntegrationDeliveryCopyWithImpl<$Res,
        _$_ExternalIntegrationDelivery>
    implements _$$_ExternalIntegrationDeliveryCopyWith<$Res> {
  __$$_ExternalIntegrationDeliveryCopyWithImpl(
      _$_ExternalIntegrationDelivery _value,
      $Res Function(_$_ExternalIntegrationDelivery) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? communityId = null,
    Object? eventId = null,
    Object? integrationId = null,
    Object? eventType = null,
    Object? eventPath = freezed,
    Object? recordingSessionId = freezed,
    Object? artifactKey = freezed,
    Object? artifactPath = freezed,
    Object? status = null,
    Object? attempts = null,
    Object? lastError = freezed,
    Object? lastResponseStatus = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? lastAttemptAt = freezed,
    Object? nextAttemptAt = freezed,
    Object? deliveredAt = freezed,
  }) {
    return _then(_$_ExternalIntegrationDelivery(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      communityId: null == communityId
          ? _value.communityId
          : communityId // ignore: cast_nullable_to_non_nullable
              as String,
      eventId: null == eventId
          ? _value.eventId
          : eventId // ignore: cast_nullable_to_non_nullable
              as String,
      integrationId: null == integrationId
          ? _value.integrationId
          : integrationId // ignore: cast_nullable_to_non_nullable
              as String,
      eventType: null == eventType
          ? _value.eventType
          : eventType // ignore: cast_nullable_to_non_nullable
              as String,
      eventPath: freezed == eventPath
          ? _value.eventPath
          : eventPath // ignore: cast_nullable_to_non_nullable
              as String?,
      recordingSessionId: freezed == recordingSessionId
          ? _value.recordingSessionId
          : recordingSessionId // ignore: cast_nullable_to_non_nullable
              as String?,
      artifactKey: freezed == artifactKey
          ? _value.artifactKey
          : artifactKey // ignore: cast_nullable_to_non_nullable
              as String?,
      artifactPath: freezed == artifactPath
          ? _value.artifactPath
          : artifactPath // ignore: cast_nullable_to_non_nullable
              as String?,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as ExternalIntegrationDeliveryStatus,
      attempts: null == attempts
          ? _value.attempts
          : attempts // ignore: cast_nullable_to_non_nullable
              as int,
      lastError: freezed == lastError
          ? _value.lastError
          : lastError // ignore: cast_nullable_to_non_nullable
              as String?,
      lastResponseStatus: freezed == lastResponseStatus
          ? _value.lastResponseStatus
          : lastResponseStatus // ignore: cast_nullable_to_non_nullable
              as int?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      lastAttemptAt: freezed == lastAttemptAt
          ? _value.lastAttemptAt
          : lastAttemptAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      nextAttemptAt: freezed == nextAttemptAt
          ? _value.nextAttemptAt
          : nextAttemptAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      deliveredAt: freezed == deliveredAt
          ? _value.deliveredAt
          : deliveredAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_ExternalIntegrationDelivery implements _ExternalIntegrationDelivery {
  _$_ExternalIntegrationDelivery(
      {required this.id,
      required this.communityId,
      required this.eventId,
      required this.integrationId,
      required this.eventType,
      this.eventPath,
      this.recordingSessionId,
      this.artifactKey,
      this.artifactPath,
      @JsonKey(unknownEnumValue: ExternalIntegrationDeliveryStatus.pending)
      this.status = ExternalIntegrationDeliveryStatus.pending,
      this.attempts = 0,
      this.lastError,
      this.lastResponseStatus,
      @JsonKey(fromJson: dateTimeFromTimestamp, toJson: serverTimestampOrNull)
      this.createdAt,
      @JsonKey(fromJson: dateTimeFromTimestamp, toJson: serverTimestampOrNull)
      this.updatedAt,
      @JsonKey(fromJson: dateTimeFromTimestamp, toJson: serverTimestampOrNull)
      this.lastAttemptAt,
      @JsonKey(fromJson: dateTimeFromTimestamp, toJson: serverTimestampOrNull)
      this.nextAttemptAt,
      @JsonKey(fromJson: dateTimeFromTimestamp, toJson: serverTimestampOrNull)
      this.deliveredAt});

  factory _$_ExternalIntegrationDelivery.fromJson(Map<String, dynamic> json) =>
      _$$_ExternalIntegrationDeliveryFromJson(json);

  @override
  final String id;
  @override
  final String communityId;
  @override
  final String eventId;
  @override
  final String integrationId;
  @override
  final String eventType;
  @override
  final String? eventPath;
  @override
  final String? recordingSessionId;
  @override
  final String? artifactKey;
  @override
  final String? artifactPath;
  @override
  @JsonKey(unknownEnumValue: ExternalIntegrationDeliveryStatus.pending)
  final ExternalIntegrationDeliveryStatus status;
  @override
  @JsonKey()
  final int attempts;
  @override
  final String? lastError;
  @override
  final int? lastResponseStatus;
  @override
  @JsonKey(fromJson: dateTimeFromTimestamp, toJson: serverTimestampOrNull)
  final DateTime? createdAt;
  @override
  @JsonKey(fromJson: dateTimeFromTimestamp, toJson: serverTimestampOrNull)
  final DateTime? updatedAt;
  @override
  @JsonKey(fromJson: dateTimeFromTimestamp, toJson: serverTimestampOrNull)
  final DateTime? lastAttemptAt;
  @override
  @JsonKey(fromJson: dateTimeFromTimestamp, toJson: serverTimestampOrNull)
  final DateTime? nextAttemptAt;
  @override
  @JsonKey(fromJson: dateTimeFromTimestamp, toJson: serverTimestampOrNull)
  final DateTime? deliveredAt;

  @override
  String toString() {
    return 'ExternalIntegrationDelivery(id: $id, communityId: $communityId, eventId: $eventId, integrationId: $integrationId, eventType: $eventType, eventPath: $eventPath, recordingSessionId: $recordingSessionId, artifactKey: $artifactKey, artifactPath: $artifactPath, status: $status, attempts: $attempts, lastError: $lastError, lastResponseStatus: $lastResponseStatus, createdAt: $createdAt, updatedAt: $updatedAt, lastAttemptAt: $lastAttemptAt, nextAttemptAt: $nextAttemptAt, deliveredAt: $deliveredAt)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_ExternalIntegrationDelivery &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.communityId, communityId) ||
                other.communityId == communityId) &&
            (identical(other.eventId, eventId) || other.eventId == eventId) &&
            (identical(other.integrationId, integrationId) ||
                other.integrationId == integrationId) &&
            (identical(other.eventType, eventType) ||
                other.eventType == eventType) &&
            (identical(other.eventPath, eventPath) ||
                other.eventPath == eventPath) &&
            (identical(other.recordingSessionId, recordingSessionId) ||
                other.recordingSessionId == recordingSessionId) &&
            (identical(other.artifactKey, artifactKey) ||
                other.artifactKey == artifactKey) &&
            (identical(other.artifactPath, artifactPath) ||
                other.artifactPath == artifactPath) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.attempts, attempts) ||
                other.attempts == attempts) &&
            (identical(other.lastError, lastError) ||
                other.lastError == lastError) &&
            (identical(other.lastResponseStatus, lastResponseStatus) ||
                other.lastResponseStatus == lastResponseStatus) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.lastAttemptAt, lastAttemptAt) ||
                other.lastAttemptAt == lastAttemptAt) &&
            (identical(other.nextAttemptAt, nextAttemptAt) ||
                other.nextAttemptAt == nextAttemptAt) &&
            (identical(other.deliveredAt, deliveredAt) ||
                other.deliveredAt == deliveredAt));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      communityId,
      eventId,
      integrationId,
      eventType,
      eventPath,
      recordingSessionId,
      artifactKey,
      artifactPath,
      status,
      attempts,
      lastError,
      lastResponseStatus,
      createdAt,
      updatedAt,
      lastAttemptAt,
      nextAttemptAt,
      deliveredAt);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_ExternalIntegrationDeliveryCopyWith<_$_ExternalIntegrationDelivery>
      get copyWith => __$$_ExternalIntegrationDeliveryCopyWithImpl<
          _$_ExternalIntegrationDelivery>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_ExternalIntegrationDeliveryToJson(
      this,
    );
  }
}

abstract class _ExternalIntegrationDelivery
    implements ExternalIntegrationDelivery {
  factory _ExternalIntegrationDelivery(
      {required final String id,
      required final String communityId,
      required final String eventId,
      required final String integrationId,
      required final String eventType,
      final String? eventPath,
      final String? recordingSessionId,
      final String? artifactKey,
      final String? artifactPath,
      @JsonKey(unknownEnumValue: ExternalIntegrationDeliveryStatus.pending)
      final ExternalIntegrationDeliveryStatus status,
      final int attempts,
      final String? lastError,
      final int? lastResponseStatus,
      @JsonKey(fromJson: dateTimeFromTimestamp, toJson: serverTimestampOrNull)
      final DateTime? createdAt,
      @JsonKey(fromJson: dateTimeFromTimestamp, toJson: serverTimestampOrNull)
      final DateTime? updatedAt,
      @JsonKey(fromJson: dateTimeFromTimestamp, toJson: serverTimestampOrNull)
      final DateTime? lastAttemptAt,
      @JsonKey(fromJson: dateTimeFromTimestamp, toJson: serverTimestampOrNull)
      final DateTime? nextAttemptAt,
      @JsonKey(fromJson: dateTimeFromTimestamp, toJson: serverTimestampOrNull)
      final DateTime? deliveredAt}) = _$_ExternalIntegrationDelivery;

  factory _ExternalIntegrationDelivery.fromJson(Map<String, dynamic> json) =
      _$_ExternalIntegrationDelivery.fromJson;

  @override
  String get id;
  @override
  String get communityId;
  @override
  String get eventId;
  @override
  String get integrationId;
  @override
  String get eventType;
  @override
  String? get eventPath;
  @override
  String? get recordingSessionId;
  @override
  String? get artifactKey;
  @override
  String? get artifactPath;
  @override
  @JsonKey(unknownEnumValue: ExternalIntegrationDeliveryStatus.pending)
  ExternalIntegrationDeliveryStatus get status;
  @override
  int get attempts;
  @override
  String? get lastError;
  @override
  int? get lastResponseStatus;
  @override
  @JsonKey(fromJson: dateTimeFromTimestamp, toJson: serverTimestampOrNull)
  DateTime? get createdAt;
  @override
  @JsonKey(fromJson: dateTimeFromTimestamp, toJson: serverTimestampOrNull)
  DateTime? get updatedAt;
  @override
  @JsonKey(fromJson: dateTimeFromTimestamp, toJson: serverTimestampOrNull)
  DateTime? get lastAttemptAt;
  @override
  @JsonKey(fromJson: dateTimeFromTimestamp, toJson: serverTimestampOrNull)
  DateTime? get nextAttemptAt;
  @override
  @JsonKey(fromJson: dateTimeFromTimestamp, toJson: serverTimestampOrNull)
  DateTime? get deliveredAt;
  @override
  @JsonKey(ignore: true)
  _$$_ExternalIntegrationDeliveryCopyWith<_$_ExternalIntegrationDelivery>
      get copyWith => throw _privateConstructorUsedError;
}
