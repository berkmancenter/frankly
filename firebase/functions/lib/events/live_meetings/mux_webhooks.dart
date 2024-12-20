import 'dart:async';

import 'package:firebase_admin_interop/firebase_admin_interop.dart';
import '../../on_request_method.dart';
import '../../utils/firestore_utils.dart';
import '../../utils/utils.dart';
import 'package:data_models/firestore/event.dart';

class MuxWebhooks extends OnRequestMethod<JsonMap> {
  MuxWebhooks() : super('MuxWebhooks', (jsonMap) => JsonMap(jsonMap));

  Future<void> _handleLiveStreamStatus({
    required String type,
    required JsonMap request,
  }) async {
    final streamId = request.json['object']['id'] as String;
    final status = request.json['data']['status'];

    final eventQuery = await firestore
        .collectionGroup('events')
        .where(
          '${Event.kFieldLiveStreamInfo}.${LiveStreamInfo.kFieldMuxId}',
          isEqualTo: streamId,
        )
        .get();
    if (eventQuery.documents.length != 1) {
      print('Error: Unexpected number of documents matching livestream ID');
    } else {
      final eventSnapshot = eventQuery.documents.single;
      final event = Event.fromJson(
        firestoreUtils.fromFirestoreJson(eventSnapshot.data.toMap()),
      );
      if (event.liveStreamInfo?.muxStatus != status) {
        await eventSnapshot.reference.updateData(
          UpdateData.fromMap({'liveStreamInfo.muxStatus': status}),
        );
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
        final playbackId =
            (request.json['data']['playback_ids'] as List<dynamic>)
                .firstWhere((entry) => entry['policy'] == 'public')['id'];

        final eventQuery = await firestore
            .collectionGroup('events')
            .where(
              '${Event.kFieldLiveStreamInfo}.${LiveStreamInfo.kFieldMuxId}',
              isEqualTo: liveStreamId,
            )
            .get();
        if (eventQuery.documents.length != 1) {
          print('Error: Unexpected number of documents matching livestream ID');
        } else {
          final eventSnapshot = eventQuery.documents.single;
          final event = Event.fromJson(
            firestoreUtils.fromFirestoreJson(eventSnapshot.data.toMap()),
          );
          if (event.liveStreamInfo?.latestAssetPlaybackId != playbackId) {
            await eventSnapshot.reference.updateData(
              UpdateData.fromMap(
                {'liveStreamInfo.latestAssetPlaybackId': playbackId},
              ),
            );
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
