import 'dart:async';

import 'package:firebase_functions_interop/firebase_functions_interop.dart';
import 'initiate_breakouts.dart';
import '../../../on_call_function.dart';
import 'check_hostless_go_to_breakouts_server.dart';
import '../../../utils/firestore_utils.dart';
import 'package:data_models/cloud_functions/requests.dart';
import 'package:data_models/firestore/event.dart';
import 'package:data_models/firestore/live_meeting.dart';

class CheckHostlessGoToBreakouts
    extends OnCallMethod<CheckHostlessGoToBreakoutsRequest> {
  CheckHostlessGoToBreakouts()
      : super(
          CheckHostlessGoToBreakoutsRequest.functionName,
          (jsonMap) => CheckHostlessGoToBreakoutsRequest.fromJson(jsonMap),
          runWithOptions: RuntimeOptions(
            timeoutSeconds: 240,
            memory: '4GB',
            minInstances: 0,
          ),
        );

  @override
  Future<void> action(
    CheckHostlessGoToBreakoutsRequest request,
    CallableContext context,
  ) async {
    await checkHostlessGoToBreakouts(request, context.authUid!);
  }

  Future<void> checkHostlessGoToBreakouts(
    CheckHostlessGoToBreakoutsRequest request,
    String userId,
  ) async {
    final event = await firestoreUtils.getFirestoreObject(
      path: request.eventPath,
      constructor: (map) => Event.fromJson(map),
    );
    print('Retrieved event: $event');

    if (event.eventType != EventType.hostless) {
      print('Event is not hostless, returning.');
      return;
    }

    if (event.status != EventStatus.active) {
      print('Event is cancelled, returning.');
      return;
    }

    final nowWithBuffer = DateTime.now().add(const Duration(milliseconds: 100));

    final timeUntilWaitingRoomFinished =
        event.timeUntilWaitingRoomFinished(nowWithBuffer);

    print(
        'comparing now ($nowWithBuffer) to scheduled start time (${event.scheduledTime}). '
        'Waiting room finished in $timeUntilWaitingRoomFinished');
    if (!timeUntilWaitingRoomFinished.isNegative) {
      print('It is still before scheduled start time so returning.');
      return;
    }

    final liveMeetingPath = '${event.fullPath}/live-meetings/${event.id}';
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
      event: event,
      request: InitiateBreakoutsRequest(
        eventPath: event.fullPath,
        // Use the event ID so that any duplicate checks will use the same breakout session ID.
        breakoutSessionId: event.id,
        assignmentMethod: event.breakoutRoomDefinition?.assignmentMethod ??
            BreakoutAssignmentMethod.targetPerRoom,
        targetParticipantsPerRoom:
            event.breakoutRoomDefinition?.targetParticipants ??
                defaultTargetParticipants,
        includeWaitingRoom: true,
      ),
      creatorId: userId,
    );
    print('Finished initiating breakouts');
  }

  Future<void> enqueueScheduledCheck(Event event) async {
    final timeToGoToBreakouts =
        DateTime.now().add(event.timeUntilWaitingRoomFinished(DateTime.now()));

    await CheckHostlessGoToBreakoutsServer().schedule(
      CheckHostlessGoToBreakoutsRequest(eventPath: event.fullPath),
      timeToGoToBreakouts,
    );
  }
}
