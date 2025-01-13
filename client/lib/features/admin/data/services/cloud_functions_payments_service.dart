import 'package:client/services.dart';
import 'package:data_models/cloud_functions/requests.dart';

class CloudFunctionsPaymentsService {
  Future<void> createStripeConnectedAccount(
    CreateStripeConnectedAccountRequest request,
  ) async {
    await cloudFunctions.callFunction(
      'createStripeConnectedAccount',
      request.toJson(),
    );
  }

  Future<GetStripeBillingPortalLinkResponse> getStripeBillingPortalLink(
    GetStripeBillingPortalLinkRequest request,
  ) async {
    final result = await cloudFunctions.callFunction(
      'getStripeBillingPortalLink',
      request.toJson(),
    );
    return GetStripeBillingPortalLinkResponse.fromJson(result);
  }

  Future<GetStripeConnectedAccountLinkResponse> getStripeConnectedAccountLink(
    GetStripeConnectedAccountLinkRequest request,
  ) async {
    final result = await cloudFunctions.callFunction(
      'getStripeConnectedAccountLink',
      request.toJson(),
    );
    return GetStripeConnectedAccountLinkResponse.fromJson(result);
  }

  Future<void> cancelStripeSubscriptionPlan(
    CancelStripeSubscriptionPlanRequest request,
  ) async {
    await cloudFunctions.callFunction(
      'CancelStripeSubscriptionPlan',
      request.toJson(),
    );
  }

  Future<void> updateStripeSubscriptionPlan(
    UpdateStripeSubscriptionPlanRequest request,
  ) async {
    await cloudFunctions.callFunction(
      'UpdateStripeSubscriptionPlan',
      request.toJson(),
    );
  }

  Future<GetStripeSubscriptionPlanInfoResponse> getStripeSubscriptionPlanInfo(
    GetStripeSubscriptionPlanInfoRequest request,
  ) async {
    final result = await cloudFunctions.callFunction(
      'GetStripeSubscriptionPlanInfo',
      request.toJson(),
    );

    return GetStripeSubscriptionPlanInfoResponse.fromJson(result);
  }

  Future<CreateDonationCheckoutSessionResponse> createDonationCheckoutSession(
    CreateDonationCheckoutSessionRequest request,
  ) async {
    final result = await cloudFunctions.callFunction(
      'createDonationCheckoutSession',
      request.toJson(),
    );
    return CreateDonationCheckoutSessionResponse.fromJson(result);
  }

  Future<CreateSubscriptionCheckoutSessionResponse>
      createSubscriptionCheckoutSession(
    CreateSubscriptionCheckoutSessionRequest request,
  ) async {
    final result = await cloudFunctions.callFunction(
      'CreateSubscriptionCheckoutSession',
      request.toJson(),
    );
    return CreateSubscriptionCheckoutSessionResponse.fromJson(result);
  }
}
