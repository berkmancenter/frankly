// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'partner_agreement.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

PartnerAgreement _$PartnerAgreementFromJson(Map<String, dynamic> json) {
  return _PartnerAgreement.fromJson(json);
}

/// @nodoc
mixin _$PartnerAgreement {
  String get id => throw _privateConstructorUsedError;

  /// allow user to link a Stripe account and receive payments
  bool get allowPayments => throw _privateConstructorUsedError;

  /// percent of donations to be withheld as fee
  double? get takeRate => throw _privateConstructorUsedError;

  /// initial user who has started onboarding on behalf of partner; will be set during onboarding
  String? get initialUserId => throw _privateConstructorUsedError;

  /// community covered by this agreement; will be set during onboarding
  String? get communityId => throw _privateConstructorUsedError;

  /// attached stripe account; will be set during onboarding (or later)
  String? get stripeConnectedAccountId => throw _privateConstructorUsedError;

  /// whether attached stripe account is fully set up; will be set by Stripe webhook
  bool get stripeConnectedAccountActive => throw _privateConstructorUsedError;

  /// overrides plan type for community covered by this agreement; set manually if needed
  String? get planOverride => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $PartnerAgreementCopyWith<PartnerAgreement> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PartnerAgreementCopyWith<$Res> {
  factory $PartnerAgreementCopyWith(
          PartnerAgreement value, $Res Function(PartnerAgreement) then) =
      _$PartnerAgreementCopyWithImpl<$Res, PartnerAgreement>;
  @useResult
  $Res call(
      {String id,
      bool allowPayments,
      double? takeRate,
      String? initialUserId,
      String? communityId,
      String? stripeConnectedAccountId,
      bool stripeConnectedAccountActive,
      String? planOverride});
}

/// @nodoc
class _$PartnerAgreementCopyWithImpl<$Res, $Val extends PartnerAgreement>
    implements $PartnerAgreementCopyWith<$Res> {
  _$PartnerAgreementCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? allowPayments = null,
    Object? takeRate = freezed,
    Object? initialUserId = freezed,
    Object? communityId = freezed,
    Object? stripeConnectedAccountId = freezed,
    Object? stripeConnectedAccountActive = null,
    Object? planOverride = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      allowPayments: null == allowPayments
          ? _value.allowPayments
          : allowPayments // ignore: cast_nullable_to_non_nullable
              as bool,
      takeRate: freezed == takeRate
          ? _value.takeRate
          : takeRate // ignore: cast_nullable_to_non_nullable
              as double?,
      initialUserId: freezed == initialUserId
          ? _value.initialUserId
          : initialUserId // ignore: cast_nullable_to_non_nullable
              as String?,
      communityId: freezed == communityId
          ? _value.communityId
          : communityId // ignore: cast_nullable_to_non_nullable
              as String?,
      stripeConnectedAccountId: freezed == stripeConnectedAccountId
          ? _value.stripeConnectedAccountId
          : stripeConnectedAccountId // ignore: cast_nullable_to_non_nullable
              as String?,
      stripeConnectedAccountActive: null == stripeConnectedAccountActive
          ? _value.stripeConnectedAccountActive
          : stripeConnectedAccountActive // ignore: cast_nullable_to_non_nullable
              as bool,
      planOverride: freezed == planOverride
          ? _value.planOverride
          : planOverride // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_PartnerAgreementCopyWith<$Res>
    implements $PartnerAgreementCopyWith<$Res> {
  factory _$$_PartnerAgreementCopyWith(
          _$_PartnerAgreement value, $Res Function(_$_PartnerAgreement) then) =
      __$$_PartnerAgreementCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      bool allowPayments,
      double? takeRate,
      String? initialUserId,
      String? communityId,
      String? stripeConnectedAccountId,
      bool stripeConnectedAccountActive,
      String? planOverride});
}

/// @nodoc
class __$$_PartnerAgreementCopyWithImpl<$Res>
    extends _$PartnerAgreementCopyWithImpl<$Res, _$_PartnerAgreement>
    implements _$$_PartnerAgreementCopyWith<$Res> {
  __$$_PartnerAgreementCopyWithImpl(
      _$_PartnerAgreement _value, $Res Function(_$_PartnerAgreement) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? allowPayments = null,
    Object? takeRate = freezed,
    Object? initialUserId = freezed,
    Object? communityId = freezed,
    Object? stripeConnectedAccountId = freezed,
    Object? stripeConnectedAccountActive = null,
    Object? planOverride = freezed,
  }) {
    return _then(_$_PartnerAgreement(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      allowPayments: null == allowPayments
          ? _value.allowPayments
          : allowPayments // ignore: cast_nullable_to_non_nullable
              as bool,
      takeRate: freezed == takeRate
          ? _value.takeRate
          : takeRate // ignore: cast_nullable_to_non_nullable
              as double?,
      initialUserId: freezed == initialUserId
          ? _value.initialUserId
          : initialUserId // ignore: cast_nullable_to_non_nullable
              as String?,
      communityId: freezed == communityId
          ? _value.communityId
          : communityId // ignore: cast_nullable_to_non_nullable
              as String?,
      stripeConnectedAccountId: freezed == stripeConnectedAccountId
          ? _value.stripeConnectedAccountId
          : stripeConnectedAccountId // ignore: cast_nullable_to_non_nullable
              as String?,
      stripeConnectedAccountActive: null == stripeConnectedAccountActive
          ? _value.stripeConnectedAccountActive
          : stripeConnectedAccountActive // ignore: cast_nullable_to_non_nullable
              as bool,
      planOverride: freezed == planOverride
          ? _value.planOverride
          : planOverride // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_PartnerAgreement implements _PartnerAgreement {
  _$_PartnerAgreement(
      {required this.id,
      this.allowPayments = false,
      this.takeRate,
      this.initialUserId,
      this.communityId,
      this.stripeConnectedAccountId,
      this.stripeConnectedAccountActive = false,
      this.planOverride});

  factory _$_PartnerAgreement.fromJson(Map<String, dynamic> json) =>
      _$$_PartnerAgreementFromJson(json);

  @override
  final String id;

  /// allow user to link a Stripe account and receive payments
  @override
  @JsonKey()
  final bool allowPayments;

  /// percent of donations to be withheld as fee
  @override
  final double? takeRate;

  /// initial user who has started onboarding on behalf of partner; will be set during onboarding
  @override
  final String? initialUserId;

  /// community covered by this agreement; will be set during onboarding
  @override
  final String? communityId;

  /// attached stripe account; will be set during onboarding (or later)
  @override
  final String? stripeConnectedAccountId;

  /// whether attached stripe account is fully set up; will be set by Stripe webhook
  @override
  @JsonKey()
  final bool stripeConnectedAccountActive;

  /// overrides plan type for community covered by this agreement; set manually if needed
  @override
  final String? planOverride;

  @override
  String toString() {
    return 'PartnerAgreement(id: $id, allowPayments: $allowPayments, takeRate: $takeRate, initialUserId: $initialUserId, communityId: $communityId, stripeConnectedAccountId: $stripeConnectedAccountId, stripeConnectedAccountActive: $stripeConnectedAccountActive, planOverride: $planOverride)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_PartnerAgreement &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.allowPayments, allowPayments) ||
                other.allowPayments == allowPayments) &&
            (identical(other.takeRate, takeRate) ||
                other.takeRate == takeRate) &&
            (identical(other.initialUserId, initialUserId) ||
                other.initialUserId == initialUserId) &&
            (identical(other.communityId, communityId) ||
                other.communityId == communityId) &&
            (identical(
                    other.stripeConnectedAccountId, stripeConnectedAccountId) ||
                other.stripeConnectedAccountId == stripeConnectedAccountId) &&
            (identical(other.stripeConnectedAccountActive,
                    stripeConnectedAccountActive) ||
                other.stripeConnectedAccountActive ==
                    stripeConnectedAccountActive) &&
            (identical(other.planOverride, planOverride) ||
                other.planOverride == planOverride));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      allowPayments,
      takeRate,
      initialUserId,
      communityId,
      stripeConnectedAccountId,
      stripeConnectedAccountActive,
      planOverride);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_PartnerAgreementCopyWith<_$_PartnerAgreement> get copyWith =>
      __$$_PartnerAgreementCopyWithImpl<_$_PartnerAgreement>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_PartnerAgreementToJson(
      this,
    );
  }
}

abstract class _PartnerAgreement implements PartnerAgreement {
  factory _PartnerAgreement(
      {required final String id,
      final bool allowPayments,
      final double? takeRate,
      final String? initialUserId,
      final String? communityId,
      final String? stripeConnectedAccountId,
      final bool stripeConnectedAccountActive,
      final String? planOverride}) = _$_PartnerAgreement;

  factory _PartnerAgreement.fromJson(Map<String, dynamic> json) =
      _$_PartnerAgreement.fromJson;

  @override
  String get id;
  @override

  /// allow user to link a Stripe account and receive payments
  bool get allowPayments;
  @override

  /// percent of donations to be withheld as fee
  double? get takeRate;
  @override

  /// initial user who has started onboarding on behalf of partner; will be set during onboarding
  String? get initialUserId;
  @override

  /// community covered by this agreement; will be set during onboarding
  String? get communityId;
  @override

  /// attached stripe account; will be set during onboarding (or later)
  String? get stripeConnectedAccountId;
  @override

  /// whether attached stripe account is fully set up; will be set by Stripe webhook
  bool get stripeConnectedAccountActive;
  @override

  /// overrides plan type for community covered by this agreement; set manually if needed
  String? get planOverride;
  @override
  @JsonKey(ignore: true)
  _$$_PartnerAgreementCopyWith<_$_PartnerAgreement> get copyWith =>
      throw _privateConstructorUsedError;
}
