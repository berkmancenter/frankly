import 'dart:async';

import 'package:junto_functions/functions/on_request_method.dart';
import 'package:junto_functions/utils/scheduled_functions.dart';
import 'package:junto_models/cloud_functions/requests.dart';

/// This class reschedules cloud tasks that exceed the 30 day quota for cloud tasks scheduling.
class ExtendCloudTaskScheduler extends OnRequestMethod<ExtendCloudTaskSchedulerRequest> {
  ExtendCloudTaskScheduler()
      : super(
          'ExtendCloudTaskScheduler',
          (jsonMap) => ExtendCloudTaskSchedulerRequest.fromJson(jsonMap),
        );

  @override
  Future<String> action(ExtendCloudTaskSchedulerRequest request) async {
    await scheduledFunctions.enqueueCall(
      request.functionName,
      request.payload,
      request.scheduledTime,
    );

    return '';
  }
}
