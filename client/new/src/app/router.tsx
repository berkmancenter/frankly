import { createBrowserRouter, type RouteObject } from "react-router";
import migrated from "../../migrated-routes.json";
import { CommunityHome } from "@/features/community/CommunityHome";
import { EventsPage } from "@/features/events/EventsPage";
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

/**
 * Every page built so far, keyed by its full URL pattern. They all live under a community
 * (`/space/:displayId`). Behind the dev proxy / at the edge only the patterns listed in
 * `migrated-routes.json` are served from here; every other URL belongs to Flutter.
 *
 * Migrating another page: build it, add an entry here (pages outside a community go in the
 * top-level `children` below), then add its pattern to the JSON.
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

const known = new Set(COMMUNITY_PAGES.map((e) => e.pattern));
const unknown = migrated.routes.filter((p) => !known.has(p));
if (unknown.length > 0) {
  throw new Error(
    `migrated-routes.json lists patterns the router has no page for: ${unknown.join(", ")}`,
  );
}

const NOT_MIGRATED =
  "This page is not in the React app yet. Behind the dev proxy, Flutter serves it.";

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
  const registered = COMMUNITY_PAGES.filter(
    (e) => !migratedOnly || enabled.has(e.pattern),
  ).map((e) => e.route);

  return [
    {
      element: <RootLayout />,
      errorElement: <NotFoundPage />,
      children: [
        ...(migratedOnly
          ? []
          : [
              { index: true, element: <NotFoundPage message={NOT_MIGRATED} /> },
            ]),
        {
          path: "space/:displayId",
          element: <CommunityLayout />,
          children: registered,
        },
        // Anything not served here (including client-side navigations to it) is Flutter's: do a
        // real page load so the edge / proxy serves it from the right app. Standalone there is no
        // Flutter to hand it to.
        {
          path: "*",
          element: migratedOnly ? (
            <LegacyFallback />
          ) : (
            <NotFoundPage message={NOT_MIGRATED} />
          ),
        },
      ],
    },
  ];
}

/** The proxied build serves assets under a sub-path (`PROXIED=1` in vite.config.ts); standalone uses "/". */
const proxied = import.meta.env.BASE_URL !== "/";

export const routes = buildRoutes({ migratedOnly: proxied });

export const createAppRouter = () => createBrowserRouter(routes);
