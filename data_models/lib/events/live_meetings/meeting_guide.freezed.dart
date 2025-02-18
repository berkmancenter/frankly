// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'meeting_guide.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

ParticipantAgendaItemDetails _$ParticipantAgendaItemDetailsFromJson(
    Map<String, dynamic> json) {
  return _ParticipantAgendaItemDetails.fromJson(json);
}

/// @nodoc
mixin _$ParticipantAgendaItemDetails {
  String? get userId => throw _privateConstructorUsedError;
  String? get agendaItemId => throw _privateConstructorUsedError;
  String? get meetingId => throw _privateConstructorUsedError;
  bool? get readyToAdvance => throw _privateConstructorUsedError;

  /// Indicates if a user has raised their hand during the video call.
  @JsonKey(fromJson: dateTimeFromTimestamp, toJson: timestampFromDateTime)
  DateTime? get handRaisedTime => throw _privateConstructorUsedError;

  /// This users response to a poll for this agenda item.
  String? get pollResponse => throw _privateConstructorUsedError;
  List<String> get wordCloudResponses => throw _privateConstructorUsedError;
  List<MeetingUserSuggestion> get suggestions =>
      throw _privateConstructorUsedError; // Participant's position within a video
  double? get videoCurrentTime => throw _privateConstructorUsedError;
  double? get videoDuration => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ParticipantAgendaItemDetailsCopyWith<ParticipantAgendaItemDetails>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ParticipantAgendaItemDetailsCopyWith<$Res> {
  factory $ParticipantAgendaItemDetailsCopyWith(
          ParticipantAgendaItemDetails value,
          $Res Function(ParticipantAgendaItemDetails) then) =
      _$ParticipantAgendaItemDetailsCopyWithImpl<$Res,
          ParticipantAgendaItemDetails>;
  @useResult
  $Res call(
      {String? userId,
      String? agendaItemId,
      String? meetingId,
      bool? readyToAdvance,
      @JsonKey(fromJson: dateTimeFromTimestamp, toJson: timestampFromDateTime)
      DateTime? handRaisedTime,
      String? pollResponse,
      List<String> wordCloudResponses,
      List<MeetingUserSuggestion> suggestions,
      double? videoCurrentTime,
      double? videoDuration});
}

/// @nodoc
class _$ParticipantAgendaItemDetailsCopyWithImpl<$Res,
        $Val extends ParticipantAgendaItemDetails>
    implements $ParticipantAgendaItemDetailsCopyWith<$Res> {
  _$ParticipantAgendaItemDetailsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = freezed,
    Object? agendaItemId = freezed,
    Object? meetingId = freezed,
    Object? readyToAdvance = freezed,
    Object? handRaisedTime = freezed,
    Object? pollResponse = freezed,
    Object? wordCloudResponses = null,
    Object? suggestions = null,
    Object? videoCurrentTime = freezed,
    Object? videoDuration = freezed,
  }) {
    return _then(_value.copyWith(
      userId: freezed == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String?,
      agendaItemId: freezed == agendaItemId
          ? _value.agendaItemId
          : agendaItemId // ignore: cast_nullable_to_non_nullable
              as String?,
      meetingId: freezed == meetingId
          ? _value.meetingId
          : meetingId // ignore: cast_nullable_to_non_nullable
              as String?,
      readyToAdvance: freezed == readyToAdvance
          ? _value.readyToAdvance
          : readyToAdvance // ignore: cast_nullable_to_non_nullable
              as bool?,
      handRaisedTime: freezed == handRaisedTime
          ? _value.handRaisedTime
          : handRaisedTime // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      pollResponse: freezed == pollResponse
          ? _value.pollResponse
          : pollResponse // ignore: cast_nullable_to_non_nullable
              as String?,
      wordCloudResponses: null == wordCloudResponses
          ? _value.wordCloudResponses
          : wordCloudResponses // ignore: cast_nullable_to_non_nullable
              as List<String>,
      suggestions: null == suggestions
          ? _value.suggestions
          : suggestions // ignore: cast_nullable_to_non_nullable
              as List<MeetingUserSuggestion>,
      videoCurrentTime: freezed == videoCurrentTime
          ? _value.videoCurrentTime
          : videoCurrentTime // ignore: cast_nullable_to_non_nullable
              as double?,
      videoDuration: freezed == videoDuration
          ? _value.videoDuration
          : videoDuration // ignore: cast_nullable_to_non_nullable
              as double?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_ParticipantAgendaItemDetailsCopyWith<$Res>
    implements $ParticipantAgendaItemDetailsCopyWith<$Res> {
  factory _$$_ParticipantAgendaItemDetailsCopyWith(
          _$_ParticipantAgendaItemDetails value,
          $Res Function(_$_ParticipantAgendaItemDetails) then) =
      __$$_ParticipantAgendaItemDetailsCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String? userId,
      String? agendaItemId,
      String? meetingId,
      bool? readyToAdvance,
      @JsonKey(fromJson: dateTimeFromTimestamp, toJson: timestampFromDateTime)
      DateTime? handRaisedTime,
      String? pollResponse,
      List<String> wordCloudResponses,
      List<MeetingUserSuggestion> suggestions,
      double? videoCurrentTime,
      double? videoDuration});
}

/// @nodoc
class __$$_ParticipantAgendaItemDetailsCopyWithImpl<$Res>
    extends _$ParticipantAgendaItemDetailsCopyWithImpl<$Res,
        _$_ParticipantAgendaItemDetails>
    implements _$$_ParticipantAgendaItemDetailsCopyWith<$Res> {
  __$$_ParticipantAgendaItemDetailsCopyWithImpl(
      _$_ParticipantAgendaItemDetails _value,
      $Res Function(_$_ParticipantAgendaItemDetails) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = freezed,
    Object? agendaItemId = freezed,
    Object? meetingId = freezed,
    Object? readyToAdvance = freezed,
    Object? handRaisedTime = freezed,
    Object? pollResponse = freezed,
    Object? wordCloudResponses = null,
    Object? suggestions = null,
    Object? videoCurrentTime = freezed,
    Object? videoDuration = freezed,
  }) {
    return _then(_$_ParticipantAgendaItemDetails(
      userId: freezed == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String?,
      agendaItemId: freezed == agendaItemId
          ? _value.agendaItemId
          : agendaItemId // ignore: cast_nullable_to_non_nullable
              as String?,
      meetingId: freezed == meetingId
          ? _value.meetingId
          : meetingId // ignore: cast_nullable_to_non_nullable
              as String?,
      readyToAdvance: freezed == readyToAdvance
          ? _value.readyToAdvance
          : readyToAdvance // ignore: cast_nullable_to_non_nullable
              as bool?,
      handRaisedTime: freezed == handRaisedTime
          ? _value.handRaisedTime
          : handRaisedTime // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      pollResponse: freezed == pollResponse
          ? _value.pollResponse
          : pollResponse // ignore: cast_nullable_to_non_nullable
              as String?,
      wordCloudResponses: null == wordCloudResponses
          ? _value.wordCloudResponses
          : wordCloudResponses // ignore: cast_nullable_to_non_nullable
              as List<String>,
      suggestions: null == suggestions
          ? _value.suggestions
          : suggestions // ignore: cast_nullable_to_non_nullable
              as List<MeetingUserSuggestion>,
      videoCurrentTime: freezed == videoCurrentTime
          ? _value.videoCurrentTime
          : videoCurrentTime // ignore: cast_nullable_to_non_nullable
              as double?,
      videoDuration: freezed == videoDuration
          ? _value.videoDuration
          : videoDuration // ignore: cast_nullable_to_non_nullable
              as double?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_ParticipantAgendaItemDetails implements _ParticipantAgendaItemDetails {
  _$_ParticipantAgendaItemDetails(
      {this.userId,
      this.agendaItemId,
      this.meetingId,
      this.readyToAdvance,
      @JsonKey(fromJson: dateTimeFromTimestamp, toJson: timestampFromDateTime)
      this.handRaisedTime,
      this.pollResponse,
      this.wordCloudResponses = const [],
      this.suggestions = const [],
      this.videoCurrentTime,
      this.videoDuration});

  factory _$_ParticipantAgendaItemDetails.fromJson(Map<String, dynamic> json) =>
      _$$_ParticipantAgendaItemDetailsFromJson(json);

  @override
  final String? userId;
  @override
  final String? agendaItemId;
  @override
  final String? meetingId;
  @override
  final bool? readyToAdvance;

  /// Indicates if a user has raised their hand during the video call.
  @override
  @JsonKey(fromJson: dateTimeFromTimestamp, toJson: timestampFromDateTime)
  final DateTime? handRaisedTime;

  /// This users response to a poll for this agenda item.
  @override
  final String? pollResponse;
  @override
  @JsonKey()
  final List<String> wordCloudResponses;
  @override
  @JsonKey()
  final List<MeetingUserSuggestion> suggestions;
// Participant's position within a video
  @override
  final double? videoCurrentTime;
  @override
  final double? videoDuration;

  @override
  String toString() {
    return 'ParticipantAgendaItemDetails(userId: $userId, agendaItemId: $agendaItemId, meetingId: $meetingId, readyToAdvance: $readyToAdvance, handRaisedTime: $handRaisedTime, pollResponse: $pollResponse, wordCloudResponses: $wordCloudResponses, suggestions: $suggestions, videoCurrentTime: $videoCurrentTime, videoDuration: $videoDuration)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_ParticipantAgendaItemDetails &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.agendaItemId, agendaItemId) ||
                other.agendaItemId == agendaItemId) &&
            (identical(other.meetingId, meetingId) ||
                other.meetingId == meetingId) &&
            (identical(other.readyToAdvance, readyToAdvance) ||
                other.readyToAdvance == readyToAdvance) &&
            (identical(other.handRaisedTime, handRaisedTime) ||
                other.handRaisedTime == handRaisedTime) &&
            (identical(other.pollResponse, pollResponse) ||
                other.pollResponse == pollResponse) &&
            const DeepCollectionEquality()
                .equals(other.wordCloudResponses, wordCloudResponses) &&
            const DeepCollectionEquality()
                .equals(other.suggestions, suggestions) &&
            (identical(other.videoCurrentTime, videoCurrentTime) ||
                other.videoCurrentTime == videoCurrentTime) &&
            (identical(other.videoDuration, videoDuration) ||
                other.videoDuration == videoDuration));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      userId,
      agendaItemId,
      meetingId,
      readyToAdvance,
      handRaisedTime,
      pollResponse,
      const DeepCollectionEquality().hash(wordCloudResponses),
      const DeepCollectionEquality().hash(suggestions),
      videoCurrentTime,
      videoDuration);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_ParticipantAgendaItemDetailsCopyWith<_$_ParticipantAgendaItemDetails>
      get copyWith => __$$_ParticipantAgendaItemDetailsCopyWithImpl<
          _$_ParticipantAgendaItemDetails>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_ParticipantAgendaItemDetailsToJson(
      this,
    );
  }
}

abstract class _ParticipantAgendaItemDetails
    implements ParticipantAgendaItemDetails {
  factory _ParticipantAgendaItemDetails(
      {final String? userId,
      final String? agendaItemId,
      final String? meetingId,
      final bool? readyToAdvance,
      @JsonKey(fromJson: dateTimeFromTimestamp, toJson: timestampFromDateTime)
      final DateTime? handRaisedTime,
      final String? pollResponse,
      final List<String> wordCloudResponses,
      final List<MeetingUserSuggestion> suggestions,
      final double? videoCurrentTime,
      final double? videoDuration}) = _$_ParticipantAgendaItemDetails;

  factory _ParticipantAgendaItemDetails.fromJson(Map<String, dynamic> json) =
      _$_ParticipantAgendaItemDetails.fromJson;

  @override
  String? get userId;
  @override
  String? get agendaItemId;
  @override
  String? get meetingId;
  @override
  bool? get readyToAdvance;
  @override

  /// Indicates if a user has raised their hand during the video call.
  @JsonKey(fromJson: dateTimeFromTimestamp, toJson: timestampFromDateTime)
  DateTime? get handRaisedTime;
  @override

  /// This users response to a poll for this agenda item.
  String? get pollResponse;
  @override
  List<String> get wordCloudResponses;
  @override
  List<MeetingUserSuggestion> get suggestions;
  @override // Participant's position within a video
  double? get videoCurrentTime;
  @override
  double? get videoDuration;
  @override
  @JsonKey(ignore: true)
  _$$_ParticipantAgendaItemDetailsCopyWith<_$_ParticipantAgendaItemDetails>
      get copyWith => throw _privateConstructorUsedError;
}

MeetingUserSuggestion _$MeetingUserSuggestionFromJson(
    Map<String, dynamic> json) {
  return _MeetingUserSuggestion.fromJson(json);
}

/// @nodoc
mixin _$MeetingUserSuggestion {
  String get id => throw _privateConstructorUsedError;
  String get suggestion => throw _privateConstructorUsedError;
  List<String> get likedByIds => throw _privateConstructorUsedError;
  List<String> get dislikedByIds => throw _privateConstructorUsedError;
  @JsonKey(fromJson: dateTimeFromTimestamp, toJson: timestampFromDateTime)
  DateTime? get createdDate => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $MeetingUserSuggestionCopyWith<MeetingUserSuggestion> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MeetingUserSuggestionCopyWith<$Res> {
  factory $MeetingUserSuggestionCopyWith(MeetingUserSuggestion value,
          $Res Function(MeetingUserSuggestion) then) =
      _$MeetingUserSuggestionCopyWithImpl<$Res, MeetingUserSuggestion>;
  @useResult
  $Res call(
      {String id,
      String suggestion,
      List<String> likedByIds,
      List<String> dislikedByIds,
      @JsonKey(fromJson: dateTimeFromTimestamp, toJson: timestampFromDateTime)
      DateTime? createdDate});
}

/// @nodoc
class _$MeetingUserSuggestionCopyWithImpl<$Res,
        $Val extends MeetingUserSuggestion>
    implements $MeetingUserSuggestionCopyWith<$Res> {
  _$MeetingUserSuggestionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? suggestion = null,
    Object? likedByIds = null,
    Object? dislikedByIds = null,
    Object? createdDate = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      suggestion: null == suggestion
          ? _value.suggestion
          : suggestion // ignore: cast_nullable_to_non_nullable
              as String,
      likedByIds: null == likedByIds
          ? _value.likedByIds
          : likedByIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
      dislikedByIds: null == dislikedByIds
          ? _value.dislikedByIds
          : dislikedByIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
      createdDate: freezed == createdDate
          ? _value.createdDate
          : createdDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_MeetingUserSuggestionCopyWith<$Res>
    implements $MeetingUserSuggestionCopyWith<$Res> {
  factory _$$_MeetingUserSuggestionCopyWith(_$_MeetingUserSuggestion value,
          $Res Function(_$_MeetingUserSuggestion) then) =
      __$$_MeetingUserSuggestionCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String suggestion,
      List<String> likedByIds,
      List<String> dislikedByIds,
      @JsonKey(fromJson: dateTimeFromTimestamp, toJson: timestampFromDateTime)
      DateTime? createdDate});
}

/// @nodoc
class __$$_MeetingUserSuggestionCopyWithImpl<$Res>
    extends _$MeetingUserSuggestionCopyWithImpl<$Res, _$_MeetingUserSuggestion>
    implements _$$_MeetingUserSuggestionCopyWith<$Res> {
  __$$_MeetingUserSuggestionCopyWithImpl(_$_MeetingUserSuggestion _value,
      $Res Function(_$_MeetingUserSuggestion) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? suggestion = null,
    Object? likedByIds = null,
    Object? dislikedByIds = null,
    Object? createdDate = freezed,
  }) {
    return _then(_$_MeetingUserSuggestion(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      suggestion: null == suggestion
          ? _value.suggestion
          : suggestion // ignore: cast_nullable_to_non_nullable
              as String,
      likedByIds: null == likedByIds
          ? _value.likedByIds
          : likedByIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
      dislikedByIds: null == dislikedByIds
          ? _value.dislikedByIds
          : dislikedByIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
      createdDate: freezed == createdDate
          ? _value.createdDate
          : createdDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_MeetingUserSuggestion extends _MeetingUserSuggestion {
  _$_MeetingUserSuggestion(
      {required this.id,
      required this.suggestion,
      this.likedByIds = const [],
      this.dislikedByIds = const [],
      @JsonKey(fromJson: dateTimeFromTimestamp, toJson: timestampFromDateTime)
      this.createdDate})
      : super._();

  factory _$_MeetingUserSuggestion.fromJson(Map<String, dynamic> json) =>
      _$$_MeetingUserSuggestionFromJson(json);

  @override
  final String id;
  @override
  final String suggestion;
  @override
  @JsonKey()
  final List<String> likedByIds;
  @override
  @JsonKey()
  final List<String> dislikedByIds;
  @override
  @JsonKey(fromJson: dateTimeFromTimestamp, toJson: timestampFromDateTime)
  final DateTime? createdDate;

  @override
  String toString() {
    return 'MeetingUserSuggestion(id: $id, suggestion: $suggestion, likedByIds: $likedByIds, dislikedByIds: $dislikedByIds, createdDate: $createdDate)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_MeetingUserSuggestion &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.suggestion, suggestion) ||
                other.suggestion == suggestion) &&
            const DeepCollectionEquality()
                .equals(other.likedByIds, likedByIds) &&
            const DeepCollectionEquality()
                .equals(other.dislikedByIds, dislikedByIds) &&
            (identical(other.createdDate, createdDate) ||
                other.createdDate == createdDate));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      suggestion,
      const DeepCollectionEquality().hash(likedByIds),
      const DeepCollectionEquality().hash(dislikedByIds),
      createdDate);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_MeetingUserSuggestionCopyWith<_$_MeetingUserSuggestion> get copyWith =>
      __$$_MeetingUserSuggestionCopyWithImpl<_$_MeetingUserSuggestion>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_MeetingUserSuggestionToJson(
      this,
    );
  }
}

abstract class _MeetingUserSuggestion extends MeetingUserSuggestion {
  factory _MeetingUserSuggestion(
      {required final String id,
      required final String suggestion,
      final List<String> likedByIds,
      final List<String> dislikedByIds,
      @JsonKey(fromJson: dateTimeFromTimestamp, toJson: timestampFromDateTime)
      final DateTime? createdDate}) = _$_MeetingUserSuggestion;
  _MeetingUserSuggestion._() : super._();

  factory _MeetingUserSuggestion.fromJson(Map<String, dynamic> json) =
      _$_MeetingUserSuggestion.fromJson;

  @override
  String get id;
  @override
  String get suggestion;
  @override
  List<String> get likedByIds;
  @override
  List<String> get dislikedByIds;
  @override
  @JsonKey(fromJson: dateTimeFromTimestamp, toJson: timestampFromDateTime)
  DateTime? get createdDate;
  @override
  @JsonKey(ignore: true)
  _$$_MeetingUserSuggestionCopyWith<_$_MeetingUserSuggestion> get copyWith =>
      throw _privateConstructorUsedError;
}

ParticipantAgendaItemDetailsMeta _$ParticipantAgendaItemDetailsMetaFromJson(
    Map<String, dynamic> json) {
  return _ParticipantAgendaItemDetailsMeta.fromJson(json);
}

/// @nodoc
mixin _$ParticipantAgendaItemDetailsMeta {
  String get documentPath => throw _privateConstructorUsedError;
  String get voterId => throw _privateConstructorUsedError;
  LikeType get likeType => throw _privateConstructorUsedError;
  String get userSuggestionId => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ParticipantAgendaItemDetailsMetaCopyWith<ParticipantAgendaItemDetailsMeta>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ParticipantAgendaItemDetailsMetaCopyWith<$Res> {
  factory $ParticipantAgendaItemDetailsMetaCopyWith(
          ParticipantAgendaItemDetailsMeta value,
          $Res Function(ParticipantAgendaItemDetailsMeta) then) =
      _$ParticipantAgendaItemDetailsMetaCopyWithImpl<$Res,
          ParticipantAgendaItemDetailsMeta>;
  @useResult
  $Res call(
      {String documentPath,
      String voterId,
      LikeType likeType,
      String userSuggestionId});
}

/// @nodoc
class _$ParticipantAgendaItemDetailsMetaCopyWithImpl<$Res,
        $Val extends ParticipantAgendaItemDetailsMeta>
    implements $ParticipantAgendaItemDetailsMetaCopyWith<$Res> {
  _$ParticipantAgendaItemDetailsMetaCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? documentPath = null,
    Object? voterId = null,
    Object? likeType = null,
    Object? userSuggestionId = null,
  }) {
    return _then(_value.copyWith(
      documentPath: null == documentPath
          ? _value.documentPath
          : documentPath // ignore: cast_nullable_to_non_nullable
              as String,
      voterId: null == voterId
          ? _value.voterId
          : voterId // ignore: cast_nullable_to_non_nullable
              as String,
      likeType: null == likeType
          ? _value.likeType
          : likeType // ignore: cast_nullable_to_non_nullable
              as LikeType,
      userSuggestionId: null == userSuggestionId
          ? _value.userSuggestionId
          : userSuggestionId // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_ParticipantAgendaItemDetailsMetaCopyWith<$Res>
    implements $ParticipantAgendaItemDetailsMetaCopyWith<$Res> {
  factory _$$_ParticipantAgendaItemDetailsMetaCopyWith(
          _$_ParticipantAgendaItemDetailsMeta value,
          $Res Function(_$_ParticipantAgendaItemDetailsMeta) then) =
      __$$_ParticipantAgendaItemDetailsMetaCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String documentPath,
      String voterId,
      LikeType likeType,
      String userSuggestionId});
}

/// @nodoc
class __$$_ParticipantAgendaItemDetailsMetaCopyWithImpl<$Res>
    extends _$ParticipantAgendaItemDetailsMetaCopyWithImpl<$Res,
        _$_ParticipantAgendaItemDetailsMeta>
    implements _$$_ParticipantAgendaItemDetailsMetaCopyWith<$Res> {
  __$$_ParticipantAgendaItemDetailsMetaCopyWithImpl(
      _$_ParticipantAgendaItemDetailsMeta _value,
      $Res Function(_$_ParticipantAgendaItemDetailsMeta) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? documentPath = null,
    Object? voterId = null,
    Object? likeType = null,
    Object? userSuggestionId = null,
  }) {
    return _then(_$_ParticipantAgendaItemDetailsMeta(
      documentPath: null == documentPath
          ? _value.documentPath
          : documentPath // ignore: cast_nullable_to_non_nullable
              as String,
      voterId: null == voterId
          ? _value.voterId
          : voterId // ignore: cast_nullable_to_non_nullable
              as String,
      likeType: null == likeType
          ? _value.likeType
          : likeType // ignore: cast_nullable_to_non_nullable
              as LikeType,
      userSuggestionId: null == userSuggestionId
          ? _value.userSuggestionId
          : userSuggestionId // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_ParticipantAgendaItemDetailsMeta
    implements _ParticipantAgendaItemDetailsMeta {
  _$_ParticipantAgendaItemDetailsMeta(
      {required this.documentPath,
      required this.voterId,
      required this.likeType,
      required this.userSuggestionId});

  factory _$_ParticipantAgendaItemDetailsMeta.fromJson(
          Map<String, dynamic> json) =>
      _$$_ParticipantAgendaItemDetailsMetaFromJson(json);

  @override
  final String documentPath;
  @override
  final String voterId;
  @override
  final LikeType likeType;
  @override
  final String userSuggestionId;

  @override
  String toString() {
    return 'ParticipantAgendaItemDetailsMeta(documentPath: $documentPath, voterId: $voterId, likeType: $likeType, userSuggestionId: $userSuggestionId)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_ParticipantAgendaItemDetailsMeta &&
            (identical(other.documentPath, documentPath) ||
                other.documentPath == documentPath) &&
            (identical(other.voterId, voterId) || other.voterId == voterId) &&
            (identical(other.likeType, likeType) ||
                other.likeType == likeType) &&
            (identical(other.userSuggestionId, userSuggestionId) ||
                other.userSuggestionId == userSuggestionId));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType, documentPath, voterId, likeType, userSuggestionId);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_ParticipantAgendaItemDetailsMetaCopyWith<
          _$_ParticipantAgendaItemDetailsMeta>
      get copyWith => __$$_ParticipantAgendaItemDetailsMetaCopyWithImpl<
          _$_ParticipantAgendaItemDetailsMeta>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_ParticipantAgendaItemDetailsMetaToJson(
      this,
    );
  }
}

abstract class _ParticipantAgendaItemDetailsMeta
    implements ParticipantAgendaItemDetailsMeta {
  factory _ParticipantAgendaItemDetailsMeta(
          {required final String documentPath,
          required final String voterId,
          required final LikeType likeType,
          required final String userSuggestionId}) =
      _$_ParticipantAgendaItemDetailsMeta;

  factory _ParticipantAgendaItemDetailsMeta.fromJson(
      Map<String, dynamic> json) = _$_ParticipantAgendaItemDetailsMeta.fromJson;

  @override
  String get documentPath;
  @override
  String get voterId;
  @override
  LikeType get likeType;
  @override
  String get userSuggestionId;
  @override
  @JsonKey(ignore: true)
  _$$_ParticipantAgendaItemDetailsMetaCopyWith<
          _$_ParticipantAgendaItemDetailsMeta>
      get copyWith => throw _privateConstructorUsedError;
}
