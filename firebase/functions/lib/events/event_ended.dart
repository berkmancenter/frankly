import 'dart:async';

import 'package:firebase_admin_interop/firebase_admin_interop.dart'
    as admin_interop;
import 'package:firebase_functions_interop/firebase_functions_interop.dart';
import '../on_call_function.dart';
import '../utils/email_templates.dart';
import '../utils/infra/firestore_utils.dart';
import '../utils/notifications_utils.dart';
import '../utils/subscription_plan_util.dart';
import 'live_meetings/agora_api.dart';
import 'package:data_models/cloud_functions/requests.dart';
import 'package:data_models/events/event.dart';
import 'package:data_models/events/live_meetings/live_meeting.dart';
import 'package:data_models/community/community.dart';

/// This function handles events after event ends
class EventEnded extends OnCallMethod<EventEndedRequest> {
  static const String kEventEndedApi = 'eventEnded';
  NotificationsUtils notificationsUtils;
  AgoraUtils agoraUtils;

  EventEnded({NotificationsUtils? notificationsUtils, AgoraUtils? agoraUtils})
      : notificationsUtils = notificationsUtils ?? NotificationsUtils(),
        agoraUtils = agoraUtils ?? AgoraUtils(),
        super(
          kEventEndedApi,
          (jsonMap) => EventEndedRequest.fromJson(jsonMap),
        );

  @override
  Future<void> action(
    EventEndedRequest request,
    CallableContext context,
  ) async {
    final participant = await firestoreUtils.getFirestoreObject(
      path: '${request.eventPath}/event-participants/${context.authUid}',
      constructor: (map) => Participant.fromJson(map),
    );

    // Check that user is an active participant
    if (participant.status != ParticipantStatus.active) {
      throw HttpsError(HttpsError.failedPrecondition, 'unauthorized', null);
    }

    final event = await firestoreUtils.getFirestoreObject(
      path: request.eventPath,
      constructor: (map) => Event.fromJson(map),
    );

    // Stop main room recording if one is active.
    final liveMeetingPath = '${request.eventPath}/live-meetings/${event.id}';
    try {
      final liveMeeting = await firestoreUtils.getFirestoreObject(
        path: liveMeetingPath,
        constructor: (map) => LiveMeeting.fromJson(map),
      );
      if (liveMeeting.recordingSessionId != null) {
        await agoraUtils.stopRoom(sessionId: liveMeeting.recordingSessionId!);
      }
    } catch (e) {
      // Do not block event-ended flow on recording stop failure.
      print('Error stopping main room recording on event end: $e');
    }

    // Stop all breakout room recordings.
    // Structure: {liveMeetingPath}/breakout-room-sessions/{sessionId}/breakout-rooms/{roomId}
    try {
      final breakoutSessionDocs = await firestore
          .collection('$liveMeetingPath/breakout-room-sessions')
          .get();
      for (final sessionDoc in breakoutSessionDocs.documents) {
        final breakoutRoomDocs = await firestore
            .collection('${sessionDoc.reference.path}/breakout-rooms')
            .get();
        for (final roomDoc in breakoutRoomDocs.documents) {
          final breakoutRoom = BreakoutRoom.fromJson(
            firestoreUtils.fromFirestoreJson(roomDoc.data.toMap()),
          );
          if (breakoutRoom.recordingSessionId != null) {
            try {
              await agoraUtils.stopRoom(
                  sessionId: breakoutRoom.recordingSessionId!);
            } catch (e) {
              print(
                  'Error stopping breakout recording ${breakoutRoom.recordingSessionId}: $e');
            }
          }
        }
      }
    } catch (e) {
      print('Error stopping breakout room recordings on event end: $e');
    }

    final capabilities =
        await subscriptionPlanUtil.calculateCapabilities(event.communityId);
    final hasPrePost = capabilities.hasPrePost ?? false;

    await notificationsUtils.sendEventEndedEmail(
      event: event,
      communityId: event.communityId,
      userIds: [context.authUid!],
      emailType: EventEmailType.ended,
      generateMessage: (Community community, admin_interop.UserRecord user) =>
          SendGridEmailMessage(
        subject: 'Thanks for joining',
        html: generateEventEndedContent(
          header: 'Thanks for joining ${event.title}!',
          community: community,
          userRecord: user,
          event: event,
          allowPrePost: hasPrePost,
        ),
      ),
    );
  }
}
