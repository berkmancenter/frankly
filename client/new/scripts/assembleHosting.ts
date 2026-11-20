/**
 * Assembles what the `react` Firebase Hosting target deploys: React owns the pages in
 * migrated-routes.json and the Flutter build answers everything else.
 *
 * Hosting rewrites can't point at another site, so one deploy folder holds both apps:
 *
 *   <out>/              the Flutter build, minus its index.html (a static file would win over
 *                       the rewrites below and capture "/")
 *   <out>/_new/         the React build made with `npm run build:proxied`
 *   <out>/media/        React's public files, which it references by absolute URL
 *
 * It also rewrites the `react` entry in firebase.json so routing stays in step with its sources:
 *
 *   1. the `web` target's function rewrites (/api/*, /share/**, calendar feeds)
 *   2. one regex rewrite per route in migrated-routes.json, to the React index
 *   3. the `web` target's final catch-all, which serves Flutter
 *
 * Redirects, ignore rules and headers are copied from `web`, plus long-lived caching for React's
 * hashed assets. Everything else in the entry (target, public) is left as is.
 *
 * Run from client/new with: npm run build:hosting, then `firebase deploy --only hosting:react`.
 */
import { cpSync, existsSync, mkdirSync, readFileSync, rmSync, writeFileSync } from "node:fs";
import { dirname, join, relative } from "node:path";
import { fileURLToPath } from "node:url";
import { compilePattern, loadConfig } from "../../../proxy/src/rules.mts";

const here = dirname(fileURLToPath(import.meta.url));
const CLIENT_DIR = join(here, "..");
const REPO_ROOT = join(CLIENT_DIR, "../..");
const FIREBASE_JSON = join(REPO_ROOT, "firebase.json");
const FLUTTER_DIR = join(REPO_ROOT, "client/build/web");
const REACT_DIR = join(CLIENT_DIR, "dist");
const OUT_DIR = join(CLIENT_DIR, "hosting");
const ROUTES_JSON = join(CLIENT_DIR, "migrated-routes.json");

type Json = Record<string, unknown>;
type Rewrite = { source?: string; regex?: string; function?: string; destination?: string };

function fail(message: string): never {
  console.error(`assembleHosting: ${message}`);
  process.exit(1);
}

function requireFile(path: string, hint: string): void {
  if (!existsSync(path)) fail(`${relative(REPO_ROOT, path)} not found. ${hint}`);
}

// RegExp#source escapes "/", which hosting's RE2 patterns don't need.
function routeRegex(pattern: string): string {
  return compilePattern(pattern).source.replaceAll("\\/", "/");
}

function assemble(assetBase: string, staticPrefixes: string[]): void {
  requireFile(join(FLUTTER_DIR, "index.html"), "Build Flutter first (./build-all.sh or flutter build web).");
  const reactIndex = join(REACT_DIR, "index.html");
  requireFile(reactIndex, "Run `npm run build:proxied` first.");
  if (!readFileSync(reactIndex, "utf8").includes(`"${assetBase}assets/`)) {
    fail(`${relative(REPO_ROOT, REACT_DIR)} wasn't built for ${assetBase}. Use \`npm run build:proxied\`, not \`npm run build\`.`);
  }

  rmSync(OUT_DIR, { recursive: true, force: true });
  cpSync(FLUTTER_DIR, OUT_DIR, { recursive: true });
  rmSync(join(OUT_DIR, "index.html"));

  const reactOut = join(OUT_DIR, assetBase);
  if (existsSync(reactOut)) fail(`Flutter's build already has ${assetBase}.`);
  mkdirSync(dirname(reactOut), { recursive: true });
  cpSync(REACT_DIR, reactOut, { recursive: true });

  for (const prefix of staticPrefixes) {
    const from = join(reactOut, prefix);
    const to = join(OUT_DIR, prefix);
    if (!existsSync(from)) fail(`React's build has no ${prefix} to serve.`);
    if (existsSync(to)) fail(`Flutter's build already has ${prefix}.`);
    cpSync(from, to, { recursive: true });
  }
}

// Replaces the `react` hosting entry in place, so the rest of the file keeps its formatting.
function writeReactEntry(source: string, entry: Json): string {
  const marker = source.indexOf('"target": "react"');
  if (marker === -1) fail(`no "react" hosting target in firebase.json.`);
  const start = source.lastIndexOf("{", marker);
  let depth = 0;
  let end = start;
  for (; end < source.length; end++) {
    if (source[end] === "{") depth++;
    if (source[end] === "}" && --depth === 0) break;
  }
  const block = JSON.stringify(entry, null, 2).replaceAll("\n", "\n    ");
  return source.slice(0, start) + block + source.slice(end + 1);
}

function main(): void {
  const config = loadConfig(ROUTES_JSON);
  const source = readFileSync(FIREBASE_JSON, "utf8");
  const hosting = (JSON.parse(source) as { hosting: Json[] }).hosting;
  const web = hosting.find((site) => site.target === "web");
  const react = hosting.find((site) => site.target === "react");
  if (!web || !react) fail(`firebase.json needs both a "web" and a "react" hosting target.`);

  const webRewrites = web.rewrites as Rewrite[];
  const catchAll = webRewrites.at(-1);
  if (catchAll?.source !== "**") fail(`the "web" rewrites must end with the "**" catch-all.`);

  assemble(config.assetBase, config.staticPrefixes);

  const pages: Rewrite[] = config.routes.map((route) => ({
    regex: routeRegex(route),
    destination: `${config.assetBase}index.html`,
  }));
  const entry: Json = {
    ...react,
    public: relative(REPO_ROOT, OUT_DIR),
    ignore: web.ignore,
    redirects: web.redirects,
    headers: [
      ...(web.headers as Json[]),
      {
        source: `${config.assetBase}assets/**`,
        headers: [{ key: "Cache-Control", value: "public, max-age=31536000, immutable" }],
      },
    ],
    rewrites: [...webRewrites.slice(0, -1), ...pages, catchAll],
  };
  if (!entry.ignore) delete entry.ignore;
  if (!entry.redirects) delete entry.redirects;

  writeFileSync(FIREBASE_JSON, writeReactEntry(source, entry));
  console.log(
    `Assembled ${relative(REPO_ROOT, OUT_DIR)} and updated the "react" target (${pages.length} React routes).\n` +
      `Deploy with: firebase deploy --only hosting:react`,
  );
}

main();
