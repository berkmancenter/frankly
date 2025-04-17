import 'dart:async';

import 'package:firebase_functions_interop/firebase_functions_interop.dart';
import '../on_call_function.dart';
import '../utils/subscription_plan_util.dart';
import '../utils/utils.dart';
import 'package:data_models/cloud_functions/requests.dart';

class GetCommunityCapabilities
    extends OnCallMethod<GetCommunityCapabilitiesRequest> {
  GetCommunityCapabilities()
      : super(
          'getCommunityCapabilities',
          (jsonMap) => GetCommunityCapabilitiesRequest.fromJson(jsonMap),
        );

  @override
  Future<Map<String, dynamic>> action(
    GetCommunityCapabilitiesRequest request,
    CallableContext context,
  ) async {
    orElseUnauthorized(
      context.authUid != null,
      logMessage: 'Context auth ID was null',
    );

    final capabilities = await subscriptionPlanUtil.calculateCapabilities(
      request.communityId,
      requesterUserId: context.authUid,
    );
    return capabilities.toJson();
  }
}
