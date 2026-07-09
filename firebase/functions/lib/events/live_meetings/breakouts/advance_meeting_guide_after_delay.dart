import 'dart:async';

import 'package:firebase_functions_interop/firebase_functions_interop.dart';
import '../../../on_call_function.dart';
import '../../../utils/infra/firestore_utils.dart';
import '../../../utils/utils.dart';
import 'check_advance_meeting_guide.dart';
import 'package:data_models/cloud_functions/requests.dart';
import 'package:data_models/events/event.dart';
import 'package:data_models/events/live_meetings/live_meeting.dart';

/// Performs the actual agenda item advance once the 10-second majority-vote countdown started by
/// [CheckAdvanceMeetingGuide] finishes. Scheduled via [AdvanceMeetingGuideAfterDelayServer].
class AdvanceMeetingGuideAfterDelay
    extends OnCallMethod<AdvanceMeetingGuideAfterDelayRequest> {
  AdvanceMeetingGuideAfterDelay()
      : super(
          AdvanceMeetingGuideAfterDelayRequest.functionName,
          (jsonMap) => AdvanceMeetingGuideAfterDelayRequest.fromJson(jsonMap),
        );

  @override
  Future<void> action(
    AdvanceMeetingGuideAfterDelayRequest request,
    CallableContext context,
  ) async {
    await advanceMeetingGuideAfterDelay(request);
  }

  Future<void> advanceMeetingGuideAfterDelay(
    AdvanceMeetingGuideAfterDelayRequest request,
  ) async {
    final event = await firestoreUtils.getFirestoreObject(
      path: request.eventPath,
      constructor: (map) => Event.fromJson(map),
    );

    final isBreakout = !isNullOrEmpty(request.breakoutRoomId);

    final liveMeetingPath = '${request.eventPath}/live-meetings/${event.id}';
    final breakoutLiveMeetingPath =
        '$liveMeetingPath/breakout-room-sessions/${request.breakoutSessionId}'
        '/breakout-rooms/${request.breakoutRoomId}/live-meetings/${request.breakoutRoomId}';

    final activeLiveMeetingPath =
        isBreakout ? breakoutLiveMeetingPath : liveMeetingPath;

    final liveMeeting = await firestoreUtils.getFirestoreObject(
      path: activeLiveMeetingPath,
      constructor: (map) => LiveMeeting.fromJson(map),
    );

    if (liveMeeting.pendingAdvanceAgendaItemId != request.agendaItemId) {
      print('Advance for ${request.agendaItemId} is no longer pending. '
          'Not advancing.');
      return;
    }

    await CheckAdvanceMeetingGuide().advanceMeetingGuide(
      event: event,
      liveMeetingPath: activeLiveMeetingPath,
      currentAgendaItemId: request.agendaItemId,
      parentLiveMeetingPath: isBreakout ? liveMeetingPath : null,
    );
  }
}
