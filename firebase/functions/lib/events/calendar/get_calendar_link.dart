import 'dart:async';

import 'package:firebase_functions_interop/firebase_functions_interop.dart';
import '../../on_call_function.dart';
import '../../utils/calendar_link_util.dart';
import '../../utils/infra/firebase_auth_utils.dart';
import '../../utils/infra/firestore_utils.dart';
import '../../utils/utils.dart';
import 'package:data_models/cloud_functions/requests.dart';
import 'package:data_models/events/event.dart';
import 'package:data_models/community/community.dart';

import '../../utils/template_utils.dart';

class GetCommunityCalendarLink
    extends OnCallMethod<GetCommunityCalendarLinkRequest> {
  GetCommunityCalendarLink()
      : super(
          GetCommunityCalendarLinkRequest.functionName,
          (jsonMap) => GetCommunityCalendarLinkRequest.fromJson(jsonMap),
        );

  @override
  Future<Map<String, dynamic>> action(
    GetCommunityCalendarLinkRequest request,
    CallableContext context,
  ) async {
    orElseUnauthorized(
      context.authUid != null,
      logMessage: 'Context auth ID was null',
    );

    final event = await firestoreUtils.getFirestoreObject(
      path: request.eventPath,
      constructor: (map) => Event.fromJson(map),
    );
    final users = await firebaseAuthUtils.getUsers([event.creatorId]);
    if (users.length != 1) {
      throw Exception('Organizer not found');
    }
    final organizer = users[0];
    final communitySnapshot =
        await firestore.document('community/${event.communityId}').get();
    final community = Community.fromJson(
      firestoreUtils.fromFirestoreJson(communitySnapshot.data.toMap()),
    );

    final templatePath =
        'community/${community.id}/templates/${event.templateId}';
    final templateDoc = await firestore.document(templatePath).get();
    final template = TemplateUtils.templateFromSnapshot(templateDoc);

    final googleCalendarLink = calendarLinkUtil.getGoogleLink(
      community: community,
      template: template,
      event: event,
    );

    final office365CalendarLink = calendarLinkUtil.getOffice365Link(
      community: community,
      template: template,
      event: event,
    );

    final outlookCalendarLink = calendarLinkUtil.getOutlookLink(
      community: community,
      template: template,
      event: event,
    );

    final icsLink = calendarLinkUtil.getICS(
      community: community,
      template: template,
      event: event,
      organizer: organizer,
    );
    return GetCommunityCalendarLinkResponse(
      googleCalendarLink: googleCalendarLink,
      office365CalendarLink: office365CalendarLink,
      outlookCalendarLink: outlookCalendarLink,
      icsLink: icsLink,
    ).toJson();
  }
}
