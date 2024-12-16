import 'dart:async';

import 'package:firebase_functions_interop/firebase_functions_interop.dart';
import 'package:junto_functions/functions/on_call_function.dart';
import 'package:junto_functions/utils/subscription_plan_util.dart';
import 'package:junto_functions/utils/utils.dart';
import 'package:junto_models/cloud_functions/requests.dart';

class GetJuntoCapabilities extends OnCallMethod<GetJuntoCapabilitiesRequest> {
  GetJuntoCapabilities()
      : super(
          'getJuntoCapabilities',
          (jsonMap) => GetJuntoCapabilitiesRequest.fromJson(jsonMap),
        );

  @override
  Future<Map<String, dynamic>> action(
      GetJuntoCapabilitiesRequest request, CallableContext context) async {
    orElseUnauthorized(context?.authUid != null, logMessage: 'Context auth ID was null');

    final capabilities = await subscriptionPlanUtil.calculateCapabilities(
      request.juntoId,
      requesterUserId: context?.authUid,
    );
    return capabilities.toJson();
  }
}
