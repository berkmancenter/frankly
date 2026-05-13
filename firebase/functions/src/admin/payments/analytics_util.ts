import * as functions from 'firebase-functions';
import * as https from 'https';

export const analyticsUtil = {
  get _secretKey(): string {
    return functions.config().segment?.write_key as string;
  },

  logEvent({ userId, event }: { userId: string; event: Record<string, unknown> }): void {
    this._doLogEvent({ userId, event }).catch(console.error);
  },

  async _doLogEvent({ userId, event }: { userId: string; event: Record<string, unknown> }): Promise<void> {
    const encodedKey = Buffer.from(`${analyticsUtil._secretKey}:`).toString('base64');
    const body = JSON.stringify({
      event: (event as any).eventType ?? (event as any).type ?? 'unknown',
      properties: event,
      userId,
    });

    return new Promise((resolve, reject) => {
      const req = https.request(
        {
          hostname: 'api.segment.io',
          path: '/v1/track',
          method: 'POST',
          headers: {
            'Authorization': `Basic ${encodedKey}`,
            'Content-Type': 'application/json',
            'Content-Length': Buffer.byteLength(body),
          },
        },
        (res) => {
          let data = '';
          res.on('data', (chunk) => (data += chunk));
          res.on('end', () => {
            const statusCode = res.statusCode ?? 500;
            if (statusCode > 299) {
              console.error('Segment POST error:', data);
            }
            resolve();
          });
        }
      );
      req.on('error', (e) => { console.error(e); resolve(); });
      req.write(body);
      req.end();
    });
  },
};
