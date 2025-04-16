import 'dart:async';

import 'package:firebase_functions_interop/firebase_functions_interop.dart';
import 'check_assign_to_breakouts.dart';
import '../../../on_request_method.dart';
import 'package:data_models/cloud_functions/requests.dart';

/// This is a wrapper on our [CheckAssignToBreakouts] function.
/// Whereas that one is called from the client, this one is called from the
/// server at a scheduled time depending on when the event is scheduled for.
class CheckAssignToBreakoutsServer
    extends OnRequestMethod<CheckAssignToBreakoutsRequest> {
  CheckAssignToBreakoutsServer()
      : super(
          'CheckAssignToBreakoutsServer',
          (jsonMap) => CheckAssignToBreakoutsRequest.fromJson(jsonMap),
          runWithOptions: RuntimeOptions(
            timeoutSeconds: 240,
            memory: '4GB',
            minInstances: 0,
          ),
        );

  @override
  Future<String> action(CheckAssignToBreakoutsRequest request) async {
    await CheckAssignToBreakouts().checkAssignToBreakouts(request, 'server');

    return '';
  }
}
