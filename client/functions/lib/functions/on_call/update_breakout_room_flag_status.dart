import 'dart:async';

import 'package:firebase_admin_interop/firebase_admin_interop.dart';
import 'package:firebase_functions_interop/firebase_functions_interop.dart';
import 'package:junto_functions/functions/on_call_function.dart';
import 'package:junto_functions/utils/firestore_utils.dart';
import 'package:junto_models/cloud_functions/requests.dart';
import 'package:junto_models/firestore/discussion.dart';
import 'package:junto_models/firestore/live_meeting.dart';
import 'package:junto_models/firestore/membership.dart';
import 'package:junto_models/utils.dart';

class UpdateBreakoutRoomFlagStatus extends OnCallMethod<UpdateBreakoutRoomFlagStatusRequest> {
  UpdateBreakoutRoomFlagStatus()
      : super(
          'UpdateBreakoutRoomFlagStatus',
          (json) => UpdateBreakoutRoomFlagStatusRequest.fromJson(json),
        );

  Future<void> _verifyCallerIsAuthorized(Discussion discussion, BreakoutRoom room,
      UpdateBreakoutRoomFlagStatusRequest request, CallableContext context) async {
    final juntoMembershipDoc = await firestore
        .document('memberships/${context?.authUid}/junto-membership/${discussion.juntoId}')
        .get();

    final membership = Membership.fromJson(firestoreUtils.fromFirestoreJson(juntoMembershipDoc.data?.toMap() ?? {}));

    final isAuthorizedParticipant = room.participantIds.contains(context?.authUid) &&
        request.flagStatus == BreakoutRoomFlagStatus.needsHelp;
    final isCreator = discussion.creatorId == context?.authUid;
    final isAuthorized = membership.isMod || isCreator || isAuthorizedParticipant;
    if (!isAuthorized) {
      throw HttpsError(HttpsError.failedPrecondition, 'unauthorized', null);
    }
  }

  @override
  Future<String> action(
      UpdateBreakoutRoomFlagStatusRequest request, CallableContext context) async {
    final discussion = await firestoreUtils.getFirestoreObject(
      path: request.discussionPath,
      constructor: (map) => Discussion.fromJson(map),
    );

    await firestore.runTransaction((transaction) async {
      final breakoutRoomDoc = await firestore
          .document('${discussion.fullPath}/live-meetings/${discussion.id}'
              '/breakout-room-sessions/${request.breakoutSessionId}/breakout-rooms/${request.roomId}')
          .get();

      final requestedBreakoutRoom = BreakoutRoom.fromJson(firestoreUtils.fromFirestoreJson(breakoutRoomDoc.data?.toMap() ?? {}));

      await _verifyCallerIsAuthorized(discussion, requestedBreakoutRoom, request, context);

      transaction.update(
          breakoutRoomDoc.reference,
          UpdateData.fromMap(jsonSubset(
              [BreakoutRoom.kFieldFlagStatus],
          firestoreUtils.toFirestoreJson(requestedBreakoutRoom
                  .copyWith(
                    flagStatus: request.flagStatus!,
                  )
                  .toJson()))));
    });

    return '';
  }
}
