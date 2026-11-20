# dev-proxy

One local origin for both frontends while the client moves from Flutter to React.

```
browser ──► http://localhost:3000 ──┬─► React  (client/new, Vite)   the pages listed in migrated-routes.json
                                    └─► Flutter (flutter run)       everything else
```

The same decision will be made at the edge in production (Firebase Hosting rewrites), so what you
see locally is what the routing rules mean there.

## What React owns today

Defined in one file, [`client/new/migrated-routes.json`](../client/new/migrated-routes.json), read by
the proxy **and** by the React router:

| URL                                  | Page           |
| ------------------------------------ | -------------- |
| `/space/:displayId`                  | Community home |
| `/space/:displayId/posts`            | Posts          |
| `/space/:displayId/resources`        | Resources      |
| `/space/:displayId/discuss/upcoming` | Events listing |

Everything else (`/`, `/home`, `/settings`, `/space/x/discuss`, event pages, admin, posts detail, `/share/…`,
`/api/…`, Flutter's own assets) goes to Flutter. Only `GET`/`HEAD` page loads go to React; writes to
the same URLs stay with Flutter.

React's own files live under `/_new/` (module graph, HMR socket, chunks) and the images it
references as `/media/…` are mapped to `/_new/media/…`; that prefix is how the proxy tells the two
apps' files apart.

## Run it

2. **Proxy + Flutter + React**, from the repo root:

   ```bash
   npm i
   npm run dev:proxy
   ```

   This concurrently runs `./run-dev.sh`, and then the proxy server waits for the Flutter port to become available, then launches the React app and proxy server.

3. Open **http://localhost:3000** (not Flutter or React's own port).

| Env var       | Default                 |                                                                     |
| ------------- | ----------------------- | ------------------------------------------------------------------- |
| `PORT`        | `3000`                  | proxy port (not 4000: that is the Firebase emulator UI)             |
| `FLUTTER_URL` | `http://localhost:5000` | where `flutter run` serves                                          |
| `REACT_URL`   | `http://localhost:5173` | where the React dev server serves; `run dev` starts it on this port |
| `VERBOSE`     | off                     | `1` logs every request, not just page navigations                   |

The proxy is TypeScript (`src/*.mts`). `start`, `dev` and `test` compile it to `dist/*.mjs` with
`tsc` first and then run the output, so there is nothing to build by hand; `npm run typecheck`
checks types without emitting.

`npm --prefix dev-proxy start` runs the proxy alone (start React yourself with
`npm --prefix client/new run dev:proxied`). Every response carries an `x-frankly-upstream:
react|flutter` header, handy in devtools.

If an app is not running you get a `502` page naming it and how to start it; the other app keeps
working.

## How React hands a URL back to Flutter

Inside React, a link or `navigate()` to a page it does not own (say Templates → `/space/x/discuss`)
reaches the router's catch-all, which does a real page load of that URL; the proxy then serves it from
Flutter. A guard stops a reload loop if the same URL comes straight back (`LegacyFallback.tsx`).

## Flutter's debug socket bypasses the proxy (on purpose)

`flutter run` injects a debug-socket URL (`ws://…/$dwdsSseHandler`) into the page, built from the
request's `Host` / `X-Forwarded-Host`. The app only starts if that socket connects to Flutter's
own address; a handshake arriving on any other port is ignored, even through a plain TCP pipe
(symptom: `#flutter-container` stays empty). So the proxy sends Flutter its own `Host` and no
`X-Forwarded-*` headers, and the page opens that one socket straight to `FLUTTER_URL`. Everything
else, including hot reload's HTTP traffic, still goes through the proxy. Consequence: `FLUTTER_URL`
must be an address the browser can reach.

## Limits to know about

- **Only page loads are routed.** Typing a URL, refreshing, deep links and links from outside go through
  the proxy. Navigation _inside Flutter_ (e.g. Flutter's own link to a community's Posts page) stays inside Flutter. To
  make Flutter send users to React for migrated pages it needs a redirect hook (not done yet).
- **Standalone `npm run dev` in `client/new`** currently has no authenticated session, Flutter has to run in parallel since that is still where the current local session is instantiated. I considered generating a fake user for this scenario, but I think we can move over the authentication page to the new React fairly rapidly.

## Tests

```bash
npm --prefix dev-proxy test         # builds, then runs the routing rules + the proxy against stub upstreams (incl. WebSocket)
npm --prefix client/new test        # includes: router and migrated-routes.json agree
```
