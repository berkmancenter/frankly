import 'dart:async';

import 'package:firebase_functions_interop/firebase_functions_interop.dart';
import '../on_call_function.dart';
import '../utils/subscription_plan_util.dart';
import 'package:data_models/cloud_functions/requests.dart';

class GetCommunityPrePostEnabled
    extends OnCallMethod<GetCommunityPrePostEnabledRequest> {
  GetCommunityPrePostEnabled()
      : super(
          'GetCommunityPrePostEnabled',
          (jsonMap) => GetCommunityPrePostEnabledRequest.fromJson(jsonMap),
        );

  @override
  Future<Map<String, dynamic>> action(
    GetCommunityPrePostEnabledRequest request,
    CallableContext context,
  ) async {
    final capabilities =
        await subscriptionPlanUtil.calculateCapabilities(request.communityId);
    return GetCommunityPrePostEnabledResponse(
      prePostEnabled: capabilities.hasPrePost!,
    ).toJson();
  }
}
