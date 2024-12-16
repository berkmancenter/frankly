// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'junto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

Junto _$JuntoFromJson(Map<String, dynamic> json) {
  return _Junto.fromJson(json);
}

/// @nodoc
mixin _$Junto {
  String get id => throw _privateConstructorUsedError;

  /// List of IDs that correlate to this Junto in the URL bar.
  List<String> get displayIds => throw _privateConstructorUsedError;
  String? get name => throw _privateConstructorUsedError;
  String? get contactEmail => throw _privateConstructorUsedError;
  String? get creatorId => throw _privateConstructorUsedError;
  String? get profileImageUrl => throw _privateConstructorUsedError;
  String? get bannerImageUrl => throw _privateConstructorUsedError;
  @JsonKey(fromJson: dateTimeFromTimestamp, toJson: serverTimestamp)
  DateTime? get createdDate => throw _privateConstructorUsedError;
  bool? get isPublic => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  String? get tagLine => throw _privateConstructorUsedError;
  @JsonKey(fromJson: juntoFeatureFlagsFromJson)
  List<JuntoFeatureFlags> get enabledFeatureFlags =>
      throw _privateConstructorUsedError;
  CommunitySettings? get communitySettings =>
      throw _privateConstructorUsedError;
  DiscussionSettings? get discussionSettings =>
      throw _privateConstructorUsedError;
  String? get donationDialogText => throw _privateConstructorUsedError;
  String? get ratingSurveyUrl => throw _privateConstructorUsedError;
  String? get themeLightColor => throw _privateConstructorUsedError;
  String? get themeDarkColor => throw _privateConstructorUsedError;
  List<OnboardingStep> get onboardingSteps =>
      throw _privateConstructorUsedError;
  bool get isOnboardingOverviewEnabled => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $JuntoCopyWith<Junto> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $JuntoCopyWith<$Res> {
  factory $JuntoCopyWith(Junto value, $Res Function(Junto) then) =
      _$JuntoCopyWithImpl<$Res, Junto>;
  @useResult
  $Res call(
      {String id,
      List<String> displayIds,
      String? name,
      String? contactEmail,
      String? creatorId,
      String? profileImageUrl,
      String? bannerImageUrl,
      @JsonKey(fromJson: dateTimeFromTimestamp, toJson: serverTimestamp)
      DateTime? createdDate,
      bool? isPublic,
      String? description,
      String? tagLine,
      @JsonKey(fromJson: juntoFeatureFlagsFromJson)
      List<JuntoFeatureFlags> enabledFeatureFlags,
      CommunitySettings? communitySettings,
      DiscussionSettings? discussionSettings,
      String? donationDialogText,
      String? ratingSurveyUrl,
      String? themeLightColor,
      String? themeDarkColor,
      List<OnboardingStep> onboardingSteps,
      bool isOnboardingOverviewEnabled});

  $CommunitySettingsCopyWith<$Res>? get communitySettings;
  $DiscussionSettingsCopyWith<$Res>? get discussionSettings;
}

/// @nodoc
class _$JuntoCopyWithImpl<$Res, $Val extends Junto>
    implements $JuntoCopyWith<$Res> {
  _$JuntoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? displayIds = null,
    Object? name = freezed,
    Object? contactEmail = freezed,
    Object? creatorId = freezed,
    Object? profileImageUrl = freezed,
    Object? bannerImageUrl = freezed,
    Object? createdDate = freezed,
    Object? isPublic = freezed,
    Object? description = freezed,
    Object? tagLine = freezed,
    Object? enabledFeatureFlags = null,
    Object? communitySettings = freezed,
    Object? discussionSettings = freezed,
    Object? donationDialogText = freezed,
    Object? ratingSurveyUrl = freezed,
    Object? themeLightColor = freezed,
    Object? themeDarkColor = freezed,
    Object? onboardingSteps = null,
    Object? isOnboardingOverviewEnabled = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      displayIds: null == displayIds
          ? _value.displayIds
          : displayIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
      name: freezed == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String?,
      contactEmail: freezed == contactEmail
          ? _value.contactEmail
          : contactEmail // ignore: cast_nullable_to_non_nullable
              as String?,
      creatorId: freezed == creatorId
          ? _value.creatorId
          : creatorId // ignore: cast_nullable_to_non_nullable
              as String?,
      profileImageUrl: freezed == profileImageUrl
          ? _value.profileImageUrl
          : profileImageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      bannerImageUrl: freezed == bannerImageUrl
          ? _value.bannerImageUrl
          : bannerImageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      createdDate: freezed == createdDate
          ? _value.createdDate
          : createdDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      isPublic: freezed == isPublic
          ? _value.isPublic
          : isPublic // ignore: cast_nullable_to_non_nullable
              as bool?,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      tagLine: freezed == tagLine
          ? _value.tagLine
          : tagLine // ignore: cast_nullable_to_non_nullable
              as String?,
      enabledFeatureFlags: null == enabledFeatureFlags
          ? _value.enabledFeatureFlags
          : enabledFeatureFlags // ignore: cast_nullable_to_non_nullable
              as List<JuntoFeatureFlags>,
      communitySettings: freezed == communitySettings
          ? _value.communitySettings
          : communitySettings // ignore: cast_nullable_to_non_nullable
              as CommunitySettings?,
      discussionSettings: freezed == discussionSettings
          ? _value.discussionSettings
          : discussionSettings // ignore: cast_nullable_to_non_nullable
              as DiscussionSettings?,
      donationDialogText: freezed == donationDialogText
          ? _value.donationDialogText
          : donationDialogText // ignore: cast_nullable_to_non_nullable
              as String?,
      ratingSurveyUrl: freezed == ratingSurveyUrl
          ? _value.ratingSurveyUrl
          : ratingSurveyUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      themeLightColor: freezed == themeLightColor
          ? _value.themeLightColor
          : themeLightColor // ignore: cast_nullable_to_non_nullable
              as String?,
      themeDarkColor: freezed == themeDarkColor
          ? _value.themeDarkColor
          : themeDarkColor // ignore: cast_nullable_to_non_nullable
              as String?,
      onboardingSteps: null == onboardingSteps
          ? _value.onboardingSteps
          : onboardingSteps // ignore: cast_nullable_to_non_nullable
              as List<OnboardingStep>,
      isOnboardingOverviewEnabled: null == isOnboardingOverviewEnabled
          ? _value.isOnboardingOverviewEnabled
          : isOnboardingOverviewEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $CommunitySettingsCopyWith<$Res>? get communitySettings {
    if (_value.communitySettings == null) {
      return null;
    }

    return $CommunitySettingsCopyWith<$Res>(_value.communitySettings!, (value) {
      return _then(_value.copyWith(communitySettings: value) as $Val);
    });
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
}

/// @nodoc
abstract class _$$_JuntoCopyWith<$Res> implements $JuntoCopyWith<$Res> {
  factory _$$_JuntoCopyWith(_$_Junto value, $Res Function(_$_Junto) then) =
      __$$_JuntoCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      List<String> displayIds,
      String? name,
      String? contactEmail,
      String? creatorId,
      String? profileImageUrl,
      String? bannerImageUrl,
      @JsonKey(fromJson: dateTimeFromTimestamp, toJson: serverTimestamp)
      DateTime? createdDate,
      bool? isPublic,
      String? description,
      String? tagLine,
      @JsonKey(fromJson: juntoFeatureFlagsFromJson)
      List<JuntoFeatureFlags> enabledFeatureFlags,
      CommunitySettings? communitySettings,
      DiscussionSettings? discussionSettings,
      String? donationDialogText,
      String? ratingSurveyUrl,
      String? themeLightColor,
      String? themeDarkColor,
      List<OnboardingStep> onboardingSteps,
      bool isOnboardingOverviewEnabled});

  @override
  $CommunitySettingsCopyWith<$Res>? get communitySettings;
  @override
  $DiscussionSettingsCopyWith<$Res>? get discussionSettings;
}

/// @nodoc
class __$$_JuntoCopyWithImpl<$Res> extends _$JuntoCopyWithImpl<$Res, _$_Junto>
    implements _$$_JuntoCopyWith<$Res> {
  __$$_JuntoCopyWithImpl(_$_Junto _value, $Res Function(_$_Junto) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? displayIds = null,
    Object? name = freezed,
    Object? contactEmail = freezed,
    Object? creatorId = freezed,
    Object? profileImageUrl = freezed,
    Object? bannerImageUrl = freezed,
    Object? createdDate = freezed,
    Object? isPublic = freezed,
    Object? description = freezed,
    Object? tagLine = freezed,
    Object? enabledFeatureFlags = null,
    Object? communitySettings = freezed,
    Object? discussionSettings = freezed,
    Object? donationDialogText = freezed,
    Object? ratingSurveyUrl = freezed,
    Object? themeLightColor = freezed,
    Object? themeDarkColor = freezed,
    Object? onboardingSteps = null,
    Object? isOnboardingOverviewEnabled = null,
  }) {
    return _then(_$_Junto(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      displayIds: null == displayIds
          ? _value.displayIds
          : displayIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
      name: freezed == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String?,
      contactEmail: freezed == contactEmail
          ? _value.contactEmail
          : contactEmail // ignore: cast_nullable_to_non_nullable
              as String?,
      creatorId: freezed == creatorId
          ? _value.creatorId
          : creatorId // ignore: cast_nullable_to_non_nullable
              as String?,
      profileImageUrl: freezed == profileImageUrl
          ? _value.profileImageUrl
          : profileImageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      bannerImageUrl: freezed == bannerImageUrl
          ? _value.bannerImageUrl
          : bannerImageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      createdDate: freezed == createdDate
          ? _value.createdDate
          : createdDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      isPublic: freezed == isPublic
          ? _value.isPublic
          : isPublic // ignore: cast_nullable_to_non_nullable
              as bool?,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      tagLine: freezed == tagLine
          ? _value.tagLine
          : tagLine // ignore: cast_nullable_to_non_nullable
              as String?,
      enabledFeatureFlags: null == enabledFeatureFlags
          ? _value.enabledFeatureFlags
          : enabledFeatureFlags // ignore: cast_nullable_to_non_nullable
              as List<JuntoFeatureFlags>,
      communitySettings: freezed == communitySettings
          ? _value.communitySettings
          : communitySettings // ignore: cast_nullable_to_non_nullable
              as CommunitySettings?,
      discussionSettings: freezed == discussionSettings
          ? _value.discussionSettings
          : discussionSettings // ignore: cast_nullable_to_non_nullable
              as DiscussionSettings?,
      donationDialogText: freezed == donationDialogText
          ? _value.donationDialogText
          : donationDialogText // ignore: cast_nullable_to_non_nullable
              as String?,
      ratingSurveyUrl: freezed == ratingSurveyUrl
          ? _value.ratingSurveyUrl
          : ratingSurveyUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      themeLightColor: freezed == themeLightColor
          ? _value.themeLightColor
          : themeLightColor // ignore: cast_nullable_to_non_nullable
              as String?,
      themeDarkColor: freezed == themeDarkColor
          ? _value.themeDarkColor
          : themeDarkColor // ignore: cast_nullable_to_non_nullable
              as String?,
      onboardingSteps: null == onboardingSteps
          ? _value.onboardingSteps
          : onboardingSteps // ignore: cast_nullable_to_non_nullable
              as List<OnboardingStep>,
      isOnboardingOverviewEnabled: null == isOnboardingOverviewEnabled
          ? _value.isOnboardingOverviewEnabled
          : isOnboardingOverviewEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_Junto extends _Junto {
  _$_Junto(
      {required this.id,
      this.displayIds = const [],
      this.name,
      this.contactEmail,
      this.creatorId,
      this.profileImageUrl,
      this.bannerImageUrl,
      @JsonKey(fromJson: dateTimeFromTimestamp, toJson: serverTimestamp)
      this.createdDate,
      this.isPublic,
      this.description,
      this.tagLine,
      @JsonKey(fromJson: juntoFeatureFlagsFromJson)
      this.enabledFeatureFlags = const [],
      this.communitySettings,
      this.discussionSettings,
      this.donationDialogText,
      this.ratingSurveyUrl,
      this.themeLightColor,
      this.themeDarkColor,
      this.onboardingSteps = const [],
      this.isOnboardingOverviewEnabled = false})
      : super._();

  factory _$_Junto.fromJson(Map<String, dynamic> json) =>
      _$$_JuntoFromJson(json);

  @override
  final String id;

  /// List of IDs that correlate to this Junto in the URL bar.
  @override
  @JsonKey()
  final List<String> displayIds;
  @override
  final String? name;
  @override
  final String? contactEmail;
  @override
  final String? creatorId;
  @override
  final String? profileImageUrl;
  @override
  final String? bannerImageUrl;
  @override
  @JsonKey(fromJson: dateTimeFromTimestamp, toJson: serverTimestamp)
  final DateTime? createdDate;
  @override
  final bool? isPublic;
  @override
  final String? description;
  @override
  final String? tagLine;
  @override
  @JsonKey(fromJson: juntoFeatureFlagsFromJson)
  final List<JuntoFeatureFlags> enabledFeatureFlags;
  @override
  final CommunitySettings? communitySettings;
  @override
  final DiscussionSettings? discussionSettings;
  @override
  final String? donationDialogText;
  @override
  final String? ratingSurveyUrl;
  @override
  final String? themeLightColor;
  @override
  final String? themeDarkColor;
  @override
  @JsonKey()
  final List<OnboardingStep> onboardingSteps;
  @override
  @JsonKey()
  final bool isOnboardingOverviewEnabled;

  @override
  String toString() {
    return 'Junto(id: $id, displayIds: $displayIds, name: $name, contactEmail: $contactEmail, creatorId: $creatorId, profileImageUrl: $profileImageUrl, bannerImageUrl: $bannerImageUrl, createdDate: $createdDate, isPublic: $isPublic, description: $description, tagLine: $tagLine, enabledFeatureFlags: $enabledFeatureFlags, communitySettings: $communitySettings, discussionSettings: $discussionSettings, donationDialogText: $donationDialogText, ratingSurveyUrl: $ratingSurveyUrl, themeLightColor: $themeLightColor, themeDarkColor: $themeDarkColor, onboardingSteps: $onboardingSteps, isOnboardingOverviewEnabled: $isOnboardingOverviewEnabled)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_Junto &&
            (identical(other.id, id) || other.id == id) &&
            const DeepCollectionEquality()
                .equals(other.displayIds, displayIds) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.contactEmail, contactEmail) ||
                other.contactEmail == contactEmail) &&
            (identical(other.creatorId, creatorId) ||
                other.creatorId == creatorId) &&
            (identical(other.profileImageUrl, profileImageUrl) ||
                other.profileImageUrl == profileImageUrl) &&
            (identical(other.bannerImageUrl, bannerImageUrl) ||
                other.bannerImageUrl == bannerImageUrl) &&
            (identical(other.createdDate, createdDate) ||
                other.createdDate == createdDate) &&
            (identical(other.isPublic, isPublic) ||
                other.isPublic == isPublic) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.tagLine, tagLine) || other.tagLine == tagLine) &&
            const DeepCollectionEquality()
                .equals(other.enabledFeatureFlags, enabledFeatureFlags) &&
            (identical(other.communitySettings, communitySettings) ||
                other.communitySettings == communitySettings) &&
            (identical(other.discussionSettings, discussionSettings) ||
                other.discussionSettings == discussionSettings) &&
            (identical(other.donationDialogText, donationDialogText) ||
                other.donationDialogText == donationDialogText) &&
            (identical(other.ratingSurveyUrl, ratingSurveyUrl) ||
                other.ratingSurveyUrl == ratingSurveyUrl) &&
            (identical(other.themeLightColor, themeLightColor) ||
                other.themeLightColor == themeLightColor) &&
            (identical(other.themeDarkColor, themeDarkColor) ||
                other.themeDarkColor == themeDarkColor) &&
            const DeepCollectionEquality()
                .equals(other.onboardingSteps, onboardingSteps) &&
            (identical(other.isOnboardingOverviewEnabled,
                    isOnboardingOverviewEnabled) ||
                other.isOnboardingOverviewEnabled ==
                    isOnboardingOverviewEnabled));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        id,
        const DeepCollectionEquality().hash(displayIds),
        name,
        contactEmail,
        creatorId,
        profileImageUrl,
        bannerImageUrl,
        createdDate,
        isPublic,
        description,
        tagLine,
        const DeepCollectionEquality().hash(enabledFeatureFlags),
        communitySettings,
        discussionSettings,
        donationDialogText,
        ratingSurveyUrl,
        themeLightColor,
        themeDarkColor,
        const DeepCollectionEquality().hash(onboardingSteps),
        isOnboardingOverviewEnabled
      ]);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_JuntoCopyWith<_$_Junto> get copyWith =>
      __$$_JuntoCopyWithImpl<_$_Junto>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_JuntoToJson(
      this,
    );
  }
}

abstract class _Junto extends Junto {
  factory _Junto(
      {required final String id,
      final List<String> displayIds,
      final String? name,
      final String? contactEmail,
      final String? creatorId,
      final String? profileImageUrl,
      final String? bannerImageUrl,
      @JsonKey(fromJson: dateTimeFromTimestamp, toJson: serverTimestamp)
      final DateTime? createdDate,
      final bool? isPublic,
      final String? description,
      final String? tagLine,
      @JsonKey(fromJson: juntoFeatureFlagsFromJson)
      final List<JuntoFeatureFlags> enabledFeatureFlags,
      final CommunitySettings? communitySettings,
      final DiscussionSettings? discussionSettings,
      final String? donationDialogText,
      final String? ratingSurveyUrl,
      final String? themeLightColor,
      final String? themeDarkColor,
      final List<OnboardingStep> onboardingSteps,
      final bool isOnboardingOverviewEnabled}) = _$_Junto;
  _Junto._() : super._();

  factory _Junto.fromJson(Map<String, dynamic> json) = _$_Junto.fromJson;

  @override
  String get id;
  @override

  /// List of IDs that correlate to this Junto in the URL bar.
  List<String> get displayIds;
  @override
  String? get name;
  @override
  String? get contactEmail;
  @override
  String? get creatorId;
  @override
  String? get profileImageUrl;
  @override
  String? get bannerImageUrl;
  @override
  @JsonKey(fromJson: dateTimeFromTimestamp, toJson: serverTimestamp)
  DateTime? get createdDate;
  @override
  bool? get isPublic;
  @override
  String? get description;
  @override
  String? get tagLine;
  @override
  @JsonKey(fromJson: juntoFeatureFlagsFromJson)
  List<JuntoFeatureFlags> get enabledFeatureFlags;
  @override
  CommunitySettings? get communitySettings;
  @override
  DiscussionSettings? get discussionSettings;
  @override
  String? get donationDialogText;
  @override
  String? get ratingSurveyUrl;
  @override
  String? get themeLightColor;
  @override
  String? get themeDarkColor;
  @override
  List<OnboardingStep> get onboardingSteps;
  @override
  bool get isOnboardingOverviewEnabled;
  @override
  @JsonKey(ignore: true)
  _$$_JuntoCopyWith<_$_Junto> get copyWith =>
      throw _privateConstructorUsedError;
}

Featured _$FeaturedFromJson(Map<String, dynamic> json) {
  return _Featured.fromJson(json);
}

/// @nodoc
mixin _$Featured {
  String? get documentPath => throw _privateConstructorUsedError;
  @JsonKey(unknownEnumValue: null)
  FeaturedType? get featuredType => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $FeaturedCopyWith<Featured> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FeaturedCopyWith<$Res> {
  factory $FeaturedCopyWith(Featured value, $Res Function(Featured) then) =
      _$FeaturedCopyWithImpl<$Res, Featured>;
  @useResult
  $Res call(
      {String? documentPath,
      @JsonKey(unknownEnumValue: null) FeaturedType? featuredType});
}

/// @nodoc
class _$FeaturedCopyWithImpl<$Res, $Val extends Featured>
    implements $FeaturedCopyWith<$Res> {
  _$FeaturedCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? documentPath = freezed,
    Object? featuredType = freezed,
  }) {
    return _then(_value.copyWith(
      documentPath: freezed == documentPath
          ? _value.documentPath
          : documentPath // ignore: cast_nullable_to_non_nullable
              as String?,
      featuredType: freezed == featuredType
          ? _value.featuredType
          : featuredType // ignore: cast_nullable_to_non_nullable
              as FeaturedType?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_FeaturedCopyWith<$Res> implements $FeaturedCopyWith<$Res> {
  factory _$$_FeaturedCopyWith(
          _$_Featured value, $Res Function(_$_Featured) then) =
      __$$_FeaturedCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String? documentPath,
      @JsonKey(unknownEnumValue: null) FeaturedType? featuredType});
}

/// @nodoc
class __$$_FeaturedCopyWithImpl<$Res>
    extends _$FeaturedCopyWithImpl<$Res, _$_Featured>
    implements _$$_FeaturedCopyWith<$Res> {
  __$$_FeaturedCopyWithImpl(
      _$_Featured _value, $Res Function(_$_Featured) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? documentPath = freezed,
    Object? featuredType = freezed,
  }) {
    return _then(_$_Featured(
      documentPath: freezed == documentPath
          ? _value.documentPath
          : documentPath // ignore: cast_nullable_to_non_nullable
              as String?,
      featuredType: freezed == featuredType
          ? _value.featuredType
          : featuredType // ignore: cast_nullable_to_non_nullable
              as FeaturedType?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_Featured implements _Featured {
  _$_Featured(
      {this.documentPath, @JsonKey(unknownEnumValue: null) this.featuredType});

  factory _$_Featured.fromJson(Map<String, dynamic> json) =>
      _$$_FeaturedFromJson(json);

  @override
  final String? documentPath;
  @override
  @JsonKey(unknownEnumValue: null)
  final FeaturedType? featuredType;

  @override
  String toString() {
    return 'Featured(documentPath: $documentPath, featuredType: $featuredType)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_Featured &&
            (identical(other.documentPath, documentPath) ||
                other.documentPath == documentPath) &&
            (identical(other.featuredType, featuredType) ||
                other.featuredType == featuredType));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, documentPath, featuredType);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_FeaturedCopyWith<_$_Featured> get copyWith =>
      __$$_FeaturedCopyWithImpl<_$_Featured>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_FeaturedToJson(
      this,
    );
  }
}

abstract class _Featured implements Featured {
  factory _Featured(
          {final String? documentPath,
          @JsonKey(unknownEnumValue: null) final FeaturedType? featuredType}) =
      _$_Featured;

  factory _Featured.fromJson(Map<String, dynamic> json) = _$_Featured.fromJson;

  @override
  String? get documentPath;
  @override
  @JsonKey(unknownEnumValue: null)
  FeaturedType? get featuredType;
  @override
  @JsonKey(ignore: true)
  _$$_FeaturedCopyWith<_$_Featured> get copyWith =>
      throw _privateConstructorUsedError;
}

CommunitySettings _$CommunitySettingsFromJson(Map<String, dynamic> json) {
  return _CommunitySettings.fromJson(json);
}

/// @nodoc
mixin _$CommunitySettings {
  bool get allowDonations => throw _privateConstructorUsedError;
  bool get allowUnofficialTopics => throw _privateConstructorUsedError;
  bool get disableEmailDigests => throw _privateConstructorUsedError;
  bool get dontAllowMembersToCreateMeetings =>
      throw _privateConstructorUsedError;
  bool get enableDiscussionThreads => throw _privateConstructorUsedError;
  bool get enableHostless => throw _privateConstructorUsedError;
  bool get featureOnKazmHome => throw _privateConstructorUsedError;
  int? get featuredOrder => throw _privateConstructorUsedError;
  bool get multiplePeopleOnStage => throw _privateConstructorUsedError;
  bool get multipleVideoTypes => throw _privateConstructorUsedError;
  bool get requireApprovalToJoin => throw _privateConstructorUsedError;
  bool get enablePlatformSelection => throw _privateConstructorUsedError;
  bool get enableUpdatedLiveMeetingMobile => throw _privateConstructorUsedError;
  bool get enableAVCheck => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $CommunitySettingsCopyWith<CommunitySettings> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CommunitySettingsCopyWith<$Res> {
  factory $CommunitySettingsCopyWith(
          CommunitySettings value, $Res Function(CommunitySettings) then) =
      _$CommunitySettingsCopyWithImpl<$Res, CommunitySettings>;
  @useResult
  $Res call(
      {bool allowDonations,
      bool allowUnofficialTopics,
      bool disableEmailDigests,
      bool dontAllowMembersToCreateMeetings,
      bool enableDiscussionThreads,
      bool enableHostless,
      bool featureOnKazmHome,
      int? featuredOrder,
      bool multiplePeopleOnStage,
      bool multipleVideoTypes,
      bool requireApprovalToJoin,
      bool enablePlatformSelection,
      bool enableUpdatedLiveMeetingMobile,
      bool enableAVCheck});
}

/// @nodoc
class _$CommunitySettingsCopyWithImpl<$Res, $Val extends CommunitySettings>
    implements $CommunitySettingsCopyWith<$Res> {
  _$CommunitySettingsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? allowDonations = null,
    Object? allowUnofficialTopics = null,
    Object? disableEmailDigests = null,
    Object? dontAllowMembersToCreateMeetings = null,
    Object? enableDiscussionThreads = null,
    Object? enableHostless = null,
    Object? featureOnKazmHome = null,
    Object? featuredOrder = freezed,
    Object? multiplePeopleOnStage = null,
    Object? multipleVideoTypes = null,
    Object? requireApprovalToJoin = null,
    Object? enablePlatformSelection = null,
    Object? enableUpdatedLiveMeetingMobile = null,
    Object? enableAVCheck = null,
  }) {
    return _then(_value.copyWith(
      allowDonations: null == allowDonations
          ? _value.allowDonations
          : allowDonations // ignore: cast_nullable_to_non_nullable
              as bool,
      allowUnofficialTopics: null == allowUnofficialTopics
          ? _value.allowUnofficialTopics
          : allowUnofficialTopics // ignore: cast_nullable_to_non_nullable
              as bool,
      disableEmailDigests: null == disableEmailDigests
          ? _value.disableEmailDigests
          : disableEmailDigests // ignore: cast_nullable_to_non_nullable
              as bool,
      dontAllowMembersToCreateMeetings: null == dontAllowMembersToCreateMeetings
          ? _value.dontAllowMembersToCreateMeetings
          : dontAllowMembersToCreateMeetings // ignore: cast_nullable_to_non_nullable
              as bool,
      enableDiscussionThreads: null == enableDiscussionThreads
          ? _value.enableDiscussionThreads
          : enableDiscussionThreads // ignore: cast_nullable_to_non_nullable
              as bool,
      enableHostless: null == enableHostless
          ? _value.enableHostless
          : enableHostless // ignore: cast_nullable_to_non_nullable
              as bool,
      featureOnKazmHome: null == featureOnKazmHome
          ? _value.featureOnKazmHome
          : featureOnKazmHome // ignore: cast_nullable_to_non_nullable
              as bool,
      featuredOrder: freezed == featuredOrder
          ? _value.featuredOrder
          : featuredOrder // ignore: cast_nullable_to_non_nullable
              as int?,
      multiplePeopleOnStage: null == multiplePeopleOnStage
          ? _value.multiplePeopleOnStage
          : multiplePeopleOnStage // ignore: cast_nullable_to_non_nullable
              as bool,
      multipleVideoTypes: null == multipleVideoTypes
          ? _value.multipleVideoTypes
          : multipleVideoTypes // ignore: cast_nullable_to_non_nullable
              as bool,
      requireApprovalToJoin: null == requireApprovalToJoin
          ? _value.requireApprovalToJoin
          : requireApprovalToJoin // ignore: cast_nullable_to_non_nullable
              as bool,
      enablePlatformSelection: null == enablePlatformSelection
          ? _value.enablePlatformSelection
          : enablePlatformSelection // ignore: cast_nullable_to_non_nullable
              as bool,
      enableUpdatedLiveMeetingMobile: null == enableUpdatedLiveMeetingMobile
          ? _value.enableUpdatedLiveMeetingMobile
          : enableUpdatedLiveMeetingMobile // ignore: cast_nullable_to_non_nullable
              as bool,
      enableAVCheck: null == enableAVCheck
          ? _value.enableAVCheck
          : enableAVCheck // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_CommunitySettingsCopyWith<$Res>
    implements $CommunitySettingsCopyWith<$Res> {
  factory _$$_CommunitySettingsCopyWith(_$_CommunitySettings value,
          $Res Function(_$_CommunitySettings) then) =
      __$$_CommunitySettingsCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {bool allowDonations,
      bool allowUnofficialTopics,
      bool disableEmailDigests,
      bool dontAllowMembersToCreateMeetings,
      bool enableDiscussionThreads,
      bool enableHostless,
      bool featureOnKazmHome,
      int? featuredOrder,
      bool multiplePeopleOnStage,
      bool multipleVideoTypes,
      bool requireApprovalToJoin,
      bool enablePlatformSelection,
      bool enableUpdatedLiveMeetingMobile,
      bool enableAVCheck});
}

/// @nodoc
class __$$_CommunitySettingsCopyWithImpl<$Res>
    extends _$CommunitySettingsCopyWithImpl<$Res, _$_CommunitySettings>
    implements _$$_CommunitySettingsCopyWith<$Res> {
  __$$_CommunitySettingsCopyWithImpl(
      _$_CommunitySettings _value, $Res Function(_$_CommunitySettings) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? allowDonations = null,
    Object? allowUnofficialTopics = null,
    Object? disableEmailDigests = null,
    Object? dontAllowMembersToCreateMeetings = null,
    Object? enableDiscussionThreads = null,
    Object? enableHostless = null,
    Object? featureOnKazmHome = null,
    Object? featuredOrder = freezed,
    Object? multiplePeopleOnStage = null,
    Object? multipleVideoTypes = null,
    Object? requireApprovalToJoin = null,
    Object? enablePlatformSelection = null,
    Object? enableUpdatedLiveMeetingMobile = null,
    Object? enableAVCheck = null,
  }) {
    return _then(_$_CommunitySettings(
      allowDonations: null == allowDonations
          ? _value.allowDonations
          : allowDonations // ignore: cast_nullable_to_non_nullable
              as bool,
      allowUnofficialTopics: null == allowUnofficialTopics
          ? _value.allowUnofficialTopics
          : allowUnofficialTopics // ignore: cast_nullable_to_non_nullable
              as bool,
      disableEmailDigests: null == disableEmailDigests
          ? _value.disableEmailDigests
          : disableEmailDigests // ignore: cast_nullable_to_non_nullable
              as bool,
      dontAllowMembersToCreateMeetings: null == dontAllowMembersToCreateMeetings
          ? _value.dontAllowMembersToCreateMeetings
          : dontAllowMembersToCreateMeetings // ignore: cast_nullable_to_non_nullable
              as bool,
      enableDiscussionThreads: null == enableDiscussionThreads
          ? _value.enableDiscussionThreads
          : enableDiscussionThreads // ignore: cast_nullable_to_non_nullable
              as bool,
      enableHostless: null == enableHostless
          ? _value.enableHostless
          : enableHostless // ignore: cast_nullable_to_non_nullable
              as bool,
      featureOnKazmHome: null == featureOnKazmHome
          ? _value.featureOnKazmHome
          : featureOnKazmHome // ignore: cast_nullable_to_non_nullable
              as bool,
      featuredOrder: freezed == featuredOrder
          ? _value.featuredOrder
          : featuredOrder // ignore: cast_nullable_to_non_nullable
              as int?,
      multiplePeopleOnStage: null == multiplePeopleOnStage
          ? _value.multiplePeopleOnStage
          : multiplePeopleOnStage // ignore: cast_nullable_to_non_nullable
              as bool,
      multipleVideoTypes: null == multipleVideoTypes
          ? _value.multipleVideoTypes
          : multipleVideoTypes // ignore: cast_nullable_to_non_nullable
              as bool,
      requireApprovalToJoin: null == requireApprovalToJoin
          ? _value.requireApprovalToJoin
          : requireApprovalToJoin // ignore: cast_nullable_to_non_nullable
              as bool,
      enablePlatformSelection: null == enablePlatformSelection
          ? _value.enablePlatformSelection
          : enablePlatformSelection // ignore: cast_nullable_to_non_nullable
              as bool,
      enableUpdatedLiveMeetingMobile: null == enableUpdatedLiveMeetingMobile
          ? _value.enableUpdatedLiveMeetingMobile
          : enableUpdatedLiveMeetingMobile // ignore: cast_nullable_to_non_nullable
              as bool,
      enableAVCheck: null == enableAVCheck
          ? _value.enableAVCheck
          : enableAVCheck // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_CommunitySettings implements _CommunitySettings {
  const _$_CommunitySettings(
      {this.allowDonations = true,
      this.allowUnofficialTopics = false,
      this.disableEmailDigests = false,
      this.dontAllowMembersToCreateMeetings = true,
      this.enableDiscussionThreads = true,
      this.enableHostless = true,
      this.featureOnKazmHome = false,
      this.featuredOrder,
      this.multiplePeopleOnStage = false,
      this.multipleVideoTypes = false,
      this.requireApprovalToJoin = false,
      this.enablePlatformSelection = true,
      this.enableUpdatedLiveMeetingMobile = false,
      this.enableAVCheck = true});

  factory _$_CommunitySettings.fromJson(Map<String, dynamic> json) =>
      _$$_CommunitySettingsFromJson(json);

  @override
  @JsonKey()
  final bool allowDonations;
  @override
  @JsonKey()
  final bool allowUnofficialTopics;
  @override
  @JsonKey()
  final bool disableEmailDigests;
  @override
  @JsonKey()
  final bool dontAllowMembersToCreateMeetings;
  @override
  @JsonKey()
  final bool enableDiscussionThreads;
  @override
  @JsonKey()
  final bool enableHostless;
  @override
  @JsonKey()
  final bool featureOnKazmHome;
  @override
  final int? featuredOrder;
  @override
  @JsonKey()
  final bool multiplePeopleOnStage;
  @override
  @JsonKey()
  final bool multipleVideoTypes;
  @override
  @JsonKey()
  final bool requireApprovalToJoin;
  @override
  @JsonKey()
  final bool enablePlatformSelection;
  @override
  @JsonKey()
  final bool enableUpdatedLiveMeetingMobile;
  @override
  @JsonKey()
  final bool enableAVCheck;

  @override
  String toString() {
    return 'CommunitySettings(allowDonations: $allowDonations, allowUnofficialTopics: $allowUnofficialTopics, disableEmailDigests: $disableEmailDigests, dontAllowMembersToCreateMeetings: $dontAllowMembersToCreateMeetings, enableDiscussionThreads: $enableDiscussionThreads, enableHostless: $enableHostless, featureOnKazmHome: $featureOnKazmHome, featuredOrder: $featuredOrder, multiplePeopleOnStage: $multiplePeopleOnStage, multipleVideoTypes: $multipleVideoTypes, requireApprovalToJoin: $requireApprovalToJoin, enablePlatformSelection: $enablePlatformSelection, enableUpdatedLiveMeetingMobile: $enableUpdatedLiveMeetingMobile, enableAVCheck: $enableAVCheck)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_CommunitySettings &&
            (identical(other.allowDonations, allowDonations) ||
                other.allowDonations == allowDonations) &&
            (identical(other.allowUnofficialTopics, allowUnofficialTopics) ||
                other.allowUnofficialTopics == allowUnofficialTopics) &&
            (identical(other.disableEmailDigests, disableEmailDigests) ||
                other.disableEmailDigests == disableEmailDigests) &&
            (identical(other.dontAllowMembersToCreateMeetings,
                    dontAllowMembersToCreateMeetings) ||
                other.dontAllowMembersToCreateMeetings ==
                    dontAllowMembersToCreateMeetings) &&
            (identical(
                    other.enableDiscussionThreads, enableDiscussionThreads) ||
                other.enableDiscussionThreads == enableDiscussionThreads) &&
            (identical(other.enableHostless, enableHostless) ||
                other.enableHostless == enableHostless) &&
            (identical(other.featureOnKazmHome, featureOnKazmHome) ||
                other.featureOnKazmHome == featureOnKazmHome) &&
            (identical(other.featuredOrder, featuredOrder) ||
                other.featuredOrder == featuredOrder) &&
            (identical(other.multiplePeopleOnStage, multiplePeopleOnStage) ||
                other.multiplePeopleOnStage == multiplePeopleOnStage) &&
            (identical(other.multipleVideoTypes, multipleVideoTypes) ||
                other.multipleVideoTypes == multipleVideoTypes) &&
            (identical(other.requireApprovalToJoin, requireApprovalToJoin) ||
                other.requireApprovalToJoin == requireApprovalToJoin) &&
            (identical(
                    other.enablePlatformSelection, enablePlatformSelection) ||
                other.enablePlatformSelection == enablePlatformSelection) &&
            (identical(other.enableUpdatedLiveMeetingMobile,
                    enableUpdatedLiveMeetingMobile) ||
                other.enableUpdatedLiveMeetingMobile ==
                    enableUpdatedLiveMeetingMobile) &&
            (identical(other.enableAVCheck, enableAVCheck) ||
                other.enableAVCheck == enableAVCheck));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      allowDonations,
      allowUnofficialTopics,
      disableEmailDigests,
      dontAllowMembersToCreateMeetings,
      enableDiscussionThreads,
      enableHostless,
      featureOnKazmHome,
      featuredOrder,
      multiplePeopleOnStage,
      multipleVideoTypes,
      requireApprovalToJoin,
      enablePlatformSelection,
      enableUpdatedLiveMeetingMobile,
      enableAVCheck);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_CommunitySettingsCopyWith<_$_CommunitySettings> get copyWith =>
      __$$_CommunitySettingsCopyWithImpl<_$_CommunitySettings>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_CommunitySettingsToJson(
      this,
    );
  }
}

abstract class _CommunitySettings implements CommunitySettings {
  const factory _CommunitySettings(
      {final bool allowDonations,
      final bool allowUnofficialTopics,
      final bool disableEmailDigests,
      final bool dontAllowMembersToCreateMeetings,
      final bool enableDiscussionThreads,
      final bool enableHostless,
      final bool featureOnKazmHome,
      final int? featuredOrder,
      final bool multiplePeopleOnStage,
      final bool multipleVideoTypes,
      final bool requireApprovalToJoin,
      final bool enablePlatformSelection,
      final bool enableUpdatedLiveMeetingMobile,
      final bool enableAVCheck}) = _$_CommunitySettings;

  factory _CommunitySettings.fromJson(Map<String, dynamic> json) =
      _$_CommunitySettings.fromJson;

  @override
  bool get allowDonations;
  @override
  bool get allowUnofficialTopics;
  @override
  bool get disableEmailDigests;
  @override
  bool get dontAllowMembersToCreateMeetings;
  @override
  bool get enableDiscussionThreads;
  @override
  bool get enableHostless;
  @override
  bool get featureOnKazmHome;
  @override
  int? get featuredOrder;
  @override
  bool get multiplePeopleOnStage;
  @override
  bool get multipleVideoTypes;
  @override
  bool get requireApprovalToJoin;
  @override
  bool get enablePlatformSelection;
  @override
  bool get enableUpdatedLiveMeetingMobile;
  @override
  bool get enableAVCheck;
  @override
  @JsonKey(ignore: true)
  _$$_CommunitySettingsCopyWith<_$_CommunitySettings> get copyWith =>
      throw _privateConstructorUsedError;
}
