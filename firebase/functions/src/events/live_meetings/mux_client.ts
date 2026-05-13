import * as functions from 'firebase-functions';
import * as https from 'https';
import * as http from 'http';

function makeRequest(options: http.RequestOptions, body?: string): Promise<{ statusCode: number; body: string }> {
  return new Promise((resolve, reject) => {
    const req = https.request(options, (res) => {
      let data = '';
      res.on('data', (chunk) => { data += chunk; });
      res.on('end', () => resolve({ statusCode: res.statusCode ?? 0, body: data }));
    });
    req.on('error', reject);
    if (body) req.write(body);
    req.end();
  });
}

export const muxApi = new class MuxApi {
  private get _muxTokenId(): string { return functions.config().mux?.token_id as string; }
  private get _muxSecret(): string { return functions.config().mux?.secret as string; }
  private get _auth(): string { return `${this._muxTokenId}:${this._muxSecret}`; }

  private get _headers(): Record<string, string> {
    return {
      Authorization: `Basic ${Buffer.from(this._auth).toString('base64')}`,
      'Content-Type': 'application/json',
    };
  }

  async createLiveStream(): Promise<Record<string, unknown>> {
    const body = JSON.stringify({
      playback_policy: 'public',
      reduced_latency: true,
      new_asset_settings: { playback_policy: 'public' },
    });
    const result = await makeRequest({
      method: 'POST',
      hostname: 'api.mux.com',
      path: '/video/v1/live-streams',
      headers: { ...this._headers, 'Content-Length': Buffer.byteLength(body).toString() },
    }, body);
    this._verifyResponse(result);
    return (JSON.parse(result.body) as { data: Record<string, unknown> }).data;
  }

  private _verifyResponse(response: { statusCode: number; body: string }): void {
    if (response.statusCode < 200 || response.statusCode > 299) {
      console.error('Error during mux call:', response.statusCode, response.body);
      throw new Error(response.body);
    }
  }
}();
