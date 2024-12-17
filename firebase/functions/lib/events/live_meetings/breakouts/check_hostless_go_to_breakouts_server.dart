import 'dart:async';

import 'package:firebase_functions_interop/firebase_functions_interop.dart';
import 'check_hostless_go_to_breakouts.dart';
import '../../../on_request_method.dart';
import 'package:data_models/cloud_functions/requests.dart';

/// This is a wrapper on our [CheckHostlessGoToBreakouts] function. Where that one is called from
/// the client, this one is called from the server at a scheduled time depending on when the
/// event is scheduled for
class CheckHostlessGoToBreakoutsServer
    extends OnRequestMethod<CheckHostlessGoToBreakoutsRequest> {
  CheckHostlessGoToBreakoutsServer()
      : super(
          'CheckHostlessGoToBreakoutsServer',
          (jsonMap) => CheckHostlessGoToBreakoutsRequest.fromJson(jsonMap),
          runWithOptions: RuntimeOptions(timeoutSeconds: 240, memory: '4GB'),
        );

  @override
  Future<String> action(CheckHostlessGoToBreakoutsRequest request) async {
    await CheckHostlessGoToBreakouts()
        .checkHostlessGoToBreakouts(request, 'server');

    return '';
  }
}
