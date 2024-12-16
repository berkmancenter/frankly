import 'dart:async';

import 'package:firebase_functions_interop/firebase_functions_interop.dart';
import 'package:junto_functions/functions/on_call/initiate_breakouts.dart';
import 'package:junto_functions/functions/on_call_function.dart';
import 'package:junto_functions/functions/on_request/check_hostless_go_to_breakouts_server.dart';
import 'package:junto_functions/utils/firestore_utils.dart';
import 'package:junto_models/cloud_functions/requests.dart';
import 'package:junto_models/firestore/discussion.dart';
import 'package:junto_models/firestore/live_meeting.dart';

class CheckHostlessGoToBreakouts extends OnCallMethod<CheckHostlessGoToBreakoutsRequest> {
  CheckHostlessGoToBreakouts()
      : super(
          CheckHostlessGoToBreakoutsRequest.functionName,
          (jsonMap) => CheckHostlessGoToBreakoutsRequest.fromJson(jsonMap),
          runWithOptions:
              RuntimeOptions(timeoutSeconds: 240, memory: '4GB', minInstances: 0),
        );

  @override
  Future<void> action(CheckHostlessGoToBreakoutsRequest request, CallableContext context) async {
    await checkHostlessGoToBreakouts(request, context!.authUid!);
  }

  Future<void> checkHostlessGoToBreakouts(
      CheckHostlessGoToBreakoutsRequest request, String userId) async {
    final discussion = await firestoreUtils.getFirestoreObject(
      path: request.discussionPath,
      constructor: (map) => Discussion.fromJson(map),
    );
    print('Retrieved discussion: $discussion');

    if (discussion.discussionType != DiscussionType.hostless) {
      print('Discussion is not hostless, returning.');
      return;
    }

    if (discussion.status != DiscussionStatus.active) {
      print('Discussion is cancelled, returning.');
      return;
    }

    final nowWithBuffer = DateTime.now().add(const Duration(milliseconds: 100));

    final timeUntilWaitingRoomFinished = discussion.timeUntilWaitingRoomFinished(nowWithBuffer);

    print('comparing now ($nowWithBuffer) to scheduled start time (${discussion.scheduledTime}). '
        'Waiting room finished in $timeUntilWaitingRoomFinished');
    if (!timeUntilWaitingRoomFinished.isNegative) {
      print('It is still before scheduled start time so returning.');
      return;
    }

    final liveMeetingPath = '${discussion.fullPath}/live-meetings/${discussion.id}';
    final liveMeeting = await firestoreUtils.getFirestoreObject(
      path: liveMeetingPath,
      constructor: (map) => LiveMeeting.fromJson(map),
    );

    if ([BreakoutRoomStatus.active]
        .contains(liveMeeting.currentBreakoutSession?.breakoutRoomStatus)) {
      print('Breakouts have already been assigned so returning.');
      return;
    }
    const defaultTargetParticipants = 8;

    print('initializing breakouts');
    await InitiateBreakouts().initiateBreakouts(
      discussion: discussion,
      request: InitiateBreakoutsRequest(
        discussionPath: discussion.fullPath,
        // Use the discussion ID so that any duplicate checks will use the same breakout session ID.
        breakoutSessionId: discussion.id,
        assignmentMethod: discussion.breakoutRoomDefinition?.assignmentMethod ??
            BreakoutAssignmentMethod.targetPerRoom,
        targetParticipantsPerRoom:
            discussion.breakoutRoomDefinition?.targetParticipants ?? defaultTargetParticipants,
        includeWaitingRoom: true,
      ),
      creatorId: userId,
    );
    print('Finished initiating breakouts');
  }

  Future<void> enqueueScheduledCheck(Discussion discussion) async {
    final timeToGoToBreakouts =
        DateTime.now().add(discussion.timeUntilWaitingRoomFinished(DateTime.now()));

    await CheckHostlessGoToBreakoutsServer().schedule(
        CheckHostlessGoToBreakoutsRequest(discussionPath: discussion.fullPath),
        timeToGoToBreakouts);
  }
}
