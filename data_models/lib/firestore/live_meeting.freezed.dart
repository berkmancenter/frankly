// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'live_meeting.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

LiveMeeting _$LiveMeetingFromJson(Map<String, dynamic> json) {
  return _LiveMeeting.fromJson(json);
}

/// @nodoc
mixin _$LiveMeeting {
// TODO(null-safety): There are places that we set various fields on the live meeting possibly
// before the meeting is created with a meeting ID. We should make it required but need to be
// careful since live meeting is updated from many places and if any of them do a non-merge
// it will overwrite this.
  String? get meetingId => throw _privateConstructorUsedError;
  List<LiveMeetingParticipant> get participants =>
      throw _privateConstructorUsedError;
  List<LiveMeetingEvent> get events => throw _privateConstructorUsedError;

  /// This is a copy of the breakout session object
  ///
  /// We could later on not copy but have the client look up the data from the breakout doc.
  BreakoutRoomSession? get currentBreakoutSession =>
      throw _privateConstructorUsedError;
  bool get record => throw _privateConstructorUsedError;
  bool get isMeetingCardMinimized => throw _privateConstructorUsedError;
  List<String> get pinnedUserIds => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $LiveMeetingCopyWith<LiveMeeting> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LiveMeetingCopyWith<$Res> {
  factory $LiveMeetingCopyWith(
          LiveMeeting value, $Res Function(LiveMeeting) then) =
      _$LiveMeetingCopyWithImpl<$Res, LiveMeeting>;
  @useResult
  $Res call(
      {String? meetingId,
      List<LiveMeetingParticipant> participants,
      List<LiveMeetingEvent> events,
      BreakoutRoomSession? currentBreakoutSession,
      bool record,
      bool isMeetingCardMinimized,
      List<String> pinnedUserIds});

  $BreakoutRoomSessionCopyWith<$Res>? get currentBreakoutSession;
}

/// @nodoc
class _$LiveMeetingCopyWithImpl<$Res, $Val extends LiveMeeting>
    implements $LiveMeetingCopyWith<$Res> {
  _$LiveMeetingCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? meetingId = freezed,
    Object? participants = null,
    Object? events = null,
    Object? currentBreakoutSession = freezed,
    Object? record = null,
    Object? isMeetingCardMinimized = null,
    Object? pinnedUserIds = null,
  }) {
    return _then(_value.copyWith(
      meetingId: freezed == meetingId
          ? _value.meetingId
          : meetingId // ignore: cast_nullable_to_non_nullable
              as String?,
      participants: null == participants
          ? _value.participants
          : participants // ignore: cast_nullable_to_non_nullable
              as List<LiveMeetingParticipant>,
      events: null == events
          ? _value.events
          : events // ignore: cast_nullable_to_non_nullable
              as List<LiveMeetingEvent>,
      currentBreakoutSession: freezed == currentBreakoutSession
          ? _value.currentBreakoutSession
          : currentBreakoutSession // ignore: cast_nullable_to_non_nullable
              as BreakoutRoomSession?,
      record: null == record
          ? _value.record
          : record // ignore: cast_nullable_to_non_nullable
              as bool,
      isMeetingCardMinimized: null == isMeetingCardMinimized
          ? _value.isMeetingCardMinimized
          : isMeetingCardMinimized // ignore: cast_nullable_to_non_nullable
              as bool,
      pinnedUserIds: null == pinnedUserIds
          ? _value.pinnedUserIds
          : pinnedUserIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $BreakoutRoomSessionCopyWith<$Res>? get currentBreakoutSession {
    if (_value.currentBreakoutSession == null) {
      return null;
    }

    return $BreakoutRoomSessionCopyWith<$Res>(_value.currentBreakoutSession!,
        (value) {
      return _then(_value.copyWith(currentBreakoutSession: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$_LiveMeetingCopyWith<$Res>
    implements $LiveMeetingCopyWith<$Res> {
  factory _$$_LiveMeetingCopyWith(
          _$_LiveMeeting value, $Res Function(_$_LiveMeeting) then) =
      __$$_LiveMeetingCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String? meetingId,
      List<LiveMeetingParticipant> participants,
      List<LiveMeetingEvent> events,
      BreakoutRoomSession? currentBreakoutSession,
      bool record,
      bool isMeetingCardMinimized,
      List<String> pinnedUserIds});

  @override
  $BreakoutRoomSessionCopyWith<$Res>? get currentBreakoutSession;
}

/// @nodoc
class __$$_LiveMeetingCopyWithImpl<$Res>
    extends _$LiveMeetingCopyWithImpl<$Res, _$_LiveMeeting>
    implements _$$_LiveMeetingCopyWith<$Res> {
  __$$_LiveMeetingCopyWithImpl(
      _$_LiveMeeting _value, $Res Function(_$_LiveMeeting) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? meetingId = freezed,
    Object? participants = null,
    Object? events = null,
    Object? currentBreakoutSession = freezed,
    Object? record = null,
    Object? isMeetingCardMinimized = null,
    Object? pinnedUserIds = null,
  }) {
    return _then(_$_LiveMeeting(
      meetingId: freezed == meetingId
          ? _value.meetingId
          : meetingId // ignore: cast_nullable_to_non_nullable
              as String?,
      participants: null == participants
          ? _value.participants
          : participants // ignore: cast_nullable_to_non_nullable
              as List<LiveMeetingParticipant>,
      events: null == events
          ? _value.events
          : events // ignore: cast_nullable_to_non_nullable
              as List<LiveMeetingEvent>,
      currentBreakoutSession: freezed == currentBreakoutSession
          ? _value.currentBreakoutSession
          : currentBreakoutSession // ignore: cast_nullable_to_non_nullable
              as BreakoutRoomSession?,
      record: null == record
          ? _value.record
          : record // ignore: cast_nullable_to_non_nullable
              as bool,
      isMeetingCardMinimized: null == isMeetingCardMinimized
          ? _value.isMeetingCardMinimized
          : isMeetingCardMinimized // ignore: cast_nullable_to_non_nullable
              as bool,
      pinnedUserIds: null == pinnedUserIds
          ? _value.pinnedUserIds
          : pinnedUserIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_LiveMeeting implements _LiveMeeting {
  _$_LiveMeeting(
      {this.meetingId,
      this.participants = const [],
      this.events = const [],
      this.currentBreakoutSession,
      this.record = false,
      this.isMeetingCardMinimized = false,
      this.pinnedUserIds = const []});

  factory _$_LiveMeeting.fromJson(Map<String, dynamic> json) =>
      _$$_LiveMeetingFromJson(json);

// TODO(null-safety): There are places that we set various fields on the live meeting possibly
// before the meeting is created with a meeting ID. We should make it required but need to be
// careful since live meeting is updated from many places and if any of them do a non-merge
// it will overwrite this.
  @override
  final String? meetingId;
  @override
  @JsonKey()
  final List<LiveMeetingParticipant> participants;
  @override
  @JsonKey()
  final List<LiveMeetingEvent> events;

  /// This is a copy of the breakout session object
  ///
  /// We could later on not copy but have the client look up the data from the breakout doc.
  @override
  final BreakoutRoomSession? currentBreakoutSession;
  @override
  @JsonKey()
  final bool record;
  @override
  @JsonKey()
  final bool isMeetingCardMinimized;
  @override
  @JsonKey()
  final List<String> pinnedUserIds;

  @override
  String toString() {
    return 'LiveMeeting(meetingId: $meetingId, participants: $participants, events: $events, currentBreakoutSession: $currentBreakoutSession, record: $record, isMeetingCardMinimized: $isMeetingCardMinimized, pinnedUserIds: $pinnedUserIds)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_LiveMeeting &&
            (identical(other.meetingId, meetingId) ||
                other.meetingId == meetingId) &&
            const DeepCollectionEquality()
                .equals(other.participants, participants) &&
            const DeepCollectionEquality().equals(other.events, events) &&
            (identical(other.currentBreakoutSession, currentBreakoutSession) ||
                other.currentBreakoutSession == currentBreakoutSession) &&
            (identical(other.record, record) || other.record == record) &&
            (identical(other.isMeetingCardMinimized, isMeetingCardMinimized) ||
                other.isMeetingCardMinimized == isMeetingCardMinimized) &&
            const DeepCollectionEquality()
                .equals(other.pinnedUserIds, pinnedUserIds));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      meetingId,
      const DeepCollectionEquality().hash(participants),
      const DeepCollectionEquality().hash(events),
      currentBreakoutSession,
      record,
      isMeetingCardMinimized,
      const DeepCollectionEquality().hash(pinnedUserIds));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_LiveMeetingCopyWith<_$_LiveMeeting> get copyWith =>
      __$$_LiveMeetingCopyWithImpl<_$_LiveMeeting>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_LiveMeetingToJson(
      this,
    );
  }
}

abstract class _LiveMeeting implements LiveMeeting {
  factory _LiveMeeting(
      {final String? meetingId,
      final List<LiveMeetingParticipant> participants,
      final List<LiveMeetingEvent> events,
      final BreakoutRoomSession? currentBreakoutSession,
      final bool record,
      final bool isMeetingCardMinimized,
      final List<String> pinnedUserIds}) = _$_LiveMeeting;

  factory _LiveMeeting.fromJson(Map<String, dynamic> json) =
      _$_LiveMeeting.fromJson;

  @override // TODO(null-safety): There are places that we set various fields on the live meeting possibly
// before the meeting is created with a meeting ID. We should make it required but need to be
// careful since live meeting is updated from many places and if any of them do a non-merge
// it will overwrite this.
  String? get meetingId;
  @override
  List<LiveMeetingParticipant> get participants;
  @override
  List<LiveMeetingEvent> get events;
  @override

  /// This is a copy of the breakout session object
  ///
  /// We could later on not copy but have the client look up the data from the breakout doc.
  BreakoutRoomSession? get currentBreakoutSession;
  @override
  bool get record;
  @override
  bool get isMeetingCardMinimized;
  @override
  List<String> get pinnedUserIds;
  @override
  @JsonKey(ignore: true)
  _$$_LiveMeetingCopyWith<_$_LiveMeeting> get copyWith =>
      throw _privateConstructorUsedError;
}

LiveMeetingParticipant _$LiveMeetingParticipantFromJson(
    Map<String, dynamic> json) {
  return _LiveMeetingParticipant.fromJson(json);
}

/// @nodoc
mixin _$LiveMeetingParticipant {
  String? get communityId => throw _privateConstructorUsedError;
  String? get meetingId =>
      throw _privateConstructorUsedError; // Temporary ID to store external community user ID mappings
// This should no longer be necessary when/if we switch to Twilio in Flutter
  String? get externalCommunityId => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $LiveMeetingParticipantCopyWith<LiveMeetingParticipant> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LiveMeetingParticipantCopyWith<$Res> {
  factory $LiveMeetingParticipantCopyWith(LiveMeetingParticipant value,
          $Res Function(LiveMeetingParticipant) then) =
      _$LiveMeetingParticipantCopyWithImpl<$Res, LiveMeetingParticipant>;
  @useResult
  $Res call(
      {String? communityId, String? meetingId, String? externalCommunityId});
}

/// @nodoc
class _$LiveMeetingParticipantCopyWithImpl<$Res,
        $Val extends LiveMeetingParticipant>
    implements $LiveMeetingParticipantCopyWith<$Res> {
  _$LiveMeetingParticipantCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? communityId = freezed,
    Object? meetingId = freezed,
    Object? externalCommunityId = freezed,
  }) {
    return _then(_value.copyWith(
      communityId: freezed == communityId
          ? _value.communityId
          : communityId // ignore: cast_nullable_to_non_nullable
              as String?,
      meetingId: freezed == meetingId
          ? _value.meetingId
          : meetingId // ignore: cast_nullable_to_non_nullable
              as String?,
      externalCommunityId: freezed == externalCommunityId
          ? _value.externalCommunityId
          : externalCommunityId // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_LiveMeetingParticipantCopyWith<$Res>
    implements $LiveMeetingParticipantCopyWith<$Res> {
  factory _$$_LiveMeetingParticipantCopyWith(_$_LiveMeetingParticipant value,
          $Res Function(_$_LiveMeetingParticipant) then) =
      __$$_LiveMeetingParticipantCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String? communityId, String? meetingId, String? externalCommunityId});
}

/// @nodoc
class __$$_LiveMeetingParticipantCopyWithImpl<$Res>
    extends _$LiveMeetingParticipantCopyWithImpl<$Res,
        _$_LiveMeetingParticipant>
    implements _$$_LiveMeetingParticipantCopyWith<$Res> {
  __$$_LiveMeetingParticipantCopyWithImpl(_$_LiveMeetingParticipant _value,
      $Res Function(_$_LiveMeetingParticipant) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? communityId = freezed,
    Object? meetingId = freezed,
    Object? externalCommunityId = freezed,
  }) {
    return _then(_$_LiveMeetingParticipant(
      communityId: freezed == communityId
          ? _value.communityId
          : communityId // ignore: cast_nullable_to_non_nullable
              as String?,
      meetingId: freezed == meetingId
          ? _value.meetingId
          : meetingId // ignore: cast_nullable_to_non_nullable
              as String?,
      externalCommunityId: freezed == externalCommunityId
          ? _value.externalCommunityId
          : externalCommunityId // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_LiveMeetingParticipant implements _LiveMeetingParticipant {
  _$_LiveMeetingParticipant(
      {this.communityId, this.meetingId, this.externalCommunityId});

  factory _$_LiveMeetingParticipant.fromJson(Map<String, dynamic> json) =>
      _$$_LiveMeetingParticipantFromJson(json);

  @override
  final String? communityId;
  @override
  final String? meetingId;
// Temporary ID to store external community user ID mappings
// This should no longer be necessary when/if we switch to Twilio in Flutter
  @override
  final String? externalCommunityId;

  @override
  String toString() {
    return 'LiveMeetingParticipant(communityId: $communityId, meetingId: $meetingId, externalCommunityId: $externalCommunityId)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_LiveMeetingParticipant &&
            (identical(other.communityId, communityId) ||
                other.communityId == communityId) &&
            (identical(other.meetingId, meetingId) ||
                other.meetingId == meetingId) &&
            (identical(other.externalCommunityId, externalCommunityId) ||
                other.externalCommunityId == externalCommunityId));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode =>
      Object.hash(runtimeType, communityId, meetingId, externalCommunityId);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_LiveMeetingParticipantCopyWith<_$_LiveMeetingParticipant> get copyWith =>
      __$$_LiveMeetingParticipantCopyWithImpl<_$_LiveMeetingParticipant>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_LiveMeetingParticipantToJson(
      this,
    );
  }
}

abstract class _LiveMeetingParticipant implements LiveMeetingParticipant {
  factory _LiveMeetingParticipant(
      {final String? communityId,
      final String? meetingId,
      final String? externalCommunityId}) = _$_LiveMeetingParticipant;

  factory _LiveMeetingParticipant.fromJson(Map<String, dynamic> json) =
      _$_LiveMeetingParticipant.fromJson;

  @override
  String? get communityId;
  @override
  String? get meetingId;
  @override // Temporary ID to store external community user ID mappings
// This should no longer be necessary when/if we switch to Twilio in Flutter
  String? get externalCommunityId;
  @override
  @JsonKey(ignore: true)
  _$$_LiveMeetingParticipantCopyWith<_$_LiveMeetingParticipant> get copyWith =>
      throw _privateConstructorUsedError;
}

LiveMeetingEvent _$LiveMeetingEventFromJson(Map<String, dynamic> json) {
  return _LiveMeetingEvent.fromJson(json);
}

/// @nodoc
mixin _$LiveMeetingEvent {
  @JsonKey(unknownEnumValue: null)
  LiveMeetingEventType? get event => throw _privateConstructorUsedError;
  DateTime? get timestamp => throw _privateConstructorUsedError;
  String? get agendaItem => throw _privateConstructorUsedError;
  bool? get hostless => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $LiveMeetingEventCopyWith<LiveMeetingEvent> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LiveMeetingEventCopyWith<$Res> {
  factory $LiveMeetingEventCopyWith(
          LiveMeetingEvent value, $Res Function(LiveMeetingEvent) then) =
      _$LiveMeetingEventCopyWithImpl<$Res, LiveMeetingEvent>;
  @useResult
  $Res call(
      {@JsonKey(unknownEnumValue: null) LiveMeetingEventType? event,
      DateTime? timestamp,
      String? agendaItem,
      bool? hostless});
}

/// @nodoc
class _$LiveMeetingEventCopyWithImpl<$Res, $Val extends LiveMeetingEvent>
    implements $LiveMeetingEventCopyWith<$Res> {
  _$LiveMeetingEventCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? event = freezed,
    Object? timestamp = freezed,
    Object? agendaItem = freezed,
    Object? hostless = freezed,
  }) {
    return _then(_value.copyWith(
      event: freezed == event
          ? _value.event
          : event // ignore: cast_nullable_to_non_nullable
              as LiveMeetingEventType?,
      timestamp: freezed == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      agendaItem: freezed == agendaItem
          ? _value.agendaItem
          : agendaItem // ignore: cast_nullable_to_non_nullable
              as String?,
      hostless: freezed == hostless
          ? _value.hostless
          : hostless // ignore: cast_nullable_to_non_nullable
              as bool?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_LiveMeetingEventCopyWith<$Res>
    implements $LiveMeetingEventCopyWith<$Res> {
  factory _$$_LiveMeetingEventCopyWith(
          _$_LiveMeetingEvent value, $Res Function(_$_LiveMeetingEvent) then) =
      __$$_LiveMeetingEventCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(unknownEnumValue: null) LiveMeetingEventType? event,
      DateTime? timestamp,
      String? agendaItem,
      bool? hostless});
}

/// @nodoc
class __$$_LiveMeetingEventCopyWithImpl<$Res>
    extends _$LiveMeetingEventCopyWithImpl<$Res, _$_LiveMeetingEvent>
    implements _$$_LiveMeetingEventCopyWith<$Res> {
  __$$_LiveMeetingEventCopyWithImpl(
      _$_LiveMeetingEvent _value, $Res Function(_$_LiveMeetingEvent) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? event = freezed,
    Object? timestamp = freezed,
    Object? agendaItem = freezed,
    Object? hostless = freezed,
  }) {
    return _then(_$_LiveMeetingEvent(
      event: freezed == event
          ? _value.event
          : event // ignore: cast_nullable_to_non_nullable
              as LiveMeetingEventType?,
      timestamp: freezed == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      agendaItem: freezed == agendaItem
          ? _value.agendaItem
          : agendaItem // ignore: cast_nullable_to_non_nullable
              as String?,
      hostless: freezed == hostless
          ? _value.hostless
          : hostless // ignore: cast_nullable_to_non_nullable
              as bool?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_LiveMeetingEvent implements _LiveMeetingEvent {
  _$_LiveMeetingEvent(
      {@JsonKey(unknownEnumValue: null) this.event,
      this.timestamp,
      this.agendaItem,
      this.hostless = false});

  factory _$_LiveMeetingEvent.fromJson(Map<String, dynamic> json) =>
      _$$_LiveMeetingEventFromJson(json);

  @override
  @JsonKey(unknownEnumValue: null)
  final LiveMeetingEventType? event;
  @override
  final DateTime? timestamp;
  @override
  final String? agendaItem;
  @override
  @JsonKey()
  final bool? hostless;

  @override
  String toString() {
    return 'LiveMeetingEvent(event: $event, timestamp: $timestamp, agendaItem: $agendaItem, hostless: $hostless)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_LiveMeetingEvent &&
            (identical(other.event, event) || other.event == event) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp) &&
            (identical(other.agendaItem, agendaItem) ||
                other.agendaItem == agendaItem) &&
            (identical(other.hostless, hostless) ||
                other.hostless == hostless));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode =>
      Object.hash(runtimeType, event, timestamp, agendaItem, hostless);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_LiveMeetingEventCopyWith<_$_LiveMeetingEvent> get copyWith =>
      __$$_LiveMeetingEventCopyWithImpl<_$_LiveMeetingEvent>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_LiveMeetingEventToJson(
      this,
    );
  }
}

abstract class _LiveMeetingEvent implements LiveMeetingEvent {
  factory _LiveMeetingEvent(
      {@JsonKey(unknownEnumValue: null) final LiveMeetingEventType? event,
      final DateTime? timestamp,
      final String? agendaItem,
      final bool? hostless}) = _$_LiveMeetingEvent;

  factory _LiveMeetingEvent.fromJson(Map<String, dynamic> json) =
      _$_LiveMeetingEvent.fromJson;

  @override
  @JsonKey(unknownEnumValue: null)
  LiveMeetingEventType? get event;
  @override
  DateTime? get timestamp;
  @override
  String? get agendaItem;
  @override
  bool? get hostless;
  @override
  @JsonKey(ignore: true)
  _$$_LiveMeetingEventCopyWith<_$_LiveMeetingEvent> get copyWith =>
      throw _privateConstructorUsedError;
}

LiveMeetingRating _$LiveMeetingRatingFromJson(Map<String, dynamic> json) {
  return _LiveMeetingRating.fromJson(json);
}

/// @nodoc
mixin _$LiveMeetingRating {
  String? get ratingId => throw _privateConstructorUsedError;
  double? get rating => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $LiveMeetingRatingCopyWith<LiveMeetingRating> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LiveMeetingRatingCopyWith<$Res> {
  factory $LiveMeetingRatingCopyWith(
          LiveMeetingRating value, $Res Function(LiveMeetingRating) then) =
      _$LiveMeetingRatingCopyWithImpl<$Res, LiveMeetingRating>;
  @useResult
  $Res call({String? ratingId, double? rating});
}

/// @nodoc
class _$LiveMeetingRatingCopyWithImpl<$Res, $Val extends LiveMeetingRating>
    implements $LiveMeetingRatingCopyWith<$Res> {
  _$LiveMeetingRatingCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? ratingId = freezed,
    Object? rating = freezed,
  }) {
    return _then(_value.copyWith(
      ratingId: freezed == ratingId
          ? _value.ratingId
          : ratingId // ignore: cast_nullable_to_non_nullable
              as String?,
      rating: freezed == rating
          ? _value.rating
          : rating // ignore: cast_nullable_to_non_nullable
              as double?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_LiveMeetingRatingCopyWith<$Res>
    implements $LiveMeetingRatingCopyWith<$Res> {
  factory _$$_LiveMeetingRatingCopyWith(_$_LiveMeetingRating value,
          $Res Function(_$_LiveMeetingRating) then) =
      __$$_LiveMeetingRatingCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String? ratingId, double? rating});
}

/// @nodoc
class __$$_LiveMeetingRatingCopyWithImpl<$Res>
    extends _$LiveMeetingRatingCopyWithImpl<$Res, _$_LiveMeetingRating>
    implements _$$_LiveMeetingRatingCopyWith<$Res> {
  __$$_LiveMeetingRatingCopyWithImpl(
      _$_LiveMeetingRating _value, $Res Function(_$_LiveMeetingRating) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? ratingId = freezed,
    Object? rating = freezed,
  }) {
    return _then(_$_LiveMeetingRating(
      ratingId: freezed == ratingId
          ? _value.ratingId
          : ratingId // ignore: cast_nullable_to_non_nullable
              as String?,
      rating: freezed == rating
          ? _value.rating
          : rating // ignore: cast_nullable_to_non_nullable
              as double?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_LiveMeetingRating implements _LiveMeetingRating {
  _$_LiveMeetingRating({this.ratingId, this.rating});

  factory _$_LiveMeetingRating.fromJson(Map<String, dynamic> json) =>
      _$$_LiveMeetingRatingFromJson(json);

  @override
  final String? ratingId;
  @override
  final double? rating;

  @override
  String toString() {
    return 'LiveMeetingRating(ratingId: $ratingId, rating: $rating)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_LiveMeetingRating &&
            (identical(other.ratingId, ratingId) ||
                other.ratingId == ratingId) &&
            (identical(other.rating, rating) || other.rating == rating));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, ratingId, rating);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_LiveMeetingRatingCopyWith<_$_LiveMeetingRating> get copyWith =>
      __$$_LiveMeetingRatingCopyWithImpl<_$_LiveMeetingRating>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_LiveMeetingRatingToJson(
      this,
    );
  }
}

abstract class _LiveMeetingRating implements LiveMeetingRating {
  factory _LiveMeetingRating({final String? ratingId, final double? rating}) =
      _$_LiveMeetingRating;

  factory _LiveMeetingRating.fromJson(Map<String, dynamic> json) =
      _$_LiveMeetingRating.fromJson;

  @override
  String? get ratingId;
  @override
  double? get rating;
  @override
  @JsonKey(ignore: true)
  _$$_LiveMeetingRatingCopyWith<_$_LiveMeetingRating> get copyWith =>
      throw _privateConstructorUsedError;
}

BreakoutRoom _$BreakoutRoomFromJson(Map<String, dynamic> json) {
  return _BreakoutRoom.fromJson(json);
}

/// @nodoc
mixin _$BreakoutRoom {
  String get roomId => throw _privateConstructorUsedError;
  String get roomName => throw _privateConstructorUsedError;

  /// This field is used in pagination to show earlier rooms first.
  /// We don't use alphabetical because waiting room needs to come first.
  int get orderingPriority => throw _privateConstructorUsedError;
  String get creatorId => throw _privateConstructorUsedError;
  List<String> get participantIds => throw _privateConstructorUsedError;
  List<String> get originalParticipantIdsAssignment =>
      throw _privateConstructorUsedError;
  @JsonKey(
      defaultValue: BreakoutRoomFlagStatus.unflagged,
      unknownEnumValue: BreakoutRoomFlagStatus.unflagged)
  BreakoutRoomFlagStatus get flagStatus => throw _privateConstructorUsedError;
  @JsonKey(fromJson: dateTimeFromTimestamp, toJson: serverTimestamp)
  DateTime? get createdDate => throw _privateConstructorUsedError;
  bool get record => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $BreakoutRoomCopyWith<BreakoutRoom> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BreakoutRoomCopyWith<$Res> {
  factory $BreakoutRoomCopyWith(
          BreakoutRoom value, $Res Function(BreakoutRoom) then) =
      _$BreakoutRoomCopyWithImpl<$Res, BreakoutRoom>;
  @useResult
  $Res call(
      {String roomId,
      String roomName,
      int orderingPriority,
      String creatorId,
      List<String> participantIds,
      List<String> originalParticipantIdsAssignment,
      @JsonKey(
          defaultValue: BreakoutRoomFlagStatus.unflagged,
          unknownEnumValue: BreakoutRoomFlagStatus.unflagged)
      BreakoutRoomFlagStatus flagStatus,
      @JsonKey(fromJson: dateTimeFromTimestamp, toJson: serverTimestamp)
      DateTime? createdDate,
      bool record});
}

/// @nodoc
class _$BreakoutRoomCopyWithImpl<$Res, $Val extends BreakoutRoom>
    implements $BreakoutRoomCopyWith<$Res> {
  _$BreakoutRoomCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? roomId = null,
    Object? roomName = null,
    Object? orderingPriority = null,
    Object? creatorId = null,
    Object? participantIds = null,
    Object? originalParticipantIdsAssignment = null,
    Object? flagStatus = null,
    Object? createdDate = freezed,
    Object? record = null,
  }) {
    return _then(_value.copyWith(
      roomId: null == roomId
          ? _value.roomId
          : roomId // ignore: cast_nullable_to_non_nullable
              as String,
      roomName: null == roomName
          ? _value.roomName
          : roomName // ignore: cast_nullable_to_non_nullable
              as String,
      orderingPriority: null == orderingPriority
          ? _value.orderingPriority
          : orderingPriority // ignore: cast_nullable_to_non_nullable
              as int,
      creatorId: null == creatorId
          ? _value.creatorId
          : creatorId // ignore: cast_nullable_to_non_nullable
              as String,
      participantIds: null == participantIds
          ? _value.participantIds
          : participantIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
      originalParticipantIdsAssignment: null == originalParticipantIdsAssignment
          ? _value.originalParticipantIdsAssignment
          : originalParticipantIdsAssignment // ignore: cast_nullable_to_non_nullable
              as List<String>,
      flagStatus: null == flagStatus
          ? _value.flagStatus
          : flagStatus // ignore: cast_nullable_to_non_nullable
              as BreakoutRoomFlagStatus,
      createdDate: freezed == createdDate
          ? _value.createdDate
          : createdDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      record: null == record
          ? _value.record
          : record // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_BreakoutRoomCopyWith<$Res>
    implements $BreakoutRoomCopyWith<$Res> {
  factory _$$_BreakoutRoomCopyWith(
          _$_BreakoutRoom value, $Res Function(_$_BreakoutRoom) then) =
      __$$_BreakoutRoomCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String roomId,
      String roomName,
      int orderingPriority,
      String creatorId,
      List<String> participantIds,
      List<String> originalParticipantIdsAssignment,
      @JsonKey(
          defaultValue: BreakoutRoomFlagStatus.unflagged,
          unknownEnumValue: BreakoutRoomFlagStatus.unflagged)
      BreakoutRoomFlagStatus flagStatus,
      @JsonKey(fromJson: dateTimeFromTimestamp, toJson: serverTimestamp)
      DateTime? createdDate,
      bool record});
}

/// @nodoc
class __$$_BreakoutRoomCopyWithImpl<$Res>
    extends _$BreakoutRoomCopyWithImpl<$Res, _$_BreakoutRoom>
    implements _$$_BreakoutRoomCopyWith<$Res> {
  __$$_BreakoutRoomCopyWithImpl(
      _$_BreakoutRoom _value, $Res Function(_$_BreakoutRoom) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? roomId = null,
    Object? roomName = null,
    Object? orderingPriority = null,
    Object? creatorId = null,
    Object? participantIds = null,
    Object? originalParticipantIdsAssignment = null,
    Object? flagStatus = null,
    Object? createdDate = freezed,
    Object? record = null,
  }) {
    return _then(_$_BreakoutRoom(
      roomId: null == roomId
          ? _value.roomId
          : roomId // ignore: cast_nullable_to_non_nullable
              as String,
      roomName: null == roomName
          ? _value.roomName
          : roomName // ignore: cast_nullable_to_non_nullable
              as String,
      orderingPriority: null == orderingPriority
          ? _value.orderingPriority
          : orderingPriority // ignore: cast_nullable_to_non_nullable
              as int,
      creatorId: null == creatorId
          ? _value.creatorId
          : creatorId // ignore: cast_nullable_to_non_nullable
              as String,
      participantIds: null == participantIds
          ? _value.participantIds
          : participantIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
      originalParticipantIdsAssignment: null == originalParticipantIdsAssignment
          ? _value.originalParticipantIdsAssignment
          : originalParticipantIdsAssignment // ignore: cast_nullable_to_non_nullable
              as List<String>,
      flagStatus: null == flagStatus
          ? _value.flagStatus
          : flagStatus // ignore: cast_nullable_to_non_nullable
              as BreakoutRoomFlagStatus,
      createdDate: freezed == createdDate
          ? _value.createdDate
          : createdDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      record: null == record
          ? _value.record
          : record // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_BreakoutRoom implements _BreakoutRoom {
  _$_BreakoutRoom(
      {required this.roomId,
      required this.roomName,
      required this.orderingPriority,
      required this.creatorId,
      this.participantIds = const [],
      this.originalParticipantIdsAssignment = const [],
      @JsonKey(
          defaultValue: BreakoutRoomFlagStatus.unflagged,
          unknownEnumValue: BreakoutRoomFlagStatus.unflagged)
      this.flagStatus = BreakoutRoomFlagStatus.unflagged,
      @JsonKey(fromJson: dateTimeFromTimestamp, toJson: serverTimestamp)
      this.createdDate,
      this.record = false});

  factory _$_BreakoutRoom.fromJson(Map<String, dynamic> json) =>
      _$$_BreakoutRoomFromJson(json);

  @override
  final String roomId;
  @override
  final String roomName;

  /// This field is used in pagination to show earlier rooms first.
  /// We don't use alphabetical because waiting room needs to come first.
  @override
  final int orderingPriority;
  @override
  final String creatorId;
  @override
  @JsonKey()
  final List<String> participantIds;
  @override
  @JsonKey()
  final List<String> originalParticipantIdsAssignment;
  @override
  @JsonKey(
      defaultValue: BreakoutRoomFlagStatus.unflagged,
      unknownEnumValue: BreakoutRoomFlagStatus.unflagged)
  final BreakoutRoomFlagStatus flagStatus;
  @override
  @JsonKey(fromJson: dateTimeFromTimestamp, toJson: serverTimestamp)
  final DateTime? createdDate;
  @override
  @JsonKey()
  final bool record;

  @override
  String toString() {
    return 'BreakoutRoom(roomId: $roomId, roomName: $roomName, orderingPriority: $orderingPriority, creatorId: $creatorId, participantIds: $participantIds, originalParticipantIdsAssignment: $originalParticipantIdsAssignment, flagStatus: $flagStatus, createdDate: $createdDate, record: $record)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_BreakoutRoom &&
            (identical(other.roomId, roomId) || other.roomId == roomId) &&
            (identical(other.roomName, roomName) ||
                other.roomName == roomName) &&
            (identical(other.orderingPriority, orderingPriority) ||
                other.orderingPriority == orderingPriority) &&
            (identical(other.creatorId, creatorId) ||
                other.creatorId == creatorId) &&
            const DeepCollectionEquality()
                .equals(other.participantIds, participantIds) &&
            const DeepCollectionEquality().equals(
                other.originalParticipantIdsAssignment,
                originalParticipantIdsAssignment) &&
            (identical(other.flagStatus, flagStatus) ||
                other.flagStatus == flagStatus) &&
            (identical(other.createdDate, createdDate) ||
                other.createdDate == createdDate) &&
            (identical(other.record, record) || other.record == record));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      roomId,
      roomName,
      orderingPriority,
      creatorId,
      const DeepCollectionEquality().hash(participantIds),
      const DeepCollectionEquality().hash(originalParticipantIdsAssignment),
      flagStatus,
      createdDate,
      record);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_BreakoutRoomCopyWith<_$_BreakoutRoom> get copyWith =>
      __$$_BreakoutRoomCopyWithImpl<_$_BreakoutRoom>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_BreakoutRoomToJson(
      this,
    );
  }
}

abstract class _BreakoutRoom implements BreakoutRoom {
  factory _BreakoutRoom(
      {required final String roomId,
      required final String roomName,
      required final int orderingPriority,
      required final String creatorId,
      final List<String> participantIds,
      final List<String> originalParticipantIdsAssignment,
      @JsonKey(
          defaultValue: BreakoutRoomFlagStatus.unflagged,
          unknownEnumValue: BreakoutRoomFlagStatus.unflagged)
      final BreakoutRoomFlagStatus flagStatus,
      @JsonKey(fromJson: dateTimeFromTimestamp, toJson: serverTimestamp)
      final DateTime? createdDate,
      final bool record}) = _$_BreakoutRoom;

  factory _BreakoutRoom.fromJson(Map<String, dynamic> json) =
      _$_BreakoutRoom.fromJson;

  @override
  String get roomId;
  @override
  String get roomName;
  @override

  /// This field is used in pagination to show earlier rooms first.
  /// We don't use alphabetical because waiting room needs to come first.
  int get orderingPriority;
  @override
  String get creatorId;
  @override
  List<String> get participantIds;
  @override
  List<String> get originalParticipantIdsAssignment;
  @override
  @JsonKey(
      defaultValue: BreakoutRoomFlagStatus.unflagged,
      unknownEnumValue: BreakoutRoomFlagStatus.unflagged)
  BreakoutRoomFlagStatus get flagStatus;
  @override
  @JsonKey(fromJson: dateTimeFromTimestamp, toJson: serverTimestamp)
  DateTime? get createdDate;
  @override
  bool get record;
  @override
  @JsonKey(ignore: true)
  _$$_BreakoutRoomCopyWith<_$_BreakoutRoom> get copyWith =>
      throw _privateConstructorUsedError;
}

BreakoutRoomSession _$BreakoutRoomSessionFromJson(Map<String, dynamic> json) {
  return _BreakoutRoomSession.fromJson(json);
}

/// @nodoc
mixin _$BreakoutRoomSession {
  String get breakoutRoomSessionId => throw _privateConstructorUsedError;
  @JsonKey(unknownEnumValue: null)
  BreakoutRoomStatus? get breakoutRoomStatus =>
      throw _privateConstructorUsedError;
  @JsonKey(fromJson: dateTimeFromTimestamp, toJson: serverTimestamp)
  DateTime? get statusUpdatedTime => throw _privateConstructorUsedError;
  BreakoutAssignmentMethod get assignmentMethod =>
      throw _privateConstructorUsedError;
  int get targetParticipantsPerRoom => throw _privateConstructorUsedError;
  bool get hasWaitingRoom => throw _privateConstructorUsedError;
  int? get maxRoomNumber => throw _privateConstructorUsedError;
  @JsonKey(fromJson: dateTimeFromTimestamp, toJson: serverTimestamp)
  DateTime? get createdDate => throw _privateConstructorUsedError;
  @JsonKey(fromJson: dateTimeFromTimestamp, toJson: timestampFromDateTime)
  DateTime? get scheduledTime => throw _privateConstructorUsedError;

  /// Generated ID that lets callers know who is currently processing assignments.
  String? get processingId => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $BreakoutRoomSessionCopyWith<BreakoutRoomSession> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BreakoutRoomSessionCopyWith<$Res> {
  factory $BreakoutRoomSessionCopyWith(
          BreakoutRoomSession value, $Res Function(BreakoutRoomSession) then) =
      _$BreakoutRoomSessionCopyWithImpl<$Res, BreakoutRoomSession>;
  @useResult
  $Res call(
      {String breakoutRoomSessionId,
      @JsonKey(unknownEnumValue: null) BreakoutRoomStatus? breakoutRoomStatus,
      @JsonKey(fromJson: dateTimeFromTimestamp, toJson: serverTimestamp)
      DateTime? statusUpdatedTime,
      BreakoutAssignmentMethod assignmentMethod,
      int targetParticipantsPerRoom,
      bool hasWaitingRoom,
      int? maxRoomNumber,
      @JsonKey(fromJson: dateTimeFromTimestamp, toJson: serverTimestamp)
      DateTime? createdDate,
      @JsonKey(fromJson: dateTimeFromTimestamp, toJson: timestampFromDateTime)
      DateTime? scheduledTime,
      String? processingId});
}

/// @nodoc
class _$BreakoutRoomSessionCopyWithImpl<$Res, $Val extends BreakoutRoomSession>
    implements $BreakoutRoomSessionCopyWith<$Res> {
  _$BreakoutRoomSessionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? breakoutRoomSessionId = null,
    Object? breakoutRoomStatus = freezed,
    Object? statusUpdatedTime = freezed,
    Object? assignmentMethod = null,
    Object? targetParticipantsPerRoom = null,
    Object? hasWaitingRoom = null,
    Object? maxRoomNumber = freezed,
    Object? createdDate = freezed,
    Object? scheduledTime = freezed,
    Object? processingId = freezed,
  }) {
    return _then(_value.copyWith(
      breakoutRoomSessionId: null == breakoutRoomSessionId
          ? _value.breakoutRoomSessionId
          : breakoutRoomSessionId // ignore: cast_nullable_to_non_nullable
              as String,
      breakoutRoomStatus: freezed == breakoutRoomStatus
          ? _value.breakoutRoomStatus
          : breakoutRoomStatus // ignore: cast_nullable_to_non_nullable
              as BreakoutRoomStatus?,
      statusUpdatedTime: freezed == statusUpdatedTime
          ? _value.statusUpdatedTime
          : statusUpdatedTime // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      assignmentMethod: null == assignmentMethod
          ? _value.assignmentMethod
          : assignmentMethod // ignore: cast_nullable_to_non_nullable
              as BreakoutAssignmentMethod,
      targetParticipantsPerRoom: null == targetParticipantsPerRoom
          ? _value.targetParticipantsPerRoom
          : targetParticipantsPerRoom // ignore: cast_nullable_to_non_nullable
              as int,
      hasWaitingRoom: null == hasWaitingRoom
          ? _value.hasWaitingRoom
          : hasWaitingRoom // ignore: cast_nullable_to_non_nullable
              as bool,
      maxRoomNumber: freezed == maxRoomNumber
          ? _value.maxRoomNumber
          : maxRoomNumber // ignore: cast_nullable_to_non_nullable
              as int?,
      createdDate: freezed == createdDate
          ? _value.createdDate
          : createdDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      scheduledTime: freezed == scheduledTime
          ? _value.scheduledTime
          : scheduledTime // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      processingId: freezed == processingId
          ? _value.processingId
          : processingId // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_BreakoutRoomSessionCopyWith<$Res>
    implements $BreakoutRoomSessionCopyWith<$Res> {
  factory _$$_BreakoutRoomSessionCopyWith(_$_BreakoutRoomSession value,
          $Res Function(_$_BreakoutRoomSession) then) =
      __$$_BreakoutRoomSessionCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String breakoutRoomSessionId,
      @JsonKey(unknownEnumValue: null) BreakoutRoomStatus? breakoutRoomStatus,
      @JsonKey(fromJson: dateTimeFromTimestamp, toJson: serverTimestamp)
      DateTime? statusUpdatedTime,
      BreakoutAssignmentMethod assignmentMethod,
      int targetParticipantsPerRoom,
      bool hasWaitingRoom,
      int? maxRoomNumber,
      @JsonKey(fromJson: dateTimeFromTimestamp, toJson: serverTimestamp)
      DateTime? createdDate,
      @JsonKey(fromJson: dateTimeFromTimestamp, toJson: timestampFromDateTime)
      DateTime? scheduledTime,
      String? processingId});
}

/// @nodoc
class __$$_BreakoutRoomSessionCopyWithImpl<$Res>
    extends _$BreakoutRoomSessionCopyWithImpl<$Res, _$_BreakoutRoomSession>
    implements _$$_BreakoutRoomSessionCopyWith<$Res> {
  __$$_BreakoutRoomSessionCopyWithImpl(_$_BreakoutRoomSession _value,
      $Res Function(_$_BreakoutRoomSession) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? breakoutRoomSessionId = null,
    Object? breakoutRoomStatus = freezed,
    Object? statusUpdatedTime = freezed,
    Object? assignmentMethod = null,
    Object? targetParticipantsPerRoom = null,
    Object? hasWaitingRoom = null,
    Object? maxRoomNumber = freezed,
    Object? createdDate = freezed,
    Object? scheduledTime = freezed,
    Object? processingId = freezed,
  }) {
    return _then(_$_BreakoutRoomSession(
      breakoutRoomSessionId: null == breakoutRoomSessionId
          ? _value.breakoutRoomSessionId
          : breakoutRoomSessionId // ignore: cast_nullable_to_non_nullable
              as String,
      breakoutRoomStatus: freezed == breakoutRoomStatus
          ? _value.breakoutRoomStatus
          : breakoutRoomStatus // ignore: cast_nullable_to_non_nullable
              as BreakoutRoomStatus?,
      statusUpdatedTime: freezed == statusUpdatedTime
          ? _value.statusUpdatedTime
          : statusUpdatedTime // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      assignmentMethod: null == assignmentMethod
          ? _value.assignmentMethod
          : assignmentMethod // ignore: cast_nullable_to_non_nullable
              as BreakoutAssignmentMethod,
      targetParticipantsPerRoom: null == targetParticipantsPerRoom
          ? _value.targetParticipantsPerRoom
          : targetParticipantsPerRoom // ignore: cast_nullable_to_non_nullable
              as int,
      hasWaitingRoom: null == hasWaitingRoom
          ? _value.hasWaitingRoom
          : hasWaitingRoom // ignore: cast_nullable_to_non_nullable
              as bool,
      maxRoomNumber: freezed == maxRoomNumber
          ? _value.maxRoomNumber
          : maxRoomNumber // ignore: cast_nullable_to_non_nullable
              as int?,
      createdDate: freezed == createdDate
          ? _value.createdDate
          : createdDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      scheduledTime: freezed == scheduledTime
          ? _value.scheduledTime
          : scheduledTime // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      processingId: freezed == processingId
          ? _value.processingId
          : processingId // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_BreakoutRoomSession implements _BreakoutRoomSession {
  _$_BreakoutRoomSession(
      {required this.breakoutRoomSessionId,
      @JsonKey(unknownEnumValue: null) this.breakoutRoomStatus,
      @JsonKey(fromJson: dateTimeFromTimestamp, toJson: serverTimestamp)
      this.statusUpdatedTime,
      required this.assignmentMethod,
      required this.targetParticipantsPerRoom,
      required this.hasWaitingRoom,
      this.maxRoomNumber,
      @JsonKey(fromJson: dateTimeFromTimestamp, toJson: serverTimestamp)
      this.createdDate,
      @JsonKey(fromJson: dateTimeFromTimestamp, toJson: timestampFromDateTime)
      this.scheduledTime,
      this.processingId});

  factory _$_BreakoutRoomSession.fromJson(Map<String, dynamic> json) =>
      _$$_BreakoutRoomSessionFromJson(json);

  @override
  final String breakoutRoomSessionId;
  @override
  @JsonKey(unknownEnumValue: null)
  final BreakoutRoomStatus? breakoutRoomStatus;
  @override
  @JsonKey(fromJson: dateTimeFromTimestamp, toJson: serverTimestamp)
  final DateTime? statusUpdatedTime;
  @override
  final BreakoutAssignmentMethod assignmentMethod;
  @override
  final int targetParticipantsPerRoom;
  @override
  final bool hasWaitingRoom;
  @override
  final int? maxRoomNumber;
  @override
  @JsonKey(fromJson: dateTimeFromTimestamp, toJson: serverTimestamp)
  final DateTime? createdDate;
  @override
  @JsonKey(fromJson: dateTimeFromTimestamp, toJson: timestampFromDateTime)
  final DateTime? scheduledTime;

  /// Generated ID that lets callers know who is currently processing assignments.
  @override
  final String? processingId;

  @override
  String toString() {
    return 'BreakoutRoomSession(breakoutRoomSessionId: $breakoutRoomSessionId, breakoutRoomStatus: $breakoutRoomStatus, statusUpdatedTime: $statusUpdatedTime, assignmentMethod: $assignmentMethod, targetParticipantsPerRoom: $targetParticipantsPerRoom, hasWaitingRoom: $hasWaitingRoom, maxRoomNumber: $maxRoomNumber, createdDate: $createdDate, scheduledTime: $scheduledTime, processingId: $processingId)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_BreakoutRoomSession &&
            (identical(other.breakoutRoomSessionId, breakoutRoomSessionId) ||
                other.breakoutRoomSessionId == breakoutRoomSessionId) &&
            (identical(other.breakoutRoomStatus, breakoutRoomStatus) ||
                other.breakoutRoomStatus == breakoutRoomStatus) &&
            (identical(other.statusUpdatedTime, statusUpdatedTime) ||
                other.statusUpdatedTime == statusUpdatedTime) &&
            (identical(other.assignmentMethod, assignmentMethod) ||
                other.assignmentMethod == assignmentMethod) &&
            (identical(other.targetParticipantsPerRoom,
                    targetParticipantsPerRoom) ||
                other.targetParticipantsPerRoom == targetParticipantsPerRoom) &&
            (identical(other.hasWaitingRoom, hasWaitingRoom) ||
                other.hasWaitingRoom == hasWaitingRoom) &&
            (identical(other.maxRoomNumber, maxRoomNumber) ||
                other.maxRoomNumber == maxRoomNumber) &&
            (identical(other.createdDate, createdDate) ||
                other.createdDate == createdDate) &&
            (identical(other.scheduledTime, scheduledTime) ||
                other.scheduledTime == scheduledTime) &&
            (identical(other.processingId, processingId) ||
                other.processingId == processingId));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      breakoutRoomSessionId,
      breakoutRoomStatus,
      statusUpdatedTime,
      assignmentMethod,
      targetParticipantsPerRoom,
      hasWaitingRoom,
      maxRoomNumber,
      createdDate,
      scheduledTime,
      processingId);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_BreakoutRoomSessionCopyWith<_$_BreakoutRoomSession> get copyWith =>
      __$$_BreakoutRoomSessionCopyWithImpl<_$_BreakoutRoomSession>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_BreakoutRoomSessionToJson(
      this,
    );
  }
}

abstract class _BreakoutRoomSession implements BreakoutRoomSession {
  factory _BreakoutRoomSession(
      {required final String breakoutRoomSessionId,
      @JsonKey(unknownEnumValue: null)
      final BreakoutRoomStatus? breakoutRoomStatus,
      @JsonKey(fromJson: dateTimeFromTimestamp, toJson: serverTimestamp)
      final DateTime? statusUpdatedTime,
      required final BreakoutAssignmentMethod assignmentMethod,
      required final int targetParticipantsPerRoom,
      required final bool hasWaitingRoom,
      final int? maxRoomNumber,
      @JsonKey(fromJson: dateTimeFromTimestamp, toJson: serverTimestamp)
      final DateTime? createdDate,
      @JsonKey(fromJson: dateTimeFromTimestamp, toJson: timestampFromDateTime)
      final DateTime? scheduledTime,
      final String? processingId}) = _$_BreakoutRoomSession;

  factory _BreakoutRoomSession.fromJson(Map<String, dynamic> json) =
      _$_BreakoutRoomSession.fromJson;

  @override
  String get breakoutRoomSessionId;
  @override
  @JsonKey(unknownEnumValue: null)
  BreakoutRoomStatus? get breakoutRoomStatus;
  @override
  @JsonKey(fromJson: dateTimeFromTimestamp, toJson: serverTimestamp)
  DateTime? get statusUpdatedTime;
  @override
  BreakoutAssignmentMethod get assignmentMethod;
  @override
  int get targetParticipantsPerRoom;
  @override
  bool get hasWaitingRoom;
  @override
  int? get maxRoomNumber;
  @override
  @JsonKey(fromJson: dateTimeFromTimestamp, toJson: serverTimestamp)
  DateTime? get createdDate;
  @override
  @JsonKey(fromJson: dateTimeFromTimestamp, toJson: timestampFromDateTime)
  DateTime? get scheduledTime;
  @override

  /// Generated ID that lets callers know who is currently processing assignments.
  String? get processingId;
  @override
  @JsonKey(ignore: true)
  _$$_BreakoutRoomSessionCopyWith<_$_BreakoutRoomSession> get copyWith =>
      throw _privateConstructorUsedError;
}
