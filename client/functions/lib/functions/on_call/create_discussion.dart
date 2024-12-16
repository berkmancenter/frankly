import 'dart:async';

import 'package:firebase_functions_interop/firebase_functions_interop.dart';
import 'package:junto_functions/functions/on_call/check_hostless_go_to_breakouts.dart';
import 'package:junto_functions/functions/on_call_function.dart';
import 'package:junto_functions/utils/discussion_emails.dart';
import 'package:junto_functions/utils/emulator_utils.dart';
import 'package:junto_functions/utils/firestore_utils.dart';
import 'package:junto_models/cloud_functions/requests.dart';
import 'package:junto_models/firestore/discussion.dart';
import 'package:junto_models/firestore/membership.dart';

/// This function handles events after discussion creation
class CreateDiscussion extends OnCallMethod<CreateDiscussionRequest> {
  CreateDiscussion()
      : super(
          CreateDiscussionRequest.functionName,
          (jsonMap) => CreateDiscussionRequest.fromJson(jsonMap),
        );

  @override
  Future<void> action(CreateDiscussionRequest request, CallableContext context) async {
    final discussion = await firestoreUtils.getFirestoreObject(
      path: request.discussionPath,
      constructor: (map) => Discussion.fromJson(map),
    );

    final membershipDoc = await firestore
        .document('memberships/${context?.authUid}/junto-membership/${discussion.juntoId}')
        .get();
    final membership = Membership.fromJson(firestoreUtils.fromFirestoreJson(membershipDoc.data?.toMap() ?? {}));
    final isModOrCreator = discussion.creatorId == context?.authUid || membership.isMod;

    if (!isEmulator && !isModOrCreator) {
      throw HttpsError(HttpsError.failedPrecondition, 'unauthorized', null);
    }

    await _handleEmailNotifications(discussion);

    if (discussion.discussionType == DiscussionType.hostless) {
      await CheckHostlessGoToBreakouts().enqueueScheduledCheck(discussion);
    }
  }

  Future<void> _handleEmailNotifications(Discussion discussion) async {
    // Send initial sign up email to user.
    await discussionEmails.sendEmailsToUsers(
      discussionPath: discussion.fullPath,
      userIds: [discussion.creatorId],
      emailType: DiscussionEmailType.initialSignUp,
    );

    await discussionEmails.enqueueReminders(discussion);
  }
}
