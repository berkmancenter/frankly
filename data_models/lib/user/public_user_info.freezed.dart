// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'public_user_info.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

PublicUserInfo _$PublicUserInfoFromJson(Map<String, dynamic> json) {
  return _PublicUserInfo.fromJson(json);
}

/// @nodoc
mixin _$PublicUserInfo {
  String get id => throw _privateConstructorUsedError;
  int get agoraId => throw _privateConstructorUsedError;
  String? get displayName => throw _privateConstructorUsedError;
  String? get imageUrl => throw _privateConstructorUsedError;
  String? get about => throw _privateConstructorUsedError;
  List<SocialMediaItem> get socialMediaItems =>
      throw _privateConstructorUsedError;
  AppRole? get appRole => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $PublicUserInfoCopyWith<PublicUserInfo> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PublicUserInfoCopyWith<$Res> {
  factory $PublicUserInfoCopyWith(
          PublicUserInfo value, $Res Function(PublicUserInfo) then) =
      _$PublicUserInfoCopyWithImpl<$Res, PublicUserInfo>;
  @useResult
  $Res call(
      {String id,
      int agoraId,
      String? displayName,
      String? imageUrl,
      String? about,
      List<SocialMediaItem> socialMediaItems,
      AppRole? appRole});
}

/// @nodoc
class _$PublicUserInfoCopyWithImpl<$Res, $Val extends PublicUserInfo>
    implements $PublicUserInfoCopyWith<$Res> {
  _$PublicUserInfoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? agoraId = null,
    Object? displayName = freezed,
    Object? imageUrl = freezed,
    Object? about = freezed,
    Object? socialMediaItems = null,
    Object? appRole = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      agoraId: null == agoraId
          ? _value.agoraId
          : agoraId // ignore: cast_nullable_to_non_nullable
              as int,
      displayName: freezed == displayName
          ? _value.displayName
          : displayName // ignore: cast_nullable_to_non_nullable
              as String?,
      imageUrl: freezed == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      about: freezed == about
          ? _value.about
          : about // ignore: cast_nullable_to_non_nullable
              as String?,
      socialMediaItems: null == socialMediaItems
          ? _value.socialMediaItems
          : socialMediaItems // ignore: cast_nullable_to_non_nullable
              as List<SocialMediaItem>,
      appRole: freezed == appRole
          ? _value.appRole
          : appRole // ignore: cast_nullable_to_non_nullable
              as AppRole?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_PublicUserInfoCopyWith<$Res>
    implements $PublicUserInfoCopyWith<$Res> {
  factory _$$_PublicUserInfoCopyWith(
          _$_PublicUserInfo value, $Res Function(_$_PublicUserInfo) then) =
      __$$_PublicUserInfoCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      int agoraId,
      String? displayName,
      String? imageUrl,
      String? about,
      List<SocialMediaItem> socialMediaItems,
      AppRole? appRole});
}

/// @nodoc
class __$$_PublicUserInfoCopyWithImpl<$Res>
    extends _$PublicUserInfoCopyWithImpl<$Res, _$_PublicUserInfo>
    implements _$$_PublicUserInfoCopyWith<$Res> {
  __$$_PublicUserInfoCopyWithImpl(
      _$_PublicUserInfo _value, $Res Function(_$_PublicUserInfo) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? agoraId = null,
    Object? displayName = freezed,
    Object? imageUrl = freezed,
    Object? about = freezed,
    Object? socialMediaItems = null,
    Object? appRole = freezed,
  }) {
    return _then(_$_PublicUserInfo(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      agoraId: null == agoraId
          ? _value.agoraId
          : agoraId // ignore: cast_nullable_to_non_nullable
              as int,
      displayName: freezed == displayName
          ? _value.displayName
          : displayName // ignore: cast_nullable_to_non_nullable
              as String?,
      imageUrl: freezed == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      about: freezed == about
          ? _value.about
          : about // ignore: cast_nullable_to_non_nullable
              as String?,
      socialMediaItems: null == socialMediaItems
          ? _value.socialMediaItems
          : socialMediaItems // ignore: cast_nullable_to_non_nullable
              as List<SocialMediaItem>,
      appRole: freezed == appRole
          ? _value.appRole
          : appRole // ignore: cast_nullable_to_non_nullable
              as AppRole?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_PublicUserInfo extends _PublicUserInfo {
  _$_PublicUserInfo(
      {required this.id,
      required this.agoraId,
      this.displayName,
      this.imageUrl,
      this.about = '',
      this.socialMediaItems = const [],
      this.appRole = AppRole.user})
      : super._();

  factory _$_PublicUserInfo.fromJson(Map<String, dynamic> json) =>
      _$$_PublicUserInfoFromJson(json);

  @override
  final String id;
  @override
  final int agoraId;
  @override
  final String? displayName;
  @override
  final String? imageUrl;
  @override
  @JsonKey()
  final String? about;
  @override
  @JsonKey()
  final List<SocialMediaItem> socialMediaItems;
  @override
  @JsonKey()
  final AppRole? appRole;

  @override
  String toString() {
    return 'PublicUserInfo(id: $id, agoraId: $agoraId, displayName: $displayName, imageUrl: $imageUrl, about: $about, socialMediaItems: $socialMediaItems, appRole: $appRole)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_PublicUserInfo &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.agoraId, agoraId) || other.agoraId == agoraId) &&
            (identical(other.displayName, displayName) ||
                other.displayName == displayName) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl) &&
            (identical(other.about, about) || other.about == about) &&
            const DeepCollectionEquality()
                .equals(other.socialMediaItems, socialMediaItems) &&
            (identical(other.appRole, appRole) || other.appRole == appRole));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      agoraId,
      displayName,
      imageUrl,
      about,
      const DeepCollectionEquality().hash(socialMediaItems),
      appRole);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_PublicUserInfoCopyWith<_$_PublicUserInfo> get copyWith =>
      __$$_PublicUserInfoCopyWithImpl<_$_PublicUserInfo>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_PublicUserInfoToJson(
      this,
    );
  }
}

abstract class _PublicUserInfo extends PublicUserInfo {
  factory _PublicUserInfo(
      {required final String id,
      required final int agoraId,
      final String? displayName,
      final String? imageUrl,
      final String? about,
      final List<SocialMediaItem> socialMediaItems,
      final AppRole? appRole}) = _$_PublicUserInfo;
  _PublicUserInfo._() : super._();

  factory _PublicUserInfo.fromJson(Map<String, dynamic> json) =
      _$_PublicUserInfo.fromJson;

  @override
  String get id;
  @override
  int get agoraId;
  @override
  String? get displayName;
  @override
  String? get imageUrl;
  @override
  String? get about;
  @override
  List<SocialMediaItem> get socialMediaItems;
  @override
  AppRole? get appRole;
  @override
  @JsonKey(ignore: true)
  _$$_PublicUserInfoCopyWith<_$_PublicUserInfo> get copyWith =>
      throw _privateConstructorUsedError;
}

SocialMediaItem _$SocialMediaItemFromJson(Map<String, dynamic> json) {
  return _SocialMediaItem.fromJson(json);
}

/// @nodoc
mixin _$SocialMediaItem {
  String? get url => throw _privateConstructorUsedError;
  @JsonKey(unknownEnumValue: null)
  SocialMediaKey? get socialMediaKey => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $SocialMediaItemCopyWith<SocialMediaItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SocialMediaItemCopyWith<$Res> {
  factory $SocialMediaItemCopyWith(
          SocialMediaItem value, $Res Function(SocialMediaItem) then) =
      _$SocialMediaItemCopyWithImpl<$Res, SocialMediaItem>;
  @useResult
  $Res call(
      {String? url,
      @JsonKey(unknownEnumValue: null) SocialMediaKey? socialMediaKey});
}

/// @nodoc
class _$SocialMediaItemCopyWithImpl<$Res, $Val extends SocialMediaItem>
    implements $SocialMediaItemCopyWith<$Res> {
  _$SocialMediaItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? url = freezed,
    Object? socialMediaKey = freezed,
  }) {
    return _then(_value.copyWith(
      url: freezed == url
          ? _value.url
          : url // ignore: cast_nullable_to_non_nullable
              as String?,
      socialMediaKey: freezed == socialMediaKey
          ? _value.socialMediaKey
          : socialMediaKey // ignore: cast_nullable_to_non_nullable
              as SocialMediaKey?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_SocialMediaItemCopyWith<$Res>
    implements $SocialMediaItemCopyWith<$Res> {
  factory _$$_SocialMediaItemCopyWith(
          _$_SocialMediaItem value, $Res Function(_$_SocialMediaItem) then) =
      __$$_SocialMediaItemCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String? url,
      @JsonKey(unknownEnumValue: null) SocialMediaKey? socialMediaKey});
}

/// @nodoc
class __$$_SocialMediaItemCopyWithImpl<$Res>
    extends _$SocialMediaItemCopyWithImpl<$Res, _$_SocialMediaItem>
    implements _$$_SocialMediaItemCopyWith<$Res> {
  __$$_SocialMediaItemCopyWithImpl(
      _$_SocialMediaItem _value, $Res Function(_$_SocialMediaItem) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? url = freezed,
    Object? socialMediaKey = freezed,
  }) {
    return _then(_$_SocialMediaItem(
      url: freezed == url
          ? _value.url
          : url // ignore: cast_nullable_to_non_nullable
              as String?,
      socialMediaKey: freezed == socialMediaKey
          ? _value.socialMediaKey
          : socialMediaKey // ignore: cast_nullable_to_non_nullable
              as SocialMediaKey?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_SocialMediaItem implements _SocialMediaItem {
  _$_SocialMediaItem(
      {this.url, @JsonKey(unknownEnumValue: null) this.socialMediaKey});

  factory _$_SocialMediaItem.fromJson(Map<String, dynamic> json) =>
      _$$_SocialMediaItemFromJson(json);

  @override
  final String? url;
  @override
  @JsonKey(unknownEnumValue: null)
  final SocialMediaKey? socialMediaKey;

  @override
  String toString() {
    return 'SocialMediaItem(url: $url, socialMediaKey: $socialMediaKey)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_SocialMediaItem &&
            (identical(other.url, url) || other.url == url) &&
            (identical(other.socialMediaKey, socialMediaKey) ||
                other.socialMediaKey == socialMediaKey));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, url, socialMediaKey);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_SocialMediaItemCopyWith<_$_SocialMediaItem> get copyWith =>
      __$$_SocialMediaItemCopyWithImpl<_$_SocialMediaItem>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_SocialMediaItemToJson(
      this,
    );
  }
}

abstract class _SocialMediaItem implements SocialMediaItem {
  factory _SocialMediaItem(
      {final String? url,
      @JsonKey(unknownEnumValue: null)
      final SocialMediaKey? socialMediaKey}) = _$_SocialMediaItem;

  factory _SocialMediaItem.fromJson(Map<String, dynamic> json) =
      _$_SocialMediaItem.fromJson;

  @override
  String? get url;
  @override
  @JsonKey(unknownEnumValue: null)
  SocialMediaKey? get socialMediaKey;
  @override
  @JsonKey(ignore: true)
  _$$_SocialMediaItemCopyWith<_$_SocialMediaItem> get copyWith =>
      throw _privateConstructorUsedError;
}
