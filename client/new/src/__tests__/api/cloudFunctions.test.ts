import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest';
import type { Auth } from 'firebase/auth';
import type { FirebaseApp } from 'firebase/app';
import type { Functions } from 'firebase/functions';

const mocks = vi.hoisted(() => ({
  connectFunctionsEmulator: vi.fn(),
  getFunctions: vi.fn(),
  httpsCallable: vi.fn(),
}));

vi.mock('firebase/functions', () => mocks);

import { CloudFunctions } from '@/api/cloudFunctions';

describe('CloudFunctions', () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  afterEach(() => {
    vi.unstubAllGlobals();
  });

  it('uses the same-origin rewrite for deployed callable functions', async () => {
    vi.stubGlobal('window', {
      location: {
        hostname: 'app.frankly.org',
        origin: 'https://app.frankly.org',
      },
    });
    const fetch = vi.fn().mockResolvedValue(
      new Response(JSON.stringify({ result: { ok: true } }), { status: 200 }),
    );
    vi.stubGlobal('fetch', fetch);
    const auth = {
      currentUser: { getIdToken: vi.fn().mockResolvedValue('firebase-id-token') },
    } as unknown as Auth;
    const client = new CloudFunctions(
      { sameOrigin: true },
      {} as FirebaseApp,
      auth,
    );

    await expect(
      client.call('createEvent', { eventPath: 'community/c/templates/t/events/e' }),
    ).resolves.toEqual({ ok: true });

    expect(fetch).toHaveBeenCalledWith(
      'https://app.frankly.org/api/createEvent',
      expect.objectContaining({
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          Authorization: 'Bearer firebase-id-token',
        },
        body: JSON.stringify({
          data: { eventPath: 'community/c/templates/t/events/e' },
        }),
      }),
    );
    expect(mocks.httpsCallable).not.toHaveBeenCalled();
  });

  it('connects to the Functions emulator and calls through the Firebase SDK', async () => {
    const functions = {} as Functions;
    const callable = vi.fn().mockResolvedValue({ data: { ok: true } });
    mocks.getFunctions.mockReturnValue(functions);
    mocks.httpsCallable.mockReturnValue(callable);
    const client = new CloudFunctions(
      {
        sameOrigin: true,
        emulator: { host: '127.0.0.1', port: 5001 },
      },
      {} as FirebaseApp,
    );

    await expect(client.call('createEvent', { eventPath: 'event/path' })).resolves.toEqual({
      ok: true,
    });

    expect(mocks.connectFunctionsEmulator).toHaveBeenCalledWith(
      functions,
      '127.0.0.1',
      5001,
    );
    expect(mocks.httpsCallable).toHaveBeenCalledWith(
      functions,
      'createEvent',
      undefined,
    );
    expect(callable).toHaveBeenCalledWith({ eventPath: 'event/path' });
  });
});
