import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:client/services/firestore/firestore_utils.dart';
import 'package:client/services/services.dart';
import 'package:data_models/cloud_functions/requests.dart';
import 'package:data_models/announcements/announcement.dart';
import 'package:data_models/utils/utils.dart';

class FirestoreAnnouncementsService {
  static const announcements = 'announcements';

  CollectionReference<Map<String, dynamic>> _communityAnnouncementsCollection({
    required String communityId,
  }) {
    return firestoreDatabase
        .communityRef(communityId)
        .collection(announcements);
  }

  BehaviorSubjectWrapper<List<Announcement>> communityAnnouncements({
    required String communityId,
  }) {
    return wrapInBehaviorSubject(
      _communityAnnouncementsCollection(
        communityId: communityId,
      )
          .orderBy('createdDate', descending: true)
          .snapshots()
          .map((s) => s.docs)
          .asyncMap(_convertAnnouncementListAsync)
          .map(
            (announcements) => announcements
                .where(
                  (a) => a.announcementStatus != AnnouncementStatus.removed,
                )
                .toList(),
          ),
    );
  }

  Future<void> createAnnouncement({
    required String communityId,
    required String title,
    required String message,
    required bool emailToMembers,
  }) async {
    return cloudFunctionsService.createAnnouncement(
      CreateAnnouncementRequest(
        communityId: communityId,
        announcement: Announcement(
          announcementStatus: AnnouncementStatus.active,
          creatorId: userService.currentUserId,
          title: title,
          message: message,
        ),
      ),
    );
  }

  Future<void> deleteAnnouncement({
    required String communityId,
    required String announcementId,
  }) {
    return _communityAnnouncementsCollection(communityId: communityId)
        .doc(announcementId)
        .update(
          jsonSubset(
            [Announcement.kFieldAnnouncementStatus],
            Announcement(announcementStatus: AnnouncementStatus.removed)
                .toJson(),
          ),
        );
  }

  static Future<List<Announcement>> _convertAnnouncementListAsync(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  ) async {
    final announcements = await Future.wait(
      docs.map((doc) => compute(_convertAnnouncement, doc.data())),
    );

    for (var i = 0; i < announcements.length; i++) {
      announcements[i] = announcements[i].copyWith(
        id: docs[i].id,
      );
    }

    return announcements;
  }

  static Announcement _convertAnnouncement(data) =>
      Announcement.fromJson(fromFirestoreJson(data));
}
