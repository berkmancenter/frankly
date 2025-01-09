import 'package:flutter/material.dart';
import 'package:client/core/utils/firestore_utils.dart';
import 'package:client/services.dart';
import 'package:data_models/announcements/announcement.dart';

class AnnouncementsProvider with ChangeNotifier {
  final String communityId;

  late BehaviorSubjectWrapper<List<Announcement>> _announcements;

  AnnouncementsProvider({required this.communityId});

  Stream<List<Announcement>>? get announcements => _announcements.stream;

  void initialize() {
    _announcements = firestoreAnnouncementsService.communityAnnouncements(
      communityId: communityId,
    );
  }

  @override
  void dispose() {
    _announcements.dispose();
    super.dispose();
  }
}
