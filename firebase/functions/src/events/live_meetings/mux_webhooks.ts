import { OnRequestMethod } from '../../on_request_method';
import { firestore, firestoreUtils } from '../../utils/infra/firestore_utils';

type JsonMap = Record<string, unknown>;

export class MuxWebhooks extends OnRequestMethod<JsonMap> {
  constructor() {
    super('MuxWebhooks', (jsonMap) => jsonMap as JsonMap);
  }

  private async _handleLiveStreamStatus({
    request,
  }: {
    type: string;
    request: JsonMap;
  }): Promise<void> {
    const streamId = (request['object'] as Record<string, unknown>)?.['id'] as string;
    const status = ((request['data'] as Record<string, unknown>)?.['status']) as string;

    const eventQuery = await firestore
      .collectionGroup('events')
      .where('liveStreamInfo.muxId', '==', streamId)
      .get();

    if (eventQuery.size !== 1) {
      console.log('Error: Unexpected number of documents matching livestream ID');
    } else {
      const eventSnapshot = eventQuery.docs[0];
      const event = firestoreUtils.fromFirestoreJson(eventSnapshot.data()) as Record<string, unknown>;
      const liveStreamInfo = event['liveStreamInfo'] as Record<string, unknown> | undefined;
      if (liveStreamInfo?.['muxStatus'] !== status) {
        await eventSnapshot.ref.update({ 'liveStreamInfo.muxStatus': status });
      }
    }
  }

  async action(request: JsonMap): Promise<string> {
    console.log(request);

    try {
      const type = request['type'] as string;

      if (type.startsWith('video.live_stream')) {
        const eventType = type.substring('video.live_stream.'.length);
        if (['created', 'idle', 'active'].includes(eventType)) {
          await this._handleLiveStreamStatus({ type, request });
        }
      }

      if (type === 'video.asset.live_stream_completed') {
        const data = request['data'] as Record<string, unknown>;
        const liveStreamId = data['live_stream_id'] as string;
        const playbackId = (data['playback_ids'] as Array<Record<string, string>>).find(
          (entry) => entry['policy'] === 'public'
        )?.['id'];

        const eventQuery = await firestore
          .collectionGroup('events')
          .where('liveStreamInfo.muxId', '==', liveStreamId)
          .get();

        if (eventQuery.size !== 1) {
          console.log('Error: Unexpected number of documents matching livestream ID');
        } else {
          const eventSnapshot = eventQuery.docs[0];
          const event = firestoreUtils.fromFirestoreJson(eventSnapshot.data()) as Record<string, unknown>;
          const liveStreamInfo = event['liveStreamInfo'] as Record<string, unknown> | undefined;
          if (liveStreamInfo?.['latestAssetPlaybackId'] !== playbackId) {
            await eventSnapshot.ref.update({ 'liveStreamInfo.latestAssetPlaybackId': playbackId });
          }
        }
      }
    } catch (e) {
      console.log('Error in parsing mux payload.');
      console.log(e);
    }

    return '';
  }
}
