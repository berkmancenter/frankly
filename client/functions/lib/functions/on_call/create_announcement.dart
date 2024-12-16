import 'dart:async';

import 'package:firebase_admin_interop/firebase_admin_interop.dart';
import 'package:firebase_functions_interop/firebase_functions_interop.dart';
import 'package:junto_functions/functions/on_call_function.dart';
import 'package:junto_functions/utils/email_templates.dart';
import 'package:junto_functions/utils/firestore_utils.dart';
import 'package:junto_functions/utils/notifications_utils.dart';
import 'package:junto_models/cloud_functions/requests.dart';
import 'package:junto_models/firestore/junto_user_settings.dart';
import 'package:junto_models/firestore/membership.dart';

class CreateAnnouncement extends OnCallMethod<CreateAnnouncementRequest> {
  CreateAnnouncement()
      : super(
          'sendAnnouncement',
          (jsonMap) => CreateAnnouncementRequest.fromJson(jsonMap),
        );

  @override
  Future<void> action(CreateAnnouncementRequest request, CallableContext context) async {
    final juntoMembershipDoc = await firestore
        .document('memberships/${context?.authUid}/junto-membership/${request.juntoId}')
        .get();

    final membership = Membership.fromJson(firestoreUtils.fromFirestoreJson(juntoMembershipDoc.data?.toMap() ?? {}));

    if (!membership.isAdmin) {
      throw HttpsError(HttpsError.failedPrecondition, 'unauthorized', null);
    }

    final docRef = firestore.collection('/junto/${request.juntoId}/announcements').document();
    final docData = DocumentData.fromMap(firestoreUtils.toFirestoreJson(request.announcement!.toJson()));

    await docRef.setData(docData);

    print('Sending notification');
    await notificationsUtils.sendJuntoNotifications(
        juntoId: request.juntoId,
        filterUsersBy: (settings) =>
            settings.notifyAnnouncements == NotificationEmailType.immediate ||
            settings.notifyAnnouncements == null,
        generateMessage: ({required junto, required user, required unsubscribeUrl}) =>
            SendGridEmailMessage(
              subject: 'New Announcement: ${request.announcement?.title}',
              html: makeNewAnnouncementBody(
                junto: junto,
                announcement: request.announcement,
                unsubscribeUrl: unsubscribeUrl,
              ),
            ));
  }
}
