import 'dart:async';

import 'package:firebase_functions_interop/firebase_functions_interop.dart';
import 'package:junto_functions/functions/on_call_function.dart';
import 'package:junto_functions/utils/subscription_plan_util.dart';
import 'package:junto_models/cloud_functions/requests.dart';

class GetJuntoPrePostEnabled extends OnCallMethod<GetJuntoPrePostEnabledRequest> {
  GetJuntoPrePostEnabled()
      : super(
            'GetJuntoPrePostEnabled', (jsonMap) => GetJuntoPrePostEnabledRequest.fromJson(jsonMap));

  @override
  Future<Map<String, dynamic>> action(
      GetJuntoPrePostEnabledRequest request, CallableContext context) async {
    final capabilities = await subscriptionPlanUtil.calculateCapabilities(request.juntoId);
    return GetJuntoPrePostEnabledResponse(prePostEnabled: capabilities.hasPrePost!).toJson();
  }
}
