import { onRequest } from 'firebase-functions/v2/https';
import corsLib from 'cors';
import * as admin from 'firebase-admin';

import { agoraStorageBucketName } from './config';

const cors = corsLib({ origin: true });

// Signed URLs expire after 15 minutes
const SIGNED_URL_EXPIRATION_MS = 15 * 60 * 1000;

export const getSessionDownloadUrl = onRequest((req, res) => {
  cors(req, res, async () => {
    try {
      const authToken = req.headers.authorization?.split('Bearer ')[1];
      if (!authToken) {
        res.status(401).json({ error: 'Unauthorized' });
        return;
      }

      const decodedToken = await admin.auth().verifyIdToken(authToken);
      const uid = decodedToken.uid;

      const { sessionId } = req.body;
      if (!sessionId || typeof sessionId !== 'string' || sessionId.trim() === '') {
        res.status(400).json({ error: 'sessionId is required' });
        return;
      }

      const firestore = admin.firestore();
      const sessionDoc = await firestore.collection('recording-sessions').doc(sessionId).get();
      if (!sessionDoc.exists) {
        res.status(404).json({ error: 'Session not found' });
        return;
      }
      const session = sessionDoc.data() as {
        communityId: string;
        artifactPaths?: Record<string, string>;
      };

      // Verify the caller is an admin/owner of the session's community.
      const membershipPath = `memberships/${uid}/community-membership/${session.communityId}`;
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

      const artifactPaths = session.artifactPaths ?? {};
      if (Object.keys(artifactPaths).length === 0) {
        res.status(200).json({ urls: {} });
        return;
      }

      const bucket = admin.storage().bucket(agoraStorageBucketName.value());
      const urlEntries = await Promise.all(
        Object.entries(artifactPaths).map(async ([key, gcsPath]) => {
          const file = bucket.file(gcsPath);
          const filename = gcsPath.split('/').pop();
          const [url] = await file.getSignedUrl({
            action: 'read',
            expires: Date.now() + SIGNED_URL_EXPIRATION_MS,
            responseDisposition: `attachment; filename="${filename}"`,
          });
          return [key, url] as const;
        })
      );

      const urls = Object.fromEntries(urlEntries);
      res.status(200).json({ urls });
    } catch (err) {
      console.error('Error generating session download URLs:', err);
      res.status(500).json({ error: 'Failed to generate session download URLs' });
    }
  });
});
