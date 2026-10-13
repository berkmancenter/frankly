#!/usr/bin/env node

// Checks a client dart-define file (.env or .json) before `flutter build web`,
// so a misconfigured build fails in CI instead of shipping a broken client.
//
//   node scripts/validate-client-config.mjs client/.env

import { readFileSync } from 'node:fs';
import { pathToFileURL } from 'node:url';

const defaultFunctionsRegion = 'us-central1';
const agoraAreas = new Set(['GLOBAL', 'EU', 'NA', 'AS', 'JP', 'IN', 'CN']);
const regionPattern =/^[a-z]+-[a-z]+[0-9]+$/;
const cloudFunctionsHostPattern = /^([a-z]+-[a-z]+[0-9]+)-(.+)\.cloudfunctions\.net$/;

export function parseDartDefines(source, fileName = '.env') {
  if (fileName.endsWith('.json')) return JSON.parse(source);
  return Object.fromEntries(
    source
      .split(/\r?\n/)
      .filter((line) => /^\s*[A-Z_][A-Z0-9_]*\s*=/.test(line))
      .map((line) => {
        const separator = line.indexOf('=');
        const raw = line.slice(separator + 1).trim();
        const quoted = /^(["'])(.*?)\1/.exec(raw);
        // Unquoted values may carry a trailing ` # comment`.
        const value = quoted ? quoted[2] : raw.replace(/\s+#.*$/, '');
        return [line.slice(0, separator).trim(), value];
      }),
  );
}

/// Region named by a FUNCTIONS_URL_PREFIX, or null for shapes we can't read
/// (custom domains, proxies).
export function regionOfFunctionsUrlPrefix(prefix) {
  let url;
  try {
    url = new URL(prefix);
  } catch {
    return null;
  }
  const hostMatch = cloudFunctionsHostPattern.exec(url.hostname);
  if (hostMatch) return hostMatch[1];
  const segments = url.pathname.split('/').filter(Boolean);
  if (segments.length === 2 && regionPattern.test(segments[1])) return segments[1];
  return null;
}

export function validateClientConfig(config) {
  const errors = [];

  if (!/^[0-9a-f]{32}$/i.test(config.AGORA_APP_ID ?? '')) {
    errors.push(
      'AGORA_APP_ID must be a 32-character hexadecimal Agora application ID. ' +
        'Refusing to build a client that cannot join meetings.',
    );
  }

  // Unknown values silently fall back to global routing in the client, which
  // would defeat a deployment that must stay in one area.
  const agoraArea = (config.AGORA_AREA ?? '').trim().toUpperCase();
  if (agoraArea && !agoraAreas.has(agoraArea)) {
    errors.push(
      `AGORA_AREA must be one of ${[...agoraAreas].join(', ')} (got "${config.AGORA_AREA}").`,
    );
  }

  const region = (config.FUNCTIONS_REGION ?? '').trim() || defaultFunctionsRegion;
  const prefix = (config.FUNCTIONS_URL_PREFIX ?? '').trim();
  if (prefix) {
    const prefixRegion = regionOfFunctionsUrlPrefix(prefix);
    if (prefixRegion && prefixRegion !== region) {
      errors.push(
        `FUNCTIONS_URL_PREFIX (${prefix}) points at ${prefixRegion}, but ` +
          `FUNCTIONS_REGION is ${region}. Direct HTTP calls (downloads, image ` +
          'proxy, artifact repair) would go to the wrong region. Make them match.',
      );
    }
  }

  return errors;
}

function main() {
  const file = process.argv[2];
  if (!file) {
    console.error('Usage: node scripts/validate-client-config.mjs <dart-define-file>');
    process.exit(2);
  }
  const config = parseDartDefines(readFileSync(file, 'utf8'), file);
  const errors = validateClientConfig(config);
  if (errors.length > 0) {
    for (const error of errors) console.error(`Client config error: ${error}`);
    process.exit(1);
  }
  console.log('Client configuration is valid.');
}

if (import.meta.url === pathToFileURL(process.argv[1] ?? '').href) {
  main();
}
