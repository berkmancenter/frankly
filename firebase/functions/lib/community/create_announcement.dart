import 'dart:async';

import 'package:firebase_admin_interop/firebase_admin_interop.dart';
import 'package:firebase_functions_interop/firebase_functions_interop.dart';
import '../on_call_function.dart';
import '../utils/email_templates.dart';
import '../utils/firestore_utils.dart';
import '../utils/notifications_utils.dart';
import 'package:data_models/cloud_functions/requests.dart';
import 'package:data_models/community/community_user_settings.dart';
import 'package:data_models/community/membership.dart';

class CreateAnnouncement extends OnCallMethod<CreateAnnouncementRequest> {
  NotificationsUtils notificationsUtils;

  CreateAnnouncement({NotificationsUtils? notificationsUtils})
      : notificationsUtils = notificationsUtils ?? NotificationsUtils(),
        super(
          'sendAnnouncement',
          (jsonMap) => CreateAnnouncementRequest.fromJson(jsonMap),
        );

  @override
  Future<void> action(
    CreateAnnouncementRequest request,
    CallableContext context,
  ) async {
    final communityMembershipDoc = await firestore
        .document(
          'memberships/${context.authUid}/community-membership/${request.communityId}',
        )
        .get();

    final membership = Membership.fromJson(
      firestoreUtils
          .fromFirestoreJson(communityMembershipDoc.data.toMap() ?? {}),
    );

    if (!membership.isAdmin) {
      throw HttpsError(HttpsError.failedPrecondition, 'unauthorized', null);
    }

    final docRef = firestore
        .collection('/community/${request.communityId}/announcements')
        .document();
    final docData = DocumentData.fromMap(
      firestoreUtils.toFirestoreJson(request.announcement!.toJson()),
    );

    await docRef.setData(docData);

    print('Sending notification');
    await notificationsUtils.sendCommunityNotifications(
      communityId: request.communityId,
      filterUsersBy: (settings) =>
          settings.notifyAnnouncements == NotificationEmailType.immediate ||
          settings.notifyAnnouncements == null,
      generateMessage: ({
        required community,
        required user,
        required unsubscribeUrl,
      }) =>
          SendGridEmailMessage(
        subject: 'New Announcement: ${request.announcement?.title}',
        html: makeNewAnnouncementBody(
          community: community,
          announcement: request.announcement,
          unsubscribeUrl: unsubscribeUrl,
        ),
      ),
    );
  }
}
