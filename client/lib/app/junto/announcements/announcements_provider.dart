import 'package:flutter/material.dart';
import 'package:junto/services/firestore/firestore_utils.dart';
import 'package:junto/services/services.dart';
import 'package:junto_models/firestore/announcement.dart';

class AnnouncementsProvider with ChangeNotifier {
  final String juntoId;

  late BehaviorSubjectWrapper<List<Announcement>> _announcements;

  AnnouncementsProvider({required this.juntoId});

  Stream<List<Announcement>>? get announcements => _announcements.stream;

  void initialize() {
    _announcements = firestoreAnnouncementsService.juntoAnnouncements(juntoId: juntoId);
  }

  @override
  void dispose() {
    _announcements.dispose();
    super.dispose();
  }
}
