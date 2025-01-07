import 'package:firebase_admin_interop/firebase_admin_interop.dart'
    as admin_interop;
import 'package:firebase_functions_interop/firebase_functions_interop.dart';
import 'package:intl/intl.dart';
import 'email_event_reminder.dart';
import '../../utils/calendar_link_util.dart';
import '../../utils/email_templates.dart';
import '../../utils/infra/firestore_utils.dart';
import '../../utils/send_email_client.dart';
import '../../utils/subscription_plan_util.dart';
import '../../utils/timezone_utils.dart';
import 'package:data_models/cloud_functions/requests.dart';
import 'package:data_models/events/event.dart';
import 'package:data_models/community/community.dart';
import 'package:data_models/templates/template.dart';

import 'package:timezone/standalone.dart' as tz;

class EventEmails {
  Future<void> enqueueReminders(Event event) async {
    // Enqueue email reminders.
    final timeUntilEvent = event.scheduledTime?.difference(DateTime.now());
    print('time until event: $timeUntilEvent');
    if (timeUntilEvent == null) {
      print('No event time scheduled');
      return;
    }

    for (final offsetEntry in EmailEventReminder.emailReminderOffset.entries) {
      final offset = offsetEntry.value;
      final emailType = offsetEntry.key;

      final doubleOffset = offset + offset;
      print('Comparing time until to $doubleOffset');
      // Only schedule the email if there is enough time between now and when
      // the email will be.
      final scheduledTime = event.scheduledTime;
      if (scheduledTime != null && timeUntilEvent > (offset + offset)) {
        print('Scheduling $emailType');
        await EmailEventReminder().schedule(
          EmailEventReminderRequest(
            communityId: event.communityId,
            templateId: event.templateId,
            eventId: event.id,
            eventEmailType: emailType,
          ),
          scheduledTime.subtract(offset),
        );
      }
    }
  }

  Future<void> sendEmailsToUsers({
    required String eventPath,
    required EventEmailType emailType,
    admin_interop.Transaction? transaction,
    Event? event,
    List<String>? userIds,
    String? sendId,
  }) async {
    Future<void> transactionRunner(admin_interop.Transaction transaction) =>
        _sendEmailsToUsersInTransaction(
          transaction: transaction,
          event: event,
          eventPath: eventPath,
          userIds: userIds,
          emailType: emailType,
          sendId: sendId,
        );
    if (transaction == null) {
      await firestore.runTransaction(transactionRunner);
    } else {
      await transactionRunner(transaction);
    }
  }

  String _getEmailSubject(
    EventEmailType emailType,
    String eventTitle,
  ) {
    if (emailType == EventEmailType.updated) {
      return 'Schedule Change for $eventTitle';
    } else if (emailType == EventEmailType.initialSignUp) {
      return 'Registration Confirmation for $eventTitle';
    } else if (emailType == EventEmailType.oneDayReminder) {
      return 'Starting in 1 day: $eventTitle';
    } else if (emailType == EventEmailType.oneHourReminder) {
      return 'Starting in 1 hour: $eventTitle';
    } else if (emailType == EventEmailType.canceled) {
      return 'Event Cancelled: $eventTitle';
    }

    return eventTitle;
  }

  Future<void> _sendEmailsToUsersInTransaction({
    required admin_interop.Transaction transaction,
    required String eventPath,
    required EventEmailType emailType,
    String? sendId,
    Event? event,
    List<Participant>? participants,
    List<String>? userIds,
  }) async {
    sendId ??= '';
    print('Sending $emailType with sendId: $sendId');
    print('Sending to users: $userIds');

    // Get event if it was not passed in
    final Event eventLocal = event ??
        await firestoreUtils.getFirestoreObject(
          transaction: transaction,
          path: eventPath,
          constructor: (map) => Event.fromJson(map),
        );

    if (participants == null) {
      final snapshots = await firestore
          .document(eventPath)
          .collection('event-participants')
          .get();
      // ignore: parameter_assignments
      participants = snapshots.documents
          .map(
            (doc) => Participant.fromJson(
              firestoreUtils.fromFirestoreJson(doc.data.toMap()),
            ),
          )
          .toList();
    }

    if (eventLocal.status == EventStatus.canceled &&
        emailType != EventEmailType.canceled) {
      print(
        'Not sending $emailType email for event that has been canceled.',
      );
      return;
    }

    print('Sending email for event: ${eventLocal.id}');
    var idsToEmail = participants
        .where((participant) => participant.status == ParticipantStatus.active)
        .map((participant) => participant.id)
        .toSet();
    if (userIds != null && userIds.isNotEmpty) {
      idsToEmail = idsToEmail.intersection(userIds.toSet());
    }

    final emailLogsCollection = firestore.collection(
      'community/${eventLocal.communityId}/templates/${eventLocal.templateId}/events/${eventLocal.id}/email-logs',
    );
    final emailLogsQuery = await emailLogsCollection.get();
    final emailLogs = emailLogsQuery.documents.map(
      (d) => EventEmailLog.fromJson(
        firestoreUtils.fromFirestoreJson(d.data.toMap()),
      ),
    );

    // Making sure we don't send more than one email. If email log already exists - we remove
    // user from the list of users whom email should be sent to.
    for (final log in emailLogs.where(
      (logEntry) =>
          logEntry.eventEmailType == emailType && logEntry.sendId == sendId,
    )) {
      idsToEmail.remove(log.userId);
    }

    var lookedUpUsers = await firestoreUtils.getUsers(idsToEmail.toList());
    print('Looked up users: ${lookedUpUsers.map((e) => e.uid).toList()}');
    if (lookedUpUsers.isEmpty) {
      print('No looked up users found.');
      return;
    }

    admin_interop.UserRecord? organizer;
    final organizerLookup =
        await firestoreUtils.getUsers([eventLocal.creatorId]);
    if (organizerLookup.isNotEmpty) {
      organizer = organizerLookup[0];
    }

    final community = await firestoreUtils.getFirestoreObject(
      transaction: transaction,
      path: 'community/${eventLocal.communityId}',
      constructor: (map) => Community.fromJson(map),
    );
    final template = await firestoreUtils.getFirestoreObject(
      transaction: transaction,
      path:
          'community/${eventLocal.communityId}/templates/${eventLocal.templateId}',
      constructor: (map) => Template.fromJson(map),
    );

    final capabilities = await subscriptionPlanUtil
        .calculateCapabilities(eventLocal.communityId);
    final hasPrePost = capabilities.hasPrePost ?? false;
    final noReplyEmailAddr =
        functions.config.get('app.no_reply_email') as String;

    // Send out emails
    for (final user in lookedUpUsers) {
      print('Sending $emailType email to user: ${user.uid}');
      await sendEmailClient.sendEmail(
        SendGridEmail(
          to: [user.email],
          from: '${community.name} <$noReplyEmailAddr>',
          message: _getEmailContent(
            community: community,
            template: template,
            event: eventLocal,
            participants: participants,
            emailType: emailType,
            userRecord: user,
            allowPrePost: hasPrePost,
            eventOrganizer: organizer,
          ),
        ),
        transaction: transaction,
      );

      // Record that we already sent these reminders so we don't do it again
      transaction.set(
        emailLogsCollection.document(),
        admin_interop.DocumentData.fromMap(
          firestoreUtils.toFirestoreJson(
            EventEmailLog(
              userId: user.uid,
              eventEmailType: emailType,
              createdDate: DateTime.now(),
              sendId: sendId,
            ).toJson(),
          ),
        ),
      );
    }
  }

  SendGridEmailMessage _getEmailContent({
    required Community community,
    required Template template,
    required Event event,
    required List<Participant> participants,
    required EventEmailType emailType,
    required admin_interop.UserRecord userRecord,
    required bool allowPrePost,
    admin_interop.UserRecord? eventOrganizer,
  }) {
    final linkPrefix = functions.config.get('app.full_url') as String;
    final link =
        '$linkPrefix/space/${event.communityId}/discuss/${event.templateId}/${event.id}';
    final communityUrl = '$linkPrefix/space/${event.communityId}';
    tz.Location scheduledLocation;
    try {
      scheduledLocation =
          timezoneUtils.getLocation(event.scheduledTimeZone ?? '');
    } catch (e) {
      print('Error getting scheduled location: $e. Using America/Los_Angeles');
      scheduledLocation = timezoneUtils.getLocation('America/Los_Angeles');
    }

    final localTime = timezoneUtils.fromDateTime(
      event.scheduledTime ?? DateTime.now(),
      scheduledLocation,
    );

    final scheduledDate = DateFormat.yMMMMd().format(localTime);
    final scheduledTime = DateFormat.jm().format(localTime);

    final timeZoneAbbreviation = scheduledLocation.currentTimeZone.abbr;

    var participantsText = 'are ${participants.length} participants';
    if (participants.length == 1) {
      participantsText = 'is 1 participant';
    }

    var imgUrl = community.profileImageUrl ?? '';
    if (imgUrl.contains('picsum')) {
      imgUrl = imgUrl.replaceAll('.webp', '.jpg');
    }

    final eventTitle = event.title ?? template.title ?? '';
    final eventImage = event.image ?? template.image;
    final calendarGoogleLink = calendarLinkUtil.getGoogleLink(
      community: community,
      template: template,
      event: event,
    );
    final calendarOffice365Link = calendarLinkUtil.getOffice365Link(
      community: community,
      template: template,
      event: event,
    );
    final calendarOutlookLink = calendarLinkUtil.getOutlookLink(
      community: community,
      template: template,
      event: event,
    );
    final calendarICS = calendarLinkUtil.getICS(
      community: community,
      template: template,
      event: event,
      organizer: eventOrganizer,
    );

    final actionTitles = {
      EventEmailType.canceled: 'Event Cancelled',
      EventEmailType.updated: 'Event Update',
      EventEmailType.initialSignUp: 'Registration',
      EventEmailType.oneDayReminder: 'Reminder',
      EventEmailType.oneHourReminder: 'Reminder',
    };
    final actionTitle = actionTitles[emailType] ?? 'Event Update';

    final headers = {
      EventEmailType.canceled: 'Your event has been CANCELLED.',
      EventEmailType.updated: 'Your event has been CHANGED.',
      EventEmailType.initialSignUp: 'You are registered for an upcoming event!',
      EventEmailType.oneDayReminder:
          'You are registered for an upcoming event!',
      EventEmailType.oneHourReminder: 'Your event is beginning in one hour!',
    };
    final header = headers[emailType] ?? '';

    final content = generateEmailEventInfo(
      actionTitle: actionTitle,
      cancellation: emailType == EventEmailType.canceled,
      eventTitle: eventTitle,
      eventImage: eventImage,
      eventDateDisplay:
          '$scheduledDate at $scheduledTime $timeZoneAbbreviation',
      bannerImgUrl: imgUrl,
      communityId: community.id,
      communityName: community.name,
      cancelUrl: '$link?cancel=true',
      detailsUrl: '$link?uid=${userRecord.uid}',
      communityUrl: communityUrl,
      participantsText: participantsText,
      header: header,
      calendarGoogleLink: calendarGoogleLink,
      calendarOffice365Link: calendarOffice365Link,
      calendarOutlookLink: calendarOutlookLink,
      event: event,
      userRecord: userRecord,
      allowPrePost: allowPrePost,
    );

    return SendGridEmailMessage(
      subject: _getEmailSubject(emailType, eventTitle),
      html: content,
      attachments: [
        EmailAttachment(
          filename: 'invite.ics',
          content: calendarICS,
          contentType: 'text/calendar',
        ),
      ],
    );
  }
}
