import 'dart:async';

import 'package:firebase_admin_interop/firebase_admin_interop.dart'
    as admin_interop;
import 'package:firebase_admin_interop/firebase_admin_interop.dart';
import '../../on_request_method.dart';
import '../../utils/email_templates.dart';
import '../../utils/infra/firestore_utils.dart';
import '../../utils/notifications_utils.dart';
import '../../utils/subscription_plan_util.dart';
import 'agora_api.dart';
import 'stop_all_event_recordings.dart';
import 'package:data_models/cloud_functions/requests.dart';
import 'package:data_models/community/community.dart';
import 'package:data_models/events/event.dart';
import 'package:data_models/events/live_meetings/live_meeting.dart';

class ScheduledEndMeeting
    extends OnRequestMethod<EndMeetingForAllRequest> {
  NotificationsUtils notificationsUtils;
  AgoraUtils agoraUtils;

  ScheduledEndMeeting(
      {NotificationsUtils? notificationsUtils, AgoraUtils? agoraUtils,})
      : notificationsUtils = notificationsUtils ?? NotificationsUtils(),
        agoraUtils = agoraUtils ?? AgoraUtils(),
        super(
          'ScheduledEndMeeting',
          (jsonMap) => EndMeetingForAllRequest.fromJson(jsonMap),
        );

  @override
  Future<String> action(EndMeetingForAllRequest request) async {
    final event = await firestoreUtils.getFirestoreObject(
      path: request.eventPath,
      constructor: (map) => Event.fromJson(map),
    );

    final liveMeetingPath = '${request.eventPath}/live-meetings/${event.id}';
    final liveMeeting = await firestoreUtils.getFirestoreObject(
      path: liveMeetingPath,
      constructor: (map) => LiveMeeting.fromJson(map),
    );

    // Already ended (by host or a previous task). No-op.
    if (liveMeeting.meetingEndedAt != null) {
      return '';
    }

    // Write meetingEndedAt to the LiveMeeting doc.
    await firestore.document(liveMeetingPath).updateData(
          UpdateData.fromMap({
            LiveMeeting.kFieldMeetingEndedAt:
                Firestore.fieldValues.serverTimestamp(),
          }),
        );

    // Stop all recordings (main + breakout).
    await stopAllEventRecordings(
      liveMeetingPath: liveMeetingPath,
      agoraUtils: agoraUtils,
    );

    // Send the post-event email to all active participants.
    final participantDocs = await firestore
        .collection('${request.eventPath}/event-participants')
        .get();
    final activeParticipantIds = participantDocs.documents
        .map((doc) => Participant.fromJson(
              firestoreUtils.fromFirestoreJson(doc.data.toMap()),
            ),)
        .where((p) => p.status == ParticipantStatus.active)
        .map((p) => p.id)
        .whereType<String>()
        .toList();

    if (activeParticipantIds.isEmpty) return '';

    final capabilities =
        await subscriptionPlanUtil.calculateCapabilities(event.communityId);
    final hasPrePost = capabilities.hasPrePost ?? false;

    await notificationsUtils.sendEventEndedEmail(
      event: event,
      communityId: event.communityId,
      userIds: activeParticipantIds,
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

    return '';
  }
}
