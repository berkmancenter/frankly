# Frankly web client — React, migrated route by route

A React + TypeScript client that incrementally takes over pages from the Flutter client in [`../`](..) one route at
a time.

It owns only the pages listed in [`migrated-routes.json`](migrated-routes.json); every other URL
falls back to Flutter:

| URL                                  | Page                                                               | Entry                                  |
| ------------------------------------ | ------------------------------------------------------------------ | -------------------------------------- |
| `/`                                  | Sign-in / sign-up form, or the signed-in user's communities        | `features/home/HomePage.tsx`           |
| `/space/:displayId`                  | Community home: hero, about, contact/share/follow, upcoming events | `features/community/CommunityHome.tsx` |
| `/space/:displayId/posts`            | Posts                                                              | `features/posts/PostsPage.tsx`         |
| `/space/:displayId/resources`        | Resources                                                          | `features/resources/ResourcesPage.tsx` |
| `/space/:displayId/discuss/upcoming` | Events listing                                                     | `features/events/EventsPage.tsx`       |

Links from these pages to anything else (templates, an event, a post, settings, the home page,
admin…) are real page loads, so the proxy / hosting rewrites serve them from Flutter
(`app/LegacyFallback.tsx`).

| Concern                   | Choice                                                                              |
| ------------------------- | ----------------------------------------------------------------------------------- |
| UI                        | React 19, MUI (`@mui/material` 9) minimal theme, Inter                   |
| Server state              | TanStack Query v5                                                                   |
| Connection, media, outbox | XState v5 machines (`src/machines`), not wired to a page yet                        |
| UI state                  | React local state (`useState` / `useReducer`)                                       |
| Routing                   | React Router 7 (library mode) — the URL is the source of truth for navigation state |
| Tooling                   | Vite 6, TypeScript 5.9 (`strict`), Vitest                                           |

**No global store.** There is no Redux/Zustand/Jotai/module-level mutable state. See
[State model](#state-model).

## Run it

```bash
cd client/new
npm install
npm run dev          # http://localhost:5173 — standalone; "/" is the sign-in page or your communities
npm test             # machines + router ↔ migrated-routes.json
npm run typecheck    # tsc, strict + noUnused*
npm run build        # tsc + vite build
```

**Next to the Flutter app:** `npm run dev:proxied` / `npm run build:proxied` serve the assets under
`/_new/` and register only the pages in [`migrated-routes.json`](migrated-routes.json); everything
else is handed back to Flutter. Run it through [`dev-proxy`](../../dev-proxy/README.md) (one origin,
path-based routing). Standalone there is no Flutter, so a page that is not migrated just says so.

Needs Node ≥ 26.13. Tooling is pinned to majors that run there (Vite 6, React Router 7,
TypeScript 5.9, Vitest 3); the newest majors need a newer Node (Vite 8 ≥ 20.19, Vitest 5 ≥ 22.12,
React Router 8 ≥ 22.22), so bumping them is a Node upgrade, not a code change.

## Moving another page to React

1. Build the page under `src/features/…` and add its entry to `COMMUNITY_PAGES` in
   `src/app/router.tsx` (a page outside a community goes in the top-level `children` there).
2. Add the data-surface `Api` methods it needs to `src/api/api.ts` and the implementation in `src/api/firebaseApi.ts`.
3. When it should go live behind the proxy / at the edge, add its URL pattern to
   `migrated-routes.json`. The router test checks the two agree.

## State model

This model is _scoped, parameterized, auto-disposed state_. Concretely:

| Kind of state                                                               | Lives in                                                                                   | Scoped by                         | Disposed when                   |
| --------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------ | --------------------------------- | ------------------------------- |
| Anything the server owns (communities, events, templates, posts, resources) | **TanStack Query** cache, keys from `queries/keys.ts`                                      | query key = the ids it depends on | unobserved for `gcTime` (5 min) |
| "Current community"                                                         | `<CommunityScope displayId>`: joins queries + derives permissions, exposes them by context | route params                      | route unmounts                  |
| Navigation state (`?initialSection=…`, …)                                   | the URL                                                                                    | —                                 | —                               |
| Dialogs, drawers, forms, panels                                             | `useState` in the component that owns them                                                 | component                         | component unmounts              |
| Connection, outbox, local media                                             | **XState** machines in `src/machines` (see below)                                          | the scope that creates them       | scope unmounts → actors stop    |

Rules of thumb that fall out of this:

1. **The server owns it → a query.** Realtime doesn't change that: a socket's only job is to write
   into the query cache. Components read `useQuery` hooks and can't tell whether a value was
   fetched or pushed.
2. **Writes go over HTTP, reads come over the socket.** HTTP writes are idempotent (client-generated
   key), which is what makes retries safe.
3. **Request/response the user is waiting on → `useMutation`** (create event, add resource).
   **Fire-and-forget interactions the UI should show as sent → the outbox.** Optimistic cheap toggles
   with an on-screen result use `useMutation` + an optimistic cache update (post likes/reactions).
4. **A machine is created by a scope, with `input`, and nothing else can reach it.** Stopping the
   scope stops the machine, which stops its invoked children — sockets and `MediaStream`s are
   released by _actor lifetime_, not by remembering to clean up.
5. **No imperative dialog stack.** A component that can open a dialog owns it (`useCreateEventDialog()`
   returns `{ open, dialog }`; `useConfirm()` returns `{ confirm, dialog }`). It exists only while open.
6. **Infrastructure is not state.** `QueryClient`, the injected `Api`, the MUI theme, the toast
   service and the router are created once at the root (`app/App.tsx`).

### The three machines (`src/machines`)

No page uses them yet; they stay, with their tests, for the live meeting once we implemetnt. I included them as a proof of concept.

```
connection   idle ─CONNECT→ active[connecting → connected] ─closed→ backoff ─→ active …
                                                 backoff ─(attempts exhausted)→ failed ─RETRY_NOW→ active
             the socket is an invoked callback actor; `emit` publishes messages / opened / closed

outbox       idle ─(gate open ∧ queued)→ sending ─ok→ idle            FIFO, one at a time
                                          ├─transient error→ backoff → idle
                                          └─permanent / too many attempts→ item `failed` (user retries/discards)
             `gate` = "connection is open"; items are plain JSON → persisted, rehydrated, idempotent

media        idle ─START→ requesting ─ok→ ready ─SELECT_*→ requesting (re-acquire)
                              └─error→ failed ─RETRY→ requesting │ ─SKIP→ unavailable
             `ready` invokes trackGuard / levelMeter / deviceWatcher; `simulate` runs without hardware
```

They are unit-tested in `src/machines/__tests__`. They talk to the world through
`api/realtime.ts` (`RealtimeTransport`, `ServerMessage`) and an injectable `MediaSource`, so they
have no SDK dependency. To wire one into React, add `@xstate/react` (removed with the scopes that used
it) and create the actor in a scope component. One gotcha from the first wiring: `@xstate/react`
restarts the _same_ actor under StrictMode, so a `getUserMedia` call from the discarded run must
release its stream and **never settle** (otherwise its `AbortError` looks like the live run's answer
and the machine lands in `failed`).

## Layout

```
src/
  api/              the seam to the backend
    api.ts            `Api` interface (the HTTP surface Fastify will implement), only what the pages call
    realtime.ts       `RealtimeTransport` + `ServerMessage` (the socket protocol the connection machine speaks)
    auth.ts           `AuthService` + `AuthSession` (Firebase-free interface; Flutter's `UserService`)
    firebaseAuthService.ts  its Firebase implementation (anonymous sign-in, returning-user flag, public profile)
    ApiProvider.tsx   dependency injection (a context, not state): `useApi()`, `useAuthService()`

  queries/          query keys + `queryOptions` + hooks, grouped by domain
  machines/         connection / outbox / media + retry policy (+ tests)
  scopes/           CommunityScope
  components/       shared UI (ActionButton, dialogs, avatars…) and shell/ (nav, sidebar, scaffold)
  features/         auth, community, events, posts, resources, profile drawer, not-found
  app/              router, route layouts, typed path builders, hand-off to Flutter
  theme/            tokens.ts (typed colors, font sizes, layout sizes) + a small MUI theme
  lib/              clock, formatting, permissions, responsive hook, placeholders…
```

## Flutter → React map

| Flutter                                                | Here                                                                                |
| ------------------------------------------------------ | ----------------------------------------------------------------------------------- |
| `Provider` / `ChangeNotifier` (`CommunityProvider`, …) | scope components + TanStack Query hooks                                             |
| `CommunityPermissionsProvider`                         | `lib/permissions.ts` (pure functions; only the permissions the migrated pages read) |
| Firestore streams / `CustomStreamBuilder`              | `useQuery`                                                                          |
| `NavBarProvider`                                       | derived from route + `CommunityScope`                                               |
| `dialogProvider`, `showCustomDialog`                   | dialogs owned by their opener (`useConfirm`, `useCreateEventDialog`)                |
| Beamer locations (`locations.dart`)                    | `app/router.tsx` + `app/paths.ts` (same URLs)                                       |
| `clockService.now()`                                   | `useClock()` (see `lib/clock.ts`); elapsed time uses plain deltas                   |
| `ResponsiveLayoutService` (breakpoint 1000 px)         | `useIsMobile()`                                                                     |
| `CustomScaffold`                                       | `AppScaffold` (+ `ScaffoldFab` portal slot)                                         |

## Auth

Port of `client/lib/features/auth`. Every visitor has a Firebase user: someone without an account is
signed in anonymously, and "signing in" replaces that user with a registered one. Flutter and React
share the session when the visitor moves between them (same origin, same Firebase persistence; in
emulator mode both keep it in `sessionStorage`), and the "returning visitor" flag lives in
`localStorage["flutter.is-returning-user"]` so both apps agree on it.

- `AuthService` (`api/auth.ts`) is injected next to `Api`; read the session with `useAuthSession()`
  (`useSyncExternalStore`, no store of our own). `RootLayout` waits for it and drops the query cache
  when the user changes.
- `features/auth`: `SignInForm` (email/password, Google, reset password), `AccountErrorMessage`,
  `SignInDialog` + `useSignInDialog()` (the opener owns the dialog), `useGuardSignedIn()` (Flutter's
  `guardSignedIn`), `SignInButtons` (shown by `ProfileMenu` to visitors without an account).
- Strings use the Flutter ARB keys as ids (`<Trans id="signIn">`), so the existing translations apply.
- Branding comes from `VITE_APP_NAME`, `VITE_SUPPORT_EMAIL`, `VITE_TERMS_URL` (`utils/appInfo.ts`).
- Not ported yet: the verify-email page and its gate, handling of the `?mode=verifyEmail&oobCode=` link.

## Theme

Deliberately minimal. `@mui/material` implements Material 2, so we do not try to reproduce Flutter's
Material 3 theme one-to-one.

- `src/theme/tokens.ts`: typed constants `colors` (the Flutter `ColorScheme` roles the pages
  use, by the same names), `fontSizes` and `appSize`. Use them directly:
  `sx={{ color: colors.onSurfaceVariant, fontSize: fontSizes.sm }}`. A typo is a compile error.
  Add a color when a page needs one.
- `src/theme/theme.ts`: the font, palette `primary` / `secondary` (the only two colors a community
  changes), and a handful of component defaults. No type scale, no module augmentation.
- Headings are handled by hand: Flutter has no `h1`, so pick a size and, where it matters, a
  semantic element (`<Typography component="h2" sx={{ fontSize: fontSizes["2xl"] }}>`).
- Community colors: a nested `ThemeProvider` over the page content only, built by
  `createAppTheme(communityColors(community))`. Use `'primary.main'` / `'secondary.main'` for the
  two themable colors and `colors.*` for everything else.

## Not here (on purpose)

- Every page Flutter still owns: home, new space, settings, templates, the event page and live
  meeting, a single post, admin, instant events. Links to them hand off to Flutter.
- Auth/sign-in/sign-up, billing, donations, email delivery, localization (English only).
- Creating a community or a template, language selection: the sidebar and the create-event dialog
  link to the Flutter pages for those.
