// Run with the Storage emulator:
//   firebase emulators:exec --only storage --project fake-project-id 'npm test'
import { readFileSync } from 'node:fs';
import { after, before, test } from 'node:test';
import { fileURLToPath } from 'node:url';

import {
  assertFails,
  assertSucceeds,
  initializeTestEnvironment,
} from '@firebase/rules-unit-testing';

const rules = readFileSync(fileURLToPath(new URL('../storage.rules', import.meta.url)), 'utf8');
const [host, port] = (process.env.FIREBASE_STORAGE_EMULATOR_HOST ?? '127.0.0.1:9199').split(':');

const MB = 1024 * 1024;
// Each call returns a new, valid file name so tests don't depend on the
// emulator being emptied between them.
let counter = 1700000000000;
const name = (extension) => `${counter++}-0123456789abcdef.${extension}`;

let env;

before(async () => {
  env = await initializeTestEnvironment({
    projectId: 'fake-project-id',
    storage: { rules, host, port: Number(port) },
  });
});

after(async () => {
  await env.cleanup();
});

function storageFor(uid, provider = 'password') {
  return uid == null
    ? env.unauthenticatedContext().storage()
    : env.authenticatedContext(uid, { firebase: { sign_in_provider: provider } }).storage();
}

function upload(storage, path, size, contentType) {
  return storage.ref(path).put(new Uint8Array(size), { contentType });
}

test('owner can upload each allowed image and video type', async () => {
  const storage = storageFor('alice');
  for (const [extension, contentType] of [
    ['jpg', 'image/jpeg'],
    ['png', 'image/png'],
    ['gif', 'image/gif'],
    ['webp', 'image/webp'],
    ['mp4', 'video/mp4'],
    ['webm', 'video/webm'],
  ]) {
    await assertSucceeds(upload(storage, `media/alice/${name(extension)}`, 1024, contentType));
  }
});

test('owner can read their file through the SDK', async () => {
  const path = `media/alice/${name('png')}`;
  await assertSucceeds(upload(storageFor('alice'), path, 10, 'image/png'));
  await assertSucceeds(storageFor('alice').ref(path).getDownloadURL());
});

test('others cannot read or upload into a user folder', async () => {
  const path = `media/alice/${name('png')}`;
  await assertSucceeds(upload(storageFor('alice'), path, 10, 'image/png'));
  await assertFails(storageFor('bob').ref(path).getDownloadURL());
  await assertFails(upload(storageFor('bob'), `media/alice/${name('jpg')}`, 10, 'image/jpeg'));
});

test('anonymous and signed-out users cannot upload', async () => {
  await assertFails(upload(storageFor('anon', 'anonymous'), `media/anon/${name('png')}`, 10, 'image/png'));
  await assertFails(upload(storageFor(null), `media/alice/${name('png')}`, 10, 'image/png'));
});

test('HTML, SVG and QuickTime uploads are rejected', async () => {
  const storage = storageFor('alice');
  await assertFails(upload(storage, `media/alice/${name('png')}`, 10, 'text/html'));
  await assertFails(upload(storage, `media/alice/${name('png')}`, 10, 'image/svg+xml'));
  await assertFails(upload(storage, 'media/alice/1700000000000-0123456789abcdef.svg', 10, 'image/svg+xml'));
  await assertFails(upload(storage, 'media/alice/1700000000000-0123456789abcdef.html', 10, 'text/html'));
  await assertFails(upload(storage, 'media/alice/1700000000000-0123456789abcdef.mov', 10, 'video/quicktime'));
  await assertFails(upload(storage, `media/alice/${name('mp4')}`, 10, 'video/quicktime'));
});

test('the extension must match the content type and the name shape', async () => {
  const storage = storageFor('alice');
  await assertFails(upload(storage, `media/alice/${name('jpg')}`, 10, 'image/png'));
  await assertFails(upload(storage, `media/alice/${name('mp4')}`, 10, 'image/png'));
  await assertFails(upload(storage, 'media/alice/profile.png', 10, 'image/png'));
  await assertFails(upload(storage, `media/alice/${name('png')}.html`, 10, 'image/png'));
});

test('size limits are enforced', async () => {
  const storage = storageFor('alice');
  await assertSucceeds(upload(storage, `media/alice/${name('png')}`, 10 * MB, 'image/png'));
  await assertFails(upload(storage, `media/alice/${name('png')}`, 10 * MB + 1, 'image/png'));
});

test('an uploaded file cannot be replaced', async () => {
  const storage = storageFor('alice');
  const path = `media/alice/${name('png')}`;
  await assertSucceeds(upload(storage, path, 10, 'image/png'));
  await assertFails(upload(storage, path, 10, 'image/png'));
});

test('everything outside media/ is denied', async () => {
  const storage = storageFor('alice');
  await assertFails(upload(storage, `other/alice/${name('png')}`, 10, 'image/png'));
  await assertFails(upload(storage, `media/alice/nested/${name('png')}`, 10, 'image/png'));
  await assertFails(storage.ref('recordings/anything.mp4').getDownloadURL());
});
