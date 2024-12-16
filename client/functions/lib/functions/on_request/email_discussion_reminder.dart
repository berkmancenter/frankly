import 'dart:async';

import 'package:junto_functions/functions/on_request_method.dart';
import 'package:junto_functions/utils/discussion_emails.dart';
import 'package:junto_functions/utils/firestore_utils.dart';
import 'package:junto_models/cloud_functions/requests.dart';
import 'package:junto_models/firestore/discussion.dart';
import 'package:junto_models/firestore/junto.dart';

/// This request method is called from our scheduled task queue.
///
/// It checks to see if this type of discussion email has been sent to this user
/// before and if not, sends the email.
class EmailDiscussionReminder extends OnRequestMethod<EmailDiscussionReminderRequest> {
  EmailDiscussionReminder()
      : super('EmailDiscussionReminder',
            (jsonMap) => EmailDiscussionReminderRequest.fromJson(jsonMap));

  static final emailReminderOffset = <DiscussionEmailType, Duration>{
    DiscussionEmailType.oneDayReminder: const Duration(days: 1),
    DiscussionEmailType.oneHourReminder: const Duration(hours: 1),
  };

  static const _reminderDurationBuffer = Duration(minutes: 30);

  @override
  Future<String> action(EmailDiscussionReminderRequest request) async {
    await firestore.runTransaction((transaction) async {
      final discussionPath =
          'junto/${request.juntoId}/topics/${request.topicId}/discussions/${request.discussionId}';
      final discussion = await firestoreUtils.getFirestoreObject(
        transaction: transaction,
        path: discussionPath,
        constructor: (map) => Discussion.fromJson(map),
      );

      print('Attempting reminder email for $discussion');
      print('Current time: ${DateTime.now()}');
      final reminderOffset = emailReminderOffset[request.discussionEmailType];

      if (reminderOffset == null) return;

      final timeUntilDiscussion = discussion.scheduledTime?.difference(DateTime.now());
      if (timeUntilDiscussion == null ||
          timeUntilDiscussion > (reminderOffset + _reminderDurationBuffer) ||
          timeUntilDiscussion < (reminderOffset - _reminderDurationBuffer)) {
        print('Time until discussion: $timeUntilDiscussion');
        print(
            'Discussion is not within $_reminderDurationBuffer notification window of $reminderOffset.');
        return;
      }

      final junto = await firestoreUtils.getFirestoreObject(
        path: 'junto/${request.juntoId}',
        constructor: (map) => Junto.fromJson(map),
      );

      final suppressEmail = !(discussion.discussionSettings?.reminderEmails ??
          junto.discussionSettingsMigration.reminderEmails ??
          true);
      if (suppressEmail) return;

      final participantsSnapshot =
          await firestore.collection('$discussionPath/discussion-participants').get();
      final participants = participantsSnapshot.documents
          .map((doc) => Participant.fromJson(doc.data?.toMap() ?? {}))
          .where((participant) => participant.status == ParticipantStatus.active)
          .toList();

      await discussionEmails.sendEmailsToUsers(
        transaction: transaction,
        discussion: discussion,
        discussionPath: discussionPath,
        userIds: participants.map((participant) => participant.id).toList(),
        emailType: request.discussionEmailType!,
      );
    });

    return '';
  }
}
