import 'package:client/services.dart';
import 'package:data_models/cloud_functions/requests.dart';

class CloudFunctionsAnnouncementsService {
  Future<void> createAnnouncement(CreateAnnouncementRequest request) async {
    await cloudFunctions.callFunction('sendAnnouncement', request.toJson());
  }
}
