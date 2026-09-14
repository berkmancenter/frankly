import 'package:firebase_admin_interop/firebase_admin_interop.dart'
    as admin_interop;
import '../../utils/email_templates.dart';
import '../../utils/infra/firestore_utils.dart';
import '../../utils/notifications_utils.dart';
import '../../utils/subscription_plan_util.dart';
import '../../admin/payments/analytics_util.dart';
import 'agora_api.dart';
import 'stop_all_event_recordings.dart';
import 'package:data_models/analytics/analytics_entities.dart';
import 'package:data_models/cloud_functions/requests.dart';
import 'package:data_models/community/community.dart';
import 'package:data_models/events/event.dart';
import 'package:data_models/events/live_meetings/live_meeting.dart';

/// Shared post-transaction logic for ending a meeting: stop recordings,
/// query active participants, send the post-event email, and log analytics.
Future<void> endMeetingCore({
  required String eventPath,
  required String liveMeetingPath,
  required Event event,
  required AgoraUtils agoraUtils,
  required NotificationsUtils notificationsUtils,
  String? callerUid,
}) async {
  // Run recording stops in parallel with participant query + email send.
  final recordingsFuture = stopAllEventRecordings(
    liveMeetingPath: liveMeetingPath,
    agoraUtils: agoraUtils,
  );

  final emailFuture = _sendEndedEmail(
    eventPath: eventPath,
    event: event,
    notificationsUtils: notificationsUtils,
  );

  await Future.wait([recordingsFuture, emailFuture]);

  await _logMeetingEndAnalytics(
    liveMeetingPath: liveMeetingPath,
    event: event,
    callerUid: callerUid,
  );
}

Future<void> _sendEndedEmail({
  required String eventPath,
  required Event event,
  required NotificationsUtils notificationsUtils,
}) async {
  final participantDocs = await firestore
      .collection('$eventPath/event-participants')
      .get();
  final activeParticipantIds = participantDocs.documents
      .map((doc) => Participant.fromJson(
            firestoreUtils.fromFirestoreJson(doc.data.toMap()),
          ),)
      .where((p) => p.status == ParticipantStatus.active)
      .map((p) => p.id)
      .whereType<String>()
      .toList();

  if (activeParticipantIds.isEmpty) return;

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
}

/// Reads the live meeting events to determine meeting start time, calculates
/// duration, and logs a "Complete Event" analytics event to Segment/Matomo.
Future<void> _logMeetingEndAnalytics({
  required String liveMeetingPath,
  required Event event,
  String? callerUid,
}) async {
  try {
    final liveMeetingSnap = await firestore.document(liveMeetingPath).get();
    if (!liveMeetingSnap.exists) return;

    final liveMeeting = LiveMeeting.fromJson(
      firestoreUtils.fromFirestoreJson(liveMeetingSnap.data.toMap()),
    );

    final startEvent = liveMeeting.events
        .where((e) => e.event == LiveMeetingEventType.agendaItemStarted)
        .firstOrNull;

    final DateTime? startTime = startEvent?.timestamp;
    final int durationInSeconds =
        startTime == null ? 0 : DateTime.now().difference(startTime).inSeconds;

    final userId = callerUid ?? event.creatorId ?? 'system';
    final bool asHost = callerUid != null &&
        event.eventType != EventType.hostless &&
        event.creatorId == callerUid;

    analyticsUtil.logEvent(
      userId: userId,
      event: AnalyticsCompleteEventEvent(
        communityId: event.communityId,
        eventId: event.id,
        asHost: asHost,
        templateId: event.templateId,
        duration: durationInSeconds,
      ),
    );
  } catch (e) {
    print('Failed to log meeting end analytics: $e');
  }
}
