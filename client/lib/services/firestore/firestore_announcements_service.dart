import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:junto/services/firestore/firestore_utils.dart';
import 'package:junto/services/services.dart';
import 'package:junto_models/cloud_functions/requests.dart';
import 'package:junto_models/firestore/announcement.dart';
import 'package:junto_models/utils.dart';

class FirestoreAnnouncementsService {
  static const announcements = 'announcements';

  CollectionReference<Map<String, dynamic>> _juntoAnnouncementsCollection({
    required String juntoId,
  }) {
    return firestoreDatabase.juntoRef(juntoId).collection(announcements);
  }

  BehaviorSubjectWrapper<List<Announcement>> juntoAnnouncements({
    required String juntoId,
  }) {
    return wrapInBehaviorSubject(_juntoAnnouncementsCollection(juntoId: juntoId)
        .orderBy('createdDate', descending: true)
        .snapshots()
        .map((s) => s.docs)
        .asyncMap(_convertAnnouncementListAsync)
        .map((announcements) => announcements
            .where((a) => a.announcementStatus != AnnouncementStatus.removed)
            .toList()));
  }

  Future<void> createAnnouncement({
    required String juntoId,
    required String title,
    required String message,
    required bool emailToMembers,
  }) async {
    return cloudFunctionsService.createAnnouncement(CreateAnnouncementRequest(
      juntoId: juntoId,
      announcement: Announcement(
        announcementStatus: AnnouncementStatus.active,
        creatorId: userService.currentUserId,
        title: title,
        message: message,
      ),
    ));
  }

  Future<void> deleteAnnouncement({
    required String juntoId,
    required String announcementId,
  }) {
    return _juntoAnnouncementsCollection(juntoId: juntoId).doc(announcementId).update(jsonSubset(
        [Announcement.kFieldAnnouncementStatus],
        Announcement(announcementStatus: AnnouncementStatus.removed).toJson()));
  }

  static Future<List<Announcement>> _convertAnnouncementListAsync(
      List<QueryDocumentSnapshot<Map<String, dynamic>>> docs) async {
    final announcements =
        await Future.wait(docs.map((doc) => compute(_convertAnnouncement, doc.data())));

    for (var i = 0; i < announcements.length; i++) {
      announcements[i] = announcements[i].copyWith(
        id: docs[i].id,
      );
    }

    return announcements;
  }

  static Announcement _convertAnnouncement(data) => Announcement.fromJson(fromFirestoreJson(data));
}
