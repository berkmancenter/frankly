import { onRequest } from 'firebase-functions/v2/https';
import corsLib from 'cors';
import * as admin from 'firebase-admin';

import { agoraStorageBucketName } from './config';

const cors = corsLib({ origin: true });

const SIGNED_URL_EXPIRATION_MS = 15 * 60 * 1000;

const EVENT_PATH_REGEX = /^community\/[^/]+\/templates\/[^/]+\/events\/[^/]+$/;

// Returns one signed URL per recording-session's merged transcript CSV
// (complete_trx_<n>, written by produceSessions)
export const downloadTranscripts = onRequest((req, res) => {
  cors(req, res, async () => {
    try {
      const authToken = req.headers.authorization?.split('Bearer ')[1];
      if (!authToken) {
        res.status(401).json({ error: 'Unauthorized' });
        return;
      }

      const decodedToken = await admin.auth().verifyIdToken(authToken);
      const uid = decodedToken.uid;

      const { eventPath } = req.body;
      if (!eventPath) {
        res.status(400).json({ error: 'eventPath not found' });
        return;
      }
      if (!EVENT_PATH_REGEX.test(eventPath)) {
        res.status(400).json({ error: 'Invalid eventPath format' });
        return;
      }

      const firestore = admin.firestore();
      const eventDoc = await firestore.doc(eventPath).get();
      if (!eventDoc.exists) {
        res.status(404).json({ error: 'event not found' });
        return;
      }
      const event = { id: eventDoc.id, ...eventDoc.data() } as { id: string; communityId: string };

      const membershipPath = `memberships/${uid}/community-membership/${event.communityId}`;
      const membershipDoc = await firestore.doc(membershipPath).get();
      if (!membershipDoc.exists) {
        res.status(403).json({ error: 'membership not found' });
        return;
      }
      const membership = membershipDoc.data() as { status: string };

      if (!['owner', 'admin'].includes(membership.status)) {
        res.status(403).json({ error: 'Unauthorized' });
        return;
      }

      const sessionsSnap = await firestore
        .collection('recording-sessions')
        .where('eventId', '==', event.id)
        .where('communityId', '==', event.communityId)
        .where('status', '==', 'stopped')
        .get();

      if (sessionsSnap.empty) {
        res.status(200).json({ transcripts: [] });
        return;
      }

      const bucket = admin.storage().bucket(agoraStorageBucketName.value());
      const transcripts: { roomId: string; roomType: string; url: string }[] = [];

      for (const sessionDoc of sessionsSnap.docs) {
        const session = sessionDoc.data() as {
          artifactPaths?: Record<string, string>;
          roomId?: string;
          roomType?: string;
        };
        const artifactPaths = session.artifactPaths || {};
        const roomId = session.roomId || 'unknown';
        const roomType = session.roomType || 'main';

        const trxPaths = Object.entries(artifactPaths)
          .filter(([key]) => key.startsWith('complete_trx_'))
          .map(([, path]) => path);

        for (const trxPath of trxPaths) {
          try {
            const filename = trxPath.split('/').pop() || `${roomId}.csv`;
            const [url] = await bucket.file(trxPath).getSignedUrl({
              action: 'read',
              expires: Date.now() + SIGNED_URL_EXPIRATION_MS,
              responseDisposition: `attachment; filename="${filename}"`,
            });
            transcripts.push({ roomId, roomType, url });
          } catch (fileErr) {
            console.error(`Error signing transcript ${trxPath}:`, fileErr);
          }
        }
      }

      res.status(200).json({ transcripts });
    } catch (err) {
      console.error('Error generating transcript URLs:', err);
      res.status(500).json({ error: 'Failed to generate transcript URLs' });
    }
  });
});
