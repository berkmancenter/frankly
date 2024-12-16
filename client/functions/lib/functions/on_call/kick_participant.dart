import 'dart:async';

import 'package:firebase_functions_interop/firebase_functions_interop.dart';
import 'package:junto_functions/functions/on_call_function.dart';
import 'package:junto_functions/utils/agora_api.dart';
import 'package:junto_functions/utils/firestore_utils.dart';
import 'package:junto_models/cloud_functions/requests.dart';
import 'package:junto_models/firestore/discussion.dart';
import 'package:junto_models/firestore/live_meeting.dart';
import 'package:junto_models/firestore/membership.dart';

class KickParticipant extends OnCallMethod<KickParticipantRequest> {
  KickParticipant()
      : super('KickParticipant', (json) => KickParticipantRequest.fromJson(json));

  @override
  Future<String> action(KickParticipantRequest request, CallableContext context) async {
    final discussionPath = request.discussionPath;

    await firestore.runTransaction((transaction) async {
      final discussion = await firestoreUtils.getFirestoreObject(
        transaction: transaction,
        path: discussionPath,
        constructor: (map) => Discussion.fromJson(map),
      );

      final juntoMembershipDoc = await firestore
          .document('memberships/${context?.authUid}/junto-membership/${discussion.juntoId}')
          .get();

      final membership = Membership.fromJson(firestoreUtils.fromFirestoreJson(juntoMembershipDoc.data?.toMap() ?? {}));

      if (discussion.creatorId != context?.authUid && !membership.isMod) {
        throw HttpsError(HttpsError.failedPrecondition, 'unauthorized', null);
      }

      final liveMeeting = await firestoreUtils.getFirestoreObject(
        transaction: transaction,
        path: '$discussionPath/live-meetings/${discussion.id}',
        constructor: (map) => LiveMeeting.fromJson(map),
      );

      // Kick participant
      final roomId = request.breakoutRoomId ?? liveMeeting.meetingId ?? '';
      await AgoraUtils().kickParticipant(roomId: roomId, userId: request.userToKickId);
    });

    return '';
  }
}
