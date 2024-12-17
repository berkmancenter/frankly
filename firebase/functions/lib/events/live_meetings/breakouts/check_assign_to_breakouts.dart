import 'dart:async';

import 'package:firebase_functions_interop/firebase_functions_interop.dart';
import 'assign_to_breakouts.dart';
import '../../../on_call_function.dart';
import '../../../utils/firestore_utils.dart';
import 'package:data_models/cloud_functions/requests.dart';
import 'package:data_models/firestore/event.dart';
import 'package:data_models/firestore/live_meeting.dart';

class CheckAssignToBreakouts
    extends OnCallMethod<CheckAssignToBreakoutsRequest> {
  static const _clockSkewBuffer = Duration(milliseconds: 100);

  CheckAssignToBreakouts()
      : super(
          CheckAssignToBreakoutsRequest.functionName,
          (jsonMap) => CheckAssignToBreakoutsRequest.fromJson(jsonMap),
          runWithOptions: RuntimeOptions(
            timeoutSeconds: 240,
            memory: '4GB',
            minInstances: 0,
          ),
        );

  @override
  Future<void> action(
    CheckAssignToBreakoutsRequest request,
    CallableContext context,
  ) async {
    await checkAssignToBreakouts(request, context.authUid!);
  }

  Future<void> checkAssignToBreakouts(
    CheckAssignToBreakoutsRequest request,
    String userId,
  ) async {
    final event = await firestoreUtils.getFirestoreObject(
      path: request.eventPath,
      constructor: (map) => Event.fromJson(map),
    );
    print('Retrieved event: $event');

    if (event.status != EventStatus.active) {
      print('Event is cancelled, returning.');
      return;
    }

    final liveMeetingPath = '${event.fullPath}/live-meetings/${event.id}';
    final liveMeeting = await firestoreUtils.getFirestoreObject(
      path: liveMeetingPath,
      constructor: (map) => LiveMeeting.fromJson(map),
    );

    final breakoutSession = liveMeeting.currentBreakoutSession;

    if (breakoutSession == null) {
      print('Breakout session not found in live meeting.');
      return;
    }

    // Check if it is currently after the expected amount of time of the waiting room
    final scheduledStartTime =
        breakoutSession.scheduledTime?.subtract(_clockSkewBuffer);
    if (scheduledStartTime == null) {
      print('Scheduled start time is null.');
      return;
    }

    final now = DateTime.now();
    print(
      'Comparing now ($now) and scheduled start time ($scheduledStartTime) with buffer',
    );
    if (now.isBefore(scheduledStartTime)) {
      print(
        'It is currently ($now) still before scheduled start time ($scheduledStartTime) so returning.',
      );
      return;
    }

    if (breakoutSession.breakoutRoomSessionId != request.breakoutSessionId) {
      print(
          'Current breakout session (${breakoutSession.breakoutRoomSessionId})'
          ' does not match requested session ID (${request.breakoutSessionId}).');
      return;
    }

    if (BreakoutRoomStatus.active == breakoutSession.breakoutRoomStatus) {
      print('Breakouts have already been assigned so returning.');
      return;
    }

    await AssignToBreakouts().assignToBreakouts(
      breakoutSessionId: breakoutSession.breakoutRoomSessionId,
      assignmentMethod: breakoutSession.assignmentMethod,
      targetParticipantsPerRoom: breakoutSession.targetParticipantsPerRoom,
      includeWaitingRoom: breakoutSession.hasWaitingRoom,
      event: event,
      creatorId: userId,
    );
  }
}
