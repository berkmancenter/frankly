/**
 * Generates client/lib/core/routing/react_routes.g.dart, the list of URLs Flutter must hand to the
 * React app with a full page load (Flutter navigates in-page, so the edge never sees those clicks).
 *
 * Run from client/new with: npm run routes:flutter
 * `assembleHosting.ts` refuses to run while the checked-in file is out of date.
 */
import { readFileSync, writeFileSync } from "node:fs";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";
import { compilePattern, loadConfig } from "../../../proxy/src/rules.mts";

const here = dirname(fileURLToPath(import.meta.url));
export const DART_FILE = join(here, "../../lib/core/routing/react_routes.g.dart");
const ROUTES_JSON = join(here, "../migrated-routes.json");

export function renderDart(): string {
  const alternatives = loadConfig(ROUTES_JSON).routes.map((route) =>
    compilePattern(route).source.slice(1, -1).replaceAll("\\/", "/"),
  );
  return `// Generated from client/new/migrated-routes.json by \`npm run routes:flutter\` in client/new.
// Do not edit by hand.

/// Paths the React app serves. Matched against a URI path, without its query string.
final reactRoutes = RegExp(
    r'^(?:${alternatives.join("|")})$');
`;
}

export function isDartCurrent(): boolean {
  try {
    return readFileSync(DART_FILE, "utf8") === renderDart();
  } catch {
    return false;
  }
}

if (process.argv[1] === fileURLToPath(import.meta.url)) {
  writeFileSync(DART_FILE, renderDart());
  console.log(`Wrote ${DART_FILE}`);
}
