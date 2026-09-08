import 'dart:async';

import 'package:firebase_functions_interop/firebase_functions_interop.dart';
import '../../on_call_function.dart';
import '../../utils/infra/firestore_utils.dart';
import 'mux_client.dart';
import 'package:data_models/cloud_functions/requests.dart';
import 'package:data_models/community/membership.dart';

class CreateLiveStream extends OnCallMethod<CreateLiveStreamRequest> {
  CreateLiveStream()
      : super(
          'CreateLiveStream',
          (jsonMap) => CreateLiveStreamRequest.fromJson(jsonMap),
        );

  @override
  Future<Map<String, dynamic>> action(
    CreateLiveStreamRequest request,
    CallableContext context,
  ) async {
    if (context.authUid == null) {
      throw HttpsError(HttpsError.failedPrecondition, 'unauthorized', null);
    }

    final membershipDoc =
        'memberships/${context.authUid}/community-membership/${request.communityId}';
    final communityMembershipDoc =
        await firestore.document(membershipDoc).get();

    if (!communityMembershipDoc.exists) {
      throw HttpsError(HttpsError.failedPrecondition, 'unauthorized', null);
    }

    final membership = Membership.fromJson(
      firestoreUtils.fromFirestoreJson(communityMembershipDoc.data.toMap()),
    );

    if (!membership.isMod) {
      print('member not moderator: $membershipDoc');
      throw HttpsError(HttpsError.failedPrecondition, 'unauthorized', null);
    }

    // Create mux live stream
    print('creating a livestream');
    final liveStream = await muxApi.createLiveStream();
    print(liveStream);

    return CreateLiveStreamResponse(
      muxId: liveStream['id'],
      muxPlaybackId: (liveStream['playback_ids'] as List<dynamic>)
          .firstWhere((entry) => entry['policy'] == 'public')['id'],
      streamServerUrl: 'rtmp://global-live.mux.com:5222/app',
      streamKey: liveStream['stream_key'],
    ).toJson();
  }
}
