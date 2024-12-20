import 'dart:async';

import 'package:firebase_functions_interop/firebase_functions_interop.dart';
import 'live_meetings/breakouts/check_hostless_go_to_breakouts.dart';
import '../on_call_function.dart';
import 'notifications/event_emails.dart';
import '../utils/emulator_utils.dart';
import '../utils/firestore_utils.dart';
import 'package:data_models/cloud_functions/requests.dart';
import 'package:data_models/events/event.dart';
import 'package:data_models/community/membership.dart';

/// This function handles events after event creation
class CreateEvent extends OnCallMethod<CreateEventRequest> {
  EventEmails eventEmailUtils;
  CheckHostlessGoToBreakouts checkHostlessGoToBreakouts;

  CreateEvent({
    EventEmails? eventEmailUtils,
    CheckHostlessGoToBreakouts? checkHostlessGoToBreakouts,
  })  : eventEmailUtils = eventEmailUtils ?? EventEmails(),
        checkHostlessGoToBreakouts =
            checkHostlessGoToBreakouts ?? CheckHostlessGoToBreakouts(),
        super(
          CreateEventRequest.functionName,
          (jsonMap) => CreateEventRequest.fromJson(jsonMap),
        );

  @override
  Future<void> action(
    CreateEventRequest request,
    CallableContext context,
  ) async {
    final event = await firestoreUtils.getFirestoreObject(
      path: request.eventPath,
      constructor: (map) => Event.fromJson(map),
    );

    final membershipDoc = await firestore
        .document(
          'memberships/${context.authUid}/community-membership/${event.communityId}',
        )
        .get();
    final membership = Membership.fromJson(
      firestoreUtils.fromFirestoreJson(membershipDoc.data.toMap() ?? {}),
    );
    final isModOrCreator =
        event.creatorId == context.authUid || membership.isMod;

    if (!isEmulator && !isModOrCreator) {
      throw HttpsError(HttpsError.failedPrecondition, 'unauthorized', null);
    }

    await _handleEmailNotifications(event);

    if (event.eventType == EventType.hostless) {
      await checkHostlessGoToBreakouts.enqueueScheduledCheck(event);
    }
  }

  Future<void> _handleEmailNotifications(Event event) async {
    // Send initial sign up email to user.
    await eventEmailUtils.sendEmailsToUsers(
      eventPath: event.fullPath,
      userIds: [event.creatorId],
      emailType: EventEmailType.initialSignUp,
    );

    await eventEmailUtils.enqueueReminders(event);
  }
}
