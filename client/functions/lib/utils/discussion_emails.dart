import 'package:firebase_admin_interop/firebase_admin_interop.dart'
    as admin_interop;
import 'package:firebase_functions_interop/firebase_functions_interop.dart';
import 'package:intl/intl.dart';
import 'package:junto_functions/functions/on_request/email_discussion_reminder.dart';
import 'package:junto_functions/utils/calendar_link_util.dart';
import 'package:junto_functions/utils/email_templates.dart';
import 'package:junto_functions/utils/firestore_utils.dart';
import 'package:junto_functions/utils/send_email_client.dart';
import 'package:junto_functions/utils/subscription_plan_util.dart';
import 'package:junto_functions/utils/timezone_utils.dart';
import 'package:junto_models/cloud_functions/requests.dart';
import 'package:junto_models/firestore/discussion.dart';
import 'package:junto_models/firestore/junto.dart';
import 'package:junto_models/firestore/topic.dart';
import 'package:timezone/standalone.dart' as tz;

final discussionEmails = DiscussionEmails();

class DiscussionEmails {
  Future<void> enqueueReminders(Discussion discussion) async {
    // Enqueue email reminders.
    final timeUntilDiscussion =
        discussion.scheduledTime?.difference(DateTime.now());
    print('time until discussion: $timeUntilDiscussion');
    if (timeUntilDiscussion == null) {
      print('No discussion time scheduled');
      return;
    }

    for (final offsetEntry
        in EmailDiscussionReminder.emailReminderOffset.entries) {
      final offset = offsetEntry.value;
      final emailType = offsetEntry.key;

      final doubleOffset = offset + offset;
      print('Comparing time until to $doubleOffset');
      // Only schedule the email if there is enough time between now and when
      // the email will be.
      final scheduledTime = discussion.scheduledTime;
      if (scheduledTime != null && timeUntilDiscussion > (offset + offset)) {
        print('Scheduling $emailType');
        await EmailDiscussionReminder().schedule(
          EmailDiscussionReminderRequest(
            juntoId: discussion.juntoId,
            topicId: discussion.topicId,
            discussionId: discussion.id,
            discussionEmailType: emailType,
          ),
          scheduledTime.subtract(offset),
        );
      }
    }
  }

  Future<void> sendEmailsToUsers({
    required String discussionPath,
    required DiscussionEmailType emailType,
    admin_interop.Transaction? transaction,
    Discussion? discussion,
    List<String>? userIds,
    String? sendId,
  }) async {
    Future<void> transactionRunner(admin_interop.Transaction transaction) =>
        _sendEmailsToUsersInTransaction(
          transaction: transaction,
          discussion: discussion,
          discussionPath: discussionPath,
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
    DiscussionEmailType emailType,
    String discussionTitle,
  ) {
    if (emailType == DiscussionEmailType.updated) {
      return 'Schedule Change for $discussionTitle';
    } else if (emailType == DiscussionEmailType.initialSignUp) {
      return 'Registration Confirmation for $discussionTitle';
    } else if (emailType == DiscussionEmailType.oneDayReminder) {
      return 'Starting in 1 day: $discussionTitle';
    } else if (emailType == DiscussionEmailType.oneHourReminder) {
      return 'Starting in 1 hour: $discussionTitle';
    } else if (emailType == DiscussionEmailType.canceled) {
      return 'Event Cancelled: $discussionTitle';
    }

    return discussionTitle;
  }

  Future<void> _sendEmailsToUsersInTransaction({
    required admin_interop.Transaction transaction,
    required String discussionPath,
    required DiscussionEmailType emailType,
    String? sendId,
    Discussion? discussion,
    List<Participant>? participants,
    List<String>? userIds,
  }) async {
    sendId ??= '';
    print('Sending $emailType with sendId: $sendId');
    print('Sending to users: $userIds');

    // Get discussion if it was not passed in
    final Discussion discussionLocal = discussion ??
        await firestoreUtils.getFirestoreObject(
          transaction: transaction,
          path: discussionPath,
          constructor: (map) => Discussion.fromJson(map),
        );

    if (participants == null) {
      final snapshots = await firestore
          .document(discussionPath)
          .collection('discussion-participants')
          .get();
      // ignore: parameter_assignments
      participants = snapshots.documents
          .map((doc) => Participant.fromJson(
              firestoreUtils.fromFirestoreJson(doc.data.toMap())))
          .toList();
    }

    if (discussionLocal.status == DiscussionStatus.canceled &&
        emailType != DiscussionEmailType.canceled) {
      print(
          'Not sending $emailType email for discussion that has been canceled.');
      return;
    }

    print('Sending email for discussion: ${discussionLocal.id}');
    var idsToEmail = participants
        .where((participant) => participant.status == ParticipantStatus.active)
        .map((participant) => participant.id)
        .toSet();
    if (userIds != null && userIds.isNotEmpty) {
      idsToEmail = idsToEmail.intersection(userIds.toSet());
    }

    final emailLogsCollection = firestore.collection(
        'junto/${discussionLocal.juntoId}/topics/${discussionLocal.topicId}/discussions/${discussionLocal.id}/email-logs');
    final emailLogsQuery = await emailLogsCollection.get();
    final emailLogs = emailLogsQuery.documents.map((d) =>
        DiscussionEmailLog.fromJson(
            firestoreUtils.fromFirestoreJson(d.data.toMap())));

    // Making sure we don't send more than one email. If email log already exists - we remove
    // user from the list of users whom email should be sent to.
    for (final log in emailLogs.where((logEntry) =>
        logEntry.discussionEmailType == emailType &&
        logEntry.sendId == sendId)) {
      idsToEmail.remove(log.userId);
    }

    var lookedUpUsers = await firestoreUtils.getUsers(idsToEmail.toList());
    print('Looked up users: ${lookedUpUsers.map((e) => e.uid).toList()}');
    if (lookedUpUsers.isEmpty) {
      print('No looked up users found.');
      return;
    }

    admin_interop.UserRecord? _organizer;
    final organizerLookup =
        await firestoreUtils.getUsers([discussionLocal.creatorId]);
    if (organizerLookup.isNotEmpty) {
      _organizer = organizerLookup[0];
    }

    final junto = await firestoreUtils.getFirestoreObject(
      transaction: transaction,
      path: 'junto/${discussionLocal.juntoId}',
      constructor: (map) => Junto.fromJson(map),
    );
    final topic = await firestoreUtils.getFirestoreObject(
      transaction: transaction,
      path:
          'junto/${discussionLocal.juntoId}/topics/${discussionLocal.topicId}',
      constructor: (map) => Topic.fromJson(map),
    );

    final capabilities = await subscriptionPlanUtil
        .calculateCapabilities(discussionLocal.juntoId);
    final hasPrePost = capabilities.hasPrePost ?? false;
    final noReplyEmailAddr =
        functions.config.get('app.no_reply_email') as String;

    // Send out emails
    for (final user in lookedUpUsers) {
      print('Sending $emailType email to user: ${user.uid}');
      await sendEmailClient.sendEmail(
        SendGridEmail(
          to: [user.email],
          from: '${junto.name} <$noReplyEmailAddr>',
          message: _getEmailContent(
            junto: junto,
            topic: topic,
            discussion: discussionLocal,
            participants: participants,
            emailType: emailType,
            userRecord: user,
            allowPrePost: hasPrePost,
            eventOrganizer: _organizer,
          ),
        ),
        transaction: transaction,
      );

      // Record that we already sent these reminders so we don't do it again
      transaction.set(
        emailLogsCollection.document(),
        admin_interop.DocumentData.fromMap(
            firestoreUtils.toFirestoreJson(DiscussionEmailLog(
          userId: user.uid,
          discussionEmailType: emailType,
          createdDate: DateTime.now(),
          sendId: sendId,
        ).toJson())),
      );
    }
  }

  SendGridEmailMessage _getEmailContent({
    required Junto junto,
    required Topic topic,
    required Discussion discussion,
    required List<Participant> participants,
    required DiscussionEmailType emailType,
    required admin_interop.UserRecord userRecord,
    required bool allowPrePost,
    admin_interop.UserRecord? eventOrganizer,
  }) {
    final prodUrl = functions.config.get('app.prod_full_url') as String;
    final devUrl = functions.config.get('app.dev_full_url') as String;
    final linkPrefix = isDev ? devUrl : prodUrl;
    final link =
        '$linkPrefix/space/${discussion.juntoId}/discuss/${discussion.topicId}/${discussion.id}';
    final juntoUrl = '$linkPrefix/space/${discussion.juntoId}';
    tz.Location scheduledLocation;
    try {
      scheduledLocation =
          timezoneUtils.getLocation(discussion.scheduledTimeZone ?? '');
    } catch (e) {
      print('Error getting scheduled location: $e. Using America/Los_Angeles');
      scheduledLocation = timezoneUtils.getLocation('America/Los_Angeles');
    }

    final localTime = timezoneUtils.fromDateTime(
        discussion.scheduledTime ?? DateTime.now(), scheduledLocation);

    final scheduledDate = DateFormat.yMMMMd().format(localTime);
    final scheduledTime = DateFormat.jm().format(localTime);

    final timeZoneAbbreviation = scheduledLocation.currentTimeZone.abbr;

    var participantsText = 'are ${participants.length} participants';
    if (participants.length == 1) {
      participantsText = 'is 1 participant';
    }

    var imgUrl = junto.profileImageUrl ?? '';
    if (imgUrl.contains('picsum')) {
      imgUrl = imgUrl.replaceAll('.webp', '.jpg');
    }

    final discussionTitle = discussion.title ?? topic.title ?? '';
    final discussionImage = discussion.image ?? topic.image;
    final calendarGoogleLink = calendarLinkUtil.getGoogleLink(
      junto: junto,
      topic: topic,
      discussion: discussion,
    );
    final calendarOffice365Link = calendarLinkUtil.getOffice365Link(
      junto: junto,
      topic: topic,
      discussion: discussion,
    );
    final calendarOutlookLink = calendarLinkUtil.getOutlookLink(
      junto: junto,
      topic: topic,
      discussion: discussion,
    );
    final calendarICS = calendarLinkUtil.getICS(
      junto: junto,
      topic: topic,
      discussion: discussion,
      organizer: eventOrganizer,
    );

    final actionTitles = {
      DiscussionEmailType.canceled: 'Event Cancelled',
      DiscussionEmailType.updated: 'Event Update',
      DiscussionEmailType.initialSignUp: 'Registration',
      DiscussionEmailType.oneDayReminder: 'Reminder',
      DiscussionEmailType.oneHourReminder: 'Reminder',
    };
    final actionTitle = actionTitles[emailType] ?? 'Event Update';

    final headers = {
      DiscussionEmailType.canceled: 'Your event has been CANCELLED.',
      DiscussionEmailType.updated: 'Your event has been CHANGED.',
      DiscussionEmailType.initialSignUp:
          'You are registered for an upcoming conversation!',
      DiscussionEmailType.oneDayReminder:
          'You are registered for an upcoming conversation!',
      DiscussionEmailType.oneHourReminder:
          'Your conversation is beginning in one hour!',
    };
    final header = headers[emailType] ?? '';

    final content = generateEmailDiscussionInfo(
      actionTitle: actionTitle,
      cancellation: emailType == DiscussionEmailType.canceled,
      discussionTitle: discussionTitle,
      discussionImage: discussionImage,
      discussionDateDisplay:
          '$scheduledDate at $scheduledTime $timeZoneAbbreviation',
      bannerImgUrl: imgUrl,
      juntoId: junto.id,
      juntoName: junto.name,
      cancelUrl: '$link?cancel=true',
      detailsUrl: '$link?uid=${userRecord.uid}',
      juntoUrl: juntoUrl,
      participantsText: participantsText,
      header: header,
      calendarGoogleLink: calendarGoogleLink,
      calendarOffice365Link: calendarOffice365Link,
      calendarOutlookLink: calendarOutlookLink,
      discussion: discussion,
      userRecord: userRecord,
      allowPrePost: allowPrePost,
    );

    return SendGridEmailMessage(
        subject: _getEmailSubject(emailType, discussionTitle),
        html: content,
        attachments: [
          EmailAttachment(
            filename: 'invite.ics',
            content: calendarICS,
            contentType: 'text/calendar',
          )
        ]);
  }
}
