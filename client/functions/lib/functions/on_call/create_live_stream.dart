import 'dart:async';

import 'package:firebase_functions_interop/firebase_functions_interop.dart';
import 'package:junto_functions/functions/on_call_function.dart';
import 'package:junto_functions/utils/firestore_utils.dart';
import 'package:junto_functions/utils/mux_client.dart';
import 'package:junto_models/cloud_functions/requests.dart';
import 'package:junto_models/firestore/membership.dart';

class CreateLiveStream extends OnCallMethod<CreateLiveStreamRequest> {
  CreateLiveStream()
      : super(
          'CreateLiveStream',
          (jsonMap) => CreateLiveStreamRequest.fromJson(jsonMap),
        );

  @override
  Future<Map<String, dynamic>> action(
      CreateLiveStreamRequest request, CallableContext context) async {
    final membershipDoc = 'memberships/${context?.authUid}/junto-membership/${request.juntoId}';
    final juntoMembershipDoc = await firestore.document(membershipDoc).get();

    final membership = Membership.fromJson(firestoreUtils.fromFirestoreJson(juntoMembershipDoc.data?.toMap() ?? {}));

    if (!membership.isAdmin) {
      print('member not admin: $membershipDoc');
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
