import 'dart:async';

import 'package:firebase_admin_interop/firebase_admin_interop.dart';
import 'package:junto_functions/functions/on_request_method.dart';
import 'package:junto_functions/utils/firestore_utils.dart';
import 'package:junto_functions/utils/utils.dart';
import 'package:junto_models/firestore/discussion.dart';

class MuxWebhooks extends OnRequestMethod<JsonMap> {
  MuxWebhooks() : super('MuxWebhooks', (jsonMap) => JsonMap(jsonMap));

  Future<void> _handleLiveStreamStatus({
    required String type,
    required JsonMap request,
  }) async {
    final streamId = request.json['object']['id'] as String;
    final status = request.json['data']['status'];

    final discussionQuery = await firestore
        .collectionGroup('discussions')
        .where(
          '${Discussion.kFieldLiveStreamInfo}.${LiveStreamInfo.kFieldMuxId}',
          isEqualTo: streamId,
        )
        .get();
    if (discussionQuery.documents.length != 1) {
      print('Error: Unexpected number of documents matching livestream ID');
    } else {
      final discussionSnapshot = discussionQuery.documents.single;
      final discussion = Discussion.fromJson(firestoreUtils.fromFirestoreJson(discussionSnapshot.data.toMap()));
      if (discussion.liveStreamInfo?.muxStatus != status) {
        await discussionSnapshot.reference
            .updateData(UpdateData.fromMap({'liveStreamInfo.muxStatus': status}));
      }
    }
  }

  @override
  Future<String> action(JsonMap request) async {
    print(request.json);

    try {
      final type = request.json['type'] as String;

      if (type.startsWith('video.live_stream')) {
        final eventType = type.substring('video.live_stream.'.length);

        // Ignore events that are not the stream going from active to idle or vice versa.
        if (['created', 'idle', 'active'].contains(eventType)) {
          await _handleLiveStreamStatus(type: type, request: request);
        }
      }

      if (type == 'video.asset.live_stream_completed') {
        final liveStreamId = request.json['data']['live_stream_id'];
        final playbackId = (request.json['data']['playback_ids'] as List<dynamic>)
            .firstWhere((entry) => entry['policy'] == 'public')['id'];

        final discussionQuery = await firestore
            .collectionGroup('discussions')
            .where(
              '${Discussion.kFieldLiveStreamInfo}.${LiveStreamInfo.kFieldMuxId}',
              isEqualTo: liveStreamId,
            )
            .get();
        if (discussionQuery.documents.length != 1) {
          print('Error: Unexpected number of documents matching livestream ID');
        } else {
          final discussionSnapshot = discussionQuery.documents.single;
          final discussion = Discussion.fromJson(firestoreUtils.fromFirestoreJson(discussionSnapshot.data.toMap()));
          if (discussion.liveStreamInfo?.latestAssetPlaybackId != playbackId) {
            await discussionSnapshot.reference.updateData(
                UpdateData.fromMap({'liveStreamInfo.latestAssetPlaybackId': playbackId}));
          }
        }
      }
    } catch (e) {
      print('Error in parsing mux payload.');
      print(e);
    }

    return '';
  }
}
