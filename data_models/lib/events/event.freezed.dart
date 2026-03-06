// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'event.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

Event _$EventFromJson(Map<String, dynamic> json) {
  return _Event.fromJson(json);
}

/// @nodoc
mixin _$Event {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(
      unknownEnumValue: EventStatus.active, defaultValue: EventStatus.active)
  EventStatus get status => throw _privateConstructorUsedError;

  /// Describes the type of event this is such as hosted or livestream.
  ///
  /// Some legacy evs do not have this field so it is nullable. Use the [eventType]
  /// getter below to determine which event type it is.
  @JsonKey(unknownEnumValue: null, name: 'eventType')
  EventType? get nullableEventType => throw _privateConstructorUsedError;
  String get collectionPath => throw _privateConstructorUsedError;
  String get communityId => throw _privateConstructorUsedError;
  String get templateId => throw _privateConstructorUsedError;
  String get creatorId => throw _privateConstructorUsedError;
  String? get prerequisiteTemplateId => throw _privateConstructorUsedError;
  String? get creatorDisplayName => throw _privateConstructorUsedError;
  @JsonKey(fromJson: dateTimeFromTimestamp, toJson: serverTimestamp)
  DateTime? get createdDate => throw _privateConstructorUsedError;
  @JsonKey(fromJson: dateTimeFromTimestamp, toJson: timestampFromDateTime)
  DateTime? get scheduledTime => throw _privateConstructorUsedError;
  String? get scheduledTimeZone => throw _privateConstructorUsedError;
  String? get title => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  String? get image => throw _privateConstructorUsedError;
  bool get isPublic => throw _privateConstructorUsedError;
  int? get minParticipants => throw _privateConstructorUsedError;
  int? get maxParticipants => throw _privateConstructorUsedError;
  List<AgendaItem> get agendaItems => throw _privateConstructorUsedError;
  WaitingRoomInfo? get waitingRoomInfo => throw _privateConstructorUsedError;
  @JsonKey(fromJson: BreakoutRoomDefinition.fromJsonMigration)
  BreakoutRoomDefinition? get breakoutRoomDefinition =>
      throw _privateConstructorUsedError;
  bool get isLocked => throw _privateConstructorUsedError;
  LiveStreamInfo? get liveStreamInfo => throw _privateConstructorUsedError;
  PrePostCard? get preEventCardData => throw _privateConstructorUsedError;
  PrePostCard? get postEventCardData => throw _privateConstructorUsedError;
  PlatformItem? get externalPlatform => throw _privateConstructorUsedError;
  EventSettings? get eventSettings => throw _privateConstructorUsedError;
  int get durationInMinutes => throw _privateConstructorUsedError;

  /// ID used to tie meetings back to external communities
  String? get externalCommunityId => throw _privateConstructorUsedError;

  /// Status that is only means something on a per-community basis.
  /// Ex: Community determines if the meeting is cancelled due to
  /// no-show or not.
  /// Leaving as a string, not enum, to allow more flexibility for each
  /// community.
  String? get externalCommunityStatus => throw _privateConstructorUsedError;

  /// For large events we compute the number of participants every x number
  /// of seconds and update this field due to large numbers of people
  int? get participantCountEstimate => throw _privateConstructorUsedError;
  int? get presentParticipantCountEstimate =>
      throw _privateConstructorUsedError;

  /// Temporary hacky solution to allow us to specify that some breakout rooms that were matched
  /// using match IDs should be recorded.
  dynamic get breakoutMatchIdsToRecord => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $EventCopyWith<Event> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $EventCopyWith<$Res> {
  factory $EventCopyWith(Event value, $Res Function(Event) then) =
      _$EventCopyWithImpl<$Res, Event>;
  @useResult
  $Res call(
      {String id,
      @JsonKey(
          unknownEnumValue: EventStatus.active,
          defaultValue: EventStatus.active)
      EventStatus status,
      @JsonKey(unknownEnumValue: null, name: 'eventType')
      EventType? nullableEventType,
      String collectionPath,
      String communityId,
      String templateId,
      String creatorId,
      String? prerequisiteTemplateId,
      String? creatorDisplayName,
      @JsonKey(fromJson: dateTimeFromTimestamp, toJson: serverTimestamp)
      DateTime? createdDate,
      @JsonKey(fromJson: dateTimeFromTimestamp, toJson: timestampFromDateTime)
      DateTime? scheduledTime,
      String? scheduledTimeZone,
      String? title,
      String? description,
      String? image,
      bool isPublic,
      int? minParticipants,
      int? maxParticipants,
      List<AgendaItem> agendaItems,
      WaitingRoomInfo? waitingRoomInfo,
      @JsonKey(fromJson: BreakoutRoomDefinition.fromJsonMigration)
      BreakoutRoomDefinition? breakoutRoomDefinition,
      bool isLocked,
      LiveStreamInfo? liveStreamInfo,
      PrePostCard? preEventCardData,
      PrePostCard? postEventCardData,
      PlatformItem? externalPlatform,
      EventSettings? eventSettings,
      int durationInMinutes,
      String? externalCommunityId,
      String? externalCommunityStatus,
      int? participantCountEstimate,
      int? presentParticipantCountEstimate,
      dynamic breakoutMatchIdsToRecord});

  $WaitingRoomInfoCopyWith<$Res>? get waitingRoomInfo;
  $BreakoutRoomDefinitionCopyWith<$Res>? get breakoutRoomDefinition;
  $LiveStreamInfoCopyWith<$Res>? get liveStreamInfo;
  $PrePostCardCopyWith<$Res>? get preEventCardData;
  $PrePostCardCopyWith<$Res>? get postEventCardData;
  $PlatformItemCopyWith<$Res>? get externalPlatform;
  $EventSettingsCopyWith<$Res>? get eventSettings;
}

/// @nodoc
class _$EventCopyWithImpl<$Res, $Val extends Event>
    implements $EventCopyWith<$Res> {
  _$EventCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? status = null,
    Object? nullableEventType = freezed,
    Object? collectionPath = null,
    Object? communityId = null,
    Object? templateId = null,
    Object? creatorId = null,
    Object? prerequisiteTemplateId = freezed,
    Object? creatorDisplayName = freezed,
    Object? createdDate = freezed,
    Object? scheduledTime = freezed,
    Object? scheduledTimeZone = freezed,
    Object? title = freezed,
    Object? description = freezed,
    Object? image = freezed,
    Object? isPublic = null,
    Object? minParticipants = freezed,
    Object? maxParticipants = freezed,
    Object? agendaItems = null,
    Object? waitingRoomInfo = freezed,
    Object? breakoutRoomDefinition = freezed,
    Object? isLocked = null,
    Object? liveStreamInfo = freezed,
    Object? preEventCardData = freezed,
    Object? postEventCardData = freezed,
    Object? externalPlatform = freezed,
    Object? eventSettings = freezed,
    Object? durationInMinutes = null,
    Object? externalCommunityId = freezed,
    Object? externalCommunityStatus = freezed,
    Object? participantCountEstimate = freezed,
    Object? presentParticipantCountEstimate = freezed,
    Object? breakoutMatchIdsToRecord = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as EventStatus,
      nullableEventType: freezed == nullableEventType
          ? _value.nullableEventType
          : nullableEventType // ignore: cast_nullable_to_non_nullable
              as EventType?,
      collectionPath: null == collectionPath
          ? _value.collectionPath
          : collectionPath // ignore: cast_nullable_to_non_nullable
              as String,
      communityId: null == communityId
          ? _value.communityId
          : communityId // ignore: cast_nullable_to_non_nullable
              as String,
      templateId: null == templateId
          ? _value.templateId
          : templateId // ignore: cast_nullable_to_non_nullable
              as String,
      creatorId: null == creatorId
          ? _value.creatorId
          : creatorId // ignore: cast_nullable_to_non_nullable
              as String,
      prerequisiteTemplateId: freezed == prerequisiteTemplateId
          ? _value.prerequisiteTemplateId
          : prerequisiteTemplateId // ignore: cast_nullable_to_non_nullable
              as String?,
      creatorDisplayName: freezed == creatorDisplayName
          ? _value.creatorDisplayName
          : creatorDisplayName // ignore: cast_nullable_to_non_nullable
              as String?,
      createdDate: freezed == createdDate
          ? _value.createdDate
          : createdDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      scheduledTime: freezed == scheduledTime
          ? _value.scheduledTime
          : scheduledTime // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      scheduledTimeZone: freezed == scheduledTimeZone
          ? _value.scheduledTimeZone
          : scheduledTimeZone // ignore: cast_nullable_to_non_nullable
              as String?,
      title: freezed == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String?,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      image: freezed == image
          ? _value.image
          : image // ignore: cast_nullable_to_non_nullable
              as String?,
      isPublic: null == isPublic
          ? _value.isPublic
          : isPublic // ignore: cast_nullable_to_non_nullable
              as bool,
      minParticipants: freezed == minParticipants
          ? _value.minParticipants
          : minParticipants // ignore: cast_nullable_to_non_nullable
              as int?,
      maxParticipants: freezed == maxParticipants
          ? _value.maxParticipants
          : maxParticipants // ignore: cast_nullable_to_non_nullable
              as int?,
      agendaItems: null == agendaItems
          ? _value.agendaItems
          : agendaItems // ignore: cast_nullable_to_non_nullable
              as List<AgendaItem>,
      waitingRoomInfo: freezed == waitingRoomInfo
          ? _value.waitingRoomInfo
          : waitingRoomInfo // ignore: cast_nullable_to_non_nullable
              as WaitingRoomInfo?,
      breakoutRoomDefinition: freezed == breakoutRoomDefinition
          ? _value.breakoutRoomDefinition
          : breakoutRoomDefinition // ignore: cast_nullable_to_non_nullable
              as BreakoutRoomDefinition?,
      isLocked: null == isLocked
          ? _value.isLocked
          : isLocked // ignore: cast_nullable_to_non_nullable
              as bool,
      liveStreamInfo: freezed == liveStreamInfo
          ? _value.liveStreamInfo
          : liveStreamInfo // ignore: cast_nullable_to_non_nullable
              as LiveStreamInfo?,
      preEventCardData: freezed == preEventCardData
          ? _value.preEventCardData
          : preEventCardData // ignore: cast_nullable_to_non_nullable
              as PrePostCard?,
      postEventCardData: freezed == postEventCardData
          ? _value.postEventCardData
          : postEventCardData // ignore: cast_nullable_to_non_nullable
              as PrePostCard?,
      externalPlatform: freezed == externalPlatform
          ? _value.externalPlatform
          : externalPlatform // ignore: cast_nullable_to_non_nullable
              as PlatformItem?,
      eventSettings: freezed == eventSettings
          ? _value.eventSettings
          : eventSettings // ignore: cast_nullable_to_non_nullable
              as EventSettings?,
      durationInMinutes: null == durationInMinutes
          ? _value.durationInMinutes
          : durationInMinutes // ignore: cast_nullable_to_non_nullable
              as int,
      externalCommunityId: freezed == externalCommunityId
          ? _value.externalCommunityId
          : externalCommunityId // ignore: cast_nullable_to_non_nullable
              as String?,
      externalCommunityStatus: freezed == externalCommunityStatus
          ? _value.externalCommunityStatus
          : externalCommunityStatus // ignore: cast_nullable_to_non_nullable
              as String?,
      participantCountEstimate: freezed == participantCountEstimate
          ? _value.participantCountEstimate
          : participantCountEstimate // ignore: cast_nullable_to_non_nullable
              as int?,
      presentParticipantCountEstimate: freezed ==
              presentParticipantCountEstimate
          ? _value.presentParticipantCountEstimate
          : presentParticipantCountEstimate // ignore: cast_nullable_to_non_nullable
              as int?,
      breakoutMatchIdsToRecord: freezed == breakoutMatchIdsToRecord
          ? _value.breakoutMatchIdsToRecord
          : breakoutMatchIdsToRecord // ignore: cast_nullable_to_non_nullable
              as dynamic,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $WaitingRoomInfoCopyWith<$Res>? get waitingRoomInfo {
    if (_value.waitingRoomInfo == null) {
      return null;
    }

    return $WaitingRoomInfoCopyWith<$Res>(_value.waitingRoomInfo!, (value) {
      return _then(_value.copyWith(waitingRoomInfo: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $BreakoutRoomDefinitionCopyWith<$Res>? get breakoutRoomDefinition {
    if (_value.breakoutRoomDefinition == null) {
      return null;
    }

    return $BreakoutRoomDefinitionCopyWith<$Res>(_value.breakoutRoomDefinition!,
        (value) {
      return _then(_value.copyWith(breakoutRoomDefinition: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $LiveStreamInfoCopyWith<$Res>? get liveStreamInfo {
    if (_value.liveStreamInfo == null) {
      return null;
    }

    return $LiveStreamInfoCopyWith<$Res>(_value.liveStreamInfo!, (value) {
      return _then(_value.copyWith(liveStreamInfo: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $PrePostCardCopyWith<$Res>? get preEventCardData {
    if (_value.preEventCardData == null) {
      return null;
    }

    return $PrePostCardCopyWith<$Res>(_value.preEventCardData!, (value) {
      return _then(_value.copyWith(preEventCardData: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $PrePostCardCopyWith<$Res>? get postEventCardData {
    if (_value.postEventCardData == null) {
      return null;
    }

    return $PrePostCardCopyWith<$Res>(_value.postEventCardData!, (value) {
      return _then(_value.copyWith(postEventCardData: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $PlatformItemCopyWith<$Res>? get externalPlatform {
    if (_value.externalPlatform == null) {
      return null;
    }

    return $PlatformItemCopyWith<$Res>(_value.externalPlatform!, (value) {
      return _then(_value.copyWith(externalPlatform: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $EventSettingsCopyWith<$Res>? get eventSettings {
    if (_value.eventSettings == null) {
      return null;
    }

    return $EventSettingsCopyWith<$Res>(_value.eventSettings!, (value) {
      return _then(_value.copyWith(eventSettings: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$_EventCopyWith<$Res> implements $EventCopyWith<$Res> {
  factory _$$_EventCopyWith(_$_Event value, $Res Function(_$_Event) then) =
      __$$_EventCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      @JsonKey(
          unknownEnumValue: EventStatus.active,
          defaultValue: EventStatus.active)
      EventStatus status,
      @JsonKey(unknownEnumValue: null, name: 'eventType')
      EventType? nullableEventType,
      String collectionPath,
      String communityId,
      String templateId,
      String creatorId,
      String? prerequisiteTemplateId,
      String? creatorDisplayName,
      @JsonKey(fromJson: dateTimeFromTimestamp, toJson: serverTimestamp)
      DateTime? createdDate,
      @JsonKey(fromJson: dateTimeFromTimestamp, toJson: timestampFromDateTime)
      DateTime? scheduledTime,
      String? scheduledTimeZone,
      String? title,
      String? description,
      String? image,
      bool isPublic,
      int? minParticipants,
      int? maxParticipants,
      List<AgendaItem> agendaItems,
      WaitingRoomInfo? waitingRoomInfo,
      @JsonKey(fromJson: BreakoutRoomDefinition.fromJsonMigration)
      BreakoutRoomDefinition? breakoutRoomDefinition,
      bool isLocked,
      LiveStreamInfo? liveStreamInfo,
      PrePostCard? preEventCardData,
      PrePostCard? postEventCardData,
      PlatformItem? externalPlatform,
      EventSettings? eventSettings,
      int durationInMinutes,
      String? externalCommunityId,
      String? externalCommunityStatus,
      int? participantCountEstimate,
      int? presentParticipantCountEstimate,
      dynamic breakoutMatchIdsToRecord});

  @override
  $WaitingRoomInfoCopyWith<$Res>? get waitingRoomInfo;
  @override
  $BreakoutRoomDefinitionCopyWith<$Res>? get breakoutRoomDefinition;
  @override
  $LiveStreamInfoCopyWith<$Res>? get liveStreamInfo;
  @override
  $PrePostCardCopyWith<$Res>? get preEventCardData;
  @override
  $PrePostCardCopyWith<$Res>? get postEventCardData;
  @override
  $PlatformItemCopyWith<$Res>? get externalPlatform;
  @override
  $EventSettingsCopyWith<$Res>? get eventSettings;
}

/// @nodoc
class __$$_EventCopyWithImpl<$Res> extends _$EventCopyWithImpl<$Res, _$_Event>
    implements _$$_EventCopyWith<$Res> {
  __$$_EventCopyWithImpl(_$_Event _value, $Res Function(_$_Event) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? status = null,
    Object? nullableEventType = freezed,
    Object? collectionPath = null,
    Object? communityId = null,
    Object? templateId = null,
    Object? creatorId = null,
    Object? prerequisiteTemplateId = freezed,
    Object? creatorDisplayName = freezed,
    Object? createdDate = freezed,
    Object? scheduledTime = freezed,
    Object? scheduledTimeZone = freezed,
    Object? title = freezed,
    Object? description = freezed,
    Object? image = freezed,
    Object? isPublic = null,
    Object? minParticipants = freezed,
    Object? maxParticipants = freezed,
    Object? agendaItems = null,
    Object? waitingRoomInfo = freezed,
    Object? breakoutRoomDefinition = freezed,
    Object? isLocked = null,
    Object? liveStreamInfo = freezed,
    Object? preEventCardData = freezed,
    Object? postEventCardData = freezed,
    Object? externalPlatform = freezed,
    Object? eventSettings = freezed,
    Object? durationInMinutes = null,
    Object? externalCommunityId = freezed,
    Object? externalCommunityStatus = freezed,
    Object? participantCountEstimate = freezed,
    Object? presentParticipantCountEstimate = freezed,
    Object? breakoutMatchIdsToRecord = freezed,
  }) {
    return _then(_$_Event(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as EventStatus,
      nullableEventType: freezed == nullableEventType
          ? _value.nullableEventType
          : nullableEventType // ignore: cast_nullable_to_non_nullable
              as EventType?,
      collectionPath: null == collectionPath
          ? _value.collectionPath
          : collectionPath // ignore: cast_nullable_to_non_nullable
              as String,
      communityId: null == communityId
          ? _value.communityId
          : communityId // ignore: cast_nullable_to_non_nullable
              as String,
      templateId: null == templateId
          ? _value.templateId
          : templateId // ignore: cast_nullable_to_non_nullable
              as String,
      creatorId: null == creatorId
          ? _value.creatorId
          : creatorId // ignore: cast_nullable_to_non_nullable
              as String,
      prerequisiteTemplateId: freezed == prerequisiteTemplateId
          ? _value.prerequisiteTemplateId
          : prerequisiteTemplateId // ignore: cast_nullable_to_non_nullable
              as String?,
      creatorDisplayName: freezed == creatorDisplayName
          ? _value.creatorDisplayName
          : creatorDisplayName // ignore: cast_nullable_to_non_nullable
              as String?,
      createdDate: freezed == createdDate
          ? _value.createdDate
          : createdDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      scheduledTime: freezed == scheduledTime
          ? _value.scheduledTime
          : scheduledTime // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      scheduledTimeZone: freezed == scheduledTimeZone
          ? _value.scheduledTimeZone
          : scheduledTimeZone // ignore: cast_nullable_to_non_nullable
              as String?,
      title: freezed == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String?,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      image: freezed == image
          ? _value.image
          : image // ignore: cast_nullable_to_non_nullable
              as String?,
      isPublic: null == isPublic
          ? _value.isPublic
          : isPublic // ignore: cast_nullable_to_non_nullable
              as bool,
      minParticipants: freezed == minParticipants
          ? _value.minParticipants
          : minParticipants // ignore: cast_nullable_to_non_nullable
              as int?,
      maxParticipants: freezed == maxParticipants
          ? _value.maxParticipants
          : maxParticipants // ignore: cast_nullable_to_non_nullable
              as int?,
      agendaItems: null == agendaItems
          ? _value.agendaItems
          : agendaItems // ignore: cast_nullable_to_non_nullable
              as List<AgendaItem>,
      waitingRoomInfo: freezed == waitingRoomInfo
          ? _value.waitingRoomInfo
          : waitingRoomInfo // ignore: cast_nullable_to_non_nullable
              as WaitingRoomInfo?,
      breakoutRoomDefinition: freezed == breakoutRoomDefinition
          ? _value.breakoutRoomDefinition
          : breakoutRoomDefinition // ignore: cast_nullable_to_non_nullable
              as BreakoutRoomDefinition?,
      isLocked: null == isLocked
          ? _value.isLocked
          : isLocked // ignore: cast_nullable_to_non_nullable
              as bool,
      liveStreamInfo: freezed == liveStreamInfo
          ? _value.liveStreamInfo
          : liveStreamInfo // ignore: cast_nullable_to_non_nullable
              as LiveStreamInfo?,
      preEventCardData: freezed == preEventCardData
          ? _value.preEventCardData
          : preEventCardData // ignore: cast_nullable_to_non_nullable
              as PrePostCard?,
      postEventCardData: freezed == postEventCardData
          ? _value.postEventCardData
          : postEventCardData // ignore: cast_nullable_to_non_nullable
              as PrePostCard?,
      externalPlatform: freezed == externalPlatform
          ? _value.externalPlatform
          : externalPlatform // ignore: cast_nullable_to_non_nullable
              as PlatformItem?,
      eventSettings: freezed == eventSettings
          ? _value.eventSettings
          : eventSettings // ignore: cast_nullable_to_non_nullable
              as EventSettings?,
      durationInMinutes: null == durationInMinutes
          ? _value.durationInMinutes
          : durationInMinutes // ignore: cast_nullable_to_non_nullable
              as int,
      externalCommunityId: freezed == externalCommunityId
          ? _value.externalCommunityId
          : externalCommunityId // ignore: cast_nullable_to_non_nullable
              as String?,
      externalCommunityStatus: freezed == externalCommunityStatus
          ? _value.externalCommunityStatus
          : externalCommunityStatus // ignore: cast_nullable_to_non_nullable
              as String?,
      participantCountEstimate: freezed == participantCountEstimate
          ? _value.participantCountEstimate
          : participantCountEstimate // ignore: cast_nullable_to_non_nullable
              as int?,
      presentParticipantCountEstimate: freezed ==
              presentParticipantCountEstimate
          ? _value.presentParticipantCountEstimate
          : presentParticipantCountEstimate // ignore: cast_nullable_to_non_nullable
              as int?,
      breakoutMatchIdsToRecord: freezed == breakoutMatchIdsToRecord
          ? _value.breakoutMatchIdsToRecord!
          : breakoutMatchIdsToRecord,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_Event extends _Event {
  _$_Event(
      {required this.id,
      @JsonKey(
          unknownEnumValue: EventStatus.active,
          defaultValue: EventStatus.active)
      required this.status,
      @JsonKey(unknownEnumValue: null, name: 'eventType')
      this.nullableEventType,
      required this.collectionPath,
      required this.communityId,
      required this.templateId,
      required this.creatorId,
      this.prerequisiteTemplateId,
      this.creatorDisplayName,
      @JsonKey(fromJson: dateTimeFromTimestamp, toJson: serverTimestamp)
      this.createdDate,
      @JsonKey(fromJson: dateTimeFromTimestamp, toJson: timestampFromDateTime)
      this.scheduledTime,
      this.scheduledTimeZone,
      this.title,
      this.description,
      this.image,
      this.isPublic = false,
      this.minParticipants,
      this.maxParticipants,
      this.agendaItems = const [],
      this.waitingRoomInfo,
      @JsonKey(fromJson: BreakoutRoomDefinition.fromJsonMigration)
      this.breakoutRoomDefinition,
      this.isLocked = false,
      this.liveStreamInfo,
      this.preEventCardData,
      this.postEventCardData,
      this.externalPlatform,
      this.eventSettings,
      this.durationInMinutes = 60,
      this.externalCommunityId,
      this.externalCommunityStatus,
      this.participantCountEstimate,
      this.presentParticipantCountEstimate,
      this.breakoutMatchIdsToRecord = const []})
      : super._();

  factory _$_Event.fromJson(Map<String, dynamic> json) =>
      _$$_EventFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(
      unknownEnumValue: EventStatus.active, defaultValue: EventStatus.active)
  final EventStatus status;

  /// Describes the type of event this is such as hosted or livestream.
  ///
  /// Some legacy evs do not have this field so it is nullable. Use the [eventType]
  /// getter below to determine which event type it is.
  @override
  @JsonKey(unknownEnumValue: null, name: 'eventType')
  final EventType? nullableEventType;
  @override
  final String collectionPath;
  @override
  final String communityId;
  @override
  final String templateId;
  @override
  final String creatorId;
  @override
  final String? prerequisiteTemplateId;
  @override
  final String? creatorDisplayName;
  @override
  @JsonKey(fromJson: dateTimeFromTimestamp, toJson: serverTimestamp)
  final DateTime? createdDate;
  @override
  @JsonKey(fromJson: dateTimeFromTimestamp, toJson: timestampFromDateTime)
  final DateTime? scheduledTime;
  @override
  final String? scheduledTimeZone;
  @override
  final String? title;
  @override
  final String? description;
  @override
  final String? image;
  @override
  @JsonKey()
  final bool isPublic;
  @override
  final int? minParticipants;
  @override
  final int? maxParticipants;
  @override
  @JsonKey()
  final List<AgendaItem> agendaItems;
  @override
  final WaitingRoomInfo? waitingRoomInfo;
  @override
  @JsonKey(fromJson: BreakoutRoomDefinition.fromJsonMigration)
  final BreakoutRoomDefinition? breakoutRoomDefinition;
  @override
  @JsonKey()
  final bool isLocked;
  @override
  final LiveStreamInfo? liveStreamInfo;
  @override
  final PrePostCard? preEventCardData;
  @override
  final PrePostCard? postEventCardData;
  @override
  final PlatformItem? externalPlatform;
  @override
  final EventSettings? eventSettings;
  @override
  @JsonKey()
  final int durationInMinutes;

  /// ID used to tie meetings back to external communities
  @override
  final String? externalCommunityId;

  /// Status that is only means something on a per-community basis.
  /// Ex: Community determines if the meeting is cancelled due to
  /// no-show or not.
  /// Leaving as a string, not enum, to allow more flexibility for each
  /// community.
  @override
  final String? externalCommunityStatus;

  /// For large events we compute the number of participants every x number
  /// of seconds and update this field due to large numbers of people
  @override
  final int? participantCountEstimate;
  @override
  final int? presentParticipantCountEstimate;

  /// Temporary hacky solution to allow us to specify that some breakout rooms that were matched
  /// using match IDs should be recorded.
  @override
  @JsonKey()
  final dynamic breakoutMatchIdsToRecord;

  @override
  String toString() {
    return 'Event(id: $id, status: $status, nullableEventType: $nullableEventType, collectionPath: $collectionPath, communityId: $communityId, templateId: $templateId, creatorId: $creatorId, prerequisiteTemplateId: $prerequisiteTemplateId, creatorDisplayName: $creatorDisplayName, createdDate: $createdDate, scheduledTime: $scheduledTime, scheduledTimeZone: $scheduledTimeZone, title: $title, description: $description, image: $image, isPublic: $isPublic, minParticipants: $minParticipants, maxParticipants: $maxParticipants, agendaItems: $agendaItems, waitingRoomInfo: $waitingRoomInfo, breakoutRoomDefinition: $breakoutRoomDefinition, isLocked: $isLocked, liveStreamInfo: $liveStreamInfo, preEventCardData: $preEventCardData, postEventCardData: $postEventCardData, externalPlatform: $externalPlatform, eventSettings: $eventSettings, durationInMinutes: $durationInMinutes, externalCommunityId: $externalCommunityId, externalCommunityStatus: $externalCommunityStatus, participantCountEstimate: $participantCountEstimate, presentParticipantCountEstimate: $presentParticipantCountEstimate, breakoutMatchIdsToRecord: $breakoutMatchIdsToRecord)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_Event &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.nullableEventType, nullableEventType) ||
                other.nullableEventType == nullableEventType) &&
            (identical(other.collectionPath, collectionPath) ||
                other.collectionPath == collectionPath) &&
            (identical(other.communityId, communityId) ||
                other.communityId == communityId) &&
            (identical(other.templateId, templateId) ||
                other.templateId == templateId) &&
            (identical(other.creatorId, creatorId) ||
                other.creatorId == creatorId) &&
            (identical(other.prerequisiteTemplateId, prerequisiteTemplateId) ||
                other.prerequisiteTemplateId == prerequisiteTemplateId) &&
            (identical(other.creatorDisplayName, creatorDisplayName) ||
                other.creatorDisplayName == creatorDisplayName) &&
            (identical(other.createdDate, createdDate) ||
                other.createdDate == createdDate) &&
            (identical(other.scheduledTime, scheduledTime) ||
                other.scheduledTime == scheduledTime) &&
            (identical(other.scheduledTimeZone, scheduledTimeZone) ||
                other.scheduledTimeZone == scheduledTimeZone) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.image, image) || other.image == image) &&
            (identical(other.isPublic, isPublic) ||
                other.isPublic == isPublic) &&
            (identical(other.minParticipants, minParticipants) ||
                other.minParticipants == minParticipants) &&
            (identical(other.maxParticipants, maxParticipants) ||
                other.maxParticipants == maxParticipants) &&
            const DeepCollectionEquality()
                .equals(other.agendaItems, agendaItems) &&
            (identical(other.waitingRoomInfo, waitingRoomInfo) ||
                other.waitingRoomInfo == waitingRoomInfo) &&
            (identical(other.breakoutRoomDefinition, breakoutRoomDefinition) ||
                other.breakoutRoomDefinition == breakoutRoomDefinition) &&
            (identical(other.isLocked, isLocked) ||
                other.isLocked == isLocked) &&
            (identical(other.liveStreamInfo, liveStreamInfo) ||
                other.liveStreamInfo == liveStreamInfo) &&
            (identical(other.preEventCardData, preEventCardData) ||
                other.preEventCardData == preEventCardData) &&
            (identical(other.postEventCardData, postEventCardData) ||
                other.postEventCardData == postEventCardData) &&
            (identical(other.externalPlatform, externalPlatform) ||
                other.externalPlatform == externalPlatform) &&
            (identical(other.eventSettings, eventSettings) ||
                other.eventSettings == eventSettings) &&
            (identical(other.durationInMinutes, durationInMinutes) ||
                other.durationInMinutes == durationInMinutes) &&
            (identical(other.externalCommunityId, externalCommunityId) ||
                other.externalCommunityId == externalCommunityId) &&
            (identical(
                    other.externalCommunityStatus, externalCommunityStatus) ||
                other.externalCommunityStatus == externalCommunityStatus) &&
            (identical(
                    other.participantCountEstimate, participantCountEstimate) ||
                other.participantCountEstimate == participantCountEstimate) &&
            (identical(other.presentParticipantCountEstimate,
                    presentParticipantCountEstimate) ||
                other.presentParticipantCountEstimate ==
                    presentParticipantCountEstimate) &&
            const DeepCollectionEquality().equals(
                other.breakoutMatchIdsToRecord, breakoutMatchIdsToRecord));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        id,
        status,
        nullableEventType,
        collectionPath,
        communityId,
        templateId,
        creatorId,
        prerequisiteTemplateId,
        creatorDisplayName,
        createdDate,
        scheduledTime,
        scheduledTimeZone,
        title,
        description,
        image,
        isPublic,
        minParticipants,
        maxParticipants,
        const DeepCollectionEquality().hash(agendaItems),
        waitingRoomInfo,
        breakoutRoomDefinition,
        isLocked,
        liveStreamInfo,
        preEventCardData,
        postEventCardData,
        externalPlatform,
        eventSettings,
        durationInMinutes,
        externalCommunityId,
        externalCommunityStatus,
        participantCountEstimate,
        presentParticipantCountEstimate,
        const DeepCollectionEquality().hash(breakoutMatchIdsToRecord)
      ]);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_EventCopyWith<_$_Event> get copyWith =>
      __$$_EventCopyWithImpl<_$_Event>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_EventToJson(
      this,
    );
  }
}

abstract class _Event extends Event {
  factory _Event(
      {required final String id,
      @JsonKey(
          unknownEnumValue: EventStatus.active,
          defaultValue: EventStatus.active)
      required final EventStatus status,
      @JsonKey(unknownEnumValue: null, name: 'eventType')
      final EventType? nullableEventType,
      required final String collectionPath,
      required final String communityId,
      required final String templateId,
      required final String creatorId,
      final String? prerequisiteTemplateId,
      final String? creatorDisplayName,
      @JsonKey(fromJson: dateTimeFromTimestamp, toJson: serverTimestamp)
      final DateTime? createdDate,
      @JsonKey(fromJson: dateTimeFromTimestamp, toJson: timestampFromDateTime)
      final DateTime? scheduledTime,
      final String? scheduledTimeZone,
      final String? title,
      final String? description,
      final String? image,
      final bool isPublic,
      final int? minParticipants,
      final int? maxParticipants,
      final List<AgendaItem> agendaItems,
      final WaitingRoomInfo? waitingRoomInfo,
      @JsonKey(fromJson: BreakoutRoomDefinition.fromJsonMigration)
      final BreakoutRoomDefinition? breakoutRoomDefinition,
      final bool isLocked,
      final LiveStreamInfo? liveStreamInfo,
      final PrePostCard? preEventCardData,
      final PrePostCard? postEventCardData,
      final PlatformItem? externalPlatform,
      final EventSettings? eventSettings,
      final int durationInMinutes,
      final String? externalCommunityId,
      final String? externalCommunityStatus,
      final int? participantCountEstimate,
      final int? presentParticipantCountEstimate,
      final dynamic breakoutMatchIdsToRecord}) = _$_Event;
  _Event._() : super._();

  factory _Event.fromJson(Map<String, dynamic> json) = _$_Event.fromJson;

  @override
  String get id;
  @override
  @JsonKey(
      unknownEnumValue: EventStatus.active, defaultValue: EventStatus.active)
  EventStatus get status;
  @override

  /// Describes the type of event this is such as hosted or livestream.
  ///
  /// Some legacy evs do not have this field so it is nullable. Use the [eventType]
  /// getter below to determine which event type it is.
  @JsonKey(unknownEnumValue: null, name: 'eventType')
  EventType? get nullableEventType;
  @override
  String get collectionPath;
  @override
  String get communityId;
  @override
  String get templateId;
  @override
  String get creatorId;
  @override
  String? get prerequisiteTemplateId;
  @override
  String? get creatorDisplayName;
  @override
  @JsonKey(fromJson: dateTimeFromTimestamp, toJson: serverTimestamp)
  DateTime? get createdDate;
  @override
  @JsonKey(fromJson: dateTimeFromTimestamp, toJson: timestampFromDateTime)
  DateTime? get scheduledTime;
  @override
  String? get scheduledTimeZone;
  @override
  String? get title;
  @override
  String? get description;
  @override
  String? get image;
  @override
  bool get isPublic;
  @override
  int? get minParticipants;
  @override
  int? get maxParticipants;
  @override
  List<AgendaItem> get agendaItems;
  @override
  WaitingRoomInfo? get waitingRoomInfo;
  @override
  @JsonKey(fromJson: BreakoutRoomDefinition.fromJsonMigration)
  BreakoutRoomDefinition? get breakoutRoomDefinition;
  @override
  bool get isLocked;
  @override
  LiveStreamInfo? get liveStreamInfo;
  @override
  PrePostCard? get preEventCardData;
  @override
  PrePostCard? get postEventCardData;
  @override
  PlatformItem? get externalPlatform;
  @override
  EventSettings? get eventSettings;
  @override
  int get durationInMinutes;
  @override

  /// ID used to tie meetings back to external communities
  String? get externalCommunityId;
  @override

  /// Status that is only means something on a per-community basis.
  /// Ex: Community determines if the meeting is cancelled due to
  /// no-show or not.
  /// Leaving as a string, not enum, to allow more flexibility for each
  /// community.
  String? get externalCommunityStatus;
  @override

  /// For large events we compute the number of participants every x number
  /// of seconds and update this field due to large numbers of people
  int? get participantCountEstimate;
  @override
  int? get presentParticipantCountEstimate;
  @override

  /// Temporary hacky solution to allow us to specify that some breakout rooms that were matched
  /// using match IDs should be recorded.
  dynamic get breakoutMatchIdsToRecord;
  @override
  @JsonKey(ignore: true)
  _$$_EventCopyWith<_$_Event> get copyWith =>
      throw _privateConstructorUsedError;
}

EventSettings _$EventSettingsFromJson(Map<String, dynamic> json) {
  return _EventSettings.fromJson(json);
}

/// @nodoc
mixin _$EventSettings {
  bool? get reminderEmails => throw _privateConstructorUsedError;
  bool? get chat => throw _privateConstructorUsedError;
  bool? get showChatMessagesInRealTime => throw _privateConstructorUsedError;
  bool? get talkingTimer =>
      throw _privateConstructorUsedError; // Reenable if screensharing is implemented
//bool? allowScreenshare,
  bool? get allowPredefineBreakoutsOnHosted =>
      throw _privateConstructorUsedError;
  bool? get defaultStageView => throw _privateConstructorUsedError;
  bool? get enableBreakoutsByCategory => throw _privateConstructorUsedError;
  bool? get allowMultiplePeopleOnStage => throw _privateConstructorUsedError;
  bool? get showSmartMatchingForBreakouts => throw _privateConstructorUsedError;
  bool? get alwaysRecord => throw _privateConstructorUsedError;
  bool? get enablePrerequisites => throw _privateConstructorUsedError;
  bool? get agendaPreview => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $EventSettingsCopyWith<EventSettings> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $EventSettingsCopyWith<$Res> {
  factory $EventSettingsCopyWith(
          EventSettings value, $Res Function(EventSettings) then) =
      _$EventSettingsCopyWithImpl<$Res, EventSettings>;
  @useResult
  $Res call(
      {bool? reminderEmails,
      bool? chat,
      bool? showChatMessagesInRealTime,
      bool? talkingTimer,
      bool? allowPredefineBreakoutsOnHosted,
      bool? defaultStageView,
      bool? enableBreakoutsByCategory,
      bool? allowMultiplePeopleOnStage,
      bool? showSmartMatchingForBreakouts,
      bool? alwaysRecord,
      bool? enablePrerequisites,
      bool? agendaPreview});
}

/// @nodoc
class _$EventSettingsCopyWithImpl<$Res, $Val extends EventSettings>
    implements $EventSettingsCopyWith<$Res> {
  _$EventSettingsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? reminderEmails = freezed,
    Object? chat = freezed,
    Object? showChatMessagesInRealTime = freezed,
    Object? talkingTimer = freezed,
    Object? allowPredefineBreakoutsOnHosted = freezed,
    Object? defaultStageView = freezed,
    Object? enableBreakoutsByCategory = freezed,
    Object? allowMultiplePeopleOnStage = freezed,
    Object? showSmartMatchingForBreakouts = freezed,
    Object? alwaysRecord = freezed,
    Object? enablePrerequisites = freezed,
    Object? agendaPreview = freezed,
  }) {
    return _then(_value.copyWith(
      reminderEmails: freezed == reminderEmails
          ? _value.reminderEmails
          : reminderEmails // ignore: cast_nullable_to_non_nullable
              as bool?,
      chat: freezed == chat
          ? _value.chat
          : chat // ignore: cast_nullable_to_non_nullable
              as bool?,
      showChatMessagesInRealTime: freezed == showChatMessagesInRealTime
          ? _value.showChatMessagesInRealTime
          : showChatMessagesInRealTime // ignore: cast_nullable_to_non_nullable
              as bool?,
      talkingTimer: freezed == talkingTimer
          ? _value.talkingTimer
          : talkingTimer // ignore: cast_nullable_to_non_nullable
              as bool?,
      allowPredefineBreakoutsOnHosted: freezed ==
              allowPredefineBreakoutsOnHosted
          ? _value.allowPredefineBreakoutsOnHosted
          : allowPredefineBreakoutsOnHosted // ignore: cast_nullable_to_non_nullable
              as bool?,
      defaultStageView: freezed == defaultStageView
          ? _value.defaultStageView
          : defaultStageView // ignore: cast_nullable_to_non_nullable
              as bool?,
      enableBreakoutsByCategory: freezed == enableBreakoutsByCategory
          ? _value.enableBreakoutsByCategory
          : enableBreakoutsByCategory // ignore: cast_nullable_to_non_nullable
              as bool?,
      allowMultiplePeopleOnStage: freezed == allowMultiplePeopleOnStage
          ? _value.allowMultiplePeopleOnStage
          : allowMultiplePeopleOnStage // ignore: cast_nullable_to_non_nullable
              as bool?,
      showSmartMatchingForBreakouts: freezed == showSmartMatchingForBreakouts
          ? _value.showSmartMatchingForBreakouts
          : showSmartMatchingForBreakouts // ignore: cast_nullable_to_non_nullable
              as bool?,
      alwaysRecord: freezed == alwaysRecord
          ? _value.alwaysRecord
          : alwaysRecord // ignore: cast_nullable_to_non_nullable
              as bool?,
      enablePrerequisites: freezed == enablePrerequisites
          ? _value.enablePrerequisites
          : enablePrerequisites // ignore: cast_nullable_to_non_nullable
              as bool?,
      agendaPreview: freezed == agendaPreview
          ? _value.agendaPreview
          : agendaPreview // ignore: cast_nullable_to_non_nullable
              as bool?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_EventSettingsCopyWith<$Res>
    implements $EventSettingsCopyWith<$Res> {
  factory _$$_EventSettingsCopyWith(
          _$_EventSettings value, $Res Function(_$_EventSettings) then) =
      __$$_EventSettingsCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {bool? reminderEmails,
      bool? chat,
      bool? showChatMessagesInRealTime,
      bool? talkingTimer,
      bool? allowPredefineBreakoutsOnHosted,
      bool? defaultStageView,
      bool? enableBreakoutsByCategory,
      bool? allowMultiplePeopleOnStage,
      bool? showSmartMatchingForBreakouts,
      bool? alwaysRecord,
      bool? enablePrerequisites,
      bool? agendaPreview});
}

/// @nodoc
class __$$_EventSettingsCopyWithImpl<$Res>
    extends _$EventSettingsCopyWithImpl<$Res, _$_EventSettings>
    implements _$$_EventSettingsCopyWith<$Res> {
  __$$_EventSettingsCopyWithImpl(
      _$_EventSettings _value, $Res Function(_$_EventSettings) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? reminderEmails = freezed,
    Object? chat = freezed,
    Object? showChatMessagesInRealTime = freezed,
    Object? talkingTimer = freezed,
    Object? allowPredefineBreakoutsOnHosted = freezed,
    Object? defaultStageView = freezed,
    Object? enableBreakoutsByCategory = freezed,
    Object? allowMultiplePeopleOnStage = freezed,
    Object? showSmartMatchingForBreakouts = freezed,
    Object? alwaysRecord = freezed,
    Object? enablePrerequisites = freezed,
    Object? agendaPreview = freezed,
  }) {
    return _then(_$_EventSettings(
      reminderEmails: freezed == reminderEmails
          ? _value.reminderEmails
          : reminderEmails // ignore: cast_nullable_to_non_nullable
              as bool?,
      chat: freezed == chat
          ? _value.chat
          : chat // ignore: cast_nullable_to_non_nullable
              as bool?,
      showChatMessagesInRealTime: freezed == showChatMessagesInRealTime
          ? _value.showChatMessagesInRealTime
          : showChatMessagesInRealTime // ignore: cast_nullable_to_non_nullable
              as bool?,
      talkingTimer: freezed == talkingTimer
          ? _value.talkingTimer
          : talkingTimer // ignore: cast_nullable_to_non_nullable
              as bool?,
      allowPredefineBreakoutsOnHosted: freezed ==
              allowPredefineBreakoutsOnHosted
          ? _value.allowPredefineBreakoutsOnHosted
          : allowPredefineBreakoutsOnHosted // ignore: cast_nullable_to_non_nullable
              as bool?,
      defaultStageView: freezed == defaultStageView
          ? _value.defaultStageView
          : defaultStageView // ignore: cast_nullable_to_non_nullable
              as bool?,
      enableBreakoutsByCategory: freezed == enableBreakoutsByCategory
          ? _value.enableBreakoutsByCategory
          : enableBreakoutsByCategory // ignore: cast_nullable_to_non_nullable
              as bool?,
      allowMultiplePeopleOnStage: freezed == allowMultiplePeopleOnStage
          ? _value.allowMultiplePeopleOnStage
          : allowMultiplePeopleOnStage // ignore: cast_nullable_to_non_nullable
              as bool?,
      showSmartMatchingForBreakouts: freezed == showSmartMatchingForBreakouts
          ? _value.showSmartMatchingForBreakouts
          : showSmartMatchingForBreakouts // ignore: cast_nullable_to_non_nullable
              as bool?,
      alwaysRecord: freezed == alwaysRecord
          ? _value.alwaysRecord
          : alwaysRecord // ignore: cast_nullable_to_non_nullable
              as bool?,
      enablePrerequisites: freezed == enablePrerequisites
          ? _value.enablePrerequisites
          : enablePrerequisites // ignore: cast_nullable_to_non_nullable
              as bool?,
      agendaPreview: freezed == agendaPreview
          ? _value.agendaPreview
          : agendaPreview // ignore: cast_nullable_to_non_nullable
              as bool?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_EventSettings implements _EventSettings {
  const _$_EventSettings(
      {this.reminderEmails,
      this.chat,
      this.showChatMessagesInRealTime,
      this.talkingTimer,
      this.allowPredefineBreakoutsOnHosted,
      this.defaultStageView,
      this.enableBreakoutsByCategory,
      this.allowMultiplePeopleOnStage,
      this.showSmartMatchingForBreakouts,
      this.alwaysRecord,
      this.enablePrerequisites,
      this.agendaPreview});

  factory _$_EventSettings.fromJson(Map<String, dynamic> json) =>
      _$$_EventSettingsFromJson(json);

  @override
  final bool? reminderEmails;
  @override
  final bool? chat;
  @override
  final bool? showChatMessagesInRealTime;
  @override
  final bool? talkingTimer;
// Reenable if screensharing is implemented
//bool? allowScreenshare,
  @override
  final bool? allowPredefineBreakoutsOnHosted;
  @override
  final bool? defaultStageView;
  @override
  final bool? enableBreakoutsByCategory;
  @override
  final bool? allowMultiplePeopleOnStage;
  @override
  final bool? showSmartMatchingForBreakouts;
  @override
  final bool? alwaysRecord;
  @override
  final bool? enablePrerequisites;
  @override
  final bool? agendaPreview;

  @override
  String toString() {
    return 'EventSettings(reminderEmails: $reminderEmails, chat: $chat, showChatMessagesInRealTime: $showChatMessagesInRealTime, talkingTimer: $talkingTimer, allowPredefineBreakoutsOnHosted: $allowPredefineBreakoutsOnHosted, defaultStageView: $defaultStageView, enableBreakoutsByCategory: $enableBreakoutsByCategory, allowMultiplePeopleOnStage: $allowMultiplePeopleOnStage, showSmartMatchingForBreakouts: $showSmartMatchingForBreakouts, alwaysRecord: $alwaysRecord, enablePrerequisites: $enablePrerequisites, agendaPreview: $agendaPreview)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_EventSettings &&
            (identical(other.reminderEmails, reminderEmails) ||
                other.reminderEmails == reminderEmails) &&
            (identical(other.chat, chat) || other.chat == chat) &&
            (identical(other.showChatMessagesInRealTime,
                    showChatMessagesInRealTime) ||
                other.showChatMessagesInRealTime ==
                    showChatMessagesInRealTime) &&
            (identical(other.talkingTimer, talkingTimer) ||
                other.talkingTimer == talkingTimer) &&
            (identical(other.allowPredefineBreakoutsOnHosted,
                    allowPredefineBreakoutsOnHosted) ||
                other.allowPredefineBreakoutsOnHosted ==
                    allowPredefineBreakoutsOnHosted) &&
            (identical(other.defaultStageView, defaultStageView) ||
                other.defaultStageView == defaultStageView) &&
            (identical(other.enableBreakoutsByCategory, enableBreakoutsByCategory) ||
                other.enableBreakoutsByCategory == enableBreakoutsByCategory) &&
            (identical(other.allowMultiplePeopleOnStage,
                    allowMultiplePeopleOnStage) ||
                other.allowMultiplePeopleOnStage ==
                    allowMultiplePeopleOnStage) &&
            (identical(other.showSmartMatchingForBreakouts,
                    showSmartMatchingForBreakouts) ||
                other.showSmartMatchingForBreakouts ==
                    showSmartMatchingForBreakouts) &&
            (identical(other.alwaysRecord, alwaysRecord) ||
                other.alwaysRecord == alwaysRecord) &&
            (identical(other.enablePrerequisites, enablePrerequisites) ||
                other.enablePrerequisites == enablePrerequisites) &&
            (identical(other.agendaPreview, agendaPreview) ||
                other.agendaPreview == agendaPreview));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      reminderEmails,
      chat,
      showChatMessagesInRealTime,
      talkingTimer,
      allowPredefineBreakoutsOnHosted,
      defaultStageView,
      enableBreakoutsByCategory,
      allowMultiplePeopleOnStage,
      showSmartMatchingForBreakouts,
      alwaysRecord,
      enablePrerequisites,
      agendaPreview);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_EventSettingsCopyWith<_$_EventSettings> get copyWith =>
      __$$_EventSettingsCopyWithImpl<_$_EventSettings>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_EventSettingsToJson(
      this,
    );
  }
}

abstract class _EventSettings implements EventSettings {
  const factory _EventSettings(
      {final bool? reminderEmails,
      final bool? chat,
      final bool? showChatMessagesInRealTime,
      final bool? talkingTimer,
      final bool? allowPredefineBreakoutsOnHosted,
      final bool? defaultStageView,
      final bool? enableBreakoutsByCategory,
      final bool? allowMultiplePeopleOnStage,
      final bool? showSmartMatchingForBreakouts,
      final bool? alwaysRecord,
      final bool? enablePrerequisites,
      final bool? agendaPreview}) = _$_EventSettings;

  factory _EventSettings.fromJson(Map<String, dynamic> json) =
      _$_EventSettings.fromJson;

  @override
  bool? get reminderEmails;
  @override
  bool? get chat;
  @override
  bool? get showChatMessagesInRealTime;
  @override
  bool? get talkingTimer;
  @override // Reenable if screensharing is implemented
//bool? allowScreenshare,
  bool? get allowPredefineBreakoutsOnHosted;
  @override
  bool? get defaultStageView;
  @override
  bool? get enableBreakoutsByCategory;
  @override
  bool? get allowMultiplePeopleOnStage;
  @override
  bool? get showSmartMatchingForBreakouts;
  @override
  bool? get alwaysRecord;
  @override
  bool? get enablePrerequisites;
  @override
  bool? get agendaPreview;
  @override
  @JsonKey(ignore: true)
  _$$_EventSettingsCopyWith<_$_EventSettings> get copyWith =>
      throw _privateConstructorUsedError;
}

LiveStreamInfo _$LiveStreamInfoFromJson(Map<String, dynamic> json) {
  return _LiveStreamInfo.fromJson(json);
}

/// @nodoc
mixin _$LiveStreamInfo {
  String? get muxId => throw _privateConstructorUsedError;
  String? get muxPlaybackId => throw _privateConstructorUsedError;
  String? get muxStatus => throw _privateConstructorUsedError;
  String? get latestAssetPlaybackId => throw _privateConstructorUsedError;
  String? get liveStreamWaitingTextOverride =>
      throw _privateConstructorUsedError;
  bool? get resetStream => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $LiveStreamInfoCopyWith<LiveStreamInfo> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LiveStreamInfoCopyWith<$Res> {
  factory $LiveStreamInfoCopyWith(
          LiveStreamInfo value, $Res Function(LiveStreamInfo) then) =
      _$LiveStreamInfoCopyWithImpl<$Res, LiveStreamInfo>;
  @useResult
  $Res call(
      {String? muxId,
      String? muxPlaybackId,
      String? muxStatus,
      String? latestAssetPlaybackId,
      String? liveStreamWaitingTextOverride,
      bool? resetStream});
}

/// @nodoc
class _$LiveStreamInfoCopyWithImpl<$Res, $Val extends LiveStreamInfo>
    implements $LiveStreamInfoCopyWith<$Res> {
  _$LiveStreamInfoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? muxId = freezed,
    Object? muxPlaybackId = freezed,
    Object? muxStatus = freezed,
    Object? latestAssetPlaybackId = freezed,
    Object? liveStreamWaitingTextOverride = freezed,
    Object? resetStream = freezed,
  }) {
    return _then(_value.copyWith(
      muxId: freezed == muxId
          ? _value.muxId
          : muxId // ignore: cast_nullable_to_non_nullable
              as String?,
      muxPlaybackId: freezed == muxPlaybackId
          ? _value.muxPlaybackId
          : muxPlaybackId // ignore: cast_nullable_to_non_nullable
              as String?,
      muxStatus: freezed == muxStatus
          ? _value.muxStatus
          : muxStatus // ignore: cast_nullable_to_non_nullable
              as String?,
      latestAssetPlaybackId: freezed == latestAssetPlaybackId
          ? _value.latestAssetPlaybackId
          : latestAssetPlaybackId // ignore: cast_nullable_to_non_nullable
              as String?,
      liveStreamWaitingTextOverride: freezed == liveStreamWaitingTextOverride
          ? _value.liveStreamWaitingTextOverride
          : liveStreamWaitingTextOverride // ignore: cast_nullable_to_non_nullable
              as String?,
      resetStream: freezed == resetStream
          ? _value.resetStream
          : resetStream // ignore: cast_nullable_to_non_nullable
              as bool?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_LiveStreamInfoCopyWith<$Res>
    implements $LiveStreamInfoCopyWith<$Res> {
  factory _$$_LiveStreamInfoCopyWith(
          _$_LiveStreamInfo value, $Res Function(_$_LiveStreamInfo) then) =
      __$$_LiveStreamInfoCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String? muxId,
      String? muxPlaybackId,
      String? muxStatus,
      String? latestAssetPlaybackId,
      String? liveStreamWaitingTextOverride,
      bool? resetStream});
}

/// @nodoc
class __$$_LiveStreamInfoCopyWithImpl<$Res>
    extends _$LiveStreamInfoCopyWithImpl<$Res, _$_LiveStreamInfo>
    implements _$$_LiveStreamInfoCopyWith<$Res> {
  __$$_LiveStreamInfoCopyWithImpl(
      _$_LiveStreamInfo _value, $Res Function(_$_LiveStreamInfo) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? muxId = freezed,
    Object? muxPlaybackId = freezed,
    Object? muxStatus = freezed,
    Object? latestAssetPlaybackId = freezed,
    Object? liveStreamWaitingTextOverride = freezed,
    Object? resetStream = freezed,
  }) {
    return _then(_$_LiveStreamInfo(
      muxId: freezed == muxId
          ? _value.muxId
          : muxId // ignore: cast_nullable_to_non_nullable
              as String?,
      muxPlaybackId: freezed == muxPlaybackId
          ? _value.muxPlaybackId
          : muxPlaybackId // ignore: cast_nullable_to_non_nullable
              as String?,
      muxStatus: freezed == muxStatus
          ? _value.muxStatus
          : muxStatus // ignore: cast_nullable_to_non_nullable
              as String?,
      latestAssetPlaybackId: freezed == latestAssetPlaybackId
          ? _value.latestAssetPlaybackId
          : latestAssetPlaybackId // ignore: cast_nullable_to_non_nullable
              as String?,
      liveStreamWaitingTextOverride: freezed == liveStreamWaitingTextOverride
          ? _value.liveStreamWaitingTextOverride
          : liveStreamWaitingTextOverride // ignore: cast_nullable_to_non_nullable
              as String?,
      resetStream: freezed == resetStream
          ? _value.resetStream
          : resetStream // ignore: cast_nullable_to_non_nullable
              as bool?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_LiveStreamInfo implements _LiveStreamInfo {
  _$_LiveStreamInfo(
      {this.muxId,
      this.muxPlaybackId,
      this.muxStatus,
      this.latestAssetPlaybackId,
      this.liveStreamWaitingTextOverride,
      this.resetStream});

  factory _$_LiveStreamInfo.fromJson(Map<String, dynamic> json) =>
      _$$_LiveStreamInfoFromJson(json);

  @override
  final String? muxId;
  @override
  final String? muxPlaybackId;
  @override
  final String? muxStatus;
  @override
  final String? latestAssetPlaybackId;
  @override
  final String? liveStreamWaitingTextOverride;
  @override
  final bool? resetStream;

  @override
  String toString() {
    return 'LiveStreamInfo(muxId: $muxId, muxPlaybackId: $muxPlaybackId, muxStatus: $muxStatus, latestAssetPlaybackId: $latestAssetPlaybackId, liveStreamWaitingTextOverride: $liveStreamWaitingTextOverride, resetStream: $resetStream)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_LiveStreamInfo &&
            (identical(other.muxId, muxId) || other.muxId == muxId) &&
            (identical(other.muxPlaybackId, muxPlaybackId) ||
                other.muxPlaybackId == muxPlaybackId) &&
            (identical(other.muxStatus, muxStatus) ||
                other.muxStatus == muxStatus) &&
            (identical(other.latestAssetPlaybackId, latestAssetPlaybackId) ||
                other.latestAssetPlaybackId == latestAssetPlaybackId) &&
            (identical(other.liveStreamWaitingTextOverride,
                    liveStreamWaitingTextOverride) ||
                other.liveStreamWaitingTextOverride ==
                    liveStreamWaitingTextOverride) &&
            (identical(other.resetStream, resetStream) ||
                other.resetStream == resetStream));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, muxId, muxPlaybackId, muxStatus,
      latestAssetPlaybackId, liveStreamWaitingTextOverride, resetStream);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_LiveStreamInfoCopyWith<_$_LiveStreamInfo> get copyWith =>
      __$$_LiveStreamInfoCopyWithImpl<_$_LiveStreamInfo>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_LiveStreamInfoToJson(
      this,
    );
  }
}

abstract class _LiveStreamInfo implements LiveStreamInfo {
  factory _LiveStreamInfo(
      {final String? muxId,
      final String? muxPlaybackId,
      final String? muxStatus,
      final String? latestAssetPlaybackId,
      final String? liveStreamWaitingTextOverride,
      final bool? resetStream}) = _$_LiveStreamInfo;

  factory _LiveStreamInfo.fromJson(Map<String, dynamic> json) =
      _$_LiveStreamInfo.fromJson;

  @override
  String? get muxId;
  @override
  String? get muxPlaybackId;
  @override
  String? get muxStatus;
  @override
  String? get latestAssetPlaybackId;
  @override
  String? get liveStreamWaitingTextOverride;
  @override
  bool? get resetStream;
  @override
  @JsonKey(ignore: true)
  _$$_LiveStreamInfoCopyWith<_$_LiveStreamInfo> get copyWith =>
      throw _privateConstructorUsedError;
}

Participant _$ParticipantFromJson(Map<String, dynamic> json) {
  return _Participant.fromJson(json);
}

/// @nodoc
mixin _$Participant {
  String get id => throw _privateConstructorUsedError;
  String? get communityId => throw _privateConstructorUsedError;
  String? get externalCommunityId => throw _privateConstructorUsedError;
  String? get templateId => throw _privateConstructorUsedError;
  @JsonKey(fromJson: dateTimeFromTimestamp, toJson: serverTimestamp)
  DateTime? get lastUpdatedTime => throw _privateConstructorUsedError;
  @JsonKey(fromJson: dateTimeFromTimestamp)
  DateTime? get createdDate =>
      throw _privateConstructorUsedError; // TODO(Danny): See if there is a way to do this without duplicating this information on the participant
  @JsonKey(fromJson: dateTimeFromTimestamp, toJson: serverTimestamp)
  DateTime? get scheduledTime => throw _privateConstructorUsedError;
  @JsonKey(unknownEnumValue: null)
  ParticipantStatus? get status => throw _privateConstructorUsedError;
  bool get isPresent => throw _privateConstructorUsedError;
  String? get availableForBreakoutSessionId =>
      throw _privateConstructorUsedError;

  /// This cannot be trusted for any auth operations. Should be enforced through
  /// firestore security rules.
  @JsonKey(unknownEnumValue: null)
  MembershipStatus? get membershipStatus => throw _privateConstructorUsedError;
  String? get currentBreakoutRoomId => throw _privateConstructorUsedError;

  /// Host can set to true to mute this user during a meeting
  bool get muteOverride => throw _privateConstructorUsedError;
  Map<String, String>? get joinParameters => throw _privateConstructorUsedError;
  List<BreakoutQuestion> get breakoutRoomSurveyQuestions =>
      throw _privateConstructorUsedError;
  @JsonKey(fromJson: dateTimeFromTimestamp, toJson: serverTimestampOrNull)
  DateTime? get mostRecentPresentTime => throw _privateConstructorUsedError;
  String? get zipCode => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ParticipantCopyWith<Participant> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ParticipantCopyWith<$Res> {
  factory $ParticipantCopyWith(
          Participant value, $Res Function(Participant) then) =
      _$ParticipantCopyWithImpl<$Res, Participant>;
  @useResult
  $Res call(
      {String id,
      String? communityId,
      String? externalCommunityId,
      String? templateId,
      @JsonKey(fromJson: dateTimeFromTimestamp, toJson: serverTimestamp)
      DateTime? lastUpdatedTime,
      @JsonKey(fromJson: dateTimeFromTimestamp) DateTime? createdDate,
      @JsonKey(fromJson: dateTimeFromTimestamp, toJson: serverTimestamp)
      DateTime? scheduledTime,
      @JsonKey(unknownEnumValue: null) ParticipantStatus? status,
      bool isPresent,
      String? availableForBreakoutSessionId,
      @JsonKey(unknownEnumValue: null) MembershipStatus? membershipStatus,
      String? currentBreakoutRoomId,
      bool muteOverride,
      Map<String, String>? joinParameters,
      List<BreakoutQuestion> breakoutRoomSurveyQuestions,
      @JsonKey(fromJson: dateTimeFromTimestamp, toJson: serverTimestampOrNull)
      DateTime? mostRecentPresentTime,
      String? zipCode});
}

/// @nodoc
class _$ParticipantCopyWithImpl<$Res, $Val extends Participant>
    implements $ParticipantCopyWith<$Res> {
  _$ParticipantCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? communityId = freezed,
    Object? externalCommunityId = freezed,
    Object? templateId = freezed,
    Object? lastUpdatedTime = freezed,
    Object? createdDate = freezed,
    Object? scheduledTime = freezed,
    Object? status = freezed,
    Object? isPresent = null,
    Object? availableForBreakoutSessionId = freezed,
    Object? membershipStatus = freezed,
    Object? currentBreakoutRoomId = freezed,
    Object? muteOverride = null,
    Object? joinParameters = freezed,
    Object? breakoutRoomSurveyQuestions = null,
    Object? mostRecentPresentTime = freezed,
    Object? zipCode = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      communityId: freezed == communityId
          ? _value.communityId
          : communityId // ignore: cast_nullable_to_non_nullable
              as String?,
      externalCommunityId: freezed == externalCommunityId
          ? _value.externalCommunityId
          : externalCommunityId // ignore: cast_nullable_to_non_nullable
              as String?,
      templateId: freezed == templateId
          ? _value.templateId
          : templateId // ignore: cast_nullable_to_non_nullable
              as String?,
      lastUpdatedTime: freezed == lastUpdatedTime
          ? _value.lastUpdatedTime
          : lastUpdatedTime // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      createdDate: freezed == createdDate
          ? _value.createdDate
          : createdDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      scheduledTime: freezed == scheduledTime
          ? _value.scheduledTime
          : scheduledTime // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      status: freezed == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as ParticipantStatus?,
      isPresent: null == isPresent
          ? _value.isPresent
          : isPresent // ignore: cast_nullable_to_non_nullable
              as bool,
      availableForBreakoutSessionId: freezed == availableForBreakoutSessionId
          ? _value.availableForBreakoutSessionId
          : availableForBreakoutSessionId // ignore: cast_nullable_to_non_nullable
              as String?,
      membershipStatus: freezed == membershipStatus
          ? _value.membershipStatus
          : membershipStatus // ignore: cast_nullable_to_non_nullable
              as MembershipStatus?,
      currentBreakoutRoomId: freezed == currentBreakoutRoomId
          ? _value.currentBreakoutRoomId
          : currentBreakoutRoomId // ignore: cast_nullable_to_non_nullable
              as String?,
      muteOverride: null == muteOverride
          ? _value.muteOverride
          : muteOverride // ignore: cast_nullable_to_non_nullable
              as bool,
      joinParameters: freezed == joinParameters
          ? _value.joinParameters
          : joinParameters // ignore: cast_nullable_to_non_nullable
              as Map<String, String>?,
      breakoutRoomSurveyQuestions: null == breakoutRoomSurveyQuestions
          ? _value.breakoutRoomSurveyQuestions
          : breakoutRoomSurveyQuestions // ignore: cast_nullable_to_non_nullable
              as List<BreakoutQuestion>,
      mostRecentPresentTime: freezed == mostRecentPresentTime
          ? _value.mostRecentPresentTime
          : mostRecentPresentTime // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      zipCode: freezed == zipCode
          ? _value.zipCode
          : zipCode // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_ParticipantCopyWith<$Res>
    implements $ParticipantCopyWith<$Res> {
  factory _$$_ParticipantCopyWith(
          _$_Participant value, $Res Function(_$_Participant) then) =
      __$$_ParticipantCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String? communityId,
      String? externalCommunityId,
      String? templateId,
      @JsonKey(fromJson: dateTimeFromTimestamp, toJson: serverTimestamp)
      DateTime? lastUpdatedTime,
      @JsonKey(fromJson: dateTimeFromTimestamp) DateTime? createdDate,
      @JsonKey(fromJson: dateTimeFromTimestamp, toJson: serverTimestamp)
      DateTime? scheduledTime,
      @JsonKey(unknownEnumValue: null) ParticipantStatus? status,
      bool isPresent,
      String? availableForBreakoutSessionId,
      @JsonKey(unknownEnumValue: null) MembershipStatus? membershipStatus,
      String? currentBreakoutRoomId,
      bool muteOverride,
      Map<String, String>? joinParameters,
      List<BreakoutQuestion> breakoutRoomSurveyQuestions,
      @JsonKey(fromJson: dateTimeFromTimestamp, toJson: serverTimestampOrNull)
      DateTime? mostRecentPresentTime,
      String? zipCode});
}

/// @nodoc
class __$$_ParticipantCopyWithImpl<$Res>
    extends _$ParticipantCopyWithImpl<$Res, _$_Participant>
    implements _$$_ParticipantCopyWith<$Res> {
  __$$_ParticipantCopyWithImpl(
      _$_Participant _value, $Res Function(_$_Participant) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? communityId = freezed,
    Object? externalCommunityId = freezed,
    Object? templateId = freezed,
    Object? lastUpdatedTime = freezed,
    Object? createdDate = freezed,
    Object? scheduledTime = freezed,
    Object? status = freezed,
    Object? isPresent = null,
    Object? availableForBreakoutSessionId = freezed,
    Object? membershipStatus = freezed,
    Object? currentBreakoutRoomId = freezed,
    Object? muteOverride = null,
    Object? joinParameters = freezed,
    Object? breakoutRoomSurveyQuestions = null,
    Object? mostRecentPresentTime = freezed,
    Object? zipCode = freezed,
  }) {
    return _then(_$_Participant(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      communityId: freezed == communityId
          ? _value.communityId
          : communityId // ignore: cast_nullable_to_non_nullable
              as String?,
      externalCommunityId: freezed == externalCommunityId
          ? _value.externalCommunityId
          : externalCommunityId // ignore: cast_nullable_to_non_nullable
              as String?,
      templateId: freezed == templateId
          ? _value.templateId
          : templateId // ignore: cast_nullable_to_non_nullable
              as String?,
      lastUpdatedTime: freezed == lastUpdatedTime
          ? _value.lastUpdatedTime
          : lastUpdatedTime // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      createdDate: freezed == createdDate
          ? _value.createdDate
          : createdDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      scheduledTime: freezed == scheduledTime
          ? _value.scheduledTime
          : scheduledTime // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      status: freezed == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as ParticipantStatus?,
      isPresent: null == isPresent
          ? _value.isPresent
          : isPresent // ignore: cast_nullable_to_non_nullable
              as bool,
      availableForBreakoutSessionId: freezed == availableForBreakoutSessionId
          ? _value.availableForBreakoutSessionId
          : availableForBreakoutSessionId // ignore: cast_nullable_to_non_nullable
              as String?,
      membershipStatus: freezed == membershipStatus
          ? _value.membershipStatus
          : membershipStatus // ignore: cast_nullable_to_non_nullable
              as MembershipStatus?,
      currentBreakoutRoomId: freezed == currentBreakoutRoomId
          ? _value.currentBreakoutRoomId
          : currentBreakoutRoomId // ignore: cast_nullable_to_non_nullable
              as String?,
      muteOverride: null == muteOverride
          ? _value.muteOverride
          : muteOverride // ignore: cast_nullable_to_non_nullable
              as bool,
      joinParameters: freezed == joinParameters
          ? _value.joinParameters
          : joinParameters // ignore: cast_nullable_to_non_nullable
              as Map<String, String>?,
      breakoutRoomSurveyQuestions: null == breakoutRoomSurveyQuestions
          ? _value.breakoutRoomSurveyQuestions
          : breakoutRoomSurveyQuestions // ignore: cast_nullable_to_non_nullable
              as List<BreakoutQuestion>,
      mostRecentPresentTime: freezed == mostRecentPresentTime
          ? _value.mostRecentPresentTime
          : mostRecentPresentTime // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      zipCode: freezed == zipCode
          ? _value.zipCode
          : zipCode // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_Participant implements _Participant {
  _$_Participant(
      {required this.id,
      this.communityId,
      this.externalCommunityId,
      this.templateId,
      @JsonKey(fromJson: dateTimeFromTimestamp, toJson: serverTimestamp)
      this.lastUpdatedTime,
      @JsonKey(fromJson: dateTimeFromTimestamp) this.createdDate,
      @JsonKey(fromJson: dateTimeFromTimestamp, toJson: serverTimestamp)
      this.scheduledTime,
      @JsonKey(unknownEnumValue: null) this.status,
      this.isPresent = false,
      this.availableForBreakoutSessionId,
      @JsonKey(unknownEnumValue: null) this.membershipStatus,
      this.currentBreakoutRoomId,
      this.muteOverride = false,
      this.joinParameters,
      this.breakoutRoomSurveyQuestions = const [],
      @JsonKey(fromJson: dateTimeFromTimestamp, toJson: serverTimestampOrNull)
      this.mostRecentPresentTime,
      this.zipCode});

  factory _$_Participant.fromJson(Map<String, dynamic> json) =>
      _$$_ParticipantFromJson(json);

  @override
  final String id;
  @override
  final String? communityId;
  @override
  final String? externalCommunityId;
  @override
  final String? templateId;
  @override
  @JsonKey(fromJson: dateTimeFromTimestamp, toJson: serverTimestamp)
  final DateTime? lastUpdatedTime;
  @override
  @JsonKey(fromJson: dateTimeFromTimestamp)
  final DateTime? createdDate;
// TODO(Danny): See if there is a way to do this without duplicating this information on the participant
  @override
  @JsonKey(fromJson: dateTimeFromTimestamp, toJson: serverTimestamp)
  final DateTime? scheduledTime;
  @override
  @JsonKey(unknownEnumValue: null)
  final ParticipantStatus? status;
  @override
  @JsonKey()
  final bool isPresent;
  @override
  final String? availableForBreakoutSessionId;

  /// This cannot be trusted for any auth operations. Should be enforced through
  /// firestore security rules.
  @override
  @JsonKey(unknownEnumValue: null)
  final MembershipStatus? membershipStatus;
  @override
  final String? currentBreakoutRoomId;

  /// Host can set to true to mute this user during a meeting
  @override
  @JsonKey()
  final bool muteOverride;
  @override
  final Map<String, String>? joinParameters;
  @override
  @JsonKey()
  final List<BreakoutQuestion> breakoutRoomSurveyQuestions;
  @override
  @JsonKey(fromJson: dateTimeFromTimestamp, toJson: serverTimestampOrNull)
  final DateTime? mostRecentPresentTime;
  @override
  final String? zipCode;

  @override
  String toString() {
    return 'Participant(id: $id, communityId: $communityId, externalCommunityId: $externalCommunityId, templateId: $templateId, lastUpdatedTime: $lastUpdatedTime, createdDate: $createdDate, scheduledTime: $scheduledTime, status: $status, isPresent: $isPresent, availableForBreakoutSessionId: $availableForBreakoutSessionId, membershipStatus: $membershipStatus, currentBreakoutRoomId: $currentBreakoutRoomId, muteOverride: $muteOverride, joinParameters: $joinParameters, breakoutRoomSurveyQuestions: $breakoutRoomSurveyQuestions, mostRecentPresentTime: $mostRecentPresentTime, zipCode: $zipCode)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_Participant &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.communityId, communityId) ||
                other.communityId == communityId) &&
            (identical(other.externalCommunityId, externalCommunityId) ||
                other.externalCommunityId == externalCommunityId) &&
            (identical(other.templateId, templateId) ||
                other.templateId == templateId) &&
            (identical(other.lastUpdatedTime, lastUpdatedTime) ||
                other.lastUpdatedTime == lastUpdatedTime) &&
            (identical(other.createdDate, createdDate) ||
                other.createdDate == createdDate) &&
            (identical(other.scheduledTime, scheduledTime) ||
                other.scheduledTime == scheduledTime) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.isPresent, isPresent) ||
                other.isPresent == isPresent) &&
            (identical(other.availableForBreakoutSessionId,
                    availableForBreakoutSessionId) ||
                other.availableForBreakoutSessionId ==
                    availableForBreakoutSessionId) &&
            (identical(other.membershipStatus, membershipStatus) ||
                other.membershipStatus == membershipStatus) &&
            (identical(other.currentBreakoutRoomId, currentBreakoutRoomId) ||
                other.currentBreakoutRoomId == currentBreakoutRoomId) &&
            (identical(other.muteOverride, muteOverride) ||
                other.muteOverride == muteOverride) &&
            const DeepCollectionEquality()
                .equals(other.joinParameters, joinParameters) &&
            const DeepCollectionEquality().equals(
                other.breakoutRoomSurveyQuestions,
                breakoutRoomSurveyQuestions) &&
            (identical(other.mostRecentPresentTime, mostRecentPresentTime) ||
                other.mostRecentPresentTime == mostRecentPresentTime) &&
            (identical(other.zipCode, zipCode) || other.zipCode == zipCode));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      communityId,
      externalCommunityId,
      templateId,
      lastUpdatedTime,
      createdDate,
      scheduledTime,
      status,
      isPresent,
      availableForBreakoutSessionId,
      membershipStatus,
      currentBreakoutRoomId,
      muteOverride,
      const DeepCollectionEquality().hash(joinParameters),
      const DeepCollectionEquality().hash(breakoutRoomSurveyQuestions),
      mostRecentPresentTime,
      zipCode);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_ParticipantCopyWith<_$_Participant> get copyWith =>
      __$$_ParticipantCopyWithImpl<_$_Participant>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_ParticipantToJson(
      this,
    );
  }
}

abstract class _Participant implements Participant {
  factory _Participant(
      {required final String id,
      final String? communityId,
      final String? externalCommunityId,
      final String? templateId,
      @JsonKey(fromJson: dateTimeFromTimestamp, toJson: serverTimestamp)
      final DateTime? lastUpdatedTime,
      @JsonKey(fromJson: dateTimeFromTimestamp) final DateTime? createdDate,
      @JsonKey(fromJson: dateTimeFromTimestamp, toJson: serverTimestamp)
      final DateTime? scheduledTime,
      @JsonKey(unknownEnumValue: null) final ParticipantStatus? status,
      final bool isPresent,
      final String? availableForBreakoutSessionId,
      @JsonKey(unknownEnumValue: null) final MembershipStatus? membershipStatus,
      final String? currentBreakoutRoomId,
      final bool muteOverride,
      final Map<String, String>? joinParameters,
      final List<BreakoutQuestion> breakoutRoomSurveyQuestions,
      @JsonKey(fromJson: dateTimeFromTimestamp, toJson: serverTimestampOrNull)
      final DateTime? mostRecentPresentTime,
      final String? zipCode}) = _$_Participant;

  factory _Participant.fromJson(Map<String, dynamic> json) =
      _$_Participant.fromJson;

  @override
  String get id;
  @override
  String? get communityId;
  @override
  String? get externalCommunityId;
  @override
  String? get templateId;
  @override
  @JsonKey(fromJson: dateTimeFromTimestamp, toJson: serverTimestamp)
  DateTime? get lastUpdatedTime;
  @override
  @JsonKey(fromJson: dateTimeFromTimestamp)
  DateTime? get createdDate;
  @override // TODO(Danny): See if there is a way to do this without duplicating this information on the participant
  @JsonKey(fromJson: dateTimeFromTimestamp, toJson: serverTimestamp)
  DateTime? get scheduledTime;
  @override
  @JsonKey(unknownEnumValue: null)
  ParticipantStatus? get status;
  @override
  bool get isPresent;
  @override
  String? get availableForBreakoutSessionId;
  @override

  /// This cannot be trusted for any auth operations. Should be enforced through
  /// firestore security rules.
  @JsonKey(unknownEnumValue: null)
  MembershipStatus? get membershipStatus;
  @override
  String? get currentBreakoutRoomId;
  @override

  /// Host can set to true to mute this user during a meeting
  bool get muteOverride;
  @override
  Map<String, String>? get joinParameters;
  @override
  List<BreakoutQuestion> get breakoutRoomSurveyQuestions;
  @override
  @JsonKey(fromJson: dateTimeFromTimestamp, toJson: serverTimestampOrNull)
  DateTime? get mostRecentPresentTime;
  @override
  String? get zipCode;
  @override
  @JsonKey(ignore: true)
  _$$_ParticipantCopyWith<_$_Participant> get copyWith =>
      throw _privateConstructorUsedError;
}

PrivateLiveStreamInfo _$PrivateLiveStreamInfoFromJson(
    Map<String, dynamic> json) {
  return _PrivateLiveStreamInfo.fromJson(json);
}

/// @nodoc
mixin _$PrivateLiveStreamInfo {
  String? get streamServerUrl => throw _privateConstructorUsedError;
  String? get streamKey => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $PrivateLiveStreamInfoCopyWith<PrivateLiveStreamInfo> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PrivateLiveStreamInfoCopyWith<$Res> {
  factory $PrivateLiveStreamInfoCopyWith(PrivateLiveStreamInfo value,
          $Res Function(PrivateLiveStreamInfo) then) =
      _$PrivateLiveStreamInfoCopyWithImpl<$Res, PrivateLiveStreamInfo>;
  @useResult
  $Res call({String? streamServerUrl, String? streamKey});
}

/// @nodoc
class _$PrivateLiveStreamInfoCopyWithImpl<$Res,
        $Val extends PrivateLiveStreamInfo>
    implements $PrivateLiveStreamInfoCopyWith<$Res> {
  _$PrivateLiveStreamInfoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? streamServerUrl = freezed,
    Object? streamKey = freezed,
  }) {
    return _then(_value.copyWith(
      streamServerUrl: freezed == streamServerUrl
          ? _value.streamServerUrl
          : streamServerUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      streamKey: freezed == streamKey
          ? _value.streamKey
          : streamKey // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_PrivateLiveStreamInfoCopyWith<$Res>
    implements $PrivateLiveStreamInfoCopyWith<$Res> {
  factory _$$_PrivateLiveStreamInfoCopyWith(_$_PrivateLiveStreamInfo value,
          $Res Function(_$_PrivateLiveStreamInfo) then) =
      __$$_PrivateLiveStreamInfoCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String? streamServerUrl, String? streamKey});
}

/// @nodoc
class __$$_PrivateLiveStreamInfoCopyWithImpl<$Res>
    extends _$PrivateLiveStreamInfoCopyWithImpl<$Res, _$_PrivateLiveStreamInfo>
    implements _$$_PrivateLiveStreamInfoCopyWith<$Res> {
  __$$_PrivateLiveStreamInfoCopyWithImpl(_$_PrivateLiveStreamInfo _value,
      $Res Function(_$_PrivateLiveStreamInfo) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? streamServerUrl = freezed,
    Object? streamKey = freezed,
  }) {
    return _then(_$_PrivateLiveStreamInfo(
      streamServerUrl: freezed == streamServerUrl
          ? _value.streamServerUrl
          : streamServerUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      streamKey: freezed == streamKey
          ? _value.streamKey
          : streamKey // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_PrivateLiveStreamInfo implements _PrivateLiveStreamInfo {
  _$_PrivateLiveStreamInfo({this.streamServerUrl, this.streamKey});

  factory _$_PrivateLiveStreamInfo.fromJson(Map<String, dynamic> json) =>
      _$$_PrivateLiveStreamInfoFromJson(json);

  @override
  final String? streamServerUrl;
  @override
  final String? streamKey;

  @override
  String toString() {
    return 'PrivateLiveStreamInfo(streamServerUrl: $streamServerUrl, streamKey: $streamKey)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_PrivateLiveStreamInfo &&
            (identical(other.streamServerUrl, streamServerUrl) ||
                other.streamServerUrl == streamServerUrl) &&
            (identical(other.streamKey, streamKey) ||
                other.streamKey == streamKey));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, streamServerUrl, streamKey);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_PrivateLiveStreamInfoCopyWith<_$_PrivateLiveStreamInfo> get copyWith =>
      __$$_PrivateLiveStreamInfoCopyWithImpl<_$_PrivateLiveStreamInfo>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_PrivateLiveStreamInfoToJson(
      this,
    );
  }
}

abstract class _PrivateLiveStreamInfo implements PrivateLiveStreamInfo {
  factory _PrivateLiveStreamInfo(
      {final String? streamServerUrl,
      final String? streamKey}) = _$_PrivateLiveStreamInfo;

  factory _PrivateLiveStreamInfo.fromJson(Map<String, dynamic> json) =
      _$_PrivateLiveStreamInfo.fromJson;

  @override
  String? get streamServerUrl;
  @override
  String? get streamKey;
  @override
  @JsonKey(ignore: true)
  _$$_PrivateLiveStreamInfoCopyWith<_$_PrivateLiveStreamInfo> get copyWith =>
      throw _privateConstructorUsedError;
}

EventEmailLog _$EventEmailLogFromJson(Map<String, dynamic> json) {
  return _EventEmailLog.fromJson(json);
}

/// @nodoc
mixin _$EventEmailLog {
  String? get userId => throw _privateConstructorUsedError;
  @JsonKey(unknownEnumValue: null)
  EventEmailType? get eventEmailType => throw _privateConstructorUsedError;
  @JsonKey(fromJson: dateTimeFromTimestamp, toJson: timestampFromDateTime)
  DateTime? get createdDate => throw _privateConstructorUsedError;

  /// ID used to identify a group of emails that were sent. This is used to
  /// ensure that the same email is not sent multiple times to a group.
  String? get sendId => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $EventEmailLogCopyWith<EventEmailLog> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $EventEmailLogCopyWith<$Res> {
  factory $EventEmailLogCopyWith(
          EventEmailLog value, $Res Function(EventEmailLog) then) =
      _$EventEmailLogCopyWithImpl<$Res, EventEmailLog>;
  @useResult
  $Res call(
      {String? userId,
      @JsonKey(unknownEnumValue: null) EventEmailType? eventEmailType,
      @JsonKey(fromJson: dateTimeFromTimestamp, toJson: timestampFromDateTime)
      DateTime? createdDate,
      String? sendId});
}

/// @nodoc
class _$EventEmailLogCopyWithImpl<$Res, $Val extends EventEmailLog>
    implements $EventEmailLogCopyWith<$Res> {
  _$EventEmailLogCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = freezed,
    Object? eventEmailType = freezed,
    Object? createdDate = freezed,
    Object? sendId = freezed,
  }) {
    return _then(_value.copyWith(
      userId: freezed == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String?,
      eventEmailType: freezed == eventEmailType
          ? _value.eventEmailType
          : eventEmailType // ignore: cast_nullable_to_non_nullable
              as EventEmailType?,
      createdDate: freezed == createdDate
          ? _value.createdDate
          : createdDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      sendId: freezed == sendId
          ? _value.sendId
          : sendId // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_EventEmailLogCopyWith<$Res>
    implements $EventEmailLogCopyWith<$Res> {
  factory _$$_EventEmailLogCopyWith(
          _$_EventEmailLog value, $Res Function(_$_EventEmailLog) then) =
      __$$_EventEmailLogCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String? userId,
      @JsonKey(unknownEnumValue: null) EventEmailType? eventEmailType,
      @JsonKey(fromJson: dateTimeFromTimestamp, toJson: timestampFromDateTime)
      DateTime? createdDate,
      String? sendId});
}

/// @nodoc
class __$$_EventEmailLogCopyWithImpl<$Res>
    extends _$EventEmailLogCopyWithImpl<$Res, _$_EventEmailLog>
    implements _$$_EventEmailLogCopyWith<$Res> {
  __$$_EventEmailLogCopyWithImpl(
      _$_EventEmailLog _value, $Res Function(_$_EventEmailLog) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = freezed,
    Object? eventEmailType = freezed,
    Object? createdDate = freezed,
    Object? sendId = freezed,
  }) {
    return _then(_$_EventEmailLog(
      userId: freezed == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String?,
      eventEmailType: freezed == eventEmailType
          ? _value.eventEmailType
          : eventEmailType // ignore: cast_nullable_to_non_nullable
              as EventEmailType?,
      createdDate: freezed == createdDate
          ? _value.createdDate
          : createdDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      sendId: freezed == sendId
          ? _value.sendId
          : sendId // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_EventEmailLog implements _EventEmailLog {
  _$_EventEmailLog(
      {this.userId,
      @JsonKey(unknownEnumValue: null) this.eventEmailType,
      @JsonKey(fromJson: dateTimeFromTimestamp, toJson: timestampFromDateTime)
      this.createdDate,
      this.sendId});

  factory _$_EventEmailLog.fromJson(Map<String, dynamic> json) =>
      _$$_EventEmailLogFromJson(json);

  @override
  final String? userId;
  @override
  @JsonKey(unknownEnumValue: null)
  final EventEmailType? eventEmailType;
  @override
  @JsonKey(fromJson: dateTimeFromTimestamp, toJson: timestampFromDateTime)
  final DateTime? createdDate;

  /// ID used to identify a group of emails that were sent. This is used to
  /// ensure that the same email is not sent multiple times to a group.
  @override
  final String? sendId;

  @override
  String toString() {
    return 'EventEmailLog(userId: $userId, eventEmailType: $eventEmailType, createdDate: $createdDate, sendId: $sendId)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_EventEmailLog &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.eventEmailType, eventEmailType) ||
                other.eventEmailType == eventEmailType) &&
            (identical(other.createdDate, createdDate) ||
                other.createdDate == createdDate) &&
            (identical(other.sendId, sendId) || other.sendId == sendId));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode =>
      Object.hash(runtimeType, userId, eventEmailType, createdDate, sendId);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_EventEmailLogCopyWith<_$_EventEmailLog> get copyWith =>
      __$$_EventEmailLogCopyWithImpl<_$_EventEmailLog>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_EventEmailLogToJson(
      this,
    );
  }
}

abstract class _EventEmailLog implements EventEmailLog {
  factory _EventEmailLog(
      {final String? userId,
      @JsonKey(unknownEnumValue: null) final EventEmailType? eventEmailType,
      @JsonKey(fromJson: dateTimeFromTimestamp, toJson: timestampFromDateTime)
      final DateTime? createdDate,
      final String? sendId}) = _$_EventEmailLog;

  factory _EventEmailLog.fromJson(Map<String, dynamic> json) =
      _$_EventEmailLog.fromJson;

  @override
  String? get userId;
  @override
  @JsonKey(unknownEnumValue: null)
  EventEmailType? get eventEmailType;
  @override
  @JsonKey(fromJson: dateTimeFromTimestamp, toJson: timestampFromDateTime)
  DateTime? get createdDate;
  @override

  /// ID used to identify a group of emails that were sent. This is used to
  /// ensure that the same email is not sent multiple times to a group.
  String? get sendId;
  @override
  @JsonKey(ignore: true)
  _$$_EventEmailLogCopyWith<_$_EventEmailLog> get copyWith =>
      throw _privateConstructorUsedError;
}

AgendaItem _$AgendaItemFromJson(Map<String, dynamic> json) {
  return _AgendaItem.fromJson(json);
}

/// @nodoc
mixin _$AgendaItem {
  String get id => throw _privateConstructorUsedError;
  int? get priority => throw _privateConstructorUsedError;
  String? get creatorId => throw _privateConstructorUsedError;
  String? get title => throw _privateConstructorUsedError;
  String? get content => throw _privateConstructorUsedError;
  AgendaItemVideoType get videoType =>
      throw _privateConstructorUsedError; // TODO: Remove this system of giving a default to nullable items
  @JsonKey(unknownEnumValue: null, name: 'type')
  AgendaItemType? get nullableType => throw _privateConstructorUsedError;
  String? get videoUrl => throw _privateConstructorUsedError;
  String? get imageUrl => throw _privateConstructorUsedError;
  List<String>? get pollAnswers => throw _privateConstructorUsedError;
  int? get timeInSeconds => throw _privateConstructorUsedError;
  String? get suggestionsButtonText => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $AgendaItemCopyWith<AgendaItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AgendaItemCopyWith<$Res> {
  factory $AgendaItemCopyWith(
          AgendaItem value, $Res Function(AgendaItem) then) =
      _$AgendaItemCopyWithImpl<$Res, AgendaItem>;
  @useResult
  $Res call(
      {String id,
      int? priority,
      String? creatorId,
      String? title,
      String? content,
      AgendaItemVideoType videoType,
      @JsonKey(unknownEnumValue: null, name: 'type')
      AgendaItemType? nullableType,
      String? videoUrl,
      String? imageUrl,
      List<String>? pollAnswers,
      int? timeInSeconds,
      String? suggestionsButtonText});
}

/// @nodoc
class _$AgendaItemCopyWithImpl<$Res, $Val extends AgendaItem>
    implements $AgendaItemCopyWith<$Res> {
  _$AgendaItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? priority = freezed,
    Object? creatorId = freezed,
    Object? title = freezed,
    Object? content = freezed,
    Object? videoType = null,
    Object? nullableType = freezed,
    Object? videoUrl = freezed,
    Object? imageUrl = freezed,
    Object? pollAnswers = freezed,
    Object? timeInSeconds = freezed,
    Object? suggestionsButtonText = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      priority: freezed == priority
          ? _value.priority
          : priority // ignore: cast_nullable_to_non_nullable
              as int?,
      creatorId: freezed == creatorId
          ? _value.creatorId
          : creatorId // ignore: cast_nullable_to_non_nullable
              as String?,
      title: freezed == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String?,
      content: freezed == content
          ? _value.content
          : content // ignore: cast_nullable_to_non_nullable
              as String?,
      videoType: null == videoType
          ? _value.videoType
          : videoType // ignore: cast_nullable_to_non_nullable
              as AgendaItemVideoType,
      nullableType: freezed == nullableType
          ? _value.nullableType
          : nullableType // ignore: cast_nullable_to_non_nullable
              as AgendaItemType?,
      videoUrl: freezed == videoUrl
          ? _value.videoUrl
          : videoUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      imageUrl: freezed == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      pollAnswers: freezed == pollAnswers
          ? _value.pollAnswers
          : pollAnswers // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      timeInSeconds: freezed == timeInSeconds
          ? _value.timeInSeconds
          : timeInSeconds // ignore: cast_nullable_to_non_nullable
              as int?,
      suggestionsButtonText: freezed == suggestionsButtonText
          ? _value.suggestionsButtonText
          : suggestionsButtonText // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_AgendaItemCopyWith<$Res>
    implements $AgendaItemCopyWith<$Res> {
  factory _$$_AgendaItemCopyWith(
          _$_AgendaItem value, $Res Function(_$_AgendaItem) then) =
      __$$_AgendaItemCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      int? priority,
      String? creatorId,
      String? title,
      String? content,
      AgendaItemVideoType videoType,
      @JsonKey(unknownEnumValue: null, name: 'type')
      AgendaItemType? nullableType,
      String? videoUrl,
      String? imageUrl,
      List<String>? pollAnswers,
      int? timeInSeconds,
      String? suggestionsButtonText});
}

/// @nodoc
class __$$_AgendaItemCopyWithImpl<$Res>
    extends _$AgendaItemCopyWithImpl<$Res, _$_AgendaItem>
    implements _$$_AgendaItemCopyWith<$Res> {
  __$$_AgendaItemCopyWithImpl(
      _$_AgendaItem _value, $Res Function(_$_AgendaItem) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? priority = freezed,
    Object? creatorId = freezed,
    Object? title = freezed,
    Object? content = freezed,
    Object? videoType = null,
    Object? nullableType = freezed,
    Object? videoUrl = freezed,
    Object? imageUrl = freezed,
    Object? pollAnswers = freezed,
    Object? timeInSeconds = freezed,
    Object? suggestionsButtonText = freezed,
  }) {
    return _then(_$_AgendaItem(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      priority: freezed == priority
          ? _value.priority
          : priority // ignore: cast_nullable_to_non_nullable
              as int?,
      creatorId: freezed == creatorId
          ? _value.creatorId
          : creatorId // ignore: cast_nullable_to_non_nullable
              as String?,
      title: freezed == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String?,
      content: freezed == content
          ? _value.content
          : content // ignore: cast_nullable_to_non_nullable
              as String?,
      videoType: null == videoType
          ? _value.videoType
          : videoType // ignore: cast_nullable_to_non_nullable
              as AgendaItemVideoType,
      nullableType: freezed == nullableType
          ? _value.nullableType
          : nullableType // ignore: cast_nullable_to_non_nullable
              as AgendaItemType?,
      videoUrl: freezed == videoUrl
          ? _value.videoUrl
          : videoUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      imageUrl: freezed == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      pollAnswers: freezed == pollAnswers
          ? _value.pollAnswers
          : pollAnswers // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      timeInSeconds: freezed == timeInSeconds
          ? _value.timeInSeconds
          : timeInSeconds // ignore: cast_nullable_to_non_nullable
              as int?,
      suggestionsButtonText: freezed == suggestionsButtonText
          ? _value.suggestionsButtonText
          : suggestionsButtonText // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_AgendaItem extends _AgendaItem {
  _$_AgendaItem(
      {required this.id,
      this.priority,
      this.creatorId,
      this.title,
      this.content,
      this.videoType = AgendaItemVideoType.url,
      @JsonKey(unknownEnumValue: null, name: 'type') this.nullableType,
      this.videoUrl,
      this.imageUrl,
      this.pollAnswers,
      this.timeInSeconds = AgendaItem.kDefaultTimeInSeconds,
      this.suggestionsButtonText})
      : super._();

  factory _$_AgendaItem.fromJson(Map<String, dynamic> json) =>
      _$$_AgendaItemFromJson(json);

  @override
  final String id;
  @override
  final int? priority;
  @override
  final String? creatorId;
  @override
  final String? title;
  @override
  final String? content;
  @override
  @JsonKey()
  final AgendaItemVideoType videoType;
// TODO: Remove this system of giving a default to nullable items
  @override
  @JsonKey(unknownEnumValue: null, name: 'type')
  final AgendaItemType? nullableType;
  @override
  final String? videoUrl;
  @override
  final String? imageUrl;
  @override
  final List<String>? pollAnswers;
  @override
  @JsonKey()
  final int? timeInSeconds;
  @override
  final String? suggestionsButtonText;

  @override
  String toString() {
    return 'AgendaItem(id: $id, priority: $priority, creatorId: $creatorId, title: $title, content: $content, videoType: $videoType, nullableType: $nullableType, videoUrl: $videoUrl, imageUrl: $imageUrl, pollAnswers: $pollAnswers, timeInSeconds: $timeInSeconds, suggestionsButtonText: $suggestionsButtonText)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_AgendaItem &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.priority, priority) ||
                other.priority == priority) &&
            (identical(other.creatorId, creatorId) ||
                other.creatorId == creatorId) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.content, content) || other.content == content) &&
            (identical(other.videoType, videoType) ||
                other.videoType == videoType) &&
            (identical(other.nullableType, nullableType) ||
                other.nullableType == nullableType) &&
            (identical(other.videoUrl, videoUrl) ||
                other.videoUrl == videoUrl) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl) &&
            const DeepCollectionEquality()
                .equals(other.pollAnswers, pollAnswers) &&
            (identical(other.timeInSeconds, timeInSeconds) ||
                other.timeInSeconds == timeInSeconds) &&
            (identical(other.suggestionsButtonText, suggestionsButtonText) ||
                other.suggestionsButtonText == suggestionsButtonText));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      priority,
      creatorId,
      title,
      content,
      videoType,
      nullableType,
      videoUrl,
      imageUrl,
      const DeepCollectionEquality().hash(pollAnswers),
      timeInSeconds,
      suggestionsButtonText);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_AgendaItemCopyWith<_$_AgendaItem> get copyWith =>
      __$$_AgendaItemCopyWithImpl<_$_AgendaItem>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_AgendaItemToJson(
      this,
    );
  }
}

abstract class _AgendaItem extends AgendaItem {
  factory _AgendaItem(
      {required final String id,
      final int? priority,
      final String? creatorId,
      final String? title,
      final String? content,
      final AgendaItemVideoType videoType,
      @JsonKey(unknownEnumValue: null, name: 'type')
      final AgendaItemType? nullableType,
      final String? videoUrl,
      final String? imageUrl,
      final List<String>? pollAnswers,
      final int? timeInSeconds,
      final String? suggestionsButtonText}) = _$_AgendaItem;
  _AgendaItem._() : super._();

  factory _AgendaItem.fromJson(Map<String, dynamic> json) =
      _$_AgendaItem.fromJson;

  @override
  String get id;
  @override
  int? get priority;
  @override
  String? get creatorId;
  @override
  String? get title;
  @override
  String? get content;
  @override
  AgendaItemVideoType get videoType;
  @override // TODO: Remove this system of giving a default to nullable items
  @JsonKey(unknownEnumValue: null, name: 'type')
  AgendaItemType? get nullableType;
  @override
  String? get videoUrl;
  @override
  String? get imageUrl;
  @override
  List<String>? get pollAnswers;
  @override
  int? get timeInSeconds;
  @override
  String? get suggestionsButtonText;
  @override
  @JsonKey(ignore: true)
  _$$_AgendaItemCopyWith<_$_AgendaItem> get copyWith =>
      throw _privateConstructorUsedError;
}

SuggestedAgendaItem _$SuggestedAgendaItemFromJson(Map<String, dynamic> json) {
  return _SuggestedAgendaItem.fromJson(json);
}

/// @nodoc
mixin _$SuggestedAgendaItem {
  String? get id => throw _privateConstructorUsedError;
  String? get creatorId => throw _privateConstructorUsedError;
  String? get content => throw _privateConstructorUsedError;
  @JsonKey(fromJson: dateTimeFromTimestamp, toJson: serverTimestamp)
  DateTime? get createdDate => throw _privateConstructorUsedError;
  List<String> get upvotedUserIds => throw _privateConstructorUsedError;
  List<String> get downvotedUserIds => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $SuggestedAgendaItemCopyWith<SuggestedAgendaItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SuggestedAgendaItemCopyWith<$Res> {
  factory $SuggestedAgendaItemCopyWith(
          SuggestedAgendaItem value, $Res Function(SuggestedAgendaItem) then) =
      _$SuggestedAgendaItemCopyWithImpl<$Res, SuggestedAgendaItem>;
  @useResult
  $Res call(
      {String? id,
      String? creatorId,
      String? content,
      @JsonKey(fromJson: dateTimeFromTimestamp, toJson: serverTimestamp)
      DateTime? createdDate,
      List<String> upvotedUserIds,
      List<String> downvotedUserIds});
}

/// @nodoc
class _$SuggestedAgendaItemCopyWithImpl<$Res, $Val extends SuggestedAgendaItem>
    implements $SuggestedAgendaItemCopyWith<$Res> {
  _$SuggestedAgendaItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? creatorId = freezed,
    Object? content = freezed,
    Object? createdDate = freezed,
    Object? upvotedUserIds = null,
    Object? downvotedUserIds = null,
  }) {
    return _then(_value.copyWith(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      creatorId: freezed == creatorId
          ? _value.creatorId
          : creatorId // ignore: cast_nullable_to_non_nullable
              as String?,
      content: freezed == content
          ? _value.content
          : content // ignore: cast_nullable_to_non_nullable
              as String?,
      createdDate: freezed == createdDate
          ? _value.createdDate
          : createdDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      upvotedUserIds: null == upvotedUserIds
          ? _value.upvotedUserIds
          : upvotedUserIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
      downvotedUserIds: null == downvotedUserIds
          ? _value.downvotedUserIds
          : downvotedUserIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_SuggestedAgendaItemCopyWith<$Res>
    implements $SuggestedAgendaItemCopyWith<$Res> {
  factory _$$_SuggestedAgendaItemCopyWith(_$_SuggestedAgendaItem value,
          $Res Function(_$_SuggestedAgendaItem) then) =
      __$$_SuggestedAgendaItemCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String? id,
      String? creatorId,
      String? content,
      @JsonKey(fromJson: dateTimeFromTimestamp, toJson: serverTimestamp)
      DateTime? createdDate,
      List<String> upvotedUserIds,
      List<String> downvotedUserIds});
}

/// @nodoc
class __$$_SuggestedAgendaItemCopyWithImpl<$Res>
    extends _$SuggestedAgendaItemCopyWithImpl<$Res, _$_SuggestedAgendaItem>
    implements _$$_SuggestedAgendaItemCopyWith<$Res> {
  __$$_SuggestedAgendaItemCopyWithImpl(_$_SuggestedAgendaItem _value,
      $Res Function(_$_SuggestedAgendaItem) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? creatorId = freezed,
    Object? content = freezed,
    Object? createdDate = freezed,
    Object? upvotedUserIds = null,
    Object? downvotedUserIds = null,
  }) {
    return _then(_$_SuggestedAgendaItem(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      creatorId: freezed == creatorId
          ? _value.creatorId
          : creatorId // ignore: cast_nullable_to_non_nullable
              as String?,
      content: freezed == content
          ? _value.content
          : content // ignore: cast_nullable_to_non_nullable
              as String?,
      createdDate: freezed == createdDate
          ? _value.createdDate
          : createdDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      upvotedUserIds: null == upvotedUserIds
          ? _value.upvotedUserIds
          : upvotedUserIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
      downvotedUserIds: null == downvotedUserIds
          ? _value.downvotedUserIds
          : downvotedUserIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_SuggestedAgendaItem implements _SuggestedAgendaItem {
  _$_SuggestedAgendaItem(
      {this.id,
      this.creatorId,
      this.content,
      @JsonKey(fromJson: dateTimeFromTimestamp, toJson: serverTimestamp)
      this.createdDate,
      this.upvotedUserIds = const [],
      this.downvotedUserIds = const []});

  factory _$_SuggestedAgendaItem.fromJson(Map<String, dynamic> json) =>
      _$$_SuggestedAgendaItemFromJson(json);

  @override
  final String? id;
  @override
  final String? creatorId;
  @override
  final String? content;
  @override
  @JsonKey(fromJson: dateTimeFromTimestamp, toJson: serverTimestamp)
  final DateTime? createdDate;
  @override
  @JsonKey()
  final List<String> upvotedUserIds;
  @override
  @JsonKey()
  final List<String> downvotedUserIds;

  @override
  String toString() {
    return 'SuggestedAgendaItem(id: $id, creatorId: $creatorId, content: $content, createdDate: $createdDate, upvotedUserIds: $upvotedUserIds, downvotedUserIds: $downvotedUserIds)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_SuggestedAgendaItem &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.creatorId, creatorId) ||
                other.creatorId == creatorId) &&
            (identical(other.content, content) || other.content == content) &&
            (identical(other.createdDate, createdDate) ||
                other.createdDate == createdDate) &&
            const DeepCollectionEquality()
                .equals(other.upvotedUserIds, upvotedUserIds) &&
            const DeepCollectionEquality()
                .equals(other.downvotedUserIds, downvotedUserIds));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      creatorId,
      content,
      createdDate,
      const DeepCollectionEquality().hash(upvotedUserIds),
      const DeepCollectionEquality().hash(downvotedUserIds));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_SuggestedAgendaItemCopyWith<_$_SuggestedAgendaItem> get copyWith =>
      __$$_SuggestedAgendaItemCopyWithImpl<_$_SuggestedAgendaItem>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_SuggestedAgendaItemToJson(
      this,
    );
  }
}

abstract class _SuggestedAgendaItem implements SuggestedAgendaItem {
  factory _SuggestedAgendaItem(
      {final String? id,
      final String? creatorId,
      final String? content,
      @JsonKey(fromJson: dateTimeFromTimestamp, toJson: serverTimestamp)
      final DateTime? createdDate,
      final List<String> upvotedUserIds,
      final List<String> downvotedUserIds}) = _$_SuggestedAgendaItem;

  factory _SuggestedAgendaItem.fromJson(Map<String, dynamic> json) =
      _$_SuggestedAgendaItem.fromJson;

  @override
  String? get id;
  @override
  String? get creatorId;
  @override
  String? get content;
  @override
  @JsonKey(fromJson: dateTimeFromTimestamp, toJson: serverTimestamp)
  DateTime? get createdDate;
  @override
  List<String> get upvotedUserIds;
  @override
  List<String> get downvotedUserIds;
  @override
  @JsonKey(ignore: true)
  _$$_SuggestedAgendaItemCopyWith<_$_SuggestedAgendaItem> get copyWith =>
      throw _privateConstructorUsedError;
}

BreakoutRoomDefinition _$BreakoutRoomDefinitionFromJson(
    Map<String, dynamic> json) {
  return _BreakoutRoomDefinition.fromJson(json);
}

/// @nodoc
mixin _$BreakoutRoomDefinition {
  String? get creatorId => throw _privateConstructorUsedError;
  int? get targetParticipants => throw _privateConstructorUsedError;
  @Deprecated('use breakoutQuestions instead')
  List<SurveyQuestion> get questions => throw _privateConstructorUsedError;
  List<BreakoutQuestion> get breakoutQuestions =>
      throw _privateConstructorUsedError;
  List<BreakoutCategory> get categories => throw _privateConstructorUsedError;
  @JsonKey(
      defaultValue: BreakoutAssignmentMethod.targetPerRoom,
      unknownEnumValue: BreakoutAssignmentMethod.targetPerRoom)
  BreakoutAssignmentMethod get assignmentMethod =>
      throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $BreakoutRoomDefinitionCopyWith<BreakoutRoomDefinition> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BreakoutRoomDefinitionCopyWith<$Res> {
  factory $BreakoutRoomDefinitionCopyWith(BreakoutRoomDefinition value,
          $Res Function(BreakoutRoomDefinition) then) =
      _$BreakoutRoomDefinitionCopyWithImpl<$Res, BreakoutRoomDefinition>;
  @useResult
  $Res call(
      {String? creatorId,
      int? targetParticipants,
      @Deprecated('use breakoutQuestions instead')
      List<SurveyQuestion> questions,
      List<BreakoutQuestion> breakoutQuestions,
      List<BreakoutCategory> categories,
      @JsonKey(
          defaultValue: BreakoutAssignmentMethod.targetPerRoom,
          unknownEnumValue: BreakoutAssignmentMethod.targetPerRoom)
      BreakoutAssignmentMethod assignmentMethod});
}

/// @nodoc
class _$BreakoutRoomDefinitionCopyWithImpl<$Res,
        $Val extends BreakoutRoomDefinition>
    implements $BreakoutRoomDefinitionCopyWith<$Res> {
  _$BreakoutRoomDefinitionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? creatorId = freezed,
    Object? targetParticipants = freezed,
    Object? questions = null,
    Object? breakoutQuestions = null,
    Object? categories = null,
    Object? assignmentMethod = null,
  }) {
    return _then(_value.copyWith(
      creatorId: freezed == creatorId
          ? _value.creatorId
          : creatorId // ignore: cast_nullable_to_non_nullable
              as String?,
      targetParticipants: freezed == targetParticipants
          ? _value.targetParticipants
          : targetParticipants // ignore: cast_nullable_to_non_nullable
              as int?,
      questions: null == questions
          ? _value.questions
          : questions // ignore: cast_nullable_to_non_nullable
              as List<SurveyQuestion>,
      breakoutQuestions: null == breakoutQuestions
          ? _value.breakoutQuestions
          : breakoutQuestions // ignore: cast_nullable_to_non_nullable
              as List<BreakoutQuestion>,
      categories: null == categories
          ? _value.categories
          : categories // ignore: cast_nullable_to_non_nullable
              as List<BreakoutCategory>,
      assignmentMethod: null == assignmentMethod
          ? _value.assignmentMethod
          : assignmentMethod // ignore: cast_nullable_to_non_nullable
              as BreakoutAssignmentMethod,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_BreakoutRoomDefinitionCopyWith<$Res>
    implements $BreakoutRoomDefinitionCopyWith<$Res> {
  factory _$$_BreakoutRoomDefinitionCopyWith(_$_BreakoutRoomDefinition value,
          $Res Function(_$_BreakoutRoomDefinition) then) =
      __$$_BreakoutRoomDefinitionCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String? creatorId,
      int? targetParticipants,
      @Deprecated('use breakoutQuestions instead')
      List<SurveyQuestion> questions,
      List<BreakoutQuestion> breakoutQuestions,
      List<BreakoutCategory> categories,
      @JsonKey(
          defaultValue: BreakoutAssignmentMethod.targetPerRoom,
          unknownEnumValue: BreakoutAssignmentMethod.targetPerRoom)
      BreakoutAssignmentMethod assignmentMethod});
}

/// @nodoc
class __$$_BreakoutRoomDefinitionCopyWithImpl<$Res>
    extends _$BreakoutRoomDefinitionCopyWithImpl<$Res,
        _$_BreakoutRoomDefinition>
    implements _$$_BreakoutRoomDefinitionCopyWith<$Res> {
  __$$_BreakoutRoomDefinitionCopyWithImpl(_$_BreakoutRoomDefinition _value,
      $Res Function(_$_BreakoutRoomDefinition) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? creatorId = freezed,
    Object? targetParticipants = freezed,
    Object? questions = null,
    Object? breakoutQuestions = null,
    Object? categories = null,
    Object? assignmentMethod = null,
  }) {
    return _then(_$_BreakoutRoomDefinition(
      creatorId: freezed == creatorId
          ? _value.creatorId
          : creatorId // ignore: cast_nullable_to_non_nullable
              as String?,
      targetParticipants: freezed == targetParticipants
          ? _value.targetParticipants
          : targetParticipants // ignore: cast_nullable_to_non_nullable
              as int?,
      questions: null == questions
          ? _value.questions
          : questions // ignore: cast_nullable_to_non_nullable
              as List<SurveyQuestion>,
      breakoutQuestions: null == breakoutQuestions
          ? _value.breakoutQuestions
          : breakoutQuestions // ignore: cast_nullable_to_non_nullable
              as List<BreakoutQuestion>,
      categories: null == categories
          ? _value.categories
          : categories // ignore: cast_nullable_to_non_nullable
              as List<BreakoutCategory>,
      assignmentMethod: null == assignmentMethod
          ? _value.assignmentMethod
          : assignmentMethod // ignore: cast_nullable_to_non_nullable
              as BreakoutAssignmentMethod,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_BreakoutRoomDefinition implements _BreakoutRoomDefinition {
  _$_BreakoutRoomDefinition(
      {this.creatorId,
      this.targetParticipants,
      @Deprecated('use breakoutQuestions instead') this.questions = const [],
      this.breakoutQuestions = const [],
      this.categories = const [],
      @JsonKey(
          defaultValue: BreakoutAssignmentMethod.targetPerRoom,
          unknownEnumValue: BreakoutAssignmentMethod.targetPerRoom)
      this.assignmentMethod = BreakoutAssignmentMethod.targetPerRoom});

  factory _$_BreakoutRoomDefinition.fromJson(Map<String, dynamic> json) =>
      _$$_BreakoutRoomDefinitionFromJson(json);

  @override
  final String? creatorId;
  @override
  final int? targetParticipants;
  @override
  @JsonKey()
  @Deprecated('use breakoutQuestions instead')
  final List<SurveyQuestion> questions;
  @override
  @JsonKey()
  final List<BreakoutQuestion> breakoutQuestions;
  @override
  @JsonKey()
  final List<BreakoutCategory> categories;
  @override
  @JsonKey(
      defaultValue: BreakoutAssignmentMethod.targetPerRoom,
      unknownEnumValue: BreakoutAssignmentMethod.targetPerRoom)
  final BreakoutAssignmentMethod assignmentMethod;

  @override
  String toString() {
    return 'BreakoutRoomDefinition(creatorId: $creatorId, targetParticipants: $targetParticipants, questions: $questions, breakoutQuestions: $breakoutQuestions, categories: $categories, assignmentMethod: $assignmentMethod)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_BreakoutRoomDefinition &&
            (identical(other.creatorId, creatorId) ||
                other.creatorId == creatorId) &&
            (identical(other.targetParticipants, targetParticipants) ||
                other.targetParticipants == targetParticipants) &&
            const DeepCollectionEquality().equals(other.questions, questions) &&
            const DeepCollectionEquality()
                .equals(other.breakoutQuestions, breakoutQuestions) &&
            const DeepCollectionEquality()
                .equals(other.categories, categories) &&
            (identical(other.assignmentMethod, assignmentMethod) ||
                other.assignmentMethod == assignmentMethod));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      creatorId,
      targetParticipants,
      const DeepCollectionEquality().hash(questions),
      const DeepCollectionEquality().hash(breakoutQuestions),
      const DeepCollectionEquality().hash(categories),
      assignmentMethod);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_BreakoutRoomDefinitionCopyWith<_$_BreakoutRoomDefinition> get copyWith =>
      __$$_BreakoutRoomDefinitionCopyWithImpl<_$_BreakoutRoomDefinition>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_BreakoutRoomDefinitionToJson(
      this,
    );
  }
}

abstract class _BreakoutRoomDefinition implements BreakoutRoomDefinition {
  factory _BreakoutRoomDefinition(
          {final String? creatorId,
          final int? targetParticipants,
          @Deprecated('use breakoutQuestions instead')
          final List<SurveyQuestion> questions,
          final List<BreakoutQuestion> breakoutQuestions,
          final List<BreakoutCategory> categories,
          @JsonKey(
              defaultValue: BreakoutAssignmentMethod.targetPerRoom,
              unknownEnumValue: BreakoutAssignmentMethod.targetPerRoom)
          final BreakoutAssignmentMethod assignmentMethod}) =
      _$_BreakoutRoomDefinition;

  factory _BreakoutRoomDefinition.fromJson(Map<String, dynamic> json) =
      _$_BreakoutRoomDefinition.fromJson;

  @override
  String? get creatorId;
  @override
  int? get targetParticipants;
  @override
  @Deprecated('use breakoutQuestions instead')
  List<SurveyQuestion> get questions;
  @override
  List<BreakoutQuestion> get breakoutQuestions;
  @override
  List<BreakoutCategory> get categories;
  @override
  @JsonKey(
      defaultValue: BreakoutAssignmentMethod.targetPerRoom,
      unknownEnumValue: BreakoutAssignmentMethod.targetPerRoom)
  BreakoutAssignmentMethod get assignmentMethod;
  @override
  @JsonKey(ignore: true)
  _$$_BreakoutRoomDefinitionCopyWith<_$_BreakoutRoomDefinition> get copyWith =>
      throw _privateConstructorUsedError;
}

SurveyQuestion _$SurveyQuestionFromJson(Map<String, dynamic> json) {
  return _SurveyQuestion.fromJson(json);
}

/// @nodoc
mixin _$SurveyQuestion {
  /// The answer options as they were saved.
  List<String>? get answerOptions => throw _privateConstructorUsedError;

  /// Indicates which of the answer options was selected.
  int? get answerIndex => throw _privateConstructorUsedError;
  String? get id => throw _privateConstructorUsedError;
  String? get question => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $SurveyQuestionCopyWith<SurveyQuestion> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SurveyQuestionCopyWith<$Res> {
  factory $SurveyQuestionCopyWith(
          SurveyQuestion value, $Res Function(SurveyQuestion) then) =
      _$SurveyQuestionCopyWithImpl<$Res, SurveyQuestion>;
  @useResult
  $Res call(
      {List<String>? answerOptions,
      int? answerIndex,
      String? id,
      String? question});
}

/// @nodoc
class _$SurveyQuestionCopyWithImpl<$Res, $Val extends SurveyQuestion>
    implements $SurveyQuestionCopyWith<$Res> {
  _$SurveyQuestionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? answerOptions = freezed,
    Object? answerIndex = freezed,
    Object? id = freezed,
    Object? question = freezed,
  }) {
    return _then(_value.copyWith(
      answerOptions: freezed == answerOptions
          ? _value.answerOptions
          : answerOptions // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      answerIndex: freezed == answerIndex
          ? _value.answerIndex
          : answerIndex // ignore: cast_nullable_to_non_nullable
              as int?,
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      question: freezed == question
          ? _value.question
          : question // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_SurveyQuestionCopyWith<$Res>
    implements $SurveyQuestionCopyWith<$Res> {
  factory _$$_SurveyQuestionCopyWith(
          _$_SurveyQuestion value, $Res Function(_$_SurveyQuestion) then) =
      __$$_SurveyQuestionCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {List<String>? answerOptions,
      int? answerIndex,
      String? id,
      String? question});
}

/// @nodoc
class __$$_SurveyQuestionCopyWithImpl<$Res>
    extends _$SurveyQuestionCopyWithImpl<$Res, _$_SurveyQuestion>
    implements _$$_SurveyQuestionCopyWith<$Res> {
  __$$_SurveyQuestionCopyWithImpl(
      _$_SurveyQuestion _value, $Res Function(_$_SurveyQuestion) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? answerOptions = freezed,
    Object? answerIndex = freezed,
    Object? id = freezed,
    Object? question = freezed,
  }) {
    return _then(_$_SurveyQuestion(
      answerOptions: freezed == answerOptions
          ? _value.answerOptions
          : answerOptions // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      answerIndex: freezed == answerIndex
          ? _value.answerIndex
          : answerIndex // ignore: cast_nullable_to_non_nullable
              as int?,
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      question: freezed == question
          ? _value.question
          : question // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_SurveyQuestion implements _SurveyQuestion {
  _$_SurveyQuestion(
      {this.answerOptions, this.answerIndex, this.id, this.question});

  factory _$_SurveyQuestion.fromJson(Map<String, dynamic> json) =>
      _$$_SurveyQuestionFromJson(json);

  /// The answer options as they were saved.
  @override
  final List<String>? answerOptions;

  /// Indicates which of the answer options was selected.
  @override
  final int? answerIndex;
  @override
  final String? id;
  @override
  final String? question;

  @override
  String toString() {
    return 'SurveyQuestion(answerOptions: $answerOptions, answerIndex: $answerIndex, id: $id, question: $question)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_SurveyQuestion &&
            const DeepCollectionEquality()
                .equals(other.answerOptions, answerOptions) &&
            (identical(other.answerIndex, answerIndex) ||
                other.answerIndex == answerIndex) &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.question, question) ||
                other.question == question));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(answerOptions),
      answerIndex,
      id,
      question);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_SurveyQuestionCopyWith<_$_SurveyQuestion> get copyWith =>
      __$$_SurveyQuestionCopyWithImpl<_$_SurveyQuestion>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_SurveyQuestionToJson(
      this,
    );
  }
}

abstract class _SurveyQuestion implements SurveyQuestion {
  factory _SurveyQuestion(
      {final List<String>? answerOptions,
      final int? answerIndex,
      final String? id,
      final String? question}) = _$_SurveyQuestion;

  factory _SurveyQuestion.fromJson(Map<String, dynamic> json) =
      _$_SurveyQuestion.fromJson;

  @override

  /// The answer options as they were saved.
  List<String>? get answerOptions;
  @override

  /// Indicates which of the answer options was selected.
  int? get answerIndex;
  @override
  String? get id;
  @override
  String? get question;
  @override
  @JsonKey(ignore: true)
  _$$_SurveyQuestionCopyWith<_$_SurveyQuestion> get copyWith =>
      throw _privateConstructorUsedError;
}

BreakoutQuestion _$BreakoutQuestionFromJson(Map<String, dynamic> json) {
  return _BreakoutQuestion.fromJson(json);
}

/// @nodoc
mixin _$BreakoutQuestion {
  String get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;

  /// ID of selected answer from Finish RSVP page
  String get answerOptionId => throw _privateConstructorUsedError;
  List<BreakoutAnswer> get answers => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $BreakoutQuestionCopyWith<BreakoutQuestion> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BreakoutQuestionCopyWith<$Res> {
  factory $BreakoutQuestionCopyWith(
          BreakoutQuestion value, $Res Function(BreakoutQuestion) then) =
      _$BreakoutQuestionCopyWithImpl<$Res, BreakoutQuestion>;
  @useResult
  $Res call(
      {String id,
      String title,
      String answerOptionId,
      List<BreakoutAnswer> answers});
}

/// @nodoc
class _$BreakoutQuestionCopyWithImpl<$Res, $Val extends BreakoutQuestion>
    implements $BreakoutQuestionCopyWith<$Res> {
  _$BreakoutQuestionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? answerOptionId = null,
    Object? answers = null,
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
      answerOptionId: null == answerOptionId
          ? _value.answerOptionId
          : answerOptionId // ignore: cast_nullable_to_non_nullable
              as String,
      answers: null == answers
          ? _value.answers
          : answers // ignore: cast_nullable_to_non_nullable
              as List<BreakoutAnswer>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_BreakoutQuestionCopyWith<$Res>
    implements $BreakoutQuestionCopyWith<$Res> {
  factory _$$_BreakoutQuestionCopyWith(
          _$_BreakoutQuestion value, $Res Function(_$_BreakoutQuestion) then) =
      __$$_BreakoutQuestionCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String title,
      String answerOptionId,
      List<BreakoutAnswer> answers});
}

/// @nodoc
class __$$_BreakoutQuestionCopyWithImpl<$Res>
    extends _$BreakoutQuestionCopyWithImpl<$Res, _$_BreakoutQuestion>
    implements _$$_BreakoutQuestionCopyWith<$Res> {
  __$$_BreakoutQuestionCopyWithImpl(
      _$_BreakoutQuestion _value, $Res Function(_$_BreakoutQuestion) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? answerOptionId = null,
    Object? answers = null,
  }) {
    return _then(_$_BreakoutQuestion(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      answerOptionId: null == answerOptionId
          ? _value.answerOptionId
          : answerOptionId // ignore: cast_nullable_to_non_nullable
              as String,
      answers: null == answers
          ? _value.answers
          : answers // ignore: cast_nullable_to_non_nullable
              as List<BreakoutAnswer>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_BreakoutQuestion implements _BreakoutQuestion {
  _$_BreakoutQuestion(
      {required this.id,
      required this.title,
      required this.answerOptionId,
      required this.answers});

  factory _$_BreakoutQuestion.fromJson(Map<String, dynamic> json) =>
      _$$_BreakoutQuestionFromJson(json);

  @override
  final String id;
  @override
  final String title;

  /// ID of selected answer from Finish RSVP page
  @override
  final String answerOptionId;
  @override
  final List<BreakoutAnswer> answers;

  @override
  String toString() {
    return 'BreakoutQuestion(id: $id, title: $title, answerOptionId: $answerOptionId, answers: $answers)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_BreakoutQuestion &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.answerOptionId, answerOptionId) ||
                other.answerOptionId == answerOptionId) &&
            const DeepCollectionEquality().equals(other.answers, answers));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, title, answerOptionId,
      const DeepCollectionEquality().hash(answers));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_BreakoutQuestionCopyWith<_$_BreakoutQuestion> get copyWith =>
      __$$_BreakoutQuestionCopyWithImpl<_$_BreakoutQuestion>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_BreakoutQuestionToJson(
      this,
    );
  }
}

abstract class _BreakoutQuestion implements BreakoutQuestion {
  factory _BreakoutQuestion(
      {required final String id,
      required final String title,
      required final String answerOptionId,
      required final List<BreakoutAnswer> answers}) = _$_BreakoutQuestion;

  factory _BreakoutQuestion.fromJson(Map<String, dynamic> json) =
      _$_BreakoutQuestion.fromJson;

  @override
  String get id;
  @override
  String get title;
  @override

  /// ID of selected answer from Finish RSVP page
  String get answerOptionId;
  @override
  List<BreakoutAnswer> get answers;
  @override
  @JsonKey(ignore: true)
  _$$_BreakoutQuestionCopyWith<_$_BreakoutQuestion> get copyWith =>
      throw _privateConstructorUsedError;
}

BreakoutAnswer _$BreakoutAnswerFromJson(Map<String, dynamic> json) {
  return _BreakoutAnswer.fromJson(json);
}

/// @nodoc
mixin _$BreakoutAnswer {
  String get id => throw _privateConstructorUsedError;
  List<BreakoutAnswerOption> get options => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $BreakoutAnswerCopyWith<BreakoutAnswer> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BreakoutAnswerCopyWith<$Res> {
  factory $BreakoutAnswerCopyWith(
          BreakoutAnswer value, $Res Function(BreakoutAnswer) then) =
      _$BreakoutAnswerCopyWithImpl<$Res, BreakoutAnswer>;
  @useResult
  $Res call({String id, List<BreakoutAnswerOption> options});
}

/// @nodoc
class _$BreakoutAnswerCopyWithImpl<$Res, $Val extends BreakoutAnswer>
    implements $BreakoutAnswerCopyWith<$Res> {
  _$BreakoutAnswerCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? options = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      options: null == options
          ? _value.options
          : options // ignore: cast_nullable_to_non_nullable
              as List<BreakoutAnswerOption>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_BreakoutAnswerCopyWith<$Res>
    implements $BreakoutAnswerCopyWith<$Res> {
  factory _$$_BreakoutAnswerCopyWith(
          _$_BreakoutAnswer value, $Res Function(_$_BreakoutAnswer) then) =
      __$$_BreakoutAnswerCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String id, List<BreakoutAnswerOption> options});
}

/// @nodoc
class __$$_BreakoutAnswerCopyWithImpl<$Res>
    extends _$BreakoutAnswerCopyWithImpl<$Res, _$_BreakoutAnswer>
    implements _$$_BreakoutAnswerCopyWith<$Res> {
  __$$_BreakoutAnswerCopyWithImpl(
      _$_BreakoutAnswer _value, $Res Function(_$_BreakoutAnswer) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? options = null,
  }) {
    return _then(_$_BreakoutAnswer(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      options: null == options
          ? _value.options
          : options // ignore: cast_nullable_to_non_nullable
              as List<BreakoutAnswerOption>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_BreakoutAnswer implements _BreakoutAnswer {
  _$_BreakoutAnswer({required this.id, required this.options});

  factory _$_BreakoutAnswer.fromJson(Map<String, dynamic> json) =>
      _$$_BreakoutAnswerFromJson(json);

  @override
  final String id;
  @override
  final List<BreakoutAnswerOption> options;

  @override
  String toString() {
    return 'BreakoutAnswer(id: $id, options: $options)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_BreakoutAnswer &&
            (identical(other.id, id) || other.id == id) &&
            const DeepCollectionEquality().equals(other.options, options));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType, id, const DeepCollectionEquality().hash(options));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_BreakoutAnswerCopyWith<_$_BreakoutAnswer> get copyWith =>
      __$$_BreakoutAnswerCopyWithImpl<_$_BreakoutAnswer>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_BreakoutAnswerToJson(
      this,
    );
  }
}

abstract class _BreakoutAnswer implements BreakoutAnswer {
  factory _BreakoutAnswer(
      {required final String id,
      required final List<BreakoutAnswerOption> options}) = _$_BreakoutAnswer;

  factory _BreakoutAnswer.fromJson(Map<String, dynamic> json) =
      _$_BreakoutAnswer.fromJson;

  @override
  String get id;
  @override
  List<BreakoutAnswerOption> get options;
  @override
  @JsonKey(ignore: true)
  _$$_BreakoutAnswerCopyWith<_$_BreakoutAnswer> get copyWith =>
      throw _privateConstructorUsedError;
}

BreakoutAnswerOption _$BreakoutAnswerOptionFromJson(Map<String, dynamic> json) {
  return _BreakoutAnswerOption.fromJson(json);
}

/// @nodoc
mixin _$BreakoutAnswerOption {
  String get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $BreakoutAnswerOptionCopyWith<BreakoutAnswerOption> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BreakoutAnswerOptionCopyWith<$Res> {
  factory $BreakoutAnswerOptionCopyWith(BreakoutAnswerOption value,
          $Res Function(BreakoutAnswerOption) then) =
      _$BreakoutAnswerOptionCopyWithImpl<$Res, BreakoutAnswerOption>;
  @useResult
  $Res call({String id, String title});
}

/// @nodoc
class _$BreakoutAnswerOptionCopyWithImpl<$Res,
        $Val extends BreakoutAnswerOption>
    implements $BreakoutAnswerOptionCopyWith<$Res> {
  _$BreakoutAnswerOptionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
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
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_BreakoutAnswerOptionCopyWith<$Res>
    implements $BreakoutAnswerOptionCopyWith<$Res> {
  factory _$$_BreakoutAnswerOptionCopyWith(_$_BreakoutAnswerOption value,
          $Res Function(_$_BreakoutAnswerOption) then) =
      __$$_BreakoutAnswerOptionCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String id, String title});
}

/// @nodoc
class __$$_BreakoutAnswerOptionCopyWithImpl<$Res>
    extends _$BreakoutAnswerOptionCopyWithImpl<$Res, _$_BreakoutAnswerOption>
    implements _$$_BreakoutAnswerOptionCopyWith<$Res> {
  __$$_BreakoutAnswerOptionCopyWithImpl(_$_BreakoutAnswerOption _value,
      $Res Function(_$_BreakoutAnswerOption) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
  }) {
    return _then(_$_BreakoutAnswerOption(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_BreakoutAnswerOption implements _BreakoutAnswerOption {
  _$_BreakoutAnswerOption({required this.id, required this.title});

  factory _$_BreakoutAnswerOption.fromJson(Map<String, dynamic> json) =>
      _$$_BreakoutAnswerOptionFromJson(json);

  @override
  final String id;
  @override
  final String title;

  @override
  String toString() {
    return 'BreakoutAnswerOption(id: $id, title: $title)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_BreakoutAnswerOption &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, title);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_BreakoutAnswerOptionCopyWith<_$_BreakoutAnswerOption> get copyWith =>
      __$$_BreakoutAnswerOptionCopyWithImpl<_$_BreakoutAnswerOption>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_BreakoutAnswerOptionToJson(
      this,
    );
  }
}

abstract class _BreakoutAnswerOption implements BreakoutAnswerOption {
  factory _BreakoutAnswerOption(
      {required final String id,
      required final String title}) = _$_BreakoutAnswerOption;

  factory _BreakoutAnswerOption.fromJson(Map<String, dynamic> json) =
      _$_BreakoutAnswerOption.fromJson;

  @override
  String get id;
  @override
  String get title;
  @override
  @JsonKey(ignore: true)
  _$$_BreakoutAnswerOptionCopyWith<_$_BreakoutAnswerOption> get copyWith =>
      throw _privateConstructorUsedError;
}

BreakoutCategory _$BreakoutCategoryFromJson(Map<String, dynamic> json) {
  return _BreakoutCategory.fromJson(json);
}

/// @nodoc
mixin _$BreakoutCategory {
  String get id => throw _privateConstructorUsedError;
  String get category => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $BreakoutCategoryCopyWith<BreakoutCategory> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BreakoutCategoryCopyWith<$Res> {
  factory $BreakoutCategoryCopyWith(
          BreakoutCategory value, $Res Function(BreakoutCategory) then) =
      _$BreakoutCategoryCopyWithImpl<$Res, BreakoutCategory>;
  @useResult
  $Res call({String id, String category});
}

/// @nodoc
class _$BreakoutCategoryCopyWithImpl<$Res, $Val extends BreakoutCategory>
    implements $BreakoutCategoryCopyWith<$Res> {
  _$BreakoutCategoryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? category = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_BreakoutCategoryCopyWith<$Res>
    implements $BreakoutCategoryCopyWith<$Res> {
  factory _$$_BreakoutCategoryCopyWith(
          _$_BreakoutCategory value, $Res Function(_$_BreakoutCategory) then) =
      __$$_BreakoutCategoryCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String id, String category});
}

/// @nodoc
class __$$_BreakoutCategoryCopyWithImpl<$Res>
    extends _$BreakoutCategoryCopyWithImpl<$Res, _$_BreakoutCategory>
    implements _$$_BreakoutCategoryCopyWith<$Res> {
  __$$_BreakoutCategoryCopyWithImpl(
      _$_BreakoutCategory _value, $Res Function(_$_BreakoutCategory) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? category = null,
  }) {
    return _then(_$_BreakoutCategory(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_BreakoutCategory implements _BreakoutCategory {
  _$_BreakoutCategory({required this.id, required this.category});

  factory _$_BreakoutCategory.fromJson(Map<String, dynamic> json) =>
      _$$_BreakoutCategoryFromJson(json);

  @override
  final String id;
  @override
  final String category;

  @override
  String toString() {
    return 'BreakoutCategory(id: $id, category: $category)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_BreakoutCategory &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.category, category) ||
                other.category == category));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, category);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_BreakoutCategoryCopyWith<_$_BreakoutCategory> get copyWith =>
      __$$_BreakoutCategoryCopyWithImpl<_$_BreakoutCategory>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_BreakoutCategoryToJson(
      this,
    );
  }
}

abstract class _BreakoutCategory implements BreakoutCategory {
  factory _BreakoutCategory(
      {required final String id,
      required final String category}) = _$_BreakoutCategory;

  factory _BreakoutCategory.fromJson(Map<String, dynamic> json) =
      _$_BreakoutCategory.fromJson;

  @override
  String get id;
  @override
  String get category;
  @override
  @JsonKey(ignore: true)
  _$$_BreakoutCategoryCopyWith<_$_BreakoutCategory> get copyWith =>
      throw _privateConstructorUsedError;
}

PlatformItem _$PlatformItemFromJson(Map<String, dynamic> json) {
  return _PlatformItem.fromJson(json);
}

/// @nodoc
mixin _$PlatformItem {
  String? get url => throw _privateConstructorUsedError;
  @JsonKey(defaultValue: PlatformKey.community, unknownEnumValue: null)
  PlatformKey get platformKey => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $PlatformItemCopyWith<PlatformItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PlatformItemCopyWith<$Res> {
  factory $PlatformItemCopyWith(
          PlatformItem value, $Res Function(PlatformItem) then) =
      _$PlatformItemCopyWithImpl<$Res, PlatformItem>;
  @useResult
  $Res call(
      {String? url,
      @JsonKey(defaultValue: PlatformKey.community, unknownEnumValue: null)
      PlatformKey platformKey});
}

/// @nodoc
class _$PlatformItemCopyWithImpl<$Res, $Val extends PlatformItem>
    implements $PlatformItemCopyWith<$Res> {
  _$PlatformItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? url = freezed,
    Object? platformKey = null,
  }) {
    return _then(_value.copyWith(
      url: freezed == url
          ? _value.url
          : url // ignore: cast_nullable_to_non_nullable
              as String?,
      platformKey: null == platformKey
          ? _value.platformKey
          : platformKey // ignore: cast_nullable_to_non_nullable
              as PlatformKey,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_PlatformItemCopyWith<$Res>
    implements $PlatformItemCopyWith<$Res> {
  factory _$$_PlatformItemCopyWith(
          _$_PlatformItem value, $Res Function(_$_PlatformItem) then) =
      __$$_PlatformItemCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String? url,
      @JsonKey(defaultValue: PlatformKey.community, unknownEnumValue: null)
      PlatformKey platformKey});
}

/// @nodoc
class __$$_PlatformItemCopyWithImpl<$Res>
    extends _$PlatformItemCopyWithImpl<$Res, _$_PlatformItem>
    implements _$$_PlatformItemCopyWith<$Res> {
  __$$_PlatformItemCopyWithImpl(
      _$_PlatformItem _value, $Res Function(_$_PlatformItem) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? url = freezed,
    Object? platformKey = null,
  }) {
    return _then(_$_PlatformItem(
      url: freezed == url
          ? _value.url
          : url // ignore: cast_nullable_to_non_nullable
              as String?,
      platformKey: null == platformKey
          ? _value.platformKey
          : platformKey // ignore: cast_nullable_to_non_nullable
              as PlatformKey,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_PlatformItem implements _PlatformItem {
  _$_PlatformItem(
      {this.url,
      @JsonKey(defaultValue: PlatformKey.community, unknownEnumValue: null)
      this.platformKey = PlatformKey.community});

  factory _$_PlatformItem.fromJson(Map<String, dynamic> json) =>
      _$$_PlatformItemFromJson(json);

  @override
  final String? url;
  @override
  @JsonKey(defaultValue: PlatformKey.community, unknownEnumValue: null)
  final PlatformKey platformKey;

  @override
  String toString() {
    return 'PlatformItem(url: $url, platformKey: $platformKey)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_PlatformItem &&
            (identical(other.url, url) || other.url == url) &&
            (identical(other.platformKey, platformKey) ||
                other.platformKey == platformKey));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, url, platformKey);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_PlatformItemCopyWith<_$_PlatformItem> get copyWith =>
      __$$_PlatformItemCopyWithImpl<_$_PlatformItem>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_PlatformItemToJson(
      this,
    );
  }
}

abstract class _PlatformItem implements PlatformItem {
  factory _PlatformItem(
      {final String? url,
      @JsonKey(defaultValue: PlatformKey.community, unknownEnumValue: null)
      final PlatformKey platformKey}) = _$_PlatformItem;

  factory _PlatformItem.fromJson(Map<String, dynamic> json) =
      _$_PlatformItem.fromJson;

  @override
  String? get url;
  @override
  @JsonKey(defaultValue: PlatformKey.community, unknownEnumValue: null)
  PlatformKey get platformKey;
  @override
  @JsonKey(ignore: true)
  _$$_PlatformItemCopyWith<_$_PlatformItem> get copyWith =>
      throw _privateConstructorUsedError;
}

WaitingRoomInfo _$WaitingRoomInfoFromJson(Map<String, dynamic> json) {
  return _WaitingRoomInfo.fromJson(json);
}

/// @nodoc
mixin _$WaitingRoomInfo {
  int get durationSeconds => throw _privateConstructorUsedError;
  int get waitingMediaBufferSeconds => throw _privateConstructorUsedError;
  String? get content => throw _privateConstructorUsedError;
  MediaItem? get waitingMediaItem => throw _privateConstructorUsedError;
  MediaItem? get introMediaItem => throw _privateConstructorUsedError;
  bool get enableChat => throw _privateConstructorUsedError;
  bool get loopWaitingVideo => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $WaitingRoomInfoCopyWith<WaitingRoomInfo> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WaitingRoomInfoCopyWith<$Res> {
  factory $WaitingRoomInfoCopyWith(
          WaitingRoomInfo value, $Res Function(WaitingRoomInfo) then) =
      _$WaitingRoomInfoCopyWithImpl<$Res, WaitingRoomInfo>;
  @useResult
  $Res call(
      {int durationSeconds,
      int waitingMediaBufferSeconds,
      String? content,
      MediaItem? waitingMediaItem,
      MediaItem? introMediaItem,
      bool enableChat,
      bool loopWaitingVideo});

  $MediaItemCopyWith<$Res>? get waitingMediaItem;
  $MediaItemCopyWith<$Res>? get introMediaItem;
}

/// @nodoc
class _$WaitingRoomInfoCopyWithImpl<$Res, $Val extends WaitingRoomInfo>
    implements $WaitingRoomInfoCopyWith<$Res> {
  _$WaitingRoomInfoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? durationSeconds = null,
    Object? waitingMediaBufferSeconds = null,
    Object? content = freezed,
    Object? waitingMediaItem = freezed,
    Object? introMediaItem = freezed,
    Object? enableChat = null,
    Object? loopWaitingVideo = null,
  }) {
    return _then(_value.copyWith(
      durationSeconds: null == durationSeconds
          ? _value.durationSeconds
          : durationSeconds // ignore: cast_nullable_to_non_nullable
              as int,
      waitingMediaBufferSeconds: null == waitingMediaBufferSeconds
          ? _value.waitingMediaBufferSeconds
          : waitingMediaBufferSeconds // ignore: cast_nullable_to_non_nullable
              as int,
      content: freezed == content
          ? _value.content
          : content // ignore: cast_nullable_to_non_nullable
              as String?,
      waitingMediaItem: freezed == waitingMediaItem
          ? _value.waitingMediaItem
          : waitingMediaItem // ignore: cast_nullable_to_non_nullable
              as MediaItem?,
      introMediaItem: freezed == introMediaItem
          ? _value.introMediaItem
          : introMediaItem // ignore: cast_nullable_to_non_nullable
              as MediaItem?,
      enableChat: null == enableChat
          ? _value.enableChat
          : enableChat // ignore: cast_nullable_to_non_nullable
              as bool,
      loopWaitingVideo: null == loopWaitingVideo
          ? _value.loopWaitingVideo
          : loopWaitingVideo // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $MediaItemCopyWith<$Res>? get waitingMediaItem {
    if (_value.waitingMediaItem == null) {
      return null;
    }

    return $MediaItemCopyWith<$Res>(_value.waitingMediaItem!, (value) {
      return _then(_value.copyWith(waitingMediaItem: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $MediaItemCopyWith<$Res>? get introMediaItem {
    if (_value.introMediaItem == null) {
      return null;
    }

    return $MediaItemCopyWith<$Res>(_value.introMediaItem!, (value) {
      return _then(_value.copyWith(introMediaItem: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$_WaitingRoomInfoCopyWith<$Res>
    implements $WaitingRoomInfoCopyWith<$Res> {
  factory _$$_WaitingRoomInfoCopyWith(
          _$_WaitingRoomInfo value, $Res Function(_$_WaitingRoomInfo) then) =
      __$$_WaitingRoomInfoCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int durationSeconds,
      int waitingMediaBufferSeconds,
      String? content,
      MediaItem? waitingMediaItem,
      MediaItem? introMediaItem,
      bool enableChat,
      bool loopWaitingVideo});

  @override
  $MediaItemCopyWith<$Res>? get waitingMediaItem;
  @override
  $MediaItemCopyWith<$Res>? get introMediaItem;
}

/// @nodoc
class __$$_WaitingRoomInfoCopyWithImpl<$Res>
    extends _$WaitingRoomInfoCopyWithImpl<$Res, _$_WaitingRoomInfo>
    implements _$$_WaitingRoomInfoCopyWith<$Res> {
  __$$_WaitingRoomInfoCopyWithImpl(
      _$_WaitingRoomInfo _value, $Res Function(_$_WaitingRoomInfo) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? durationSeconds = null,
    Object? waitingMediaBufferSeconds = null,
    Object? content = freezed,
    Object? waitingMediaItem = freezed,
    Object? introMediaItem = freezed,
    Object? enableChat = null,
    Object? loopWaitingVideo = null,
  }) {
    return _then(_$_WaitingRoomInfo(
      durationSeconds: null == durationSeconds
          ? _value.durationSeconds
          : durationSeconds // ignore: cast_nullable_to_non_nullable
              as int,
      waitingMediaBufferSeconds: null == waitingMediaBufferSeconds
          ? _value.waitingMediaBufferSeconds
          : waitingMediaBufferSeconds // ignore: cast_nullable_to_non_nullable
              as int,
      content: freezed == content
          ? _value.content
          : content // ignore: cast_nullable_to_non_nullable
              as String?,
      waitingMediaItem: freezed == waitingMediaItem
          ? _value.waitingMediaItem
          : waitingMediaItem // ignore: cast_nullable_to_non_nullable
              as MediaItem?,
      introMediaItem: freezed == introMediaItem
          ? _value.introMediaItem
          : introMediaItem // ignore: cast_nullable_to_non_nullable
              as MediaItem?,
      enableChat: null == enableChat
          ? _value.enableChat
          : enableChat // ignore: cast_nullable_to_non_nullable
              as bool,
      loopWaitingVideo: null == loopWaitingVideo
          ? _value.loopWaitingVideo
          : loopWaitingVideo // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_WaitingRoomInfo extends _WaitingRoomInfo {
  const _$_WaitingRoomInfo(
      {this.durationSeconds = 0,
      this.waitingMediaBufferSeconds = 0,
      this.content,
      this.waitingMediaItem,
      this.introMediaItem,
      this.enableChat = false,
      this.loopWaitingVideo = false})
      : super._();

  factory _$_WaitingRoomInfo.fromJson(Map<String, dynamic> json) =>
      _$$_WaitingRoomInfoFromJson(json);

  @override
  @JsonKey()
  final int durationSeconds;
  @override
  @JsonKey()
  final int waitingMediaBufferSeconds;
  @override
  final String? content;
  @override
  final MediaItem? waitingMediaItem;
  @override
  final MediaItem? introMediaItem;
  @override
  @JsonKey()
  final bool enableChat;
  @override
  @JsonKey()
  final bool loopWaitingVideo;

  @override
  String toString() {
    return 'WaitingRoomInfo(durationSeconds: $durationSeconds, waitingMediaBufferSeconds: $waitingMediaBufferSeconds, content: $content, waitingMediaItem: $waitingMediaItem, introMediaItem: $introMediaItem, enableChat: $enableChat, loopWaitingVideo: $loopWaitingVideo)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_WaitingRoomInfo &&
            (identical(other.durationSeconds, durationSeconds) ||
                other.durationSeconds == durationSeconds) &&
            (identical(other.waitingMediaBufferSeconds,
                    waitingMediaBufferSeconds) ||
                other.waitingMediaBufferSeconds == waitingMediaBufferSeconds) &&
            (identical(other.content, content) || other.content == content) &&
            (identical(other.waitingMediaItem, waitingMediaItem) ||
                other.waitingMediaItem == waitingMediaItem) &&
            (identical(other.introMediaItem, introMediaItem) ||
                other.introMediaItem == introMediaItem) &&
            (identical(other.enableChat, enableChat) ||
                other.enableChat == enableChat) &&
            (identical(other.loopWaitingVideo, loopWaitingVideo) ||
                other.loopWaitingVideo == loopWaitingVideo));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      durationSeconds,
      waitingMediaBufferSeconds,
      content,
      waitingMediaItem,
      introMediaItem,
      enableChat,
      loopWaitingVideo);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_WaitingRoomInfoCopyWith<_$_WaitingRoomInfo> get copyWith =>
      __$$_WaitingRoomInfoCopyWithImpl<_$_WaitingRoomInfo>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_WaitingRoomInfoToJson(
      this,
    );
  }
}

abstract class _WaitingRoomInfo extends WaitingRoomInfo {
  const factory _WaitingRoomInfo(
      {final int durationSeconds,
      final int waitingMediaBufferSeconds,
      final String? content,
      final MediaItem? waitingMediaItem,
      final MediaItem? introMediaItem,
      final bool enableChat,
      final bool loopWaitingVideo}) = _$_WaitingRoomInfo;
  const _WaitingRoomInfo._() : super._();

  factory _WaitingRoomInfo.fromJson(Map<String, dynamic> json) =
      _$_WaitingRoomInfo.fromJson;

  @override
  int get durationSeconds;
  @override
  int get waitingMediaBufferSeconds;
  @override
  String? get content;
  @override
  MediaItem? get waitingMediaItem;
  @override
  MediaItem? get introMediaItem;
  @override
  bool get enableChat;
  @override
  bool get loopWaitingVideo;
  @override
  @JsonKey(ignore: true)
  _$$_WaitingRoomInfoCopyWith<_$_WaitingRoomInfo> get copyWith =>
      throw _privateConstructorUsedError;
}
