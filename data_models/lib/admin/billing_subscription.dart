import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:data_models/utils/firestore_utils.dart';

part 'billing_subscription.freezed.dart';
part 'billing_subscription.g.dart';

@Freezed(makeCollectionsUnmodifiable: false)
class BillingSubscription with _$BillingSubscription {
  static const String kFieldStripeSubscriptionId = 'stripeSubscriptionId';
  static const String kFieldType = 'type';
  static const String kFieldActiveUntil = 'activeUntil';
  static const String kFieldAppliedCommunityId = 'appliedCommunityId';
  static const String kFieldCanceled = 'canceled';
  static const String kFieldWillCancelAtPeriodEnd = 'willCancelAtPeriodEnd';

  factory BillingSubscription({
    required String stripeSubscriptionId,
    required String type,
    @JsonKey(fromJson: dateTimeFromTimestamp, toJson: timestampFromDateTime)
    DateTime? activeUntil,
    required bool canceled,
    required bool willCancelAtPeriodEnd,

    /// the specific community designated to be provisioned under this subscription
    String? appliedCommunityId,
  }) = _BillingSubscription;

  factory BillingSubscription.fromJson(Map<String, dynamic> json) =>
      _$BillingSubscriptionFromJson(json);
}
