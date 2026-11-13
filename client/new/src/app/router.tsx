import { i18n } from "@lingui/core";
import { msg } from "@lingui/core/macro";
import { createBrowserRouter, type RouteObject } from "react-router";
import migrated from "../../migrated-routes.json";
import { CommunityHome } from "@/features/community/CommunityHome";
import { EventsPage } from "@/features/events/EventsPage";
import { HomePage } from "@/features/home/HomePage";
import { NotFoundPage } from "@/features/NotFoundPage";
import {
  CommunityLayout,
  type CommunityRouteHandle,
} from "./layouts/CommunityLayout";
import { RootLayout } from "./layouts/RootLayout";
import { LegacyFallback } from "./LegacyFallback";

const handle = (h: CommunityRouteHandle) => h;

/**
 * Route-level code splitting: pages most visitors never open load on demand. React Router calls
 * `lazy` when the route is about to match, so navigation waits for the chunk instead of flashing
 * an empty page.
 */
const page =
  <M extends Record<string, unknown>>(load: () => Promise<M>, name: keyof M) =>
  async () => ({ Component: (await load())[name] as React.ComponentType });

interface Entry {
  /** Full URL pattern, exactly as listed in `migrated-routes.json`. */
  pattern: string;
  route: RouteObject;
}

/** Pages outside a community. They are children of the root layout, next to `/space/:displayId`. */
const TOP_LEVEL_PAGES: Entry[] = [
  { pattern: "/", route: { index: true, element: <HomePage /> } },
];

/**
 * Every page built inside a community (`/space/:displayId`), keyed by its full URL pattern. Behind the dev proxy / at the edge only the patterns listed in
 * `migrated-routes.json` are served from here; every other URL belongs to Flutter.
 *
 * Migrating another page: build it, add an entry here (or to `TOP_LEVEL_PAGES` if it is outside
 * a community), then add its pattern to the JSON.
 */
const COMMUNITY_PAGES: Entry[] = [
  {
    pattern: "/space/:displayId",
    route: {
      index: true,
      element: <CommunityHome />,
      handle: handle({ createEventFab: true }),
    },
  },
  {
    pattern: "/space/:displayId/resources",
    route: {
      path: "resources",
      lazy: page(
        () => import("@/features/resources/ResourcesPage"),
        "ResourcesPage",
      ),
    },
  },
  {
    pattern: "/space/:displayId/posts",
    route: {
      path: "posts",
      lazy: page(() => import("@/features/posts/PostsPage"), "PostsPage"),
    },
  },
  {
    pattern: "/space/:displayId/discuss/upcoming",
    route: {
      path: "discuss/upcoming",
      element: <EventsPage />,
      handle: handle({ createEventFab: true }),
    },
  },
];

const known = new Set(
  [...TOP_LEVEL_PAGES, ...COMMUNITY_PAGES].map((e) => e.pattern),
);
const unknown = migrated.routes.filter((p) => !known.has(p));
if (unknown.length > 0) {
  throw new Error(
    `migrated-routes.json lists patterns the router has no page for: ${unknown.join(", ")}`,
  );
}

const NOT_MIGRATED = msg`This page is not in the React app yet. Soon, this would fall back to the Flutter app.`;

// Resolves `NOT_MIGRATED` on every render rather than once at import time, so it tracks locale changes.
function NotMigratedPage() {
  return <NotFoundPage message={i18n._(NOT_MIGRATED)} />;
}

/**
 * `migratedOnly: true`  — behind the proxy / at the edge: register only the patterns in
 *   `migrated-routes.json`; any other URL is handed back to Flutter.
 * `migratedOnly: false` — standalone (`npm run dev`): there is no Flutter next to us, so register
 *   every page built (even ones not yet in the JSON) and show "not found" for the rest.
 */
export function buildRoutes({
  migratedOnly,
}: {
  migratedOnly: boolean;
}): RouteObject[] {
  const enabled = new Set(migrated.routes);
  const registered = (entries: Entry[]) =>
    entries
      .filter((e) => !migratedOnly || enabled.has(e.pattern))
      .map((e) => e.route);

  return [
    {
      element: <RootLayout />,
      errorElement: <NotFoundPage />,
      children: [
        ...registered(TOP_LEVEL_PAGES),
        {
          path: "space/:displayId",
          element: <CommunityLayout />,
          children: registered(COMMUNITY_PAGES),
        },
        // Anything not served here (including client-side navigations to it) is Flutter's: do a
        // real page load so the edge / proxy serves it from the right app. Standalone there is no
        // Flutter to hand it to.
        {
          path: "*",
          element: migratedOnly ? <LegacyFallback /> : <NotMigratedPage />,
        },
      ],
    },
  ];
}

/** The proxied build serves assets under a sub-path (`PROXIED=1` in vite.config.ts); standalone uses "/". */
const proxied = import.meta.env.BASE_URL !== "/";

export const routes = buildRoutes({ migratedOnly: proxied });

export const createAppRouter = () => createBrowserRouter(routes);
