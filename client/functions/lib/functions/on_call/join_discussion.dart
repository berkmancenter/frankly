import 'dart:async';

import 'package:firebase_functions_interop/firebase_functions_interop.dart';
import 'package:junto_functions/functions/on_call_function.dart';
import 'package:junto_functions/utils/discussion_emails.dart';
import 'package:junto_functions/utils/firestore_utils.dart';
import 'package:junto_models/firestore/discussion.dart';
import 'package:junto_models/firestore/junto.dart';

/// This function handles events after discussion creation
class JoinDiscussion extends OnCallMethod<Discussion> {
  JoinDiscussion() : super('joinDiscussion', (jsonMap) => Discussion.fromJson(jsonMap));

  @override
  Future<void> action(Discussion request, CallableContext context) async {
    final participant = await firestoreUtils.getFirestoreObject(
      path: '${request.collectionPath}/${request.id}/discussion-participants/${context?.authUid}',
      constructor: (map) => Participant.fromJson(map),
    );

    final junto = await firestoreUtils.getFirestoreObject(
      path: 'junto/${request.juntoId}',
      constructor: (map) => Junto.fromJson(map),
    );

    final suppressEmail = !(request.discussionSettings?.reminderEmails ??
        junto.discussionSettingsMigration.reminderEmails ??
        true);
    if (participant.status == ParticipantStatus.active && !suppressEmail) {
      // Send initial sign up email to user.
      await discussionEmails.sendEmailsToUsers(
        discussionPath:
            'junto/${request.juntoId}/topics/${request.topicId}/discussions/${request.id}',
        userIds: [context!.authUid!],
        emailType: DiscussionEmailType.initialSignUp,
      );
    }
  }
}
