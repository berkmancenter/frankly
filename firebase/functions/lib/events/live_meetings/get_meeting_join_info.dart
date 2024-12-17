import 'dart:async';

import 'package:collection/collection.dart';
import 'package:firebase_functions_interop/firebase_functions_interop.dart';
import 'live_meeting_utils.dart';
import '../../on_call_function.dart';
import '../../utils/firestore_utils.dart';
import 'package:data_models/cloud_functions/requests.dart';
import 'package:data_models/events/event.dart';
import 'package:data_models/user/public_user_info.dart';
import 'package:data_models/utils/utils.dart';

class GetMeetingJoinInfo extends OnCallMethod<GetMeetingJoinInfoRequest> {
  GetMeetingJoinInfo()
      : super(
          'GetMeetingJoinInfo',
          (jsonMap) => GetMeetingJoinInfoRequest.fromJson(jsonMap),
        );

  @override
  Future<Map<String, dynamic>> action(
    GetMeetingJoinInfoRequest request,
    CallableContext context,
  ) async {
    return firestore.runTransaction((transaction) async {
      final event = await firestoreUtils.getFirestoreObject(
        transaction: transaction,
        path: request.eventPath,
        constructor: (map) => Event.fromJson(map),
      );

      final participant = await firestoreUtils.getFirestoreObject(
        transaction: transaction,
        path: '${request.eventPath}/event-participants/${context.authUid}',
        constructor: (map) => Participant.fromJson(map),
      );

      if (participant.status != ParticipantStatus.active) {
        throw HttpsError(HttpsError.failedPrecondition, 'unauthorized', null);
      }

      // Decide on users identifier
      final userSnapshot =
          await firestore.document('publicUser/${context.authUid}').get();
      final publicUserInfo = PublicUserInfo.fromJson(
        firestoreUtils.fromFirestoreJson(userSnapshot.data.toMap() ?? {}),
      );
      var displayName = publicUserInfo.displayName;
      print('Public user display name: $displayName');

      if (displayName == null || displayName.trim().isEmpty) {
        final userLookup = await firestoreUtils.getUsers([context.authUid!]);
        displayName =
            firstAndLastInitial(userLookup.firstOrNull?.displayName) ??
                'User-${context.authUid!.substring(0, 4)}';
        print('Public user display name: $displayName');
      }

      final joinInfo = await LiveMeetingUtils().getMeetingJoinInfo(
        transaction: transaction,
        event: event,
        communityId: event.communityId,
        liveMeetingCollectionPath: '${request.eventPath}/live-meetings',
        meetingId: event.id,
        userId: context.authUid!,
      );

      return joinInfo.toJson();
    });
  }
}
