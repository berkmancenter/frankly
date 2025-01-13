import 'dart:convert';

import 'package:client/core/utils/firestore_utils.dart';
import 'package:client/services.dart';
import 'package:data_models/admin/plan_capability_list.dart';
import 'package:data_models/cloud_functions/requests.dart';

class CloudFunctionsCommunityService {
  Future<CreateCommunityResponse> createCommunity(
    CreateCommunityRequest request,
  ) async {
    final result =
        await cloudFunctions.callFunction('createCommunity', request.toJson());
    return CreateCommunityResponse.fromJson(result);
  }

  Future<void> updateCommunity(UpdateCommunityRequest request) async {
    loggingService.log(
      'CloudFunctionsService.updateCommunity: DataMap: ${request.toJson()}',
    );
    await cloudFunctions.callFunction('UpdateCommunity', request.toJson());
  }

  Future<PlanCapabilityList> getCommunityCapabilities(
    GetCommunityCapabilitiesRequest request,
  ) async {
    final result = await cloudFunctions.callFunction(
      'getCommunityCapabilities',
      request.toJson(),
    );
    return PlanCapabilityList.fromJson(result);
  }

  Future<GetMembersDataResponse> getMembersData({
    required GetMembersDataRequest request,
  }) async {
    final result =
        await cloudFunctions.callFunction('GetMembersData', request.toJson());

    return GetMembersDataResponse.fromJson(fromFirestoreJson(result));
  }

  Future<GetUserAdminDetailsResponse> getUserAdminDetails(
    GetUserAdminDetailsRequest request,
  ) async {
    final result = await cloudFunctions.callFunction(
      'GetUserAdminDetails',
      request.toJson(),
    );

    return GetUserAdminDetailsResponse.fromJson(getDecodedData(result));
  }

  Future<void> resolveJoinRequest(ResolveJoinRequestRequest request) async {
    await cloudFunctions.callFunction('resolveJoinRequest', request.toJson());
  }

  Future<void> updateMembership(UpdateMembershipRequest request) async {
    await cloudFunctions.callFunction('updateMembership', request.toJson());
  }

  Future<GetCommunityDonationsEnabledResponse> getCommunityDonationsEnabled(
    GetCommunityDonationsEnabledRequest request,
  ) async {
    final result = await cloudFunctions.callFunction(
        'GetCommunityDonationsEnabled', request.toJson());

    return GetCommunityDonationsEnabledResponse.fromJson(result);
  }

  Future<GetCommunityPrePostEnabledResponse> getCommunityPrePostEnabled(
    GetCommunityPrePostEnabledRequest request,
  ) async {
    final result = await cloudFunctions.callFunction(
        'GetCommunityPrePostEnabled', request.toJson());

    return GetCommunityPrePostEnabledResponse.fromJson(result);
  }

  Future<void> unsubscribeFromCommunityNotifications({
    required UnsubscribeFromCommunityNotificationsRequest request,
  }) async {
    await cloudFunctions.callFunction(
      'unsubscribeFromCommunityNotifications',
      request.toJson(),
    );
  }

  /// Regular `result` doesn't work on macos.
  /// type '_InternalLinkedHashMap<Object?, Object?>' is not a subtype of type 'Map<String, dynamic>' in type cast
  /// Additionally Map<String,dynamic>.from doesn't work as well.
  Map<String, dynamic> getDecodedData(data, {bool isWeb = true}) {
    if (isWeb) {
      return data;
    } else {
      return jsonDecode(jsonEncode(data));
    }
  }
}
