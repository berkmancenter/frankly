import 'dart:async';

import 'package:firebase_functions_interop/firebase_functions_interop.dart';
import 'package:junto_functions/functions/on_call/assign_to_breakouts.dart';
import 'package:junto_functions/functions/on_call_function.dart';
import 'package:junto_functions/utils/firestore_utils.dart';
import 'package:junto_models/cloud_functions/requests.dart';
import 'package:junto_models/firestore/discussion.dart';
import 'package:junto_models/firestore/live_meeting.dart';

class CheckAssignToBreakouts extends OnCallMethod<CheckAssignToBreakoutsRequest> {
  static const _clockSkewBuffer = Duration(milliseconds: 100);

  CheckAssignToBreakouts()
      : super(
          CheckAssignToBreakoutsRequest.functionName,
          (jsonMap) => CheckAssignToBreakoutsRequest.fromJson(jsonMap),
          runWithOptions:
              RuntimeOptions(timeoutSeconds: 240, memory: '4GB', minInstances: 0),
        );

  @override
  Future<void> action(CheckAssignToBreakoutsRequest request, CallableContext context) async {
    await checkAssignToBreakouts(request, context!.authUid!);
  }

  Future<void> checkAssignToBreakouts(CheckAssignToBreakoutsRequest request, String userId) async {
    final discussion = await firestoreUtils.getFirestoreObject(
      path: request.discussionPath,
      constructor: (map) => Discussion.fromJson(map),
    );
    print('Retrieved discussion: $discussion');

    if (discussion.status != DiscussionStatus.active) {
      print('Discussion is cancelled, returning.');
      return;
    }

    final liveMeetingPath = '${discussion.fullPath}/live-meetings/${discussion.id}';
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
    final scheduledStartTime = breakoutSession.scheduledTime?.subtract(_clockSkewBuffer);
    if (scheduledStartTime == null) {
      print('Scheduled start time is null.');
      return;
    }

    final now = DateTime.now();
    print('Comparing now ($now) and scheduled start time ($scheduledStartTime) with buffer');
    if (now.isBefore(scheduledStartTime)) {
      print(
          'It is currently ($now) still before scheduled start time ($scheduledStartTime) so returning.');
      return;
    }

    if (breakoutSession.breakoutRoomSessionId != request.breakoutSessionId) {
      print('Current breakout session (${breakoutSession.breakoutRoomSessionId})'
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
      discussion: discussion,
      creatorId: userId,
    );
  }
}
