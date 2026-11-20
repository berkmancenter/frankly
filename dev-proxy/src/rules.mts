import { readFileSync } from 'node:fs';

/**
 * Path rules: which app serves which URL. Pure functions, no I/O beyond reading the config, so
 * they can be tested exhaustively and later reused to generate `firebase.json` rewrites.
 *
 * The rules come from `client/new/migrated-routes.json`, the same file the React router reads:
 *
 *   assetBase        everything under it is React's (Vite's module graph, HMR socket, chunks)
 *   staticPrefixes   public files the React app references by absolute URL (e.g. /media/…);
 *                    they live under `assetBase` on disk and are mapped there
 *   routes           page URL patterns React owns (':name' = one non-empty segment, exact match)
 *
 * Everything else, including every non-GET request, belongs to Flutter.
 */

export type Upstream = 'react' | 'flutter';

export interface RoutesConfig {
  assetBase: string;
  staticPrefixes: string[];
  routes: string[];
}

export interface RouteDecision {
  upstream: Upstream;
  /** What to request from the chosen upstream, including the query string. */
  path: string;
  reason: 'asset' | 'static' | 'page' | 'fallback';
}

export type Router = (method: string, url: string) => RouteDecision;

export function loadConfig(path: string): RoutesConfig {
  const config = JSON.parse(readFileSync(path, 'utf8')) as Partial<RoutesConfig>;
  const { assetBase } = config;
  if (typeof assetBase !== 'string' || !assetBase.startsWith('/') || !assetBase.endsWith('/')) {
    throw new Error(`${path}: "assetBase" must start and end with "/" (got ${JSON.stringify(assetBase)})`);
  }
  const { staticPrefixes, routes } = config;
  if (!Array.isArray(staticPrefixes)) throw new Error(`${path}: "staticPrefixes" must be an array`);
  if (!Array.isArray(routes)) throw new Error(`${path}: "routes" must be an array`);
  return { assetBase, staticPrefixes, routes };
}

const escapeRegExp = (s: string): string => s.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');

/** '/space/:displayId/posts' → /^\/space\/[^/]+\/posts\/?$/ */
export function compilePattern(pattern: string): RegExp {
  if (!pattern.startsWith('/')) throw new Error(`Route pattern must start with "/": ${pattern}`);
  const body = pattern
    .split('/')
    .filter(Boolean)
    .map((segment) => (segment.startsWith(':') ? '[^/]+' : escapeRegExp(segment)))
    .join('/');
  return new RegExp(`^/${body}/?$`);
}

const PAGE_METHODS = new Set(['GET', 'HEAD']);

export function createRouter(config: RoutesConfig): Router {
  const pages = config.routes.map(compilePattern);

  return function route(method, url) {
    // Split by hand: `new URL('//x', base)` would read "//x" as a host, and we want Flutter's
    // requests forwarded exactly as received.
    const q = url.indexOf('?');
    const pathname = q === -1 ? url : url.slice(0, q);
    const search = q === -1 ? '' : url.slice(q);

    if (pathname.startsWith(config.assetBase)) {
      return { upstream: 'react', path: pathname + search, reason: 'asset' };
    }

    if (config.staticPrefixes.some((prefix) => pathname.startsWith(prefix))) {
      // Vite serves `public/` under its base, so /media/x.png is /_new/media/x.png upstream.
      return { upstream: 'react', path: config.assetBase + pathname.slice(1) + search, reason: 'static' };
    }

    if (PAGE_METHODS.has(method.toUpperCase()) && pages.some((re) => re.test(pathname))) {
      // The browser keeps the real URL; React gets its HTML shell and routes client-side.
      return { upstream: 'react', path: config.assetBase + search, reason: 'page' };
    }

    return { upstream: 'flutter', path: url, reason: 'fallback' };
  };
}
