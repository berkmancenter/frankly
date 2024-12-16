import 'dart:async';

import 'package:firebase_functions_interop/firebase_functions_interop.dart';
import 'package:functions/functions/on_call_function.dart';
import 'package:functions/utils/agora_api.dart';
import 'package:functions/utils/firestore_utils.dart';
import 'package:data_models/cloud_functions/requests.dart';
import 'package:data_models/firestore/event.dart';
import 'package:data_models/firestore/live_meeting.dart';
import 'package:data_models/firestore/membership.dart';

class KickParticipant extends OnCallMethod<KickParticipantRequest> {
  KickParticipant()
      : super(
          'KickParticipant',
          (json) => KickParticipantRequest.fromJson(json),
        );

  @override
  Future<String> action(
    KickParticipantRequest request,
    CallableContext context,
  ) async {
    final eventPath = request.eventPath;

    await firestore.runTransaction((transaction) async {
      final event = await firestoreUtils.getFirestoreObject(
        transaction: transaction,
        path: eventPath,
        constructor: (map) => Event.fromJson(map),
      );

      final communityMembershipDoc = await firestore
          .document(
            'memberships/${context.authUid}/community-membership/${event.communityId}',
          )
          .get();

      final membership = Membership.fromJson(
        firestoreUtils
            .fromFirestoreJson(communityMembershipDoc.data.toMap() ?? {}),
      );

      if (event.creatorId != context.authUid && !membership.isMod) {
        throw HttpsError(HttpsError.failedPrecondition, 'unauthorized', null);
      }

      final liveMeeting = await firestoreUtils.getFirestoreObject(
        transaction: transaction,
        path: '$eventPath/live-meetings/${event.id}',
        constructor: (map) => LiveMeeting.fromJson(map),
      );

      // Kick participant
      final roomId = request.breakoutRoomId ?? liveMeeting.meetingId ?? '';
      await AgoraUtils()
          .kickParticipant(roomId: roomId, userId: request.userToKickId);
    });

    return '';
  }
}
