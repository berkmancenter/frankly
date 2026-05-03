import 'dart:async';

import 'package:firebase_admin_interop/firebase_admin_interop.dart';
import 'package:firebase_functions_interop/firebase_functions_interop.dart';
import '../../on_call_function.dart';
import '../../utils/infra/firestore_utils.dart';
import '../../utils/notifications_utils.dart';
import 'agora_api.dart';
import 'end_meeting_core.dart';
import 'package:data_models/cloud_functions/requests.dart';
import 'package:data_models/community/membership.dart';
import 'package:data_models/events/event.dart';
import 'package:data_models/events/live_meetings/live_meeting.dart';

class EndMeetingForAll extends OnCallMethod<EndMeetingForAllRequest> {
  static const String kEndMeetingForAllApi = 'endMeetingForAll';
  NotificationsUtils notificationsUtils;
  AgoraUtils agoraUtils;

  EndMeetingForAll(
      {NotificationsUtils? notificationsUtils, AgoraUtils? agoraUtils,})
      : notificationsUtils = notificationsUtils ?? NotificationsUtils(),
        agoraUtils = agoraUtils ?? AgoraUtils(),
        super(
          kEndMeetingForAllApi,
          (jsonMap) => EndMeetingForAllRequest.fromJson(jsonMap),
        );

  @override
  Future<void> action(
    EndMeetingForAllRequest request,
    CallableContext context,
  ) async {
    final event = await firestoreUtils.getFirestoreObject(
      path: request.eventPath,
      constructor: (map) => Event.fromJson(map),
    );

    // Verify caller is mod/admin/owner.
    final membership = await firestoreUtils.getFirestoreObject(
      path:
          'memberships/${context.authUid}/community-membership/${event.communityId}',
      constructor: (map) => Membership.fromJson(map),
    );
    const allowedStatuses = [
      MembershipStatus.moderator,
      MembershipStatus.admin,
      MembershipStatus.owner,
    ];
    if (!allowedStatuses.contains(membership.status)) {
      throw HttpsError(HttpsError.failedPrecondition, 'unauthorized', null);
    }

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

    if (!didEnd) return;

    await endMeetingCore(
      eventPath: request.eventPath,
      liveMeetingPath: liveMeetingPath,
      event: event,
      agoraUtils: agoraUtils,
      notificationsUtils: notificationsUtils,
    );
  }
}
