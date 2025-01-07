// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'template.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

Template _$TemplateFromJson(Map<String, dynamic> json) {
  return _Template.fromJson(json);
}

/// @nodoc
mixin _$Template {
  String get id => throw _privateConstructorUsedError;
  String? get collectionPath => throw _privateConstructorUsedError;

  /// If set indicates where in the order this template should be. Lower priorities are shown first
  /// followed by any templates with null.
  ///
  /// Currently only applies to the "What we're talking about" section.
  int? get orderingPriority => throw _privateConstructorUsedError;
  String? get creatorId => throw _privateConstructorUsedError;
  String? get prerequisiteTemplateId => throw _privateConstructorUsedError;
  @JsonKey(fromJson: dateTimeFromTimestamp, toJson: serverTimestamp)
  DateTime? get createdDate => throw _privateConstructorUsedError;
  String? get title => throw _privateConstructorUsedError;
  String? get url => throw _privateConstructorUsedError;
  String? get image => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  String? get category => throw _privateConstructorUsedError;
  EventSettings? get eventSettings => throw _privateConstructorUsedError;
  bool get isOfficial => throw _privateConstructorUsedError;
  @JsonKey(
      defaultValue: TemplateStatus.active,
      unknownEnumValue: TemplateStatus.active)
  TemplateStatus get status => throw _privateConstructorUsedError;
  List<AgendaItem> get agendaItems => throw _privateConstructorUsedError;
  PrePostCard? get preEventCardData => throw _privateConstructorUsedError;
  PrePostCard? get postEventCardData => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $TemplateCopyWith<Template> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TemplateCopyWith<$Res> {
  factory $TemplateCopyWith(Template value, $Res Function(Template) then) =
      _$TemplateCopyWithImpl<$Res, Template>;
  @useResult
  $Res call(
      {String id,
      String? collectionPath,
      int? orderingPriority,
      String? creatorId,
      String? prerequisiteTemplateId,
      @JsonKey(fromJson: dateTimeFromTimestamp, toJson: serverTimestamp)
      DateTime? createdDate,
      String? title,
      String? url,
      String? image,
      String? description,
      String? category,
      EventSettings? eventSettings,
      bool isOfficial,
      @JsonKey(
          defaultValue: TemplateStatus.active,
          unknownEnumValue: TemplateStatus.active)
      TemplateStatus status,
      List<AgendaItem> agendaItems,
      PrePostCard? preEventCardData,
      PrePostCard? postEventCardData});

  $EventSettingsCopyWith<$Res>? get eventSettings;
  $PrePostCardCopyWith<$Res>? get preEventCardData;
  $PrePostCardCopyWith<$Res>? get postEventCardData;
}

/// @nodoc
class _$TemplateCopyWithImpl<$Res, $Val extends Template>
    implements $TemplateCopyWith<$Res> {
  _$TemplateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? collectionPath = freezed,
    Object? orderingPriority = freezed,
    Object? creatorId = freezed,
    Object? prerequisiteTemplateId = freezed,
    Object? createdDate = freezed,
    Object? title = freezed,
    Object? url = freezed,
    Object? image = freezed,
    Object? description = freezed,
    Object? category = freezed,
    Object? eventSettings = freezed,
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
      collectionPath: freezed == collectionPath
          ? _value.collectionPath
          : collectionPath // ignore: cast_nullable_to_non_nullable
              as String?,
      orderingPriority: freezed == orderingPriority
          ? _value.orderingPriority
          : orderingPriority // ignore: cast_nullable_to_non_nullable
              as int?,
      creatorId: freezed == creatorId
          ? _value.creatorId
          : creatorId // ignore: cast_nullable_to_non_nullable
              as String?,
      prerequisiteTemplateId: freezed == prerequisiteTemplateId
          ? _value.prerequisiteTemplateId
          : prerequisiteTemplateId // ignore: cast_nullable_to_non_nullable
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
      eventSettings: freezed == eventSettings
          ? _value.eventSettings
          : eventSettings // ignore: cast_nullable_to_non_nullable
              as EventSettings?,
      isOfficial: null == isOfficial
          ? _value.isOfficial
          : isOfficial // ignore: cast_nullable_to_non_nullable
              as bool,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as TemplateStatus,
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
  $EventSettingsCopyWith<$Res>? get eventSettings {
    if (_value.eventSettings == null) {
      return null;
    }

    return $EventSettingsCopyWith<$Res>(_value.eventSettings!, (value) {
      return _then(_value.copyWith(eventSettings: value) as $Val);
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
abstract class _$$_TemplateCopyWith<$Res> implements $TemplateCopyWith<$Res> {
  factory _$$_TemplateCopyWith(
          _$_Template value, $Res Function(_$_Template) then) =
      __$$_TemplateCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String? collectionPath,
      int? orderingPriority,
      String? creatorId,
      String? prerequisiteTemplateId,
      @JsonKey(fromJson: dateTimeFromTimestamp, toJson: serverTimestamp)
      DateTime? createdDate,
      String? title,
      String? url,
      String? image,
      String? description,
      String? category,
      EventSettings? eventSettings,
      bool isOfficial,
      @JsonKey(
          defaultValue: TemplateStatus.active,
          unknownEnumValue: TemplateStatus.active)
      TemplateStatus status,
      List<AgendaItem> agendaItems,
      PrePostCard? preEventCardData,
      PrePostCard? postEventCardData});

  @override
  $EventSettingsCopyWith<$Res>? get eventSettings;
  @override
  $PrePostCardCopyWith<$Res>? get preEventCardData;
  @override
  $PrePostCardCopyWith<$Res>? get postEventCardData;
}

/// @nodoc
class __$$_TemplateCopyWithImpl<$Res>
    extends _$TemplateCopyWithImpl<$Res, _$_Template>
    implements _$$_TemplateCopyWith<$Res> {
  __$$_TemplateCopyWithImpl(
      _$_Template _value, $Res Function(_$_Template) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? collectionPath = freezed,
    Object? orderingPriority = freezed,
    Object? creatorId = freezed,
    Object? prerequisiteTemplateId = freezed,
    Object? createdDate = freezed,
    Object? title = freezed,
    Object? url = freezed,
    Object? image = freezed,
    Object? description = freezed,
    Object? category = freezed,
    Object? eventSettings = freezed,
    Object? isOfficial = null,
    Object? status = null,
    Object? agendaItems = null,
    Object? preEventCardData = freezed,
    Object? postEventCardData = freezed,
  }) {
    return _then(_$_Template(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      collectionPath: freezed == collectionPath
          ? _value.collectionPath
          : collectionPath // ignore: cast_nullable_to_non_nullable
              as String?,
      orderingPriority: freezed == orderingPriority
          ? _value.orderingPriority
          : orderingPriority // ignore: cast_nullable_to_non_nullable
              as int?,
      creatorId: freezed == creatorId
          ? _value.creatorId
          : creatorId // ignore: cast_nullable_to_non_nullable
              as String?,
      prerequisiteTemplateId: freezed == prerequisiteTemplateId
          ? _value.prerequisiteTemplateId
          : prerequisiteTemplateId // ignore: cast_nullable_to_non_nullable
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
      eventSettings: freezed == eventSettings
          ? _value.eventSettings
          : eventSettings // ignore: cast_nullable_to_non_nullable
              as EventSettings?,
      isOfficial: null == isOfficial
          ? _value.isOfficial
          : isOfficial // ignore: cast_nullable_to_non_nullable
              as bool,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as TemplateStatus,
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
class _$_Template extends _Template {
  const _$_Template(
      {required this.id,
      this.collectionPath,
      this.orderingPriority,
      this.creatorId,
      this.prerequisiteTemplateId,
      @JsonKey(fromJson: dateTimeFromTimestamp, toJson: serverTimestamp)
      this.createdDate,
      this.title,
      this.url,
      this.image,
      this.description,
      this.category,
      this.eventSettings,
      this.isOfficial = true,
      @JsonKey(
          defaultValue: TemplateStatus.active,
          unknownEnumValue: TemplateStatus.active)
      this.status = TemplateStatus.active,
      this.agendaItems = const [],
      this.preEventCardData,
      this.postEventCardData})
      : super._();

  factory _$_Template.fromJson(Map<String, dynamic> json) =>
      _$$_TemplateFromJson(json);

  @override
  final String id;
  @override
  final String? collectionPath;

  /// If set indicates where in the order this template should be. Lower priorities are shown first
  /// followed by any templates with null.
  ///
  /// Currently only applies to the "What we're talking about" section.
  @override
  final int? orderingPriority;
  @override
  final String? creatorId;
  @override
  final String? prerequisiteTemplateId;
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
  final EventSettings? eventSettings;
  @override
  @JsonKey()
  final bool isOfficial;
  @override
  @JsonKey(
      defaultValue: TemplateStatus.active,
      unknownEnumValue: TemplateStatus.active)
  final TemplateStatus status;
  @override
  @JsonKey()
  final List<AgendaItem> agendaItems;
  @override
  final PrePostCard? preEventCardData;
  @override
  final PrePostCard? postEventCardData;

  @override
  String toString() {
    return 'Template(id: $id, collectionPath: $collectionPath, orderingPriority: $orderingPriority, creatorId: $creatorId, prerequisiteTemplateId: $prerequisiteTemplateId, createdDate: $createdDate, title: $title, url: $url, image: $image, description: $description, category: $category, eventSettings: $eventSettings, isOfficial: $isOfficial, status: $status, agendaItems: $agendaItems, preEventCardData: $preEventCardData, postEventCardData: $postEventCardData)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_Template &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.collectionPath, collectionPath) ||
                other.collectionPath == collectionPath) &&
            (identical(other.orderingPriority, orderingPriority) ||
                other.orderingPriority == orderingPriority) &&
            (identical(other.creatorId, creatorId) ||
                other.creatorId == creatorId) &&
            (identical(other.prerequisiteTemplateId, prerequisiteTemplateId) ||
                other.prerequisiteTemplateId == prerequisiteTemplateId) &&
            (identical(other.createdDate, createdDate) ||
                other.createdDate == createdDate) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.url, url) || other.url == url) &&
            (identical(other.image, image) || other.image == image) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.eventSettings, eventSettings) ||
                other.eventSettings == eventSettings) &&
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
      prerequisiteTemplateId,
      createdDate,
      title,
      url,
      image,
      description,
      category,
      eventSettings,
      isOfficial,
      status,
      const DeepCollectionEquality().hash(agendaItems),
      preEventCardData,
      postEventCardData);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_TemplateCopyWith<_$_Template> get copyWith =>
      __$$_TemplateCopyWithImpl<_$_Template>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_TemplateToJson(
      this,
    );
  }
}

abstract class _Template extends Template {
  const factory _Template(
      {required final String id,
      final String? collectionPath,
      final int? orderingPriority,
      final String? creatorId,
      final String? prerequisiteTemplateId,
      @JsonKey(fromJson: dateTimeFromTimestamp, toJson: serverTimestamp)
      final DateTime? createdDate,
      final String? title,
      final String? url,
      final String? image,
      final String? description,
      final String? category,
      final EventSettings? eventSettings,
      final bool isOfficial,
      @JsonKey(
          defaultValue: TemplateStatus.active,
          unknownEnumValue: TemplateStatus.active)
      final TemplateStatus status,
      final List<AgendaItem> agendaItems,
      final PrePostCard? preEventCardData,
      final PrePostCard? postEventCardData}) = _$_Template;
  const _Template._() : super._();

  factory _Template.fromJson(Map<String, dynamic> json) = _$_Template.fromJson;

  @override
  String get id;
  @override
  String? get collectionPath;
  @override

  /// If set indicates where in the order this template should be. Lower priorities are shown first
  /// followed by any templates with null.
  ///
  /// Currently only applies to the "What we're talking about" section.
  int? get orderingPriority;
  @override
  String? get creatorId;
  @override
  String? get prerequisiteTemplateId;
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
  EventSettings? get eventSettings;
  @override
  bool get isOfficial;
  @override
  @JsonKey(
      defaultValue: TemplateStatus.active,
      unknownEnumValue: TemplateStatus.active)
  TemplateStatus get status;
  @override
  List<AgendaItem> get agendaItems;
  @override
  PrePostCard? get preEventCardData;
  @override
  PrePostCard? get postEventCardData;
  @override
  @JsonKey(ignore: true)
  _$$_TemplateCopyWith<_$_Template> get copyWith =>
      throw _privateConstructorUsedError;
}
