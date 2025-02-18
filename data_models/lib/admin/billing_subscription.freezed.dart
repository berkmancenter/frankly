// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'billing_subscription.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

BillingSubscription _$BillingSubscriptionFromJson(Map<String, dynamic> json) {
  return _BillingSubscription.fromJson(json);
}

/// @nodoc
mixin _$BillingSubscription {
  String get stripeSubscriptionId => throw _privateConstructorUsedError;
  String get type => throw _privateConstructorUsedError;
  @JsonKey(fromJson: dateTimeFromTimestamp, toJson: timestampFromDateTime)
  DateTime? get activeUntil => throw _privateConstructorUsedError;
  bool get canceled => throw _privateConstructorUsedError;
  bool get willCancelAtPeriodEnd => throw _privateConstructorUsedError;

  /// the specific community designated to be provisioned under this subscription
  String? get appliedCommunityId => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $BillingSubscriptionCopyWith<BillingSubscription> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BillingSubscriptionCopyWith<$Res> {
  factory $BillingSubscriptionCopyWith(
          BillingSubscription value, $Res Function(BillingSubscription) then) =
      _$BillingSubscriptionCopyWithImpl<$Res, BillingSubscription>;
  @useResult
  $Res call(
      {String stripeSubscriptionId,
      String type,
      @JsonKey(fromJson: dateTimeFromTimestamp, toJson: timestampFromDateTime)
      DateTime? activeUntil,
      bool canceled,
      bool willCancelAtPeriodEnd,
      String? appliedCommunityId});
}

/// @nodoc
class _$BillingSubscriptionCopyWithImpl<$Res, $Val extends BillingSubscription>
    implements $BillingSubscriptionCopyWith<$Res> {
  _$BillingSubscriptionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? stripeSubscriptionId = null,
    Object? type = null,
    Object? activeUntil = freezed,
    Object? canceled = null,
    Object? willCancelAtPeriodEnd = null,
    Object? appliedCommunityId = freezed,
  }) {
    return _then(_value.copyWith(
      stripeSubscriptionId: null == stripeSubscriptionId
          ? _value.stripeSubscriptionId
          : stripeSubscriptionId // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      activeUntil: freezed == activeUntil
          ? _value.activeUntil
          : activeUntil // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      canceled: null == canceled
          ? _value.canceled
          : canceled // ignore: cast_nullable_to_non_nullable
              as bool,
      willCancelAtPeriodEnd: null == willCancelAtPeriodEnd
          ? _value.willCancelAtPeriodEnd
          : willCancelAtPeriodEnd // ignore: cast_nullable_to_non_nullable
              as bool,
      appliedCommunityId: freezed == appliedCommunityId
          ? _value.appliedCommunityId
          : appliedCommunityId // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_BillingSubscriptionCopyWith<$Res>
    implements $BillingSubscriptionCopyWith<$Res> {
  factory _$$_BillingSubscriptionCopyWith(_$_BillingSubscription value,
          $Res Function(_$_BillingSubscription) then) =
      __$$_BillingSubscriptionCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String stripeSubscriptionId,
      String type,
      @JsonKey(fromJson: dateTimeFromTimestamp, toJson: timestampFromDateTime)
      DateTime? activeUntil,
      bool canceled,
      bool willCancelAtPeriodEnd,
      String? appliedCommunityId});
}

/// @nodoc
class __$$_BillingSubscriptionCopyWithImpl<$Res>
    extends _$BillingSubscriptionCopyWithImpl<$Res, _$_BillingSubscription>
    implements _$$_BillingSubscriptionCopyWith<$Res> {
  __$$_BillingSubscriptionCopyWithImpl(_$_BillingSubscription _value,
      $Res Function(_$_BillingSubscription) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? stripeSubscriptionId = null,
    Object? type = null,
    Object? activeUntil = freezed,
    Object? canceled = null,
    Object? willCancelAtPeriodEnd = null,
    Object? appliedCommunityId = freezed,
  }) {
    return _then(_$_BillingSubscription(
      stripeSubscriptionId: null == stripeSubscriptionId
          ? _value.stripeSubscriptionId
          : stripeSubscriptionId // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      activeUntil: freezed == activeUntil
          ? _value.activeUntil
          : activeUntil // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      canceled: null == canceled
          ? _value.canceled
          : canceled // ignore: cast_nullable_to_non_nullable
              as bool,
      willCancelAtPeriodEnd: null == willCancelAtPeriodEnd
          ? _value.willCancelAtPeriodEnd
          : willCancelAtPeriodEnd // ignore: cast_nullable_to_non_nullable
              as bool,
      appliedCommunityId: freezed == appliedCommunityId
          ? _value.appliedCommunityId
          : appliedCommunityId // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_BillingSubscription implements _BillingSubscription {
  _$_BillingSubscription(
      {required this.stripeSubscriptionId,
      required this.type,
      @JsonKey(fromJson: dateTimeFromTimestamp, toJson: timestampFromDateTime)
      this.activeUntil,
      required this.canceled,
      required this.willCancelAtPeriodEnd,
      this.appliedCommunityId});

  factory _$_BillingSubscription.fromJson(Map<String, dynamic> json) =>
      _$$_BillingSubscriptionFromJson(json);

  @override
  final String stripeSubscriptionId;
  @override
  final String type;
  @override
  @JsonKey(fromJson: dateTimeFromTimestamp, toJson: timestampFromDateTime)
  final DateTime? activeUntil;
  @override
  final bool canceled;
  @override
  final bool willCancelAtPeriodEnd;

  /// the specific community designated to be provisioned under this subscription
  @override
  final String? appliedCommunityId;

  @override
  String toString() {
    return 'BillingSubscription(stripeSubscriptionId: $stripeSubscriptionId, type: $type, activeUntil: $activeUntil, canceled: $canceled, willCancelAtPeriodEnd: $willCancelAtPeriodEnd, appliedCommunityId: $appliedCommunityId)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_BillingSubscription &&
            (identical(other.stripeSubscriptionId, stripeSubscriptionId) ||
                other.stripeSubscriptionId == stripeSubscriptionId) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.activeUntil, activeUntil) ||
                other.activeUntil == activeUntil) &&
            (identical(other.canceled, canceled) ||
                other.canceled == canceled) &&
            (identical(other.willCancelAtPeriodEnd, willCancelAtPeriodEnd) ||
                other.willCancelAtPeriodEnd == willCancelAtPeriodEnd) &&
            (identical(other.appliedCommunityId, appliedCommunityId) ||
                other.appliedCommunityId == appliedCommunityId));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, stripeSubscriptionId, type,
      activeUntil, canceled, willCancelAtPeriodEnd, appliedCommunityId);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_BillingSubscriptionCopyWith<_$_BillingSubscription> get copyWith =>
      __$$_BillingSubscriptionCopyWithImpl<_$_BillingSubscription>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_BillingSubscriptionToJson(
      this,
    );
  }
}

abstract class _BillingSubscription implements BillingSubscription {
  factory _BillingSubscription(
      {required final String stripeSubscriptionId,
      required final String type,
      @JsonKey(fromJson: dateTimeFromTimestamp, toJson: timestampFromDateTime)
      final DateTime? activeUntil,
      required final bool canceled,
      required final bool willCancelAtPeriodEnd,
      final String? appliedCommunityId}) = _$_BillingSubscription;

  factory _BillingSubscription.fromJson(Map<String, dynamic> json) =
      _$_BillingSubscription.fromJson;

  @override
  String get stripeSubscriptionId;
  @override
  String get type;
  @override
  @JsonKey(fromJson: dateTimeFromTimestamp, toJson: timestampFromDateTime)
  DateTime? get activeUntil;
  @override
  bool get canceled;
  @override
  bool get willCancelAtPeriodEnd;
  @override

  /// the specific community designated to be provisioned under this subscription
  String? get appliedCommunityId;
  @override
  @JsonKey(ignore: true)
  _$$_BillingSubscriptionCopyWith<_$_BillingSubscription> get copyWith =>
      throw _privateConstructorUsedError;
}
