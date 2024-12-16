import 'dart:async';

import 'package:collection/collection.dart';
import 'package:firebase_functions_interop/firebase_functions_interop.dart';
import 'package:junto_functions/functions/on_call/live_meeting_utils.dart';
import 'package:junto_functions/functions/on_call_function.dart';
import 'package:junto_functions/utils/firestore_utils.dart';
import 'package:junto_models/cloud_functions/requests.dart';
import 'package:junto_models/firestore/discussion.dart';
import 'package:junto_models/firestore/public_user_info.dart';
import 'package:junto_models/utils.dart';

class GetMeetingJoinInfo extends OnCallMethod<GetMeetingJoinInfoRequest> {
  GetMeetingJoinInfo()
      : super('GetMeetingJoinInfo', (jsonMap) => GetMeetingJoinInfoRequest.fromJson(jsonMap));

  @override
  Future<Map<String, dynamic>> action(
      GetMeetingJoinInfoRequest request, CallableContext context) async {
    return firestore.runTransaction((transaction) async {
      final discussion = await firestoreUtils.getFirestoreObject(
        transaction: transaction,
        path: request.discussionPath,
        constructor: (map) => Discussion.fromJson(map),
      );

      final participant = await firestoreUtils.getFirestoreObject(
        transaction: transaction,
        path: '${request.discussionPath}/discussion-participants/${context?.authUid}',
        constructor: (map) => Participant.fromJson(map),
      );

      if (participant.status != ParticipantStatus.active) {
        throw HttpsError(HttpsError.failedPrecondition, 'unauthorized', null);
      }

      // Decide on users identifier
      final userSnapshot = await firestore.document('publicUser/${context?.authUid}').get();
      final publicUserInfo = PublicUserInfo.fromJson(firestoreUtils.fromFirestoreJson(userSnapshot.data?.toMap() ?? {}));
      var displayName = publicUserInfo.displayName;
      print('Public user display name: $displayName');

      if (displayName == null || displayName.trim().isEmpty) {
        final userLookup = await firestoreUtils.getUsers([context!.authUid!]);
        displayName = firstAndLastInitial(userLookup.firstOrNull?.displayName) ??
            'User-${context?.authUid!.substring(0, 4)}';
        print('Public user display name: $displayName');
      }

      final joinInfo = await LiveMeetingUtils().getMeetingJoinInfo(
        transaction: transaction,
        discussion: discussion,
        juntoId: discussion.juntoId,
        liveMeetingCollectionPath: '${request.discussionPath}/live-meetings',
        meetingId: discussion.id,
        userId: context!.authUid!,
      );

      return joinInfo.toJson();
    });
  }
}
