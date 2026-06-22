#!/usr/bin/env node

import { readFileSync, writeFileSync } from 'node:fs';
import { resolve } from 'node:path';

const defaultRegion = 'us-central1';
const defaultInput = resolve('firebase.json');
const defaultOutput = resolve('firebase.generated.json');
const rewriteFunctionIds = new Set(['ShareLink', 'CalendarFeedIcs', 'CalendarFeedRss']);

function parseArgs(argv) {
  const options = {
    region: process.env.FUNCTIONS_REGION?.trim() || defaultRegion,
    input: defaultInput,
    output: defaultOutput,
    inPlace: false,
  };

  for (let index = 0; index < argv.length; index += 1) {
    const arg = argv[index];
    if (arg === '--region') {
      options.region = argv[++index] ?? defaultRegion;
    } else if (arg === '--input') {
      options.input = resolve(argv[++index] ?? defaultInput);
    } else if (arg === '--output') {
      options.output = resolve(argv[++index] ?? defaultOutput);
    } else if (arg === '--in-place') {
      options.inPlace = true;
    } else {
      throw new Error(`Unknown argument: ${arg}`);
    }
  }

  if (options.inPlace) {
    options.output = options.input;
  }

  if (!options.region.trim()) {
    options.region = defaultRegion;
  }

  return options;
}

function withFunctionRegion(rewrites, region) {
  return rewrites.map((rewrite) => {
    const functionTarget =
      typeof rewrite.function === 'string'
        ? rewrite.function
        : rewrite.function?.functionId;
    if (!rewriteFunctionIds.has(functionTarget)) {
      return rewrite;
    }

    return {
      ...rewrite,
      function: {
        functionId: functionTarget,
        region,
      },
    };
  });
}

function main() {
  const options = parseArgs(process.argv.slice(2));
  const config = JSON.parse(readFileSync(options.input, 'utf8'));
  const rewrites = config.hosting?.rewrites ?? [];

  const renderedConfig = {
    ...config,
    hosting: {
      ...config.hosting,
      rewrites: withFunctionRegion(rewrites, options.region),
    },
  };

  writeFileSync(options.output, `${JSON.stringify(renderedConfig, null, 2)}\n`);
}

main();
