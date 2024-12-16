import 'dart:async';
import 'dart:math' as math;

import 'package:firebase_admin_interop/firebase_admin_interop.dart';
import 'package:firebase_functions_interop/firebase_functions_interop.dart';
import 'package:junto_functions/functions/on_call/assign_to_breakouts.dart';
import 'package:junto_functions/functions/on_call_function.dart';
import 'package:junto_functions/functions/on_request/check_assign_to_breakouts_server.dart';
import 'package:junto_functions/utils/firestore_utils.dart';
import 'package:junto_models/cloud_functions/requests.dart';
import 'package:junto_models/firestore/discussion.dart';
import 'package:junto_models/firestore/live_meeting.dart';
import 'package:junto_models/firestore/membership.dart';
import 'package:junto_models/utils.dart';
import 'package:meta/meta.dart';

class InitiateBreakouts extends OnCallMethod<InitiateBreakoutsRequest> {
  @visibleForTesting
  static math.Random random = math.Random();

  InitiateBreakouts()
      : super(
          InitiateBreakoutsRequest.functionName,
          (json) => InitiateBreakoutsRequest.fromJson(json),
          runWithOptions:
              RuntimeOptions(timeoutSeconds: 120, memory: '4GB', minInstances: 0),
        );

  @override
  Future<void> action(InitiateBreakoutsRequest request, CallableContext context) async {
    final discussion = await firestoreUtils.getFirestoreObject(
      path: request.discussionPath,
      constructor: (map) => Discussion.fromJson(map),
    );

    print('checking is authorized');
    await _verifyCallerIsAuthorized(discussion, context);

    await initiateBreakouts(
      request: request,
      discussion: discussion,
      creatorId: context!.authUid!,
    );
  }

  Future<void> _verifyCallerIsAuthorized(Discussion discussion, CallableContext context) async {
    final juntoMembershipDoc = await firestore
        .document('memberships/${context?.authUid}/junto-membership/${discussion.juntoId}')
        .get();

    final membership = Membership.fromJson(firestoreUtils.fromFirestoreJson(juntoMembershipDoc.data?.toMap() ?? {}));

    final isAuthorized = discussion.creatorId == context?.authUid || membership.isMod;
    if (!isAuthorized) {
      throw HttpsError(HttpsError.failedPrecondition, 'unauthorized', null);
    }
  }

  Future<void> initiateBreakouts({
    required InitiateBreakoutsRequest request,
    required Discussion discussion,
    required String creatorId,
  }) async {
    if (discussion.isHosted) {
      print('Assigning users to breakouts.');
      await AssignToBreakouts().assignToBreakouts(
        targetParticipantsPerRoom: request.targetParticipantsPerRoom,
        breakoutSessionId: request.breakoutSessionId,
        assignmentMethod: request.assignmentMethod ?? BreakoutAssignmentMethod.targetPerRoom,
        includeWaitingRoom: request.includeWaitingRoom,
        discussion: discussion,
        creatorId: creatorId,
      );
    } else {
      print('Pinging breakout availability.');
      await _pingBreakoutsAvailability(
        discussion: discussion,
        request: request,
      );
    }
  }

  Future<void> _pingBreakoutsAvailability({
    required Discussion discussion,
    required InitiateBreakoutsRequest request,
  }) async {
    final breakoutRoomSessionId = request.breakoutSessionId;
    final liveMeetingPath = '${discussion.fullPath}/live-meetings/${discussion.id}';

    const smartMatchingWaitTime = Duration(seconds: 30);

    final now = DateTime.now();
    final nowWithoutMilliseconds = now.subtract(Duration(milliseconds: now.millisecond));
    final scheduledTime = nowWithoutMilliseconds.add(smartMatchingWaitTime);

    final newlyInitiated = await firestore.runTransaction((transaction) async {
      final liveMeetingDocRef = firestore.document(liveMeetingPath);
      final liveMeetingDoc = await transaction.get(liveMeetingDocRef);
      final liveMeeting = LiveMeeting.fromJson(firestoreUtils.fromFirestoreJson(liveMeetingDoc.data.toMap()));
      if (liveMeeting.currentBreakoutSession?.breakoutRoomSessionId == breakoutRoomSessionId) {
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
        DocumentData.fromMap(jsonSubset(
            [LiveMeeting.kFieldCurrentBreakoutSession],
          firestoreUtils.toFirestoreJson(LiveMeeting(
              currentBreakoutSession: breakoutSession,
            ).toJson()))),
        merge: true,
      );
      return true;
    });

    if (newlyInitiated) {
      print('scheduling assign to breakouts server check');
      await CheckAssignToBreakoutsServer().schedule(
          CheckAssignToBreakoutsRequest(
            discussionPath: discussion.fullPath,
            breakoutSessionId: breakoutRoomSessionId,
          ),
          scheduledTime);
    } else {
      print('not enqueuing assign to breakouts checks since it was already setup.');
    }
  }
}
