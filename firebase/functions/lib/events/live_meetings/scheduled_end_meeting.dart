import 'dart:async';

import 'package:firebase_admin_interop/firebase_admin_interop.dart';
import 'package:firebase_functions_interop/firebase_functions_interop.dart'
    hide CloudFunction;
import '../../on_request_method.dart';
import '../../utils/infra/firestore_utils.dart';
import '../../utils/notifications_utils.dart';
import 'agora_api.dart';
import 'end_meeting_core.dart';
import 'package:data_models/cloud_functions/requests.dart';
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
  Future<void> handleRequest(ExpressHttpRequest expressRequest) async {
    // Only Cloud Tasks sets X-CloudTasks-TaskName. Cloud Functions strips
    // this header from external requests, so its presence confirms the
    // call originated from a Cloud Tasks queue.
    final taskName = expressRequest.headers.value('X-CloudTasks-TaskName');
    if (taskName == null || taskName.isEmpty) {
      expressRequest.response.statusCode = 403;
      expressRequest.response.write('Forbidden');
      return;
    }
    await super.handleRequest(expressRequest);
  }

  @override
  Future<String> action(EndMeetingForAllRequest request) async {
    final event = await firestoreUtils.getFirestoreObject(
      path: request.eventPath,
      constructor: (map) => Event.fromJson(map),
    );

    // Atomically set meetingEndedAt. If already set, return (idempotent).
    final liveMeetingPath = '${request.eventPath}/live-meetings/${event.id}';
    final liveMeetingRef = firestore.document(liveMeetingPath);
    final didEnd = await firestore.runTransaction<bool>((transaction) async {
      final snap = await transaction.get(liveMeetingRef);
      final liveMeeting = LiveMeeting.fromJson(
        firestoreUtils.fromFirestoreJson(snap.data.toMap()),
      );
      if (liveMeeting.meetingEndedAt != null) {
        return false;
      }
      transaction.update(
        liveMeetingRef,
        UpdateData.fromMap({
          LiveMeeting.kFieldMeetingEndedAt:
              Firestore.fieldValues.serverTimestamp(),
        }),
      );
      return true;
    });

    if (!didEnd) return '';

    await endMeetingCore(
      eventPath: request.eventPath,
      liveMeetingPath: liveMeetingPath,
      event: event,
      agoraUtils: agoraUtils,
      notificationsUtils: notificationsUtils,
    );

    return '';
  }
}
