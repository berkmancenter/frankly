import http from 'node:http';
import type { Socket } from 'node:net';
import httpProxy from 'http-proxy';
import { createRouter, type RoutesConfig, type Upstream } from './rules.mjs';

const notRunning = (upstream: string, url: string, hint: string): string =>
  `502: the ${upstream} app is not reachable at ${url}.\n\n${hint}\n`;

const HINTS: Record<Upstream, string> = {
  flutter:
    'Start it with the usual dev flow (./run-dev.sh) and make sure it serves on that address, e.g.\n' +
    '  flutter run -d web-server --web-port 5000 …   or point FLUTTER_URL at wherever it runs.',
  react:
    'Start it with:\n  npm --prefix client/new run dev:proxied\n(or run the proxy with `npm run dev`, which starts it for you).',
};

export interface ProxyOptions {
  config: RoutesConfig;
  flutterUrl: string;
  reactUrl: string;
  log?: (line: string) => void;
  verbose?: boolean;
}

/** Builds (does not start) the proxy server. */
export function createProxy({ config, flutterUrl, reactUrl, log = () => {}, verbose = false }: ProxyOptions): http.Server {
  const route = createRouter(config);
  const targets: Record<Upstream, string> = { flutter: flutterUrl, react: reactUrl };
  const proxy = httpProxy.createProxyServer({ xfwd: true, ws: true });
  // Remembers which upstream a response was routed to, for the 502 page.
  const upstreamOf = new WeakMap<http.ServerResponse, Upstream>();

  // Flutter's dev server (`flutter run`, via dwds) injects a debug-socket URL into the page built
  // from the request's Host header, and the app never starts unless that socket connects to
  // Flutter's *own* address: a handshake that arrives on any other port is ignored.
  // Sending Host: <flutter> makes the page open that one socket straight to Flutter; everything
  // else still goes through here.
  // Both options are needed: Flutter also honors X-Forwarded-Host (the browser's host, which would
  // put the socket back on the proxy), so Flutter gets no X-Forwarded-* headers at all.
  // React keeps the browser's Host: Vite's HMR client derives its URL from the page.
  const upstreamOptions: Record<Upstream, httpProxy.ServerOptions> = {
    flutter: { changeOrigin: true, xfwd: false },
    react: {},
  };

  proxy.on('error', (err: NodeJS.ErrnoException, _req, res) => {
    if (res instanceof http.ServerResponse) {
      const upstream = upstreamOf.get(res);
      log(`✗ ${upstream ?? 'upstream'}: ${err.code ?? err.message}`);
      if (!res.headersSent) res.writeHead(502, { 'content-type': 'text/plain; charset=utf-8' });
      res.end(upstream ? notRunning(upstream, targets[upstream], HINTS[upstream]) : notRunning('upstream', '?', ''));
    } else {
      log(`✗ websocket: ${err.code ?? err.message}`);
      (res as Socket).destroy(); // a WebSocket upgrade: just drop the socket
    }
  });

  const server = http.createServer((req, res) => {
    const method = req.method ?? 'GET';
    const decision = route(method, req.url ?? '/');
    const isDocument = (req.headers.accept ?? '').includes('text/html');
    if (verbose || (isDocument && decision.reason !== 'asset')) {
      const rewritten = decision.path !== req.url ? `  →  ${decision.path}` : '';
      log(`${decision.upstream.padEnd(7)} ${method} ${req.url}${rewritten}`);
    }
    upstreamOf.set(res, decision.upstream);
    res.setHeader('x-frankly-upstream', decision.upstream);
    req.url = decision.path;
    proxy.web(req, res, { target: targets[decision.upstream], ...upstreamOptions[decision.upstream] });
  });

  server.on('upgrade', (req, socket, head) => {
    const decision = route('GET', req.url ?? '/');
    if (verbose) log(`${decision.upstream.padEnd(7)} WS  ${req.url}`);
    req.url = decision.path;
    socket.on('error', () => {});
    proxy.ws(req, socket, head, { target: targets[decision.upstream], ...upstreamOptions[decision.upstream] });
  });

  server.on('close', () => proxy.close());
  return server;
}
