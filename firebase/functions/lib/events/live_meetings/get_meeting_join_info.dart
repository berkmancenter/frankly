import 'dart:async';

import 'package:collection/collection.dart';
import 'package:firebase_functions_interop/firebase_functions_interop.dart';
import '../../utils/infra/firebase_auth_utils.dart';
import 'live_meeting_utils.dart';
import 'scheduled_end_meeting.dart';
import '../../on_call_function.dart';
import '../../utils/infra/firestore_utils.dart';
import 'package:data_models/cloud_functions/requests.dart';
import 'package:data_models/events/event.dart';
import 'package:data_models/events/live_meetings/live_meeting.dart';
import 'package:data_models/user/public_user_info.dart';
import 'package:data_models/utils/utils.dart';

class GetMeetingJoinInfo extends OnCallMethod<GetMeetingJoinInfoRequest> {
  LiveMeetingUtils liveMeetingUtils;
  GetMeetingJoinInfo({LiveMeetingUtils? liveMeetingUtils})
      : liveMeetingUtils = liveMeetingUtils ?? LiveMeetingUtils(),
        super(
          'GetMeetingJoinInfo',
          (jsonMap) => GetMeetingJoinInfoRequest.fromJson(jsonMap),
        );

  @override
  Future<Map<String, dynamic>> action(
    GetMeetingJoinInfoRequest request,
    CallableContext context,
  ) async {
    final result = await firestore.runTransaction((transaction) async {
      final event = await firestoreUtils.getFirestoreObject(
        transaction: transaction,
        path: request.eventPath,
        constructor: (map) => Event.fromJson(map),
      );

      final participant = await firestoreUtils.getFirestoreObject(
        transaction: transaction,
        path: '${request.eventPath}/event-participants/${context.authUid}',
        constructor: (map) => Participant.fromJson(map),
      );

      if (participant.status != ParticipantStatus.active) {
        throw HttpsError(HttpsError.failedPrecondition, 'unauthorized', null);
      }

      // Reject join if the meeting has already ended.
      final liveMeetingPath =
          '${request.eventPath}/live-meetings/${event.id}';
      final liveMeetingSnap =
          await transaction.get(firestore.document(liveMeetingPath));
      if (liveMeetingSnap.exists) {
        final liveMeeting = LiveMeeting.fromJson(
          firestoreUtils.fromFirestoreJson(liveMeetingSnap.data.toMap()),
        );
        if (liveMeeting.meetingEndedAt != null) {
          throw HttpsError(
            HttpsError.failedPrecondition,
            'meeting-ended',
            null,
          );
        }
      }

      // Decide on users identifier
      final userSnapshot =
          await firestore.document('publicUser/${context.authUid}').get();
      final publicUserInfo = PublicUserInfo.fromJson(
        firestoreUtils.fromFirestoreJson(userSnapshot.data.toMap()),
      );
      var displayName = publicUserInfo.displayName;
      print('Public user display name: $displayName');

      if (displayName == null || displayName.trim().isEmpty) {
        final userLookup = await firebaseAuthUtils.getUsers([context.authUid!]);
        displayName =
            firstAndLastInitial(userLookup.firstOrNull?.displayName) ??
                'User-${context.authUid!.substring(0, 4)}';
        print('Public user display name: $displayName');
      }

      return liveMeetingUtils.getMeetingJoinInfo(
        transaction: transaction,
        event: event,
        communityId: event.communityId,
        liveMeetingCollectionPath: '${request.eventPath}/live-meetings',
        meetingId: event.id,
        userId: context.authUid!,
      );
    });

    final pending = result.pendingRecording;
    if (pending != null) {
      await liveMeetingUtils.agoraUtils.recordRoom(
        roomId: pending.roomId,
        sessionId: pending.sessionId,
        eventId: pending.eventId,
        communityId: pending.communityId,
        roomType: pending.roomType,
        chatPath: pending.chatPath,
        participantIds: pending.participantIds,
      );
    }

    // On first join, schedule automatic meeting end if the event has
    // autoEndMeeting enabled, a scheduled time, and a duration.
    if (result.isFirstJoin) {
      final event = await firestoreUtils.getFirestoreObject(
        path: request.eventPath,
        constructor: (map) => Event.fromJson(map),
      );
      final autoEnd = event.eventSettings?.autoEndMeeting ?? false;
      if (autoEnd) {
        final scheduledTime = event.scheduledTime;
        if (scheduledTime != null) {
          final gracePeriod =
              event.eventSettings?.autoEndGracePeriodMinutes ?? 0;
          final endTime = scheduledTime.add(
            Duration(minutes: event.durationInMinutes + gracePeriod),
          );
          if (endTime.isAfter(DateTime.now())) {
            await ScheduledEndMeeting().schedule(
              EndMeetingForAllRequest(eventPath: request.eventPath),
              endTime,
            );
          }
        }
      }
    }

    return result.response.toJson();
  }
}
