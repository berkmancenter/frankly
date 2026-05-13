import * as functions from 'firebase-functions';
import { OnCallMethod } from '../../on_call_function';
import { firestore, firestoreUtils } from '../../utils/infra/firestore_utils';
import { orElseUnauthorized, orElseNotFound } from '../../utils/utils';

interface GetUserIdFromAgoraIdRequest {
  agoraId: number | string;
}

interface GetUserIdFromAgoraIdResponse {
  userId?: string;
}

export class GetUserIdFromAgoraId extends OnCallMethod<GetUserIdFromAgoraIdRequest> {
  constructor() {
    super('GetUserIdFromAgoraId', (jsonMap) => jsonMap as GetUserIdFromAgoraIdRequest);
  }

  async action(
    request: GetUserIdFromAgoraIdRequest,
    context: functions.https.CallableContext
  ): Promise<GetUserIdFromAgoraIdResponse> {
    orElseUnauthorized(context.auth?.uid != null);

    const docs = await firestore
      .collection('publicUser')
      .where('agoraId', '==', request.agoraId)
      .get();

    if (docs.empty) {
      throw new functions.https.HttpsError('not-found', `User with agora ID ${request.agoraId} not found`);
    }

    const userInfo = firestoreUtils.fromFirestoreJson(docs.docs[0].data()) as unknown as { id?: string };

    return { userId: userInfo.id };
  }
}
