import 'dart:async';

import 'package:firebase_admin_interop/firebase_admin_interop.dart' as admin_interop;
import 'package:firebase_functions_interop/firebase_functions_interop.dart';
import 'package:junto_functions/functions/on_call_function.dart';
import 'package:junto_functions/utils/email_templates.dart';
import 'package:junto_functions/utils/firestore_utils.dart';
import 'package:junto_functions/utils/notifications_utils.dart';
import 'package:junto_functions/utils/subscription_plan_util.dart';
import 'package:junto_models/cloud_functions/requests.dart';
import 'package:junto_models/firestore/discussion.dart';
import 'package:junto_models/firestore/junto.dart';

/// This function handles events after discussion ends
class DiscussionEnded extends OnCallMethod<DiscussionEndedRequest> {
  static const String kDiscussionEndedApi = 'discussionEnded';

  DiscussionEnded()
      : super(
          kDiscussionEndedApi,
          (jsonMap) => DiscussionEndedRequest.fromJson(jsonMap),
        );

  @override
  Future<void> action(DiscussionEndedRequest request, CallableContext context) async {
    final participant = await firestoreUtils.getFirestoreObject(
      path: '${request.discussionPath}/discussion-participants/${context?.authUid}',
      constructor: (map) => Participant.fromJson(map),
    );

    // Check that user is an active participant
    if (participant.status != ParticipantStatus.active) {
      throw HttpsError(HttpsError.failedPrecondition, 'unauthorized', null);
    }

    final discussion = await firestoreUtils.getFirestoreObject(
      path: request.discussionPath,
      constructor: (map) => Discussion.fromJson(map),
    );

    final capabilities = await subscriptionPlanUtil.calculateCapabilities(discussion.juntoId);
    final hasPrePost = capabilities.hasPrePost ?? false;

    await notificationsUtils.sendDiscussionEndedEmail(
      discussion: discussion,
      juntoId: discussion.juntoId,
      userIds: [context!.authUid!],
      emailType: DiscussionEmailType.ended,
      generateMessage: (Junto junto, admin_interop.UserRecord user) => SendGridEmailMessage(
        subject: 'Thanks for joining',
        html: generateDiscussionEndedContent(
          header: 'Thanks for joining ${discussion.title}!',
          junto: junto,
          userRecord: user,
          discussion: discussion,
          allowPrePost: hasPrePost,
        ),
      ),
    );
  }
}
