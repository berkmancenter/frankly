import { readFileSync } from 'node:fs';

const file = process.argv[2];
if (!file) throw new Error('Usage: node scripts/validate-client-config.mjs <dart-define-file>');
const source = readFileSync(file, 'utf8');
const config = file.endsWith('.json') ? JSON.parse(source) : Object.fromEntries(
  source.split(/\r?\n/).filter(line => /^\s*[A-Z_]+\s*=/.test(line)).map(line => {
    const separator = line.indexOf('=');
    return [line.slice(0, separator).trim(), line.slice(separator + 1).trim().replace(/^(["'])(.*)\1$/, '$2')];
  }),
);
if (!/^[0-9a-f]{32}$/i.test(config.AGORA_APP_ID ?? '')) {
  throw new Error('AGORA_APP_ID must be a 32-character hexadecimal Agora application ID. Refusing to build a client that cannot join meetings.');
}
console.log('Client Agora configuration is valid.');
