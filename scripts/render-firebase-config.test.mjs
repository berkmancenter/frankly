import assert from 'node:assert/strict';
import { execFileSync } from 'node:child_process';
import { mkdtempSync, readFileSync, rmSync, writeFileSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { join, resolve } from 'node:path';
import { test } from 'node:test';

const scriptPath = resolve('scripts/render-firebase-config.mjs');

function runRenderer(input, region) {
  const directory = mkdtempSync(join(tmpdir(), 'frankly-render-config-'));
  const inputPath = join(directory, 'firebase.json');
  const outputPath = join(directory, 'firebase.generated.json');

  try {
    writeFileSync(inputPath, JSON.stringify(input));
    execFileSync(
      process.execPath,
      [scriptPath, '--input', inputPath, '--output', outputPath, '--region', region],
      { stdio: 'pipe' },
    );
    return JSON.parse(readFileSync(outputPath, 'utf8'));
  } finally {
    rmSync(directory, { recursive: true, force: true });
  }
}

test('renders regional targets for every function-backed Hosting rewrite', () => {
  const rendered = runRenderer(
    {
      hosting: {
        rewrites: [
          { source: '/share/**', function: 'ShareLink' },
          { source: '/space/*/ics', function: 'CalendarFeedIcs' },
          { source: '/space/*/rss', function: 'CalendarFeedRss' },
          { source: '/api/createEvent', function: 'createEvent' },
          { source: '**', function: 'ServeIndex' },
          { source: '/static/**', destination: '/index.html' },
        ],
      },
    },
    '  europe-west1  ',
  );

  const functions = rendered.hosting.rewrites.slice(0, 5).map((rewrite) => rewrite.function);
  assert.deepEqual(functions, [
    { functionId: 'ShareLink', region: 'europe-west1' },
    { functionId: 'CalendarFeedIcs', region: 'europe-west1' },
    { functionId: 'CalendarFeedRss', region: 'europe-west1' },
    { functionId: 'createEvent', region: 'europe-west1' },
    { functionId: 'ServeIndex', region: 'europe-west1' },
  ]);
  assert.deepEqual(rendered.hosting.rewrites[5], {
    source: '/static/**',
    destination: '/index.html',
  });
});

test('uses us-central1 when the supplied region is blank', () => {
  const rendered = runRenderer(
    { hosting: { rewrites: [{ source: '**', function: 'ServeIndex' }] } },
    '   ',
  );

  assert.deepEqual(rendered.hosting.rewrites[0].function, {
    functionId: 'ServeIndex',
    region: 'us-central1',
  });
});

test('re-renders an already regional rewrite with the new region', () => {
  const rendered = runRenderer(
    {
      hosting: {
        rewrites: [
          { source: '**', function: { functionId: 'ServeIndex', region: 'us-central1' } },
        ],
      },
    },
    'europe-west1',
  );

  assert.deepEqual(rendered.hosting.rewrites[0].function, {
    functionId: 'ServeIndex',
    region: 'europe-west1',
  });
});

test('renders the checked-in firebase.json without dropping any rewrite', () => {
  const source = JSON.parse(readFileSync(resolve('firebase.json'), 'utf8'));
  const rendered = runRenderer(source, 'europe-west1');

  assert.equal(rendered.hosting.rewrites.length, source.hosting.rewrites.length);
  for (const [index, rewrite] of source.hosting.rewrites.entries()) {
    if (rewrite.function) {
      assert.deepEqual(rendered.hosting.rewrites[index].function, {
        functionId: rewrite.function,
        region: 'europe-west1',
      });
    } else {
      assert.deepEqual(rendered.hosting.rewrites[index], rewrite);
    }
  }
});
