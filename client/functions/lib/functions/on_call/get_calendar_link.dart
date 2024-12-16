import 'dart:async';

import 'package:firebase_functions_interop/firebase_functions_interop.dart';
import 'package:junto_functions/functions/on_call_function.dart';
import 'package:junto_functions/utils/calendar_link_util.dart';
import 'package:junto_functions/utils/firestore_utils.dart';
import 'package:junto_functions/utils/utils.dart';
import 'package:junto_models/cloud_functions/requests.dart';
import 'package:junto_models/firestore/discussion.dart';
import 'package:junto_models/firestore/junto.dart';

import '../../utils/topic_utils.dart';

class GetJuntoCalendarLink extends OnCallMethod<GetJuntoCalendarLinkRequest> {
  GetJuntoCalendarLink()
      : super(
          GetJuntoCalendarLinkRequest.functionName,
          (jsonMap) => GetJuntoCalendarLinkRequest.fromJson(jsonMap),
        );

  @override
  Future<Map<String, dynamic>> action(
      GetJuntoCalendarLinkRequest request, CallableContext context) async {
    orElseUnauthorized(context?.authUid != null, logMessage: 'Context auth ID was null');

    final discussion = await firestoreUtils.getFirestoreObject(
      path: request.discussionPath,
      constructor: (map) => Discussion.fromJson(map),
    );
    final users = await firestoreUtils.getUsers([discussion.creatorId]);
    if (users.length != 1) {
      throw Exception('Organizer not found');
    }
    final organizer = users[0];
    final juntoSnapshot = await firestore.document('junto/${discussion.juntoId}').get();
    final junto =
        Junto.fromJson(firestoreUtils.fromFirestoreJson(juntoSnapshot.data?.toMap() ?? {}));

    final topicPath = 'junto/${junto.id}/topics/${discussion.topicId}';
    final topicDoc = await firestore.document(topicPath).get();
    final topic = TopicUtils.topicFromSnapshot(topicDoc);

    final googleCalendarLink = calendarLinkUtil.getGoogleLink(
      junto: junto,
      topic: topic,
      discussion: discussion,
    );

    final office365CalendarLink = calendarLinkUtil.getOffice365Link(
      junto: junto,
      topic: topic,
      discussion: discussion,
    );

    final outlookCalendarLink = calendarLinkUtil.getOutlookLink(
      junto: junto,
      topic: topic,
      discussion: discussion,
    );

    final icsLink = calendarLinkUtil.getICS(
      junto: junto,
      topic: topic,
      discussion: discussion,
      organizer: organizer,
    );
    return GetJuntoCalendarLinkResponse(
      googleCalendarLink: googleCalendarLink,
      office365CalendarLink: office365CalendarLink,
      outlookCalendarLink: outlookCalendarLink,
      icsLink: icsLink,
    ).toJson();
  }
}
