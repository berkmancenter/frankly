// @vitest-environment jsdom
import { matchRoutes } from 'react-router';
import { describe, expect, it } from 'vitest';
import migrated from '../../../migrated-routes.json';
import { shouldHandOff } from '@/app/LegacyFallback';
import { buildRoutes } from '@/app/router';

/** Fill ':param' segments with a sample value. */
const sample = (pattern: string) => pattern.replace(/:[A-Za-z]+/g, 'sample');

/** The deepest matched route; the '*' route means "not ours". */
const lastRoute = (routes: ReturnType<typeof buildRoutes>, path: string) =>
  matchRoutes(routes, path)?.at(-1)?.route;

/** Behind the proxy only the migrated pages are registered, and everything else is handed to Flutter. */
const proxied = buildRoutes({ migratedOnly: true });

describe('router vs migrated-routes.json', () => {
  it.each(migrated.routes)('serves %s', (pattern) => {
    const route = lastRoute(proxied, sample(pattern));
    expect(route, `no route registered for ${pattern}`).toBeDefined();
    expect(route?.path).not.toBe('*');
  });

  // Everything the Flutter app owns today must fall through to the hand-off route.
  it.each([
    '/home',
    '/space/civic-lab/discuss',
    '/space/civic-lab/discuss/t_checkin',
    '/space/civic-lab/discuss/t_checkin/e_live',
    '/space/civic-lab/post/p1',
    '/space/civic-lab/admin/profile',
    '/space/civic-lab/instant',
    '/space/civic-lab/posts/extra',
    '/settings',
    '/newspace',
    '/emailunsubscribe',
    '/somewhere/else',
  ])('hands %s back to Flutter', (path) => {
    expect(lastRoute(proxied, path)?.path).toBe('*');
  });
});

describe('standalone mode (no Flutter next to it)', () => {
  const standalone = buildRoutes({ migratedOnly: false });

  it('serves the migrated pages too', () => {
    for (const pattern of migrated.routes) {
      expect(lastRoute(standalone, sample(pattern))?.path, pattern).not.toBe('*');
    }
  });

  it('shows "not migrated" at "/", since there is no home page', () => {
    const root = lastRoute(standalone, '/');
    expect(root?.index).toBe(true);
    expect(root?.path).not.toBe('*');
  });

  it('shows "not found" instead of reloading for a page Flutter owns', () => {
    expect(lastRoute(standalone, '/settings')?.path).toBe('*');
  });
});

describe('shouldHandOff', () => {
  const now = 1_000_000;
  const prev = (target: string, ago: number) => JSON.stringify({ target, at: now - ago });

  it('hands off the first time', () => {
    expect(shouldHandOff('/settings', null, now)).toBe(true);
  });

  it('refuses to hand the same URL off twice in a row (the edge sent it back)', () => {
    expect(shouldHandOff('/settings', prev('/settings', 800), now)).toBe(false);
  });

  it('hands off again for a different URL, an old attempt, or unreadable state', () => {
    expect(shouldHandOff('/settings', prev('/newspace', 800), now)).toBe(true);
    expect(shouldHandOff('/settings', prev('/settings', 60_000), now)).toBe(true);
    expect(shouldHandOff('/settings', 'not json', now)).toBe(true);
  });
});
