import 'dart:async';

import 'package:firebase_functions_interop/firebase_functions_interop.dart';
import '../on_call_function.dart';
import 'notifications/event_emails.dart';
import '../utils/firestore_utils.dart';
import 'package:data_models/events/event.dart';
import 'package:data_models/community/community.dart';

/// This function handles events after event creation
class JoinEvent extends OnCallMethod<Event> {
  EventEmails eventEmailUtils;
  JoinEvent({EventEmails? eventEmailUtils})
      : eventEmailUtils = eventEmailUtils ?? EventEmails(),
        super('joinEvent', (jsonMap) => Event.fromJson(jsonMap));

  @override
  Future<void> action(Event request, CallableContext context) async {
    final participant = await firestoreUtils.getFirestoreObject(
      path:
          '${request.collectionPath}/${request.id}/event-participants/${context.authUid}',
      constructor: (map) => Participant.fromJson(map),
    );

    final community = await firestoreUtils.getFirestoreObject(
      path: 'community/${request.communityId}',
      constructor: (map) => Community.fromJson(map),
    );

    final suppressEmail = !(request.eventSettings?.reminderEmails ??
        community.eventSettingsMigration.reminderEmails ??
        true);
    if (participant.status == ParticipantStatus.active && !suppressEmail) {
      // Send initial sign up email to user.
      await eventEmailUtils.sendEmailsToUsers(
        eventPath:
            'community/${request.communityId}/templates/${request.templateId}/events/${request.id}',
        userIds: [context.authUid!],
        emailType: EventEmailType.initialSignUp,
      );
    }
  }
}
