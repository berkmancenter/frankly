import type { RoutesConfig } from './rules.mjs';

/**
 * A fixed route table for the tests. They deliberately do not read `client/new/migrated-routes.json`,
 * which changes every time a page migrates; `rules.test.mts` has one test that loads the real file.
 * `/home` is in here only so the tests cover a page outside a community.
 */
export const fixtureConfig: RoutesConfig = {
  assetBase: '/_new/',
  staticPrefixes: ['/media/'],
  routes: [
    '/home',
    '/space/:displayId',
    '/space/:displayId/posts',
    '/space/:displayId/resources',
    '/space/:displayId/discuss/upcoming',
  ],
};
