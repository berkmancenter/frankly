import 'dart:async';

import 'package:firebase_admin_interop/firebase_admin_interop.dart';
import 'package:firebase_functions_interop/firebase_functions_interop.dart'
    as functions_interop;
import '../../on_call_function.dart';
import '../../utils/email_templates.dart';
import '../../utils/infra/firestore_utils.dart';
import '../../utils/notifications_utils.dart';
import '../../utils/utils.dart';
import 'package:data_models/cloud_functions/requests.dart';
import 'package:data_models/events/event.dart';


import '../../utils/template_utils.dart';

class SendEventMessage extends OnCallMethod<SendEventMessageRequest> {
  static const String kSendEventMessageApi = 'sendEventMessage';
  NotificationsUtils notificationsUtils;

  SendEventMessage({NotificationsUtils? notificationsUtils})
      : notificationsUtils = notificationsUtils ?? NotificationsUtils(),
        super(
          kSendEventMessageApi,
          (jsonMap) => SendEventMessageRequest.fromJson(jsonMap),
        );

  @override
  Future<void> action(
    SendEventMessageRequest request,
    functions_interop.CallableContext context,
  ) async {
    orElseUnauthorized(context.authUid != null);

    final documentData = DocumentData.fromMap(
      firestoreUtils.toFirestoreJson(request.eventMessage.toJson()),
    );

    final createdAtMillis = request.eventMessage.createdAtMillis ??
        DateTime.now().millisecondsSinceEpoch;
    final createdAtTimestamp = Timestamp.fromDateTime(
      DateTime.fromMillisecondsSinceEpoch(createdAtMillis),
    );

    documentData.setTimestamp('createdAt', createdAtTimestamp);

    print('Adding data: ${documentData.toMap()}');

    // First of all - add a new event message to the firestore
    await firestore
        .collection('community')
        .document(request.communityId)
        .collection('templates')
        .document(request.templateId)
        .collection('events')
        .document(request.eventId)
        .collection('event-messages')
        .add(documentData);

    // Then get template and event in one go, to make it faster
    final eventDocFuture = firestore
        .collection('community')
        .document(request.communityId)
        .collection('templates')
        .document(request.templateId)
        .collection('events')
        .document(request.eventId)
        .get();
    final templateDocFuture = firestore
        .collection('community')
        .document(request.communityId)
        .collection('templates')
        .document(request.templateId)
        .get();

    final List<DocumentSnapshot> futures = await Future.wait<DocumentSnapshot>([
      templateDocFuture,
      eventDocFuture,
    ]);

    // Parse it after both futures completed
    final template = TemplateUtils.templateFromSnapshot(futures[0]);
    final event = Event.fromJson(
      firestoreUtils.fromFirestoreJson(futures[1].data.toMap()),
    );

    await notificationsUtils.sendEmailToEventParticipants(
      communityId: request.communityId,
      template: template,
      event: event,
      generateMessage: ({
        required community,
        required user,
        required unsubscribeUrl,
      }) {
        return SendGridEmailMessage(
          subject: 'New Message in Event ${event.title}',
          html: makeNewEventMessageBody(
            community: community,
            template: template,
            event: event,
            eventMessage: request.eventMessage,
            unsubscribeUrl: unsubscribeUrl,
          ),
        );
      },
    );
  }
}
