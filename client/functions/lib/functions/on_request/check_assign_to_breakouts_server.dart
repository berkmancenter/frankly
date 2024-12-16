import 'dart:async';

import 'package:firebase_functions_interop/firebase_functions_interop.dart';
import 'package:junto_functions/functions/on_call/check_assign_to_breakouts.dart';
import 'package:junto_functions/functions/on_request_method.dart';
import 'package:junto_functions/utils/firestore_utils.dart';
import 'package:junto_models/cloud_functions/requests.dart';

/// This is a wrapper on our [CheckAssignToBreakouts] function. Where that one is called from
/// the client, this one is called from the server at a scheduled time depending on when the
/// discussion is scheduled for
class CheckAssignToBreakoutsServer extends OnRequestMethod<CheckAssignToBreakoutsRequest> {
  CheckAssignToBreakoutsServer()
      : super(
          'CheckAssignToBreakoutsServer',
          (jsonMap) => CheckAssignToBreakoutsRequest.fromJson(jsonMap),
          runWithOptions:
              RuntimeOptions(timeoutSeconds: 240, memory: '4GB', minInstances: 0),
        );

  @override
  Future<String> action(CheckAssignToBreakoutsRequest request) async {
    await CheckAssignToBreakouts().checkAssignToBreakouts(request, 'server');

    return '';
  }
}
