import assert from 'node:assert/strict';
import { execFileSync } from 'node:child_process';
import { mkdtempSync, rmSync, writeFileSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { join, resolve } from 'node:path';
import { test } from 'node:test';

import {
  parseDartDefines,
  regionOfFunctionsUrlPrefix,
  validateClientConfig,
} from './validate-client-config.mjs';

const appId = '0123456789abcdef0123456789abcdef';
const scriptPath = resolve('scripts/validate-client-config.mjs');

test('parses .env lines, quotes and comments', () => {
  assert.deepEqual(
    parseDartDefines(
      '# comment\nAGORA_APP_ID="abc"\nFUNCTIONS_REGION = europe-west1 # trailing note\n\nnot a line',
    ),
    { AGORA_APP_ID: 'abc', FUNCTIONS_REGION: 'europe-west1' },
  );
  assert.deepEqual(parseDartDefines('{"AGORA_APP_ID":"x"}', 'defines.json'), {
    AGORA_APP_ID: 'x',
  });
});

test('rejects a missing or malformed AGORA_APP_ID', () => {
  assert.equal(validateClientConfig({}).length, 1);
  assert.equal(validateClientConfig({ AGORA_APP_ID: 'not-an-id' }).length, 1);
  assert.deepEqual(validateClientConfig({ AGORA_APP_ID: appId }), []);
});

test('reads the region from standard Functions URL prefixes', () => {
  assert.equal(
    regionOfFunctionsUrlPrefix('https://europe-west1-my-project.cloudfunctions.net'),
    'europe-west1',
  );
  assert.equal(regionOfFunctionsUrlPrefix('http://127.0.0.1:5001/dev/us-central1'), 'us-central1');
  assert.equal(regionOfFunctionsUrlPrefix('https://functions.example.org'), null);
  assert.equal(regionOfFunctionsUrlPrefix('not a url'), null);
});

test('rejects a Functions URL prefix in a different region', () => {
  const errors = validateClientConfig({
    AGORA_APP_ID: appId,
    FUNCTIONS_REGION: 'europe-west1',
    FUNCTIONS_URL_PREFIX: 'https://us-central1-my-project.cloudfunctions.net',
  });
  assert.equal(errors.length, 1);
  assert.match(errors[0], /FUNCTIONS_URL_PREFIX/);
});

test('treats a missing FUNCTIONS_REGION as us-central1', () => {
  assert.deepEqual(
    validateClientConfig({
      AGORA_APP_ID: appId,
      FUNCTIONS_URL_PREFIX: 'https://us-central1-my-project.cloudfunctions.net',
    }),
    [],
  );
  assert.equal(
    validateClientConfig({
      AGORA_APP_ID: appId,
      FUNCTIONS_URL_PREFIX: 'https://europe-west1-my-project.cloudfunctions.net',
    }).length,
    1,
  );
});

test('accepts matching or custom-domain prefixes', () => {
  for (const prefix of [
    'https://europe-west1-my-project.cloudfunctions.net',
    'https://functions.example.org',
  ]) {
    assert.deepEqual(
      validateClientConfig({
        AGORA_APP_ID: appId,
        FUNCTIONS_REGION: 'europe-west1',
        FUNCTIONS_URL_PREFIX: prefix,
      }),
      [],
    );
  }
});

test('accepts known Agora areas and rejects unknown ones', () => {
  for (const area of ['', 'GLOBAL', 'EU', 'eu']) {
    assert.deepEqual(validateClientConfig({ AGORA_APP_ID: appId, AGORA_AREA: area }), []);
  }
  const errors = validateClientConfig({ AGORA_APP_ID: appId, AGORA_AREA: 'EUROPE' });
  assert.equal(errors.length, 1);
  assert.match(errors[0], /AGORA_AREA/);
});

test('checks the media upload provider and its bucket', () => {
  assert.deepEqual(validateClientConfig({ AGORA_APP_ID: appId }), []);
  assert.deepEqual(
    validateClientConfig({ AGORA_APP_ID: appId, MEDIA_UPLOAD_PROVIDER: 'cloudinary' }),
    [],
  );
  assert.deepEqual(
    validateClientConfig({
      AGORA_APP_ID: appId,
      MEDIA_UPLOAD_PROVIDER: 'firebase',
      FIREBASE_STORAGE_BUCKET: 'my-eu-bucket',
    }),
    [],
  );
  assert.match(
    validateClientConfig({ AGORA_APP_ID: appId, MEDIA_UPLOAD_PROVIDER: 'Firebase' })[0],
    /MEDIA_UPLOAD_PROVIDER/,
  );
  assert.match(
    validateClientConfig({ AGORA_APP_ID: appId, MEDIA_UPLOAD_PROVIDER: 'firebase' })[0],
    /FIREBASE_STORAGE_BUCKET/,
  );
});

test('the CLI exits non-zero on an invalid file and zero on a valid one', () => {
  const directory = mkdtempSync(join(tmpdir(), 'frankly-validate-config-'));
  try {
    const bad = join(directory, 'bad.env');
    const good = join(directory, 'good.env');
    writeFileSync(bad, 'AGORA_APP_ID=\n');
    writeFileSync(good, `AGORA_APP_ID=${appId}\n`);
    assert.throws(() => execFileSync(process.execPath, [scriptPath, bad], { stdio: 'pipe' }));
    execFileSync(process.execPath, [scriptPath, good], { stdio: 'pipe' });
  } finally {
    rmSync(directory, { recursive: true, force: true });
  }
});
