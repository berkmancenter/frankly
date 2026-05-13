import * as functions from 'firebase-functions';
import { CloudFunction } from '../../cloud_function';
import { firestore, firestoreUtils } from '../../utils/infra/firestore_utils';

export interface Community {
  id?: string;
  displayIds?: string[];
  name?: string;
  [key: string]: unknown;
}

export abstract class AbstractCalendarFeed implements CloudFunction {
  abstract readonly functionName: string;

  abstract generateData(params: { community: Community }): Promise<string>;
  abstract getContentType(): string;

  async expressAction(req: functions.https.Request, res: import('express').Response): Promise<void> {
    try {
      const segments = req.path.split('/').filter(Boolean);
      if (segments.length !== 2) {
        res.status(400).send('Bad path');
        return;
      }
      const communityId = segments[1];

      const communityDocs = await firestore
        .collection('community')
        .where('displayIds', 'array-contains', communityId)
        .get();

      if (communityDocs.empty) {
        res.status(404).send('Not found');
        return;
      }

      const community = firestoreUtils.fromFirestoreJson(communityDocs.docs[0].data()) as unknown as Community;
      const data = await this.generateData({ community });
      res.setHeader('Content-Type', this.getContentType());
      res.send(data);
    } catch (e) {
      console.error('Error during action', e);
      res.status(500).send(String(e));
    }
  }

  register(_functions: typeof functions): functions.HttpsFunction {
    return _functions.https.onRequest((req, res) => this.expressAction(req, res));
  }
}
