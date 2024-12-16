// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'topic.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

Topic _$TopicFromJson(Map<String, dynamic> json) {
  return _Topic.fromJson(json);
}

/// @nodoc
mixin _$Topic {
  String get id => throw _privateConstructorUsedError;
  String get collectionPath => throw _privateConstructorUsedError;

  /// If set indicates where in the order this topic should be. Lower priorities are shown first
  /// followed by any topics with null.
  ///
  /// Currently only applies to the "What we're talking about" section.
  int? get orderingPriority => throw _privateConstructorUsedError;
  String get creatorId => throw _privateConstructorUsedError;
  String? get prerequisiteTopicId => throw _privateConstructorUsedError;
  @JsonKey(fromJson: dateTimeFromTimestamp, toJson: serverTimestamp)
  DateTime? get createdDate => throw _privateConstructorUsedError;
  String? get title => throw _privateConstructorUsedError;
  String? get url => throw _privateConstructorUsedError;
  String? get image => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  String? get category => throw _privateConstructorUsedError;
  DiscussionSettings? get discussionSettings =>
      throw _privateConstructorUsedError;
  bool get isOfficial => throw _privateConstructorUsedError;
  @JsonKey(
      defaultValue: TopicStatus.active, unknownEnumValue: TopicStatus.active)
  TopicStatus get status => throw _privateConstructorUsedError;
  List<AgendaItem> get agendaItems => throw _privateConstructorUsedError;
  PrePostCard? get preEventCardData => throw _privateConstructorUsedError;
  PrePostCard? get postEventCardData => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $TopicCopyWith<Topic> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TopicCopyWith<$Res> {
  factory $TopicCopyWith(Topic value, $Res Function(Topic) then) =
      _$TopicCopyWithImpl<$Res, Topic>;
  @useResult
  $Res call(
      {String id,
      String collectionPath,
      int? orderingPriority,
      String creatorId,
      String? prerequisiteTopicId,
      @JsonKey(fromJson: dateTimeFromTimestamp, toJson: serverTimestamp)
      DateTime? createdDate,
      String? title,
      String? url,
      String? image,
      String? description,
      String? category,
      DiscussionSettings? discussionSettings,
      bool isOfficial,
      @JsonKey(
          defaultValue: TopicStatus.active,
          unknownEnumValue: TopicStatus.active)
      TopicStatus status,
      List<AgendaItem> agendaItems,
      PrePostCard? preEventCardData,
      PrePostCard? postEventCardData});

  $DiscussionSettingsCopyWith<$Res>? get discussionSettings;
  $PrePostCardCopyWith<$Res>? get preEventCardData;
  $PrePostCardCopyWith<$Res>? get postEventCardData;
}

/// @nodoc
class _$TopicCopyWithImpl<$Res, $Val extends Topic>
    implements $TopicCopyWith<$Res> {
  _$TopicCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? collectionPath = null,
    Object? orderingPriority = freezed,
    Object? creatorId = null,
    Object? prerequisiteTopicId = freezed,
    Object? createdDate = freezed,
    Object? title = freezed,
    Object? url = freezed,
    Object? image = freezed,
    Object? description = freezed,
    Object? category = freezed,
    Object? discussionSettings = freezed,
    Object? isOfficial = null,
    Object? status = null,
    Object? agendaItems = null,
    Object? preEventCardData = freezed,
    Object? postEventCardData = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      collectionPath: null == collectionPath
          ? _value.collectionPath
          : collectionPath // ignore: cast_nullable_to_non_nullable
              as String,
      orderingPriority: freezed == orderingPriority
          ? _value.orderingPriority
          : orderingPriority // ignore: cast_nullable_to_non_nullable
              as int?,
      creatorId: null == creatorId
          ? _value.creatorId
          : creatorId // ignore: cast_nullable_to_non_nullable
              as String,
      prerequisiteTopicId: freezed == prerequisiteTopicId
          ? _value.prerequisiteTopicId
          : prerequisiteTopicId // ignore: cast_nullable_to_non_nullable
              as String?,
      createdDate: freezed == createdDate
          ? _value.createdDate
          : createdDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      title: freezed == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String?,
      url: freezed == url
          ? _value.url
          : url // ignore: cast_nullable_to_non_nullable
              as String?,
      image: freezed == image
          ? _value.image
          : image // ignore: cast_nullable_to_non_nullable
              as String?,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      category: freezed == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as String?,
      discussionSettings: freezed == discussionSettings
          ? _value.discussionSettings
          : discussionSettings // ignore: cast_nullable_to_non_nullable
              as DiscussionSettings?,
      isOfficial: null == isOfficial
          ? _value.isOfficial
          : isOfficial // ignore: cast_nullable_to_non_nullable
              as bool,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as TopicStatus,
      agendaItems: null == agendaItems
          ? _value.agendaItems
          : agendaItems // ignore: cast_nullable_to_non_nullable
              as List<AgendaItem>,
      preEventCardData: freezed == preEventCardData
          ? _value.preEventCardData
          : preEventCardData // ignore: cast_nullable_to_non_nullable
              as PrePostCard?,
      postEventCardData: freezed == postEventCardData
          ? _value.postEventCardData
          : postEventCardData // ignore: cast_nullable_to_non_nullable
              as PrePostCard?,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $DiscussionSettingsCopyWith<$Res>? get discussionSettings {
    if (_value.discussionSettings == null) {
      return null;
    }

    return $DiscussionSettingsCopyWith<$Res>(_value.discussionSettings!,
        (value) {
      return _then(_value.copyWith(discussionSettings: value) as $Val);
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
}

/// @nodoc
abstract class _$$_TopicCopyWith<$Res> implements $TopicCopyWith<$Res> {
  factory _$$_TopicCopyWith(_$_Topic value, $Res Function(_$_Topic) then) =
      __$$_TopicCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String collectionPath,
      int? orderingPriority,
      String creatorId,
      String? prerequisiteTopicId,
      @JsonKey(fromJson: dateTimeFromTimestamp, toJson: serverTimestamp)
      DateTime? createdDate,
      String? title,
      String? url,
      String? image,
      String? description,
      String? category,
      DiscussionSettings? discussionSettings,
      bool isOfficial,
      @JsonKey(
          defaultValue: TopicStatus.active,
          unknownEnumValue: TopicStatus.active)
      TopicStatus status,
      List<AgendaItem> agendaItems,
      PrePostCard? preEventCardData,
      PrePostCard? postEventCardData});

  @override
  $DiscussionSettingsCopyWith<$Res>? get discussionSettings;
  @override
  $PrePostCardCopyWith<$Res>? get preEventCardData;
  @override
  $PrePostCardCopyWith<$Res>? get postEventCardData;
}

/// @nodoc
class __$$_TopicCopyWithImpl<$Res> extends _$TopicCopyWithImpl<$Res, _$_Topic>
    implements _$$_TopicCopyWith<$Res> {
  __$$_TopicCopyWithImpl(_$_Topic _value, $Res Function(_$_Topic) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? collectionPath = null,
    Object? orderingPriority = freezed,
    Object? creatorId = null,
    Object? prerequisiteTopicId = freezed,
    Object? createdDate = freezed,
    Object? title = freezed,
    Object? url = freezed,
    Object? image = freezed,
    Object? description = freezed,
    Object? category = freezed,
    Object? discussionSettings = freezed,
    Object? isOfficial = null,
    Object? status = null,
    Object? agendaItems = null,
    Object? preEventCardData = freezed,
    Object? postEventCardData = freezed,
  }) {
    return _then(_$_Topic(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      collectionPath: null == collectionPath
          ? _value.collectionPath
          : collectionPath // ignore: cast_nullable_to_non_nullable
              as String,
      orderingPriority: freezed == orderingPriority
          ? _value.orderingPriority
          : orderingPriority // ignore: cast_nullable_to_non_nullable
              as int?,
      creatorId: null == creatorId
          ? _value.creatorId
          : creatorId // ignore: cast_nullable_to_non_nullable
              as String,
      prerequisiteTopicId: freezed == prerequisiteTopicId
          ? _value.prerequisiteTopicId
          : prerequisiteTopicId // ignore: cast_nullable_to_non_nullable
              as String?,
      createdDate: freezed == createdDate
          ? _value.createdDate
          : createdDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      title: freezed == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String?,
      url: freezed == url
          ? _value.url
          : url // ignore: cast_nullable_to_non_nullable
              as String?,
      image: freezed == image
          ? _value.image
          : image // ignore: cast_nullable_to_non_nullable
              as String?,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      category: freezed == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as String?,
      discussionSettings: freezed == discussionSettings
          ? _value.discussionSettings
          : discussionSettings // ignore: cast_nullable_to_non_nullable
              as DiscussionSettings?,
      isOfficial: null == isOfficial
          ? _value.isOfficial
          : isOfficial // ignore: cast_nullable_to_non_nullable
              as bool,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as TopicStatus,
      agendaItems: null == agendaItems
          ? _value.agendaItems
          : agendaItems // ignore: cast_nullable_to_non_nullable
              as List<AgendaItem>,
      preEventCardData: freezed == preEventCardData
          ? _value.preEventCardData
          : preEventCardData // ignore: cast_nullable_to_non_nullable
              as PrePostCard?,
      postEventCardData: freezed == postEventCardData
          ? _value.postEventCardData
          : postEventCardData // ignore: cast_nullable_to_non_nullable
              as PrePostCard?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_Topic extends _Topic {
  const _$_Topic(
      {required this.id,
      required this.collectionPath,
      this.orderingPriority,
      required this.creatorId,
      this.prerequisiteTopicId,
      @JsonKey(fromJson: dateTimeFromTimestamp, toJson: serverTimestamp)
      this.createdDate,
      this.title,
      this.url,
      this.image,
      this.description,
      this.category,
      this.discussionSettings,
      this.isOfficial = true,
      @JsonKey(
          defaultValue: TopicStatus.active,
          unknownEnumValue: TopicStatus.active)
      this.status = TopicStatus.active,
      this.agendaItems = const [],
      this.preEventCardData,
      this.postEventCardData})
      : super._();

  factory _$_Topic.fromJson(Map<String, dynamic> json) =>
      _$$_TopicFromJson(json);

  @override
  final String id;
  @override
  final String collectionPath;

  /// If set indicates where in the order this topic should be. Lower priorities are shown first
  /// followed by any topics with null.
  ///
  /// Currently only applies to the "What we're talking about" section.
  @override
  final int? orderingPriority;
  @override
  final String creatorId;
  @override
  final String? prerequisiteTopicId;
  @override
  @JsonKey(fromJson: dateTimeFromTimestamp, toJson: serverTimestamp)
  final DateTime? createdDate;
  @override
  final String? title;
  @override
  final String? url;
  @override
  final String? image;
  @override
  final String? description;
  @override
  final String? category;
  @override
  final DiscussionSettings? discussionSettings;
  @override
  @JsonKey()
  final bool isOfficial;
  @override
  @JsonKey(
      defaultValue: TopicStatus.active, unknownEnumValue: TopicStatus.active)
  final TopicStatus status;
  @override
  @JsonKey()
  final List<AgendaItem> agendaItems;
  @override
  final PrePostCard? preEventCardData;
  @override
  final PrePostCard? postEventCardData;

  @override
  String toString() {
    return 'Topic(id: $id, collectionPath: $collectionPath, orderingPriority: $orderingPriority, creatorId: $creatorId, prerequisiteTopicId: $prerequisiteTopicId, createdDate: $createdDate, title: $title, url: $url, image: $image, description: $description, category: $category, discussionSettings: $discussionSettings, isOfficial: $isOfficial, status: $status, agendaItems: $agendaItems, preEventCardData: $preEventCardData, postEventCardData: $postEventCardData)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_Topic &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.collectionPath, collectionPath) ||
                other.collectionPath == collectionPath) &&
            (identical(other.orderingPriority, orderingPriority) ||
                other.orderingPriority == orderingPriority) &&
            (identical(other.creatorId, creatorId) ||
                other.creatorId == creatorId) &&
            (identical(other.prerequisiteTopicId, prerequisiteTopicId) ||
                other.prerequisiteTopicId == prerequisiteTopicId) &&
            (identical(other.createdDate, createdDate) ||
                other.createdDate == createdDate) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.url, url) || other.url == url) &&
            (identical(other.image, image) || other.image == image) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.discussionSettings, discussionSettings) ||
                other.discussionSettings == discussionSettings) &&
            (identical(other.isOfficial, isOfficial) ||
                other.isOfficial == isOfficial) &&
            (identical(other.status, status) || other.status == status) &&
            const DeepCollectionEquality()
                .equals(other.agendaItems, agendaItems) &&
            (identical(other.preEventCardData, preEventCardData) ||
                other.preEventCardData == preEventCardData) &&
            (identical(other.postEventCardData, postEventCardData) ||
                other.postEventCardData == postEventCardData));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      collectionPath,
      orderingPriority,
      creatorId,
      prerequisiteTopicId,
      createdDate,
      title,
      url,
      image,
      description,
      category,
      discussionSettings,
      isOfficial,
      status,
      const DeepCollectionEquality().hash(agendaItems),
      preEventCardData,
      postEventCardData);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_TopicCopyWith<_$_Topic> get copyWith =>
      __$$_TopicCopyWithImpl<_$_Topic>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_TopicToJson(
      this,
    );
  }
}

abstract class _Topic extends Topic {
  const factory _Topic(
      {required final String id,
      required final String collectionPath,
      final int? orderingPriority,
      required final String creatorId,
      final String? prerequisiteTopicId,
      @JsonKey(fromJson: dateTimeFromTimestamp, toJson: serverTimestamp)
      final DateTime? createdDate,
      final String? title,
      final String? url,
      final String? image,
      final String? description,
      final String? category,
      final DiscussionSettings? discussionSettings,
      final bool isOfficial,
      @JsonKey(
          defaultValue: TopicStatus.active,
          unknownEnumValue: TopicStatus.active)
      final TopicStatus status,
      final List<AgendaItem> agendaItems,
      final PrePostCard? preEventCardData,
      final PrePostCard? postEventCardData}) = _$_Topic;
  const _Topic._() : super._();

  factory _Topic.fromJson(Map<String, dynamic> json) = _$_Topic.fromJson;

  @override
  String get id;
  @override
  String get collectionPath;
  @override

  /// If set indicates where in the order this topic should be. Lower priorities are shown first
  /// followed by any topics with null.
  ///
  /// Currently only applies to the "What we're talking about" section.
  int? get orderingPriority;
  @override
  String get creatorId;
  @override
  String? get prerequisiteTopicId;
  @override
  @JsonKey(fromJson: dateTimeFromTimestamp, toJson: serverTimestamp)
  DateTime? get createdDate;
  @override
  String? get title;
  @override
  String? get url;
  @override
  String? get image;
  @override
  String? get description;
  @override
  String? get category;
  @override
  DiscussionSettings? get discussionSettings;
  @override
  bool get isOfficial;
  @override
  @JsonKey(
      defaultValue: TopicStatus.active, unknownEnumValue: TopicStatus.active)
  TopicStatus get status;
  @override
  List<AgendaItem> get agendaItems;
  @override
  PrePostCard? get preEventCardData;
  @override
  PrePostCard? get postEventCardData;
  @override
  @JsonKey(ignore: true)
  _$$_TopicCopyWith<_$_Topic> get copyWith =>
      throw _privateConstructorUsedError;
}
