import 'dart:async';

import 'advance_meeting_guide_after_delay.dart';
import '../../../on_request_method.dart';
import 'package:data_models/cloud_functions/requests.dart';

/// This is a wrapper on our [AdvanceMeetingGuideAfterDelay] function. Where that one could be
/// called directly, this one is called from the server at the scheduled time once a
/// majority-vote countdown finishes.
class AdvanceMeetingGuideAfterDelayServer
    extends OnRequestMethod<AdvanceMeetingGuideAfterDelayRequest> {
  AdvanceMeetingGuideAfterDelayServer()
      : super(
          AdvanceMeetingGuideAfterDelayRequest.functionName,
          (jsonMap) => AdvanceMeetingGuideAfterDelayRequest.fromJson(jsonMap),
        );

  @override
  Future<String> action(AdvanceMeetingGuideAfterDelayRequest request) async {
    await AdvanceMeetingGuideAfterDelay().advanceMeetingGuideAfterDelay(request);

    return '';
  }
}
