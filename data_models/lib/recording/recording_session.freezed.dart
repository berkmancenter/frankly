// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'recording_session.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

RecordingSession _$RecordingSessionFromJson(Map<String, dynamic> json) {
  return _RecordingSession.fromJson(json);
}

/// @nodoc
mixin _$RecordingSession {
  String? get sessionId => throw _privateConstructorUsedError;
  String get communityId => throw _privateConstructorUsedError;
  String get eventId => throw _privateConstructorUsedError;
  String get roomId => throw _privateConstructorUsedError;
  @JsonKey(unknownEnumValue: RecordingRoomType.main)
  RecordingRoomType get roomType => throw _privateConstructorUsedError;
  @JsonKey(unknownEnumValue: RecordingSessionStatus.failed)
  RecordingSessionStatus get status => throw _privateConstructorUsedError;
  String get startedBy => throw _privateConstructorUsedError;
  @JsonKey(fromJson: dateTimeFromTimestamp, toJson: serverTimestamp)
  DateTime? get startedAt => throw _privateConstructorUsedError;
  @JsonKey(fromJson: dateTimeFromTimestamp, toJson: serverTimestampOrNull)
  DateTime? get stoppedAt => throw _privateConstructorUsedError;
  String? get breakoutSessionId => throw _privateConstructorUsedError;
  String? get agoraResourceId => throw _privateConstructorUsedError;
  String? get agoraSid => throw _privateConstructorUsedError;
  String? get agoraRttAgentId => throw _privateConstructorUsedError;
  String? get rttLanguage => throw _privateConstructorUsedError;
  String? get gcsPrefix => throw _privateConstructorUsedError;
  String? get chatPath => throw _privateConstructorUsedError;
  String? get errorMessage => throw _privateConstructorUsedError;
  Map<String, String> get artifactPaths => throw _privateConstructorUsedError;
  List<String> get participantIds => throw _privateConstructorUsedError;
  Map<String, String> get uidToDisplayName =>
      throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $RecordingSessionCopyWith<RecordingSession> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RecordingSessionCopyWith<$Res> {
  factory $RecordingSessionCopyWith(
          RecordingSession value, $Res Function(RecordingSession) then) =
      _$RecordingSessionCopyWithImpl<$Res, RecordingSession>;
  @useResult
  $Res call(
      {String? sessionId,
      String communityId,
      String eventId,
      String roomId,
      @JsonKey(unknownEnumValue: RecordingRoomType.main)
      RecordingRoomType roomType,
      @JsonKey(unknownEnumValue: RecordingSessionStatus.failed)
      RecordingSessionStatus status,
      String startedBy,
      @JsonKey(fromJson: dateTimeFromTimestamp, toJson: serverTimestamp)
      DateTime? startedAt,
      @JsonKey(fromJson: dateTimeFromTimestamp, toJson: serverTimestampOrNull)
      DateTime? stoppedAt,
      String? breakoutSessionId,
      String? agoraResourceId,
      String? agoraSid,
      String? agoraRttAgentId,
      String? rttLanguage,
      String? gcsPrefix,
      String? chatPath,
      String? errorMessage,
      Map<String, String> artifactPaths,
      List<String> participantIds,
      Map<String, String> uidToDisplayName});
}

/// @nodoc
class _$RecordingSessionCopyWithImpl<$Res, $Val extends RecordingSession>
    implements $RecordingSessionCopyWith<$Res> {
  _$RecordingSessionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? sessionId = freezed,
    Object? communityId = null,
    Object? eventId = null,
    Object? roomId = null,
    Object? roomType = null,
    Object? status = null,
    Object? startedBy = null,
    Object? startedAt = freezed,
    Object? stoppedAt = freezed,
    Object? breakoutSessionId = freezed,
    Object? agoraResourceId = freezed,
    Object? agoraSid = freezed,
    Object? agoraRttAgentId = freezed,
    Object? rttLanguage = freezed,
    Object? gcsPrefix = freezed,
    Object? chatPath = freezed,
    Object? errorMessage = freezed,
    Object? artifactPaths = null,
    Object? participantIds = null,
    Object? uidToDisplayName = null,
  }) {
    return _then(_value.copyWith(
      sessionId: freezed == sessionId
          ? _value.sessionId
          : sessionId // ignore: cast_nullable_to_non_nullable
              as String?,
      communityId: null == communityId
          ? _value.communityId
          : communityId // ignore: cast_nullable_to_non_nullable
              as String,
      eventId: null == eventId
          ? _value.eventId
          : eventId // ignore: cast_nullable_to_non_nullable
              as String,
      roomId: null == roomId
          ? _value.roomId
          : roomId // ignore: cast_nullable_to_non_nullable
              as String,
      roomType: null == roomType
          ? _value.roomType
          : roomType // ignore: cast_nullable_to_non_nullable
              as RecordingRoomType,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as RecordingSessionStatus,
      startedBy: null == startedBy
          ? _value.startedBy
          : startedBy // ignore: cast_nullable_to_non_nullable
              as String,
      startedAt: freezed == startedAt
          ? _value.startedAt
          : startedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      stoppedAt: freezed == stoppedAt
          ? _value.stoppedAt
          : stoppedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      breakoutSessionId: freezed == breakoutSessionId
          ? _value.breakoutSessionId
          : breakoutSessionId // ignore: cast_nullable_to_non_nullable
              as String?,
      agoraResourceId: freezed == agoraResourceId
          ? _value.agoraResourceId
          : agoraResourceId // ignore: cast_nullable_to_non_nullable
              as String?,
      agoraSid: freezed == agoraSid
          ? _value.agoraSid
          : agoraSid // ignore: cast_nullable_to_non_nullable
              as String?,
      agoraRttAgentId: freezed == agoraRttAgentId
          ? _value.agoraRttAgentId
          : agoraRttAgentId // ignore: cast_nullable_to_non_nullable
              as String?,
      rttLanguage: freezed == rttLanguage
          ? _value.rttLanguage
          : rttLanguage // ignore: cast_nullable_to_non_nullable
              as String?,
      gcsPrefix: freezed == gcsPrefix
          ? _value.gcsPrefix
          : gcsPrefix // ignore: cast_nullable_to_non_nullable
              as String?,
      chatPath: freezed == chatPath
          ? _value.chatPath
          : chatPath // ignore: cast_nullable_to_non_nullable
              as String?,
      errorMessage: freezed == errorMessage
          ? _value.errorMessage
          : errorMessage // ignore: cast_nullable_to_non_nullable
              as String?,
      artifactPaths: null == artifactPaths
          ? _value.artifactPaths
          : artifactPaths // ignore: cast_nullable_to_non_nullable
              as Map<String, String>,
      participantIds: null == participantIds
          ? _value.participantIds
          : participantIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
      uidToDisplayName: null == uidToDisplayName
          ? _value.uidToDisplayName
          : uidToDisplayName // ignore: cast_nullable_to_non_nullable
              as Map<String, String>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_RecordingSessionCopyWith<$Res>
    implements $RecordingSessionCopyWith<$Res> {
  factory _$$_RecordingSessionCopyWith(
          _$_RecordingSession value, $Res Function(_$_RecordingSession) then) =
      __$$_RecordingSessionCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String? sessionId,
      String communityId,
      String eventId,
      String roomId,
      @JsonKey(unknownEnumValue: RecordingRoomType.main)
      RecordingRoomType roomType,
      @JsonKey(unknownEnumValue: RecordingSessionStatus.failed)
      RecordingSessionStatus status,
      String startedBy,
      @JsonKey(fromJson: dateTimeFromTimestamp, toJson: serverTimestamp)
      DateTime? startedAt,
      @JsonKey(fromJson: dateTimeFromTimestamp, toJson: serverTimestampOrNull)
      DateTime? stoppedAt,
      String? breakoutSessionId,
      String? agoraResourceId,
      String? agoraSid,
      String? agoraRttAgentId,
      String? rttLanguage,
      String? gcsPrefix,
      String? chatPath,
      String? errorMessage,
      Map<String, String> artifactPaths,
      List<String> participantIds,
      Map<String, String> uidToDisplayName});
}

/// @nodoc
class __$$_RecordingSessionCopyWithImpl<$Res>
    extends _$RecordingSessionCopyWithImpl<$Res, _$_RecordingSession>
    implements _$$_RecordingSessionCopyWith<$Res> {
  __$$_RecordingSessionCopyWithImpl(
      _$_RecordingSession _value, $Res Function(_$_RecordingSession) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? sessionId = freezed,
    Object? communityId = null,
    Object? eventId = null,
    Object? roomId = null,
    Object? roomType = null,
    Object? status = null,
    Object? startedBy = null,
    Object? startedAt = freezed,
    Object? stoppedAt = freezed,
    Object? breakoutSessionId = freezed,
    Object? agoraResourceId = freezed,
    Object? agoraSid = freezed,
    Object? agoraRttAgentId = freezed,
    Object? rttLanguage = freezed,
    Object? gcsPrefix = freezed,
    Object? chatPath = freezed,
    Object? errorMessage = freezed,
    Object? artifactPaths = null,
    Object? participantIds = null,
    Object? uidToDisplayName = null,
  }) {
    return _then(_$_RecordingSession(
      sessionId: freezed == sessionId
          ? _value.sessionId
          : sessionId // ignore: cast_nullable_to_non_nullable
              as String?,
      communityId: null == communityId
          ? _value.communityId
          : communityId // ignore: cast_nullable_to_non_nullable
              as String,
      eventId: null == eventId
          ? _value.eventId
          : eventId // ignore: cast_nullable_to_non_nullable
              as String,
      roomId: null == roomId
          ? _value.roomId
          : roomId // ignore: cast_nullable_to_non_nullable
              as String,
      roomType: null == roomType
          ? _value.roomType
          : roomType // ignore: cast_nullable_to_non_nullable
              as RecordingRoomType,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as RecordingSessionStatus,
      startedBy: null == startedBy
          ? _value.startedBy
          : startedBy // ignore: cast_nullable_to_non_nullable
              as String,
      startedAt: freezed == startedAt
          ? _value.startedAt
          : startedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      stoppedAt: freezed == stoppedAt
          ? _value.stoppedAt
          : stoppedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      breakoutSessionId: freezed == breakoutSessionId
          ? _value.breakoutSessionId
          : breakoutSessionId // ignore: cast_nullable_to_non_nullable
              as String?,
      agoraResourceId: freezed == agoraResourceId
          ? _value.agoraResourceId
          : agoraResourceId // ignore: cast_nullable_to_non_nullable
              as String?,
      agoraSid: freezed == agoraSid
          ? _value.agoraSid
          : agoraSid // ignore: cast_nullable_to_non_nullable
              as String?,
      agoraRttAgentId: freezed == agoraRttAgentId
          ? _value.agoraRttAgentId
          : agoraRttAgentId // ignore: cast_nullable_to_non_nullable
              as String?,
      rttLanguage: freezed == rttLanguage
          ? _value.rttLanguage
          : rttLanguage // ignore: cast_nullable_to_non_nullable
              as String?,
      gcsPrefix: freezed == gcsPrefix
          ? _value.gcsPrefix
          : gcsPrefix // ignore: cast_nullable_to_non_nullable
              as String?,
      chatPath: freezed == chatPath
          ? _value.chatPath
          : chatPath // ignore: cast_nullable_to_non_nullable
              as String?,
      errorMessage: freezed == errorMessage
          ? _value.errorMessage
          : errorMessage // ignore: cast_nullable_to_non_nullable
              as String?,
      artifactPaths: null == artifactPaths
          ? _value.artifactPaths
          : artifactPaths // ignore: cast_nullable_to_non_nullable
              as Map<String, String>,
      participantIds: null == participantIds
          ? _value.participantIds
          : participantIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
      uidToDisplayName: null == uidToDisplayName
          ? _value.uidToDisplayName
          : uidToDisplayName // ignore: cast_nullable_to_non_nullable
              as Map<String, String>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_RecordingSession implements _RecordingSession {
  _$_RecordingSession(
      {this.sessionId,
      required this.communityId,
      required this.eventId,
      required this.roomId,
      @JsonKey(unknownEnumValue: RecordingRoomType.main) required this.roomType,
      @JsonKey(unknownEnumValue: RecordingSessionStatus.failed)
      required this.status,
      this.startedBy = 'system',
      @JsonKey(fromJson: dateTimeFromTimestamp, toJson: serverTimestamp)
      this.startedAt,
      @JsonKey(fromJson: dateTimeFromTimestamp, toJson: serverTimestampOrNull)
      this.stoppedAt,
      this.breakoutSessionId,
      this.agoraResourceId,
      this.agoraSid,
      this.agoraRttAgentId,
      this.rttLanguage,
      this.gcsPrefix,
      this.chatPath,
      this.errorMessage,
      this.artifactPaths = const {},
      this.participantIds = const [],
      this.uidToDisplayName = const {}});

  factory _$_RecordingSession.fromJson(Map<String, dynamic> json) =>
      _$$_RecordingSessionFromJson(json);

  @override
  final String? sessionId;
  @override
  final String communityId;
  @override
  final String eventId;
  @override
  final String roomId;
  @override
  @JsonKey(unknownEnumValue: RecordingRoomType.main)
  final RecordingRoomType roomType;
  @override
  @JsonKey(unknownEnumValue: RecordingSessionStatus.failed)
  final RecordingSessionStatus status;
  @override
  @JsonKey()
  final String startedBy;
  @override
  @JsonKey(fromJson: dateTimeFromTimestamp, toJson: serverTimestamp)
  final DateTime? startedAt;
  @override
  @JsonKey(fromJson: dateTimeFromTimestamp, toJson: serverTimestampOrNull)
  final DateTime? stoppedAt;
  @override
  final String? breakoutSessionId;
  @override
  final String? agoraResourceId;
  @override
  final String? agoraSid;
  @override
  final String? agoraRttAgentId;
  @override
  final String? rttLanguage;
  @override
  final String? gcsPrefix;
  @override
  final String? chatPath;
  @override
  final String? errorMessage;
  @override
  @JsonKey()
  final Map<String, String> artifactPaths;
  @override
  @JsonKey()
  final List<String> participantIds;
  @override
  @JsonKey()
  final Map<String, String> uidToDisplayName;

  @override
  String toString() {
    return 'RecordingSession(sessionId: $sessionId, communityId: $communityId, eventId: $eventId, roomId: $roomId, roomType: $roomType, status: $status, startedBy: $startedBy, startedAt: $startedAt, stoppedAt: $stoppedAt, breakoutSessionId: $breakoutSessionId, agoraResourceId: $agoraResourceId, agoraSid: $agoraSid, agoraRttAgentId: $agoraRttAgentId, rttLanguage: $rttLanguage, gcsPrefix: $gcsPrefix, chatPath: $chatPath, errorMessage: $errorMessage, artifactPaths: $artifactPaths, participantIds: $participantIds, uidToDisplayName: $uidToDisplayName)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_RecordingSession &&
            (identical(other.sessionId, sessionId) ||
                other.sessionId == sessionId) &&
            (identical(other.communityId, communityId) ||
                other.communityId == communityId) &&
            (identical(other.eventId, eventId) || other.eventId == eventId) &&
            (identical(other.roomId, roomId) || other.roomId == roomId) &&
            (identical(other.roomType, roomType) ||
                other.roomType == roomType) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.startedBy, startedBy) ||
                other.startedBy == startedBy) &&
            (identical(other.startedAt, startedAt) ||
                other.startedAt == startedAt) &&
            (identical(other.stoppedAt, stoppedAt) ||
                other.stoppedAt == stoppedAt) &&
            (identical(other.breakoutSessionId, breakoutSessionId) ||
                other.breakoutSessionId == breakoutSessionId) &&
            (identical(other.agoraResourceId, agoraResourceId) ||
                other.agoraResourceId == agoraResourceId) &&
            (identical(other.agoraSid, agoraSid) ||
                other.agoraSid == agoraSid) &&
            (identical(other.agoraRttAgentId, agoraRttAgentId) ||
                other.agoraRttAgentId == agoraRttAgentId) &&
            (identical(other.rttLanguage, rttLanguage) ||
                other.rttLanguage == rttLanguage) &&
            (identical(other.gcsPrefix, gcsPrefix) ||
                other.gcsPrefix == gcsPrefix) &&
            (identical(other.chatPath, chatPath) ||
                other.chatPath == chatPath) &&
            (identical(other.errorMessage, errorMessage) ||
                other.errorMessage == errorMessage) &&
            const DeepCollectionEquality()
                .equals(other.artifactPaths, artifactPaths) &&
            const DeepCollectionEquality()
                .equals(other.participantIds, participantIds) &&
            const DeepCollectionEquality()
                .equals(other.uidToDisplayName, uidToDisplayName));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        sessionId,
        communityId,
        eventId,
        roomId,
        roomType,
        status,
        startedBy,
        startedAt,
        stoppedAt,
        breakoutSessionId,
        agoraResourceId,
        agoraSid,
        agoraRttAgentId,
        rttLanguage,
        gcsPrefix,
        chatPath,
        errorMessage,
        const DeepCollectionEquality().hash(artifactPaths),
        const DeepCollectionEquality().hash(participantIds),
        const DeepCollectionEquality().hash(uidToDisplayName)
      ]);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_RecordingSessionCopyWith<_$_RecordingSession> get copyWith =>
      __$$_RecordingSessionCopyWithImpl<_$_RecordingSession>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_RecordingSessionToJson(
      this,
    );
  }
}

abstract class _RecordingSession implements RecordingSession {
  factory _RecordingSession(
      {final String? sessionId,
      required final String communityId,
      required final String eventId,
      required final String roomId,
      @JsonKey(unknownEnumValue: RecordingRoomType.main)
      required final RecordingRoomType roomType,
      @JsonKey(unknownEnumValue: RecordingSessionStatus.failed)
      required final RecordingSessionStatus status,
      final String startedBy,
      @JsonKey(fromJson: dateTimeFromTimestamp, toJson: serverTimestamp)
      final DateTime? startedAt,
      @JsonKey(fromJson: dateTimeFromTimestamp, toJson: serverTimestampOrNull)
      final DateTime? stoppedAt,
      final String? breakoutSessionId,
      final String? agoraResourceId,
      final String? agoraSid,
      final String? agoraRttAgentId,
      final String? rttLanguage,
      final String? gcsPrefix,
      final String? chatPath,
      final String? errorMessage,
      final Map<String, String> artifactPaths,
      final List<String> participantIds,
      final Map<String, String> uidToDisplayName}) = _$_RecordingSession;

  factory _RecordingSession.fromJson(Map<String, dynamic> json) =
      _$_RecordingSession.fromJson;

  @override
  String? get sessionId;
  @override
  String get communityId;
  @override
  String get eventId;
  @override
  String get roomId;
  @override
  @JsonKey(unknownEnumValue: RecordingRoomType.main)
  RecordingRoomType get roomType;
  @override
  @JsonKey(unknownEnumValue: RecordingSessionStatus.failed)
  RecordingSessionStatus get status;
  @override
  String get startedBy;
  @override
  @JsonKey(fromJson: dateTimeFromTimestamp, toJson: serverTimestamp)
  DateTime? get startedAt;
  @override
  @JsonKey(fromJson: dateTimeFromTimestamp, toJson: serverTimestampOrNull)
  DateTime? get stoppedAt;
  @override
  String? get breakoutSessionId;
  @override
  String? get agoraResourceId;
  @override
  String? get agoraSid;
  @override
  String? get agoraRttAgentId;
  @override
  String? get rttLanguage;
  @override
  String? get gcsPrefix;
  @override
  String? get chatPath;
  @override
  String? get errorMessage;
  @override
  Map<String, String> get artifactPaths;
  @override
  List<String> get participantIds;
  @override
  Map<String, String> get uidToDisplayName;
  @override
  @JsonKey(ignore: true)
  _$$_RecordingSessionCopyWith<_$_RecordingSession> get copyWith =>
      throw _privateConstructorUsedError;
}
