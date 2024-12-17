import 'dart:async';
import 'dart:math' as math;

import 'package:firebase_admin_interop/firebase_admin_interop.dart';
import 'package:firebase_functions_interop/firebase_functions_interop.dart';
import 'assign_to_breakouts.dart';
import '../../../on_call_function.dart';
import 'check_assign_to_breakouts_server.dart';
import '../../../utils/firestore_utils.dart';
import 'package:data_models/cloud_functions/requests.dart';
import 'package:data_models/events/event.dart';
import 'package:data_models/events/live_meetings/live_meeting.dart';
import 'package:data_models/community/membership.dart';
import 'package:data_models/utils/utils.dart';
import 'package:meta/meta.dart';

class InitiateBreakouts extends OnCallMethod<InitiateBreakoutsRequest> {
  @visibleForTesting
  static math.Random random = math.Random();

  InitiateBreakouts()
      : super(
          InitiateBreakoutsRequest.functionName,
          (json) => InitiateBreakoutsRequest.fromJson(json),
          runWithOptions: RuntimeOptions(
            timeoutSeconds: 120,
            memory: '4GB',
            minInstances: 0,
          ),
        );

  @override
  Future<void> action(
    InitiateBreakoutsRequest request,
    CallableContext context,
  ) async {
    final event = await firestoreUtils.getFirestoreObject(
      path: request.eventPath,
      constructor: (map) => Event.fromJson(map),
    );

    print('checking is authorized');
    await _verifyCallerIsAuthorized(event, context);

    await initiateBreakouts(
      request: request,
      event: event,
      creatorId: context.authUid!,
    );
  }

  Future<void> _verifyCallerIsAuthorized(
    Event event,
    CallableContext context,
  ) async {
    final communityMembershipDoc = await firestore
        .document(
          'memberships/${context.authUid}/community-membership/${event.communityId}',
        )
        .get();

    final membership = Membership.fromJson(
      firestoreUtils
          .fromFirestoreJson(communityMembershipDoc.data.toMap() ?? {}),
    );

    final isAuthorized = event.creatorId == context.authUid || membership.isMod;
    if (!isAuthorized) {
      throw HttpsError(HttpsError.failedPrecondition, 'unauthorized', null);
    }
  }

  Future<void> initiateBreakouts({
    required InitiateBreakoutsRequest request,
    required Event event,
    required String creatorId,
  }) async {
    if (event.isHosted) {
      print('Assigning users to breakouts.');
      await AssignToBreakouts().assignToBreakouts(
        targetParticipantsPerRoom: request.targetParticipantsPerRoom,
        breakoutSessionId: request.breakoutSessionId,
        assignmentMethod:
            request.assignmentMethod ?? BreakoutAssignmentMethod.targetPerRoom,
        includeWaitingRoom: request.includeWaitingRoom,
        event: event,
        creatorId: creatorId,
      );
    } else {
      print('Pinging breakout availability.');
      await _pingBreakoutsAvailability(
        event: event,
        request: request,
      );
    }
  }

  Future<void> _pingBreakoutsAvailability({
    required Event event,
    required InitiateBreakoutsRequest request,
  }) async {
    final breakoutRoomSessionId = request.breakoutSessionId;
    final liveMeetingPath = '${event.fullPath}/live-meetings/${event.id}';

    const smartMatchingWaitTime = Duration(seconds: 30);

    final now = DateTime.now();
    final nowWithoutMilliseconds =
        now.subtract(Duration(milliseconds: now.millisecond));
    final scheduledTime = nowWithoutMilliseconds.add(smartMatchingWaitTime);

    final newlyInitiated = await firestore.runTransaction((transaction) async {
      final liveMeetingDocRef = firestore.document(liveMeetingPath);
      final liveMeetingDoc = await transaction.get(liveMeetingDocRef);
      final liveMeeting = LiveMeeting.fromJson(
        firestoreUtils.fromFirestoreJson(liveMeetingDoc.data.toMap()),
      );
      if (liveMeeting.currentBreakoutSession?.breakoutRoomSessionId ==
          breakoutRoomSessionId) {
        print('Breakout session already initiated. Returning');
        return false;
      }
      final breakoutSession = BreakoutRoomSession(
        breakoutRoomSessionId: breakoutRoomSessionId,
        breakoutRoomStatus: BreakoutRoomStatus.pending,
        assignmentMethod: request.assignmentMethod!,
        targetParticipantsPerRoom: request.targetParticipantsPerRoom,
        hasWaitingRoom: request.includeWaitingRoom,
        scheduledTime: scheduledTime,
      );
      transaction.set(
        liveMeetingDocRef,
        DocumentData.fromMap(
          jsonSubset(
            [LiveMeeting.kFieldCurrentBreakoutSession],
            firestoreUtils.toFirestoreJson(
              LiveMeeting(
                currentBreakoutSession: breakoutSession,
              ).toJson(),
            ),
          ),
        ),
        merge: true,
      );
      return true;
    });

    if (newlyInitiated) {
      print('scheduling assign to breakouts server check');
      await CheckAssignToBreakoutsServer().schedule(
        CheckAssignToBreakoutsRequest(
          eventPath: event.fullPath,
          breakoutSessionId: breakoutRoomSessionId,
        ),
        scheduledTime,
      );
    } else {
      print(
        'not enqueuing assign to breakouts checks since it was already setup.',
      );
    }
  }
}
