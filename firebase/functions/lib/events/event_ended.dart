import 'dart:async';

import 'package:firebase_admin_interop/firebase_admin_interop.dart'
    as admin_interop;
import 'package:firebase_functions_interop/firebase_functions_interop.dart';
import '../on_call_function.dart';
import '../utils/email_templates.dart';
import '../utils/firestore_utils.dart';
import '../utils/notifications_utils.dart';
import '../utils/subscription_plan_util.dart';
import 'package:data_models/cloud_functions/requests.dart';
import 'package:data_models/firestore/event.dart';
import 'package:data_models/firestore/community.dart';

/// This function handles events after event ends
class EventEnded extends OnCallMethod<EventEndedRequest> {
  static const String kEventEndedApi = 'eventEnded';
  NotificationsUtils notificationsUtils;

  EventEnded({NotificationsUtils? notificationsUtils})
      : notificationsUtils = notificationsUtils ?? NotificationsUtils(),
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
