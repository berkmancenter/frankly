// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'requests.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

AddNewFieldRequest _$AddNewFieldRequestFromJson(Map<String, dynamic> json) {
  return _AddNewFieldRequest.fromJson(json);
}

/// @nodoc
mixin _$AddNewFieldRequest {
  String get collectionName => throw _privateConstructorUsedError;
  Map<String, dynamic> get fieldWithValue => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $AddNewFieldRequestCopyWith<AddNewFieldRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AddNewFieldRequestCopyWith<$Res> {
  factory $AddNewFieldRequestCopyWith(
          AddNewFieldRequest value, $Res Function(AddNewFieldRequest) then) =
      _$AddNewFieldRequestCopyWithImpl<$Res, AddNewFieldRequest>;
  @useResult
  $Res call({String collectionName, Map<String, dynamic> fieldWithValue});
}

/// @nodoc
class _$AddNewFieldRequestCopyWithImpl<$Res, $Val extends AddNewFieldRequest>
    implements $AddNewFieldRequestCopyWith<$Res> {
  _$AddNewFieldRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? collectionName = null,
    Object? fieldWithValue = null,
  }) {
    return _then(_value.copyWith(
      collectionName: null == collectionName
          ? _value.collectionName
          : collectionName // ignore: cast_nullable_to_non_nullable
              as String,
      fieldWithValue: null == fieldWithValue
          ? _value.fieldWithValue
          : fieldWithValue // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_AddNewFieldRequestCopyWith<$Res>
    implements $AddNewFieldRequestCopyWith<$Res> {
  factory _$$_AddNewFieldRequestCopyWith(_$_AddNewFieldRequest value,
          $Res Function(_$_AddNewFieldRequest) then) =
      __$$_AddNewFieldRequestCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String collectionName, Map<String, dynamic> fieldWithValue});
}

/// @nodoc
class __$$_AddNewFieldRequestCopyWithImpl<$Res>
    extends _$AddNewFieldRequestCopyWithImpl<$Res, _$_AddNewFieldRequest>
    implements _$$_AddNewFieldRequestCopyWith<$Res> {
  __$$_AddNewFieldRequestCopyWithImpl(
      _$_AddNewFieldRequest _value, $Res Function(_$_AddNewFieldRequest) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? collectionName = null,
    Object? fieldWithValue = null,
  }) {
    return _then(_$_AddNewFieldRequest(
      collectionName: null == collectionName
          ? _value.collectionName
          : collectionName // ignore: cast_nullable_to_non_nullable
              as String,
      fieldWithValue: null == fieldWithValue
          ? _value.fieldWithValue
          : fieldWithValue // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_AddNewFieldRequest implements _AddNewFieldRequest {
  _$_AddNewFieldRequest(
      {required this.collectionName, required this.fieldWithValue});

  factory _$_AddNewFieldRequest.fromJson(Map<String, dynamic> json) =>
      _$$_AddNewFieldRequestFromJson(json);

  @override
  final String collectionName;
  @override
  final Map<String, dynamic> fieldWithValue;

  @override
  String toString() {
    return 'AddNewFieldRequest(collectionName: $collectionName, fieldWithValue: $fieldWithValue)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_AddNewFieldRequest &&
            (identical(other.collectionName, collectionName) ||
                other.collectionName == collectionName) &&
            const DeepCollectionEquality()
                .equals(other.fieldWithValue, fieldWithValue));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, collectionName,
      const DeepCollectionEquality().hash(fieldWithValue));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_AddNewFieldRequestCopyWith<_$_AddNewFieldRequest> get copyWith =>
      __$$_AddNewFieldRequestCopyWithImpl<_$_AddNewFieldRequest>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_AddNewFieldRequestToJson(
      this,
    );
  }
}

abstract class _AddNewFieldRequest implements AddNewFieldRequest {
  factory _AddNewFieldRequest(
          {required final String collectionName,
          required final Map<String, dynamic> fieldWithValue}) =
      _$_AddNewFieldRequest;

  factory _AddNewFieldRequest.fromJson(Map<String, dynamic> json) =
      _$_AddNewFieldRequest.fromJson;

  @override
  String get collectionName;
  @override
  Map<String, dynamic> get fieldWithValue;
  @override
  @JsonKey(ignore: true)
  _$$_AddNewFieldRequestCopyWith<_$_AddNewFieldRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

RemoveExistingFieldRequest _$RemoveExistingFieldRequestFromJson(
    Map<String, dynamic> json) {
  return _RemoveFieldRequest.fromJson(json);
}

/// @nodoc
mixin _$RemoveExistingFieldRequest {
  String get collectionName => throw _privateConstructorUsedError;
  String get field => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $RemoveExistingFieldRequestCopyWith<RemoveExistingFieldRequest>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RemoveExistingFieldRequestCopyWith<$Res> {
  factory $RemoveExistingFieldRequestCopyWith(RemoveExistingFieldRequest value,
          $Res Function(RemoveExistingFieldRequest) then) =
      _$RemoveExistingFieldRequestCopyWithImpl<$Res,
          RemoveExistingFieldRequest>;
  @useResult
  $Res call({String collectionName, String field});
}

/// @nodoc
class _$RemoveExistingFieldRequestCopyWithImpl<$Res,
        $Val extends RemoveExistingFieldRequest>
    implements $RemoveExistingFieldRequestCopyWith<$Res> {
  _$RemoveExistingFieldRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? collectionName = null,
    Object? field = null,
  }) {
    return _then(_value.copyWith(
      collectionName: null == collectionName
          ? _value.collectionName
          : collectionName // ignore: cast_nullable_to_non_nullable
              as String,
      field: null == field
          ? _value.field
          : field // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_RemoveFieldRequestCopyWith<$Res>
    implements $RemoveExistingFieldRequestCopyWith<$Res> {
  factory _$$_RemoveFieldRequestCopyWith(_$_RemoveFieldRequest value,
          $Res Function(_$_RemoveFieldRequest) then) =
      __$$_RemoveFieldRequestCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String collectionName, String field});
}

/// @nodoc
class __$$_RemoveFieldRequestCopyWithImpl<$Res>
    extends _$RemoveExistingFieldRequestCopyWithImpl<$Res,
        _$_RemoveFieldRequest> implements _$$_RemoveFieldRequestCopyWith<$Res> {
  __$$_RemoveFieldRequestCopyWithImpl(
      _$_RemoveFieldRequest _value, $Res Function(_$_RemoveFieldRequest) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? collectionName = null,
    Object? field = null,
  }) {
    return _then(_$_RemoveFieldRequest(
      collectionName: null == collectionName
          ? _value.collectionName
          : collectionName // ignore: cast_nullable_to_non_nullable
              as String,
      field: null == field
          ? _value.field
          : field // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_RemoveFieldRequest implements _RemoveFieldRequest {
  _$_RemoveFieldRequest({required this.collectionName, required this.field});

  factory _$_RemoveFieldRequest.fromJson(Map<String, dynamic> json) =>
      _$$_RemoveFieldRequestFromJson(json);

  @override
  final String collectionName;
  @override
  final String field;

  @override
  String toString() {
    return 'RemoveExistingFieldRequest(collectionName: $collectionName, field: $field)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_RemoveFieldRequest &&
            (identical(other.collectionName, collectionName) ||
                other.collectionName == collectionName) &&
            (identical(other.field, field) || other.field == field));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, collectionName, field);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_RemoveFieldRequestCopyWith<_$_RemoveFieldRequest> get copyWith =>
      __$$_RemoveFieldRequestCopyWithImpl<_$_RemoveFieldRequest>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_RemoveFieldRequestToJson(
      this,
    );
  }
}

abstract class _RemoveFieldRequest implements RemoveExistingFieldRequest {
  factory _RemoveFieldRequest(
      {required final String collectionName,
      required final String field}) = _$_RemoveFieldRequest;

  factory _RemoveFieldRequest.fromJson(Map<String, dynamic> json) =
      _$_RemoveFieldRequest.fromJson;

  @override
  String get collectionName;
  @override
  String get field;
  @override
  @JsonKey(ignore: true)
  _$$_RemoveFieldRequestCopyWith<_$_RemoveFieldRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

CreateDiscussionRequest _$CreateDiscussionRequestFromJson(
    Map<String, dynamic> json) {
  return _CreateDiscussionRequest.fromJson(json);
}

/// @nodoc
mixin _$CreateDiscussionRequest {
  String get discussionPath => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $CreateDiscussionRequestCopyWith<CreateDiscussionRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CreateDiscussionRequestCopyWith<$Res> {
  factory $CreateDiscussionRequestCopyWith(CreateDiscussionRequest value,
          $Res Function(CreateDiscussionRequest) then) =
      _$CreateDiscussionRequestCopyWithImpl<$Res, CreateDiscussionRequest>;
  @useResult
  $Res call({String discussionPath});
}

/// @nodoc
class _$CreateDiscussionRequestCopyWithImpl<$Res,
        $Val extends CreateDiscussionRequest>
    implements $CreateDiscussionRequestCopyWith<$Res> {
  _$CreateDiscussionRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? discussionPath = null,
  }) {
    return _then(_value.copyWith(
      discussionPath: null == discussionPath
          ? _value.discussionPath
          : discussionPath // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_CreateDiscussionRequestCopyWith<$Res>
    implements $CreateDiscussionRequestCopyWith<$Res> {
  factory _$$_CreateDiscussionRequestCopyWith(_$_CreateDiscussionRequest value,
          $Res Function(_$_CreateDiscussionRequest) then) =
      __$$_CreateDiscussionRequestCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String discussionPath});
}

/// @nodoc
class __$$_CreateDiscussionRequestCopyWithImpl<$Res>
    extends _$CreateDiscussionRequestCopyWithImpl<$Res,
        _$_CreateDiscussionRequest>
    implements _$$_CreateDiscussionRequestCopyWith<$Res> {
  __$$_CreateDiscussionRequestCopyWithImpl(_$_CreateDiscussionRequest _value,
      $Res Function(_$_CreateDiscussionRequest) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? discussionPath = null,
  }) {
    return _then(_$_CreateDiscussionRequest(
      discussionPath: null == discussionPath
          ? _value.discussionPath
          : discussionPath // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_CreateDiscussionRequest implements _CreateDiscussionRequest {
  _$_CreateDiscussionRequest({required this.discussionPath});

  factory _$_CreateDiscussionRequest.fromJson(Map<String, dynamic> json) =>
      _$$_CreateDiscussionRequestFromJson(json);

  @override
  final String discussionPath;

  @override
  String toString() {
    return 'CreateDiscussionRequest(discussionPath: $discussionPath)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_CreateDiscussionRequest &&
            (identical(other.discussionPath, discussionPath) ||
                other.discussionPath == discussionPath));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, discussionPath);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_CreateDiscussionRequestCopyWith<_$_CreateDiscussionRequest>
      get copyWith =>
          __$$_CreateDiscussionRequestCopyWithImpl<_$_CreateDiscussionRequest>(
              this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_CreateDiscussionRequestToJson(
      this,
    );
  }
}

abstract class _CreateDiscussionRequest implements CreateDiscussionRequest {
  factory _CreateDiscussionRequest({required final String discussionPath}) =
      _$_CreateDiscussionRequest;

  factory _CreateDiscussionRequest.fromJson(Map<String, dynamic> json) =
      _$_CreateDiscussionRequest.fromJson;

  @override
  String get discussionPath;
  @override
  @JsonKey(ignore: true)
  _$$_CreateDiscussionRequestCopyWith<_$_CreateDiscussionRequest>
      get copyWith => throw _privateConstructorUsedError;
}

CreateAnnouncementRequest _$CreateAnnouncementRequestFromJson(
    Map<String, dynamic> json) {
  return _CreateAnnouncementRequest.fromJson(json);
}

/// @nodoc
mixin _$CreateAnnouncementRequest {
  String get juntoId => throw _privateConstructorUsedError;
  @JsonKey(toJson: Announcement.toJsonForCloudFunction)
  Announcement? get announcement => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $CreateAnnouncementRequestCopyWith<CreateAnnouncementRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CreateAnnouncementRequestCopyWith<$Res> {
  factory $CreateAnnouncementRequestCopyWith(CreateAnnouncementRequest value,
          $Res Function(CreateAnnouncementRequest) then) =
      _$CreateAnnouncementRequestCopyWithImpl<$Res, CreateAnnouncementRequest>;
  @useResult
  $Res call(
      {String juntoId,
      @JsonKey(toJson: Announcement.toJsonForCloudFunction)
      Announcement? announcement});

  $AnnouncementCopyWith<$Res>? get announcement;
}

/// @nodoc
class _$CreateAnnouncementRequestCopyWithImpl<$Res,
        $Val extends CreateAnnouncementRequest>
    implements $CreateAnnouncementRequestCopyWith<$Res> {
  _$CreateAnnouncementRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? juntoId = null,
    Object? announcement = freezed,
  }) {
    return _then(_value.copyWith(
      juntoId: null == juntoId
          ? _value.juntoId
          : juntoId // ignore: cast_nullable_to_non_nullable
              as String,
      announcement: freezed == announcement
          ? _value.announcement
          : announcement // ignore: cast_nullable_to_non_nullable
              as Announcement?,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $AnnouncementCopyWith<$Res>? get announcement {
    if (_value.announcement == null) {
      return null;
    }

    return $AnnouncementCopyWith<$Res>(_value.announcement!, (value) {
      return _then(_value.copyWith(announcement: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$_CreateAnnouncementRequestCopyWith<$Res>
    implements $CreateAnnouncementRequestCopyWith<$Res> {
  factory _$$_CreateAnnouncementRequestCopyWith(
          _$_CreateAnnouncementRequest value,
          $Res Function(_$_CreateAnnouncementRequest) then) =
      __$$_CreateAnnouncementRequestCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String juntoId,
      @JsonKey(toJson: Announcement.toJsonForCloudFunction)
      Announcement? announcement});

  @override
  $AnnouncementCopyWith<$Res>? get announcement;
}

/// @nodoc
class __$$_CreateAnnouncementRequestCopyWithImpl<$Res>
    extends _$CreateAnnouncementRequestCopyWithImpl<$Res,
        _$_CreateAnnouncementRequest>
    implements _$$_CreateAnnouncementRequestCopyWith<$Res> {
  __$$_CreateAnnouncementRequestCopyWithImpl(
      _$_CreateAnnouncementRequest _value,
      $Res Function(_$_CreateAnnouncementRequest) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? juntoId = null,
    Object? announcement = freezed,
  }) {
    return _then(_$_CreateAnnouncementRequest(
      juntoId: null == juntoId
          ? _value.juntoId
          : juntoId // ignore: cast_nullable_to_non_nullable
              as String,
      announcement: freezed == announcement
          ? _value.announcement
          : announcement // ignore: cast_nullable_to_non_nullable
              as Announcement?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_CreateAnnouncementRequest implements _CreateAnnouncementRequest {
  _$_CreateAnnouncementRequest(
      {required this.juntoId,
      @JsonKey(toJson: Announcement.toJsonForCloudFunction) this.announcement});

  factory _$_CreateAnnouncementRequest.fromJson(Map<String, dynamic> json) =>
      _$$_CreateAnnouncementRequestFromJson(json);

  @override
  final String juntoId;
  @override
  @JsonKey(toJson: Announcement.toJsonForCloudFunction)
  final Announcement? announcement;

  @override
  String toString() {
    return 'CreateAnnouncementRequest(juntoId: $juntoId, announcement: $announcement)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_CreateAnnouncementRequest &&
            (identical(other.juntoId, juntoId) || other.juntoId == juntoId) &&
            (identical(other.announcement, announcement) ||
                other.announcement == announcement));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, juntoId, announcement);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_CreateAnnouncementRequestCopyWith<_$_CreateAnnouncementRequest>
      get copyWith => __$$_CreateAnnouncementRequestCopyWithImpl<
          _$_CreateAnnouncementRequest>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_CreateAnnouncementRequestToJson(
      this,
    );
  }
}

abstract class _CreateAnnouncementRequest implements CreateAnnouncementRequest {
  factory _CreateAnnouncementRequest(
      {required final String juntoId,
      @JsonKey(toJson: Announcement.toJsonForCloudFunction)
      final Announcement? announcement}) = _$_CreateAnnouncementRequest;

  factory _CreateAnnouncementRequest.fromJson(Map<String, dynamic> json) =
      _$_CreateAnnouncementRequest.fromJson;

  @override
  String get juntoId;
  @override
  @JsonKey(toJson: Announcement.toJsonForCloudFunction)
  Announcement? get announcement;
  @override
  @JsonKey(ignore: true)
  _$$_CreateAnnouncementRequestCopyWith<_$_CreateAnnouncementRequest>
      get copyWith => throw _privateConstructorUsedError;
}

SendDiscussionMessageRequest _$SendDiscussionMessageRequestFromJson(
    Map<String, dynamic> json) {
  return _SendDiscussionMessageRequest.fromJson(json);
}

/// @nodoc
mixin _$SendDiscussionMessageRequest {
  String get juntoId => throw _privateConstructorUsedError;
  String get topicId => throw _privateConstructorUsedError;
  String get discussionId => throw _privateConstructorUsedError;
  @JsonKey(toJson: DiscussionMessage.toJsonForCloudFunction)
  DiscussionMessage get discussionMessage => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $SendDiscussionMessageRequestCopyWith<SendDiscussionMessageRequest>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SendDiscussionMessageRequestCopyWith<$Res> {
  factory $SendDiscussionMessageRequestCopyWith(
          SendDiscussionMessageRequest value,
          $Res Function(SendDiscussionMessageRequest) then) =
      _$SendDiscussionMessageRequestCopyWithImpl<$Res,
          SendDiscussionMessageRequest>;
  @useResult
  $Res call(
      {String juntoId,
      String topicId,
      String discussionId,
      @JsonKey(toJson: DiscussionMessage.toJsonForCloudFunction)
      DiscussionMessage discussionMessage});

  $DiscussionMessageCopyWith<$Res> get discussionMessage;
}

/// @nodoc
class _$SendDiscussionMessageRequestCopyWithImpl<$Res,
        $Val extends SendDiscussionMessageRequest>
    implements $SendDiscussionMessageRequestCopyWith<$Res> {
  _$SendDiscussionMessageRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? juntoId = null,
    Object? topicId = null,
    Object? discussionId = null,
    Object? discussionMessage = null,
  }) {
    return _then(_value.copyWith(
      juntoId: null == juntoId
          ? _value.juntoId
          : juntoId // ignore: cast_nullable_to_non_nullable
              as String,
      topicId: null == topicId
          ? _value.topicId
          : topicId // ignore: cast_nullable_to_non_nullable
              as String,
      discussionId: null == discussionId
          ? _value.discussionId
          : discussionId // ignore: cast_nullable_to_non_nullable
              as String,
      discussionMessage: null == discussionMessage
          ? _value.discussionMessage
          : discussionMessage // ignore: cast_nullable_to_non_nullable
              as DiscussionMessage,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $DiscussionMessageCopyWith<$Res> get discussionMessage {
    return $DiscussionMessageCopyWith<$Res>(_value.discussionMessage, (value) {
      return _then(_value.copyWith(discussionMessage: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$_SendDiscussionMessageRequestCopyWith<$Res>
    implements $SendDiscussionMessageRequestCopyWith<$Res> {
  factory _$$_SendDiscussionMessageRequestCopyWith(
          _$_SendDiscussionMessageRequest value,
          $Res Function(_$_SendDiscussionMessageRequest) then) =
      __$$_SendDiscussionMessageRequestCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String juntoId,
      String topicId,
      String discussionId,
      @JsonKey(toJson: DiscussionMessage.toJsonForCloudFunction)
      DiscussionMessage discussionMessage});

  @override
  $DiscussionMessageCopyWith<$Res> get discussionMessage;
}

/// @nodoc
class __$$_SendDiscussionMessageRequestCopyWithImpl<$Res>
    extends _$SendDiscussionMessageRequestCopyWithImpl<$Res,
        _$_SendDiscussionMessageRequest>
    implements _$$_SendDiscussionMessageRequestCopyWith<$Res> {
  __$$_SendDiscussionMessageRequestCopyWithImpl(
      _$_SendDiscussionMessageRequest _value,
      $Res Function(_$_SendDiscussionMessageRequest) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? juntoId = null,
    Object? topicId = null,
    Object? discussionId = null,
    Object? discussionMessage = null,
  }) {
    return _then(_$_SendDiscussionMessageRequest(
      juntoId: null == juntoId
          ? _value.juntoId
          : juntoId // ignore: cast_nullable_to_non_nullable
              as String,
      topicId: null == topicId
          ? _value.topicId
          : topicId // ignore: cast_nullable_to_non_nullable
              as String,
      discussionId: null == discussionId
          ? _value.discussionId
          : discussionId // ignore: cast_nullable_to_non_nullable
              as String,
      discussionMessage: null == discussionMessage
          ? _value.discussionMessage
          : discussionMessage // ignore: cast_nullable_to_non_nullable
              as DiscussionMessage,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_SendDiscussionMessageRequest implements _SendDiscussionMessageRequest {
  _$_SendDiscussionMessageRequest(
      {required this.juntoId,
      required this.topicId,
      required this.discussionId,
      @JsonKey(toJson: DiscussionMessage.toJsonForCloudFunction)
      required this.discussionMessage});

  factory _$_SendDiscussionMessageRequest.fromJson(Map<String, dynamic> json) =>
      _$$_SendDiscussionMessageRequestFromJson(json);

  @override
  final String juntoId;
  @override
  final String topicId;
  @override
  final String discussionId;
  @override
  @JsonKey(toJson: DiscussionMessage.toJsonForCloudFunction)
  final DiscussionMessage discussionMessage;

  @override
  String toString() {
    return 'SendDiscussionMessageRequest(juntoId: $juntoId, topicId: $topicId, discussionId: $discussionId, discussionMessage: $discussionMessage)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_SendDiscussionMessageRequest &&
            (identical(other.juntoId, juntoId) || other.juntoId == juntoId) &&
            (identical(other.topicId, topicId) || other.topicId == topicId) &&
            (identical(other.discussionId, discussionId) ||
                other.discussionId == discussionId) &&
            (identical(other.discussionMessage, discussionMessage) ||
                other.discussionMessage == discussionMessage));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType, juntoId, topicId, discussionId, discussionMessage);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_SendDiscussionMessageRequestCopyWith<_$_SendDiscussionMessageRequest>
      get copyWith => __$$_SendDiscussionMessageRequestCopyWithImpl<
          _$_SendDiscussionMessageRequest>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_SendDiscussionMessageRequestToJson(
      this,
    );
  }
}

abstract class _SendDiscussionMessageRequest
    implements SendDiscussionMessageRequest {
  factory _SendDiscussionMessageRequest(
          {required final String juntoId,
          required final String topicId,
          required final String discussionId,
          @JsonKey(toJson: DiscussionMessage.toJsonForCloudFunction)
          required final DiscussionMessage discussionMessage}) =
      _$_SendDiscussionMessageRequest;

  factory _SendDiscussionMessageRequest.fromJson(Map<String, dynamic> json) =
      _$_SendDiscussionMessageRequest.fromJson;

  @override
  String get juntoId;
  @override
  String get topicId;
  @override
  String get discussionId;
  @override
  @JsonKey(toJson: DiscussionMessage.toJsonForCloudFunction)
  DiscussionMessage get discussionMessage;
  @override
  @JsonKey(ignore: true)
  _$$_SendDiscussionMessageRequestCopyWith<_$_SendDiscussionMessageRequest>
      get copyWith => throw _privateConstructorUsedError;
}

CreateDonationCheckoutSessionRequest
    _$CreateDonationCheckoutSessionRequestFromJson(Map<String, dynamic> json) {
  return _CreateDonationCheckoutSessionRequest.fromJson(json);
}

/// @nodoc
mixin _$CreateDonationCheckoutSessionRequest {
  String get juntoId => throw _privateConstructorUsedError;
  int get amountInCents => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $CreateDonationCheckoutSessionRequestCopyWith<
          CreateDonationCheckoutSessionRequest>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CreateDonationCheckoutSessionRequestCopyWith<$Res> {
  factory $CreateDonationCheckoutSessionRequestCopyWith(
          CreateDonationCheckoutSessionRequest value,
          $Res Function(CreateDonationCheckoutSessionRequest) then) =
      _$CreateDonationCheckoutSessionRequestCopyWithImpl<$Res,
          CreateDonationCheckoutSessionRequest>;
  @useResult
  $Res call({String juntoId, int amountInCents});
}

/// @nodoc
class _$CreateDonationCheckoutSessionRequestCopyWithImpl<$Res,
        $Val extends CreateDonationCheckoutSessionRequest>
    implements $CreateDonationCheckoutSessionRequestCopyWith<$Res> {
  _$CreateDonationCheckoutSessionRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? juntoId = null,
    Object? amountInCents = null,
  }) {
    return _then(_value.copyWith(
      juntoId: null == juntoId
          ? _value.juntoId
          : juntoId // ignore: cast_nullable_to_non_nullable
              as String,
      amountInCents: null == amountInCents
          ? _value.amountInCents
          : amountInCents // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_CreateDonationCheckoutSessionRequestCopyWith<$Res>
    implements $CreateDonationCheckoutSessionRequestCopyWith<$Res> {
  factory _$$_CreateDonationCheckoutSessionRequestCopyWith(
          _$_CreateDonationCheckoutSessionRequest value,
          $Res Function(_$_CreateDonationCheckoutSessionRequest) then) =
      __$$_CreateDonationCheckoutSessionRequestCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String juntoId, int amountInCents});
}

/// @nodoc
class __$$_CreateDonationCheckoutSessionRequestCopyWithImpl<$Res>
    extends _$CreateDonationCheckoutSessionRequestCopyWithImpl<$Res,
        _$_CreateDonationCheckoutSessionRequest>
    implements _$$_CreateDonationCheckoutSessionRequestCopyWith<$Res> {
  __$$_CreateDonationCheckoutSessionRequestCopyWithImpl(
      _$_CreateDonationCheckoutSessionRequest _value,
      $Res Function(_$_CreateDonationCheckoutSessionRequest) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? juntoId = null,
    Object? amountInCents = null,
  }) {
    return _then(_$_CreateDonationCheckoutSessionRequest(
      juntoId: null == juntoId
          ? _value.juntoId
          : juntoId // ignore: cast_nullable_to_non_nullable
              as String,
      amountInCents: null == amountInCents
          ? _value.amountInCents
          : amountInCents // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_CreateDonationCheckoutSessionRequest
    implements _CreateDonationCheckoutSessionRequest {
  _$_CreateDonationCheckoutSessionRequest(
      {required this.juntoId, required this.amountInCents});

  factory _$_CreateDonationCheckoutSessionRequest.fromJson(
          Map<String, dynamic> json) =>
      _$$_CreateDonationCheckoutSessionRequestFromJson(json);

  @override
  final String juntoId;
  @override
  final int amountInCents;

  @override
  String toString() {
    return 'CreateDonationCheckoutSessionRequest(juntoId: $juntoId, amountInCents: $amountInCents)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_CreateDonationCheckoutSessionRequest &&
            (identical(other.juntoId, juntoId) || other.juntoId == juntoId) &&
            (identical(other.amountInCents, amountInCents) ||
                other.amountInCents == amountInCents));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, juntoId, amountInCents);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_CreateDonationCheckoutSessionRequestCopyWith<
          _$_CreateDonationCheckoutSessionRequest>
      get copyWith => __$$_CreateDonationCheckoutSessionRequestCopyWithImpl<
          _$_CreateDonationCheckoutSessionRequest>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_CreateDonationCheckoutSessionRequestToJson(
      this,
    );
  }
}

abstract class _CreateDonationCheckoutSessionRequest
    implements CreateDonationCheckoutSessionRequest {
  factory _CreateDonationCheckoutSessionRequest(
          {required final String juntoId, required final int amountInCents}) =
      _$_CreateDonationCheckoutSessionRequest;

  factory _CreateDonationCheckoutSessionRequest.fromJson(
          Map<String, dynamic> json) =
      _$_CreateDonationCheckoutSessionRequest.fromJson;

  @override
  String get juntoId;
  @override
  int get amountInCents;
  @override
  @JsonKey(ignore: true)
  _$$_CreateDonationCheckoutSessionRequestCopyWith<
          _$_CreateDonationCheckoutSessionRequest>
      get copyWith => throw _privateConstructorUsedError;
}

CreateDonationCheckoutSessionResponse
    _$CreateDonationCheckoutSessionResponseFromJson(Map<String, dynamic> json) {
  return _CreateDonationCheckoutSessionResponse.fromJson(json);
}

/// @nodoc
mixin _$CreateDonationCheckoutSessionResponse {
  String get sessionId => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $CreateDonationCheckoutSessionResponseCopyWith<
          CreateDonationCheckoutSessionResponse>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CreateDonationCheckoutSessionResponseCopyWith<$Res> {
  factory $CreateDonationCheckoutSessionResponseCopyWith(
          CreateDonationCheckoutSessionResponse value,
          $Res Function(CreateDonationCheckoutSessionResponse) then) =
      _$CreateDonationCheckoutSessionResponseCopyWithImpl<$Res,
          CreateDonationCheckoutSessionResponse>;
  @useResult
  $Res call({String sessionId});
}

/// @nodoc
class _$CreateDonationCheckoutSessionResponseCopyWithImpl<$Res,
        $Val extends CreateDonationCheckoutSessionResponse>
    implements $CreateDonationCheckoutSessionResponseCopyWith<$Res> {
  _$CreateDonationCheckoutSessionResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? sessionId = null,
  }) {
    return _then(_value.copyWith(
      sessionId: null == sessionId
          ? _value.sessionId
          : sessionId // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_CreateDonationCheckoutSessionResponseCopyWith<$Res>
    implements $CreateDonationCheckoutSessionResponseCopyWith<$Res> {
  factory _$$_CreateDonationCheckoutSessionResponseCopyWith(
          _$_CreateDonationCheckoutSessionResponse value,
          $Res Function(_$_CreateDonationCheckoutSessionResponse) then) =
      __$$_CreateDonationCheckoutSessionResponseCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String sessionId});
}

/// @nodoc
class __$$_CreateDonationCheckoutSessionResponseCopyWithImpl<$Res>
    extends _$CreateDonationCheckoutSessionResponseCopyWithImpl<$Res,
        _$_CreateDonationCheckoutSessionResponse>
    implements _$$_CreateDonationCheckoutSessionResponseCopyWith<$Res> {
  __$$_CreateDonationCheckoutSessionResponseCopyWithImpl(
      _$_CreateDonationCheckoutSessionResponse _value,
      $Res Function(_$_CreateDonationCheckoutSessionResponse) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? sessionId = null,
  }) {
    return _then(_$_CreateDonationCheckoutSessionResponse(
      sessionId: null == sessionId
          ? _value.sessionId
          : sessionId // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_CreateDonationCheckoutSessionResponse
    implements _CreateDonationCheckoutSessionResponse {
  _$_CreateDonationCheckoutSessionResponse({required this.sessionId});

  factory _$_CreateDonationCheckoutSessionResponse.fromJson(
          Map<String, dynamic> json) =>
      _$$_CreateDonationCheckoutSessionResponseFromJson(json);

  @override
  final String sessionId;

  @override
  String toString() {
    return 'CreateDonationCheckoutSessionResponse(sessionId: $sessionId)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_CreateDonationCheckoutSessionResponse &&
            (identical(other.sessionId, sessionId) ||
                other.sessionId == sessionId));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, sessionId);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_CreateDonationCheckoutSessionResponseCopyWith<
          _$_CreateDonationCheckoutSessionResponse>
      get copyWith => __$$_CreateDonationCheckoutSessionResponseCopyWithImpl<
          _$_CreateDonationCheckoutSessionResponse>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_CreateDonationCheckoutSessionResponseToJson(
      this,
    );
  }
}

abstract class _CreateDonationCheckoutSessionResponse
    implements CreateDonationCheckoutSessionResponse {
  factory _CreateDonationCheckoutSessionResponse(
          {required final String sessionId}) =
      _$_CreateDonationCheckoutSessionResponse;

  factory _CreateDonationCheckoutSessionResponse.fromJson(
          Map<String, dynamic> json) =
      _$_CreateDonationCheckoutSessionResponse.fromJson;

  @override
  String get sessionId;
  @override
  @JsonKey(ignore: true)
  _$$_CreateDonationCheckoutSessionResponseCopyWith<
          _$_CreateDonationCheckoutSessionResponse>
      get copyWith => throw _privateConstructorUsedError;
}

CreateSubscriptionCheckoutSessionRequest
    _$CreateSubscriptionCheckoutSessionRequestFromJson(
        Map<String, dynamic> json) {
  return _CreateSubscriptionCheckoutSessionRequest.fromJson(json);
}

/// @nodoc
mixin _$CreateSubscriptionCheckoutSessionRequest {
  PlanType get type => throw _privateConstructorUsedError;
  String get appliedJuntoId => throw _privateConstructorUsedError;
  String get returnRedirectPath => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $CreateSubscriptionCheckoutSessionRequestCopyWith<
          CreateSubscriptionCheckoutSessionRequest>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CreateSubscriptionCheckoutSessionRequestCopyWith<$Res> {
  factory $CreateSubscriptionCheckoutSessionRequestCopyWith(
          CreateSubscriptionCheckoutSessionRequest value,
          $Res Function(CreateSubscriptionCheckoutSessionRequest) then) =
      _$CreateSubscriptionCheckoutSessionRequestCopyWithImpl<$Res,
          CreateSubscriptionCheckoutSessionRequest>;
  @useResult
  $Res call({PlanType type, String appliedJuntoId, String returnRedirectPath});
}

/// @nodoc
class _$CreateSubscriptionCheckoutSessionRequestCopyWithImpl<$Res,
        $Val extends CreateSubscriptionCheckoutSessionRequest>
    implements $CreateSubscriptionCheckoutSessionRequestCopyWith<$Res> {
  _$CreateSubscriptionCheckoutSessionRequestCopyWithImpl(
      this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? type = null,
    Object? appliedJuntoId = null,
    Object? returnRedirectPath = null,
  }) {
    return _then(_value.copyWith(
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as PlanType,
      appliedJuntoId: null == appliedJuntoId
          ? _value.appliedJuntoId
          : appliedJuntoId // ignore: cast_nullable_to_non_nullable
              as String,
      returnRedirectPath: null == returnRedirectPath
          ? _value.returnRedirectPath
          : returnRedirectPath // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_CreateSubscriptionCheckoutSessionRequestCopyWith<$Res>
    implements $CreateSubscriptionCheckoutSessionRequestCopyWith<$Res> {
  factory _$$_CreateSubscriptionCheckoutSessionRequestCopyWith(
          _$_CreateSubscriptionCheckoutSessionRequest value,
          $Res Function(_$_CreateSubscriptionCheckoutSessionRequest) then) =
      __$$_CreateSubscriptionCheckoutSessionRequestCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({PlanType type, String appliedJuntoId, String returnRedirectPath});
}

/// @nodoc
class __$$_CreateSubscriptionCheckoutSessionRequestCopyWithImpl<$Res>
    extends _$CreateSubscriptionCheckoutSessionRequestCopyWithImpl<$Res,
        _$_CreateSubscriptionCheckoutSessionRequest>
    implements _$$_CreateSubscriptionCheckoutSessionRequestCopyWith<$Res> {
  __$$_CreateSubscriptionCheckoutSessionRequestCopyWithImpl(
      _$_CreateSubscriptionCheckoutSessionRequest _value,
      $Res Function(_$_CreateSubscriptionCheckoutSessionRequest) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? type = null,
    Object? appliedJuntoId = null,
    Object? returnRedirectPath = null,
  }) {
    return _then(_$_CreateSubscriptionCheckoutSessionRequest(
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as PlanType,
      appliedJuntoId: null == appliedJuntoId
          ? _value.appliedJuntoId
          : appliedJuntoId // ignore: cast_nullable_to_non_nullable
              as String,
      returnRedirectPath: null == returnRedirectPath
          ? _value.returnRedirectPath
          : returnRedirectPath // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_CreateSubscriptionCheckoutSessionRequest
    implements _CreateSubscriptionCheckoutSessionRequest {
  _$_CreateSubscriptionCheckoutSessionRequest(
      {required this.type,
      required this.appliedJuntoId,
      required this.returnRedirectPath});

  factory _$_CreateSubscriptionCheckoutSessionRequest.fromJson(
          Map<String, dynamic> json) =>
      _$$_CreateSubscriptionCheckoutSessionRequestFromJson(json);

  @override
  final PlanType type;
  @override
  final String appliedJuntoId;
  @override
  final String returnRedirectPath;

  @override
  String toString() {
    return 'CreateSubscriptionCheckoutSessionRequest(type: $type, appliedJuntoId: $appliedJuntoId, returnRedirectPath: $returnRedirectPath)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_CreateSubscriptionCheckoutSessionRequest &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.appliedJuntoId, appliedJuntoId) ||
                other.appliedJuntoId == appliedJuntoId) &&
            (identical(other.returnRedirectPath, returnRedirectPath) ||
                other.returnRedirectPath == returnRedirectPath));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode =>
      Object.hash(runtimeType, type, appliedJuntoId, returnRedirectPath);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_CreateSubscriptionCheckoutSessionRequestCopyWith<
          _$_CreateSubscriptionCheckoutSessionRequest>
      get copyWith => __$$_CreateSubscriptionCheckoutSessionRequestCopyWithImpl<
          _$_CreateSubscriptionCheckoutSessionRequest>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_CreateSubscriptionCheckoutSessionRequestToJson(
      this,
    );
  }
}

abstract class _CreateSubscriptionCheckoutSessionRequest
    implements CreateSubscriptionCheckoutSessionRequest {
  factory _CreateSubscriptionCheckoutSessionRequest(
          {required final PlanType type,
          required final String appliedJuntoId,
          required final String returnRedirectPath}) =
      _$_CreateSubscriptionCheckoutSessionRequest;

  factory _CreateSubscriptionCheckoutSessionRequest.fromJson(
          Map<String, dynamic> json) =
      _$_CreateSubscriptionCheckoutSessionRequest.fromJson;

  @override
  PlanType get type;
  @override
  String get appliedJuntoId;
  @override
  String get returnRedirectPath;
  @override
  @JsonKey(ignore: true)
  _$$_CreateSubscriptionCheckoutSessionRequestCopyWith<
          _$_CreateSubscriptionCheckoutSessionRequest>
      get copyWith => throw _privateConstructorUsedError;
}

CreateSubscriptionCheckoutSessionResponse
    _$CreateSubscriptionCheckoutSessionResponseFromJson(
        Map<String, dynamic> json) {
  return __$CreateSubscriptionCheckoutSessionResponse.fromJson(json);
}

/// @nodoc
mixin _$CreateSubscriptionCheckoutSessionResponse {
  String get sessionId => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $CreateSubscriptionCheckoutSessionResponseCopyWith<
          CreateSubscriptionCheckoutSessionResponse>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CreateSubscriptionCheckoutSessionResponseCopyWith<$Res> {
  factory $CreateSubscriptionCheckoutSessionResponseCopyWith(
          CreateSubscriptionCheckoutSessionResponse value,
          $Res Function(CreateSubscriptionCheckoutSessionResponse) then) =
      _$CreateSubscriptionCheckoutSessionResponseCopyWithImpl<$Res,
          CreateSubscriptionCheckoutSessionResponse>;
  @useResult
  $Res call({String sessionId});
}

/// @nodoc
class _$CreateSubscriptionCheckoutSessionResponseCopyWithImpl<$Res,
        $Val extends CreateSubscriptionCheckoutSessionResponse>
    implements $CreateSubscriptionCheckoutSessionResponseCopyWith<$Res> {
  _$CreateSubscriptionCheckoutSessionResponseCopyWithImpl(
      this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? sessionId = null,
  }) {
    return _then(_value.copyWith(
      sessionId: null == sessionId
          ? _value.sessionId
          : sessionId // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$__$CreateSubscriptionCheckoutSessionResponseCopyWith<$Res>
    implements $CreateSubscriptionCheckoutSessionResponseCopyWith<$Res> {
  factory _$$__$CreateSubscriptionCheckoutSessionResponseCopyWith(
          _$__$CreateSubscriptionCheckoutSessionResponse value,
          $Res Function(_$__$CreateSubscriptionCheckoutSessionResponse) then) =
      __$$__$CreateSubscriptionCheckoutSessionResponseCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String sessionId});
}

/// @nodoc
class __$$__$CreateSubscriptionCheckoutSessionResponseCopyWithImpl<$Res>
    extends _$CreateSubscriptionCheckoutSessionResponseCopyWithImpl<$Res,
        _$__$CreateSubscriptionCheckoutSessionResponse>
    implements _$$__$CreateSubscriptionCheckoutSessionResponseCopyWith<$Res> {
  __$$__$CreateSubscriptionCheckoutSessionResponseCopyWithImpl(
      _$__$CreateSubscriptionCheckoutSessionResponse _value,
      $Res Function(_$__$CreateSubscriptionCheckoutSessionResponse) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? sessionId = null,
  }) {
    return _then(_$__$CreateSubscriptionCheckoutSessionResponse(
      sessionId: null == sessionId
          ? _value.sessionId
          : sessionId // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$__$CreateSubscriptionCheckoutSessionResponse
    implements __$CreateSubscriptionCheckoutSessionResponse {
  _$__$CreateSubscriptionCheckoutSessionResponse({required this.sessionId});

  factory _$__$CreateSubscriptionCheckoutSessionResponse.fromJson(
          Map<String, dynamic> json) =>
      _$$__$CreateSubscriptionCheckoutSessionResponseFromJson(json);

  @override
  final String sessionId;

  @override
  String toString() {
    return 'CreateSubscriptionCheckoutSessionResponse(sessionId: $sessionId)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$__$CreateSubscriptionCheckoutSessionResponse &&
            (identical(other.sessionId, sessionId) ||
                other.sessionId == sessionId));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, sessionId);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$__$CreateSubscriptionCheckoutSessionResponseCopyWith<
          _$__$CreateSubscriptionCheckoutSessionResponse>
      get copyWith =>
          __$$__$CreateSubscriptionCheckoutSessionResponseCopyWithImpl<
              _$__$CreateSubscriptionCheckoutSessionResponse>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$__$CreateSubscriptionCheckoutSessionResponseToJson(
      this,
    );
  }
}

abstract class __$CreateSubscriptionCheckoutSessionResponse
    implements CreateSubscriptionCheckoutSessionResponse {
  factory __$CreateSubscriptionCheckoutSessionResponse(
          {required final String sessionId}) =
      _$__$CreateSubscriptionCheckoutSessionResponse;

  factory __$CreateSubscriptionCheckoutSessionResponse.fromJson(
          Map<String, dynamic> json) =
      _$__$CreateSubscriptionCheckoutSessionResponse.fromJson;

  @override
  String get sessionId;
  @override
  @JsonKey(ignore: true)
  _$$__$CreateSubscriptionCheckoutSessionResponseCopyWith<
          _$__$CreateSubscriptionCheckoutSessionResponse>
      get copyWith => throw _privateConstructorUsedError;
}

CreateStripeConnectedAccountRequest
    _$CreateStripeConnectedAccountRequestFromJson(Map<String, dynamic> json) {
  return _CreateStripeConnectedAccountRequest.fromJson(json);
}

/// @nodoc
mixin _$CreateStripeConnectedAccountRequest {
  String get agreementId => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $CreateStripeConnectedAccountRequestCopyWith<
          CreateStripeConnectedAccountRequest>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CreateStripeConnectedAccountRequestCopyWith<$Res> {
  factory $CreateStripeConnectedAccountRequestCopyWith(
          CreateStripeConnectedAccountRequest value,
          $Res Function(CreateStripeConnectedAccountRequest) then) =
      _$CreateStripeConnectedAccountRequestCopyWithImpl<$Res,
          CreateStripeConnectedAccountRequest>;
  @useResult
  $Res call({String agreementId});
}

/// @nodoc
class _$CreateStripeConnectedAccountRequestCopyWithImpl<$Res,
        $Val extends CreateStripeConnectedAccountRequest>
    implements $CreateStripeConnectedAccountRequestCopyWith<$Res> {
  _$CreateStripeConnectedAccountRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? agreementId = null,
  }) {
    return _then(_value.copyWith(
      agreementId: null == agreementId
          ? _value.agreementId
          : agreementId // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_CreateStripeConnectedAccountRequestCopyWith<$Res>
    implements $CreateStripeConnectedAccountRequestCopyWith<$Res> {
  factory _$$_CreateStripeConnectedAccountRequestCopyWith(
          _$_CreateStripeConnectedAccountRequest value,
          $Res Function(_$_CreateStripeConnectedAccountRequest) then) =
      __$$_CreateStripeConnectedAccountRequestCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String agreementId});
}

/// @nodoc
class __$$_CreateStripeConnectedAccountRequestCopyWithImpl<$Res>
    extends _$CreateStripeConnectedAccountRequestCopyWithImpl<$Res,
        _$_CreateStripeConnectedAccountRequest>
    implements _$$_CreateStripeConnectedAccountRequestCopyWith<$Res> {
  __$$_CreateStripeConnectedAccountRequestCopyWithImpl(
      _$_CreateStripeConnectedAccountRequest _value,
      $Res Function(_$_CreateStripeConnectedAccountRequest) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? agreementId = null,
  }) {
    return _then(_$_CreateStripeConnectedAccountRequest(
      agreementId: null == agreementId
          ? _value.agreementId
          : agreementId // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_CreateStripeConnectedAccountRequest
    implements _CreateStripeConnectedAccountRequest {
  _$_CreateStripeConnectedAccountRequest({required this.agreementId});

  factory _$_CreateStripeConnectedAccountRequest.fromJson(
          Map<String, dynamic> json) =>
      _$$_CreateStripeConnectedAccountRequestFromJson(json);

  @override
  final String agreementId;

  @override
  String toString() {
    return 'CreateStripeConnectedAccountRequest(agreementId: $agreementId)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_CreateStripeConnectedAccountRequest &&
            (identical(other.agreementId, agreementId) ||
                other.agreementId == agreementId));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, agreementId);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_CreateStripeConnectedAccountRequestCopyWith<
          _$_CreateStripeConnectedAccountRequest>
      get copyWith => __$$_CreateStripeConnectedAccountRequestCopyWithImpl<
          _$_CreateStripeConnectedAccountRequest>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_CreateStripeConnectedAccountRequestToJson(
      this,
    );
  }
}

abstract class _CreateStripeConnectedAccountRequest
    implements CreateStripeConnectedAccountRequest {
  factory _CreateStripeConnectedAccountRequest(
          {required final String agreementId}) =
      _$_CreateStripeConnectedAccountRequest;

  factory _CreateStripeConnectedAccountRequest.fromJson(
          Map<String, dynamic> json) =
      _$_CreateStripeConnectedAccountRequest.fromJson;

  @override
  String get agreementId;
  @override
  @JsonKey(ignore: true)
  _$$_CreateStripeConnectedAccountRequestCopyWith<
          _$_CreateStripeConnectedAccountRequest>
      get copyWith => throw _privateConstructorUsedError;
}

EmailDiscussionReminderRequest _$EmailDiscussionReminderRequestFromJson(
    Map<String, dynamic> json) {
  return _EmailDiscussionReminderRequest.fromJson(json);
}

/// @nodoc
mixin _$EmailDiscussionReminderRequest {
  String get juntoId => throw _privateConstructorUsedError;
  String get topicId => throw _privateConstructorUsedError;
  String get discussionId => throw _privateConstructorUsedError;
  DiscussionEmailType? get discussionEmailType =>
      throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $EmailDiscussionReminderRequestCopyWith<EmailDiscussionReminderRequest>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $EmailDiscussionReminderRequestCopyWith<$Res> {
  factory $EmailDiscussionReminderRequestCopyWith(
          EmailDiscussionReminderRequest value,
          $Res Function(EmailDiscussionReminderRequest) then) =
      _$EmailDiscussionReminderRequestCopyWithImpl<$Res,
          EmailDiscussionReminderRequest>;
  @useResult
  $Res call(
      {String juntoId,
      String topicId,
      String discussionId,
      DiscussionEmailType? discussionEmailType});
}

/// @nodoc
class _$EmailDiscussionReminderRequestCopyWithImpl<$Res,
        $Val extends EmailDiscussionReminderRequest>
    implements $EmailDiscussionReminderRequestCopyWith<$Res> {
  _$EmailDiscussionReminderRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? juntoId = null,
    Object? topicId = null,
    Object? discussionId = null,
    Object? discussionEmailType = freezed,
  }) {
    return _then(_value.copyWith(
      juntoId: null == juntoId
          ? _value.juntoId
          : juntoId // ignore: cast_nullable_to_non_nullable
              as String,
      topicId: null == topicId
          ? _value.topicId
          : topicId // ignore: cast_nullable_to_non_nullable
              as String,
      discussionId: null == discussionId
          ? _value.discussionId
          : discussionId // ignore: cast_nullable_to_non_nullable
              as String,
      discussionEmailType: freezed == discussionEmailType
          ? _value.discussionEmailType
          : discussionEmailType // ignore: cast_nullable_to_non_nullable
              as DiscussionEmailType?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_EmailDiscussionReminderRequestCopyWith<$Res>
    implements $EmailDiscussionReminderRequestCopyWith<$Res> {
  factory _$$_EmailDiscussionReminderRequestCopyWith(
          _$_EmailDiscussionReminderRequest value,
          $Res Function(_$_EmailDiscussionReminderRequest) then) =
      __$$_EmailDiscussionReminderRequestCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String juntoId,
      String topicId,
      String discussionId,
      DiscussionEmailType? discussionEmailType});
}

/// @nodoc
class __$$_EmailDiscussionReminderRequestCopyWithImpl<$Res>
    extends _$EmailDiscussionReminderRequestCopyWithImpl<$Res,
        _$_EmailDiscussionReminderRequest>
    implements _$$_EmailDiscussionReminderRequestCopyWith<$Res> {
  __$$_EmailDiscussionReminderRequestCopyWithImpl(
      _$_EmailDiscussionReminderRequest _value,
      $Res Function(_$_EmailDiscussionReminderRequest) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? juntoId = null,
    Object? topicId = null,
    Object? discussionId = null,
    Object? discussionEmailType = freezed,
  }) {
    return _then(_$_EmailDiscussionReminderRequest(
      juntoId: null == juntoId
          ? _value.juntoId
          : juntoId // ignore: cast_nullable_to_non_nullable
              as String,
      topicId: null == topicId
          ? _value.topicId
          : topicId // ignore: cast_nullable_to_non_nullable
              as String,
      discussionId: null == discussionId
          ? _value.discussionId
          : discussionId // ignore: cast_nullable_to_non_nullable
              as String,
      discussionEmailType: freezed == discussionEmailType
          ? _value.discussionEmailType
          : discussionEmailType // ignore: cast_nullable_to_non_nullable
              as DiscussionEmailType?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_EmailDiscussionReminderRequest
    implements _EmailDiscussionReminderRequest {
  _$_EmailDiscussionReminderRequest(
      {required this.juntoId,
      required this.topicId,
      required this.discussionId,
      this.discussionEmailType});

  factory _$_EmailDiscussionReminderRequest.fromJson(
          Map<String, dynamic> json) =>
      _$$_EmailDiscussionReminderRequestFromJson(json);

  @override
  final String juntoId;
  @override
  final String topicId;
  @override
  final String discussionId;
  @override
  final DiscussionEmailType? discussionEmailType;

  @override
  String toString() {
    return 'EmailDiscussionReminderRequest(juntoId: $juntoId, topicId: $topicId, discussionId: $discussionId, discussionEmailType: $discussionEmailType)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_EmailDiscussionReminderRequest &&
            (identical(other.juntoId, juntoId) || other.juntoId == juntoId) &&
            (identical(other.topicId, topicId) || other.topicId == topicId) &&
            (identical(other.discussionId, discussionId) ||
                other.discussionId == discussionId) &&
            (identical(other.discussionEmailType, discussionEmailType) ||
                other.discussionEmailType == discussionEmailType));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType, juntoId, topicId, discussionId, discussionEmailType);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_EmailDiscussionReminderRequestCopyWith<_$_EmailDiscussionReminderRequest>
      get copyWith => __$$_EmailDiscussionReminderRequestCopyWithImpl<
          _$_EmailDiscussionReminderRequest>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_EmailDiscussionReminderRequestToJson(
      this,
    );
  }
}

abstract class _EmailDiscussionReminderRequest
    implements EmailDiscussionReminderRequest {
  factory _EmailDiscussionReminderRequest(
          {required final String juntoId,
          required final String topicId,
          required final String discussionId,
          final DiscussionEmailType? discussionEmailType}) =
      _$_EmailDiscussionReminderRequest;

  factory _EmailDiscussionReminderRequest.fromJson(Map<String, dynamic> json) =
      _$_EmailDiscussionReminderRequest.fromJson;

  @override
  String get juntoId;
  @override
  String get topicId;
  @override
  String get discussionId;
  @override
  DiscussionEmailType? get discussionEmailType;
  @override
  @JsonKey(ignore: true)
  _$$_EmailDiscussionReminderRequestCopyWith<_$_EmailDiscussionReminderRequest>
      get copyWith => throw _privateConstructorUsedError;
}

ExtendCloudTaskSchedulerRequest _$ExtendCloudTaskSchedulerRequestFromJson(
    Map<String, dynamic> json) {
  return _ExtendCloudTaskSchedulerRequest.fromJson(json);
}

/// @nodoc
mixin _$ExtendCloudTaskSchedulerRequest {
  DateTime get scheduledTime => throw _privateConstructorUsedError;
  String get functionName => throw _privateConstructorUsedError;
  String get payload => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ExtendCloudTaskSchedulerRequestCopyWith<ExtendCloudTaskSchedulerRequest>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ExtendCloudTaskSchedulerRequestCopyWith<$Res> {
  factory $ExtendCloudTaskSchedulerRequestCopyWith(
          ExtendCloudTaskSchedulerRequest value,
          $Res Function(ExtendCloudTaskSchedulerRequest) then) =
      _$ExtendCloudTaskSchedulerRequestCopyWithImpl<$Res,
          ExtendCloudTaskSchedulerRequest>;
  @useResult
  $Res call({DateTime scheduledTime, String functionName, String payload});
}

/// @nodoc
class _$ExtendCloudTaskSchedulerRequestCopyWithImpl<$Res,
        $Val extends ExtendCloudTaskSchedulerRequest>
    implements $ExtendCloudTaskSchedulerRequestCopyWith<$Res> {
  _$ExtendCloudTaskSchedulerRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? scheduledTime = null,
    Object? functionName = null,
    Object? payload = null,
  }) {
    return _then(_value.copyWith(
      scheduledTime: null == scheduledTime
          ? _value.scheduledTime
          : scheduledTime // ignore: cast_nullable_to_non_nullable
              as DateTime,
      functionName: null == functionName
          ? _value.functionName
          : functionName // ignore: cast_nullable_to_non_nullable
              as String,
      payload: null == payload
          ? _value.payload
          : payload // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_ExtendCloudTaskSchedulerRequestCopyWith<$Res>
    implements $ExtendCloudTaskSchedulerRequestCopyWith<$Res> {
  factory _$$_ExtendCloudTaskSchedulerRequestCopyWith(
          _$_ExtendCloudTaskSchedulerRequest value,
          $Res Function(_$_ExtendCloudTaskSchedulerRequest) then) =
      __$$_ExtendCloudTaskSchedulerRequestCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({DateTime scheduledTime, String functionName, String payload});
}

/// @nodoc
class __$$_ExtendCloudTaskSchedulerRequestCopyWithImpl<$Res>
    extends _$ExtendCloudTaskSchedulerRequestCopyWithImpl<$Res,
        _$_ExtendCloudTaskSchedulerRequest>
    implements _$$_ExtendCloudTaskSchedulerRequestCopyWith<$Res> {
  __$$_ExtendCloudTaskSchedulerRequestCopyWithImpl(
      _$_ExtendCloudTaskSchedulerRequest _value,
      $Res Function(_$_ExtendCloudTaskSchedulerRequest) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? scheduledTime = null,
    Object? functionName = null,
    Object? payload = null,
  }) {
    return _then(_$_ExtendCloudTaskSchedulerRequest(
      scheduledTime: null == scheduledTime
          ? _value.scheduledTime
          : scheduledTime // ignore: cast_nullable_to_non_nullable
              as DateTime,
      functionName: null == functionName
          ? _value.functionName
          : functionName // ignore: cast_nullable_to_non_nullable
              as String,
      payload: null == payload
          ? _value.payload
          : payload // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_ExtendCloudTaskSchedulerRequest
    implements _ExtendCloudTaskSchedulerRequest {
  _$_ExtendCloudTaskSchedulerRequest(
      {required this.scheduledTime,
      required this.functionName,
      required this.payload});

  factory _$_ExtendCloudTaskSchedulerRequest.fromJson(
          Map<String, dynamic> json) =>
      _$$_ExtendCloudTaskSchedulerRequestFromJson(json);

  @override
  final DateTime scheduledTime;
  @override
  final String functionName;
  @override
  final String payload;

  @override
  String toString() {
    return 'ExtendCloudTaskSchedulerRequest(scheduledTime: $scheduledTime, functionName: $functionName, payload: $payload)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_ExtendCloudTaskSchedulerRequest &&
            (identical(other.scheduledTime, scheduledTime) ||
                other.scheduledTime == scheduledTime) &&
            (identical(other.functionName, functionName) ||
                other.functionName == functionName) &&
            (identical(other.payload, payload) || other.payload == payload));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode =>
      Object.hash(runtimeType, scheduledTime, functionName, payload);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_ExtendCloudTaskSchedulerRequestCopyWith<
          _$_ExtendCloudTaskSchedulerRequest>
      get copyWith => __$$_ExtendCloudTaskSchedulerRequestCopyWithImpl<
          _$_ExtendCloudTaskSchedulerRequest>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_ExtendCloudTaskSchedulerRequestToJson(
      this,
    );
  }
}

abstract class _ExtendCloudTaskSchedulerRequest
    implements ExtendCloudTaskSchedulerRequest {
  factory _ExtendCloudTaskSchedulerRequest(
      {required final DateTime scheduledTime,
      required final String functionName,
      required final String payload}) = _$_ExtendCloudTaskSchedulerRequest;

  factory _ExtendCloudTaskSchedulerRequest.fromJson(Map<String, dynamic> json) =
      _$_ExtendCloudTaskSchedulerRequest.fromJson;

  @override
  DateTime get scheduledTime;
  @override
  String get functionName;
  @override
  String get payload;
  @override
  @JsonKey(ignore: true)
  _$$_ExtendCloudTaskSchedulerRequestCopyWith<
          _$_ExtendCloudTaskSchedulerRequest>
      get copyWith => throw _privateConstructorUsedError;
}

JuntoUserInfo _$JuntoUserInfoFromJson(Map<String, dynamic> json) {
  return _JuntoUserInfo.fromJson(json);
}

/// @nodoc
mixin _$JuntoUserInfo {
  String get id => throw _privateConstructorUsedError;
  String get photoURL => throw _privateConstructorUsedError;
  String get displayName => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $JuntoUserInfoCopyWith<JuntoUserInfo> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $JuntoUserInfoCopyWith<$Res> {
  factory $JuntoUserInfoCopyWith(
          JuntoUserInfo value, $Res Function(JuntoUserInfo) then) =
      _$JuntoUserInfoCopyWithImpl<$Res, JuntoUserInfo>;
  @useResult
  $Res call({String id, String photoURL, String displayName});
}

/// @nodoc
class _$JuntoUserInfoCopyWithImpl<$Res, $Val extends JuntoUserInfo>
    implements $JuntoUserInfoCopyWith<$Res> {
  _$JuntoUserInfoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? photoURL = null,
    Object? displayName = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      photoURL: null == photoURL
          ? _value.photoURL
          : photoURL // ignore: cast_nullable_to_non_nullable
              as String,
      displayName: null == displayName
          ? _value.displayName
          : displayName // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_JuntoUserInfoCopyWith<$Res>
    implements $JuntoUserInfoCopyWith<$Res> {
  factory _$$_JuntoUserInfoCopyWith(
          _$_JuntoUserInfo value, $Res Function(_$_JuntoUserInfo) then) =
      __$$_JuntoUserInfoCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String id, String photoURL, String displayName});
}

/// @nodoc
class __$$_JuntoUserInfoCopyWithImpl<$Res>
    extends _$JuntoUserInfoCopyWithImpl<$Res, _$_JuntoUserInfo>
    implements _$$_JuntoUserInfoCopyWith<$Res> {
  __$$_JuntoUserInfoCopyWithImpl(
      _$_JuntoUserInfo _value, $Res Function(_$_JuntoUserInfo) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? photoURL = null,
    Object? displayName = null,
  }) {
    return _then(_$_JuntoUserInfo(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      photoURL: null == photoURL
          ? _value.photoURL
          : photoURL // ignore: cast_nullable_to_non_nullable
              as String,
      displayName: null == displayName
          ? _value.displayName
          : displayName // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_JuntoUserInfo implements _JuntoUserInfo {
  _$_JuntoUserInfo(
      {required this.id, required this.photoURL, required this.displayName});

  factory _$_JuntoUserInfo.fromJson(Map<String, dynamic> json) =>
      _$$_JuntoUserInfoFromJson(json);

  @override
  final String id;
  @override
  final String photoURL;
  @override
  final String displayName;

  @override
  String toString() {
    return 'JuntoUserInfo(id: $id, photoURL: $photoURL, displayName: $displayName)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_JuntoUserInfo &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.photoURL, photoURL) ||
                other.photoURL == photoURL) &&
            (identical(other.displayName, displayName) ||
                other.displayName == displayName));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, photoURL, displayName);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_JuntoUserInfoCopyWith<_$_JuntoUserInfo> get copyWith =>
      __$$_JuntoUserInfoCopyWithImpl<_$_JuntoUserInfo>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_JuntoUserInfoToJson(
      this,
    );
  }
}

abstract class _JuntoUserInfo implements JuntoUserInfo {
  factory _JuntoUserInfo(
      {required final String id,
      required final String photoURL,
      required final String displayName}) = _$_JuntoUserInfo;

  factory _JuntoUserInfo.fromJson(Map<String, dynamic> json) =
      _$_JuntoUserInfo.fromJson;

  @override
  String get id;
  @override
  String get photoURL;
  @override
  String get displayName;
  @override
  @JsonKey(ignore: true)
  _$$_JuntoUserInfoCopyWith<_$_JuntoUserInfo> get copyWith =>
      throw _privateConstructorUsedError;
}

SendGridEmail _$SendGridEmailFromJson(Map<String, dynamic> json) {
  return _SendGridEmail.fromJson(json);
}

/// @nodoc
mixin _$SendGridEmail {
  List<String> get to => throw _privateConstructorUsedError;
  String get from => throw _privateConstructorUsedError;
  SendGridEmailMessage get message => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $SendGridEmailCopyWith<SendGridEmail> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SendGridEmailCopyWith<$Res> {
  factory $SendGridEmailCopyWith(
          SendGridEmail value, $Res Function(SendGridEmail) then) =
      _$SendGridEmailCopyWithImpl<$Res, SendGridEmail>;
  @useResult
  $Res call({List<String> to, String from, SendGridEmailMessage message});

  $SendGridEmailMessageCopyWith<$Res> get message;
}

/// @nodoc
class _$SendGridEmailCopyWithImpl<$Res, $Val extends SendGridEmail>
    implements $SendGridEmailCopyWith<$Res> {
  _$SendGridEmailCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? to = null,
    Object? from = null,
    Object? message = null,
  }) {
    return _then(_value.copyWith(
      to: null == to
          ? _value.to
          : to // ignore: cast_nullable_to_non_nullable
              as List<String>,
      from: null == from
          ? _value.from
          : from // ignore: cast_nullable_to_non_nullable
              as String,
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as SendGridEmailMessage,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $SendGridEmailMessageCopyWith<$Res> get message {
    return $SendGridEmailMessageCopyWith<$Res>(_value.message, (value) {
      return _then(_value.copyWith(message: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$_SendGridEmailCopyWith<$Res>
    implements $SendGridEmailCopyWith<$Res> {
  factory _$$_SendGridEmailCopyWith(
          _$_SendGridEmail value, $Res Function(_$_SendGridEmail) then) =
      __$$_SendGridEmailCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({List<String> to, String from, SendGridEmailMessage message});

  @override
  $SendGridEmailMessageCopyWith<$Res> get message;
}

/// @nodoc
class __$$_SendGridEmailCopyWithImpl<$Res>
    extends _$SendGridEmailCopyWithImpl<$Res, _$_SendGridEmail>
    implements _$$_SendGridEmailCopyWith<$Res> {
  __$$_SendGridEmailCopyWithImpl(
      _$_SendGridEmail _value, $Res Function(_$_SendGridEmail) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? to = null,
    Object? from = null,
    Object? message = null,
  }) {
    return _then(_$_SendGridEmail(
      to: null == to
          ? _value.to
          : to // ignore: cast_nullable_to_non_nullable
              as List<String>,
      from: null == from
          ? _value.from
          : from // ignore: cast_nullable_to_non_nullable
              as String,
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as SendGridEmailMessage,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_SendGridEmail implements _SendGridEmail {
  _$_SendGridEmail(
      {required this.to, required this.from, required this.message});

  factory _$_SendGridEmail.fromJson(Map<String, dynamic> json) =>
      _$$_SendGridEmailFromJson(json);

  @override
  final List<String> to;
  @override
  final String from;
  @override
  final SendGridEmailMessage message;

  @override
  String toString() {
    return 'SendGridEmail(to: $to, from: $from, message: $message)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_SendGridEmail &&
            const DeepCollectionEquality().equals(other.to, to) &&
            (identical(other.from, from) || other.from == from) &&
            (identical(other.message, message) || other.message == message));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType, const DeepCollectionEquality().hash(to), from, message);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_SendGridEmailCopyWith<_$_SendGridEmail> get copyWith =>
      __$$_SendGridEmailCopyWithImpl<_$_SendGridEmail>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_SendGridEmailToJson(
      this,
    );
  }
}

abstract class _SendGridEmail implements SendGridEmail {
  factory _SendGridEmail(
      {required final List<String> to,
      required final String from,
      required final SendGridEmailMessage message}) = _$_SendGridEmail;

  factory _SendGridEmail.fromJson(Map<String, dynamic> json) =
      _$_SendGridEmail.fromJson;

  @override
  List<String> get to;
  @override
  String get from;
  @override
  SendGridEmailMessage get message;
  @override
  @JsonKey(ignore: true)
  _$$_SendGridEmailCopyWith<_$_SendGridEmail> get copyWith =>
      throw _privateConstructorUsedError;
}

EmailAttachment _$EmailAttachmentFromJson(Map<String, dynamic> json) {
  return _EmailAttachment.fromJson(json);
}

/// @nodoc
mixin _$EmailAttachment {
  String get filename => throw _privateConstructorUsedError;
  String get content => throw _privateConstructorUsedError;
  String get contentType => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $EmailAttachmentCopyWith<EmailAttachment> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $EmailAttachmentCopyWith<$Res> {
  factory $EmailAttachmentCopyWith(
          EmailAttachment value, $Res Function(EmailAttachment) then) =
      _$EmailAttachmentCopyWithImpl<$Res, EmailAttachment>;
  @useResult
  $Res call({String filename, String content, String contentType});
}

/// @nodoc
class _$EmailAttachmentCopyWithImpl<$Res, $Val extends EmailAttachment>
    implements $EmailAttachmentCopyWith<$Res> {
  _$EmailAttachmentCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? filename = null,
    Object? content = null,
    Object? contentType = null,
  }) {
    return _then(_value.copyWith(
      filename: null == filename
          ? _value.filename
          : filename // ignore: cast_nullable_to_non_nullable
              as String,
      content: null == content
          ? _value.content
          : content // ignore: cast_nullable_to_non_nullable
              as String,
      contentType: null == contentType
          ? _value.contentType
          : contentType // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_EmailAttachmentCopyWith<$Res>
    implements $EmailAttachmentCopyWith<$Res> {
  factory _$$_EmailAttachmentCopyWith(
          _$_EmailAttachment value, $Res Function(_$_EmailAttachment) then) =
      __$$_EmailAttachmentCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String filename, String content, String contentType});
}

/// @nodoc
class __$$_EmailAttachmentCopyWithImpl<$Res>
    extends _$EmailAttachmentCopyWithImpl<$Res, _$_EmailAttachment>
    implements _$$_EmailAttachmentCopyWith<$Res> {
  __$$_EmailAttachmentCopyWithImpl(
      _$_EmailAttachment _value, $Res Function(_$_EmailAttachment) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? filename = null,
    Object? content = null,
    Object? contentType = null,
  }) {
    return _then(_$_EmailAttachment(
      filename: null == filename
          ? _value.filename
          : filename // ignore: cast_nullable_to_non_nullable
              as String,
      content: null == content
          ? _value.content
          : content // ignore: cast_nullable_to_non_nullable
              as String,
      contentType: null == contentType
          ? _value.contentType
          : contentType // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_EmailAttachment implements _EmailAttachment {
  _$_EmailAttachment(
      {required this.filename,
      required this.content,
      required this.contentType});

  factory _$_EmailAttachment.fromJson(Map<String, dynamic> json) =>
      _$$_EmailAttachmentFromJson(json);

  @override
  final String filename;
  @override
  final String content;
  @override
  final String contentType;

  @override
  String toString() {
    return 'EmailAttachment(filename: $filename, content: $content, contentType: $contentType)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_EmailAttachment &&
            (identical(other.filename, filename) ||
                other.filename == filename) &&
            (identical(other.content, content) || other.content == content) &&
            (identical(other.contentType, contentType) ||
                other.contentType == contentType));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, filename, content, contentType);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_EmailAttachmentCopyWith<_$_EmailAttachment> get copyWith =>
      __$$_EmailAttachmentCopyWithImpl<_$_EmailAttachment>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_EmailAttachmentToJson(
      this,
    );
  }
}

abstract class _EmailAttachment implements EmailAttachment {
  factory _EmailAttachment(
      {required final String filename,
      required final String content,
      required final String contentType}) = _$_EmailAttachment;

  factory _EmailAttachment.fromJson(Map<String, dynamic> json) =
      _$_EmailAttachment.fromJson;

  @override
  String get filename;
  @override
  String get content;
  @override
  String get contentType;
  @override
  @JsonKey(ignore: true)
  _$$_EmailAttachmentCopyWith<_$_EmailAttachment> get copyWith =>
      throw _privateConstructorUsedError;
}

SendGridEmailMessage _$SendGridEmailMessageFromJson(Map<String, dynamic> json) {
  return _SendGridEmailMessage.fromJson(json);
}

/// @nodoc
mixin _$SendGridEmailMessage {
  String get subject => throw _privateConstructorUsedError;
  String get html => throw _privateConstructorUsedError;
  List<EmailAttachment>? get attachments => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $SendGridEmailMessageCopyWith<SendGridEmailMessage> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SendGridEmailMessageCopyWith<$Res> {
  factory $SendGridEmailMessageCopyWith(SendGridEmailMessage value,
          $Res Function(SendGridEmailMessage) then) =
      _$SendGridEmailMessageCopyWithImpl<$Res, SendGridEmailMessage>;
  @useResult
  $Res call({String subject, String html, List<EmailAttachment>? attachments});
}

/// @nodoc
class _$SendGridEmailMessageCopyWithImpl<$Res,
        $Val extends SendGridEmailMessage>
    implements $SendGridEmailMessageCopyWith<$Res> {
  _$SendGridEmailMessageCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? subject = null,
    Object? html = null,
    Object? attachments = freezed,
  }) {
    return _then(_value.copyWith(
      subject: null == subject
          ? _value.subject
          : subject // ignore: cast_nullable_to_non_nullable
              as String,
      html: null == html
          ? _value.html
          : html // ignore: cast_nullable_to_non_nullable
              as String,
      attachments: freezed == attachments
          ? _value.attachments
          : attachments // ignore: cast_nullable_to_non_nullable
              as List<EmailAttachment>?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_SendGridEmailMessageCopyWith<$Res>
    implements $SendGridEmailMessageCopyWith<$Res> {
  factory _$$_SendGridEmailMessageCopyWith(_$_SendGridEmailMessage value,
          $Res Function(_$_SendGridEmailMessage) then) =
      __$$_SendGridEmailMessageCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String subject, String html, List<EmailAttachment>? attachments});
}

/// @nodoc
class __$$_SendGridEmailMessageCopyWithImpl<$Res>
    extends _$SendGridEmailMessageCopyWithImpl<$Res, _$_SendGridEmailMessage>
    implements _$$_SendGridEmailMessageCopyWith<$Res> {
  __$$_SendGridEmailMessageCopyWithImpl(_$_SendGridEmailMessage _value,
      $Res Function(_$_SendGridEmailMessage) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? subject = null,
    Object? html = null,
    Object? attachments = freezed,
  }) {
    return _then(_$_SendGridEmailMessage(
      subject: null == subject
          ? _value.subject
          : subject // ignore: cast_nullable_to_non_nullable
              as String,
      html: null == html
          ? _value.html
          : html // ignore: cast_nullable_to_non_nullable
              as String,
      attachments: freezed == attachments
          ? _value.attachments
          : attachments // ignore: cast_nullable_to_non_nullable
              as List<EmailAttachment>?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_SendGridEmailMessage implements _SendGridEmailMessage {
  _$_SendGridEmailMessage(
      {required this.subject, required this.html, this.attachments});

  factory _$_SendGridEmailMessage.fromJson(Map<String, dynamic> json) =>
      _$$_SendGridEmailMessageFromJson(json);

  @override
  final String subject;
  @override
  final String html;
  @override
  final List<EmailAttachment>? attachments;

  @override
  String toString() {
    return 'SendGridEmailMessage(subject: $subject, html: $html, attachments: $attachments)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_SendGridEmailMessage &&
            (identical(other.subject, subject) || other.subject == subject) &&
            (identical(other.html, html) || other.html == html) &&
            const DeepCollectionEquality()
                .equals(other.attachments, attachments));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, subject, html,
      const DeepCollectionEquality().hash(attachments));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_SendGridEmailMessageCopyWith<_$_SendGridEmailMessage> get copyWith =>
      __$$_SendGridEmailMessageCopyWithImpl<_$_SendGridEmailMessage>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_SendGridEmailMessageToJson(
      this,
    );
  }
}

abstract class _SendGridEmailMessage implements SendGridEmailMessage {
  factory _SendGridEmailMessage(
      {required final String subject,
      required final String html,
      final List<EmailAttachment>? attachments}) = _$_SendGridEmailMessage;

  factory _SendGridEmailMessage.fromJson(Map<String, dynamic> json) =
      _$_SendGridEmailMessage.fromJson;

  @override
  String get subject;
  @override
  String get html;
  @override
  List<EmailAttachment>? get attachments;
  @override
  @JsonKey(ignore: true)
  _$$_SendGridEmailMessageCopyWith<_$_SendGridEmailMessage> get copyWith =>
      throw _privateConstructorUsedError;
}

GetServerTimestampRequest _$GetServerTimestampRequestFromJson(
    Map<String, dynamic> json) {
  return _GetServerTimestampRequest.fromJson(json);
}

/// @nodoc
mixin _$GetServerTimestampRequest {
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GetServerTimestampRequestCopyWith<$Res> {
  factory $GetServerTimestampRequestCopyWith(GetServerTimestampRequest value,
          $Res Function(GetServerTimestampRequest) then) =
      _$GetServerTimestampRequestCopyWithImpl<$Res, GetServerTimestampRequest>;
}

/// @nodoc
class _$GetServerTimestampRequestCopyWithImpl<$Res,
        $Val extends GetServerTimestampRequest>
    implements $GetServerTimestampRequestCopyWith<$Res> {
  _$GetServerTimestampRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;
}

/// @nodoc
abstract class _$$_GetServerTimestampRequestCopyWith<$Res> {
  factory _$$_GetServerTimestampRequestCopyWith(
          _$_GetServerTimestampRequest value,
          $Res Function(_$_GetServerTimestampRequest) then) =
      __$$_GetServerTimestampRequestCopyWithImpl<$Res>;
}

/// @nodoc
class __$$_GetServerTimestampRequestCopyWithImpl<$Res>
    extends _$GetServerTimestampRequestCopyWithImpl<$Res,
        _$_GetServerTimestampRequest>
    implements _$$_GetServerTimestampRequestCopyWith<$Res> {
  __$$_GetServerTimestampRequestCopyWithImpl(
      _$_GetServerTimestampRequest _value,
      $Res Function(_$_GetServerTimestampRequest) _then)
      : super(_value, _then);
}

/// @nodoc
@JsonSerializable()
class _$_GetServerTimestampRequest implements _GetServerTimestampRequest {
  _$_GetServerTimestampRequest();

  factory _$_GetServerTimestampRequest.fromJson(Map<String, dynamic> json) =>
      _$$_GetServerTimestampRequestFromJson(json);

  @override
  String toString() {
    return 'GetServerTimestampRequest()';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_GetServerTimestampRequest);
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => runtimeType.hashCode;

  @override
  Map<String, dynamic> toJson() {
    return _$$_GetServerTimestampRequestToJson(
      this,
    );
  }
}

abstract class _GetServerTimestampRequest implements GetServerTimestampRequest {
  factory _GetServerTimestampRequest() = _$_GetServerTimestampRequest;

  factory _GetServerTimestampRequest.fromJson(Map<String, dynamic> json) =
      _$_GetServerTimestampRequest.fromJson;
}

GetServerTimestampResponse _$GetServerTimestampResponseFromJson(
    Map<String, dynamic> json) {
  return _GetServerTimestampResponse.fromJson(json);
}

/// @nodoc
mixin _$GetServerTimestampResponse {
  DateTime get serverTimestamp => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $GetServerTimestampResponseCopyWith<GetServerTimestampResponse>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GetServerTimestampResponseCopyWith<$Res> {
  factory $GetServerTimestampResponseCopyWith(GetServerTimestampResponse value,
          $Res Function(GetServerTimestampResponse) then) =
      _$GetServerTimestampResponseCopyWithImpl<$Res,
          GetServerTimestampResponse>;
  @useResult
  $Res call({DateTime serverTimestamp});
}

/// @nodoc
class _$GetServerTimestampResponseCopyWithImpl<$Res,
        $Val extends GetServerTimestampResponse>
    implements $GetServerTimestampResponseCopyWith<$Res> {
  _$GetServerTimestampResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? serverTimestamp = null,
  }) {
    return _then(_value.copyWith(
      serverTimestamp: null == serverTimestamp
          ? _value.serverTimestamp
          : serverTimestamp // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_GetServerTimestampResponseCopyWith<$Res>
    implements $GetServerTimestampResponseCopyWith<$Res> {
  factory _$$_GetServerTimestampResponseCopyWith(
          _$_GetServerTimestampResponse value,
          $Res Function(_$_GetServerTimestampResponse) then) =
      __$$_GetServerTimestampResponseCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({DateTime serverTimestamp});
}

/// @nodoc
class __$$_GetServerTimestampResponseCopyWithImpl<$Res>
    extends _$GetServerTimestampResponseCopyWithImpl<$Res,
        _$_GetServerTimestampResponse>
    implements _$$_GetServerTimestampResponseCopyWith<$Res> {
  __$$_GetServerTimestampResponseCopyWithImpl(
      _$_GetServerTimestampResponse _value,
      $Res Function(_$_GetServerTimestampResponse) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? serverTimestamp = null,
  }) {
    return _then(_$_GetServerTimestampResponse(
      serverTimestamp: null == serverTimestamp
          ? _value.serverTimestamp
          : serverTimestamp // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_GetServerTimestampResponse implements _GetServerTimestampResponse {
  _$_GetServerTimestampResponse({required this.serverTimestamp});

  factory _$_GetServerTimestampResponse.fromJson(Map<String, dynamic> json) =>
      _$$_GetServerTimestampResponseFromJson(json);

  @override
  final DateTime serverTimestamp;

  @override
  String toString() {
    return 'GetServerTimestampResponse(serverTimestamp: $serverTimestamp)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_GetServerTimestampResponse &&
            (identical(other.serverTimestamp, serverTimestamp) ||
                other.serverTimestamp == serverTimestamp));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, serverTimestamp);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_GetServerTimestampResponseCopyWith<_$_GetServerTimestampResponse>
      get copyWith => __$$_GetServerTimestampResponseCopyWithImpl<
          _$_GetServerTimestampResponse>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_GetServerTimestampResponseToJson(
      this,
    );
  }
}

abstract class _GetServerTimestampResponse
    implements GetServerTimestampResponse {
  factory _GetServerTimestampResponse(
          {required final DateTime serverTimestamp}) =
      _$_GetServerTimestampResponse;

  factory _GetServerTimestampResponse.fromJson(Map<String, dynamic> json) =
      _$_GetServerTimestampResponse.fromJson;

  @override
  DateTime get serverTimestamp;
  @override
  @JsonKey(ignore: true)
  _$$_GetServerTimestampResponseCopyWith<_$_GetServerTimestampResponse>
      get copyWith => throw _privateConstructorUsedError;
}

GetTwilioMeetingJoinInfoRequest _$GetTwilioMeetingJoinInfoRequestFromJson(
    Map<String, dynamic> json) {
  return _GetTwilioMeetingJoinInfoRequest.fromJson(json);
}

/// @nodoc
mixin _$GetTwilioMeetingJoinInfoRequest {
  String get discussionPath => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $GetTwilioMeetingJoinInfoRequestCopyWith<GetTwilioMeetingJoinInfoRequest>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GetTwilioMeetingJoinInfoRequestCopyWith<$Res> {
  factory $GetTwilioMeetingJoinInfoRequestCopyWith(
          GetTwilioMeetingJoinInfoRequest value,
          $Res Function(GetTwilioMeetingJoinInfoRequest) then) =
      _$GetTwilioMeetingJoinInfoRequestCopyWithImpl<$Res,
          GetTwilioMeetingJoinInfoRequest>;
  @useResult
  $Res call({String discussionPath});
}

/// @nodoc
class _$GetTwilioMeetingJoinInfoRequestCopyWithImpl<$Res,
        $Val extends GetTwilioMeetingJoinInfoRequest>
    implements $GetTwilioMeetingJoinInfoRequestCopyWith<$Res> {
  _$GetTwilioMeetingJoinInfoRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? discussionPath = null,
  }) {
    return _then(_value.copyWith(
      discussionPath: null == discussionPath
          ? _value.discussionPath
          : discussionPath // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_GetTwilioMeetingJoinInfoRequestCopyWith<$Res>
    implements $GetTwilioMeetingJoinInfoRequestCopyWith<$Res> {
  factory _$$_GetTwilioMeetingJoinInfoRequestCopyWith(
          _$_GetTwilioMeetingJoinInfoRequest value,
          $Res Function(_$_GetTwilioMeetingJoinInfoRequest) then) =
      __$$_GetTwilioMeetingJoinInfoRequestCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String discussionPath});
}

/// @nodoc
class __$$_GetTwilioMeetingJoinInfoRequestCopyWithImpl<$Res>
    extends _$GetTwilioMeetingJoinInfoRequestCopyWithImpl<$Res,
        _$_GetTwilioMeetingJoinInfoRequest>
    implements _$$_GetTwilioMeetingJoinInfoRequestCopyWith<$Res> {
  __$$_GetTwilioMeetingJoinInfoRequestCopyWithImpl(
      _$_GetTwilioMeetingJoinInfoRequest _value,
      $Res Function(_$_GetTwilioMeetingJoinInfoRequest) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? discussionPath = null,
  }) {
    return _then(_$_GetTwilioMeetingJoinInfoRequest(
      discussionPath: null == discussionPath
          ? _value.discussionPath
          : discussionPath // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_GetTwilioMeetingJoinInfoRequest
    implements _GetTwilioMeetingJoinInfoRequest {
  _$_GetTwilioMeetingJoinInfoRequest({required this.discussionPath});

  factory _$_GetTwilioMeetingJoinInfoRequest.fromJson(
          Map<String, dynamic> json) =>
      _$$_GetTwilioMeetingJoinInfoRequestFromJson(json);

  @override
  final String discussionPath;

  @override
  String toString() {
    return 'GetTwilioMeetingJoinInfoRequest(discussionPath: $discussionPath)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_GetTwilioMeetingJoinInfoRequest &&
            (identical(other.discussionPath, discussionPath) ||
                other.discussionPath == discussionPath));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, discussionPath);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_GetTwilioMeetingJoinInfoRequestCopyWith<
          _$_GetTwilioMeetingJoinInfoRequest>
      get copyWith => __$$_GetTwilioMeetingJoinInfoRequestCopyWithImpl<
          _$_GetTwilioMeetingJoinInfoRequest>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_GetTwilioMeetingJoinInfoRequestToJson(
      this,
    );
  }
}

abstract class _GetTwilioMeetingJoinInfoRequest
    implements GetTwilioMeetingJoinInfoRequest {
  factory _GetTwilioMeetingJoinInfoRequest(
          {required final String discussionPath}) =
      _$_GetTwilioMeetingJoinInfoRequest;

  factory _GetTwilioMeetingJoinInfoRequest.fromJson(Map<String, dynamic> json) =
      _$_GetTwilioMeetingJoinInfoRequest.fromJson;

  @override
  String get discussionPath;
  @override
  @JsonKey(ignore: true)
  _$$_GetTwilioMeetingJoinInfoRequestCopyWith<
          _$_GetTwilioMeetingJoinInfoRequest>
      get copyWith => throw _privateConstructorUsedError;
}

GetMeetingJoinInfoRequest _$GetMeetingJoinInfoRequestFromJson(
    Map<String, dynamic> json) {
  return _GetMeetingJoinInfoRequest.fromJson(json);
}

/// @nodoc
mixin _$GetMeetingJoinInfoRequest {
  String get discussionPath =>
      throw _privateConstructorUsedError; // External ID of this user when provided by communities such as Unify America.
  String? get externalCommunityId => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $GetMeetingJoinInfoRequestCopyWith<GetMeetingJoinInfoRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GetMeetingJoinInfoRequestCopyWith<$Res> {
  factory $GetMeetingJoinInfoRequestCopyWith(GetMeetingJoinInfoRequest value,
          $Res Function(GetMeetingJoinInfoRequest) then) =
      _$GetMeetingJoinInfoRequestCopyWithImpl<$Res, GetMeetingJoinInfoRequest>;
  @useResult
  $Res call({String discussionPath, String? externalCommunityId});
}

/// @nodoc
class _$GetMeetingJoinInfoRequestCopyWithImpl<$Res,
        $Val extends GetMeetingJoinInfoRequest>
    implements $GetMeetingJoinInfoRequestCopyWith<$Res> {
  _$GetMeetingJoinInfoRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? discussionPath = null,
    Object? externalCommunityId = freezed,
  }) {
    return _then(_value.copyWith(
      discussionPath: null == discussionPath
          ? _value.discussionPath
          : discussionPath // ignore: cast_nullable_to_non_nullable
              as String,
      externalCommunityId: freezed == externalCommunityId
          ? _value.externalCommunityId
          : externalCommunityId // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_GetMeetingJoinInfoRequestCopyWith<$Res>
    implements $GetMeetingJoinInfoRequestCopyWith<$Res> {
  factory _$$_GetMeetingJoinInfoRequestCopyWith(
          _$_GetMeetingJoinInfoRequest value,
          $Res Function(_$_GetMeetingJoinInfoRequest) then) =
      __$$_GetMeetingJoinInfoRequestCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String discussionPath, String? externalCommunityId});
}

/// @nodoc
class __$$_GetMeetingJoinInfoRequestCopyWithImpl<$Res>
    extends _$GetMeetingJoinInfoRequestCopyWithImpl<$Res,
        _$_GetMeetingJoinInfoRequest>
    implements _$$_GetMeetingJoinInfoRequestCopyWith<$Res> {
  __$$_GetMeetingJoinInfoRequestCopyWithImpl(
      _$_GetMeetingJoinInfoRequest _value,
      $Res Function(_$_GetMeetingJoinInfoRequest) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? discussionPath = null,
    Object? externalCommunityId = freezed,
  }) {
    return _then(_$_GetMeetingJoinInfoRequest(
      discussionPath: null == discussionPath
          ? _value.discussionPath
          : discussionPath // ignore: cast_nullable_to_non_nullable
              as String,
      externalCommunityId: freezed == externalCommunityId
          ? _value.externalCommunityId
          : externalCommunityId // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_GetMeetingJoinInfoRequest implements _GetMeetingJoinInfoRequest {
  _$_GetMeetingJoinInfoRequest(
      {required this.discussionPath, this.externalCommunityId});

  factory _$_GetMeetingJoinInfoRequest.fromJson(Map<String, dynamic> json) =>
      _$$_GetMeetingJoinInfoRequestFromJson(json);

  @override
  final String discussionPath;
// External ID of this user when provided by communities such as Unify America.
  @override
  final String? externalCommunityId;

  @override
  String toString() {
    return 'GetMeetingJoinInfoRequest(discussionPath: $discussionPath, externalCommunityId: $externalCommunityId)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_GetMeetingJoinInfoRequest &&
            (identical(other.discussionPath, discussionPath) ||
                other.discussionPath == discussionPath) &&
            (identical(other.externalCommunityId, externalCommunityId) ||
                other.externalCommunityId == externalCommunityId));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode =>
      Object.hash(runtimeType, discussionPath, externalCommunityId);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_GetMeetingJoinInfoRequestCopyWith<_$_GetMeetingJoinInfoRequest>
      get copyWith => __$$_GetMeetingJoinInfoRequestCopyWithImpl<
          _$_GetMeetingJoinInfoRequest>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_GetMeetingJoinInfoRequestToJson(
      this,
    );
  }
}

abstract class _GetMeetingJoinInfoRequest implements GetMeetingJoinInfoRequest {
  factory _GetMeetingJoinInfoRequest(
      {required final String discussionPath,
      final String? externalCommunityId}) = _$_GetMeetingJoinInfoRequest;

  factory _GetMeetingJoinInfoRequest.fromJson(Map<String, dynamic> json) =
      _$_GetMeetingJoinInfoRequest.fromJson;

  @override
  String get discussionPath;
  @override // External ID of this user when provided by communities such as Unify America.
  String? get externalCommunityId;
  @override
  @JsonKey(ignore: true)
  _$$_GetMeetingJoinInfoRequestCopyWith<_$_GetMeetingJoinInfoRequest>
      get copyWith => throw _privateConstructorUsedError;
}

GetMeetingJoinInfoResponse _$GetMeetingJoinInfoResponseFromJson(
    Map<String, dynamic> json) {
  return _GetMeetingJoinInfoResponse.fromJson(json);
}

/// @nodoc
mixin _$GetMeetingJoinInfoResponse {
  String get identity => throw _privateConstructorUsedError;
  String get meetingToken => throw _privateConstructorUsedError;
  String get meetingId => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $GetMeetingJoinInfoResponseCopyWith<GetMeetingJoinInfoResponse>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GetMeetingJoinInfoResponseCopyWith<$Res> {
  factory $GetMeetingJoinInfoResponseCopyWith(GetMeetingJoinInfoResponse value,
          $Res Function(GetMeetingJoinInfoResponse) then) =
      _$GetMeetingJoinInfoResponseCopyWithImpl<$Res,
          GetMeetingJoinInfoResponse>;
  @useResult
  $Res call({String identity, String meetingToken, String meetingId});
}

/// @nodoc
class _$GetMeetingJoinInfoResponseCopyWithImpl<$Res,
        $Val extends GetMeetingJoinInfoResponse>
    implements $GetMeetingJoinInfoResponseCopyWith<$Res> {
  _$GetMeetingJoinInfoResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? identity = null,
    Object? meetingToken = null,
    Object? meetingId = null,
  }) {
    return _then(_value.copyWith(
      identity: null == identity
          ? _value.identity
          : identity // ignore: cast_nullable_to_non_nullable
              as String,
      meetingToken: null == meetingToken
          ? _value.meetingToken
          : meetingToken // ignore: cast_nullable_to_non_nullable
              as String,
      meetingId: null == meetingId
          ? _value.meetingId
          : meetingId // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_GetMeetingJoinInfoResponseCopyWith<$Res>
    implements $GetMeetingJoinInfoResponseCopyWith<$Res> {
  factory _$$_GetMeetingJoinInfoResponseCopyWith(
          _$_GetMeetingJoinInfoResponse value,
          $Res Function(_$_GetMeetingJoinInfoResponse) then) =
      __$$_GetMeetingJoinInfoResponseCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String identity, String meetingToken, String meetingId});
}

/// @nodoc
class __$$_GetMeetingJoinInfoResponseCopyWithImpl<$Res>
    extends _$GetMeetingJoinInfoResponseCopyWithImpl<$Res,
        _$_GetMeetingJoinInfoResponse>
    implements _$$_GetMeetingJoinInfoResponseCopyWith<$Res> {
  __$$_GetMeetingJoinInfoResponseCopyWithImpl(
      _$_GetMeetingJoinInfoResponse _value,
      $Res Function(_$_GetMeetingJoinInfoResponse) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? identity = null,
    Object? meetingToken = null,
    Object? meetingId = null,
  }) {
    return _then(_$_GetMeetingJoinInfoResponse(
      identity: null == identity
          ? _value.identity
          : identity // ignore: cast_nullable_to_non_nullable
              as String,
      meetingToken: null == meetingToken
          ? _value.meetingToken
          : meetingToken // ignore: cast_nullable_to_non_nullable
              as String,
      meetingId: null == meetingId
          ? _value.meetingId
          : meetingId // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_GetMeetingJoinInfoResponse implements _GetMeetingJoinInfoResponse {
  _$_GetMeetingJoinInfoResponse(
      {required this.identity,
      required this.meetingToken,
      required this.meetingId});

  factory _$_GetMeetingJoinInfoResponse.fromJson(Map<String, dynamic> json) =>
      _$$_GetMeetingJoinInfoResponseFromJson(json);

  @override
  final String identity;
  @override
  final String meetingToken;
  @override
  final String meetingId;

  @override
  String toString() {
    return 'GetMeetingJoinInfoResponse(identity: $identity, meetingToken: $meetingToken, meetingId: $meetingId)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_GetMeetingJoinInfoResponse &&
            (identical(other.identity, identity) ||
                other.identity == identity) &&
            (identical(other.meetingToken, meetingToken) ||
                other.meetingToken == meetingToken) &&
            (identical(other.meetingId, meetingId) ||
                other.meetingId == meetingId));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode =>
      Object.hash(runtimeType, identity, meetingToken, meetingId);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_GetMeetingJoinInfoResponseCopyWith<_$_GetMeetingJoinInfoResponse>
      get copyWith => __$$_GetMeetingJoinInfoResponseCopyWithImpl<
          _$_GetMeetingJoinInfoResponse>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_GetMeetingJoinInfoResponseToJson(
      this,
    );
  }
}

abstract class _GetMeetingJoinInfoResponse
    implements GetMeetingJoinInfoResponse {
  factory _GetMeetingJoinInfoResponse(
      {required final String identity,
      required final String meetingToken,
      required final String meetingId}) = _$_GetMeetingJoinInfoResponse;

  factory _GetMeetingJoinInfoResponse.fromJson(Map<String, dynamic> json) =
      _$_GetMeetingJoinInfoResponse.fromJson;

  @override
  String get identity;
  @override
  String get meetingToken;
  @override
  String get meetingId;
  @override
  @JsonKey(ignore: true)
  _$$_GetMeetingJoinInfoResponseCopyWith<_$_GetMeetingJoinInfoResponse>
      get copyWith => throw _privateConstructorUsedError;
}

GetInstantMeetingJoinInfoRequest _$GetInstantMeetingJoinInfoRequestFromJson(
    Map<String, dynamic> json) {
  return _GetInstantMeetingJoinInfoRequest.fromJson(json);
}

/// @nodoc
mixin _$GetInstantMeetingJoinInfoRequest {
  String get juntoId => throw _privateConstructorUsedError;
  String get meetingId => throw _privateConstructorUsedError;
  String get userIdentifier => throw _privateConstructorUsedError;
  String get userDisplayName => throw _privateConstructorUsedError;
  bool get record => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $GetInstantMeetingJoinInfoRequestCopyWith<GetInstantMeetingJoinInfoRequest>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GetInstantMeetingJoinInfoRequestCopyWith<$Res> {
  factory $GetInstantMeetingJoinInfoRequestCopyWith(
          GetInstantMeetingJoinInfoRequest value,
          $Res Function(GetInstantMeetingJoinInfoRequest) then) =
      _$GetInstantMeetingJoinInfoRequestCopyWithImpl<$Res,
          GetInstantMeetingJoinInfoRequest>;
  @useResult
  $Res call(
      {String juntoId,
      String meetingId,
      String userIdentifier,
      String userDisplayName,
      bool record});
}

/// @nodoc
class _$GetInstantMeetingJoinInfoRequestCopyWithImpl<$Res,
        $Val extends GetInstantMeetingJoinInfoRequest>
    implements $GetInstantMeetingJoinInfoRequestCopyWith<$Res> {
  _$GetInstantMeetingJoinInfoRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? juntoId = null,
    Object? meetingId = null,
    Object? userIdentifier = null,
    Object? userDisplayName = null,
    Object? record = null,
  }) {
    return _then(_value.copyWith(
      juntoId: null == juntoId
          ? _value.juntoId
          : juntoId // ignore: cast_nullable_to_non_nullable
              as String,
      meetingId: null == meetingId
          ? _value.meetingId
          : meetingId // ignore: cast_nullable_to_non_nullable
              as String,
      userIdentifier: null == userIdentifier
          ? _value.userIdentifier
          : userIdentifier // ignore: cast_nullable_to_non_nullable
              as String,
      userDisplayName: null == userDisplayName
          ? _value.userDisplayName
          : userDisplayName // ignore: cast_nullable_to_non_nullable
              as String,
      record: null == record
          ? _value.record
          : record // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_GetInstantMeetingJoinInfoRequestCopyWith<$Res>
    implements $GetInstantMeetingJoinInfoRequestCopyWith<$Res> {
  factory _$$_GetInstantMeetingJoinInfoRequestCopyWith(
          _$_GetInstantMeetingJoinInfoRequest value,
          $Res Function(_$_GetInstantMeetingJoinInfoRequest) then) =
      __$$_GetInstantMeetingJoinInfoRequestCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String juntoId,
      String meetingId,
      String userIdentifier,
      String userDisplayName,
      bool record});
}

/// @nodoc
class __$$_GetInstantMeetingJoinInfoRequestCopyWithImpl<$Res>
    extends _$GetInstantMeetingJoinInfoRequestCopyWithImpl<$Res,
        _$_GetInstantMeetingJoinInfoRequest>
    implements _$$_GetInstantMeetingJoinInfoRequestCopyWith<$Res> {
  __$$_GetInstantMeetingJoinInfoRequestCopyWithImpl(
      _$_GetInstantMeetingJoinInfoRequest _value,
      $Res Function(_$_GetInstantMeetingJoinInfoRequest) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? juntoId = null,
    Object? meetingId = null,
    Object? userIdentifier = null,
    Object? userDisplayName = null,
    Object? record = null,
  }) {
    return _then(_$_GetInstantMeetingJoinInfoRequest(
      juntoId: null == juntoId
          ? _value.juntoId
          : juntoId // ignore: cast_nullable_to_non_nullable
              as String,
      meetingId: null == meetingId
          ? _value.meetingId
          : meetingId // ignore: cast_nullable_to_non_nullable
              as String,
      userIdentifier: null == userIdentifier
          ? _value.userIdentifier
          : userIdentifier // ignore: cast_nullable_to_non_nullable
              as String,
      userDisplayName: null == userDisplayName
          ? _value.userDisplayName
          : userDisplayName // ignore: cast_nullable_to_non_nullable
              as String,
      record: null == record
          ? _value.record
          : record // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_GetInstantMeetingJoinInfoRequest
    implements _GetInstantMeetingJoinInfoRequest {
  _$_GetInstantMeetingJoinInfoRequest(
      {required this.juntoId,
      required this.meetingId,
      required this.userIdentifier,
      required this.userDisplayName,
      required this.record});

  factory _$_GetInstantMeetingJoinInfoRequest.fromJson(
          Map<String, dynamic> json) =>
      _$$_GetInstantMeetingJoinInfoRequestFromJson(json);

  @override
  final String juntoId;
  @override
  final String meetingId;
  @override
  final String userIdentifier;
  @override
  final String userDisplayName;
  @override
  final bool record;

  @override
  String toString() {
    return 'GetInstantMeetingJoinInfoRequest(juntoId: $juntoId, meetingId: $meetingId, userIdentifier: $userIdentifier, userDisplayName: $userDisplayName, record: $record)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_GetInstantMeetingJoinInfoRequest &&
            (identical(other.juntoId, juntoId) || other.juntoId == juntoId) &&
            (identical(other.meetingId, meetingId) ||
                other.meetingId == meetingId) &&
            (identical(other.userIdentifier, userIdentifier) ||
                other.userIdentifier == userIdentifier) &&
            (identical(other.userDisplayName, userDisplayName) ||
                other.userDisplayName == userDisplayName) &&
            (identical(other.record, record) || other.record == record));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType, juntoId, meetingId, userIdentifier, userDisplayName, record);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_GetInstantMeetingJoinInfoRequestCopyWith<
          _$_GetInstantMeetingJoinInfoRequest>
      get copyWith => __$$_GetInstantMeetingJoinInfoRequestCopyWithImpl<
          _$_GetInstantMeetingJoinInfoRequest>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_GetInstantMeetingJoinInfoRequestToJson(
      this,
    );
  }
}

abstract class _GetInstantMeetingJoinInfoRequest
    implements GetInstantMeetingJoinInfoRequest {
  factory _GetInstantMeetingJoinInfoRequest(
      {required final String juntoId,
      required final String meetingId,
      required final String userIdentifier,
      required final String userDisplayName,
      required final bool record}) = _$_GetInstantMeetingJoinInfoRequest;

  factory _GetInstantMeetingJoinInfoRequest.fromJson(
      Map<String, dynamic> json) = _$_GetInstantMeetingJoinInfoRequest.fromJson;

  @override
  String get juntoId;
  @override
  String get meetingId;
  @override
  String get userIdentifier;
  @override
  String get userDisplayName;
  @override
  bool get record;
  @override
  @JsonKey(ignore: true)
  _$$_GetInstantMeetingJoinInfoRequestCopyWith<
          _$_GetInstantMeetingJoinInfoRequest>
      get copyWith => throw _privateConstructorUsedError;
}

GetUserAdminDetailsRequest _$GetUserAdminDetailsRequestFromJson(
    Map<String, dynamic> json) {
  return _GetUserAdminDetailsRequest.fromJson(json);
}

/// @nodoc
mixin _$GetUserAdminDetailsRequest {
  List<String> get userIds => throw _privateConstructorUsedError;
  String? get juntoId => throw _privateConstructorUsedError;
  String? get discussionPath => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $GetUserAdminDetailsRequestCopyWith<GetUserAdminDetailsRequest>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GetUserAdminDetailsRequestCopyWith<$Res> {
  factory $GetUserAdminDetailsRequestCopyWith(GetUserAdminDetailsRequest value,
          $Res Function(GetUserAdminDetailsRequest) then) =
      _$GetUserAdminDetailsRequestCopyWithImpl<$Res,
          GetUserAdminDetailsRequest>;
  @useResult
  $Res call({List<String> userIds, String? juntoId, String? discussionPath});
}

/// @nodoc
class _$GetUserAdminDetailsRequestCopyWithImpl<$Res,
        $Val extends GetUserAdminDetailsRequest>
    implements $GetUserAdminDetailsRequestCopyWith<$Res> {
  _$GetUserAdminDetailsRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userIds = null,
    Object? juntoId = freezed,
    Object? discussionPath = freezed,
  }) {
    return _then(_value.copyWith(
      userIds: null == userIds
          ? _value.userIds
          : userIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
      juntoId: freezed == juntoId
          ? _value.juntoId
          : juntoId // ignore: cast_nullable_to_non_nullable
              as String?,
      discussionPath: freezed == discussionPath
          ? _value.discussionPath
          : discussionPath // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_GetUserAdminDetailsRequestCopyWith<$Res>
    implements $GetUserAdminDetailsRequestCopyWith<$Res> {
  factory _$$_GetUserAdminDetailsRequestCopyWith(
          _$_GetUserAdminDetailsRequest value,
          $Res Function(_$_GetUserAdminDetailsRequest) then) =
      __$$_GetUserAdminDetailsRequestCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({List<String> userIds, String? juntoId, String? discussionPath});
}

/// @nodoc
class __$$_GetUserAdminDetailsRequestCopyWithImpl<$Res>
    extends _$GetUserAdminDetailsRequestCopyWithImpl<$Res,
        _$_GetUserAdminDetailsRequest>
    implements _$$_GetUserAdminDetailsRequestCopyWith<$Res> {
  __$$_GetUserAdminDetailsRequestCopyWithImpl(
      _$_GetUserAdminDetailsRequest _value,
      $Res Function(_$_GetUserAdminDetailsRequest) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userIds = null,
    Object? juntoId = freezed,
    Object? discussionPath = freezed,
  }) {
    return _then(_$_GetUserAdminDetailsRequest(
      userIds: null == userIds
          ? _value.userIds
          : userIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
      juntoId: freezed == juntoId
          ? _value.juntoId
          : juntoId // ignore: cast_nullable_to_non_nullable
              as String?,
      discussionPath: freezed == discussionPath
          ? _value.discussionPath
          : discussionPath // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_GetUserAdminDetailsRequest implements _GetUserAdminDetailsRequest {
  _$_GetUserAdminDetailsRequest(
      {required this.userIds, this.juntoId, this.discussionPath});

  factory _$_GetUserAdminDetailsRequest.fromJson(Map<String, dynamic> json) =>
      _$$_GetUserAdminDetailsRequestFromJson(json);

  @override
  final List<String> userIds;
  @override
  final String? juntoId;
  @override
  final String? discussionPath;

  @override
  String toString() {
    return 'GetUserAdminDetailsRequest(userIds: $userIds, juntoId: $juntoId, discussionPath: $discussionPath)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_GetUserAdminDetailsRequest &&
            const DeepCollectionEquality().equals(other.userIds, userIds) &&
            (identical(other.juntoId, juntoId) || other.juntoId == juntoId) &&
            (identical(other.discussionPath, discussionPath) ||
                other.discussionPath == discussionPath));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType,
      const DeepCollectionEquality().hash(userIds), juntoId, discussionPath);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_GetUserAdminDetailsRequestCopyWith<_$_GetUserAdminDetailsRequest>
      get copyWith => __$$_GetUserAdminDetailsRequestCopyWithImpl<
          _$_GetUserAdminDetailsRequest>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_GetUserAdminDetailsRequestToJson(
      this,
    );
  }
}

abstract class _GetUserAdminDetailsRequest
    implements GetUserAdminDetailsRequest {
  factory _GetUserAdminDetailsRequest(
      {required final List<String> userIds,
      final String? juntoId,
      final String? discussionPath}) = _$_GetUserAdminDetailsRequest;

  factory _GetUserAdminDetailsRequest.fromJson(Map<String, dynamic> json) =
      _$_GetUserAdminDetailsRequest.fromJson;

  @override
  List<String> get userIds;
  @override
  String? get juntoId;
  @override
  String? get discussionPath;
  @override
  @JsonKey(ignore: true)
  _$$_GetUserAdminDetailsRequestCopyWith<_$_GetUserAdminDetailsRequest>
      get copyWith => throw _privateConstructorUsedError;
}

GetUserAdminDetailsResponse _$GetUserAdminDetailsResponseFromJson(
    Map<String, dynamic> json) {
  return _GetUserAdminDetailsResponse.fromJson(json);
}

/// @nodoc
mixin _$GetUserAdminDetailsResponse {
  List<UserAdminDetails> get userAdminDetails =>
      throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $GetUserAdminDetailsResponseCopyWith<GetUserAdminDetailsResponse>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GetUserAdminDetailsResponseCopyWith<$Res> {
  factory $GetUserAdminDetailsResponseCopyWith(
          GetUserAdminDetailsResponse value,
          $Res Function(GetUserAdminDetailsResponse) then) =
      _$GetUserAdminDetailsResponseCopyWithImpl<$Res,
          GetUserAdminDetailsResponse>;
  @useResult
  $Res call({List<UserAdminDetails> userAdminDetails});
}

/// @nodoc
class _$GetUserAdminDetailsResponseCopyWithImpl<$Res,
        $Val extends GetUserAdminDetailsResponse>
    implements $GetUserAdminDetailsResponseCopyWith<$Res> {
  _$GetUserAdminDetailsResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userAdminDetails = null,
  }) {
    return _then(_value.copyWith(
      userAdminDetails: null == userAdminDetails
          ? _value.userAdminDetails
          : userAdminDetails // ignore: cast_nullable_to_non_nullable
              as List<UserAdminDetails>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_GetUserAdminDetailsResponseCopyWith<$Res>
    implements $GetUserAdminDetailsResponseCopyWith<$Res> {
  factory _$$_GetUserAdminDetailsResponseCopyWith(
          _$_GetUserAdminDetailsResponse value,
          $Res Function(_$_GetUserAdminDetailsResponse) then) =
      __$$_GetUserAdminDetailsResponseCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({List<UserAdminDetails> userAdminDetails});
}

/// @nodoc
class __$$_GetUserAdminDetailsResponseCopyWithImpl<$Res>
    extends _$GetUserAdminDetailsResponseCopyWithImpl<$Res,
        _$_GetUserAdminDetailsResponse>
    implements _$$_GetUserAdminDetailsResponseCopyWith<$Res> {
  __$$_GetUserAdminDetailsResponseCopyWithImpl(
      _$_GetUserAdminDetailsResponse _value,
      $Res Function(_$_GetUserAdminDetailsResponse) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userAdminDetails = null,
  }) {
    return _then(_$_GetUserAdminDetailsResponse(
      userAdminDetails: null == userAdminDetails
          ? _value.userAdminDetails
          : userAdminDetails // ignore: cast_nullable_to_non_nullable
              as List<UserAdminDetails>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_GetUserAdminDetailsResponse implements _GetUserAdminDetailsResponse {
  _$_GetUserAdminDetailsResponse({required this.userAdminDetails});

  factory _$_GetUserAdminDetailsResponse.fromJson(Map<String, dynamic> json) =>
      _$$_GetUserAdminDetailsResponseFromJson(json);

  @override
  final List<UserAdminDetails> userAdminDetails;

  @override
  String toString() {
    return 'GetUserAdminDetailsResponse(userAdminDetails: $userAdminDetails)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_GetUserAdminDetailsResponse &&
            const DeepCollectionEquality()
                .equals(other.userAdminDetails, userAdminDetails));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType, const DeepCollectionEquality().hash(userAdminDetails));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_GetUserAdminDetailsResponseCopyWith<_$_GetUserAdminDetailsResponse>
      get copyWith => __$$_GetUserAdminDetailsResponseCopyWithImpl<
          _$_GetUserAdminDetailsResponse>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_GetUserAdminDetailsResponseToJson(
      this,
    );
  }
}

abstract class _GetUserAdminDetailsResponse
    implements GetUserAdminDetailsResponse {
  factory _GetUserAdminDetailsResponse(
          {required final List<UserAdminDetails> userAdminDetails}) =
      _$_GetUserAdminDetailsResponse;

  factory _GetUserAdminDetailsResponse.fromJson(Map<String, dynamic> json) =
      _$_GetUserAdminDetailsResponse.fromJson;

  @override
  List<UserAdminDetails> get userAdminDetails;
  @override
  @JsonKey(ignore: true)
  _$$_GetUserAdminDetailsResponseCopyWith<_$_GetUserAdminDetailsResponse>
      get copyWith => throw _privateConstructorUsedError;
}

GetMeetingChatsSuggestionsDataRequest
    _$GetMeetingChatsSuggestionsDataRequestFromJson(Map<String, dynamic> json) {
  return _GetMeetingChatsSuggestionsDataRequest.fromJson(json);
}

/// @nodoc
mixin _$GetMeetingChatsSuggestionsDataRequest {
  String get discussionPath => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $GetMeetingChatsSuggestionsDataRequestCopyWith<
          GetMeetingChatsSuggestionsDataRequest>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GetMeetingChatsSuggestionsDataRequestCopyWith<$Res> {
  factory $GetMeetingChatsSuggestionsDataRequestCopyWith(
          GetMeetingChatsSuggestionsDataRequest value,
          $Res Function(GetMeetingChatsSuggestionsDataRequest) then) =
      _$GetMeetingChatsSuggestionsDataRequestCopyWithImpl<$Res,
          GetMeetingChatsSuggestionsDataRequest>;
  @useResult
  $Res call({String discussionPath});
}

/// @nodoc
class _$GetMeetingChatsSuggestionsDataRequestCopyWithImpl<$Res,
        $Val extends GetMeetingChatsSuggestionsDataRequest>
    implements $GetMeetingChatsSuggestionsDataRequestCopyWith<$Res> {
  _$GetMeetingChatsSuggestionsDataRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? discussionPath = null,
  }) {
    return _then(_value.copyWith(
      discussionPath: null == discussionPath
          ? _value.discussionPath
          : discussionPath // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_GetMeetingChatsSuggestionsDataRequestCopyWith<$Res>
    implements $GetMeetingChatsSuggestionsDataRequestCopyWith<$Res> {
  factory _$$_GetMeetingChatsSuggestionsDataRequestCopyWith(
          _$_GetMeetingChatsSuggestionsDataRequest value,
          $Res Function(_$_GetMeetingChatsSuggestionsDataRequest) then) =
      __$$_GetMeetingChatsSuggestionsDataRequestCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String discussionPath});
}

/// @nodoc
class __$$_GetMeetingChatsSuggestionsDataRequestCopyWithImpl<$Res>
    extends _$GetMeetingChatsSuggestionsDataRequestCopyWithImpl<$Res,
        _$_GetMeetingChatsSuggestionsDataRequest>
    implements _$$_GetMeetingChatsSuggestionsDataRequestCopyWith<$Res> {
  __$$_GetMeetingChatsSuggestionsDataRequestCopyWithImpl(
      _$_GetMeetingChatsSuggestionsDataRequest _value,
      $Res Function(_$_GetMeetingChatsSuggestionsDataRequest) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? discussionPath = null,
  }) {
    return _then(_$_GetMeetingChatsSuggestionsDataRequest(
      discussionPath: null == discussionPath
          ? _value.discussionPath
          : discussionPath // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_GetMeetingChatsSuggestionsDataRequest
    implements _GetMeetingChatsSuggestionsDataRequest {
  _$_GetMeetingChatsSuggestionsDataRequest({required this.discussionPath});

  factory _$_GetMeetingChatsSuggestionsDataRequest.fromJson(
          Map<String, dynamic> json) =>
      _$$_GetMeetingChatsSuggestionsDataRequestFromJson(json);

  @override
  final String discussionPath;

  @override
  String toString() {
    return 'GetMeetingChatsSuggestionsDataRequest(discussionPath: $discussionPath)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_GetMeetingChatsSuggestionsDataRequest &&
            (identical(other.discussionPath, discussionPath) ||
                other.discussionPath == discussionPath));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, discussionPath);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_GetMeetingChatsSuggestionsDataRequestCopyWith<
          _$_GetMeetingChatsSuggestionsDataRequest>
      get copyWith => __$$_GetMeetingChatsSuggestionsDataRequestCopyWithImpl<
          _$_GetMeetingChatsSuggestionsDataRequest>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_GetMeetingChatsSuggestionsDataRequestToJson(
      this,
    );
  }
}

abstract class _GetMeetingChatsSuggestionsDataRequest
    implements GetMeetingChatsSuggestionsDataRequest {
  factory _GetMeetingChatsSuggestionsDataRequest(
          {required final String discussionPath}) =
      _$_GetMeetingChatsSuggestionsDataRequest;

  factory _GetMeetingChatsSuggestionsDataRequest.fromJson(
          Map<String, dynamic> json) =
      _$_GetMeetingChatsSuggestionsDataRequest.fromJson;

  @override
  String get discussionPath;
  @override
  @JsonKey(ignore: true)
  _$$_GetMeetingChatsSuggestionsDataRequestCopyWith<
          _$_GetMeetingChatsSuggestionsDataRequest>
      get copyWith => throw _privateConstructorUsedError;
}

GetMeetingChatsSuggestionsDataResponse
    _$GetMeetingChatsSuggestionsDataResponseFromJson(
        Map<String, dynamic> json) {
  return _GetMeetingChatsSuggestionsDataResponse.fromJson(json);
}

/// @nodoc
mixin _$GetMeetingChatsSuggestionsDataResponse {
  List<ChatSuggestionData>? get chatsSuggestionsList =>
      throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $GetMeetingChatsSuggestionsDataResponseCopyWith<
          GetMeetingChatsSuggestionsDataResponse>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GetMeetingChatsSuggestionsDataResponseCopyWith<$Res> {
  factory $GetMeetingChatsSuggestionsDataResponseCopyWith(
          GetMeetingChatsSuggestionsDataResponse value,
          $Res Function(GetMeetingChatsSuggestionsDataResponse) then) =
      _$GetMeetingChatsSuggestionsDataResponseCopyWithImpl<$Res,
          GetMeetingChatsSuggestionsDataResponse>;
  @useResult
  $Res call({List<ChatSuggestionData>? chatsSuggestionsList});
}

/// @nodoc
class _$GetMeetingChatsSuggestionsDataResponseCopyWithImpl<$Res,
        $Val extends GetMeetingChatsSuggestionsDataResponse>
    implements $GetMeetingChatsSuggestionsDataResponseCopyWith<$Res> {
  _$GetMeetingChatsSuggestionsDataResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? chatsSuggestionsList = freezed,
  }) {
    return _then(_value.copyWith(
      chatsSuggestionsList: freezed == chatsSuggestionsList
          ? _value.chatsSuggestionsList
          : chatsSuggestionsList // ignore: cast_nullable_to_non_nullable
              as List<ChatSuggestionData>?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_GetMeetingChatsSuggestionsDataResponseCopyWith<$Res>
    implements $GetMeetingChatsSuggestionsDataResponseCopyWith<$Res> {
  factory _$$_GetMeetingChatsSuggestionsDataResponseCopyWith(
          _$_GetMeetingChatsSuggestionsDataResponse value,
          $Res Function(_$_GetMeetingChatsSuggestionsDataResponse) then) =
      __$$_GetMeetingChatsSuggestionsDataResponseCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({List<ChatSuggestionData>? chatsSuggestionsList});
}

/// @nodoc
class __$$_GetMeetingChatsSuggestionsDataResponseCopyWithImpl<$Res>
    extends _$GetMeetingChatsSuggestionsDataResponseCopyWithImpl<$Res,
        _$_GetMeetingChatsSuggestionsDataResponse>
    implements _$$_GetMeetingChatsSuggestionsDataResponseCopyWith<$Res> {
  __$$_GetMeetingChatsSuggestionsDataResponseCopyWithImpl(
      _$_GetMeetingChatsSuggestionsDataResponse _value,
      $Res Function(_$_GetMeetingChatsSuggestionsDataResponse) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? chatsSuggestionsList = freezed,
  }) {
    return _then(_$_GetMeetingChatsSuggestionsDataResponse(
      chatsSuggestionsList: freezed == chatsSuggestionsList
          ? _value.chatsSuggestionsList
          : chatsSuggestionsList // ignore: cast_nullable_to_non_nullable
              as List<ChatSuggestionData>?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_GetMeetingChatsSuggestionsDataResponse
    implements _GetMeetingChatsSuggestionsDataResponse {
  _$_GetMeetingChatsSuggestionsDataResponse({this.chatsSuggestionsList});

  factory _$_GetMeetingChatsSuggestionsDataResponse.fromJson(
          Map<String, dynamic> json) =>
      _$$_GetMeetingChatsSuggestionsDataResponseFromJson(json);

  @override
  final List<ChatSuggestionData>? chatsSuggestionsList;

  @override
  String toString() {
    return 'GetMeetingChatsSuggestionsDataResponse(chatsSuggestionsList: $chatsSuggestionsList)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_GetMeetingChatsSuggestionsDataResponse &&
            const DeepCollectionEquality()
                .equals(other.chatsSuggestionsList, chatsSuggestionsList));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType, const DeepCollectionEquality().hash(chatsSuggestionsList));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_GetMeetingChatsSuggestionsDataResponseCopyWith<
          _$_GetMeetingChatsSuggestionsDataResponse>
      get copyWith => __$$_GetMeetingChatsSuggestionsDataResponseCopyWithImpl<
          _$_GetMeetingChatsSuggestionsDataResponse>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_GetMeetingChatsSuggestionsDataResponseToJson(
      this,
    );
  }
}

abstract class _GetMeetingChatsSuggestionsDataResponse
    implements GetMeetingChatsSuggestionsDataResponse {
  factory _GetMeetingChatsSuggestionsDataResponse(
          {final List<ChatSuggestionData>? chatsSuggestionsList}) =
      _$_GetMeetingChatsSuggestionsDataResponse;

  factory _GetMeetingChatsSuggestionsDataResponse.fromJson(
          Map<String, dynamic> json) =
      _$_GetMeetingChatsSuggestionsDataResponse.fromJson;

  @override
  List<ChatSuggestionData>? get chatsSuggestionsList;
  @override
  @JsonKey(ignore: true)
  _$$_GetMeetingChatsSuggestionsDataResponseCopyWith<
          _$_GetMeetingChatsSuggestionsDataResponse>
      get copyWith => throw _privateConstructorUsedError;
}

GetMembersDataRequest _$GetMembersDataRequestFromJson(
    Map<String, dynamic> json) {
  return _GetMembersDataRequest.fromJson(json);
}

/// @nodoc
mixin _$GetMembersDataRequest {
  String get juntoId => throw _privateConstructorUsedError;
  List<String> get userIds => throw _privateConstructorUsedError;
  String? get discussionPath => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $GetMembersDataRequestCopyWith<GetMembersDataRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GetMembersDataRequestCopyWith<$Res> {
  factory $GetMembersDataRequestCopyWith(GetMembersDataRequest value,
          $Res Function(GetMembersDataRequest) then) =
      _$GetMembersDataRequestCopyWithImpl<$Res, GetMembersDataRequest>;
  @useResult
  $Res call({String juntoId, List<String> userIds, String? discussionPath});
}

/// @nodoc
class _$GetMembersDataRequestCopyWithImpl<$Res,
        $Val extends GetMembersDataRequest>
    implements $GetMembersDataRequestCopyWith<$Res> {
  _$GetMembersDataRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? juntoId = null,
    Object? userIds = null,
    Object? discussionPath = freezed,
  }) {
    return _then(_value.copyWith(
      juntoId: null == juntoId
          ? _value.juntoId
          : juntoId // ignore: cast_nullable_to_non_nullable
              as String,
      userIds: null == userIds
          ? _value.userIds
          : userIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
      discussionPath: freezed == discussionPath
          ? _value.discussionPath
          : discussionPath // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_GetMembersDataRequestCopyWith<$Res>
    implements $GetMembersDataRequestCopyWith<$Res> {
  factory _$$_GetMembersDataRequestCopyWith(_$_GetMembersDataRequest value,
          $Res Function(_$_GetMembersDataRequest) then) =
      __$$_GetMembersDataRequestCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String juntoId, List<String> userIds, String? discussionPath});
}

/// @nodoc
class __$$_GetMembersDataRequestCopyWithImpl<$Res>
    extends _$GetMembersDataRequestCopyWithImpl<$Res, _$_GetMembersDataRequest>
    implements _$$_GetMembersDataRequestCopyWith<$Res> {
  __$$_GetMembersDataRequestCopyWithImpl(_$_GetMembersDataRequest _value,
      $Res Function(_$_GetMembersDataRequest) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? juntoId = null,
    Object? userIds = null,
    Object? discussionPath = freezed,
  }) {
    return _then(_$_GetMembersDataRequest(
      juntoId: null == juntoId
          ? _value.juntoId
          : juntoId // ignore: cast_nullable_to_non_nullable
              as String,
      userIds: null == userIds
          ? _value.userIds
          : userIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
      discussionPath: freezed == discussionPath
          ? _value.discussionPath
          : discussionPath // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_GetMembersDataRequest implements _GetMembersDataRequest {
  _$_GetMembersDataRequest(
      {required this.juntoId, required this.userIds, this.discussionPath});

  factory _$_GetMembersDataRequest.fromJson(Map<String, dynamic> json) =>
      _$$_GetMembersDataRequestFromJson(json);

  @override
  final String juntoId;
  @override
  final List<String> userIds;
  @override
  final String? discussionPath;

  @override
  String toString() {
    return 'GetMembersDataRequest(juntoId: $juntoId, userIds: $userIds, discussionPath: $discussionPath)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_GetMembersDataRequest &&
            (identical(other.juntoId, juntoId) || other.juntoId == juntoId) &&
            const DeepCollectionEquality().equals(other.userIds, userIds) &&
            (identical(other.discussionPath, discussionPath) ||
                other.discussionPath == discussionPath));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, juntoId,
      const DeepCollectionEquality().hash(userIds), discussionPath);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_GetMembersDataRequestCopyWith<_$_GetMembersDataRequest> get copyWith =>
      __$$_GetMembersDataRequestCopyWithImpl<_$_GetMembersDataRequest>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_GetMembersDataRequestToJson(
      this,
    );
  }
}

abstract class _GetMembersDataRequest implements GetMembersDataRequest {
  factory _GetMembersDataRequest(
      {required final String juntoId,
      required final List<String> userIds,
      final String? discussionPath}) = _$_GetMembersDataRequest;

  factory _GetMembersDataRequest.fromJson(Map<String, dynamic> json) =
      _$_GetMembersDataRequest.fromJson;

  @override
  String get juntoId;
  @override
  List<String> get userIds;
  @override
  String? get discussionPath;
  @override
  @JsonKey(ignore: true)
  _$$_GetMembersDataRequestCopyWith<_$_GetMembersDataRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

GetMembersDataResponse _$GetMembersDataResponseFromJson(
    Map<String, dynamic> json) {
  return _GetMembersDataResponse.fromJson(json);
}

/// @nodoc
mixin _$GetMembersDataResponse {
  List<MemberDetails>? get membersDetailsList =>
      throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $GetMembersDataResponseCopyWith<GetMembersDataResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GetMembersDataResponseCopyWith<$Res> {
  factory $GetMembersDataResponseCopyWith(GetMembersDataResponse value,
          $Res Function(GetMembersDataResponse) then) =
      _$GetMembersDataResponseCopyWithImpl<$Res, GetMembersDataResponse>;
  @useResult
  $Res call({List<MemberDetails>? membersDetailsList});
}

/// @nodoc
class _$GetMembersDataResponseCopyWithImpl<$Res,
        $Val extends GetMembersDataResponse>
    implements $GetMembersDataResponseCopyWith<$Res> {
  _$GetMembersDataResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? membersDetailsList = freezed,
  }) {
    return _then(_value.copyWith(
      membersDetailsList: freezed == membersDetailsList
          ? _value.membersDetailsList
          : membersDetailsList // ignore: cast_nullable_to_non_nullable
              as List<MemberDetails>?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_GetMembersDataResponseCopyWith<$Res>
    implements $GetMembersDataResponseCopyWith<$Res> {
  factory _$$_GetMembersDataResponseCopyWith(_$_GetMembersDataResponse value,
          $Res Function(_$_GetMembersDataResponse) then) =
      __$$_GetMembersDataResponseCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({List<MemberDetails>? membersDetailsList});
}

/// @nodoc
class __$$_GetMembersDataResponseCopyWithImpl<$Res>
    extends _$GetMembersDataResponseCopyWithImpl<$Res,
        _$_GetMembersDataResponse>
    implements _$$_GetMembersDataResponseCopyWith<$Res> {
  __$$_GetMembersDataResponseCopyWithImpl(_$_GetMembersDataResponse _value,
      $Res Function(_$_GetMembersDataResponse) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? membersDetailsList = freezed,
  }) {
    return _then(_$_GetMembersDataResponse(
      membersDetailsList: freezed == membersDetailsList
          ? _value.membersDetailsList
          : membersDetailsList // ignore: cast_nullable_to_non_nullable
              as List<MemberDetails>?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_GetMembersDataResponse implements _GetMembersDataResponse {
  _$_GetMembersDataResponse({this.membersDetailsList});

  factory _$_GetMembersDataResponse.fromJson(Map<String, dynamic> json) =>
      _$$_GetMembersDataResponseFromJson(json);

  @override
  final List<MemberDetails>? membersDetailsList;

  @override
  String toString() {
    return 'GetMembersDataResponse(membersDetailsList: $membersDetailsList)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_GetMembersDataResponse &&
            const DeepCollectionEquality()
                .equals(other.membersDetailsList, membersDetailsList));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType, const DeepCollectionEquality().hash(membersDetailsList));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_GetMembersDataResponseCopyWith<_$_GetMembersDataResponse> get copyWith =>
      __$$_GetMembersDataResponseCopyWithImpl<_$_GetMembersDataResponse>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_GetMembersDataResponseToJson(
      this,
    );
  }
}

abstract class _GetMembersDataResponse implements GetMembersDataResponse {
  factory _GetMembersDataResponse(
          {final List<MemberDetails>? membersDetailsList}) =
      _$_GetMembersDataResponse;

  factory _GetMembersDataResponse.fromJson(Map<String, dynamic> json) =
      _$_GetMembersDataResponse.fromJson;

  @override
  List<MemberDetails>? get membersDetailsList;
  @override
  @JsonKey(ignore: true)
  _$$_GetMembersDataResponseCopyWith<_$_GetMembersDataResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

UserAdminDetails _$UserAdminDetailsFromJson(Map<String, dynamic> json) {
  return _UserAdminDetails.fromJson(json);
}

/// @nodoc
mixin _$UserAdminDetails {
  String? get userId => throw _privateConstructorUsedError;
  String? get email => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $UserAdminDetailsCopyWith<UserAdminDetails> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserAdminDetailsCopyWith<$Res> {
  factory $UserAdminDetailsCopyWith(
          UserAdminDetails value, $Res Function(UserAdminDetails) then) =
      _$UserAdminDetailsCopyWithImpl<$Res, UserAdminDetails>;
  @useResult
  $Res call({String? userId, String? email});
}

/// @nodoc
class _$UserAdminDetailsCopyWithImpl<$Res, $Val extends UserAdminDetails>
    implements $UserAdminDetailsCopyWith<$Res> {
  _$UserAdminDetailsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = freezed,
    Object? email = freezed,
  }) {
    return _then(_value.copyWith(
      userId: freezed == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String?,
      email: freezed == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_UserAdminDetailsCopyWith<$Res>
    implements $UserAdminDetailsCopyWith<$Res> {
  factory _$$_UserAdminDetailsCopyWith(
          _$_UserAdminDetails value, $Res Function(_$_UserAdminDetails) then) =
      __$$_UserAdminDetailsCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String? userId, String? email});
}

/// @nodoc
class __$$_UserAdminDetailsCopyWithImpl<$Res>
    extends _$UserAdminDetailsCopyWithImpl<$Res, _$_UserAdminDetails>
    implements _$$_UserAdminDetailsCopyWith<$Res> {
  __$$_UserAdminDetailsCopyWithImpl(
      _$_UserAdminDetails _value, $Res Function(_$_UserAdminDetails) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = freezed,
    Object? email = freezed,
  }) {
    return _then(_$_UserAdminDetails(
      userId: freezed == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String?,
      email: freezed == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_UserAdminDetails implements _UserAdminDetails {
  _$_UserAdminDetails({this.userId, this.email});

  factory _$_UserAdminDetails.fromJson(Map<String, dynamic> json) =>
      _$$_UserAdminDetailsFromJson(json);

  @override
  final String? userId;
  @override
  final String? email;

  @override
  String toString() {
    return 'UserAdminDetails(userId: $userId, email: $email)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_UserAdminDetails &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.email, email) || other.email == email));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, userId, email);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_UserAdminDetailsCopyWith<_$_UserAdminDetails> get copyWith =>
      __$$_UserAdminDetailsCopyWithImpl<_$_UserAdminDetails>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_UserAdminDetailsToJson(
      this,
    );
  }
}

abstract class _UserAdminDetails implements UserAdminDetails {
  factory _UserAdminDetails({final String? userId, final String? email}) =
      _$_UserAdminDetails;

  factory _UserAdminDetails.fromJson(Map<String, dynamic> json) =
      _$_UserAdminDetails.fromJson;

  @override
  String? get userId;
  @override
  String? get email;
  @override
  @JsonKey(ignore: true)
  _$$_UserAdminDetailsCopyWith<_$_UserAdminDetails> get copyWith =>
      throw _privateConstructorUsedError;
}

CreateLiveStreamRequest _$CreateLiveStreamRequestFromJson(
    Map<String, dynamic> json) {
  return _CreateLiveStreamRequest.fromJson(json);
}

/// @nodoc
mixin _$CreateLiveStreamRequest {
  String get juntoId => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $CreateLiveStreamRequestCopyWith<CreateLiveStreamRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CreateLiveStreamRequestCopyWith<$Res> {
  factory $CreateLiveStreamRequestCopyWith(CreateLiveStreamRequest value,
          $Res Function(CreateLiveStreamRequest) then) =
      _$CreateLiveStreamRequestCopyWithImpl<$Res, CreateLiveStreamRequest>;
  @useResult
  $Res call({String juntoId});
}

/// @nodoc
class _$CreateLiveStreamRequestCopyWithImpl<$Res,
        $Val extends CreateLiveStreamRequest>
    implements $CreateLiveStreamRequestCopyWith<$Res> {
  _$CreateLiveStreamRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? juntoId = null,
  }) {
    return _then(_value.copyWith(
      juntoId: null == juntoId
          ? _value.juntoId
          : juntoId // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_CreateLiveStreamRequestCopyWith<$Res>
    implements $CreateLiveStreamRequestCopyWith<$Res> {
  factory _$$_CreateLiveStreamRequestCopyWith(_$_CreateLiveStreamRequest value,
          $Res Function(_$_CreateLiveStreamRequest) then) =
      __$$_CreateLiveStreamRequestCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String juntoId});
}

/// @nodoc
class __$$_CreateLiveStreamRequestCopyWithImpl<$Res>
    extends _$CreateLiveStreamRequestCopyWithImpl<$Res,
        _$_CreateLiveStreamRequest>
    implements _$$_CreateLiveStreamRequestCopyWith<$Res> {
  __$$_CreateLiveStreamRequestCopyWithImpl(_$_CreateLiveStreamRequest _value,
      $Res Function(_$_CreateLiveStreamRequest) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? juntoId = null,
  }) {
    return _then(_$_CreateLiveStreamRequest(
      juntoId: null == juntoId
          ? _value.juntoId
          : juntoId // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_CreateLiveStreamRequest implements _CreateLiveStreamRequest {
  _$_CreateLiveStreamRequest({required this.juntoId});

  factory _$_CreateLiveStreamRequest.fromJson(Map<String, dynamic> json) =>
      _$$_CreateLiveStreamRequestFromJson(json);

  @override
  final String juntoId;

  @override
  String toString() {
    return 'CreateLiveStreamRequest(juntoId: $juntoId)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_CreateLiveStreamRequest &&
            (identical(other.juntoId, juntoId) || other.juntoId == juntoId));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, juntoId);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_CreateLiveStreamRequestCopyWith<_$_CreateLiveStreamRequest>
      get copyWith =>
          __$$_CreateLiveStreamRequestCopyWithImpl<_$_CreateLiveStreamRequest>(
              this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_CreateLiveStreamRequestToJson(
      this,
    );
  }
}

abstract class _CreateLiveStreamRequest implements CreateLiveStreamRequest {
  factory _CreateLiveStreamRequest({required final String juntoId}) =
      _$_CreateLiveStreamRequest;

  factory _CreateLiveStreamRequest.fromJson(Map<String, dynamic> json) =
      _$_CreateLiveStreamRequest.fromJson;

  @override
  String get juntoId;
  @override
  @JsonKey(ignore: true)
  _$$_CreateLiveStreamRequestCopyWith<_$_CreateLiveStreamRequest>
      get copyWith => throw _privateConstructorUsedError;
}

CreateLiveStreamResponse _$CreateLiveStreamResponseFromJson(
    Map<String, dynamic> json) {
  return _CreateLiveStreamResponse.fromJson(json);
}

/// @nodoc
mixin _$CreateLiveStreamResponse {
  String get muxId => throw _privateConstructorUsedError;
  String get muxPlaybackId => throw _privateConstructorUsedError;
  String get streamServerUrl => throw _privateConstructorUsedError;
  String get streamKey => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $CreateLiveStreamResponseCopyWith<CreateLiveStreamResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CreateLiveStreamResponseCopyWith<$Res> {
  factory $CreateLiveStreamResponseCopyWith(CreateLiveStreamResponse value,
          $Res Function(CreateLiveStreamResponse) then) =
      _$CreateLiveStreamResponseCopyWithImpl<$Res, CreateLiveStreamResponse>;
  @useResult
  $Res call(
      {String muxId,
      String muxPlaybackId,
      String streamServerUrl,
      String streamKey});
}

/// @nodoc
class _$CreateLiveStreamResponseCopyWithImpl<$Res,
        $Val extends CreateLiveStreamResponse>
    implements $CreateLiveStreamResponseCopyWith<$Res> {
  _$CreateLiveStreamResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? muxId = null,
    Object? muxPlaybackId = null,
    Object? streamServerUrl = null,
    Object? streamKey = null,
  }) {
    return _then(_value.copyWith(
      muxId: null == muxId
          ? _value.muxId
          : muxId // ignore: cast_nullable_to_non_nullable
              as String,
      muxPlaybackId: null == muxPlaybackId
          ? _value.muxPlaybackId
          : muxPlaybackId // ignore: cast_nullable_to_non_nullable
              as String,
      streamServerUrl: null == streamServerUrl
          ? _value.streamServerUrl
          : streamServerUrl // ignore: cast_nullable_to_non_nullable
              as String,
      streamKey: null == streamKey
          ? _value.streamKey
          : streamKey // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_CreateLiveStreamResponseCopyWith<$Res>
    implements $CreateLiveStreamResponseCopyWith<$Res> {
  factory _$$_CreateLiveStreamResponseCopyWith(
          _$_CreateLiveStreamResponse value,
          $Res Function(_$_CreateLiveStreamResponse) then) =
      __$$_CreateLiveStreamResponseCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String muxId,
      String muxPlaybackId,
      String streamServerUrl,
      String streamKey});
}

/// @nodoc
class __$$_CreateLiveStreamResponseCopyWithImpl<$Res>
    extends _$CreateLiveStreamResponseCopyWithImpl<$Res,
        _$_CreateLiveStreamResponse>
    implements _$$_CreateLiveStreamResponseCopyWith<$Res> {
  __$$_CreateLiveStreamResponseCopyWithImpl(_$_CreateLiveStreamResponse _value,
      $Res Function(_$_CreateLiveStreamResponse) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? muxId = null,
    Object? muxPlaybackId = null,
    Object? streamServerUrl = null,
    Object? streamKey = null,
  }) {
    return _then(_$_CreateLiveStreamResponse(
      muxId: null == muxId
          ? _value.muxId
          : muxId // ignore: cast_nullable_to_non_nullable
              as String,
      muxPlaybackId: null == muxPlaybackId
          ? _value.muxPlaybackId
          : muxPlaybackId // ignore: cast_nullable_to_non_nullable
              as String,
      streamServerUrl: null == streamServerUrl
          ? _value.streamServerUrl
          : streamServerUrl // ignore: cast_nullable_to_non_nullable
              as String,
      streamKey: null == streamKey
          ? _value.streamKey
          : streamKey // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_CreateLiveStreamResponse implements _CreateLiveStreamResponse {
  _$_CreateLiveStreamResponse(
      {required this.muxId,
      required this.muxPlaybackId,
      required this.streamServerUrl,
      required this.streamKey});

  factory _$_CreateLiveStreamResponse.fromJson(Map<String, dynamic> json) =>
      _$$_CreateLiveStreamResponseFromJson(json);

  @override
  final String muxId;
  @override
  final String muxPlaybackId;
  @override
  final String streamServerUrl;
  @override
  final String streamKey;

  @override
  String toString() {
    return 'CreateLiveStreamResponse(muxId: $muxId, muxPlaybackId: $muxPlaybackId, streamServerUrl: $streamServerUrl, streamKey: $streamKey)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_CreateLiveStreamResponse &&
            (identical(other.muxId, muxId) || other.muxId == muxId) &&
            (identical(other.muxPlaybackId, muxPlaybackId) ||
                other.muxPlaybackId == muxPlaybackId) &&
            (identical(other.streamServerUrl, streamServerUrl) ||
                other.streamServerUrl == streamServerUrl) &&
            (identical(other.streamKey, streamKey) ||
                other.streamKey == streamKey));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType, muxId, muxPlaybackId, streamServerUrl, streamKey);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_CreateLiveStreamResponseCopyWith<_$_CreateLiveStreamResponse>
      get copyWith => __$$_CreateLiveStreamResponseCopyWithImpl<
          _$_CreateLiveStreamResponse>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_CreateLiveStreamResponseToJson(
      this,
    );
  }
}

abstract class _CreateLiveStreamResponse implements CreateLiveStreamResponse {
  factory _CreateLiveStreamResponse(
      {required final String muxId,
      required final String muxPlaybackId,
      required final String streamServerUrl,
      required final String streamKey}) = _$_CreateLiveStreamResponse;

  factory _CreateLiveStreamResponse.fromJson(Map<String, dynamic> json) =
      _$_CreateLiveStreamResponse.fromJson;

  @override
  String get muxId;
  @override
  String get muxPlaybackId;
  @override
  String get streamServerUrl;
  @override
  String get streamKey;
  @override
  @JsonKey(ignore: true)
  _$$_CreateLiveStreamResponseCopyWith<_$_CreateLiveStreamResponse>
      get copyWith => throw _privateConstructorUsedError;
}

GetBreakoutRoomJoinInfoRequest _$GetBreakoutRoomJoinInfoRequestFromJson(
    Map<String, dynamic> json) {
  return _GetBreakoutRoomJoinInfoRequest.fromJson(json);
}

/// @nodoc
mixin _$GetBreakoutRoomJoinInfoRequest {
  String get discussionId => throw _privateConstructorUsedError;
  String get discussionPath => throw _privateConstructorUsedError;
  String get breakoutRoomId => throw _privateConstructorUsedError;
  bool get enableAudio => throw _privateConstructorUsedError;
  bool get enableVideo => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $GetBreakoutRoomJoinInfoRequestCopyWith<GetBreakoutRoomJoinInfoRequest>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GetBreakoutRoomJoinInfoRequestCopyWith<$Res> {
  factory $GetBreakoutRoomJoinInfoRequestCopyWith(
          GetBreakoutRoomJoinInfoRequest value,
          $Res Function(GetBreakoutRoomJoinInfoRequest) then) =
      _$GetBreakoutRoomJoinInfoRequestCopyWithImpl<$Res,
          GetBreakoutRoomJoinInfoRequest>;
  @useResult
  $Res call(
      {String discussionId,
      String discussionPath,
      String breakoutRoomId,
      bool enableAudio,
      bool enableVideo});
}

/// @nodoc
class _$GetBreakoutRoomJoinInfoRequestCopyWithImpl<$Res,
        $Val extends GetBreakoutRoomJoinInfoRequest>
    implements $GetBreakoutRoomJoinInfoRequestCopyWith<$Res> {
  _$GetBreakoutRoomJoinInfoRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? discussionId = null,
    Object? discussionPath = null,
    Object? breakoutRoomId = null,
    Object? enableAudio = null,
    Object? enableVideo = null,
  }) {
    return _then(_value.copyWith(
      discussionId: null == discussionId
          ? _value.discussionId
          : discussionId // ignore: cast_nullable_to_non_nullable
              as String,
      discussionPath: null == discussionPath
          ? _value.discussionPath
          : discussionPath // ignore: cast_nullable_to_non_nullable
              as String,
      breakoutRoomId: null == breakoutRoomId
          ? _value.breakoutRoomId
          : breakoutRoomId // ignore: cast_nullable_to_non_nullable
              as String,
      enableAudio: null == enableAudio
          ? _value.enableAudio
          : enableAudio // ignore: cast_nullable_to_non_nullable
              as bool,
      enableVideo: null == enableVideo
          ? _value.enableVideo
          : enableVideo // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_GetBreakoutRoomJoinInfoRequestCopyWith<$Res>
    implements $GetBreakoutRoomJoinInfoRequestCopyWith<$Res> {
  factory _$$_GetBreakoutRoomJoinInfoRequestCopyWith(
          _$_GetBreakoutRoomJoinInfoRequest value,
          $Res Function(_$_GetBreakoutRoomJoinInfoRequest) then) =
      __$$_GetBreakoutRoomJoinInfoRequestCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String discussionId,
      String discussionPath,
      String breakoutRoomId,
      bool enableAudio,
      bool enableVideo});
}

/// @nodoc
class __$$_GetBreakoutRoomJoinInfoRequestCopyWithImpl<$Res>
    extends _$GetBreakoutRoomJoinInfoRequestCopyWithImpl<$Res,
        _$_GetBreakoutRoomJoinInfoRequest>
    implements _$$_GetBreakoutRoomJoinInfoRequestCopyWith<$Res> {
  __$$_GetBreakoutRoomJoinInfoRequestCopyWithImpl(
      _$_GetBreakoutRoomJoinInfoRequest _value,
      $Res Function(_$_GetBreakoutRoomJoinInfoRequest) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? discussionId = null,
    Object? discussionPath = null,
    Object? breakoutRoomId = null,
    Object? enableAudio = null,
    Object? enableVideo = null,
  }) {
    return _then(_$_GetBreakoutRoomJoinInfoRequest(
      discussionId: null == discussionId
          ? _value.discussionId
          : discussionId // ignore: cast_nullable_to_non_nullable
              as String,
      discussionPath: null == discussionPath
          ? _value.discussionPath
          : discussionPath // ignore: cast_nullable_to_non_nullable
              as String,
      breakoutRoomId: null == breakoutRoomId
          ? _value.breakoutRoomId
          : breakoutRoomId // ignore: cast_nullable_to_non_nullable
              as String,
      enableAudio: null == enableAudio
          ? _value.enableAudio
          : enableAudio // ignore: cast_nullable_to_non_nullable
              as bool,
      enableVideo: null == enableVideo
          ? _value.enableVideo
          : enableVideo // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_GetBreakoutRoomJoinInfoRequest
    implements _GetBreakoutRoomJoinInfoRequest {
  _$_GetBreakoutRoomJoinInfoRequest(
      {required this.discussionId,
      required this.discussionPath,
      required this.breakoutRoomId,
      required this.enableAudio,
      required this.enableVideo});

  factory _$_GetBreakoutRoomJoinInfoRequest.fromJson(
          Map<String, dynamic> json) =>
      _$$_GetBreakoutRoomJoinInfoRequestFromJson(json);

  @override
  final String discussionId;
  @override
  final String discussionPath;
  @override
  final String breakoutRoomId;
  @override
  final bool enableAudio;
  @override
  final bool enableVideo;

  @override
  String toString() {
    return 'GetBreakoutRoomJoinInfoRequest(discussionId: $discussionId, discussionPath: $discussionPath, breakoutRoomId: $breakoutRoomId, enableAudio: $enableAudio, enableVideo: $enableVideo)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_GetBreakoutRoomJoinInfoRequest &&
            (identical(other.discussionId, discussionId) ||
                other.discussionId == discussionId) &&
            (identical(other.discussionPath, discussionPath) ||
                other.discussionPath == discussionPath) &&
            (identical(other.breakoutRoomId, breakoutRoomId) ||
                other.breakoutRoomId == breakoutRoomId) &&
            (identical(other.enableAudio, enableAudio) ||
                other.enableAudio == enableAudio) &&
            (identical(other.enableVideo, enableVideo) ||
                other.enableVideo == enableVideo));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, discussionId, discussionPath,
      breakoutRoomId, enableAudio, enableVideo);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_GetBreakoutRoomJoinInfoRequestCopyWith<_$_GetBreakoutRoomJoinInfoRequest>
      get copyWith => __$$_GetBreakoutRoomJoinInfoRequestCopyWithImpl<
          _$_GetBreakoutRoomJoinInfoRequest>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_GetBreakoutRoomJoinInfoRequestToJson(
      this,
    );
  }
}

abstract class _GetBreakoutRoomJoinInfoRequest
    implements GetBreakoutRoomJoinInfoRequest {
  factory _GetBreakoutRoomJoinInfoRequest(
      {required final String discussionId,
      required final String discussionPath,
      required final String breakoutRoomId,
      required final bool enableAudio,
      required final bool enableVideo}) = _$_GetBreakoutRoomJoinInfoRequest;

  factory _GetBreakoutRoomJoinInfoRequest.fromJson(Map<String, dynamic> json) =
      _$_GetBreakoutRoomJoinInfoRequest.fromJson;

  @override
  String get discussionId;
  @override
  String get discussionPath;
  @override
  String get breakoutRoomId;
  @override
  bool get enableAudio;
  @override
  bool get enableVideo;
  @override
  @JsonKey(ignore: true)
  _$$_GetBreakoutRoomJoinInfoRequestCopyWith<_$_GetBreakoutRoomJoinInfoRequest>
      get copyWith => throw _privateConstructorUsedError;
}

GetBreakoutRoomAssignmentRequest _$GetBreakoutRoomAssignmentRequestFromJson(
    Map<String, dynamic> json) {
  return _GetBreakoutRoomAssignmentRequest.fromJson(json);
}

/// @nodoc
mixin _$GetBreakoutRoomAssignmentRequest {
  String get discussionId => throw _privateConstructorUsedError;
  String get discussionPath => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $GetBreakoutRoomAssignmentRequestCopyWith<GetBreakoutRoomAssignmentRequest>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GetBreakoutRoomAssignmentRequestCopyWith<$Res> {
  factory $GetBreakoutRoomAssignmentRequestCopyWith(
          GetBreakoutRoomAssignmentRequest value,
          $Res Function(GetBreakoutRoomAssignmentRequest) then) =
      _$GetBreakoutRoomAssignmentRequestCopyWithImpl<$Res,
          GetBreakoutRoomAssignmentRequest>;
  @useResult
  $Res call({String discussionId, String discussionPath});
}

/// @nodoc
class _$GetBreakoutRoomAssignmentRequestCopyWithImpl<$Res,
        $Val extends GetBreakoutRoomAssignmentRequest>
    implements $GetBreakoutRoomAssignmentRequestCopyWith<$Res> {
  _$GetBreakoutRoomAssignmentRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? discussionId = null,
    Object? discussionPath = null,
  }) {
    return _then(_value.copyWith(
      discussionId: null == discussionId
          ? _value.discussionId
          : discussionId // ignore: cast_nullable_to_non_nullable
              as String,
      discussionPath: null == discussionPath
          ? _value.discussionPath
          : discussionPath // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_GetBreakoutRoomAssignmentRequestCopyWith<$Res>
    implements $GetBreakoutRoomAssignmentRequestCopyWith<$Res> {
  factory _$$_GetBreakoutRoomAssignmentRequestCopyWith(
          _$_GetBreakoutRoomAssignmentRequest value,
          $Res Function(_$_GetBreakoutRoomAssignmentRequest) then) =
      __$$_GetBreakoutRoomAssignmentRequestCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String discussionId, String discussionPath});
}

/// @nodoc
class __$$_GetBreakoutRoomAssignmentRequestCopyWithImpl<$Res>
    extends _$GetBreakoutRoomAssignmentRequestCopyWithImpl<$Res,
        _$_GetBreakoutRoomAssignmentRequest>
    implements _$$_GetBreakoutRoomAssignmentRequestCopyWith<$Res> {
  __$$_GetBreakoutRoomAssignmentRequestCopyWithImpl(
      _$_GetBreakoutRoomAssignmentRequest _value,
      $Res Function(_$_GetBreakoutRoomAssignmentRequest) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? discussionId = null,
    Object? discussionPath = null,
  }) {
    return _then(_$_GetBreakoutRoomAssignmentRequest(
      discussionId: null == discussionId
          ? _value.discussionId
          : discussionId // ignore: cast_nullable_to_non_nullable
              as String,
      discussionPath: null == discussionPath
          ? _value.discussionPath
          : discussionPath // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_GetBreakoutRoomAssignmentRequest
    implements _GetBreakoutRoomAssignmentRequest {
  _$_GetBreakoutRoomAssignmentRequest(
      {required this.discussionId, required this.discussionPath});

  factory _$_GetBreakoutRoomAssignmentRequest.fromJson(
          Map<String, dynamic> json) =>
      _$$_GetBreakoutRoomAssignmentRequestFromJson(json);

  @override
  final String discussionId;
  @override
  final String discussionPath;

  @override
  String toString() {
    return 'GetBreakoutRoomAssignmentRequest(discussionId: $discussionId, discussionPath: $discussionPath)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_GetBreakoutRoomAssignmentRequest &&
            (identical(other.discussionId, discussionId) ||
                other.discussionId == discussionId) &&
            (identical(other.discussionPath, discussionPath) ||
                other.discussionPath == discussionPath));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, discussionId, discussionPath);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_GetBreakoutRoomAssignmentRequestCopyWith<
          _$_GetBreakoutRoomAssignmentRequest>
      get copyWith => __$$_GetBreakoutRoomAssignmentRequestCopyWithImpl<
          _$_GetBreakoutRoomAssignmentRequest>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_GetBreakoutRoomAssignmentRequestToJson(
      this,
    );
  }
}

abstract class _GetBreakoutRoomAssignmentRequest
    implements GetBreakoutRoomAssignmentRequest {
  factory _GetBreakoutRoomAssignmentRequest(
          {required final String discussionId,
          required final String discussionPath}) =
      _$_GetBreakoutRoomAssignmentRequest;

  factory _GetBreakoutRoomAssignmentRequest.fromJson(
      Map<String, dynamic> json) = _$_GetBreakoutRoomAssignmentRequest.fromJson;

  @override
  String get discussionId;
  @override
  String get discussionPath;
  @override
  @JsonKey(ignore: true)
  _$$_GetBreakoutRoomAssignmentRequestCopyWith<
          _$_GetBreakoutRoomAssignmentRequest>
      get copyWith => throw _privateConstructorUsedError;
}

GetBreakoutRoomAssignmentResponse _$GetBreakoutRoomAssignmentResponseFromJson(
    Map<String, dynamic> json) {
  return _GetBreakoutRoomAssignmentResponse.fromJson(json);
}

/// @nodoc
mixin _$GetBreakoutRoomAssignmentResponse {
  String? get roomId => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $GetBreakoutRoomAssignmentResponseCopyWith<GetBreakoutRoomAssignmentResponse>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GetBreakoutRoomAssignmentResponseCopyWith<$Res> {
  factory $GetBreakoutRoomAssignmentResponseCopyWith(
          GetBreakoutRoomAssignmentResponse value,
          $Res Function(GetBreakoutRoomAssignmentResponse) then) =
      _$GetBreakoutRoomAssignmentResponseCopyWithImpl<$Res,
          GetBreakoutRoomAssignmentResponse>;
  @useResult
  $Res call({String? roomId});
}

/// @nodoc
class _$GetBreakoutRoomAssignmentResponseCopyWithImpl<$Res,
        $Val extends GetBreakoutRoomAssignmentResponse>
    implements $GetBreakoutRoomAssignmentResponseCopyWith<$Res> {
  _$GetBreakoutRoomAssignmentResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? roomId = freezed,
  }) {
    return _then(_value.copyWith(
      roomId: freezed == roomId
          ? _value.roomId
          : roomId // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_GetBreakoutRoomAssignmentResponseCopyWith<$Res>
    implements $GetBreakoutRoomAssignmentResponseCopyWith<$Res> {
  factory _$$_GetBreakoutRoomAssignmentResponseCopyWith(
          _$_GetBreakoutRoomAssignmentResponse value,
          $Res Function(_$_GetBreakoutRoomAssignmentResponse) then) =
      __$$_GetBreakoutRoomAssignmentResponseCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String? roomId});
}

/// @nodoc
class __$$_GetBreakoutRoomAssignmentResponseCopyWithImpl<$Res>
    extends _$GetBreakoutRoomAssignmentResponseCopyWithImpl<$Res,
        _$_GetBreakoutRoomAssignmentResponse>
    implements _$$_GetBreakoutRoomAssignmentResponseCopyWith<$Res> {
  __$$_GetBreakoutRoomAssignmentResponseCopyWithImpl(
      _$_GetBreakoutRoomAssignmentResponse _value,
      $Res Function(_$_GetBreakoutRoomAssignmentResponse) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? roomId = freezed,
  }) {
    return _then(_$_GetBreakoutRoomAssignmentResponse(
      roomId: freezed == roomId
          ? _value.roomId
          : roomId // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_GetBreakoutRoomAssignmentResponse
    implements _GetBreakoutRoomAssignmentResponse {
  _$_GetBreakoutRoomAssignmentResponse({required this.roomId});

  factory _$_GetBreakoutRoomAssignmentResponse.fromJson(
          Map<String, dynamic> json) =>
      _$$_GetBreakoutRoomAssignmentResponseFromJson(json);

  @override
  final String? roomId;

  @override
  String toString() {
    return 'GetBreakoutRoomAssignmentResponse(roomId: $roomId)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_GetBreakoutRoomAssignmentResponse &&
            (identical(other.roomId, roomId) || other.roomId == roomId));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, roomId);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_GetBreakoutRoomAssignmentResponseCopyWith<
          _$_GetBreakoutRoomAssignmentResponse>
      get copyWith => __$$_GetBreakoutRoomAssignmentResponseCopyWithImpl<
          _$_GetBreakoutRoomAssignmentResponse>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_GetBreakoutRoomAssignmentResponseToJson(
      this,
    );
  }
}

abstract class _GetBreakoutRoomAssignmentResponse
    implements GetBreakoutRoomAssignmentResponse {
  factory _GetBreakoutRoomAssignmentResponse({required final String? roomId}) =
      _$_GetBreakoutRoomAssignmentResponse;

  factory _GetBreakoutRoomAssignmentResponse.fromJson(
          Map<String, dynamic> json) =
      _$_GetBreakoutRoomAssignmentResponse.fromJson;

  @override
  String? get roomId;
  @override
  @JsonKey(ignore: true)
  _$$_GetBreakoutRoomAssignmentResponseCopyWith<
          _$_GetBreakoutRoomAssignmentResponse>
      get copyWith => throw _privateConstructorUsedError;
}

GetHelpInMeetingRequest _$GetHelpInMeetingRequestFromJson(
    Map<String, dynamic> json) {
  return _GetHelpInMeetingRequest.fromJson(json);
}

/// @nodoc
mixin _$GetHelpInMeetingRequest {
  String get discussionPath => throw _privateConstructorUsedError;
  String get externalCommunityId => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $GetHelpInMeetingRequestCopyWith<GetHelpInMeetingRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GetHelpInMeetingRequestCopyWith<$Res> {
  factory $GetHelpInMeetingRequestCopyWith(GetHelpInMeetingRequest value,
          $Res Function(GetHelpInMeetingRequest) then) =
      _$GetHelpInMeetingRequestCopyWithImpl<$Res, GetHelpInMeetingRequest>;
  @useResult
  $Res call({String discussionPath, String externalCommunityId});
}

/// @nodoc
class _$GetHelpInMeetingRequestCopyWithImpl<$Res,
        $Val extends GetHelpInMeetingRequest>
    implements $GetHelpInMeetingRequestCopyWith<$Res> {
  _$GetHelpInMeetingRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? discussionPath = null,
    Object? externalCommunityId = null,
  }) {
    return _then(_value.copyWith(
      discussionPath: null == discussionPath
          ? _value.discussionPath
          : discussionPath // ignore: cast_nullable_to_non_nullable
              as String,
      externalCommunityId: null == externalCommunityId
          ? _value.externalCommunityId
          : externalCommunityId // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_GetHelpInMeetingRequestCopyWith<$Res>
    implements $GetHelpInMeetingRequestCopyWith<$Res> {
  factory _$$_GetHelpInMeetingRequestCopyWith(_$_GetHelpInMeetingRequest value,
          $Res Function(_$_GetHelpInMeetingRequest) then) =
      __$$_GetHelpInMeetingRequestCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String discussionPath, String externalCommunityId});
}

/// @nodoc
class __$$_GetHelpInMeetingRequestCopyWithImpl<$Res>
    extends _$GetHelpInMeetingRequestCopyWithImpl<$Res,
        _$_GetHelpInMeetingRequest>
    implements _$$_GetHelpInMeetingRequestCopyWith<$Res> {
  __$$_GetHelpInMeetingRequestCopyWithImpl(_$_GetHelpInMeetingRequest _value,
      $Res Function(_$_GetHelpInMeetingRequest) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? discussionPath = null,
    Object? externalCommunityId = null,
  }) {
    return _then(_$_GetHelpInMeetingRequest(
      discussionPath: null == discussionPath
          ? _value.discussionPath
          : discussionPath // ignore: cast_nullable_to_non_nullable
              as String,
      externalCommunityId: null == externalCommunityId
          ? _value.externalCommunityId
          : externalCommunityId // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_GetHelpInMeetingRequest implements _GetHelpInMeetingRequest {
  _$_GetHelpInMeetingRequest(
      {required this.discussionPath, required this.externalCommunityId});

  factory _$_GetHelpInMeetingRequest.fromJson(Map<String, dynamic> json) =>
      _$$_GetHelpInMeetingRequestFromJson(json);

  @override
  final String discussionPath;
  @override
  final String externalCommunityId;

  @override
  String toString() {
    return 'GetHelpInMeetingRequest(discussionPath: $discussionPath, externalCommunityId: $externalCommunityId)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_GetHelpInMeetingRequest &&
            (identical(other.discussionPath, discussionPath) ||
                other.discussionPath == discussionPath) &&
            (identical(other.externalCommunityId, externalCommunityId) ||
                other.externalCommunityId == externalCommunityId));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode =>
      Object.hash(runtimeType, discussionPath, externalCommunityId);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_GetHelpInMeetingRequestCopyWith<_$_GetHelpInMeetingRequest>
      get copyWith =>
          __$$_GetHelpInMeetingRequestCopyWithImpl<_$_GetHelpInMeetingRequest>(
              this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_GetHelpInMeetingRequestToJson(
      this,
    );
  }
}

abstract class _GetHelpInMeetingRequest implements GetHelpInMeetingRequest {
  factory _GetHelpInMeetingRequest(
      {required final String discussionPath,
      required final String externalCommunityId}) = _$_GetHelpInMeetingRequest;

  factory _GetHelpInMeetingRequest.fromJson(Map<String, dynamic> json) =
      _$_GetHelpInMeetingRequest.fromJson;

  @override
  String get discussionPath;
  @override
  String get externalCommunityId;
  @override
  @JsonKey(ignore: true)
  _$$_GetHelpInMeetingRequestCopyWith<_$_GetHelpInMeetingRequest>
      get copyWith => throw _privateConstructorUsedError;
}

GenerateTwilioCompositionRequest _$GenerateTwilioCompositionRequestFromJson(
    Map<String, dynamic> json) {
  return _GenerateTwilioCompositionRequest.fromJson(json);
}

/// @nodoc
mixin _$GenerateTwilioCompositionRequest {
  String get discussionPath => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $GenerateTwilioCompositionRequestCopyWith<GenerateTwilioCompositionRequest>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GenerateTwilioCompositionRequestCopyWith<$Res> {
  factory $GenerateTwilioCompositionRequestCopyWith(
          GenerateTwilioCompositionRequest value,
          $Res Function(GenerateTwilioCompositionRequest) then) =
      _$GenerateTwilioCompositionRequestCopyWithImpl<$Res,
          GenerateTwilioCompositionRequest>;
  @useResult
  $Res call({String discussionPath});
}

/// @nodoc
class _$GenerateTwilioCompositionRequestCopyWithImpl<$Res,
        $Val extends GenerateTwilioCompositionRequest>
    implements $GenerateTwilioCompositionRequestCopyWith<$Res> {
  _$GenerateTwilioCompositionRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? discussionPath = null,
  }) {
    return _then(_value.copyWith(
      discussionPath: null == discussionPath
          ? _value.discussionPath
          : discussionPath // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_GenerateTwilioCompositionRequestCopyWith<$Res>
    implements $GenerateTwilioCompositionRequestCopyWith<$Res> {
  factory _$$_GenerateTwilioCompositionRequestCopyWith(
          _$_GenerateTwilioCompositionRequest value,
          $Res Function(_$_GenerateTwilioCompositionRequest) then) =
      __$$_GenerateTwilioCompositionRequestCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String discussionPath});
}

/// @nodoc
class __$$_GenerateTwilioCompositionRequestCopyWithImpl<$Res>
    extends _$GenerateTwilioCompositionRequestCopyWithImpl<$Res,
        _$_GenerateTwilioCompositionRequest>
    implements _$$_GenerateTwilioCompositionRequestCopyWith<$Res> {
  __$$_GenerateTwilioCompositionRequestCopyWithImpl(
      _$_GenerateTwilioCompositionRequest _value,
      $Res Function(_$_GenerateTwilioCompositionRequest) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? discussionPath = null,
  }) {
    return _then(_$_GenerateTwilioCompositionRequest(
      discussionPath: null == discussionPath
          ? _value.discussionPath
          : discussionPath // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_GenerateTwilioCompositionRequest
    implements _GenerateTwilioCompositionRequest {
  _$_GenerateTwilioCompositionRequest({required this.discussionPath});

  factory _$_GenerateTwilioCompositionRequest.fromJson(
          Map<String, dynamic> json) =>
      _$$_GenerateTwilioCompositionRequestFromJson(json);

  @override
  final String discussionPath;

  @override
  String toString() {
    return 'GenerateTwilioCompositionRequest(discussionPath: $discussionPath)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_GenerateTwilioCompositionRequest &&
            (identical(other.discussionPath, discussionPath) ||
                other.discussionPath == discussionPath));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, discussionPath);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_GenerateTwilioCompositionRequestCopyWith<
          _$_GenerateTwilioCompositionRequest>
      get copyWith => __$$_GenerateTwilioCompositionRequestCopyWithImpl<
          _$_GenerateTwilioCompositionRequest>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_GenerateTwilioCompositionRequestToJson(
      this,
    );
  }
}

abstract class _GenerateTwilioCompositionRequest
    implements GenerateTwilioCompositionRequest {
  factory _GenerateTwilioCompositionRequest(
          {required final String discussionPath}) =
      _$_GenerateTwilioCompositionRequest;

  factory _GenerateTwilioCompositionRequest.fromJson(
      Map<String, dynamic> json) = _$_GenerateTwilioCompositionRequest.fromJson;

  @override
  String get discussionPath;
  @override
  @JsonKey(ignore: true)
  _$$_GenerateTwilioCompositionRequestCopyWith<
          _$_GenerateTwilioCompositionRequest>
      get copyWith => throw _privateConstructorUsedError;
}

DownloadTwilioCompositionRequest _$DownloadTwilioCompositionRequestFromJson(
    Map<String, dynamic> json) {
  return _DownloadTwilioCompositionRequest.fromJson(json);
}

/// @nodoc
mixin _$DownloadTwilioCompositionRequest {
  String get discussionPath => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $DownloadTwilioCompositionRequestCopyWith<DownloadTwilioCompositionRequest>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DownloadTwilioCompositionRequestCopyWith<$Res> {
  factory $DownloadTwilioCompositionRequestCopyWith(
          DownloadTwilioCompositionRequest value,
          $Res Function(DownloadTwilioCompositionRequest) then) =
      _$DownloadTwilioCompositionRequestCopyWithImpl<$Res,
          DownloadTwilioCompositionRequest>;
  @useResult
  $Res call({String discussionPath});
}

/// @nodoc
class _$DownloadTwilioCompositionRequestCopyWithImpl<$Res,
        $Val extends DownloadTwilioCompositionRequest>
    implements $DownloadTwilioCompositionRequestCopyWith<$Res> {
  _$DownloadTwilioCompositionRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? discussionPath = null,
  }) {
    return _then(_value.copyWith(
      discussionPath: null == discussionPath
          ? _value.discussionPath
          : discussionPath // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_DownloadTwilioCompositionRequestCopyWith<$Res>
    implements $DownloadTwilioCompositionRequestCopyWith<$Res> {
  factory _$$_DownloadTwilioCompositionRequestCopyWith(
          _$_DownloadTwilioCompositionRequest value,
          $Res Function(_$_DownloadTwilioCompositionRequest) then) =
      __$$_DownloadTwilioCompositionRequestCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String discussionPath});
}

/// @nodoc
class __$$_DownloadTwilioCompositionRequestCopyWithImpl<$Res>
    extends _$DownloadTwilioCompositionRequestCopyWithImpl<$Res,
        _$_DownloadTwilioCompositionRequest>
    implements _$$_DownloadTwilioCompositionRequestCopyWith<$Res> {
  __$$_DownloadTwilioCompositionRequestCopyWithImpl(
      _$_DownloadTwilioCompositionRequest _value,
      $Res Function(_$_DownloadTwilioCompositionRequest) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? discussionPath = null,
  }) {
    return _then(_$_DownloadTwilioCompositionRequest(
      discussionPath: null == discussionPath
          ? _value.discussionPath
          : discussionPath // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_DownloadTwilioCompositionRequest
    implements _DownloadTwilioCompositionRequest {
  _$_DownloadTwilioCompositionRequest({required this.discussionPath});

  factory _$_DownloadTwilioCompositionRequest.fromJson(
          Map<String, dynamic> json) =>
      _$$_DownloadTwilioCompositionRequestFromJson(json);

  @override
  final String discussionPath;

  @override
  String toString() {
    return 'DownloadTwilioCompositionRequest(discussionPath: $discussionPath)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_DownloadTwilioCompositionRequest &&
            (identical(other.discussionPath, discussionPath) ||
                other.discussionPath == discussionPath));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, discussionPath);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_DownloadTwilioCompositionRequestCopyWith<
          _$_DownloadTwilioCompositionRequest>
      get copyWith => __$$_DownloadTwilioCompositionRequestCopyWithImpl<
          _$_DownloadTwilioCompositionRequest>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_DownloadTwilioCompositionRequestToJson(
      this,
    );
  }
}

abstract class _DownloadTwilioCompositionRequest
    implements DownloadTwilioCompositionRequest {
  factory _DownloadTwilioCompositionRequest(
          {required final String discussionPath}) =
      _$_DownloadTwilioCompositionRequest;

  factory _DownloadTwilioCompositionRequest.fromJson(
      Map<String, dynamic> json) = _$_DownloadTwilioCompositionRequest.fromJson;

  @override
  String get discussionPath;
  @override
  @JsonKey(ignore: true)
  _$$_DownloadTwilioCompositionRequestCopyWith<
          _$_DownloadTwilioCompositionRequest>
      get copyWith => throw _privateConstructorUsedError;
}

DownloadTwilioCompositionResponse _$DownloadTwilioCompositionResponseFromJson(
    Map<String, dynamic> json) {
  return _DownloadTwilioCompositionResponse.fromJson(json);
}

/// @nodoc
mixin _$DownloadTwilioCompositionResponse {
  String get redirectUrl => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $DownloadTwilioCompositionResponseCopyWith<DownloadTwilioCompositionResponse>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DownloadTwilioCompositionResponseCopyWith<$Res> {
  factory $DownloadTwilioCompositionResponseCopyWith(
          DownloadTwilioCompositionResponse value,
          $Res Function(DownloadTwilioCompositionResponse) then) =
      _$DownloadTwilioCompositionResponseCopyWithImpl<$Res,
          DownloadTwilioCompositionResponse>;
  @useResult
  $Res call({String redirectUrl});
}

/// @nodoc
class _$DownloadTwilioCompositionResponseCopyWithImpl<$Res,
        $Val extends DownloadTwilioCompositionResponse>
    implements $DownloadTwilioCompositionResponseCopyWith<$Res> {
  _$DownloadTwilioCompositionResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? redirectUrl = null,
  }) {
    return _then(_value.copyWith(
      redirectUrl: null == redirectUrl
          ? _value.redirectUrl
          : redirectUrl // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_DownloadTwilioCompositionResponseCopyWith<$Res>
    implements $DownloadTwilioCompositionResponseCopyWith<$Res> {
  factory _$$_DownloadTwilioCompositionResponseCopyWith(
          _$_DownloadTwilioCompositionResponse value,
          $Res Function(_$_DownloadTwilioCompositionResponse) then) =
      __$$_DownloadTwilioCompositionResponseCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String redirectUrl});
}

/// @nodoc
class __$$_DownloadTwilioCompositionResponseCopyWithImpl<$Res>
    extends _$DownloadTwilioCompositionResponseCopyWithImpl<$Res,
        _$_DownloadTwilioCompositionResponse>
    implements _$$_DownloadTwilioCompositionResponseCopyWith<$Res> {
  __$$_DownloadTwilioCompositionResponseCopyWithImpl(
      _$_DownloadTwilioCompositionResponse _value,
      $Res Function(_$_DownloadTwilioCompositionResponse) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? redirectUrl = null,
  }) {
    return _then(_$_DownloadTwilioCompositionResponse(
      redirectUrl: null == redirectUrl
          ? _value.redirectUrl
          : redirectUrl // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_DownloadTwilioCompositionResponse
    implements _DownloadTwilioCompositionResponse {
  _$_DownloadTwilioCompositionResponse({required this.redirectUrl});

  factory _$_DownloadTwilioCompositionResponse.fromJson(
          Map<String, dynamic> json) =>
      _$$_DownloadTwilioCompositionResponseFromJson(json);

  @override
  final String redirectUrl;

  @override
  String toString() {
    return 'DownloadTwilioCompositionResponse(redirectUrl: $redirectUrl)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_DownloadTwilioCompositionResponse &&
            (identical(other.redirectUrl, redirectUrl) ||
                other.redirectUrl == redirectUrl));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, redirectUrl);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_DownloadTwilioCompositionResponseCopyWith<
          _$_DownloadTwilioCompositionResponse>
      get copyWith => __$$_DownloadTwilioCompositionResponseCopyWithImpl<
          _$_DownloadTwilioCompositionResponse>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_DownloadTwilioCompositionResponseToJson(
      this,
    );
  }
}

abstract class _DownloadTwilioCompositionResponse
    implements DownloadTwilioCompositionResponse {
  factory _DownloadTwilioCompositionResponse(
          {required final String redirectUrl}) =
      _$_DownloadTwilioCompositionResponse;

  factory _DownloadTwilioCompositionResponse.fromJson(
          Map<String, dynamic> json) =
      _$_DownloadTwilioCompositionResponse.fromJson;

  @override
  String get redirectUrl;
  @override
  @JsonKey(ignore: true)
  _$$_DownloadTwilioCompositionResponseCopyWith<
          _$_DownloadTwilioCompositionResponse>
      get copyWith => throw _privateConstructorUsedError;
}

KickParticipantRequest _$KickParticipantRequestFromJson(
    Map<String, dynamic> json) {
  return _KickParticipantRequest.fromJson(json);
}

/// @nodoc
mixin _$KickParticipantRequest {
  String get userToKickId => throw _privateConstructorUsedError;
  String get discussionPath => throw _privateConstructorUsedError;
  String? get breakoutRoomId => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $KickParticipantRequestCopyWith<KickParticipantRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $KickParticipantRequestCopyWith<$Res> {
  factory $KickParticipantRequestCopyWith(KickParticipantRequest value,
          $Res Function(KickParticipantRequest) then) =
      _$KickParticipantRequestCopyWithImpl<$Res, KickParticipantRequest>;
  @useResult
  $Res call(
      {String userToKickId, String discussionPath, String? breakoutRoomId});
}

/// @nodoc
class _$KickParticipantRequestCopyWithImpl<$Res,
        $Val extends KickParticipantRequest>
    implements $KickParticipantRequestCopyWith<$Res> {
  _$KickParticipantRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userToKickId = null,
    Object? discussionPath = null,
    Object? breakoutRoomId = freezed,
  }) {
    return _then(_value.copyWith(
      userToKickId: null == userToKickId
          ? _value.userToKickId
          : userToKickId // ignore: cast_nullable_to_non_nullable
              as String,
      discussionPath: null == discussionPath
          ? _value.discussionPath
          : discussionPath // ignore: cast_nullable_to_non_nullable
              as String,
      breakoutRoomId: freezed == breakoutRoomId
          ? _value.breakoutRoomId
          : breakoutRoomId // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_KickParticipantRequestCopyWith<$Res>
    implements $KickParticipantRequestCopyWith<$Res> {
  factory _$$_KickParticipantRequestCopyWith(_$_KickParticipantRequest value,
          $Res Function(_$_KickParticipantRequest) then) =
      __$$_KickParticipantRequestCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String userToKickId, String discussionPath, String? breakoutRoomId});
}

/// @nodoc
class __$$_KickParticipantRequestCopyWithImpl<$Res>
    extends _$KickParticipantRequestCopyWithImpl<$Res,
        _$_KickParticipantRequest>
    implements _$$_KickParticipantRequestCopyWith<$Res> {
  __$$_KickParticipantRequestCopyWithImpl(_$_KickParticipantRequest _value,
      $Res Function(_$_KickParticipantRequest) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userToKickId = null,
    Object? discussionPath = null,
    Object? breakoutRoomId = freezed,
  }) {
    return _then(_$_KickParticipantRequest(
      userToKickId: null == userToKickId
          ? _value.userToKickId
          : userToKickId // ignore: cast_nullable_to_non_nullable
              as String,
      discussionPath: null == discussionPath
          ? _value.discussionPath
          : discussionPath // ignore: cast_nullable_to_non_nullable
              as String,
      breakoutRoomId: freezed == breakoutRoomId
          ? _value.breakoutRoomId
          : breakoutRoomId // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_KickParticipantRequest implements _KickParticipantRequest {
  _$_KickParticipantRequest(
      {required this.userToKickId,
      required this.discussionPath,
      this.breakoutRoomId});

  factory _$_KickParticipantRequest.fromJson(Map<String, dynamic> json) =>
      _$$_KickParticipantRequestFromJson(json);

  @override
  final String userToKickId;
  @override
  final String discussionPath;
  @override
  final String? breakoutRoomId;

  @override
  String toString() {
    return 'KickParticipantRequest(userToKickId: $userToKickId, discussionPath: $discussionPath, breakoutRoomId: $breakoutRoomId)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_KickParticipantRequest &&
            (identical(other.userToKickId, userToKickId) ||
                other.userToKickId == userToKickId) &&
            (identical(other.discussionPath, discussionPath) ||
                other.discussionPath == discussionPath) &&
            (identical(other.breakoutRoomId, breakoutRoomId) ||
                other.breakoutRoomId == breakoutRoomId));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode =>
      Object.hash(runtimeType, userToKickId, discussionPath, breakoutRoomId);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_KickParticipantRequestCopyWith<_$_KickParticipantRequest> get copyWith =>
      __$$_KickParticipantRequestCopyWithImpl<_$_KickParticipantRequest>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_KickParticipantRequestToJson(
      this,
    );
  }
}

abstract class _KickParticipantRequest implements KickParticipantRequest {
  factory _KickParticipantRequest(
      {required final String userToKickId,
      required final String discussionPath,
      final String? breakoutRoomId}) = _$_KickParticipantRequest;

  factory _KickParticipantRequest.fromJson(Map<String, dynamic> json) =
      _$_KickParticipantRequest.fromJson;

  @override
  String get userToKickId;
  @override
  String get discussionPath;
  @override
  String? get breakoutRoomId;
  @override
  @JsonKey(ignore: true)
  _$$_KickParticipantRequestCopyWith<_$_KickParticipantRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

OnUnifyCancellationRequest _$OnUnifyCancellationRequestFromJson(
    Map<String, dynamic> json) {
  return _OnUnifyCancellationRequest.fromJson(json);
}

/// @nodoc
mixin _$OnUnifyCancellationRequest {
  String get meetingId => throw _privateConstructorUsedError;
  String get participantId => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $OnUnifyCancellationRequestCopyWith<OnUnifyCancellationRequest>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $OnUnifyCancellationRequestCopyWith<$Res> {
  factory $OnUnifyCancellationRequestCopyWith(OnUnifyCancellationRequest value,
          $Res Function(OnUnifyCancellationRequest) then) =
      _$OnUnifyCancellationRequestCopyWithImpl<$Res,
          OnUnifyCancellationRequest>;
  @useResult
  $Res call({String meetingId, String participantId});
}

/// @nodoc
class _$OnUnifyCancellationRequestCopyWithImpl<$Res,
        $Val extends OnUnifyCancellationRequest>
    implements $OnUnifyCancellationRequestCopyWith<$Res> {
  _$OnUnifyCancellationRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? meetingId = null,
    Object? participantId = null,
  }) {
    return _then(_value.copyWith(
      meetingId: null == meetingId
          ? _value.meetingId
          : meetingId // ignore: cast_nullable_to_non_nullable
              as String,
      participantId: null == participantId
          ? _value.participantId
          : participantId // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_OnUnifyCancellationRequestCopyWith<$Res>
    implements $OnUnifyCancellationRequestCopyWith<$Res> {
  factory _$$_OnUnifyCancellationRequestCopyWith(
          _$_OnUnifyCancellationRequest value,
          $Res Function(_$_OnUnifyCancellationRequest) then) =
      __$$_OnUnifyCancellationRequestCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String meetingId, String participantId});
}

/// @nodoc
class __$$_OnUnifyCancellationRequestCopyWithImpl<$Res>
    extends _$OnUnifyCancellationRequestCopyWithImpl<$Res,
        _$_OnUnifyCancellationRequest>
    implements _$$_OnUnifyCancellationRequestCopyWith<$Res> {
  __$$_OnUnifyCancellationRequestCopyWithImpl(
      _$_OnUnifyCancellationRequest _value,
      $Res Function(_$_OnUnifyCancellationRequest) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? meetingId = null,
    Object? participantId = null,
  }) {
    return _then(_$_OnUnifyCancellationRequest(
      meetingId: null == meetingId
          ? _value.meetingId
          : meetingId // ignore: cast_nullable_to_non_nullable
              as String,
      participantId: null == participantId
          ? _value.participantId
          : participantId // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_OnUnifyCancellationRequest implements _OnUnifyCancellationRequest {
  _$_OnUnifyCancellationRequest(
      {required this.meetingId, required this.participantId});

  factory _$_OnUnifyCancellationRequest.fromJson(Map<String, dynamic> json) =>
      _$$_OnUnifyCancellationRequestFromJson(json);

  @override
  final String meetingId;
  @override
  final String participantId;

  @override
  String toString() {
    return 'OnUnifyCancellationRequest(meetingId: $meetingId, participantId: $participantId)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_OnUnifyCancellationRequest &&
            (identical(other.meetingId, meetingId) ||
                other.meetingId == meetingId) &&
            (identical(other.participantId, participantId) ||
                other.participantId == participantId));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, meetingId, participantId);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_OnUnifyCancellationRequestCopyWith<_$_OnUnifyCancellationRequest>
      get copyWith => __$$_OnUnifyCancellationRequestCopyWithImpl<
          _$_OnUnifyCancellationRequest>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_OnUnifyCancellationRequestToJson(
      this,
    );
  }
}

abstract class _OnUnifyCancellationRequest
    implements OnUnifyCancellationRequest {
  factory _OnUnifyCancellationRequest(
      {required final String meetingId,
      required final String participantId}) = _$_OnUnifyCancellationRequest;

  factory _OnUnifyCancellationRequest.fromJson(Map<String, dynamic> json) =
      _$_OnUnifyCancellationRequest.fromJson;

  @override
  String get meetingId;
  @override
  String get participantId;
  @override
  @JsonKey(ignore: true)
  _$$_OnUnifyCancellationRequestCopyWith<_$_OnUnifyCancellationRequest>
      get copyWith => throw _privateConstructorUsedError;
}

ResolveJoinRequestRequest _$ResolveJoinRequestRequestFromJson(
    Map<String, dynamic> json) {
  return _ResolveJoinRequestRequest.fromJson(json);
}

/// @nodoc
mixin _$ResolveJoinRequestRequest {
  String get juntoId => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  bool get approve => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ResolveJoinRequestRequestCopyWith<ResolveJoinRequestRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ResolveJoinRequestRequestCopyWith<$Res> {
  factory $ResolveJoinRequestRequestCopyWith(ResolveJoinRequestRequest value,
          $Res Function(ResolveJoinRequestRequest) then) =
      _$ResolveJoinRequestRequestCopyWithImpl<$Res, ResolveJoinRequestRequest>;
  @useResult
  $Res call({String juntoId, String userId, bool approve});
}

/// @nodoc
class _$ResolveJoinRequestRequestCopyWithImpl<$Res,
        $Val extends ResolveJoinRequestRequest>
    implements $ResolveJoinRequestRequestCopyWith<$Res> {
  _$ResolveJoinRequestRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? juntoId = null,
    Object? userId = null,
    Object? approve = null,
  }) {
    return _then(_value.copyWith(
      juntoId: null == juntoId
          ? _value.juntoId
          : juntoId // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      approve: null == approve
          ? _value.approve
          : approve // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_ResolveJoinRequestRequestCopyWith<$Res>
    implements $ResolveJoinRequestRequestCopyWith<$Res> {
  factory _$$_ResolveJoinRequestRequestCopyWith(
          _$_ResolveJoinRequestRequest value,
          $Res Function(_$_ResolveJoinRequestRequest) then) =
      __$$_ResolveJoinRequestRequestCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String juntoId, String userId, bool approve});
}

/// @nodoc
class __$$_ResolveJoinRequestRequestCopyWithImpl<$Res>
    extends _$ResolveJoinRequestRequestCopyWithImpl<$Res,
        _$_ResolveJoinRequestRequest>
    implements _$$_ResolveJoinRequestRequestCopyWith<$Res> {
  __$$_ResolveJoinRequestRequestCopyWithImpl(
      _$_ResolveJoinRequestRequest _value,
      $Res Function(_$_ResolveJoinRequestRequest) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? juntoId = null,
    Object? userId = null,
    Object? approve = null,
  }) {
    return _then(_$_ResolveJoinRequestRequest(
      juntoId: null == juntoId
          ? _value.juntoId
          : juntoId // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      approve: null == approve
          ? _value.approve
          : approve // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_ResolveJoinRequestRequest implements _ResolveJoinRequestRequest {
  _$_ResolveJoinRequestRequest(
      {required this.juntoId, required this.userId, required this.approve});

  factory _$_ResolveJoinRequestRequest.fromJson(Map<String, dynamic> json) =>
      _$$_ResolveJoinRequestRequestFromJson(json);

  @override
  final String juntoId;
  @override
  final String userId;
  @override
  final bool approve;

  @override
  String toString() {
    return 'ResolveJoinRequestRequest(juntoId: $juntoId, userId: $userId, approve: $approve)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_ResolveJoinRequestRequest &&
            (identical(other.juntoId, juntoId) || other.juntoId == juntoId) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.approve, approve) || other.approve == approve));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, juntoId, userId, approve);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_ResolveJoinRequestRequestCopyWith<_$_ResolveJoinRequestRequest>
      get copyWith => __$$_ResolveJoinRequestRequestCopyWithImpl<
          _$_ResolveJoinRequestRequest>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_ResolveJoinRequestRequestToJson(
      this,
    );
  }
}

abstract class _ResolveJoinRequestRequest implements ResolveJoinRequestRequest {
  factory _ResolveJoinRequestRequest(
      {required final String juntoId,
      required final String userId,
      required final bool approve}) = _$_ResolveJoinRequestRequest;

  factory _ResolveJoinRequestRequest.fromJson(Map<String, dynamic> json) =
      _$_ResolveJoinRequestRequest.fromJson;

  @override
  String get juntoId;
  @override
  String get userId;
  @override
  bool get approve;
  @override
  @JsonKey(ignore: true)
  _$$_ResolveJoinRequestRequestCopyWith<_$_ResolveJoinRequestRequest>
      get copyWith => throw _privateConstructorUsedError;
}

InitiateBreakoutsRequest _$InitiateBreakoutsRequestFromJson(
    Map<String, dynamic> json) {
  return _InitiateBreakoutsRequest.fromJson(json);
}

/// @nodoc
mixin _$InitiateBreakoutsRequest {
  String get discussionPath => throw _privateConstructorUsedError;
  int get targetParticipantsPerRoom => throw _privateConstructorUsedError;
  String get breakoutSessionId => throw _privateConstructorUsedError;
  @JsonKey(unknownEnumValue: null)
  BreakoutAssignmentMethod? get assignmentMethod =>
      throw _privateConstructorUsedError;
  bool get includeWaitingRoom => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $InitiateBreakoutsRequestCopyWith<InitiateBreakoutsRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $InitiateBreakoutsRequestCopyWith<$Res> {
  factory $InitiateBreakoutsRequestCopyWith(InitiateBreakoutsRequest value,
          $Res Function(InitiateBreakoutsRequest) then) =
      _$InitiateBreakoutsRequestCopyWithImpl<$Res, InitiateBreakoutsRequest>;
  @useResult
  $Res call(
      {String discussionPath,
      int targetParticipantsPerRoom,
      String breakoutSessionId,
      @JsonKey(unknownEnumValue: null)
      BreakoutAssignmentMethod? assignmentMethod,
      bool includeWaitingRoom});
}

/// @nodoc
class _$InitiateBreakoutsRequestCopyWithImpl<$Res,
        $Val extends InitiateBreakoutsRequest>
    implements $InitiateBreakoutsRequestCopyWith<$Res> {
  _$InitiateBreakoutsRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? discussionPath = null,
    Object? targetParticipantsPerRoom = null,
    Object? breakoutSessionId = null,
    Object? assignmentMethod = freezed,
    Object? includeWaitingRoom = null,
  }) {
    return _then(_value.copyWith(
      discussionPath: null == discussionPath
          ? _value.discussionPath
          : discussionPath // ignore: cast_nullable_to_non_nullable
              as String,
      targetParticipantsPerRoom: null == targetParticipantsPerRoom
          ? _value.targetParticipantsPerRoom
          : targetParticipantsPerRoom // ignore: cast_nullable_to_non_nullable
              as int,
      breakoutSessionId: null == breakoutSessionId
          ? _value.breakoutSessionId
          : breakoutSessionId // ignore: cast_nullable_to_non_nullable
              as String,
      assignmentMethod: freezed == assignmentMethod
          ? _value.assignmentMethod
          : assignmentMethod // ignore: cast_nullable_to_non_nullable
              as BreakoutAssignmentMethod?,
      includeWaitingRoom: null == includeWaitingRoom
          ? _value.includeWaitingRoom
          : includeWaitingRoom // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_InitiateBreakoutsRequestCopyWith<$Res>
    implements $InitiateBreakoutsRequestCopyWith<$Res> {
  factory _$$_InitiateBreakoutsRequestCopyWith(
          _$_InitiateBreakoutsRequest value,
          $Res Function(_$_InitiateBreakoutsRequest) then) =
      __$$_InitiateBreakoutsRequestCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String discussionPath,
      int targetParticipantsPerRoom,
      String breakoutSessionId,
      @JsonKey(unknownEnumValue: null)
      BreakoutAssignmentMethod? assignmentMethod,
      bool includeWaitingRoom});
}

/// @nodoc
class __$$_InitiateBreakoutsRequestCopyWithImpl<$Res>
    extends _$InitiateBreakoutsRequestCopyWithImpl<$Res,
        _$_InitiateBreakoutsRequest>
    implements _$$_InitiateBreakoutsRequestCopyWith<$Res> {
  __$$_InitiateBreakoutsRequestCopyWithImpl(_$_InitiateBreakoutsRequest _value,
      $Res Function(_$_InitiateBreakoutsRequest) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? discussionPath = null,
    Object? targetParticipantsPerRoom = null,
    Object? breakoutSessionId = null,
    Object? assignmentMethod = freezed,
    Object? includeWaitingRoom = null,
  }) {
    return _then(_$_InitiateBreakoutsRequest(
      discussionPath: null == discussionPath
          ? _value.discussionPath
          : discussionPath // ignore: cast_nullable_to_non_nullable
              as String,
      targetParticipantsPerRoom: null == targetParticipantsPerRoom
          ? _value.targetParticipantsPerRoom
          : targetParticipantsPerRoom // ignore: cast_nullable_to_non_nullable
              as int,
      breakoutSessionId: null == breakoutSessionId
          ? _value.breakoutSessionId
          : breakoutSessionId // ignore: cast_nullable_to_non_nullable
              as String,
      assignmentMethod: freezed == assignmentMethod
          ? _value.assignmentMethod
          : assignmentMethod // ignore: cast_nullable_to_non_nullable
              as BreakoutAssignmentMethod?,
      includeWaitingRoom: null == includeWaitingRoom
          ? _value.includeWaitingRoom
          : includeWaitingRoom // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_InitiateBreakoutsRequest implements _InitiateBreakoutsRequest {
  _$_InitiateBreakoutsRequest(
      {required this.discussionPath,
      required this.targetParticipantsPerRoom,
      required this.breakoutSessionId,
      @JsonKey(unknownEnumValue: null) this.assignmentMethod,
      this.includeWaitingRoom = false});

  factory _$_InitiateBreakoutsRequest.fromJson(Map<String, dynamic> json) =>
      _$$_InitiateBreakoutsRequestFromJson(json);

  @override
  final String discussionPath;
  @override
  final int targetParticipantsPerRoom;
  @override
  final String breakoutSessionId;
  @override
  @JsonKey(unknownEnumValue: null)
  final BreakoutAssignmentMethod? assignmentMethod;
  @override
  @JsonKey()
  final bool includeWaitingRoom;

  @override
  String toString() {
    return 'InitiateBreakoutsRequest(discussionPath: $discussionPath, targetParticipantsPerRoom: $targetParticipantsPerRoom, breakoutSessionId: $breakoutSessionId, assignmentMethod: $assignmentMethod, includeWaitingRoom: $includeWaitingRoom)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_InitiateBreakoutsRequest &&
            (identical(other.discussionPath, discussionPath) ||
                other.discussionPath == discussionPath) &&
            (identical(other.targetParticipantsPerRoom,
                    targetParticipantsPerRoom) ||
                other.targetParticipantsPerRoom == targetParticipantsPerRoom) &&
            (identical(other.breakoutSessionId, breakoutSessionId) ||
                other.breakoutSessionId == breakoutSessionId) &&
            (identical(other.assignmentMethod, assignmentMethod) ||
                other.assignmentMethod == assignmentMethod) &&
            (identical(other.includeWaitingRoom, includeWaitingRoom) ||
                other.includeWaitingRoom == includeWaitingRoom));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      discussionPath,
      targetParticipantsPerRoom,
      breakoutSessionId,
      assignmentMethod,
      includeWaitingRoom);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_InitiateBreakoutsRequestCopyWith<_$_InitiateBreakoutsRequest>
      get copyWith => __$$_InitiateBreakoutsRequestCopyWithImpl<
          _$_InitiateBreakoutsRequest>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_InitiateBreakoutsRequestToJson(
      this,
    );
  }
}

abstract class _InitiateBreakoutsRequest implements InitiateBreakoutsRequest {
  factory _InitiateBreakoutsRequest(
      {required final String discussionPath,
      required final int targetParticipantsPerRoom,
      required final String breakoutSessionId,
      @JsonKey(unknownEnumValue: null)
      final BreakoutAssignmentMethod? assignmentMethod,
      final bool includeWaitingRoom}) = _$_InitiateBreakoutsRequest;

  factory _InitiateBreakoutsRequest.fromJson(Map<String, dynamic> json) =
      _$_InitiateBreakoutsRequest.fromJson;

  @override
  String get discussionPath;
  @override
  int get targetParticipantsPerRoom;
  @override
  String get breakoutSessionId;
  @override
  @JsonKey(unknownEnumValue: null)
  BreakoutAssignmentMethod? get assignmentMethod;
  @override
  bool get includeWaitingRoom;
  @override
  @JsonKey(ignore: true)
  _$$_InitiateBreakoutsRequestCopyWith<_$_InitiateBreakoutsRequest>
      get copyWith => throw _privateConstructorUsedError;
}

InitiateBreakoutsResponse _$InitiateBreakoutsResponseFromJson(
    Map<String, dynamic> json) {
  return _InitiateBreakoutsResponse.fromJson(json);
}

/// @nodoc
mixin _$InitiateBreakoutsResponse {
  String get breakoutSessionId => throw _privateConstructorUsedError;
  DateTime get scheduledTime => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $InitiateBreakoutsResponseCopyWith<InitiateBreakoutsResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $InitiateBreakoutsResponseCopyWith<$Res> {
  factory $InitiateBreakoutsResponseCopyWith(InitiateBreakoutsResponse value,
          $Res Function(InitiateBreakoutsResponse) then) =
      _$InitiateBreakoutsResponseCopyWithImpl<$Res, InitiateBreakoutsResponse>;
  @useResult
  $Res call({String breakoutSessionId, DateTime scheduledTime});
}

/// @nodoc
class _$InitiateBreakoutsResponseCopyWithImpl<$Res,
        $Val extends InitiateBreakoutsResponse>
    implements $InitiateBreakoutsResponseCopyWith<$Res> {
  _$InitiateBreakoutsResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? breakoutSessionId = null,
    Object? scheduledTime = null,
  }) {
    return _then(_value.copyWith(
      breakoutSessionId: null == breakoutSessionId
          ? _value.breakoutSessionId
          : breakoutSessionId // ignore: cast_nullable_to_non_nullable
              as String,
      scheduledTime: null == scheduledTime
          ? _value.scheduledTime
          : scheduledTime // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_InitiateBreakoutsResponseCopyWith<$Res>
    implements $InitiateBreakoutsResponseCopyWith<$Res> {
  factory _$$_InitiateBreakoutsResponseCopyWith(
          _$_InitiateBreakoutsResponse value,
          $Res Function(_$_InitiateBreakoutsResponse) then) =
      __$$_InitiateBreakoutsResponseCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String breakoutSessionId, DateTime scheduledTime});
}

/// @nodoc
class __$$_InitiateBreakoutsResponseCopyWithImpl<$Res>
    extends _$InitiateBreakoutsResponseCopyWithImpl<$Res,
        _$_InitiateBreakoutsResponse>
    implements _$$_InitiateBreakoutsResponseCopyWith<$Res> {
  __$$_InitiateBreakoutsResponseCopyWithImpl(
      _$_InitiateBreakoutsResponse _value,
      $Res Function(_$_InitiateBreakoutsResponse) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? breakoutSessionId = null,
    Object? scheduledTime = null,
  }) {
    return _then(_$_InitiateBreakoutsResponse(
      breakoutSessionId: null == breakoutSessionId
          ? _value.breakoutSessionId
          : breakoutSessionId // ignore: cast_nullable_to_non_nullable
              as String,
      scheduledTime: null == scheduledTime
          ? _value.scheduledTime
          : scheduledTime // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_InitiateBreakoutsResponse implements _InitiateBreakoutsResponse {
  _$_InitiateBreakoutsResponse(
      {required this.breakoutSessionId, required this.scheduledTime});

  factory _$_InitiateBreakoutsResponse.fromJson(Map<String, dynamic> json) =>
      _$$_InitiateBreakoutsResponseFromJson(json);

  @override
  final String breakoutSessionId;
  @override
  final DateTime scheduledTime;

  @override
  String toString() {
    return 'InitiateBreakoutsResponse(breakoutSessionId: $breakoutSessionId, scheduledTime: $scheduledTime)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_InitiateBreakoutsResponse &&
            (identical(other.breakoutSessionId, breakoutSessionId) ||
                other.breakoutSessionId == breakoutSessionId) &&
            (identical(other.scheduledTime, scheduledTime) ||
                other.scheduledTime == scheduledTime));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode =>
      Object.hash(runtimeType, breakoutSessionId, scheduledTime);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_InitiateBreakoutsResponseCopyWith<_$_InitiateBreakoutsResponse>
      get copyWith => __$$_InitiateBreakoutsResponseCopyWithImpl<
          _$_InitiateBreakoutsResponse>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_InitiateBreakoutsResponseToJson(
      this,
    );
  }
}

abstract class _InitiateBreakoutsResponse implements InitiateBreakoutsResponse {
  factory _InitiateBreakoutsResponse(
      {required final String breakoutSessionId,
      required final DateTime scheduledTime}) = _$_InitiateBreakoutsResponse;

  factory _InitiateBreakoutsResponse.fromJson(Map<String, dynamic> json) =
      _$_InitiateBreakoutsResponse.fromJson;

  @override
  String get breakoutSessionId;
  @override
  DateTime get scheduledTime;
  @override
  @JsonKey(ignore: true)
  _$$_InitiateBreakoutsResponseCopyWith<_$_InitiateBreakoutsResponse>
      get copyWith => throw _privateConstructorUsedError;
}

ReassignBreakoutRoomRequest _$ReassignBreakoutRoomRequestFromJson(
    Map<String, dynamic> json) {
  return _ReassignBreakoutRoomRequest.fromJson(json);
}

/// @nodoc
mixin _$ReassignBreakoutRoomRequest {
  String get discussionPath => throw _privateConstructorUsedError;
  String get breakoutRoomSessionId => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;

  /// This is a little bit hacky. This can be the waiting room ID constant,
  /// the assign new room ID constant, or the integer room name of the room
  /// being assigned to.
  String? get newRoomNumber => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ReassignBreakoutRoomRequestCopyWith<ReassignBreakoutRoomRequest>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ReassignBreakoutRoomRequestCopyWith<$Res> {
  factory $ReassignBreakoutRoomRequestCopyWith(
          ReassignBreakoutRoomRequest value,
          $Res Function(ReassignBreakoutRoomRequest) then) =
      _$ReassignBreakoutRoomRequestCopyWithImpl<$Res,
          ReassignBreakoutRoomRequest>;
  @useResult
  $Res call(
      {String discussionPath,
      String breakoutRoomSessionId,
      String userId,
      String? newRoomNumber});
}

/// @nodoc
class _$ReassignBreakoutRoomRequestCopyWithImpl<$Res,
        $Val extends ReassignBreakoutRoomRequest>
    implements $ReassignBreakoutRoomRequestCopyWith<$Res> {
  _$ReassignBreakoutRoomRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? discussionPath = null,
    Object? breakoutRoomSessionId = null,
    Object? userId = null,
    Object? newRoomNumber = freezed,
  }) {
    return _then(_value.copyWith(
      discussionPath: null == discussionPath
          ? _value.discussionPath
          : discussionPath // ignore: cast_nullable_to_non_nullable
              as String,
      breakoutRoomSessionId: null == breakoutRoomSessionId
          ? _value.breakoutRoomSessionId
          : breakoutRoomSessionId // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      newRoomNumber: freezed == newRoomNumber
          ? _value.newRoomNumber
          : newRoomNumber // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_ReassignBreakoutRoomRequestCopyWith<$Res>
    implements $ReassignBreakoutRoomRequestCopyWith<$Res> {
  factory _$$_ReassignBreakoutRoomRequestCopyWith(
          _$_ReassignBreakoutRoomRequest value,
          $Res Function(_$_ReassignBreakoutRoomRequest) then) =
      __$$_ReassignBreakoutRoomRequestCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String discussionPath,
      String breakoutRoomSessionId,
      String userId,
      String? newRoomNumber});
}

/// @nodoc
class __$$_ReassignBreakoutRoomRequestCopyWithImpl<$Res>
    extends _$ReassignBreakoutRoomRequestCopyWithImpl<$Res,
        _$_ReassignBreakoutRoomRequest>
    implements _$$_ReassignBreakoutRoomRequestCopyWith<$Res> {
  __$$_ReassignBreakoutRoomRequestCopyWithImpl(
      _$_ReassignBreakoutRoomRequest _value,
      $Res Function(_$_ReassignBreakoutRoomRequest) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? discussionPath = null,
    Object? breakoutRoomSessionId = null,
    Object? userId = null,
    Object? newRoomNumber = freezed,
  }) {
    return _then(_$_ReassignBreakoutRoomRequest(
      discussionPath: null == discussionPath
          ? _value.discussionPath
          : discussionPath // ignore: cast_nullable_to_non_nullable
              as String,
      breakoutRoomSessionId: null == breakoutRoomSessionId
          ? _value.breakoutRoomSessionId
          : breakoutRoomSessionId // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      newRoomNumber: freezed == newRoomNumber
          ? _value.newRoomNumber
          : newRoomNumber // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_ReassignBreakoutRoomRequest implements _ReassignBreakoutRoomRequest {
  _$_ReassignBreakoutRoomRequest(
      {required this.discussionPath,
      required this.breakoutRoomSessionId,
      required this.userId,
      this.newRoomNumber});

  factory _$_ReassignBreakoutRoomRequest.fromJson(Map<String, dynamic> json) =>
      _$$_ReassignBreakoutRoomRequestFromJson(json);

  @override
  final String discussionPath;
  @override
  final String breakoutRoomSessionId;
  @override
  final String userId;

  /// This is a little bit hacky. This can be the waiting room ID constant,
  /// the assign new room ID constant, or the integer room name of the room
  /// being assigned to.
  @override
  final String? newRoomNumber;

  @override
  String toString() {
    return 'ReassignBreakoutRoomRequest(discussionPath: $discussionPath, breakoutRoomSessionId: $breakoutRoomSessionId, userId: $userId, newRoomNumber: $newRoomNumber)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_ReassignBreakoutRoomRequest &&
            (identical(other.discussionPath, discussionPath) ||
                other.discussionPath == discussionPath) &&
            (identical(other.breakoutRoomSessionId, breakoutRoomSessionId) ||
                other.breakoutRoomSessionId == breakoutRoomSessionId) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.newRoomNumber, newRoomNumber) ||
                other.newRoomNumber == newRoomNumber));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, discussionPath,
      breakoutRoomSessionId, userId, newRoomNumber);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_ReassignBreakoutRoomRequestCopyWith<_$_ReassignBreakoutRoomRequest>
      get copyWith => __$$_ReassignBreakoutRoomRequestCopyWithImpl<
          _$_ReassignBreakoutRoomRequest>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_ReassignBreakoutRoomRequestToJson(
      this,
    );
  }
}

abstract class _ReassignBreakoutRoomRequest
    implements ReassignBreakoutRoomRequest {
  factory _ReassignBreakoutRoomRequest(
      {required final String discussionPath,
      required final String breakoutRoomSessionId,
      required final String userId,
      final String? newRoomNumber}) = _$_ReassignBreakoutRoomRequest;

  factory _ReassignBreakoutRoomRequest.fromJson(Map<String, dynamic> json) =
      _$_ReassignBreakoutRoomRequest.fromJson;

  @override
  String get discussionPath;
  @override
  String get breakoutRoomSessionId;
  @override
  String get userId;
  @override

  /// This is a little bit hacky. This can be the waiting room ID constant,
  /// the assign new room ID constant, or the integer room name of the room
  /// being assigned to.
  String? get newRoomNumber;
  @override
  @JsonKey(ignore: true)
  _$$_ReassignBreakoutRoomRequestCopyWith<_$_ReassignBreakoutRoomRequest>
      get copyWith => throw _privateConstructorUsedError;
}

UpdateBreakoutRoomFlagStatusRequest
    _$UpdateBreakoutRoomFlagStatusRequestFromJson(Map<String, dynamic> json) {
  return _UpdateBreakoutRoomFlagStatusRequest.fromJson(json);
}

/// @nodoc
mixin _$UpdateBreakoutRoomFlagStatusRequest {
  String get discussionPath => throw _privateConstructorUsedError;
  String get breakoutSessionId => throw _privateConstructorUsedError;
  String get roomId => throw _privateConstructorUsedError;
  @JsonKey(unknownEnumValue: null)
  BreakoutRoomFlagStatus? get flagStatus => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $UpdateBreakoutRoomFlagStatusRequestCopyWith<
          UpdateBreakoutRoomFlagStatusRequest>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UpdateBreakoutRoomFlagStatusRequestCopyWith<$Res> {
  factory $UpdateBreakoutRoomFlagStatusRequestCopyWith(
          UpdateBreakoutRoomFlagStatusRequest value,
          $Res Function(UpdateBreakoutRoomFlagStatusRequest) then) =
      _$UpdateBreakoutRoomFlagStatusRequestCopyWithImpl<$Res,
          UpdateBreakoutRoomFlagStatusRequest>;
  @useResult
  $Res call(
      {String discussionPath,
      String breakoutSessionId,
      String roomId,
      @JsonKey(unknownEnumValue: null) BreakoutRoomFlagStatus? flagStatus});
}

/// @nodoc
class _$UpdateBreakoutRoomFlagStatusRequestCopyWithImpl<$Res,
        $Val extends UpdateBreakoutRoomFlagStatusRequest>
    implements $UpdateBreakoutRoomFlagStatusRequestCopyWith<$Res> {
  _$UpdateBreakoutRoomFlagStatusRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? discussionPath = null,
    Object? breakoutSessionId = null,
    Object? roomId = null,
    Object? flagStatus = freezed,
  }) {
    return _then(_value.copyWith(
      discussionPath: null == discussionPath
          ? _value.discussionPath
          : discussionPath // ignore: cast_nullable_to_non_nullable
              as String,
      breakoutSessionId: null == breakoutSessionId
          ? _value.breakoutSessionId
          : breakoutSessionId // ignore: cast_nullable_to_non_nullable
              as String,
      roomId: null == roomId
          ? _value.roomId
          : roomId // ignore: cast_nullable_to_non_nullable
              as String,
      flagStatus: freezed == flagStatus
          ? _value.flagStatus
          : flagStatus // ignore: cast_nullable_to_non_nullable
              as BreakoutRoomFlagStatus?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_UpdateBreakoutRoomFlagStatusRequestCopyWith<$Res>
    implements $UpdateBreakoutRoomFlagStatusRequestCopyWith<$Res> {
  factory _$$_UpdateBreakoutRoomFlagStatusRequestCopyWith(
          _$_UpdateBreakoutRoomFlagStatusRequest value,
          $Res Function(_$_UpdateBreakoutRoomFlagStatusRequest) then) =
      __$$_UpdateBreakoutRoomFlagStatusRequestCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String discussionPath,
      String breakoutSessionId,
      String roomId,
      @JsonKey(unknownEnumValue: null) BreakoutRoomFlagStatus? flagStatus});
}

/// @nodoc
class __$$_UpdateBreakoutRoomFlagStatusRequestCopyWithImpl<$Res>
    extends _$UpdateBreakoutRoomFlagStatusRequestCopyWithImpl<$Res,
        _$_UpdateBreakoutRoomFlagStatusRequest>
    implements _$$_UpdateBreakoutRoomFlagStatusRequestCopyWith<$Res> {
  __$$_UpdateBreakoutRoomFlagStatusRequestCopyWithImpl(
      _$_UpdateBreakoutRoomFlagStatusRequest _value,
      $Res Function(_$_UpdateBreakoutRoomFlagStatusRequest) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? discussionPath = null,
    Object? breakoutSessionId = null,
    Object? roomId = null,
    Object? flagStatus = freezed,
  }) {
    return _then(_$_UpdateBreakoutRoomFlagStatusRequest(
      discussionPath: null == discussionPath
          ? _value.discussionPath
          : discussionPath // ignore: cast_nullable_to_non_nullable
              as String,
      breakoutSessionId: null == breakoutSessionId
          ? _value.breakoutSessionId
          : breakoutSessionId // ignore: cast_nullable_to_non_nullable
              as String,
      roomId: null == roomId
          ? _value.roomId
          : roomId // ignore: cast_nullable_to_non_nullable
              as String,
      flagStatus: freezed == flagStatus
          ? _value.flagStatus
          : flagStatus // ignore: cast_nullable_to_non_nullable
              as BreakoutRoomFlagStatus?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_UpdateBreakoutRoomFlagStatusRequest
    implements _UpdateBreakoutRoomFlagStatusRequest {
  _$_UpdateBreakoutRoomFlagStatusRequest(
      {required this.discussionPath,
      required this.breakoutSessionId,
      required this.roomId,
      @JsonKey(unknownEnumValue: null) this.flagStatus});

  factory _$_UpdateBreakoutRoomFlagStatusRequest.fromJson(
          Map<String, dynamic> json) =>
      _$$_UpdateBreakoutRoomFlagStatusRequestFromJson(json);

  @override
  final String discussionPath;
  @override
  final String breakoutSessionId;
  @override
  final String roomId;
  @override
  @JsonKey(unknownEnumValue: null)
  final BreakoutRoomFlagStatus? flagStatus;

  @override
  String toString() {
    return 'UpdateBreakoutRoomFlagStatusRequest(discussionPath: $discussionPath, breakoutSessionId: $breakoutSessionId, roomId: $roomId, flagStatus: $flagStatus)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_UpdateBreakoutRoomFlagStatusRequest &&
            (identical(other.discussionPath, discussionPath) ||
                other.discussionPath == discussionPath) &&
            (identical(other.breakoutSessionId, breakoutSessionId) ||
                other.breakoutSessionId == breakoutSessionId) &&
            (identical(other.roomId, roomId) || other.roomId == roomId) &&
            (identical(other.flagStatus, flagStatus) ||
                other.flagStatus == flagStatus));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType, discussionPath, breakoutSessionId, roomId, flagStatus);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_UpdateBreakoutRoomFlagStatusRequestCopyWith<
          _$_UpdateBreakoutRoomFlagStatusRequest>
      get copyWith => __$$_UpdateBreakoutRoomFlagStatusRequestCopyWithImpl<
          _$_UpdateBreakoutRoomFlagStatusRequest>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_UpdateBreakoutRoomFlagStatusRequestToJson(
      this,
    );
  }
}

abstract class _UpdateBreakoutRoomFlagStatusRequest
    implements UpdateBreakoutRoomFlagStatusRequest {
  factory _UpdateBreakoutRoomFlagStatusRequest(
          {required final String discussionPath,
          required final String breakoutSessionId,
          required final String roomId,
          @JsonKey(unknownEnumValue: null)
          final BreakoutRoomFlagStatus? flagStatus}) =
      _$_UpdateBreakoutRoomFlagStatusRequest;

  factory _UpdateBreakoutRoomFlagStatusRequest.fromJson(
          Map<String, dynamic> json) =
      _$_UpdateBreakoutRoomFlagStatusRequest.fromJson;

  @override
  String get discussionPath;
  @override
  String get breakoutSessionId;
  @override
  String get roomId;
  @override
  @JsonKey(unknownEnumValue: null)
  BreakoutRoomFlagStatus? get flagStatus;
  @override
  @JsonKey(ignore: true)
  _$$_UpdateBreakoutRoomFlagStatusRequestCopyWith<
          _$_UpdateBreakoutRoomFlagStatusRequest>
      get copyWith => throw _privateConstructorUsedError;
}

CreateJuntoRequest _$CreateJuntoRequestFromJson(Map<String, dynamic> json) {
  return _CreateJuntoRequest.fromJson(json);
}

/// @nodoc
mixin _$CreateJuntoRequest {
  @JsonKey(toJson: Junto.toJsonForCloudFunction)
  Junto? get junto => throw _privateConstructorUsedError;
  String? get agreementId => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $CreateJuntoRequestCopyWith<CreateJuntoRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CreateJuntoRequestCopyWith<$Res> {
  factory $CreateJuntoRequestCopyWith(
          CreateJuntoRequest value, $Res Function(CreateJuntoRequest) then) =
      _$CreateJuntoRequestCopyWithImpl<$Res, CreateJuntoRequest>;
  @useResult
  $Res call(
      {@JsonKey(toJson: Junto.toJsonForCloudFunction) Junto? junto,
      String? agreementId});

  $JuntoCopyWith<$Res>? get junto;
}

/// @nodoc
class _$CreateJuntoRequestCopyWithImpl<$Res, $Val extends CreateJuntoRequest>
    implements $CreateJuntoRequestCopyWith<$Res> {
  _$CreateJuntoRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? junto = freezed,
    Object? agreementId = freezed,
  }) {
    return _then(_value.copyWith(
      junto: freezed == junto
          ? _value.junto
          : junto // ignore: cast_nullable_to_non_nullable
              as Junto?,
      agreementId: freezed == agreementId
          ? _value.agreementId
          : agreementId // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $JuntoCopyWith<$Res>? get junto {
    if (_value.junto == null) {
      return null;
    }

    return $JuntoCopyWith<$Res>(_value.junto!, (value) {
      return _then(_value.copyWith(junto: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$_CreateJuntoRequestCopyWith<$Res>
    implements $CreateJuntoRequestCopyWith<$Res> {
  factory _$$_CreateJuntoRequestCopyWith(_$_CreateJuntoRequest value,
          $Res Function(_$_CreateJuntoRequest) then) =
      __$$_CreateJuntoRequestCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(toJson: Junto.toJsonForCloudFunction) Junto? junto,
      String? agreementId});

  @override
  $JuntoCopyWith<$Res>? get junto;
}

/// @nodoc
class __$$_CreateJuntoRequestCopyWithImpl<$Res>
    extends _$CreateJuntoRequestCopyWithImpl<$Res, _$_CreateJuntoRequest>
    implements _$$_CreateJuntoRequestCopyWith<$Res> {
  __$$_CreateJuntoRequestCopyWithImpl(
      _$_CreateJuntoRequest _value, $Res Function(_$_CreateJuntoRequest) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? junto = freezed,
    Object? agreementId = freezed,
  }) {
    return _then(_$_CreateJuntoRequest(
      junto: freezed == junto
          ? _value.junto
          : junto // ignore: cast_nullable_to_non_nullable
              as Junto?,
      agreementId: freezed == agreementId
          ? _value.agreementId
          : agreementId // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_CreateJuntoRequest implements _CreateJuntoRequest {
  _$_CreateJuntoRequest(
      {@JsonKey(toJson: Junto.toJsonForCloudFunction) this.junto,
      this.agreementId});

  factory _$_CreateJuntoRequest.fromJson(Map<String, dynamic> json) =>
      _$$_CreateJuntoRequestFromJson(json);

  @override
  @JsonKey(toJson: Junto.toJsonForCloudFunction)
  final Junto? junto;
  @override
  final String? agreementId;

  @override
  String toString() {
    return 'CreateJuntoRequest(junto: $junto, agreementId: $agreementId)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_CreateJuntoRequest &&
            (identical(other.junto, junto) || other.junto == junto) &&
            (identical(other.agreementId, agreementId) ||
                other.agreementId == agreementId));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, junto, agreementId);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_CreateJuntoRequestCopyWith<_$_CreateJuntoRequest> get copyWith =>
      __$$_CreateJuntoRequestCopyWithImpl<_$_CreateJuntoRequest>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_CreateJuntoRequestToJson(
      this,
    );
  }
}

abstract class _CreateJuntoRequest implements CreateJuntoRequest {
  factory _CreateJuntoRequest(
      {@JsonKey(toJson: Junto.toJsonForCloudFunction) final Junto? junto,
      final String? agreementId}) = _$_CreateJuntoRequest;

  factory _CreateJuntoRequest.fromJson(Map<String, dynamic> json) =
      _$_CreateJuntoRequest.fromJson;

  @override
  @JsonKey(toJson: Junto.toJsonForCloudFunction)
  Junto? get junto;
  @override
  String? get agreementId;
  @override
  @JsonKey(ignore: true)
  _$$_CreateJuntoRequestCopyWith<_$_CreateJuntoRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

CreateJuntoResponse _$CreateJuntoResponseFromJson(Map<String, dynamic> json) {
  return _CreateJuntoResponse.fromJson(json);
}

/// @nodoc
mixin _$CreateJuntoResponse {
  String get juntoId => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $CreateJuntoResponseCopyWith<CreateJuntoResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CreateJuntoResponseCopyWith<$Res> {
  factory $CreateJuntoResponseCopyWith(
          CreateJuntoResponse value, $Res Function(CreateJuntoResponse) then) =
      _$CreateJuntoResponseCopyWithImpl<$Res, CreateJuntoResponse>;
  @useResult
  $Res call({String juntoId});
}

/// @nodoc
class _$CreateJuntoResponseCopyWithImpl<$Res, $Val extends CreateJuntoResponse>
    implements $CreateJuntoResponseCopyWith<$Res> {
  _$CreateJuntoResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? juntoId = null,
  }) {
    return _then(_value.copyWith(
      juntoId: null == juntoId
          ? _value.juntoId
          : juntoId // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_CreateJuntoResponseCopyWith<$Res>
    implements $CreateJuntoResponseCopyWith<$Res> {
  factory _$$_CreateJuntoResponseCopyWith(_$_CreateJuntoResponse value,
          $Res Function(_$_CreateJuntoResponse) then) =
      __$$_CreateJuntoResponseCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String juntoId});
}

/// @nodoc
class __$$_CreateJuntoResponseCopyWithImpl<$Res>
    extends _$CreateJuntoResponseCopyWithImpl<$Res, _$_CreateJuntoResponse>
    implements _$$_CreateJuntoResponseCopyWith<$Res> {
  __$$_CreateJuntoResponseCopyWithImpl(_$_CreateJuntoResponse _value,
      $Res Function(_$_CreateJuntoResponse) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? juntoId = null,
  }) {
    return _then(_$_CreateJuntoResponse(
      juntoId: null == juntoId
          ? _value.juntoId
          : juntoId // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_CreateJuntoResponse implements _CreateJuntoResponse {
  _$_CreateJuntoResponse({required this.juntoId});

  factory _$_CreateJuntoResponse.fromJson(Map<String, dynamic> json) =>
      _$$_CreateJuntoResponseFromJson(json);

  @override
  final String juntoId;

  @override
  String toString() {
    return 'CreateJuntoResponse(juntoId: $juntoId)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_CreateJuntoResponse &&
            (identical(other.juntoId, juntoId) || other.juntoId == juntoId));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, juntoId);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_CreateJuntoResponseCopyWith<_$_CreateJuntoResponse> get copyWith =>
      __$$_CreateJuntoResponseCopyWithImpl<_$_CreateJuntoResponse>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_CreateJuntoResponseToJson(
      this,
    );
  }
}

abstract class _CreateJuntoResponse implements CreateJuntoResponse {
  factory _CreateJuntoResponse({required final String juntoId}) =
      _$_CreateJuntoResponse;

  factory _CreateJuntoResponse.fromJson(Map<String, dynamic> json) =
      _$_CreateJuntoResponse.fromJson;

  @override
  String get juntoId;
  @override
  @JsonKey(ignore: true)
  _$$_CreateJuntoResponseCopyWith<_$_CreateJuntoResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

UpdateJuntoRequest _$UpdateJuntoRequestFromJson(Map<String, dynamic> json) {
  return _UpdateJuntoRequest.fromJson(json);
}

/// @nodoc
mixin _$UpdateJuntoRequest {
  @JsonKey(toJson: Junto.toJsonForCloudFunction)
  Junto get junto => throw _privateConstructorUsedError;
  List<String> get keys => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $UpdateJuntoRequestCopyWith<UpdateJuntoRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UpdateJuntoRequestCopyWith<$Res> {
  factory $UpdateJuntoRequestCopyWith(
          UpdateJuntoRequest value, $Res Function(UpdateJuntoRequest) then) =
      _$UpdateJuntoRequestCopyWithImpl<$Res, UpdateJuntoRequest>;
  @useResult
  $Res call(
      {@JsonKey(toJson: Junto.toJsonForCloudFunction) Junto junto,
      List<String> keys});

  $JuntoCopyWith<$Res> get junto;
}

/// @nodoc
class _$UpdateJuntoRequestCopyWithImpl<$Res, $Val extends UpdateJuntoRequest>
    implements $UpdateJuntoRequestCopyWith<$Res> {
  _$UpdateJuntoRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? junto = null,
    Object? keys = null,
  }) {
    return _then(_value.copyWith(
      junto: null == junto
          ? _value.junto
          : junto // ignore: cast_nullable_to_non_nullable
              as Junto,
      keys: null == keys
          ? _value.keys
          : keys // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $JuntoCopyWith<$Res> get junto {
    return $JuntoCopyWith<$Res>(_value.junto, (value) {
      return _then(_value.copyWith(junto: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$_UpdateJuntoRequestCopyWith<$Res>
    implements $UpdateJuntoRequestCopyWith<$Res> {
  factory _$$_UpdateJuntoRequestCopyWith(_$_UpdateJuntoRequest value,
          $Res Function(_$_UpdateJuntoRequest) then) =
      __$$_UpdateJuntoRequestCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(toJson: Junto.toJsonForCloudFunction) Junto junto,
      List<String> keys});

  @override
  $JuntoCopyWith<$Res> get junto;
}

/// @nodoc
class __$$_UpdateJuntoRequestCopyWithImpl<$Res>
    extends _$UpdateJuntoRequestCopyWithImpl<$Res, _$_UpdateJuntoRequest>
    implements _$$_UpdateJuntoRequestCopyWith<$Res> {
  __$$_UpdateJuntoRequestCopyWithImpl(
      _$_UpdateJuntoRequest _value, $Res Function(_$_UpdateJuntoRequest) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? junto = null,
    Object? keys = null,
  }) {
    return _then(_$_UpdateJuntoRequest(
      junto: null == junto
          ? _value.junto
          : junto // ignore: cast_nullable_to_non_nullable
              as Junto,
      keys: null == keys
          ? _value.keys
          : keys // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_UpdateJuntoRequest implements _UpdateJuntoRequest {
  _$_UpdateJuntoRequest(
      {@JsonKey(toJson: Junto.toJsonForCloudFunction) required this.junto,
      required this.keys});

  factory _$_UpdateJuntoRequest.fromJson(Map<String, dynamic> json) =>
      _$$_UpdateJuntoRequestFromJson(json);

  @override
  @JsonKey(toJson: Junto.toJsonForCloudFunction)
  final Junto junto;
  @override
  final List<String> keys;

  @override
  String toString() {
    return 'UpdateJuntoRequest(junto: $junto, keys: $keys)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_UpdateJuntoRequest &&
            (identical(other.junto, junto) || other.junto == junto) &&
            const DeepCollectionEquality().equals(other.keys, keys));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType, junto, const DeepCollectionEquality().hash(keys));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_UpdateJuntoRequestCopyWith<_$_UpdateJuntoRequest> get copyWith =>
      __$$_UpdateJuntoRequestCopyWithImpl<_$_UpdateJuntoRequest>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_UpdateJuntoRequestToJson(
      this,
    );
  }
}

abstract class _UpdateJuntoRequest implements UpdateJuntoRequest {
  factory _UpdateJuntoRequest(
      {@JsonKey(toJson: Junto.toJsonForCloudFunction)
      required final Junto junto,
      required final List<String> keys}) = _$_UpdateJuntoRequest;

  factory _UpdateJuntoRequest.fromJson(Map<String, dynamic> json) =
      _$_UpdateJuntoRequest.fromJson;

  @override
  @JsonKey(toJson: Junto.toJsonForCloudFunction)
  Junto get junto;
  @override
  List<String> get keys;
  @override
  @JsonKey(ignore: true)
  _$$_UpdateJuntoRequestCopyWith<_$_UpdateJuntoRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

GetJuntoCapabilitiesRequest _$GetJuntoCapabilitiesRequestFromJson(
    Map<String, dynamic> json) {
  return _GetJuntoCapabilitiesRequest.fromJson(json);
}

/// @nodoc
mixin _$GetJuntoCapabilitiesRequest {
  String get juntoId => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $GetJuntoCapabilitiesRequestCopyWith<GetJuntoCapabilitiesRequest>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GetJuntoCapabilitiesRequestCopyWith<$Res> {
  factory $GetJuntoCapabilitiesRequestCopyWith(
          GetJuntoCapabilitiesRequest value,
          $Res Function(GetJuntoCapabilitiesRequest) then) =
      _$GetJuntoCapabilitiesRequestCopyWithImpl<$Res,
          GetJuntoCapabilitiesRequest>;
  @useResult
  $Res call({String juntoId});
}

/// @nodoc
class _$GetJuntoCapabilitiesRequestCopyWithImpl<$Res,
        $Val extends GetJuntoCapabilitiesRequest>
    implements $GetJuntoCapabilitiesRequestCopyWith<$Res> {
  _$GetJuntoCapabilitiesRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? juntoId = null,
  }) {
    return _then(_value.copyWith(
      juntoId: null == juntoId
          ? _value.juntoId
          : juntoId // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_GetJuntoCapabilitiesRequestCopyWith<$Res>
    implements $GetJuntoCapabilitiesRequestCopyWith<$Res> {
  factory _$$_GetJuntoCapabilitiesRequestCopyWith(
          _$_GetJuntoCapabilitiesRequest value,
          $Res Function(_$_GetJuntoCapabilitiesRequest) then) =
      __$$_GetJuntoCapabilitiesRequestCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String juntoId});
}

/// @nodoc
class __$$_GetJuntoCapabilitiesRequestCopyWithImpl<$Res>
    extends _$GetJuntoCapabilitiesRequestCopyWithImpl<$Res,
        _$_GetJuntoCapabilitiesRequest>
    implements _$$_GetJuntoCapabilitiesRequestCopyWith<$Res> {
  __$$_GetJuntoCapabilitiesRequestCopyWithImpl(
      _$_GetJuntoCapabilitiesRequest _value,
      $Res Function(_$_GetJuntoCapabilitiesRequest) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? juntoId = null,
  }) {
    return _then(_$_GetJuntoCapabilitiesRequest(
      juntoId: null == juntoId
          ? _value.juntoId
          : juntoId // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_GetJuntoCapabilitiesRequest implements _GetJuntoCapabilitiesRequest {
  _$_GetJuntoCapabilitiesRequest({required this.juntoId});

  factory _$_GetJuntoCapabilitiesRequest.fromJson(Map<String, dynamic> json) =>
      _$$_GetJuntoCapabilitiesRequestFromJson(json);

  @override
  final String juntoId;

  @override
  String toString() {
    return 'GetJuntoCapabilitiesRequest(juntoId: $juntoId)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_GetJuntoCapabilitiesRequest &&
            (identical(other.juntoId, juntoId) || other.juntoId == juntoId));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, juntoId);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_GetJuntoCapabilitiesRequestCopyWith<_$_GetJuntoCapabilitiesRequest>
      get copyWith => __$$_GetJuntoCapabilitiesRequestCopyWithImpl<
          _$_GetJuntoCapabilitiesRequest>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_GetJuntoCapabilitiesRequestToJson(
      this,
    );
  }
}

abstract class _GetJuntoCapabilitiesRequest
    implements GetJuntoCapabilitiesRequest {
  factory _GetJuntoCapabilitiesRequest({required final String juntoId}) =
      _$_GetJuntoCapabilitiesRequest;

  factory _GetJuntoCapabilitiesRequest.fromJson(Map<String, dynamic> json) =
      _$_GetJuntoCapabilitiesRequest.fromJson;

  @override
  String get juntoId;
  @override
  @JsonKey(ignore: true)
  _$$_GetJuntoCapabilitiesRequestCopyWith<_$_GetJuntoCapabilitiesRequest>
      get copyWith => throw _privateConstructorUsedError;
}

GetStripeBillingPortalLinkRequest _$GetStripeBillingPortalLinkRequestFromJson(
    Map<String, dynamic> json) {
  return _GetStripeBillingPortalLinkRequest.fromJson(json);
}

/// @nodoc
mixin _$GetStripeBillingPortalLinkRequest {
  String get responsePath => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $GetStripeBillingPortalLinkRequestCopyWith<GetStripeBillingPortalLinkRequest>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GetStripeBillingPortalLinkRequestCopyWith<$Res> {
  factory $GetStripeBillingPortalLinkRequestCopyWith(
          GetStripeBillingPortalLinkRequest value,
          $Res Function(GetStripeBillingPortalLinkRequest) then) =
      _$GetStripeBillingPortalLinkRequestCopyWithImpl<$Res,
          GetStripeBillingPortalLinkRequest>;
  @useResult
  $Res call({String responsePath});
}

/// @nodoc
class _$GetStripeBillingPortalLinkRequestCopyWithImpl<$Res,
        $Val extends GetStripeBillingPortalLinkRequest>
    implements $GetStripeBillingPortalLinkRequestCopyWith<$Res> {
  _$GetStripeBillingPortalLinkRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? responsePath = null,
  }) {
    return _then(_value.copyWith(
      responsePath: null == responsePath
          ? _value.responsePath
          : responsePath // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_GetStripeBillingPortalLinkRequestCopyWith<$Res>
    implements $GetStripeBillingPortalLinkRequestCopyWith<$Res> {
  factory _$$_GetStripeBillingPortalLinkRequestCopyWith(
          _$_GetStripeBillingPortalLinkRequest value,
          $Res Function(_$_GetStripeBillingPortalLinkRequest) then) =
      __$$_GetStripeBillingPortalLinkRequestCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String responsePath});
}

/// @nodoc
class __$$_GetStripeBillingPortalLinkRequestCopyWithImpl<$Res>
    extends _$GetStripeBillingPortalLinkRequestCopyWithImpl<$Res,
        _$_GetStripeBillingPortalLinkRequest>
    implements _$$_GetStripeBillingPortalLinkRequestCopyWith<$Res> {
  __$$_GetStripeBillingPortalLinkRequestCopyWithImpl(
      _$_GetStripeBillingPortalLinkRequest _value,
      $Res Function(_$_GetStripeBillingPortalLinkRequest) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? responsePath = null,
  }) {
    return _then(_$_GetStripeBillingPortalLinkRequest(
      responsePath: null == responsePath
          ? _value.responsePath
          : responsePath // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_GetStripeBillingPortalLinkRequest
    implements _GetStripeBillingPortalLinkRequest {
  _$_GetStripeBillingPortalLinkRequest({required this.responsePath});

  factory _$_GetStripeBillingPortalLinkRequest.fromJson(
          Map<String, dynamic> json) =>
      _$$_GetStripeBillingPortalLinkRequestFromJson(json);

  @override
  final String responsePath;

  @override
  String toString() {
    return 'GetStripeBillingPortalLinkRequest(responsePath: $responsePath)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_GetStripeBillingPortalLinkRequest &&
            (identical(other.responsePath, responsePath) ||
                other.responsePath == responsePath));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, responsePath);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_GetStripeBillingPortalLinkRequestCopyWith<
          _$_GetStripeBillingPortalLinkRequest>
      get copyWith => __$$_GetStripeBillingPortalLinkRequestCopyWithImpl<
          _$_GetStripeBillingPortalLinkRequest>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_GetStripeBillingPortalLinkRequestToJson(
      this,
    );
  }
}

abstract class _GetStripeBillingPortalLinkRequest
    implements GetStripeBillingPortalLinkRequest {
  factory _GetStripeBillingPortalLinkRequest(
          {required final String responsePath}) =
      _$_GetStripeBillingPortalLinkRequest;

  factory _GetStripeBillingPortalLinkRequest.fromJson(
          Map<String, dynamic> json) =
      _$_GetStripeBillingPortalLinkRequest.fromJson;

  @override
  String get responsePath;
  @override
  @JsonKey(ignore: true)
  _$$_GetStripeBillingPortalLinkRequestCopyWith<
          _$_GetStripeBillingPortalLinkRequest>
      get copyWith => throw _privateConstructorUsedError;
}

GetStripeBillingPortalLinkResponse _$GetStripeBillingPortalLinkResponseFromJson(
    Map<String, dynamic> json) {
  return _GetStripeBillingPortalLinkResponse.fromJson(json);
}

/// @nodoc
mixin _$GetStripeBillingPortalLinkResponse {
  String get url => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $GetStripeBillingPortalLinkResponseCopyWith<
          GetStripeBillingPortalLinkResponse>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GetStripeBillingPortalLinkResponseCopyWith<$Res> {
  factory $GetStripeBillingPortalLinkResponseCopyWith(
          GetStripeBillingPortalLinkResponse value,
          $Res Function(GetStripeBillingPortalLinkResponse) then) =
      _$GetStripeBillingPortalLinkResponseCopyWithImpl<$Res,
          GetStripeBillingPortalLinkResponse>;
  @useResult
  $Res call({String url});
}

/// @nodoc
class _$GetStripeBillingPortalLinkResponseCopyWithImpl<$Res,
        $Val extends GetStripeBillingPortalLinkResponse>
    implements $GetStripeBillingPortalLinkResponseCopyWith<$Res> {
  _$GetStripeBillingPortalLinkResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? url = null,
  }) {
    return _then(_value.copyWith(
      url: null == url
          ? _value.url
          : url // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_GetStripeBillingPortalLinkResponseCopyWith<$Res>
    implements $GetStripeBillingPortalLinkResponseCopyWith<$Res> {
  factory _$$_GetStripeBillingPortalLinkResponseCopyWith(
          _$_GetStripeBillingPortalLinkResponse value,
          $Res Function(_$_GetStripeBillingPortalLinkResponse) then) =
      __$$_GetStripeBillingPortalLinkResponseCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String url});
}

/// @nodoc
class __$$_GetStripeBillingPortalLinkResponseCopyWithImpl<$Res>
    extends _$GetStripeBillingPortalLinkResponseCopyWithImpl<$Res,
        _$_GetStripeBillingPortalLinkResponse>
    implements _$$_GetStripeBillingPortalLinkResponseCopyWith<$Res> {
  __$$_GetStripeBillingPortalLinkResponseCopyWithImpl(
      _$_GetStripeBillingPortalLinkResponse _value,
      $Res Function(_$_GetStripeBillingPortalLinkResponse) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? url = null,
  }) {
    return _then(_$_GetStripeBillingPortalLinkResponse(
      url: null == url
          ? _value.url
          : url // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_GetStripeBillingPortalLinkResponse
    implements _GetStripeBillingPortalLinkResponse {
  _$_GetStripeBillingPortalLinkResponse({required this.url});

  factory _$_GetStripeBillingPortalLinkResponse.fromJson(
          Map<String, dynamic> json) =>
      _$$_GetStripeBillingPortalLinkResponseFromJson(json);

  @override
  final String url;

  @override
  String toString() {
    return 'GetStripeBillingPortalLinkResponse(url: $url)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_GetStripeBillingPortalLinkResponse &&
            (identical(other.url, url) || other.url == url));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, url);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_GetStripeBillingPortalLinkResponseCopyWith<
          _$_GetStripeBillingPortalLinkResponse>
      get copyWith => __$$_GetStripeBillingPortalLinkResponseCopyWithImpl<
          _$_GetStripeBillingPortalLinkResponse>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_GetStripeBillingPortalLinkResponseToJson(
      this,
    );
  }
}

abstract class _GetStripeBillingPortalLinkResponse
    implements GetStripeBillingPortalLinkResponse {
  factory _GetStripeBillingPortalLinkResponse({required final String url}) =
      _$_GetStripeBillingPortalLinkResponse;

  factory _GetStripeBillingPortalLinkResponse.fromJson(
          Map<String, dynamic> json) =
      _$_GetStripeBillingPortalLinkResponse.fromJson;

  @override
  String get url;
  @override
  @JsonKey(ignore: true)
  _$$_GetStripeBillingPortalLinkResponseCopyWith<
          _$_GetStripeBillingPortalLinkResponse>
      get copyWith => throw _privateConstructorUsedError;
}

GetStripeConnectedAccountLinkRequest
    _$GetStripeConnectedAccountLinkRequestFromJson(Map<String, dynamic> json) {
  return _GetStripeConnectedAccountLinkRequest.fromJson(json);
}

/// @nodoc
mixin _$GetStripeConnectedAccountLinkRequest {
  String get agreementId => throw _privateConstructorUsedError;
  String get responsePath => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $GetStripeConnectedAccountLinkRequestCopyWith<
          GetStripeConnectedAccountLinkRequest>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GetStripeConnectedAccountLinkRequestCopyWith<$Res> {
  factory $GetStripeConnectedAccountLinkRequestCopyWith(
          GetStripeConnectedAccountLinkRequest value,
          $Res Function(GetStripeConnectedAccountLinkRequest) then) =
      _$GetStripeConnectedAccountLinkRequestCopyWithImpl<$Res,
          GetStripeConnectedAccountLinkRequest>;
  @useResult
  $Res call({String agreementId, String responsePath});
}

/// @nodoc
class _$GetStripeConnectedAccountLinkRequestCopyWithImpl<$Res,
        $Val extends GetStripeConnectedAccountLinkRequest>
    implements $GetStripeConnectedAccountLinkRequestCopyWith<$Res> {
  _$GetStripeConnectedAccountLinkRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? agreementId = null,
    Object? responsePath = null,
  }) {
    return _then(_value.copyWith(
      agreementId: null == agreementId
          ? _value.agreementId
          : agreementId // ignore: cast_nullable_to_non_nullable
              as String,
      responsePath: null == responsePath
          ? _value.responsePath
          : responsePath // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_GetStripeConnectedAccountLinkRequestCopyWith<$Res>
    implements $GetStripeConnectedAccountLinkRequestCopyWith<$Res> {
  factory _$$_GetStripeConnectedAccountLinkRequestCopyWith(
          _$_GetStripeConnectedAccountLinkRequest value,
          $Res Function(_$_GetStripeConnectedAccountLinkRequest) then) =
      __$$_GetStripeConnectedAccountLinkRequestCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String agreementId, String responsePath});
}

/// @nodoc
class __$$_GetStripeConnectedAccountLinkRequestCopyWithImpl<$Res>
    extends _$GetStripeConnectedAccountLinkRequestCopyWithImpl<$Res,
        _$_GetStripeConnectedAccountLinkRequest>
    implements _$$_GetStripeConnectedAccountLinkRequestCopyWith<$Res> {
  __$$_GetStripeConnectedAccountLinkRequestCopyWithImpl(
      _$_GetStripeConnectedAccountLinkRequest _value,
      $Res Function(_$_GetStripeConnectedAccountLinkRequest) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? agreementId = null,
    Object? responsePath = null,
  }) {
    return _then(_$_GetStripeConnectedAccountLinkRequest(
      agreementId: null == agreementId
          ? _value.agreementId
          : agreementId // ignore: cast_nullable_to_non_nullable
              as String,
      responsePath: null == responsePath
          ? _value.responsePath
          : responsePath // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_GetStripeConnectedAccountLinkRequest
    implements _GetStripeConnectedAccountLinkRequest {
  _$_GetStripeConnectedAccountLinkRequest(
      {required this.agreementId, required this.responsePath});

  factory _$_GetStripeConnectedAccountLinkRequest.fromJson(
          Map<String, dynamic> json) =>
      _$$_GetStripeConnectedAccountLinkRequestFromJson(json);

  @override
  final String agreementId;
  @override
  final String responsePath;

  @override
  String toString() {
    return 'GetStripeConnectedAccountLinkRequest(agreementId: $agreementId, responsePath: $responsePath)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_GetStripeConnectedAccountLinkRequest &&
            (identical(other.agreementId, agreementId) ||
                other.agreementId == agreementId) &&
            (identical(other.responsePath, responsePath) ||
                other.responsePath == responsePath));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, agreementId, responsePath);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_GetStripeConnectedAccountLinkRequestCopyWith<
          _$_GetStripeConnectedAccountLinkRequest>
      get copyWith => __$$_GetStripeConnectedAccountLinkRequestCopyWithImpl<
          _$_GetStripeConnectedAccountLinkRequest>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_GetStripeConnectedAccountLinkRequestToJson(
      this,
    );
  }
}

abstract class _GetStripeConnectedAccountLinkRequest
    implements GetStripeConnectedAccountLinkRequest {
  factory _GetStripeConnectedAccountLinkRequest(
          {required final String agreementId,
          required final String responsePath}) =
      _$_GetStripeConnectedAccountLinkRequest;

  factory _GetStripeConnectedAccountLinkRequest.fromJson(
          Map<String, dynamic> json) =
      _$_GetStripeConnectedAccountLinkRequest.fromJson;

  @override
  String get agreementId;
  @override
  String get responsePath;
  @override
  @JsonKey(ignore: true)
  _$$_GetStripeConnectedAccountLinkRequestCopyWith<
          _$_GetStripeConnectedAccountLinkRequest>
      get copyWith => throw _privateConstructorUsedError;
}

GetStripeConnectedAccountLinkResponse
    _$GetStripeConnectedAccountLinkResponseFromJson(Map<String, dynamic> json) {
  return _GetStripeConnectedAccountLinkResponse.fromJson(json);
}

/// @nodoc
mixin _$GetStripeConnectedAccountLinkResponse {
  String get url => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $GetStripeConnectedAccountLinkResponseCopyWith<
          GetStripeConnectedAccountLinkResponse>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GetStripeConnectedAccountLinkResponseCopyWith<$Res> {
  factory $GetStripeConnectedAccountLinkResponseCopyWith(
          GetStripeConnectedAccountLinkResponse value,
          $Res Function(GetStripeConnectedAccountLinkResponse) then) =
      _$GetStripeConnectedAccountLinkResponseCopyWithImpl<$Res,
          GetStripeConnectedAccountLinkResponse>;
  @useResult
  $Res call({String url});
}

/// @nodoc
class _$GetStripeConnectedAccountLinkResponseCopyWithImpl<$Res,
        $Val extends GetStripeConnectedAccountLinkResponse>
    implements $GetStripeConnectedAccountLinkResponseCopyWith<$Res> {
  _$GetStripeConnectedAccountLinkResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? url = null,
  }) {
    return _then(_value.copyWith(
      url: null == url
          ? _value.url
          : url // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_GetStripeConnectedAccountLinkResponseCopyWith<$Res>
    implements $GetStripeConnectedAccountLinkResponseCopyWith<$Res> {
  factory _$$_GetStripeConnectedAccountLinkResponseCopyWith(
          _$_GetStripeConnectedAccountLinkResponse value,
          $Res Function(_$_GetStripeConnectedAccountLinkResponse) then) =
      __$$_GetStripeConnectedAccountLinkResponseCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String url});
}

/// @nodoc
class __$$_GetStripeConnectedAccountLinkResponseCopyWithImpl<$Res>
    extends _$GetStripeConnectedAccountLinkResponseCopyWithImpl<$Res,
        _$_GetStripeConnectedAccountLinkResponse>
    implements _$$_GetStripeConnectedAccountLinkResponseCopyWith<$Res> {
  __$$_GetStripeConnectedAccountLinkResponseCopyWithImpl(
      _$_GetStripeConnectedAccountLinkResponse _value,
      $Res Function(_$_GetStripeConnectedAccountLinkResponse) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? url = null,
  }) {
    return _then(_$_GetStripeConnectedAccountLinkResponse(
      url: null == url
          ? _value.url
          : url // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_GetStripeConnectedAccountLinkResponse
    implements _GetStripeConnectedAccountLinkResponse {
  _$_GetStripeConnectedAccountLinkResponse({required this.url});

  factory _$_GetStripeConnectedAccountLinkResponse.fromJson(
          Map<String, dynamic> json) =>
      _$$_GetStripeConnectedAccountLinkResponseFromJson(json);

  @override
  final String url;

  @override
  String toString() {
    return 'GetStripeConnectedAccountLinkResponse(url: $url)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_GetStripeConnectedAccountLinkResponse &&
            (identical(other.url, url) || other.url == url));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, url);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_GetStripeConnectedAccountLinkResponseCopyWith<
          _$_GetStripeConnectedAccountLinkResponse>
      get copyWith => __$$_GetStripeConnectedAccountLinkResponseCopyWithImpl<
          _$_GetStripeConnectedAccountLinkResponse>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_GetStripeConnectedAccountLinkResponseToJson(
      this,
    );
  }
}

abstract class _GetStripeConnectedAccountLinkResponse
    implements GetStripeConnectedAccountLinkResponse {
  factory _GetStripeConnectedAccountLinkResponse({required final String url}) =
      _$_GetStripeConnectedAccountLinkResponse;

  factory _GetStripeConnectedAccountLinkResponse.fromJson(
          Map<String, dynamic> json) =
      _$_GetStripeConnectedAccountLinkResponse.fromJson;

  @override
  String get url;
  @override
  @JsonKey(ignore: true)
  _$$_GetStripeConnectedAccountLinkResponseCopyWith<
          _$_GetStripeConnectedAccountLinkResponse>
      get copyWith => throw _privateConstructorUsedError;
}

UnsubscribeFromJuntoNotificationsRequest
    _$UnsubscribeFromJuntoNotificationsRequestFromJson(
        Map<String, dynamic> json) {
  return _UnsubscribeFromJuntoNotificationsRequest.fromJson(json);
}

/// @nodoc
mixin _$UnsubscribeFromJuntoNotificationsRequest {
  String get data => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $UnsubscribeFromJuntoNotificationsRequestCopyWith<
          UnsubscribeFromJuntoNotificationsRequest>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UnsubscribeFromJuntoNotificationsRequestCopyWith<$Res> {
  factory $UnsubscribeFromJuntoNotificationsRequestCopyWith(
          UnsubscribeFromJuntoNotificationsRequest value,
          $Res Function(UnsubscribeFromJuntoNotificationsRequest) then) =
      _$UnsubscribeFromJuntoNotificationsRequestCopyWithImpl<$Res,
          UnsubscribeFromJuntoNotificationsRequest>;
  @useResult
  $Res call({String data});
}

/// @nodoc
class _$UnsubscribeFromJuntoNotificationsRequestCopyWithImpl<$Res,
        $Val extends UnsubscribeFromJuntoNotificationsRequest>
    implements $UnsubscribeFromJuntoNotificationsRequestCopyWith<$Res> {
  _$UnsubscribeFromJuntoNotificationsRequestCopyWithImpl(
      this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? data = null,
  }) {
    return _then(_value.copyWith(
      data: null == data
          ? _value.data
          : data // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_UnsubscribeFromJuntoNotificationsRequestCopyWith<$Res>
    implements $UnsubscribeFromJuntoNotificationsRequestCopyWith<$Res> {
  factory _$$_UnsubscribeFromJuntoNotificationsRequestCopyWith(
          _$_UnsubscribeFromJuntoNotificationsRequest value,
          $Res Function(_$_UnsubscribeFromJuntoNotificationsRequest) then) =
      __$$_UnsubscribeFromJuntoNotificationsRequestCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String data});
}

/// @nodoc
class __$$_UnsubscribeFromJuntoNotificationsRequestCopyWithImpl<$Res>
    extends _$UnsubscribeFromJuntoNotificationsRequestCopyWithImpl<$Res,
        _$_UnsubscribeFromJuntoNotificationsRequest>
    implements _$$_UnsubscribeFromJuntoNotificationsRequestCopyWith<$Res> {
  __$$_UnsubscribeFromJuntoNotificationsRequestCopyWithImpl(
      _$_UnsubscribeFromJuntoNotificationsRequest _value,
      $Res Function(_$_UnsubscribeFromJuntoNotificationsRequest) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? data = null,
  }) {
    return _then(_$_UnsubscribeFromJuntoNotificationsRequest(
      data: null == data
          ? _value.data
          : data // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_UnsubscribeFromJuntoNotificationsRequest
    implements _UnsubscribeFromJuntoNotificationsRequest {
  _$_UnsubscribeFromJuntoNotificationsRequest({required this.data});

  factory _$_UnsubscribeFromJuntoNotificationsRequest.fromJson(
          Map<String, dynamic> json) =>
      _$$_UnsubscribeFromJuntoNotificationsRequestFromJson(json);

  @override
  final String data;

  @override
  String toString() {
    return 'UnsubscribeFromJuntoNotificationsRequest(data: $data)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_UnsubscribeFromJuntoNotificationsRequest &&
            (identical(other.data, data) || other.data == data));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, data);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_UnsubscribeFromJuntoNotificationsRequestCopyWith<
          _$_UnsubscribeFromJuntoNotificationsRequest>
      get copyWith => __$$_UnsubscribeFromJuntoNotificationsRequestCopyWithImpl<
          _$_UnsubscribeFromJuntoNotificationsRequest>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_UnsubscribeFromJuntoNotificationsRequestToJson(
      this,
    );
  }
}

abstract class _UnsubscribeFromJuntoNotificationsRequest
    implements UnsubscribeFromJuntoNotificationsRequest {
  factory _UnsubscribeFromJuntoNotificationsRequest(
          {required final String data}) =
      _$_UnsubscribeFromJuntoNotificationsRequest;

  factory _UnsubscribeFromJuntoNotificationsRequest.fromJson(
          Map<String, dynamic> json) =
      _$_UnsubscribeFromJuntoNotificationsRequest.fromJson;

  @override
  String get data;
  @override
  @JsonKey(ignore: true)
  _$$_UnsubscribeFromJuntoNotificationsRequestCopyWith<
          _$_UnsubscribeFromJuntoNotificationsRequest>
      get copyWith => throw _privateConstructorUsedError;
}

CheckAdvanceMeetingGuideRequest _$CheckAdvanceMeetingGuideRequestFromJson(
    Map<String, dynamic> json) {
  return _CheckAdvanceMeetingGuideRequest.fromJson(json);
}

/// @nodoc
mixin _$CheckAdvanceMeetingGuideRequest {
  String get discussionPath => throw _privateConstructorUsedError;
  String? get breakoutSessionId => throw _privateConstructorUsedError;
  String? get breakoutRoomId => throw _privateConstructorUsedError;
  List<String> get presentIds => throw _privateConstructorUsedError;
  String? get userReadyAgendaId => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $CheckAdvanceMeetingGuideRequestCopyWith<CheckAdvanceMeetingGuideRequest>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CheckAdvanceMeetingGuideRequestCopyWith<$Res> {
  factory $CheckAdvanceMeetingGuideRequestCopyWith(
          CheckAdvanceMeetingGuideRequest value,
          $Res Function(CheckAdvanceMeetingGuideRequest) then) =
      _$CheckAdvanceMeetingGuideRequestCopyWithImpl<$Res,
          CheckAdvanceMeetingGuideRequest>;
  @useResult
  $Res call(
      {String discussionPath,
      String? breakoutSessionId,
      String? breakoutRoomId,
      List<String> presentIds,
      String? userReadyAgendaId});
}

/// @nodoc
class _$CheckAdvanceMeetingGuideRequestCopyWithImpl<$Res,
        $Val extends CheckAdvanceMeetingGuideRequest>
    implements $CheckAdvanceMeetingGuideRequestCopyWith<$Res> {
  _$CheckAdvanceMeetingGuideRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? discussionPath = null,
    Object? breakoutSessionId = freezed,
    Object? breakoutRoomId = freezed,
    Object? presentIds = null,
    Object? userReadyAgendaId = freezed,
  }) {
    return _then(_value.copyWith(
      discussionPath: null == discussionPath
          ? _value.discussionPath
          : discussionPath // ignore: cast_nullable_to_non_nullable
              as String,
      breakoutSessionId: freezed == breakoutSessionId
          ? _value.breakoutSessionId
          : breakoutSessionId // ignore: cast_nullable_to_non_nullable
              as String?,
      breakoutRoomId: freezed == breakoutRoomId
          ? _value.breakoutRoomId
          : breakoutRoomId // ignore: cast_nullable_to_non_nullable
              as String?,
      presentIds: null == presentIds
          ? _value.presentIds
          : presentIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
      userReadyAgendaId: freezed == userReadyAgendaId
          ? _value.userReadyAgendaId
          : userReadyAgendaId // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_CheckAdvanceMeetingGuideRequestCopyWith<$Res>
    implements $CheckAdvanceMeetingGuideRequestCopyWith<$Res> {
  factory _$$_CheckAdvanceMeetingGuideRequestCopyWith(
          _$_CheckAdvanceMeetingGuideRequest value,
          $Res Function(_$_CheckAdvanceMeetingGuideRequest) then) =
      __$$_CheckAdvanceMeetingGuideRequestCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String discussionPath,
      String? breakoutSessionId,
      String? breakoutRoomId,
      List<String> presentIds,
      String? userReadyAgendaId});
}

/// @nodoc
class __$$_CheckAdvanceMeetingGuideRequestCopyWithImpl<$Res>
    extends _$CheckAdvanceMeetingGuideRequestCopyWithImpl<$Res,
        _$_CheckAdvanceMeetingGuideRequest>
    implements _$$_CheckAdvanceMeetingGuideRequestCopyWith<$Res> {
  __$$_CheckAdvanceMeetingGuideRequestCopyWithImpl(
      _$_CheckAdvanceMeetingGuideRequest _value,
      $Res Function(_$_CheckAdvanceMeetingGuideRequest) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? discussionPath = null,
    Object? breakoutSessionId = freezed,
    Object? breakoutRoomId = freezed,
    Object? presentIds = null,
    Object? userReadyAgendaId = freezed,
  }) {
    return _then(_$_CheckAdvanceMeetingGuideRequest(
      discussionPath: null == discussionPath
          ? _value.discussionPath
          : discussionPath // ignore: cast_nullable_to_non_nullable
              as String,
      breakoutSessionId: freezed == breakoutSessionId
          ? _value.breakoutSessionId
          : breakoutSessionId // ignore: cast_nullable_to_non_nullable
              as String?,
      breakoutRoomId: freezed == breakoutRoomId
          ? _value.breakoutRoomId
          : breakoutRoomId // ignore: cast_nullable_to_non_nullable
              as String?,
      presentIds: null == presentIds
          ? _value.presentIds
          : presentIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
      userReadyAgendaId: freezed == userReadyAgendaId
          ? _value.userReadyAgendaId
          : userReadyAgendaId // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_CheckAdvanceMeetingGuideRequest
    implements _CheckAdvanceMeetingGuideRequest {
  _$_CheckAdvanceMeetingGuideRequest(
      {required this.discussionPath,
      this.breakoutSessionId,
      this.breakoutRoomId,
      required this.presentIds,
      this.userReadyAgendaId});

  factory _$_CheckAdvanceMeetingGuideRequest.fromJson(
          Map<String, dynamic> json) =>
      _$$_CheckAdvanceMeetingGuideRequestFromJson(json);

  @override
  final String discussionPath;
  @override
  final String? breakoutSessionId;
  @override
  final String? breakoutRoomId;
  @override
  final List<String> presentIds;
  @override
  final String? userReadyAgendaId;

  @override
  String toString() {
    return 'CheckAdvanceMeetingGuideRequest(discussionPath: $discussionPath, breakoutSessionId: $breakoutSessionId, breakoutRoomId: $breakoutRoomId, presentIds: $presentIds, userReadyAgendaId: $userReadyAgendaId)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_CheckAdvanceMeetingGuideRequest &&
            (identical(other.discussionPath, discussionPath) ||
                other.discussionPath == discussionPath) &&
            (identical(other.breakoutSessionId, breakoutSessionId) ||
                other.breakoutSessionId == breakoutSessionId) &&
            (identical(other.breakoutRoomId, breakoutRoomId) ||
                other.breakoutRoomId == breakoutRoomId) &&
            const DeepCollectionEquality()
                .equals(other.presentIds, presentIds) &&
            (identical(other.userReadyAgendaId, userReadyAgendaId) ||
                other.userReadyAgendaId == userReadyAgendaId));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      discussionPath,
      breakoutSessionId,
      breakoutRoomId,
      const DeepCollectionEquality().hash(presentIds),
      userReadyAgendaId);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_CheckAdvanceMeetingGuideRequestCopyWith<
          _$_CheckAdvanceMeetingGuideRequest>
      get copyWith => __$$_CheckAdvanceMeetingGuideRequestCopyWithImpl<
          _$_CheckAdvanceMeetingGuideRequest>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_CheckAdvanceMeetingGuideRequestToJson(
      this,
    );
  }
}

abstract class _CheckAdvanceMeetingGuideRequest
    implements CheckAdvanceMeetingGuideRequest {
  factory _CheckAdvanceMeetingGuideRequest(
      {required final String discussionPath,
      final String? breakoutSessionId,
      final String? breakoutRoomId,
      required final List<String> presentIds,
      final String? userReadyAgendaId}) = _$_CheckAdvanceMeetingGuideRequest;

  factory _CheckAdvanceMeetingGuideRequest.fromJson(Map<String, dynamic> json) =
      _$_CheckAdvanceMeetingGuideRequest.fromJson;

  @override
  String get discussionPath;
  @override
  String? get breakoutSessionId;
  @override
  String? get breakoutRoomId;
  @override
  List<String> get presentIds;
  @override
  String? get userReadyAgendaId;
  @override
  @JsonKey(ignore: true)
  _$$_CheckAdvanceMeetingGuideRequestCopyWith<
          _$_CheckAdvanceMeetingGuideRequest>
      get copyWith => throw _privateConstructorUsedError;
}

CheckHostlessGoToBreakoutsRequest _$CheckHostlessGoToBreakoutsRequestFromJson(
    Map<String, dynamic> json) {
  return _CheckHostlessGoToBreakoutsRequest.fromJson(json);
}

/// @nodoc
mixin _$CheckHostlessGoToBreakoutsRequest {
  String get discussionPath => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $CheckHostlessGoToBreakoutsRequestCopyWith<CheckHostlessGoToBreakoutsRequest>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CheckHostlessGoToBreakoutsRequestCopyWith<$Res> {
  factory $CheckHostlessGoToBreakoutsRequestCopyWith(
          CheckHostlessGoToBreakoutsRequest value,
          $Res Function(CheckHostlessGoToBreakoutsRequest) then) =
      _$CheckHostlessGoToBreakoutsRequestCopyWithImpl<$Res,
          CheckHostlessGoToBreakoutsRequest>;
  @useResult
  $Res call({String discussionPath});
}

/// @nodoc
class _$CheckHostlessGoToBreakoutsRequestCopyWithImpl<$Res,
        $Val extends CheckHostlessGoToBreakoutsRequest>
    implements $CheckHostlessGoToBreakoutsRequestCopyWith<$Res> {
  _$CheckHostlessGoToBreakoutsRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? discussionPath = null,
  }) {
    return _then(_value.copyWith(
      discussionPath: null == discussionPath
          ? _value.discussionPath
          : discussionPath // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_CheckHostlessGoToBreakoutsRequestCopyWith<$Res>
    implements $CheckHostlessGoToBreakoutsRequestCopyWith<$Res> {
  factory _$$_CheckHostlessGoToBreakoutsRequestCopyWith(
          _$_CheckHostlessGoToBreakoutsRequest value,
          $Res Function(_$_CheckHostlessGoToBreakoutsRequest) then) =
      __$$_CheckHostlessGoToBreakoutsRequestCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String discussionPath});
}

/// @nodoc
class __$$_CheckHostlessGoToBreakoutsRequestCopyWithImpl<$Res>
    extends _$CheckHostlessGoToBreakoutsRequestCopyWithImpl<$Res,
        _$_CheckHostlessGoToBreakoutsRequest>
    implements _$$_CheckHostlessGoToBreakoutsRequestCopyWith<$Res> {
  __$$_CheckHostlessGoToBreakoutsRequestCopyWithImpl(
      _$_CheckHostlessGoToBreakoutsRequest _value,
      $Res Function(_$_CheckHostlessGoToBreakoutsRequest) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? discussionPath = null,
  }) {
    return _then(_$_CheckHostlessGoToBreakoutsRequest(
      discussionPath: null == discussionPath
          ? _value.discussionPath
          : discussionPath // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_CheckHostlessGoToBreakoutsRequest
    implements _CheckHostlessGoToBreakoutsRequest {
  _$_CheckHostlessGoToBreakoutsRequest({required this.discussionPath});

  factory _$_CheckHostlessGoToBreakoutsRequest.fromJson(
          Map<String, dynamic> json) =>
      _$$_CheckHostlessGoToBreakoutsRequestFromJson(json);

  @override
  final String discussionPath;

  @override
  String toString() {
    return 'CheckHostlessGoToBreakoutsRequest(discussionPath: $discussionPath)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_CheckHostlessGoToBreakoutsRequest &&
            (identical(other.discussionPath, discussionPath) ||
                other.discussionPath == discussionPath));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, discussionPath);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_CheckHostlessGoToBreakoutsRequestCopyWith<
          _$_CheckHostlessGoToBreakoutsRequest>
      get copyWith => __$$_CheckHostlessGoToBreakoutsRequestCopyWithImpl<
          _$_CheckHostlessGoToBreakoutsRequest>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_CheckHostlessGoToBreakoutsRequestToJson(
      this,
    );
  }
}

abstract class _CheckHostlessGoToBreakoutsRequest
    implements CheckHostlessGoToBreakoutsRequest {
  factory _CheckHostlessGoToBreakoutsRequest(
          {required final String discussionPath}) =
      _$_CheckHostlessGoToBreakoutsRequest;

  factory _CheckHostlessGoToBreakoutsRequest.fromJson(
          Map<String, dynamic> json) =
      _$_CheckHostlessGoToBreakoutsRequest.fromJson;

  @override
  String get discussionPath;
  @override
  @JsonKey(ignore: true)
  _$$_CheckHostlessGoToBreakoutsRequestCopyWith<
          _$_CheckHostlessGoToBreakoutsRequest>
      get copyWith => throw _privateConstructorUsedError;
}

CheckAssignToBreakoutsRequest _$CheckAssignToBreakoutsRequestFromJson(
    Map<String, dynamic> json) {
  return _CheckAssignToBreakoutsRequest.fromJson(json);
}

/// @nodoc
mixin _$CheckAssignToBreakoutsRequest {
  String get discussionPath => throw _privateConstructorUsedError;
  String get breakoutSessionId => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $CheckAssignToBreakoutsRequestCopyWith<CheckAssignToBreakoutsRequest>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CheckAssignToBreakoutsRequestCopyWith<$Res> {
  factory $CheckAssignToBreakoutsRequestCopyWith(
          CheckAssignToBreakoutsRequest value,
          $Res Function(CheckAssignToBreakoutsRequest) then) =
      _$CheckAssignToBreakoutsRequestCopyWithImpl<$Res,
          CheckAssignToBreakoutsRequest>;
  @useResult
  $Res call({String discussionPath, String breakoutSessionId});
}

/// @nodoc
class _$CheckAssignToBreakoutsRequestCopyWithImpl<$Res,
        $Val extends CheckAssignToBreakoutsRequest>
    implements $CheckAssignToBreakoutsRequestCopyWith<$Res> {
  _$CheckAssignToBreakoutsRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? discussionPath = null,
    Object? breakoutSessionId = null,
  }) {
    return _then(_value.copyWith(
      discussionPath: null == discussionPath
          ? _value.discussionPath
          : discussionPath // ignore: cast_nullable_to_non_nullable
              as String,
      breakoutSessionId: null == breakoutSessionId
          ? _value.breakoutSessionId
          : breakoutSessionId // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_CheckAssignToBreakoutsRequestCopyWith<$Res>
    implements $CheckAssignToBreakoutsRequestCopyWith<$Res> {
  factory _$$_CheckAssignToBreakoutsRequestCopyWith(
          _$_CheckAssignToBreakoutsRequest value,
          $Res Function(_$_CheckAssignToBreakoutsRequest) then) =
      __$$_CheckAssignToBreakoutsRequestCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String discussionPath, String breakoutSessionId});
}

/// @nodoc
class __$$_CheckAssignToBreakoutsRequestCopyWithImpl<$Res>
    extends _$CheckAssignToBreakoutsRequestCopyWithImpl<$Res,
        _$_CheckAssignToBreakoutsRequest>
    implements _$$_CheckAssignToBreakoutsRequestCopyWith<$Res> {
  __$$_CheckAssignToBreakoutsRequestCopyWithImpl(
      _$_CheckAssignToBreakoutsRequest _value,
      $Res Function(_$_CheckAssignToBreakoutsRequest) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? discussionPath = null,
    Object? breakoutSessionId = null,
  }) {
    return _then(_$_CheckAssignToBreakoutsRequest(
      discussionPath: null == discussionPath
          ? _value.discussionPath
          : discussionPath // ignore: cast_nullable_to_non_nullable
              as String,
      breakoutSessionId: null == breakoutSessionId
          ? _value.breakoutSessionId
          : breakoutSessionId // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_CheckAssignToBreakoutsRequest
    implements _CheckAssignToBreakoutsRequest {
  _$_CheckAssignToBreakoutsRequest(
      {required this.discussionPath, required this.breakoutSessionId});

  factory _$_CheckAssignToBreakoutsRequest.fromJson(
          Map<String, dynamic> json) =>
      _$$_CheckAssignToBreakoutsRequestFromJson(json);

  @override
  final String discussionPath;
  @override
  final String breakoutSessionId;

  @override
  String toString() {
    return 'CheckAssignToBreakoutsRequest(discussionPath: $discussionPath, breakoutSessionId: $breakoutSessionId)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_CheckAssignToBreakoutsRequest &&
            (identical(other.discussionPath, discussionPath) ||
                other.discussionPath == discussionPath) &&
            (identical(other.breakoutSessionId, breakoutSessionId) ||
                other.breakoutSessionId == breakoutSessionId));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode =>
      Object.hash(runtimeType, discussionPath, breakoutSessionId);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_CheckAssignToBreakoutsRequestCopyWith<_$_CheckAssignToBreakoutsRequest>
      get copyWith => __$$_CheckAssignToBreakoutsRequestCopyWithImpl<
          _$_CheckAssignToBreakoutsRequest>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_CheckAssignToBreakoutsRequestToJson(
      this,
    );
  }
}

abstract class _CheckAssignToBreakoutsRequest
    implements CheckAssignToBreakoutsRequest {
  factory _CheckAssignToBreakoutsRequest(
          {required final String discussionPath,
          required final String breakoutSessionId}) =
      _$_CheckAssignToBreakoutsRequest;

  factory _CheckAssignToBreakoutsRequest.fromJson(Map<String, dynamic> json) =
      _$_CheckAssignToBreakoutsRequest.fromJson;

  @override
  String get discussionPath;
  @override
  String get breakoutSessionId;
  @override
  @JsonKey(ignore: true)
  _$$_CheckAssignToBreakoutsRequestCopyWith<_$_CheckAssignToBreakoutsRequest>
      get copyWith => throw _privateConstructorUsedError;
}

ResetParticipantAgendaItemsRequest _$ResetParticipantAgendaItemsRequestFromJson(
    Map<String, dynamic> json) {
  return _ResetParticipantAgendaItemsRequest.fromJson(json);
}

/// @nodoc
mixin _$ResetParticipantAgendaItemsRequest {
  String get liveMeetingPath => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ResetParticipantAgendaItemsRequestCopyWith<
          ResetParticipantAgendaItemsRequest>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ResetParticipantAgendaItemsRequestCopyWith<$Res> {
  factory $ResetParticipantAgendaItemsRequestCopyWith(
          ResetParticipantAgendaItemsRequest value,
          $Res Function(ResetParticipantAgendaItemsRequest) then) =
      _$ResetParticipantAgendaItemsRequestCopyWithImpl<$Res,
          ResetParticipantAgendaItemsRequest>;
  @useResult
  $Res call({String liveMeetingPath});
}

/// @nodoc
class _$ResetParticipantAgendaItemsRequestCopyWithImpl<$Res,
        $Val extends ResetParticipantAgendaItemsRequest>
    implements $ResetParticipantAgendaItemsRequestCopyWith<$Res> {
  _$ResetParticipantAgendaItemsRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? liveMeetingPath = null,
  }) {
    return _then(_value.copyWith(
      liveMeetingPath: null == liveMeetingPath
          ? _value.liveMeetingPath
          : liveMeetingPath // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_ResetParticipantAgendaItemsRequestCopyWith<$Res>
    implements $ResetParticipantAgendaItemsRequestCopyWith<$Res> {
  factory _$$_ResetParticipantAgendaItemsRequestCopyWith(
          _$_ResetParticipantAgendaItemsRequest value,
          $Res Function(_$_ResetParticipantAgendaItemsRequest) then) =
      __$$_ResetParticipantAgendaItemsRequestCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String liveMeetingPath});
}

/// @nodoc
class __$$_ResetParticipantAgendaItemsRequestCopyWithImpl<$Res>
    extends _$ResetParticipantAgendaItemsRequestCopyWithImpl<$Res,
        _$_ResetParticipantAgendaItemsRequest>
    implements _$$_ResetParticipantAgendaItemsRequestCopyWith<$Res> {
  __$$_ResetParticipantAgendaItemsRequestCopyWithImpl(
      _$_ResetParticipantAgendaItemsRequest _value,
      $Res Function(_$_ResetParticipantAgendaItemsRequest) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? liveMeetingPath = null,
  }) {
    return _then(_$_ResetParticipantAgendaItemsRequest(
      liveMeetingPath: null == liveMeetingPath
          ? _value.liveMeetingPath
          : liveMeetingPath // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_ResetParticipantAgendaItemsRequest
    implements _ResetParticipantAgendaItemsRequest {
  _$_ResetParticipantAgendaItemsRequest({required this.liveMeetingPath});

  factory _$_ResetParticipantAgendaItemsRequest.fromJson(
          Map<String, dynamic> json) =>
      _$$_ResetParticipantAgendaItemsRequestFromJson(json);

  @override
  final String liveMeetingPath;

  @override
  String toString() {
    return 'ResetParticipantAgendaItemsRequest(liveMeetingPath: $liveMeetingPath)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_ResetParticipantAgendaItemsRequest &&
            (identical(other.liveMeetingPath, liveMeetingPath) ||
                other.liveMeetingPath == liveMeetingPath));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, liveMeetingPath);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_ResetParticipantAgendaItemsRequestCopyWith<
          _$_ResetParticipantAgendaItemsRequest>
      get copyWith => __$$_ResetParticipantAgendaItemsRequestCopyWithImpl<
          _$_ResetParticipantAgendaItemsRequest>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_ResetParticipantAgendaItemsRequestToJson(
      this,
    );
  }
}

abstract class _ResetParticipantAgendaItemsRequest
    implements ResetParticipantAgendaItemsRequest {
  factory _ResetParticipantAgendaItemsRequest(
          {required final String liveMeetingPath}) =
      _$_ResetParticipantAgendaItemsRequest;

  factory _ResetParticipantAgendaItemsRequest.fromJson(
          Map<String, dynamic> json) =
      _$_ResetParticipantAgendaItemsRequest.fromJson;

  @override
  String get liveMeetingPath;
  @override
  @JsonKey(ignore: true)
  _$$_ResetParticipantAgendaItemsRequestCopyWith<
          _$_ResetParticipantAgendaItemsRequest>
      get copyWith => throw _privateConstructorUsedError;
}

UpdateMembershipRequest _$UpdateMembershipRequestFromJson(
    Map<String, dynamic> json) {
  return _UpdateMembershipRequest.fromJson(json);
}

/// @nodoc
mixin _$UpdateMembershipRequest {
  String get userId => throw _privateConstructorUsedError;
  String get juntoId => throw _privateConstructorUsedError;
  @JsonKey(unknownEnumValue: null)
  MembershipStatus? get status => throw _privateConstructorUsedError;
  bool? get invisible => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $UpdateMembershipRequestCopyWith<UpdateMembershipRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UpdateMembershipRequestCopyWith<$Res> {
  factory $UpdateMembershipRequestCopyWith(UpdateMembershipRequest value,
          $Res Function(UpdateMembershipRequest) then) =
      _$UpdateMembershipRequestCopyWithImpl<$Res, UpdateMembershipRequest>;
  @useResult
  $Res call(
      {String userId,
      String juntoId,
      @JsonKey(unknownEnumValue: null) MembershipStatus? status,
      bool? invisible});
}

/// @nodoc
class _$UpdateMembershipRequestCopyWithImpl<$Res,
        $Val extends UpdateMembershipRequest>
    implements $UpdateMembershipRequestCopyWith<$Res> {
  _$UpdateMembershipRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? juntoId = null,
    Object? status = freezed,
    Object? invisible = freezed,
  }) {
    return _then(_value.copyWith(
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      juntoId: null == juntoId
          ? _value.juntoId
          : juntoId // ignore: cast_nullable_to_non_nullable
              as String,
      status: freezed == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as MembershipStatus?,
      invisible: freezed == invisible
          ? _value.invisible
          : invisible // ignore: cast_nullable_to_non_nullable
              as bool?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_UpdateMembershipRequestCopyWith<$Res>
    implements $UpdateMembershipRequestCopyWith<$Res> {
  factory _$$_UpdateMembershipRequestCopyWith(_$_UpdateMembershipRequest value,
          $Res Function(_$_UpdateMembershipRequest) then) =
      __$$_UpdateMembershipRequestCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String userId,
      String juntoId,
      @JsonKey(unknownEnumValue: null) MembershipStatus? status,
      bool? invisible});
}

/// @nodoc
class __$$_UpdateMembershipRequestCopyWithImpl<$Res>
    extends _$UpdateMembershipRequestCopyWithImpl<$Res,
        _$_UpdateMembershipRequest>
    implements _$$_UpdateMembershipRequestCopyWith<$Res> {
  __$$_UpdateMembershipRequestCopyWithImpl(_$_UpdateMembershipRequest _value,
      $Res Function(_$_UpdateMembershipRequest) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? juntoId = null,
    Object? status = freezed,
    Object? invisible = freezed,
  }) {
    return _then(_$_UpdateMembershipRequest(
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      juntoId: null == juntoId
          ? _value.juntoId
          : juntoId // ignore: cast_nullable_to_non_nullable
              as String,
      status: freezed == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as MembershipStatus?,
      invisible: freezed == invisible
          ? _value.invisible
          : invisible // ignore: cast_nullable_to_non_nullable
              as bool?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_UpdateMembershipRequest implements _UpdateMembershipRequest {
  _$_UpdateMembershipRequest(
      {required this.userId,
      required this.juntoId,
      @JsonKey(unknownEnumValue: null) required this.status,
      this.invisible});

  factory _$_UpdateMembershipRequest.fromJson(Map<String, dynamic> json) =>
      _$$_UpdateMembershipRequestFromJson(json);

  @override
  final String userId;
  @override
  final String juntoId;
  @override
  @JsonKey(unknownEnumValue: null)
  final MembershipStatus? status;
  @override
  final bool? invisible;

  @override
  String toString() {
    return 'UpdateMembershipRequest(userId: $userId, juntoId: $juntoId, status: $status, invisible: $invisible)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_UpdateMembershipRequest &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.juntoId, juntoId) || other.juntoId == juntoId) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.invisible, invisible) ||
                other.invisible == invisible));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode =>
      Object.hash(runtimeType, userId, juntoId, status, invisible);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_UpdateMembershipRequestCopyWith<_$_UpdateMembershipRequest>
      get copyWith =>
          __$$_UpdateMembershipRequestCopyWithImpl<_$_UpdateMembershipRequest>(
              this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_UpdateMembershipRequestToJson(
      this,
    );
  }
}

abstract class _UpdateMembershipRequest implements UpdateMembershipRequest {
  factory _UpdateMembershipRequest(
      {required final String userId,
      required final String juntoId,
      @JsonKey(unknownEnumValue: null) required final MembershipStatus? status,
      final bool? invisible}) = _$_UpdateMembershipRequest;

  factory _UpdateMembershipRequest.fromJson(Map<String, dynamic> json) =
      _$_UpdateMembershipRequest.fromJson;

  @override
  String get userId;
  @override
  String get juntoId;
  @override
  @JsonKey(unknownEnumValue: null)
  MembershipStatus? get status;
  @override
  bool? get invisible;
  @override
  @JsonKey(ignore: true)
  _$$_UpdateMembershipRequestCopyWith<_$_UpdateMembershipRequest>
      get copyWith => throw _privateConstructorUsedError;
}

VoteToKickRequest _$VoteToKickRequestFromJson(Map<String, dynamic> json) {
  return _VoteToKickRequest.fromJson(json);
}

/// @nodoc
mixin _$VoteToKickRequest {
  String get targetUserId => throw _privateConstructorUsedError;
  String get discussionPath => throw _privateConstructorUsedError;

  /// This can be the path to a live meeting or a breakout room live meeting
  String get liveMeetingPath => throw _privateConstructorUsedError;
  bool get inFavor => throw _privateConstructorUsedError;
  String? get reason => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $VoteToKickRequestCopyWith<VoteToKickRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $VoteToKickRequestCopyWith<$Res> {
  factory $VoteToKickRequestCopyWith(
          VoteToKickRequest value, $Res Function(VoteToKickRequest) then) =
      _$VoteToKickRequestCopyWithImpl<$Res, VoteToKickRequest>;
  @useResult
  $Res call(
      {String targetUserId,
      String discussionPath,
      String liveMeetingPath,
      bool inFavor,
      String? reason});
}

/// @nodoc
class _$VoteToKickRequestCopyWithImpl<$Res, $Val extends VoteToKickRequest>
    implements $VoteToKickRequestCopyWith<$Res> {
  _$VoteToKickRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? targetUserId = null,
    Object? discussionPath = null,
    Object? liveMeetingPath = null,
    Object? inFavor = null,
    Object? reason = freezed,
  }) {
    return _then(_value.copyWith(
      targetUserId: null == targetUserId
          ? _value.targetUserId
          : targetUserId // ignore: cast_nullable_to_non_nullable
              as String,
      discussionPath: null == discussionPath
          ? _value.discussionPath
          : discussionPath // ignore: cast_nullable_to_non_nullable
              as String,
      liveMeetingPath: null == liveMeetingPath
          ? _value.liveMeetingPath
          : liveMeetingPath // ignore: cast_nullable_to_non_nullable
              as String,
      inFavor: null == inFavor
          ? _value.inFavor
          : inFavor // ignore: cast_nullable_to_non_nullable
              as bool,
      reason: freezed == reason
          ? _value.reason
          : reason // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_VoteToKickRequestCopyWith<$Res>
    implements $VoteToKickRequestCopyWith<$Res> {
  factory _$$_VoteToKickRequestCopyWith(_$_VoteToKickRequest value,
          $Res Function(_$_VoteToKickRequest) then) =
      __$$_VoteToKickRequestCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String targetUserId,
      String discussionPath,
      String liveMeetingPath,
      bool inFavor,
      String? reason});
}

/// @nodoc
class __$$_VoteToKickRequestCopyWithImpl<$Res>
    extends _$VoteToKickRequestCopyWithImpl<$Res, _$_VoteToKickRequest>
    implements _$$_VoteToKickRequestCopyWith<$Res> {
  __$$_VoteToKickRequestCopyWithImpl(
      _$_VoteToKickRequest _value, $Res Function(_$_VoteToKickRequest) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? targetUserId = null,
    Object? discussionPath = null,
    Object? liveMeetingPath = null,
    Object? inFavor = null,
    Object? reason = freezed,
  }) {
    return _then(_$_VoteToKickRequest(
      targetUserId: null == targetUserId
          ? _value.targetUserId
          : targetUserId // ignore: cast_nullable_to_non_nullable
              as String,
      discussionPath: null == discussionPath
          ? _value.discussionPath
          : discussionPath // ignore: cast_nullable_to_non_nullable
              as String,
      liveMeetingPath: null == liveMeetingPath
          ? _value.liveMeetingPath
          : liveMeetingPath // ignore: cast_nullable_to_non_nullable
              as String,
      inFavor: null == inFavor
          ? _value.inFavor
          : inFavor // ignore: cast_nullable_to_non_nullable
              as bool,
      reason: freezed == reason
          ? _value.reason
          : reason // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_VoteToKickRequest implements _VoteToKickRequest {
  _$_VoteToKickRequest(
      {required this.targetUserId,
      required this.discussionPath,
      required this.liveMeetingPath,
      required this.inFavor,
      this.reason});

  factory _$_VoteToKickRequest.fromJson(Map<String, dynamic> json) =>
      _$$_VoteToKickRequestFromJson(json);

  @override
  final String targetUserId;
  @override
  final String discussionPath;

  /// This can be the path to a live meeting or a breakout room live meeting
  @override
  final String liveMeetingPath;
  @override
  final bool inFavor;
  @override
  final String? reason;

  @override
  String toString() {
    return 'VoteToKickRequest(targetUserId: $targetUserId, discussionPath: $discussionPath, liveMeetingPath: $liveMeetingPath, inFavor: $inFavor, reason: $reason)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_VoteToKickRequest &&
            (identical(other.targetUserId, targetUserId) ||
                other.targetUserId == targetUserId) &&
            (identical(other.discussionPath, discussionPath) ||
                other.discussionPath == discussionPath) &&
            (identical(other.liveMeetingPath, liveMeetingPath) ||
                other.liveMeetingPath == liveMeetingPath) &&
            (identical(other.inFavor, inFavor) || other.inFavor == inFavor) &&
            (identical(other.reason, reason) || other.reason == reason));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, targetUserId, discussionPath,
      liveMeetingPath, inFavor, reason);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_VoteToKickRequestCopyWith<_$_VoteToKickRequest> get copyWith =>
      __$$_VoteToKickRequestCopyWithImpl<_$_VoteToKickRequest>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_VoteToKickRequestToJson(
      this,
    );
  }
}

abstract class _VoteToKickRequest implements VoteToKickRequest {
  factory _VoteToKickRequest(
      {required final String targetUserId,
      required final String discussionPath,
      required final String liveMeetingPath,
      required final bool inFavor,
      final String? reason}) = _$_VoteToKickRequest;

  factory _VoteToKickRequest.fromJson(Map<String, dynamic> json) =
      _$_VoteToKickRequest.fromJson;

  @override
  String get targetUserId;
  @override
  String get discussionPath;
  @override

  /// This can be the path to a live meeting or a breakout room live meeting
  String get liveMeetingPath;
  @override
  bool get inFavor;
  @override
  String? get reason;
  @override
  @JsonKey(ignore: true)
  _$$_VoteToKickRequestCopyWith<_$_VoteToKickRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

DiscussionEndedRequest _$DiscussionEndedRequestFromJson(
    Map<String, dynamic> json) {
  return _DiscussionEndedRequest.fromJson(json);
}

/// @nodoc
mixin _$DiscussionEndedRequest {
  String get discussionPath => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $DiscussionEndedRequestCopyWith<DiscussionEndedRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DiscussionEndedRequestCopyWith<$Res> {
  factory $DiscussionEndedRequestCopyWith(DiscussionEndedRequest value,
          $Res Function(DiscussionEndedRequest) then) =
      _$DiscussionEndedRequestCopyWithImpl<$Res, DiscussionEndedRequest>;
  @useResult
  $Res call({String discussionPath});
}

/// @nodoc
class _$DiscussionEndedRequestCopyWithImpl<$Res,
        $Val extends DiscussionEndedRequest>
    implements $DiscussionEndedRequestCopyWith<$Res> {
  _$DiscussionEndedRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? discussionPath = null,
  }) {
    return _then(_value.copyWith(
      discussionPath: null == discussionPath
          ? _value.discussionPath
          : discussionPath // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_DiscussionEndedRequestCopyWith<$Res>
    implements $DiscussionEndedRequestCopyWith<$Res> {
  factory _$$_DiscussionEndedRequestCopyWith(_$_DiscussionEndedRequest value,
          $Res Function(_$_DiscussionEndedRequest) then) =
      __$$_DiscussionEndedRequestCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String discussionPath});
}

/// @nodoc
class __$$_DiscussionEndedRequestCopyWithImpl<$Res>
    extends _$DiscussionEndedRequestCopyWithImpl<$Res,
        _$_DiscussionEndedRequest>
    implements _$$_DiscussionEndedRequestCopyWith<$Res> {
  __$$_DiscussionEndedRequestCopyWithImpl(_$_DiscussionEndedRequest _value,
      $Res Function(_$_DiscussionEndedRequest) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? discussionPath = null,
  }) {
    return _then(_$_DiscussionEndedRequest(
      discussionPath: null == discussionPath
          ? _value.discussionPath
          : discussionPath // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_DiscussionEndedRequest implements _DiscussionEndedRequest {
  _$_DiscussionEndedRequest({required this.discussionPath});

  factory _$_DiscussionEndedRequest.fromJson(Map<String, dynamic> json) =>
      _$$_DiscussionEndedRequestFromJson(json);

  @override
  final String discussionPath;

  @override
  String toString() {
    return 'DiscussionEndedRequest(discussionPath: $discussionPath)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_DiscussionEndedRequest &&
            (identical(other.discussionPath, discussionPath) ||
                other.discussionPath == discussionPath));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, discussionPath);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_DiscussionEndedRequestCopyWith<_$_DiscussionEndedRequest> get copyWith =>
      __$$_DiscussionEndedRequestCopyWithImpl<_$_DiscussionEndedRequest>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_DiscussionEndedRequestToJson(
      this,
    );
  }
}

abstract class _DiscussionEndedRequest implements DiscussionEndedRequest {
  factory _DiscussionEndedRequest({required final String discussionPath}) =
      _$_DiscussionEndedRequest;

  factory _DiscussionEndedRequest.fromJson(Map<String, dynamic> json) =
      _$_DiscussionEndedRequest.fromJson;

  @override
  String get discussionPath;
  @override
  @JsonKey(ignore: true)
  _$$_DiscussionEndedRequestCopyWith<_$_DiscussionEndedRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

GetJuntoDonationsEnabledRequest _$GetJuntoDonationsEnabledRequestFromJson(
    Map<String, dynamic> json) {
  return _GetJuntoDonationsEnabledRequest.fromJson(json);
}

/// @nodoc
mixin _$GetJuntoDonationsEnabledRequest {
  String get juntoId => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $GetJuntoDonationsEnabledRequestCopyWith<GetJuntoDonationsEnabledRequest>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GetJuntoDonationsEnabledRequestCopyWith<$Res> {
  factory $GetJuntoDonationsEnabledRequestCopyWith(
          GetJuntoDonationsEnabledRequest value,
          $Res Function(GetJuntoDonationsEnabledRequest) then) =
      _$GetJuntoDonationsEnabledRequestCopyWithImpl<$Res,
          GetJuntoDonationsEnabledRequest>;
  @useResult
  $Res call({String juntoId});
}

/// @nodoc
class _$GetJuntoDonationsEnabledRequestCopyWithImpl<$Res,
        $Val extends GetJuntoDonationsEnabledRequest>
    implements $GetJuntoDonationsEnabledRequestCopyWith<$Res> {
  _$GetJuntoDonationsEnabledRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? juntoId = null,
  }) {
    return _then(_value.copyWith(
      juntoId: null == juntoId
          ? _value.juntoId
          : juntoId // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_GetJuntoDonationsEnabledRequestCopyWith<$Res>
    implements $GetJuntoDonationsEnabledRequestCopyWith<$Res> {
  factory _$$_GetJuntoDonationsEnabledRequestCopyWith(
          _$_GetJuntoDonationsEnabledRequest value,
          $Res Function(_$_GetJuntoDonationsEnabledRequest) then) =
      __$$_GetJuntoDonationsEnabledRequestCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String juntoId});
}

/// @nodoc
class __$$_GetJuntoDonationsEnabledRequestCopyWithImpl<$Res>
    extends _$GetJuntoDonationsEnabledRequestCopyWithImpl<$Res,
        _$_GetJuntoDonationsEnabledRequest>
    implements _$$_GetJuntoDonationsEnabledRequestCopyWith<$Res> {
  __$$_GetJuntoDonationsEnabledRequestCopyWithImpl(
      _$_GetJuntoDonationsEnabledRequest _value,
      $Res Function(_$_GetJuntoDonationsEnabledRequest) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? juntoId = null,
  }) {
    return _then(_$_GetJuntoDonationsEnabledRequest(
      juntoId: null == juntoId
          ? _value.juntoId
          : juntoId // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_GetJuntoDonationsEnabledRequest
    implements _GetJuntoDonationsEnabledRequest {
  _$_GetJuntoDonationsEnabledRequest({required this.juntoId});

  factory _$_GetJuntoDonationsEnabledRequest.fromJson(
          Map<String, dynamic> json) =>
      _$$_GetJuntoDonationsEnabledRequestFromJson(json);

  @override
  final String juntoId;

  @override
  String toString() {
    return 'GetJuntoDonationsEnabledRequest(juntoId: $juntoId)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_GetJuntoDonationsEnabledRequest &&
            (identical(other.juntoId, juntoId) || other.juntoId == juntoId));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, juntoId);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_GetJuntoDonationsEnabledRequestCopyWith<
          _$_GetJuntoDonationsEnabledRequest>
      get copyWith => __$$_GetJuntoDonationsEnabledRequestCopyWithImpl<
          _$_GetJuntoDonationsEnabledRequest>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_GetJuntoDonationsEnabledRequestToJson(
      this,
    );
  }
}

abstract class _GetJuntoDonationsEnabledRequest
    implements GetJuntoDonationsEnabledRequest {
  factory _GetJuntoDonationsEnabledRequest({required final String juntoId}) =
      _$_GetJuntoDonationsEnabledRequest;

  factory _GetJuntoDonationsEnabledRequest.fromJson(Map<String, dynamic> json) =
      _$_GetJuntoDonationsEnabledRequest.fromJson;

  @override
  String get juntoId;
  @override
  @JsonKey(ignore: true)
  _$$_GetJuntoDonationsEnabledRequestCopyWith<
          _$_GetJuntoDonationsEnabledRequest>
      get copyWith => throw _privateConstructorUsedError;
}

GetJuntoDonationsEnabledResponse _$GetJuntoDonationsEnabledResponseFromJson(
    Map<String, dynamic> json) {
  return _GetJuntoDonationsEnabledResponse.fromJson(json);
}

/// @nodoc
mixin _$GetJuntoDonationsEnabledResponse {
  bool get donationsEnabled => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $GetJuntoDonationsEnabledResponseCopyWith<GetJuntoDonationsEnabledResponse>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GetJuntoDonationsEnabledResponseCopyWith<$Res> {
  factory $GetJuntoDonationsEnabledResponseCopyWith(
          GetJuntoDonationsEnabledResponse value,
          $Res Function(GetJuntoDonationsEnabledResponse) then) =
      _$GetJuntoDonationsEnabledResponseCopyWithImpl<$Res,
          GetJuntoDonationsEnabledResponse>;
  @useResult
  $Res call({bool donationsEnabled});
}

/// @nodoc
class _$GetJuntoDonationsEnabledResponseCopyWithImpl<$Res,
        $Val extends GetJuntoDonationsEnabledResponse>
    implements $GetJuntoDonationsEnabledResponseCopyWith<$Res> {
  _$GetJuntoDonationsEnabledResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? donationsEnabled = null,
  }) {
    return _then(_value.copyWith(
      donationsEnabled: null == donationsEnabled
          ? _value.donationsEnabled
          : donationsEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_GetJuntoDonationsEnabledResponseCopyWith<$Res>
    implements $GetJuntoDonationsEnabledResponseCopyWith<$Res> {
  factory _$$_GetJuntoDonationsEnabledResponseCopyWith(
          _$_GetJuntoDonationsEnabledResponse value,
          $Res Function(_$_GetJuntoDonationsEnabledResponse) then) =
      __$$_GetJuntoDonationsEnabledResponseCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({bool donationsEnabled});
}

/// @nodoc
class __$$_GetJuntoDonationsEnabledResponseCopyWithImpl<$Res>
    extends _$GetJuntoDonationsEnabledResponseCopyWithImpl<$Res,
        _$_GetJuntoDonationsEnabledResponse>
    implements _$$_GetJuntoDonationsEnabledResponseCopyWith<$Res> {
  __$$_GetJuntoDonationsEnabledResponseCopyWithImpl(
      _$_GetJuntoDonationsEnabledResponse _value,
      $Res Function(_$_GetJuntoDonationsEnabledResponse) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? donationsEnabled = null,
  }) {
    return _then(_$_GetJuntoDonationsEnabledResponse(
      donationsEnabled: null == donationsEnabled
          ? _value.donationsEnabled
          : donationsEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_GetJuntoDonationsEnabledResponse
    implements _GetJuntoDonationsEnabledResponse {
  _$_GetJuntoDonationsEnabledResponse({required this.donationsEnabled});

  factory _$_GetJuntoDonationsEnabledResponse.fromJson(
          Map<String, dynamic> json) =>
      _$$_GetJuntoDonationsEnabledResponseFromJson(json);

  @override
  final bool donationsEnabled;

  @override
  String toString() {
    return 'GetJuntoDonationsEnabledResponse(donationsEnabled: $donationsEnabled)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_GetJuntoDonationsEnabledResponse &&
            (identical(other.donationsEnabled, donationsEnabled) ||
                other.donationsEnabled == donationsEnabled));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, donationsEnabled);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_GetJuntoDonationsEnabledResponseCopyWith<
          _$_GetJuntoDonationsEnabledResponse>
      get copyWith => __$$_GetJuntoDonationsEnabledResponseCopyWithImpl<
          _$_GetJuntoDonationsEnabledResponse>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_GetJuntoDonationsEnabledResponseToJson(
      this,
    );
  }
}

abstract class _GetJuntoDonationsEnabledResponse
    implements GetJuntoDonationsEnabledResponse {
  factory _GetJuntoDonationsEnabledResponse(
          {required final bool donationsEnabled}) =
      _$_GetJuntoDonationsEnabledResponse;

  factory _GetJuntoDonationsEnabledResponse.fromJson(
      Map<String, dynamic> json) = _$_GetJuntoDonationsEnabledResponse.fromJson;

  @override
  bool get donationsEnabled;
  @override
  @JsonKey(ignore: true)
  _$$_GetJuntoDonationsEnabledResponseCopyWith<
          _$_GetJuntoDonationsEnabledResponse>
      get copyWith => throw _privateConstructorUsedError;
}

GetJuntoPrePostEnabledRequest _$GetJuntoPrePostEnabledRequestFromJson(
    Map<String, dynamic> json) {
  return _GetJuntoPrePostEnabledRequest.fromJson(json);
}

/// @nodoc
mixin _$GetJuntoPrePostEnabledRequest {
  String get juntoId => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $GetJuntoPrePostEnabledRequestCopyWith<GetJuntoPrePostEnabledRequest>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GetJuntoPrePostEnabledRequestCopyWith<$Res> {
  factory $GetJuntoPrePostEnabledRequestCopyWith(
          GetJuntoPrePostEnabledRequest value,
          $Res Function(GetJuntoPrePostEnabledRequest) then) =
      _$GetJuntoPrePostEnabledRequestCopyWithImpl<$Res,
          GetJuntoPrePostEnabledRequest>;
  @useResult
  $Res call({String juntoId});
}

/// @nodoc
class _$GetJuntoPrePostEnabledRequestCopyWithImpl<$Res,
        $Val extends GetJuntoPrePostEnabledRequest>
    implements $GetJuntoPrePostEnabledRequestCopyWith<$Res> {
  _$GetJuntoPrePostEnabledRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? juntoId = null,
  }) {
    return _then(_value.copyWith(
      juntoId: null == juntoId
          ? _value.juntoId
          : juntoId // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_GetJuntoPrePostEnabledRequestCopyWith<$Res>
    implements $GetJuntoPrePostEnabledRequestCopyWith<$Res> {
  factory _$$_GetJuntoPrePostEnabledRequestCopyWith(
          _$_GetJuntoPrePostEnabledRequest value,
          $Res Function(_$_GetJuntoPrePostEnabledRequest) then) =
      __$$_GetJuntoPrePostEnabledRequestCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String juntoId});
}

/// @nodoc
class __$$_GetJuntoPrePostEnabledRequestCopyWithImpl<$Res>
    extends _$GetJuntoPrePostEnabledRequestCopyWithImpl<$Res,
        _$_GetJuntoPrePostEnabledRequest>
    implements _$$_GetJuntoPrePostEnabledRequestCopyWith<$Res> {
  __$$_GetJuntoPrePostEnabledRequestCopyWithImpl(
      _$_GetJuntoPrePostEnabledRequest _value,
      $Res Function(_$_GetJuntoPrePostEnabledRequest) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? juntoId = null,
  }) {
    return _then(_$_GetJuntoPrePostEnabledRequest(
      juntoId: null == juntoId
          ? _value.juntoId
          : juntoId // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_GetJuntoPrePostEnabledRequest
    implements _GetJuntoPrePostEnabledRequest {
  _$_GetJuntoPrePostEnabledRequest({required this.juntoId});

  factory _$_GetJuntoPrePostEnabledRequest.fromJson(
          Map<String, dynamic> json) =>
      _$$_GetJuntoPrePostEnabledRequestFromJson(json);

  @override
  final String juntoId;

  @override
  String toString() {
    return 'GetJuntoPrePostEnabledRequest(juntoId: $juntoId)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_GetJuntoPrePostEnabledRequest &&
            (identical(other.juntoId, juntoId) || other.juntoId == juntoId));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, juntoId);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_GetJuntoPrePostEnabledRequestCopyWith<_$_GetJuntoPrePostEnabledRequest>
      get copyWith => __$$_GetJuntoPrePostEnabledRequestCopyWithImpl<
          _$_GetJuntoPrePostEnabledRequest>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_GetJuntoPrePostEnabledRequestToJson(
      this,
    );
  }
}

abstract class _GetJuntoPrePostEnabledRequest
    implements GetJuntoPrePostEnabledRequest {
  factory _GetJuntoPrePostEnabledRequest({required final String juntoId}) =
      _$_GetJuntoPrePostEnabledRequest;

  factory _GetJuntoPrePostEnabledRequest.fromJson(Map<String, dynamic> json) =
      _$_GetJuntoPrePostEnabledRequest.fromJson;

  @override
  String get juntoId;
  @override
  @JsonKey(ignore: true)
  _$$_GetJuntoPrePostEnabledRequestCopyWith<_$_GetJuntoPrePostEnabledRequest>
      get copyWith => throw _privateConstructorUsedError;
}

GetJuntoPrePostEnabledResponse _$GetJuntoPrePostEnabledResponseFromJson(
    Map<String, dynamic> json) {
  return _GetJuntoPrePostEnabledResponse.fromJson(json);
}

/// @nodoc
mixin _$GetJuntoPrePostEnabledResponse {
  bool get prePostEnabled => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $GetJuntoPrePostEnabledResponseCopyWith<GetJuntoPrePostEnabledResponse>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GetJuntoPrePostEnabledResponseCopyWith<$Res> {
  factory $GetJuntoPrePostEnabledResponseCopyWith(
          GetJuntoPrePostEnabledResponse value,
          $Res Function(GetJuntoPrePostEnabledResponse) then) =
      _$GetJuntoPrePostEnabledResponseCopyWithImpl<$Res,
          GetJuntoPrePostEnabledResponse>;
  @useResult
  $Res call({bool prePostEnabled});
}

/// @nodoc
class _$GetJuntoPrePostEnabledResponseCopyWithImpl<$Res,
        $Val extends GetJuntoPrePostEnabledResponse>
    implements $GetJuntoPrePostEnabledResponseCopyWith<$Res> {
  _$GetJuntoPrePostEnabledResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? prePostEnabled = null,
  }) {
    return _then(_value.copyWith(
      prePostEnabled: null == prePostEnabled
          ? _value.prePostEnabled
          : prePostEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_GetJuntoPrePostEnabledResponseCopyWith<$Res>
    implements $GetJuntoPrePostEnabledResponseCopyWith<$Res> {
  factory _$$_GetJuntoPrePostEnabledResponseCopyWith(
          _$_GetJuntoPrePostEnabledResponse value,
          $Res Function(_$_GetJuntoPrePostEnabledResponse) then) =
      __$$_GetJuntoPrePostEnabledResponseCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({bool prePostEnabled});
}

/// @nodoc
class __$$_GetJuntoPrePostEnabledResponseCopyWithImpl<$Res>
    extends _$GetJuntoPrePostEnabledResponseCopyWithImpl<$Res,
        _$_GetJuntoPrePostEnabledResponse>
    implements _$$_GetJuntoPrePostEnabledResponseCopyWith<$Res> {
  __$$_GetJuntoPrePostEnabledResponseCopyWithImpl(
      _$_GetJuntoPrePostEnabledResponse _value,
      $Res Function(_$_GetJuntoPrePostEnabledResponse) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? prePostEnabled = null,
  }) {
    return _then(_$_GetJuntoPrePostEnabledResponse(
      prePostEnabled: null == prePostEnabled
          ? _value.prePostEnabled
          : prePostEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_GetJuntoPrePostEnabledResponse
    implements _GetJuntoPrePostEnabledResponse {
  _$_GetJuntoPrePostEnabledResponse({required this.prePostEnabled});

  factory _$_GetJuntoPrePostEnabledResponse.fromJson(
          Map<String, dynamic> json) =>
      _$$_GetJuntoPrePostEnabledResponseFromJson(json);

  @override
  final bool prePostEnabled;

  @override
  String toString() {
    return 'GetJuntoPrePostEnabledResponse(prePostEnabled: $prePostEnabled)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_GetJuntoPrePostEnabledResponse &&
            (identical(other.prePostEnabled, prePostEnabled) ||
                other.prePostEnabled == prePostEnabled));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, prePostEnabled);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_GetJuntoPrePostEnabledResponseCopyWith<_$_GetJuntoPrePostEnabledResponse>
      get copyWith => __$$_GetJuntoPrePostEnabledResponseCopyWithImpl<
          _$_GetJuntoPrePostEnabledResponse>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_GetJuntoPrePostEnabledResponseToJson(
      this,
    );
  }
}

abstract class _GetJuntoPrePostEnabledResponse
    implements GetJuntoPrePostEnabledResponse {
  factory _GetJuntoPrePostEnabledResponse(
      {required final bool prePostEnabled}) = _$_GetJuntoPrePostEnabledResponse;

  factory _GetJuntoPrePostEnabledResponse.fromJson(Map<String, dynamic> json) =
      _$_GetJuntoPrePostEnabledResponse.fromJson;

  @override
  bool get prePostEnabled;
  @override
  @JsonKey(ignore: true)
  _$$_GetJuntoPrePostEnabledResponseCopyWith<_$_GetJuntoPrePostEnabledResponse>
      get copyWith => throw _privateConstructorUsedError;
}

UpdateStripeSubscriptionPlanRequest
    _$UpdateStripeSubscriptionPlanRequestFromJson(Map<String, dynamic> json) {
  return _UpdateStripeSubscriptionPlanRequest.fromJson(json);
}

/// @nodoc
mixin _$UpdateStripeSubscriptionPlanRequest {
  String get juntoId => throw _privateConstructorUsedError;

  /// Identifier of the specific "price" object associated with a subscription in Stripe
  String get stripePriceId => throw _privateConstructorUsedError;
  PlanType get type => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $UpdateStripeSubscriptionPlanRequestCopyWith<
          UpdateStripeSubscriptionPlanRequest>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UpdateStripeSubscriptionPlanRequestCopyWith<$Res> {
  factory $UpdateStripeSubscriptionPlanRequestCopyWith(
          UpdateStripeSubscriptionPlanRequest value,
          $Res Function(UpdateStripeSubscriptionPlanRequest) then) =
      _$UpdateStripeSubscriptionPlanRequestCopyWithImpl<$Res,
          UpdateStripeSubscriptionPlanRequest>;
  @useResult
  $Res call({String juntoId, String stripePriceId, PlanType type});
}

/// @nodoc
class _$UpdateStripeSubscriptionPlanRequestCopyWithImpl<$Res,
        $Val extends UpdateStripeSubscriptionPlanRequest>
    implements $UpdateStripeSubscriptionPlanRequestCopyWith<$Res> {
  _$UpdateStripeSubscriptionPlanRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? juntoId = null,
    Object? stripePriceId = null,
    Object? type = null,
  }) {
    return _then(_value.copyWith(
      juntoId: null == juntoId
          ? _value.juntoId
          : juntoId // ignore: cast_nullable_to_non_nullable
              as String,
      stripePriceId: null == stripePriceId
          ? _value.stripePriceId
          : stripePriceId // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as PlanType,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_UpdateStripeSubscriptionPlanRequestCopyWith<$Res>
    implements $UpdateStripeSubscriptionPlanRequestCopyWith<$Res> {
  factory _$$_UpdateStripeSubscriptionPlanRequestCopyWith(
          _$_UpdateStripeSubscriptionPlanRequest value,
          $Res Function(_$_UpdateStripeSubscriptionPlanRequest) then) =
      __$$_UpdateStripeSubscriptionPlanRequestCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String juntoId, String stripePriceId, PlanType type});
}

/// @nodoc
class __$$_UpdateStripeSubscriptionPlanRequestCopyWithImpl<$Res>
    extends _$UpdateStripeSubscriptionPlanRequestCopyWithImpl<$Res,
        _$_UpdateStripeSubscriptionPlanRequest>
    implements _$$_UpdateStripeSubscriptionPlanRequestCopyWith<$Res> {
  __$$_UpdateStripeSubscriptionPlanRequestCopyWithImpl(
      _$_UpdateStripeSubscriptionPlanRequest _value,
      $Res Function(_$_UpdateStripeSubscriptionPlanRequest) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? juntoId = null,
    Object? stripePriceId = null,
    Object? type = null,
  }) {
    return _then(_$_UpdateStripeSubscriptionPlanRequest(
      juntoId: null == juntoId
          ? _value.juntoId
          : juntoId // ignore: cast_nullable_to_non_nullable
              as String,
      stripePriceId: null == stripePriceId
          ? _value.stripePriceId
          : stripePriceId // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as PlanType,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_UpdateStripeSubscriptionPlanRequest
    implements _UpdateStripeSubscriptionPlanRequest {
  _$_UpdateStripeSubscriptionPlanRequest(
      {required this.juntoId, required this.stripePriceId, required this.type});

  factory _$_UpdateStripeSubscriptionPlanRequest.fromJson(
          Map<String, dynamic> json) =>
      _$$_UpdateStripeSubscriptionPlanRequestFromJson(json);

  @override
  final String juntoId;

  /// Identifier of the specific "price" object associated with a subscription in Stripe
  @override
  final String stripePriceId;
  @override
  final PlanType type;

  @override
  String toString() {
    return 'UpdateStripeSubscriptionPlanRequest(juntoId: $juntoId, stripePriceId: $stripePriceId, type: $type)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_UpdateStripeSubscriptionPlanRequest &&
            (identical(other.juntoId, juntoId) || other.juntoId == juntoId) &&
            (identical(other.stripePriceId, stripePriceId) ||
                other.stripePriceId == stripePriceId) &&
            (identical(other.type, type) || other.type == type));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, juntoId, stripePriceId, type);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_UpdateStripeSubscriptionPlanRequestCopyWith<
          _$_UpdateStripeSubscriptionPlanRequest>
      get copyWith => __$$_UpdateStripeSubscriptionPlanRequestCopyWithImpl<
          _$_UpdateStripeSubscriptionPlanRequest>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_UpdateStripeSubscriptionPlanRequestToJson(
      this,
    );
  }
}

abstract class _UpdateStripeSubscriptionPlanRequest
    implements UpdateStripeSubscriptionPlanRequest {
  factory _UpdateStripeSubscriptionPlanRequest(
      {required final String juntoId,
      required final String stripePriceId,
      required final PlanType type}) = _$_UpdateStripeSubscriptionPlanRequest;

  factory _UpdateStripeSubscriptionPlanRequest.fromJson(
          Map<String, dynamic> json) =
      _$_UpdateStripeSubscriptionPlanRequest.fromJson;

  @override
  String get juntoId;
  @override

  /// Identifier of the specific "price" object associated with a subscription in Stripe
  String get stripePriceId;
  @override
  PlanType get type;
  @override
  @JsonKey(ignore: true)
  _$$_UpdateStripeSubscriptionPlanRequestCopyWith<
          _$_UpdateStripeSubscriptionPlanRequest>
      get copyWith => throw _privateConstructorUsedError;
}

CancelStripeSubscriptionPlanRequest
    _$CancelStripeSubscriptionPlanRequestFromJson(Map<String, dynamic> json) {
  return _CancelStripeSubscriptionPlanRequest.fromJson(json);
}

/// @nodoc
mixin _$CancelStripeSubscriptionPlanRequest {
  String get juntoId => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $CancelStripeSubscriptionPlanRequestCopyWith<
          CancelStripeSubscriptionPlanRequest>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CancelStripeSubscriptionPlanRequestCopyWith<$Res> {
  factory $CancelStripeSubscriptionPlanRequestCopyWith(
          CancelStripeSubscriptionPlanRequest value,
          $Res Function(CancelStripeSubscriptionPlanRequest) then) =
      _$CancelStripeSubscriptionPlanRequestCopyWithImpl<$Res,
          CancelStripeSubscriptionPlanRequest>;
  @useResult
  $Res call({String juntoId});
}

/// @nodoc
class _$CancelStripeSubscriptionPlanRequestCopyWithImpl<$Res,
        $Val extends CancelStripeSubscriptionPlanRequest>
    implements $CancelStripeSubscriptionPlanRequestCopyWith<$Res> {
  _$CancelStripeSubscriptionPlanRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? juntoId = null,
  }) {
    return _then(_value.copyWith(
      juntoId: null == juntoId
          ? _value.juntoId
          : juntoId // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_CancelStripeSubscriptionPlanRequestCopyWith<$Res>
    implements $CancelStripeSubscriptionPlanRequestCopyWith<$Res> {
  factory _$$_CancelStripeSubscriptionPlanRequestCopyWith(
          _$_CancelStripeSubscriptionPlanRequest value,
          $Res Function(_$_CancelStripeSubscriptionPlanRequest) then) =
      __$$_CancelStripeSubscriptionPlanRequestCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String juntoId});
}

/// @nodoc
class __$$_CancelStripeSubscriptionPlanRequestCopyWithImpl<$Res>
    extends _$CancelStripeSubscriptionPlanRequestCopyWithImpl<$Res,
        _$_CancelStripeSubscriptionPlanRequest>
    implements _$$_CancelStripeSubscriptionPlanRequestCopyWith<$Res> {
  __$$_CancelStripeSubscriptionPlanRequestCopyWithImpl(
      _$_CancelStripeSubscriptionPlanRequest _value,
      $Res Function(_$_CancelStripeSubscriptionPlanRequest) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? juntoId = null,
  }) {
    return _then(_$_CancelStripeSubscriptionPlanRequest(
      juntoId: null == juntoId
          ? _value.juntoId
          : juntoId // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_CancelStripeSubscriptionPlanRequest
    implements _CancelStripeSubscriptionPlanRequest {
  _$_CancelStripeSubscriptionPlanRequest({required this.juntoId});

  factory _$_CancelStripeSubscriptionPlanRequest.fromJson(
          Map<String, dynamic> json) =>
      _$$_CancelStripeSubscriptionPlanRequestFromJson(json);

  @override
  final String juntoId;

  @override
  String toString() {
    return 'CancelStripeSubscriptionPlanRequest(juntoId: $juntoId)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_CancelStripeSubscriptionPlanRequest &&
            (identical(other.juntoId, juntoId) || other.juntoId == juntoId));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, juntoId);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_CancelStripeSubscriptionPlanRequestCopyWith<
          _$_CancelStripeSubscriptionPlanRequest>
      get copyWith => __$$_CancelStripeSubscriptionPlanRequestCopyWithImpl<
          _$_CancelStripeSubscriptionPlanRequest>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_CancelStripeSubscriptionPlanRequestToJson(
      this,
    );
  }
}

abstract class _CancelStripeSubscriptionPlanRequest
    implements CancelStripeSubscriptionPlanRequest {
  factory _CancelStripeSubscriptionPlanRequest(
      {required final String juntoId}) = _$_CancelStripeSubscriptionPlanRequest;

  factory _CancelStripeSubscriptionPlanRequest.fromJson(
          Map<String, dynamic> json) =
      _$_CancelStripeSubscriptionPlanRequest.fromJson;

  @override
  String get juntoId;
  @override
  @JsonKey(ignore: true)
  _$$_CancelStripeSubscriptionPlanRequestCopyWith<
          _$_CancelStripeSubscriptionPlanRequest>
      get copyWith => throw _privateConstructorUsedError;
}

GetStripeSubscriptionPlanInfoRequest
    _$GetStripeSubscriptionPlanInfoRequestFromJson(Map<String, dynamic> json) {
  return _GetStripeSubscriptionPlanInfoRequest.fromJson(json);
}

/// @nodoc
mixin _$GetStripeSubscriptionPlanInfoRequest {
  PlanType get type => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $GetStripeSubscriptionPlanInfoRequestCopyWith<
          GetStripeSubscriptionPlanInfoRequest>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GetStripeSubscriptionPlanInfoRequestCopyWith<$Res> {
  factory $GetStripeSubscriptionPlanInfoRequestCopyWith(
          GetStripeSubscriptionPlanInfoRequest value,
          $Res Function(GetStripeSubscriptionPlanInfoRequest) then) =
      _$GetStripeSubscriptionPlanInfoRequestCopyWithImpl<$Res,
          GetStripeSubscriptionPlanInfoRequest>;
  @useResult
  $Res call({PlanType type});
}

/// @nodoc
class _$GetStripeSubscriptionPlanInfoRequestCopyWithImpl<$Res,
        $Val extends GetStripeSubscriptionPlanInfoRequest>
    implements $GetStripeSubscriptionPlanInfoRequestCopyWith<$Res> {
  _$GetStripeSubscriptionPlanInfoRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? type = null,
  }) {
    return _then(_value.copyWith(
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as PlanType,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_GetStripeSubscriptionPlanInfoRequestCopyWith<$Res>
    implements $GetStripeSubscriptionPlanInfoRequestCopyWith<$Res> {
  factory _$$_GetStripeSubscriptionPlanInfoRequestCopyWith(
          _$_GetStripeSubscriptionPlanInfoRequest value,
          $Res Function(_$_GetStripeSubscriptionPlanInfoRequest) then) =
      __$$_GetStripeSubscriptionPlanInfoRequestCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({PlanType type});
}

/// @nodoc
class __$$_GetStripeSubscriptionPlanInfoRequestCopyWithImpl<$Res>
    extends _$GetStripeSubscriptionPlanInfoRequestCopyWithImpl<$Res,
        _$_GetStripeSubscriptionPlanInfoRequest>
    implements _$$_GetStripeSubscriptionPlanInfoRequestCopyWith<$Res> {
  __$$_GetStripeSubscriptionPlanInfoRequestCopyWithImpl(
      _$_GetStripeSubscriptionPlanInfoRequest _value,
      $Res Function(_$_GetStripeSubscriptionPlanInfoRequest) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? type = null,
  }) {
    return _then(_$_GetStripeSubscriptionPlanInfoRequest(
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as PlanType,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_GetStripeSubscriptionPlanInfoRequest
    implements _GetStripeSubscriptionPlanInfoRequest {
  _$_GetStripeSubscriptionPlanInfoRequest({required this.type});

  factory _$_GetStripeSubscriptionPlanInfoRequest.fromJson(
          Map<String, dynamic> json) =>
      _$$_GetStripeSubscriptionPlanInfoRequestFromJson(json);

  @override
  final PlanType type;

  @override
  String toString() {
    return 'GetStripeSubscriptionPlanInfoRequest(type: $type)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_GetStripeSubscriptionPlanInfoRequest &&
            (identical(other.type, type) || other.type == type));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, type);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_GetStripeSubscriptionPlanInfoRequestCopyWith<
          _$_GetStripeSubscriptionPlanInfoRequest>
      get copyWith => __$$_GetStripeSubscriptionPlanInfoRequestCopyWithImpl<
          _$_GetStripeSubscriptionPlanInfoRequest>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_GetStripeSubscriptionPlanInfoRequestToJson(
      this,
    );
  }
}

abstract class _GetStripeSubscriptionPlanInfoRequest
    implements GetStripeSubscriptionPlanInfoRequest {
  factory _GetStripeSubscriptionPlanInfoRequest(
      {required final PlanType type}) = _$_GetStripeSubscriptionPlanInfoRequest;

  factory _GetStripeSubscriptionPlanInfoRequest.fromJson(
          Map<String, dynamic> json) =
      _$_GetStripeSubscriptionPlanInfoRequest.fromJson;

  @override
  PlanType get type;
  @override
  @JsonKey(ignore: true)
  _$$_GetStripeSubscriptionPlanInfoRequestCopyWith<
          _$_GetStripeSubscriptionPlanInfoRequest>
      get copyWith => throw _privateConstructorUsedError;
}

GetStripeSubscriptionPlanInfoResponse
    _$GetStripeSubscriptionPlanInfoResponseFromJson(Map<String, dynamic> json) {
  return _GetStripeSubscriptionPlanInfoResponse.fromJson(json);
}

/// @nodoc
mixin _$GetStripeSubscriptionPlanInfoResponse {
  PlanType get plan => throw _privateConstructorUsedError;
  int get priceInCents => throw _privateConstructorUsedError;

  /// Identifier of the specific "price" object associated with a subscription in Stripe
  String get stripePriceId => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $GetStripeSubscriptionPlanInfoResponseCopyWith<
          GetStripeSubscriptionPlanInfoResponse>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GetStripeSubscriptionPlanInfoResponseCopyWith<$Res> {
  factory $GetStripeSubscriptionPlanInfoResponseCopyWith(
          GetStripeSubscriptionPlanInfoResponse value,
          $Res Function(GetStripeSubscriptionPlanInfoResponse) then) =
      _$GetStripeSubscriptionPlanInfoResponseCopyWithImpl<$Res,
          GetStripeSubscriptionPlanInfoResponse>;
  @useResult
  $Res call(
      {PlanType plan, int priceInCents, String stripePriceId, String name});
}

/// @nodoc
class _$GetStripeSubscriptionPlanInfoResponseCopyWithImpl<$Res,
        $Val extends GetStripeSubscriptionPlanInfoResponse>
    implements $GetStripeSubscriptionPlanInfoResponseCopyWith<$Res> {
  _$GetStripeSubscriptionPlanInfoResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? plan = null,
    Object? priceInCents = null,
    Object? stripePriceId = null,
    Object? name = null,
  }) {
    return _then(_value.copyWith(
      plan: null == plan
          ? _value.plan
          : plan // ignore: cast_nullable_to_non_nullable
              as PlanType,
      priceInCents: null == priceInCents
          ? _value.priceInCents
          : priceInCents // ignore: cast_nullable_to_non_nullable
              as int,
      stripePriceId: null == stripePriceId
          ? _value.stripePriceId
          : stripePriceId // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_GetStripeSubscriptionPlanInfoResponseCopyWith<$Res>
    implements $GetStripeSubscriptionPlanInfoResponseCopyWith<$Res> {
  factory _$$_GetStripeSubscriptionPlanInfoResponseCopyWith(
          _$_GetStripeSubscriptionPlanInfoResponse value,
          $Res Function(_$_GetStripeSubscriptionPlanInfoResponse) then) =
      __$$_GetStripeSubscriptionPlanInfoResponseCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {PlanType plan, int priceInCents, String stripePriceId, String name});
}

/// @nodoc
class __$$_GetStripeSubscriptionPlanInfoResponseCopyWithImpl<$Res>
    extends _$GetStripeSubscriptionPlanInfoResponseCopyWithImpl<$Res,
        _$_GetStripeSubscriptionPlanInfoResponse>
    implements _$$_GetStripeSubscriptionPlanInfoResponseCopyWith<$Res> {
  __$$_GetStripeSubscriptionPlanInfoResponseCopyWithImpl(
      _$_GetStripeSubscriptionPlanInfoResponse _value,
      $Res Function(_$_GetStripeSubscriptionPlanInfoResponse) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? plan = null,
    Object? priceInCents = null,
    Object? stripePriceId = null,
    Object? name = null,
  }) {
    return _then(_$_GetStripeSubscriptionPlanInfoResponse(
      plan: null == plan
          ? _value.plan
          : plan // ignore: cast_nullable_to_non_nullable
              as PlanType,
      priceInCents: null == priceInCents
          ? _value.priceInCents
          : priceInCents // ignore: cast_nullable_to_non_nullable
              as int,
      stripePriceId: null == stripePriceId
          ? _value.stripePriceId
          : stripePriceId // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_GetStripeSubscriptionPlanInfoResponse
    implements _GetStripeSubscriptionPlanInfoResponse {
  _$_GetStripeSubscriptionPlanInfoResponse(
      {required this.plan,
      required this.priceInCents,
      required this.stripePriceId,
      required this.name});

  factory _$_GetStripeSubscriptionPlanInfoResponse.fromJson(
          Map<String, dynamic> json) =>
      _$$_GetStripeSubscriptionPlanInfoResponseFromJson(json);

  @override
  final PlanType plan;
  @override
  final int priceInCents;

  /// Identifier of the specific "price" object associated with a subscription in Stripe
  @override
  final String stripePriceId;
  @override
  final String name;

  @override
  String toString() {
    return 'GetStripeSubscriptionPlanInfoResponse(plan: $plan, priceInCents: $priceInCents, stripePriceId: $stripePriceId, name: $name)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_GetStripeSubscriptionPlanInfoResponse &&
            (identical(other.plan, plan) || other.plan == plan) &&
            (identical(other.priceInCents, priceInCents) ||
                other.priceInCents == priceInCents) &&
            (identical(other.stripePriceId, stripePriceId) ||
                other.stripePriceId == stripePriceId) &&
            (identical(other.name, name) || other.name == name));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode =>
      Object.hash(runtimeType, plan, priceInCents, stripePriceId, name);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_GetStripeSubscriptionPlanInfoResponseCopyWith<
          _$_GetStripeSubscriptionPlanInfoResponse>
      get copyWith => __$$_GetStripeSubscriptionPlanInfoResponseCopyWithImpl<
          _$_GetStripeSubscriptionPlanInfoResponse>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_GetStripeSubscriptionPlanInfoResponseToJson(
      this,
    );
  }
}

abstract class _GetStripeSubscriptionPlanInfoResponse
    implements GetStripeSubscriptionPlanInfoResponse {
  factory _GetStripeSubscriptionPlanInfoResponse(
      {required final PlanType plan,
      required final int priceInCents,
      required final String stripePriceId,
      required final String name}) = _$_GetStripeSubscriptionPlanInfoResponse;

  factory _GetStripeSubscriptionPlanInfoResponse.fromJson(
          Map<String, dynamic> json) =
      _$_GetStripeSubscriptionPlanInfoResponse.fromJson;

  @override
  PlanType get plan;
  @override
  int get priceInCents;
  @override

  /// Identifier of the specific "price" object associated with a subscription in Stripe
  String get stripePriceId;
  @override
  String get name;
  @override
  @JsonKey(ignore: true)
  _$$_GetStripeSubscriptionPlanInfoResponseCopyWith<
          _$_GetStripeSubscriptionPlanInfoResponse>
      get copyWith => throw _privateConstructorUsedError;
}

GetJuntoCalendarLinkRequest _$GetJuntoCalendarLinkRequestFromJson(
    Map<String, dynamic> json) {
  return _GetJuntoCalendarLinkRequest.fromJson(json);
}

/// @nodoc
mixin _$GetJuntoCalendarLinkRequest {
  String get discussionPath => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $GetJuntoCalendarLinkRequestCopyWith<GetJuntoCalendarLinkRequest>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GetJuntoCalendarLinkRequestCopyWith<$Res> {
  factory $GetJuntoCalendarLinkRequestCopyWith(
          GetJuntoCalendarLinkRequest value,
          $Res Function(GetJuntoCalendarLinkRequest) then) =
      _$GetJuntoCalendarLinkRequestCopyWithImpl<$Res,
          GetJuntoCalendarLinkRequest>;
  @useResult
  $Res call({String discussionPath});
}

/// @nodoc
class _$GetJuntoCalendarLinkRequestCopyWithImpl<$Res,
        $Val extends GetJuntoCalendarLinkRequest>
    implements $GetJuntoCalendarLinkRequestCopyWith<$Res> {
  _$GetJuntoCalendarLinkRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? discussionPath = null,
  }) {
    return _then(_value.copyWith(
      discussionPath: null == discussionPath
          ? _value.discussionPath
          : discussionPath // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_GetJuntoCalendarLinkRequestCopyWith<$Res>
    implements $GetJuntoCalendarLinkRequestCopyWith<$Res> {
  factory _$$_GetJuntoCalendarLinkRequestCopyWith(
          _$_GetJuntoCalendarLinkRequest value,
          $Res Function(_$_GetJuntoCalendarLinkRequest) then) =
      __$$_GetJuntoCalendarLinkRequestCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String discussionPath});
}

/// @nodoc
class __$$_GetJuntoCalendarLinkRequestCopyWithImpl<$Res>
    extends _$GetJuntoCalendarLinkRequestCopyWithImpl<$Res,
        _$_GetJuntoCalendarLinkRequest>
    implements _$$_GetJuntoCalendarLinkRequestCopyWith<$Res> {
  __$$_GetJuntoCalendarLinkRequestCopyWithImpl(
      _$_GetJuntoCalendarLinkRequest _value,
      $Res Function(_$_GetJuntoCalendarLinkRequest) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? discussionPath = null,
  }) {
    return _then(_$_GetJuntoCalendarLinkRequest(
      discussionPath: null == discussionPath
          ? _value.discussionPath
          : discussionPath // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_GetJuntoCalendarLinkRequest implements _GetJuntoCalendarLinkRequest {
  _$_GetJuntoCalendarLinkRequest({required this.discussionPath});

  factory _$_GetJuntoCalendarLinkRequest.fromJson(Map<String, dynamic> json) =>
      _$$_GetJuntoCalendarLinkRequestFromJson(json);

  @override
  final String discussionPath;

  @override
  String toString() {
    return 'GetJuntoCalendarLinkRequest(discussionPath: $discussionPath)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_GetJuntoCalendarLinkRequest &&
            (identical(other.discussionPath, discussionPath) ||
                other.discussionPath == discussionPath));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, discussionPath);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_GetJuntoCalendarLinkRequestCopyWith<_$_GetJuntoCalendarLinkRequest>
      get copyWith => __$$_GetJuntoCalendarLinkRequestCopyWithImpl<
          _$_GetJuntoCalendarLinkRequest>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_GetJuntoCalendarLinkRequestToJson(
      this,
    );
  }
}

abstract class _GetJuntoCalendarLinkRequest
    implements GetJuntoCalendarLinkRequest {
  factory _GetJuntoCalendarLinkRequest({required final String discussionPath}) =
      _$_GetJuntoCalendarLinkRequest;

  factory _GetJuntoCalendarLinkRequest.fromJson(Map<String, dynamic> json) =
      _$_GetJuntoCalendarLinkRequest.fromJson;

  @override
  String get discussionPath;
  @override
  @JsonKey(ignore: true)
  _$$_GetJuntoCalendarLinkRequestCopyWith<_$_GetJuntoCalendarLinkRequest>
      get copyWith => throw _privateConstructorUsedError;
}

GetJuntoCalendarLinkResponse _$GetJuntoCalendarLinkResponseFromJson(
    Map<String, dynamic> json) {
  return _GetJuntoCalendarLinkResponse.fromJson(json);
}

/// @nodoc
mixin _$GetJuntoCalendarLinkResponse {
  String get googleCalendarLink => throw _privateConstructorUsedError;
  String get outlookCalendarLink => throw _privateConstructorUsedError;
  String get office365CalendarLink => throw _privateConstructorUsedError;
  String get icsLink => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $GetJuntoCalendarLinkResponseCopyWith<GetJuntoCalendarLinkResponse>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GetJuntoCalendarLinkResponseCopyWith<$Res> {
  factory $GetJuntoCalendarLinkResponseCopyWith(
          GetJuntoCalendarLinkResponse value,
          $Res Function(GetJuntoCalendarLinkResponse) then) =
      _$GetJuntoCalendarLinkResponseCopyWithImpl<$Res,
          GetJuntoCalendarLinkResponse>;
  @useResult
  $Res call(
      {String googleCalendarLink,
      String outlookCalendarLink,
      String office365CalendarLink,
      String icsLink});
}

/// @nodoc
class _$GetJuntoCalendarLinkResponseCopyWithImpl<$Res,
        $Val extends GetJuntoCalendarLinkResponse>
    implements $GetJuntoCalendarLinkResponseCopyWith<$Res> {
  _$GetJuntoCalendarLinkResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? googleCalendarLink = null,
    Object? outlookCalendarLink = null,
    Object? office365CalendarLink = null,
    Object? icsLink = null,
  }) {
    return _then(_value.copyWith(
      googleCalendarLink: null == googleCalendarLink
          ? _value.googleCalendarLink
          : googleCalendarLink // ignore: cast_nullable_to_non_nullable
              as String,
      outlookCalendarLink: null == outlookCalendarLink
          ? _value.outlookCalendarLink
          : outlookCalendarLink // ignore: cast_nullable_to_non_nullable
              as String,
      office365CalendarLink: null == office365CalendarLink
          ? _value.office365CalendarLink
          : office365CalendarLink // ignore: cast_nullable_to_non_nullable
              as String,
      icsLink: null == icsLink
          ? _value.icsLink
          : icsLink // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_GetJuntoCalendarLinkResponseCopyWith<$Res>
    implements $GetJuntoCalendarLinkResponseCopyWith<$Res> {
  factory _$$_GetJuntoCalendarLinkResponseCopyWith(
          _$_GetJuntoCalendarLinkResponse value,
          $Res Function(_$_GetJuntoCalendarLinkResponse) then) =
      __$$_GetJuntoCalendarLinkResponseCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String googleCalendarLink,
      String outlookCalendarLink,
      String office365CalendarLink,
      String icsLink});
}

/// @nodoc
class __$$_GetJuntoCalendarLinkResponseCopyWithImpl<$Res>
    extends _$GetJuntoCalendarLinkResponseCopyWithImpl<$Res,
        _$_GetJuntoCalendarLinkResponse>
    implements _$$_GetJuntoCalendarLinkResponseCopyWith<$Res> {
  __$$_GetJuntoCalendarLinkResponseCopyWithImpl(
      _$_GetJuntoCalendarLinkResponse _value,
      $Res Function(_$_GetJuntoCalendarLinkResponse) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? googleCalendarLink = null,
    Object? outlookCalendarLink = null,
    Object? office365CalendarLink = null,
    Object? icsLink = null,
  }) {
    return _then(_$_GetJuntoCalendarLinkResponse(
      googleCalendarLink: null == googleCalendarLink
          ? _value.googleCalendarLink
          : googleCalendarLink // ignore: cast_nullable_to_non_nullable
              as String,
      outlookCalendarLink: null == outlookCalendarLink
          ? _value.outlookCalendarLink
          : outlookCalendarLink // ignore: cast_nullable_to_non_nullable
              as String,
      office365CalendarLink: null == office365CalendarLink
          ? _value.office365CalendarLink
          : office365CalendarLink // ignore: cast_nullable_to_non_nullable
              as String,
      icsLink: null == icsLink
          ? _value.icsLink
          : icsLink // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_GetJuntoCalendarLinkResponse implements _GetJuntoCalendarLinkResponse {
  _$_GetJuntoCalendarLinkResponse(
      {required this.googleCalendarLink,
      required this.outlookCalendarLink,
      required this.office365CalendarLink,
      required this.icsLink});

  factory _$_GetJuntoCalendarLinkResponse.fromJson(Map<String, dynamic> json) =>
      _$$_GetJuntoCalendarLinkResponseFromJson(json);

  @override
  final String googleCalendarLink;
  @override
  final String outlookCalendarLink;
  @override
  final String office365CalendarLink;
  @override
  final String icsLink;

  @override
  String toString() {
    return 'GetJuntoCalendarLinkResponse(googleCalendarLink: $googleCalendarLink, outlookCalendarLink: $outlookCalendarLink, office365CalendarLink: $office365CalendarLink, icsLink: $icsLink)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_GetJuntoCalendarLinkResponse &&
            (identical(other.googleCalendarLink, googleCalendarLink) ||
                other.googleCalendarLink == googleCalendarLink) &&
            (identical(other.outlookCalendarLink, outlookCalendarLink) ||
                other.outlookCalendarLink == outlookCalendarLink) &&
            (identical(other.office365CalendarLink, office365CalendarLink) ||
                other.office365CalendarLink == office365CalendarLink) &&
            (identical(other.icsLink, icsLink) || other.icsLink == icsLink));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, googleCalendarLink,
      outlookCalendarLink, office365CalendarLink, icsLink);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_GetJuntoCalendarLinkResponseCopyWith<_$_GetJuntoCalendarLinkResponse>
      get copyWith => __$$_GetJuntoCalendarLinkResponseCopyWithImpl<
          _$_GetJuntoCalendarLinkResponse>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_GetJuntoCalendarLinkResponseToJson(
      this,
    );
  }
}

abstract class _GetJuntoCalendarLinkResponse
    implements GetJuntoCalendarLinkResponse {
  factory _GetJuntoCalendarLinkResponse(
      {required final String googleCalendarLink,
      required final String outlookCalendarLink,
      required final String office365CalendarLink,
      required final String icsLink}) = _$_GetJuntoCalendarLinkResponse;

  factory _GetJuntoCalendarLinkResponse.fromJson(Map<String, dynamic> json) =
      _$_GetJuntoCalendarLinkResponse.fromJson;

  @override
  String get googleCalendarLink;
  @override
  String get outlookCalendarLink;
  @override
  String get office365CalendarLink;
  @override
  String get icsLink;
  @override
  @JsonKey(ignore: true)
  _$$_GetJuntoCalendarLinkResponseCopyWith<_$_GetJuntoCalendarLinkResponse>
      get copyWith => throw _privateConstructorUsedError;
}

GetUserIdFromAgoraIdRequest _$GetUserIdFromAgoraIdRequestFromJson(
    Map<String, dynamic> json) {
  return _GetUserIdFromAgoraIdRequest.fromJson(json);
}

/// @nodoc
mixin _$GetUserIdFromAgoraIdRequest {
  int get agoraId => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $GetUserIdFromAgoraIdRequestCopyWith<GetUserIdFromAgoraIdRequest>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GetUserIdFromAgoraIdRequestCopyWith<$Res> {
  factory $GetUserIdFromAgoraIdRequestCopyWith(
          GetUserIdFromAgoraIdRequest value,
          $Res Function(GetUserIdFromAgoraIdRequest) then) =
      _$GetUserIdFromAgoraIdRequestCopyWithImpl<$Res,
          GetUserIdFromAgoraIdRequest>;
  @useResult
  $Res call({int agoraId});
}

/// @nodoc
class _$GetUserIdFromAgoraIdRequestCopyWithImpl<$Res,
        $Val extends GetUserIdFromAgoraIdRequest>
    implements $GetUserIdFromAgoraIdRequestCopyWith<$Res> {
  _$GetUserIdFromAgoraIdRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? agoraId = null,
  }) {
    return _then(_value.copyWith(
      agoraId: null == agoraId
          ? _value.agoraId
          : agoraId // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_GetUserIdFromAgoraIdRequestCopyWith<$Res>
    implements $GetUserIdFromAgoraIdRequestCopyWith<$Res> {
  factory _$$_GetUserIdFromAgoraIdRequestCopyWith(
          _$_GetUserIdFromAgoraIdRequest value,
          $Res Function(_$_GetUserIdFromAgoraIdRequest) then) =
      __$$_GetUserIdFromAgoraIdRequestCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int agoraId});
}

/// @nodoc
class __$$_GetUserIdFromAgoraIdRequestCopyWithImpl<$Res>
    extends _$GetUserIdFromAgoraIdRequestCopyWithImpl<$Res,
        _$_GetUserIdFromAgoraIdRequest>
    implements _$$_GetUserIdFromAgoraIdRequestCopyWith<$Res> {
  __$$_GetUserIdFromAgoraIdRequestCopyWithImpl(
      _$_GetUserIdFromAgoraIdRequest _value,
      $Res Function(_$_GetUserIdFromAgoraIdRequest) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? agoraId = null,
  }) {
    return _then(_$_GetUserIdFromAgoraIdRequest(
      agoraId: null == agoraId
          ? _value.agoraId
          : agoraId // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_GetUserIdFromAgoraIdRequest implements _GetUserIdFromAgoraIdRequest {
  _$_GetUserIdFromAgoraIdRequest({required this.agoraId});

  factory _$_GetUserIdFromAgoraIdRequest.fromJson(Map<String, dynamic> json) =>
      _$$_GetUserIdFromAgoraIdRequestFromJson(json);

  @override
  final int agoraId;

  @override
  String toString() {
    return 'GetUserIdFromAgoraIdRequest(agoraId: $agoraId)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_GetUserIdFromAgoraIdRequest &&
            (identical(other.agoraId, agoraId) || other.agoraId == agoraId));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, agoraId);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_GetUserIdFromAgoraIdRequestCopyWith<_$_GetUserIdFromAgoraIdRequest>
      get copyWith => __$$_GetUserIdFromAgoraIdRequestCopyWithImpl<
          _$_GetUserIdFromAgoraIdRequest>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_GetUserIdFromAgoraIdRequestToJson(
      this,
    );
  }
}

abstract class _GetUserIdFromAgoraIdRequest
    implements GetUserIdFromAgoraIdRequest {
  factory _GetUserIdFromAgoraIdRequest({required final int agoraId}) =
      _$_GetUserIdFromAgoraIdRequest;

  factory _GetUserIdFromAgoraIdRequest.fromJson(Map<String, dynamic> json) =
      _$_GetUserIdFromAgoraIdRequest.fromJson;

  @override
  int get agoraId;
  @override
  @JsonKey(ignore: true)
  _$$_GetUserIdFromAgoraIdRequestCopyWith<_$_GetUserIdFromAgoraIdRequest>
      get copyWith => throw _privateConstructorUsedError;
}

GetUserIdFromAgoraIdResponse _$GetUserIdFromAgoraIdResponseFromJson(
    Map<String, dynamic> json) {
  return _GetUserIdFromAgoraIdResponse.fromJson(json);
}

/// @nodoc
mixin _$GetUserIdFromAgoraIdResponse {
  String get userId => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $GetUserIdFromAgoraIdResponseCopyWith<GetUserIdFromAgoraIdResponse>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GetUserIdFromAgoraIdResponseCopyWith<$Res> {
  factory $GetUserIdFromAgoraIdResponseCopyWith(
          GetUserIdFromAgoraIdResponse value,
          $Res Function(GetUserIdFromAgoraIdResponse) then) =
      _$GetUserIdFromAgoraIdResponseCopyWithImpl<$Res,
          GetUserIdFromAgoraIdResponse>;
  @useResult
  $Res call({String userId});
}

/// @nodoc
class _$GetUserIdFromAgoraIdResponseCopyWithImpl<$Res,
        $Val extends GetUserIdFromAgoraIdResponse>
    implements $GetUserIdFromAgoraIdResponseCopyWith<$Res> {
  _$GetUserIdFromAgoraIdResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
  }) {
    return _then(_value.copyWith(
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_GetUserIdFromAgoraIdResponseCopyWith<$Res>
    implements $GetUserIdFromAgoraIdResponseCopyWith<$Res> {
  factory _$$_GetUserIdFromAgoraIdResponseCopyWith(
          _$_GetUserIdFromAgoraIdResponse value,
          $Res Function(_$_GetUserIdFromAgoraIdResponse) then) =
      __$$_GetUserIdFromAgoraIdResponseCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String userId});
}

/// @nodoc
class __$$_GetUserIdFromAgoraIdResponseCopyWithImpl<$Res>
    extends _$GetUserIdFromAgoraIdResponseCopyWithImpl<$Res,
        _$_GetUserIdFromAgoraIdResponse>
    implements _$$_GetUserIdFromAgoraIdResponseCopyWith<$Res> {
  __$$_GetUserIdFromAgoraIdResponseCopyWithImpl(
      _$_GetUserIdFromAgoraIdResponse _value,
      $Res Function(_$_GetUserIdFromAgoraIdResponse) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
  }) {
    return _then(_$_GetUserIdFromAgoraIdResponse(
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_GetUserIdFromAgoraIdResponse implements _GetUserIdFromAgoraIdResponse {
  _$_GetUserIdFromAgoraIdResponse({required this.userId});

  factory _$_GetUserIdFromAgoraIdResponse.fromJson(Map<String, dynamic> json) =>
      _$$_GetUserIdFromAgoraIdResponseFromJson(json);

  @override
  final String userId;

  @override
  String toString() {
    return 'GetUserIdFromAgoraIdResponse(userId: $userId)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_GetUserIdFromAgoraIdResponse &&
            (identical(other.userId, userId) || other.userId == userId));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, userId);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_GetUserIdFromAgoraIdResponseCopyWith<_$_GetUserIdFromAgoraIdResponse>
      get copyWith => __$$_GetUserIdFromAgoraIdResponseCopyWithImpl<
          _$_GetUserIdFromAgoraIdResponse>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_GetUserIdFromAgoraIdResponseToJson(
      this,
    );
  }
}

abstract class _GetUserIdFromAgoraIdResponse
    implements GetUserIdFromAgoraIdResponse {
  factory _GetUserIdFromAgoraIdResponse({required final String userId}) =
      _$_GetUserIdFromAgoraIdResponse;

  factory _GetUserIdFromAgoraIdResponse.fromJson(Map<String, dynamic> json) =
      _$_GetUserIdFromAgoraIdResponse.fromJson;

  @override
  String get userId;
  @override
  @JsonKey(ignore: true)
  _$$_GetUserIdFromAgoraIdResponseCopyWith<_$_GetUserIdFromAgoraIdResponse>
      get copyWith => throw _privateConstructorUsedError;
}
