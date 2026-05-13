import * as functions from 'firebase-functions';
import { OnCallMethod } from '../../on_call_function';
import { firestore, firestoreUtils } from '../../utils/infra/firestore_utils';
import { muxApi } from './mux_client';
import { Membership } from '../../types';

interface CreateLiveStreamRequest {
  communityId: string;
}

interface CreateLiveStreamResponse {
  muxId?: string;
  muxPlaybackId?: string;
  streamServerUrl?: string;
  streamKey?: string;
}

export class CreateLiveStream extends OnCallMethod<CreateLiveStreamRequest> {
  constructor() {
    super('CreateLiveStream', (jsonMap) => jsonMap as CreateLiveStreamRequest);
  }

  async action(
    request: CreateLiveStreamRequest,
    context: functions.https.CallableContext
  ): Promise<CreateLiveStreamResponse> {
    const membershipSnap = await firestore
      .doc(`memberships/${context.auth?.uid}/community-membership/${request.communityId}`)
      .get();
    const membership = firestoreUtils.fromFirestoreJson(membershipSnap.data() ?? {}) as unknown as Membership;

    if (!(membership as any).isAdmin) {
      console.log(`member not admin: memberships/${context.auth?.uid}/community-membership/${request.communityId}`);
      throw new functions.https.HttpsError('failed-precondition', 'unauthorized');
    }

    console.log('creating a livestream');
    const liveStream = await muxApi.createLiveStream();
    console.log(liveStream);

    const ls = liveStream as Record<string, unknown>;
    return {
      muxId: ls['id'] as string,
      muxPlaybackId: (ls['playback_ids'] as Array<Record<string, string>>).find(
        (entry) => entry['policy'] === 'public'
      )?.['id'],
      streamServerUrl: 'rtmp://global-live.mux.com:5222/app',
      streamKey: ls['stream_key'] as string,
    };
  }
}
