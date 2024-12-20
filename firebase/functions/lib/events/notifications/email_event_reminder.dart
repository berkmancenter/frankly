import 'dart:async';

import '../../on_request_method.dart';
import 'event_emails.dart';
import '../../utils/firestore_utils.dart';
import 'package:data_models/cloud_functions/requests.dart';
import 'package:data_models/firestore/event.dart';
import 'package:data_models/firestore/community.dart';

/// This request method is called from our scheduled task queue.
///
/// It checks to see if this type of event email has been sent to this user
/// before and if not, sends the email.
class EmailEventReminder extends OnRequestMethod<EmailEventReminderRequest> {
  EventEmails eventEmailUtils;

  EmailEventReminder({EventEmails? eventEmailUtils})
      : eventEmailUtils = eventEmailUtils ?? EventEmails(),
        super(
          'EmailEventReminder',
          (jsonMap) => EmailEventReminderRequest.fromJson(jsonMap),
        );

  static final emailReminderOffset = <EventEmailType, Duration>{
    EventEmailType.oneDayReminder: const Duration(days: 1),
    EventEmailType.oneHourReminder: const Duration(hours: 1),
  };

  static const _reminderDurationBuffer = Duration(minutes: 30);

  @override
  Future<String> action(EmailEventReminderRequest request) async {
    await firestore.runTransaction((transaction) async {
      final eventPath =
          'community/${request.communityId}/templates/${request.templateId}/events/${request.eventId}';
      final event = await firestoreUtils.getFirestoreObject(
        transaction: transaction,
        path: eventPath,
        constructor: (map) => Event.fromJson(map),
      );

      print('Attempting reminder email for $event');
      print('Current time: ${DateTime.now()}');
      final reminderOffset = emailReminderOffset[request.eventEmailType];

      if (reminderOffset == null) return;

      final timeUntilEvent = event.scheduledTime?.difference(DateTime.now());
      if (timeUntilEvent == null ||
          timeUntilEvent > (reminderOffset + _reminderDurationBuffer) ||
          timeUntilEvent < (reminderOffset - _reminderDurationBuffer)) {
        print('Time until event: $timeUntilEvent');
        print(
          'Event is not within $_reminderDurationBuffer notification window of $reminderOffset.',
        );
        return;
      }

      final community = await firestoreUtils.getFirestoreObject(
        path: 'community/${request.communityId}',
        constructor: (map) => Community.fromJson(map),
      );

      final suppressEmail = !(event.eventSettings?.reminderEmails ??
          community.eventSettingsMigration.reminderEmails ??
          true);
      if (suppressEmail) return;

      final participantsSnapshot =
          await firestore.collection('$eventPath/event-participants').get();
      final participants = participantsSnapshot.documents
          .map((doc) => Participant.fromJson(doc.data.toMap() ?? {}))
          .where(
            (participant) => participant.status == ParticipantStatus.active,
          )
          .toList();

      await eventEmailUtils.sendEmailsToUsers(
        transaction: transaction,
        event: event,
        eventPath: eventPath,
        userIds: participants.map((participant) => participant.id).toList(),
        emailType: request.eventEmailType!,
      );
    });

    return '';
  }
}
