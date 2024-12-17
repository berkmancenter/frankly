import 'dart:async';

import 'package:firebase_admin_interop/firebase_admin_interop.dart';
import 'package:firebase_functions_interop/firebase_functions_interop.dart';
import '../../../on_call_function.dart';
import '../../../utils/firestore_utils.dart';
import 'package:data_models/cloud_functions/requests.dart';
import 'package:data_models/firestore/event.dart';
import 'package:data_models/firestore/live_meeting.dart';
import 'package:data_models/firestore/membership.dart';
import 'package:data_models/utils.dart';

class UpdateBreakoutRoomFlagStatus
    extends OnCallMethod<UpdateBreakoutRoomFlagStatusRequest> {
  UpdateBreakoutRoomFlagStatus()
      : super(
          'UpdateBreakoutRoomFlagStatus',
          (json) => UpdateBreakoutRoomFlagStatusRequest.fromJson(json),
        );

  Future<void> _verifyCallerIsAuthorized(
    Event event,
    BreakoutRoom room,
    UpdateBreakoutRoomFlagStatusRequest request,
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

    final isAuthorizedParticipant =
        room.participantIds.contains(context.authUid) &&
            request.flagStatus == BreakoutRoomFlagStatus.needsHelp;
    final isCreator = event.creatorId == context.authUid;
    final isAuthorized =
        membership.isMod || isCreator || isAuthorizedParticipant;
    if (!isAuthorized) {
      throw HttpsError(HttpsError.failedPrecondition, 'unauthorized', null);
    }
  }

  @override
  Future<String> action(
    UpdateBreakoutRoomFlagStatusRequest request,
    CallableContext context,
  ) async {
    final event = await firestoreUtils.getFirestoreObject(
      path: request.eventPath,
      constructor: (map) => Event.fromJson(map),
    );

    await firestore.runTransaction((transaction) async {
      final breakoutRoomDoc = await firestore
          .document('${event.fullPath}/live-meetings/${event.id}'
              '/breakout-room-sessions/${request.breakoutSessionId}/breakout-rooms/${request.roomId}')
          .get();

      final requestedBreakoutRoom = BreakoutRoom.fromJson(
        firestoreUtils.fromFirestoreJson(breakoutRoomDoc.data.toMap() ?? {}),
      );

      await _verifyCallerIsAuthorized(
        event,
        requestedBreakoutRoom,
        request,
        context,
      );

      transaction.update(
        breakoutRoomDoc.reference,
        UpdateData.fromMap(
          jsonSubset(
            [BreakoutRoom.kFieldFlagStatus],
            firestoreUtils.toFirestoreJson(
              requestedBreakoutRoom
                  .copyWith(
                    flagStatus: request.flagStatus!,
                  )
                  .toJson(),
            ),
          ),
        ),
      );
    });

    return '';
  }
}
