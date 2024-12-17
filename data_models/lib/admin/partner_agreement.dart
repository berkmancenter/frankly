import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:data_models/cloud_functions/requests.dart';

part 'partner_agreement.freezed.dart';
part 'partner_agreement.g.dart';

@Freezed(makeCollectionsUnmodifiable: false)
class PartnerAgreement with _$PartnerAgreement implements SerializeableRequest {
  static const String kFieldId = 'id';
  static const String kFieldAllowPayments = 'allowPayments';
  static const String kFieldTakeRate = 'takeRate';
  static const String kFieldInitialUserId = 'initialUserId';
  static const String kFieldCommunityId = 'communityId';
  static const String kFieldStripeConnectedAccountId =
      'stripeConnectedAccountId';
  static const String kFieldStripeConnectedAccountActive =
      'stripeConnectedAccountActive';

  factory PartnerAgreement({
    required String id,

    /// allow user to link a Stripe account and receive payments
    @Default(false) bool allowPayments,

    /// percent of donations to be withheld as fee
    double? takeRate,

    /// initial user who has started onboarding on behalf of partner; will be set during onboarding
    String? initialUserId,

    /// community covered by this agreement; will be set during onboarding
    String? communityId,

    /// attached stripe account; will be set during onboarding (or later)
    String? stripeConnectedAccountId,

    /// whether attached stripe account is fully set up; will be set by Stripe webhook
    @Default(false) bool stripeConnectedAccountActive,

    /// overrides plan type for community covered by this agreement; set manually if needed
    String? planOverride,
  }) = _PartnerAgreement;

  factory PartnerAgreement.fromJson(Map<String, dynamic> json) =>
      _$PartnerAgreementFromJson(json);
}
