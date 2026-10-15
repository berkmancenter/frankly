import { Readable } from 'stream';
import { onRequest } from 'firebase-functions/v2/https';
import corsLib from 'cors';

const cors = corsLib({ origin: true });

// Gen2 runs on Node 24, which has a global `fetch` - no node-fetch dependency needed.
export const imageProxy = onRequest((req, res) => {
  cors(req, res, async () => {
    console.log('Requested URI:', req.originalUrl);
    const url = req.query.url;

    if (!url || typeof url !== 'string') {
      res.status(400).send('URL parameter is required');
      return;
    }

    try {
      const response = await fetch(url);
      const contentType = response.headers.get('content-type');
      if (contentType) res.setHeader('Content-Type', contentType);

      if (!response.body) {
        res.status(502).send('Error fetching URL');
        return;
      }

      // Native `fetch`'s body is a web ReadableStream, not a Node stream, so
      // it can't be `.pipe()`d directly the way node-fetch's could -
      // `Readable.fromWeb` adapts it back to preserve streaming behavior.
      Readable.fromWeb(response.body as import('stream/web').ReadableStream).pipe(res);
    } catch (error) {
      console.error('Error fetching URL:', error);
      res.status(500).send('Error fetching URL');
    }
  });
});
