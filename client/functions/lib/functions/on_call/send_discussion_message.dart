import 'dart:async';

import 'package:firebase_admin_interop/firebase_admin_interop.dart';
import 'package:firebase_functions_interop/firebase_functions_interop.dart' as functions_interop;
import 'package:junto_functions/functions/on_call_function.dart';
import 'package:junto_functions/utils/email_templates.dart';
import 'package:junto_functions/utils/firestore_utils.dart';
import 'package:junto_functions/utils/notifications_utils.dart';
import 'package:junto_functions/utils/utils.dart';
import 'package:junto_models/cloud_functions/requests.dart';
import 'package:junto_models/firestore/discussion.dart';

import '../../utils/topic_utils.dart';

class SendDiscussionMessage extends OnCallMethod<SendDiscussionMessageRequest> {
  static const String kSendDiscussionMessageApi = 'sendDiscussionMessage';

  SendDiscussionMessage()
      : super(
          kSendDiscussionMessageApi,
          (jsonMap) => SendDiscussionMessageRequest.fromJson(jsonMap),
        );

  @override
  Future<void> action(SendDiscussionMessageRequest request, functions_interop.CallableContext context) async {
    orElseUnauthorized(context?.authUid != null);

    final documentData = DocumentData.fromMap(firestoreUtils.toFirestoreJson(request.discussionMessage.toJson()));

    final createdAtMillis =
        request.discussionMessage.createdAtMillis ?? DateTime.now().millisecondsSinceEpoch;
    final createdAtTimestamp =
        Timestamp.fromDateTime(DateTime.fromMillisecondsSinceEpoch(createdAtMillis));

    documentData.setTimestamp('createdAt', createdAtTimestamp);

    print('Adding data: ${documentData.toMap()}');

    // First of all - add a new discussion message to the firestore
    await firestore
        .collection('junto')
        .document(request.juntoId)
        .collection('topics')
        .document(request.topicId)
        .collection('discussions')
        .document(request.discussionId)
        .collection('discussion-messages')
        .add(documentData);

    // Then get topic and discussion in one go, to make it faster
    final discussionDocFuture = firestore
        .collection('junto')
        .document(request.juntoId)
        .collection('topics')
        .document(request.topicId)
        .collection('discussions')
        .document(request.discussionId)
        .get();
    final topicDocFuture = firestore
        .collection('junto')
        .document(request.juntoId)
        .collection('topics')
        .document(request.topicId)
        .get();

    final List<DocumentSnapshot> futures = await Future.wait<DocumentSnapshot>([
      topicDocFuture,
      discussionDocFuture,
    ]);

    // Parse it after both futures completed
    final topic = TopicUtils.topicFromSnapshot(futures[0]);
    final discussion = Discussion.fromJson(firestoreUtils.fromFirestoreJson(futures[1].data.toMap()));

    await notificationsUtils.sendEmailToDiscussionParticipants(
      juntoId: request.juntoId,
      topic: topic,
      discussion: discussion,
      generateMessage: ({
        required junto,
        required user,
        required unsubscribeUrl,
      }) {
        return SendGridEmailMessage(
            subject: 'New Message in Discussion ${discussion.title}',
            html: makeNewDiscussionMessageBody(
              junto: junto,
              topic: topic,
              discussion: discussion,
              discussionMessage: request.discussionMessage,
              unsubscribeUrl: unsubscribeUrl,
            ));
      },
    );
  }
}
