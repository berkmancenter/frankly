import 'package:firebase_admin_interop/firebase_admin_interop.dart';
import 'package:junto_functions/utils/agora_api.dart';
import 'package:junto_functions/utils/firestore_utils.dart';
import 'package:junto_functions/utils/utils.dart';
import 'package:junto_models/cloud_functions/requests.dart';
import 'package:junto_models/firestore/discussion.dart';
import 'package:junto_models/firestore/live_meeting.dart';
import 'package:junto_models/utils.dart';

class LiveMeetingUtils {
  bool _shouldRecord(Discussion discussion) => discussion.discussionSettings?.alwaysRecord ?? false;
  AgoraUtils agoraUtils;

  LiveMeetingUtils({AgoraUtils? agoraUtils}) : agoraUtils = agoraUtils ?? AgoraUtils();

  Future<GetMeetingJoinInfoResponse> getMeetingJoinInfo({
    required Transaction transaction,
    required String juntoId,
    required String liveMeetingCollectionPath,
    required String meetingId,
    required String userId,
    required Discussion discussion,
  }) async {
    final fieldsToUpdate = <String>[];

    // Look up live meeting
    final liveMeetingSnapshot = await transaction.get(
      firestore.document('$liveMeetingCollectionPath/$meetingId'),
    );
    var liveMeeting = LiveMeeting.fromJson(firestoreUtils.fromFirestoreJson(liveMeetingSnapshot.data?.toMap() ?? {}));
    if (isNullOrEmpty(liveMeeting.meetingId)) {
      fieldsToUpdate.add(LiveMeeting.kFieldMeetingId);
    }
    liveMeeting = liveMeeting.copyWith(
      meetingId: liveMeeting.meetingId ?? meetingId,
    );

    final shouldRecord = _shouldRecord(discussion) || (liveMeeting.record);
    if (shouldRecord) {
      await agoraUtils.recordRoom(roomId: meetingId);
    }

    if (liveMeetingSnapshot.exists && fieldsToUpdate.isNotEmpty) {
      transaction.update(liveMeetingSnapshot.reference,
          UpdateData.fromMap(jsonSubset(fieldsToUpdate, firestoreUtils.toFirestoreJson(liveMeeting.toJson()))));
    } else if (!liveMeetingSnapshot.exists) {
      transaction.set(
          liveMeetingSnapshot.reference, DocumentData.fromMap(firestoreUtils.toFirestoreJson(liveMeeting.toJson())));
    }

    final token = agoraUtils.createToken(uid: uidToInt(userId), roomId: meetingId);

    return GetMeetingJoinInfoResponse(
      identity: userId,
      meetingToken: token,
      meetingId: meetingId,
    );
  }

  Future<GetMeetingJoinInfoResponse> getBreakoutRoomJoinInfo({
    required String juntoId,
    required String meetingId,
    required String userId,
    required bool record,
  }) async {
    final token = agoraUtils.createToken(uid: uidToInt(userId), roomId: meetingId);
    if (record) {
      await agoraUtils.recordRoom(roomId: meetingId);
    }

    final meetingInfo = GetMeetingJoinInfoResponse(
      identity: userId,
      meetingToken: token,
      meetingId: meetingId,
    );

    return meetingInfo;
  }
}
