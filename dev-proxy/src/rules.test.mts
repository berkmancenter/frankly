import assert from 'node:assert/strict';
import { test } from 'node:test';
import { fileURLToPath } from 'node:url';
import { fixtureConfig } from './fixture.mjs';
import { compilePattern, createRouter, loadConfig } from './rules.mjs';

const route = createRouter(fixtureConfig);

const expectReact = (method: string, url: string, path: string, reason: string): void => {
  assert.deepEqual(route(method, url), { upstream: 'react', path, reason }, `${method} ${url}`);
};
const expectFlutter = (method: string, url: string): void => {
  assert.deepEqual(route(method, url), { upstream: 'flutter', path: url, reason: 'fallback' }, `${method} ${url}`);
};

test('the pages in the route table go to React, which gets its HTML shell', () => {
  expectReact('GET', '/home', '/_new/', 'page');
  expectReact('GET', '/space/civic-lab', '/_new/', 'page');
  expectReact('GET', '/space/civic-lab/posts', '/_new/', 'page');
  expectReact('GET', '/space/civic-lab/resources', '/_new/', 'page');
  expectReact('GET', '/space/civic-lab/discuss/upcoming', '/_new/', 'page');
});

test('trailing slashes and query strings are fine, and the query is preserved', () => {
  expectReact('GET', '/home/', '/_new/', 'page');
  expectReact('GET', '/space/civic-lab/?utm=1&x=2', '/_new/?utm=1&x=2', 'page');
  expectReact('HEAD', '/home', '/_new/', 'page');
});

test('every other page falls back to Flutter, untouched', () => {
  for (const url of [
    '/',
    '/settings',
    '/newspace',
    '/emailunsubscribe',
    '/space/civic-lab/discuss',
    '/space/civic-lab/discuss/t_checkin',
    '/space/civic-lab/discuss/t_checkin/e_live?status=joined',
    '/space/civic-lab/post/abc123',
    '/space/civic-lab/admin',
    '/space/civic-lab/admin/profile',
    '/space/civic-lab/instant?meetingId=m1',
    '/share/abc',
    '/space/civic-lab/ics',
    '/api/GetMembersData',
    '/main.dart.js',
    '/assets/AssetManifest.json',
    '//double-slash',
  ]) {
    expectFlutter('GET', url);
  }
});

test('matching is exact: no sub-paths, no empty segments, no look-alikes', () => {
  expectFlutter('GET', '/space/civic-lab/posts/extra');
  expectFlutter('GET', '/space//posts');
  expectFlutter('GET', '/homepage');
  expectFlutter('GET', '/home/extra');
  expectFlutter('GET', '/space/civic-lab/posts.js');
});

test('a community id may collide with a section name: /space/posts is the community "posts"', () => {
  expectReact('GET', '/space/posts', '/_new/', 'page');
  expectReact('GET', '/space/posts/posts', '/_new/', 'page');
});

test('only GET and HEAD navigations go to React; writes to the same URLs stay with Flutter', () => {
  expectFlutter('POST', '/home');
  expectFlutter('PUT', '/space/civic-lab/posts');
  expectFlutter('DELETE', '/space/civic-lab');
});

test('React asset URLs pass through unchanged, for any method', () => {
  expectReact('GET', '/_new/src/main.tsx?t=123', '/_new/src/main.tsx?t=123', 'asset');
  expectReact('GET', '/_new/@vite/client', '/_new/@vite/client', 'asset');
  expectReact('GET', '/_new/', '/_new/', 'asset');
  expectReact('POST', '/_new/__vite_ping', '/_new/__vite_ping', 'asset');
});

test('absolute /media/ URLs are mapped to where Vite serves its public dir', () => {
  expectReact('GET', '/media/like.png', '/_new/media/like.png', 'static');
  expectReact('GET', '/media/sub/dir/x.png?v=1', '/_new/media/sub/dir/x.png?v=1', 'static');
});

test('a pattern with ":param" matches exactly one segment', () => {
  const re = compilePattern('/space/:id/posts');
  assert.ok(re.test('/space/a/posts'));
  assert.ok(re.test('/space/a/posts/'));
  assert.ok(!re.test('/space/a/b/posts'));
  assert.ok(!re.test('/space//posts'));
});

test('regex metacharacters in a pattern are literal', () => {
  const re = compilePattern('/a.b/:x');
  assert.ok(re.test('/a.b/c'));
  assert.ok(!re.test('/aXb/c'));
});

test('bad config is rejected with a useful message', () => {
  assert.throws(() => compilePattern('home'), /must start with "\/"/);
});

test('the real migrated-routes.json loads, and every pattern in it is served by React', () => {
  // Compiled tests run from `dist/`, one level below the dev-proxy folder.
  const live = loadConfig(fileURLToPath(new URL('../../client/new/migrated-routes.json', import.meta.url)));
  const liveRoute = createRouter(live);
  assert.ok(live.routes.length > 0);
  for (const pattern of live.routes) {
    const sample = pattern.replace(/:[A-Za-z]+/g, 'sample');
    assert.equal(liveRoute('GET', sample).upstream, 'react', pattern);
  }
  // Anything not listed stays with Flutter.
  assert.equal(liveRoute('GET', '/definitely/not/migrated').upstream, 'flutter');
});
