import assert from 'node:assert/strict';
import http from 'node:http';
import type { AddressInfo } from 'node:net';
import { after, before, test } from 'node:test';
import { fixtureConfig as config } from './fixture.mjs';
import { createProxy } from './proxy.mjs';

interface StubReply {
  who: string;
  method: string;
  url: string;
  host: string;
  forwardedHost: string | null;
}

/** An upstream that answers every request with who it is and what it received. */
function stub(name: string): http.Server {
  const server = http.createServer((req, res) => {
    const reply: StubReply = {
      who: name,
      method: req.method ?? '',
      url: req.url ?? '',
      host: req.headers.host ?? '',
      forwardedHost: (req.headers['x-forwarded-host'] as string | undefined) ?? null,
    };
    res.setHeader('content-type', 'application/json');
    res.end(JSON.stringify(reply));
  });
  server.on('upgrade', (req, socket) => {
    socket.write(
      'HTTP/1.1 101 Switching Protocols\r\nUpgrade: websocket\r\nConnection: Upgrade\r\n' +
        `x-stub: ${name}\r\nx-stub-url: ${req.url}\r\n\r\n`,
    );
    socket.end();
  });
  return server;
}

const listen = (server: http.Server): Promise<number> =>
  new Promise((resolve) => server.listen(0, '127.0.0.1', () => resolve((server.address() as AddressInfo).port)));

const servers: http.Server[] = [];
const upstreamPorts = { flutter: 0 };
let proxyPort = 0;

before(async () => {
  const flutter = stub('flutter');
  const react = stub('react');
  const [fp, rp] = await Promise.all([listen(flutter), listen(react)]);
  upstreamPorts.flutter = fp;
  const proxy = createProxy({
    config,
    flutterUrl: `http://127.0.0.1:${fp}`,
    reactUrl: `http://127.0.0.1:${rp}`,
  });
  proxyPort = await listen(proxy);
  servers.push(flutter, react, proxy);
});

after(() => {
  for (const s of servers) s.close();
});

interface RequestOptions {
  method?: string;
  headers?: http.OutgoingHttpHeaders;
  port?: number;
}

interface RawResponse {
  status: number | undefined;
  headers: http.IncomingHttpHeaders;
  body: string;
}

function request(path: string, { method = 'GET', headers = {}, port = proxyPort }: RequestOptions = {}): Promise<RawResponse> {
  return new Promise((resolve, reject) => {
    const req = http.request({ host: '127.0.0.1', port, path, method, headers }, (res) => {
      let body = '';
      res.on('data', (chunk: Buffer) => (body += chunk));
      res.on('end', () => resolve({ status: res.statusCode, headers: res.headers, body }));
    });
    req.on('error', reject);
    req.end();
  });
}

const json = async (path: string, opts?: RequestOptions): Promise<RawResponse & { data: StubReply }> => {
  const res = await request(path, opts);
  return { ...res, data: JSON.parse(res.body) as StubReply };
};

test('migrated pages are served by React, which receives its shell URL', async () => {
  for (const path of ['/home', '/space/civic-lab', '/space/civic-lab/posts', '/space/civic-lab/resources', '/space/civic-lab/discuss/upcoming']) {
    const { data, headers } = await json(path);
    assert.equal(data.who, 'react', path);
    assert.equal(data.url, '/_new/', path);
    assert.equal(headers['x-frankly-upstream'], 'react');
  }
});

test('the query string survives the rewrite', async () => {
  const { data } = await json('/space/civic-lab/posts?tag=a&b=2');
  assert.equal(data.url, '/_new/?tag=a&b=2');
});

test('everything else is served by Flutter, request untouched', async () => {
  for (const path of ['/', '/settings', '/space/civic-lab/discuss', '/space/civic-lab/admin/profile', '/space/civic-lab/discuss/t1/e1?status=joined', '/main.dart.js']) {
    const { data, headers } = await json(path);
    assert.equal(data.who, 'flutter', path);
    assert.equal(data.url, path, path);
    assert.equal(headers['x-frankly-upstream'], 'flutter');
  }
});

test('writes to a migrated URL go to Flutter', async () => {
  const { data } = await json('/home', { method: 'POST' });
  assert.equal(data.who, 'flutter');
});

test('React assets and /media/ files are served by React from under its asset base', async () => {
  assert.equal((await json('/_new/src/main.tsx')).data.url, '/_new/src/main.tsx');
  const media = (await json('/media/like.png')).data;
  assert.equal(media.who, 'react');
  assert.equal(media.url, '/_new/media/like.png');
});

test('React sees the browser-facing Host; Flutter sees its own (its debug socket URL derives from it)', async () => {
  const react = (await json('/home')).data;
  assert.equal(react.who, 'react');
  assert.equal(react.host, `127.0.0.1:${proxyPort}`);

  const flutter = (await json('/settings')).data;
  assert.equal(flutter.who, 'flutter');
  assert.equal(flutter.host, `127.0.0.1:${upstreamPorts.flutter}`);
  assert.equal(flutter.forwardedHost, null, 'Flutter must not see the browser host via X-Forwarded-Host either');
});

test('WebSocket upgrades follow the same rules (Vite HMR vs Flutter debug socket)', async () => {
  const upgrade = (path: string): Promise<{ who: string | string[] | undefined; url: string | string[] | undefined }> =>
    new Promise((resolve, reject) => {
      const req = http.request({
        host: '127.0.0.1',
        port: proxyPort,
        path,
        headers: { Connection: 'Upgrade', Upgrade: 'websocket', 'Sec-WebSocket-Key': 'dGhlIHNhbXBsZSBub25jZQ==', 'Sec-WebSocket-Version': '13' },
      });
      req.on('upgrade', (res, socket) => {
        socket.destroy();
        resolve({ who: res.headers['x-stub'], url: res.headers['x-stub-url'] });
      });
      req.on('error', reject);
      req.end();
    });

  assert.deepEqual(await upgrade('/_new/'), { who: 'react', url: '/_new/' });
  assert.deepEqual(await upgrade('/$debugHandler'), { who: 'flutter', url: '/$debugHandler' });
});

test('a down upstream gets a readable 502, and the other app keeps working', async () => {
  const dead = http.createServer();
  const deadPort = await listen(dead);
  await new Promise((resolve) => dead.close(resolve));
  const react = stub('react');
  const rp = await listen(react);
  const proxy = createProxy({ config, flutterUrl: `http://127.0.0.1:${deadPort}`, reactUrl: `http://127.0.0.1:${rp}` });
  const pp = await listen(proxy);
  try {
    const flutterDown = await request('/settings', { port: pp });
    assert.equal(flutterDown.status, 502);
    assert.match(flutterDown.body, /flutter app is not reachable/);
    assert.match(flutterDown.body, /FLUTTER_URL/);
    assert.equal((await json('/home', { port: pp })).data.who, 'react');
  } finally {
    proxy.close();
    react.close();
  }
});
